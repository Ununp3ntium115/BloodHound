// Copyright 2025 Specter Ops, Inc.
//
// Licensed under the Apache License, Version 2.0
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

package v2

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/gorilla/mux"
	"github.com/specterops/bloodhound/cmd/api/src/api"
	"github.com/specterops/bloodhound/cmd/api/src/config"
)

const (
	URIPathVariableDetonatorID = "detonator_id"
	URIPathVariableCaseID      = "case_id"
	URIPathVariableAgentID     = "agent_id"
)

// PyroDetectorClient handles communication with the PYRO Detector MCP server
type PyroDetectorClient struct {
	config     config.Configuration
	serverPath string
}

// NewPyroDetectorClient creates a new PYRO Detector client
func NewPyroDetectorClient(cfg config.Configuration) *PyroDetectorClient {
	// Default to looking for the binary in the same directory or target/release
	serverPath := filepath.Join(".", "target", "release", "pyro-detector")
	if cfg.PyroDetectorPath != "" {
		serverPath = cfg.PyroDetectorPath
	}
	return &PyroDetectorClient{
		config:     cfg,
		serverPath: serverPath,
	}
}

// callMCPMethod calls a method on the PYRO Detector MCP server via stdio
func (c *PyroDetectorClient) callMCPMethod(ctx context.Context, method string, params map[string]interface{}) (map[string]interface{}, error) {
	startTime := time.Now()
	
	// Log request
	slog.InfoContext(ctx, "PYRO Detector MCP request",
		"method", method,
		"params", params,
		"server_path", c.serverPath,
	)

	// Build JSON-RPC 2.0 request
	request := map[string]interface{}{
		"jsonrpc": "2.0",
		"id":      1,
		"method":  method,
		"params":  params,
	}

	requestJSON, err := json.Marshal(request)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to marshal MCP request",
			"method", method,
			"error", err,
		)
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Execute the MCP server binary
	cmd := exec.CommandContext(ctx, c.serverPath)
	cmd.Stdin = strings.NewReader(string(requestJSON) + "\n")

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		slog.ErrorContext(ctx, "Failed to create stdout pipe for MCP server",
			"method", method,
			"error", err,
		)
		return nil, fmt.Errorf("failed to create stdout pipe: %w", err)
	}

	if err := cmd.Start(); err != nil {
		slog.ErrorContext(ctx, "Failed to start MCP server",
			"method", method,
			"server_path", c.serverPath,
			"error", err,
		)
		return nil, fmt.Errorf("failed to start MCP server: %w", err)
	}
	defer cmd.Process.Kill()

	// Read response
	responseBytes, err := io.ReadAll(stdout)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to read MCP server response",
			"method", method,
			"error", err,
		)
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if err := cmd.Wait(); err != nil {
		slog.ErrorContext(ctx, "MCP server exited with error",
			"method", method,
			"error", err,
		)
		return nil, fmt.Errorf("MCP server exited with error: %w", err)
	}

	// Parse JSON-RPC 2.0 response
	var response map[string]interface{}
	if err := json.Unmarshal(responseBytes, &response); err != nil {
		slog.ErrorContext(ctx, "Failed to parse MCP server response",
			"method", method,
			"response_bytes", len(responseBytes),
			"error", err,
		)
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	duration := time.Since(startTime)

	// Check for errors
	if errVal, ok := response["error"]; ok {
		slog.ErrorContext(ctx, "MCP server returned error",
			"method", method,
			"error", errVal,
			"duration_ms", duration.Milliseconds(),
		)
		return nil, fmt.Errorf("MCP server error: %v", errVal)
	}

	// Return result
	var result map[string]interface{}
	if resultVal, ok := response["result"]; ok {
		if resultMap, ok := resultVal.(map[string]interface{}); ok {
			result = resultMap
		} else {
			result = map[string]interface{}{"result": resultVal}
		}
	} else {
		slog.WarnContext(ctx, "MCP server response missing result",
			"method", method,
			"response", response,
		)
		return nil, fmt.Errorf("no result in response")
	}

	// Log successful response
	slog.InfoContext(ctx, "PYRO Detector MCP response",
		"method", method,
		"duration_ms", duration.Milliseconds(),
		"success", true,
	)

	return result, nil
}

// ListDetonators lists available Fire Marshal detonators
func (s *Resources) ListDetonators(response http.ResponseWriter, request *http.Request) {
	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: ListDetonators",
		"method", "GET",
		"path", request.URL.Path,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod(ctx, "pyro_list_detonators", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(ctx, "Failed to list detonators",
			"error", err,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to list detonators: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: ListDetonators success",
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusOK,
	)

	api.WriteBasicResponse(ctx, result, http.StatusOK, response)
}

// ExecuteDetonator executes a Fire Marshal detonator
func (s *Resources) ExecuteDetonator(response http.ResponseWriter, request *http.Request) {
	var (
		requestVars = mux.Vars(request)
		detonatorID = requestVars[URIPathVariableDetonatorID]
	)

	if detonatorID == "" {
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, "detonator_id is required", request), response)
		return
	}

	// Parse request body for parameters
	var params map[string]interface{}
	if request.Body != nil {
		if err := json.NewDecoder(request.Body).Decode(&params); err != nil && err != io.EOF {
			api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, fmt.Sprintf("Invalid request body: %v", err), request), response)
			return
		}
	}
	if params == nil {
		params = make(map[string]interface{})
	}
	params["detonator_id"] = detonatorID

	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: ExecuteDetonator",
		"method", "POST",
		"path", request.URL.Path,
		"detonator_id", detonatorID,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod(ctx, "pyro_execute_detonator", params)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to execute detonator",
			"error", err,
			"detonator_id", detonatorID,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to execute detonator: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: ExecuteDetonator success",
		"detonator_id", detonatorID,
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusOK,
	)

	api.WriteBasicResponse(ctx, result, http.StatusOK, response)
}

// CreateCase creates a new investigation case
func (s *Resources) CreateCase(response http.ResponseWriter, request *http.Request) {
	var params map[string]interface{}
	if err := json.NewDecoder(request.Body).Decode(&params); err != nil {
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, fmt.Sprintf("Invalid request body: %v", err), request), response)
		return
	}

	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: CreateCase",
		"method", "POST",
		"path", request.URL.Path,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod(ctx, "pyro_create_case", params)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to create case",
			"error", err,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to create case: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: CreateCase success",
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusCreated,
	)

	api.WriteBasicResponse(ctx, result, http.StatusCreated, response)
}

// ListAgents lists all Fire Marshal agents
func (s *Resources) ListAgents(response http.ResponseWriter, request *http.Request) {
	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: ListAgents",
		"method", "GET",
		"path", request.URL.Path,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod(ctx, "pyro_list_agents", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(ctx, "Failed to list agents",
			"error", err,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to list agents: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: ListAgents success",
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusOK,
	)

	api.WriteBasicResponse(ctx, result, http.StatusOK, response)
}

// ExecutePQL executes a Pyro Query Language query
func (s *Resources) ExecutePQL(response http.ResponseWriter, request *http.Request) {
	var params map[string]interface{}
	if err := json.NewDecoder(request.Body).Decode(&params); err != nil {
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, fmt.Sprintf("Invalid request body: %v", err), request), response)
		return
	}

	if query, ok := params["query"].(string); !ok || query == "" {
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, "query parameter is required", request), response)
		return
	}

	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: ExecutePQL",
		"method", "POST",
		"path", request.URL.Path,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod(ctx, "pyro_execute_pql", params)
	if err != nil {
		slog.ErrorContext(ctx, "Failed to execute PQL query",
			"error", err,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to execute PQL query: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: ExecutePQL success",
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusOK,
	)

	api.WriteBasicResponse(ctx, result, http.StatusOK, response)
}

// GetHealth checks the health of the PYRO Detector service
func (s *Resources) GetPyroDetectorHealth(response http.ResponseWriter, request *http.Request) {
	startTime := time.Now()
	ctx := request.Context()
	
	slog.InfoContext(ctx, "PYRO Detector API: GetHealth",
		"method", "GET",
		"path", request.URL.Path,
		"remote_addr", request.RemoteAddr,
	)

	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod(ctx, "pyro_health", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(ctx, "Failed to get health status",
			"error", err,
			"duration_ms", time.Since(startTime).Milliseconds(),
		)
		api.WriteErrorResponse(ctx, api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to get health status: %v", err), request), response)
		return
	}

	slog.InfoContext(ctx, "PYRO Detector API: GetHealth success",
		"duration_ms", time.Since(startTime).Milliseconds(),
		"status", http.StatusOK,
	)

	api.WriteBasicResponse(ctx, result, http.StatusOK, response)
}

