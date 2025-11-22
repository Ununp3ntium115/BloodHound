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
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"os/exec"
	"path/filepath"
	"strings"

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
func (c *PyroDetectorClient) callMCPMethod(method string, params map[string]interface{}) (map[string]interface{}, error) {
	// Build JSON-RPC 2.0 request
	request := map[string]interface{}{
		"jsonrpc": "2.0",
		"id":      1,
		"method":  method,
		"params":  params,
	}

	requestJSON, err := json.Marshal(request)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Execute the MCP server binary
	cmd := exec.Command(c.serverPath)
	cmd.Stdin = strings.NewReader(string(requestJSON) + "\n")

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, fmt.Errorf("failed to create stdout pipe: %w", err)
	}

	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("failed to start MCP server: %w", err)
	}
	defer cmd.Process.Kill()

	// Read response
	responseBytes, err := io.ReadAll(stdout)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	if err := cmd.Wait(); err != nil {
		return nil, fmt.Errorf("MCP server exited with error: %w", err)
	}

	// Parse JSON-RPC 2.0 response
	var response map[string]interface{}
	if err := json.Unmarshal(responseBytes, &response); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w", err)
	}

	// Check for errors
	if errVal, ok := response["error"]; ok {
		return nil, fmt.Errorf("MCP server error: %v", errVal)
	}

	// Return result
	if result, ok := response["result"]; ok {
		if resultMap, ok := result.(map[string]interface{}); ok {
			return resultMap, nil
		}
		return map[string]interface{}{"result": result}, nil
	}

	return nil, fmt.Errorf("no result in response")
}

// ListDetonators lists available Fire Marshal detonators
func (s *Resources) ListDetonators(response http.ResponseWriter, request *http.Request) {
	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod("pyro_list_detonators", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to list detonators", "error", err)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to list detonators: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusOK, response)
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

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod("pyro_execute_detonator", params)
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to execute detonator", "error", err, "detonator_id", detonatorID)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to execute detonator: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusOK, response)
}

// CreateCase creates a new investigation case
func (s *Resources) CreateCase(response http.ResponseWriter, request *http.Request) {
	var params map[string]interface{}
	if err := json.NewDecoder(request.Body).Decode(&params); err != nil {
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusBadRequest, fmt.Sprintf("Invalid request body: %v", err), request), response)
		return
	}

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod("pyro_create_case", params)
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to create case", "error", err)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to create case: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusCreated, response)
}

// ListAgents lists all Fire Marshal agents
func (s *Resources) ListAgents(response http.ResponseWriter, request *http.Request) {
	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod("pyro_list_agents", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to list agents", "error", err)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to list agents: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusOK, response)
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

	client := NewPyroDetectorClient(s.Config)
	result, err := client.callMCPMethod("pyro_execute_pql", params)
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to execute PQL query", "error", err)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to execute PQL query: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusOK, response)
}

// GetHealth checks the health of the PYRO Detector service
func (s *Resources) GetPyroDetectorHealth(response http.ResponseWriter, request *http.Request) {
	client := NewPyroDetectorClient(s.Config)

	result, err := client.callMCPMethod("pyro_health", map[string]interface{}{})
	if err != nil {
		slog.ErrorContext(request.Context(), "Failed to get health status", "error", err)
		api.WriteErrorResponse(request.Context(), api.BuildErrorResponse(http.StatusInternalServerError, fmt.Sprintf("Failed to get health status: %v", err), request), response)
		return
	}

	api.WriteBasicResponse(request.Context(), result, http.StatusOK, response)
}

