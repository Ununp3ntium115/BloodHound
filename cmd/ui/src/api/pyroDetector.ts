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

/**
 * PYRO Detector API Client
 * 
 * Client for communicating with the PYRO Detector backend API endpoints
 * which proxy to the PYRO Detector MCP server.
 */

export interface Detonator {
    id: string;
    name: string;
    description?: string;
    category?: string;
    version?: string;
}

export interface DetonatorExecutionRequest {
    detonator_id: string;
    case_id?: string;
    parameters?: Record<string, any>;
}

export interface DetonatorExecutionResult {
    id: string;
    detonator_id: string;
    status: 'running' | 'completed' | 'failed';
    timestamp: string;
    results?: any;
    nodes?: NetworkNode[];
    edges?: NetworkEdge[];
}

export interface NetworkNode {
    id: string;
    label: string;
    type: 'host' | 'network' | 'service' | 'agent';
    properties?: Record<string, any>;
}

export interface NetworkEdge {
    id: string;
    source: string;
    target: string;
    type: string;
    properties?: Record<string, any>;
}

export interface Case {
    id: string;
    name: string;
    description?: string;
    created_at: string;
    status: string;
}

export interface Agent {
    id: string;
    name: string;
    status: string;
    last_seen?: string;
}

export interface PQLQuery {
    query: string;
    parameters?: Record<string, any>;
}

export interface HealthStatus {
    status: string;
    version: string;
    uptime_seconds: number;
    api_healthy: boolean;
    cdif_compliance: boolean;
}

const API_BASE = '/api/v2/pyro-detector';

async function apiRequest<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const response = await fetch(`${API_BASE}${endpoint}`, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...options?.headers,
        },
    });

    if (!response.ok) {
        const error = await response.json().catch(() => ({ message: 'Unknown error' }));
        throw new Error(error.message || `HTTP ${response.status}`);
    }

    return response.json();
}

export const pyroDetectorApi = {
    /**
     * List all available Fire Marshal detonators
     */
    listDetonators: async (): Promise<Detonator[]> => {
        const response = await apiRequest<{ detonators?: Detonator[] }>('/detonators');
        return response.detonators || [];
    },

    /**
     * Execute a Fire Marshal detonator
     */
    executeDetonator: async (request: DetonatorExecutionRequest): Promise<DetonatorExecutionResult> => {
        return apiRequest<DetonatorExecutionResult>(
            `/detonators/${request.detonator_id}/execute`,
            {
                method: 'POST',
                body: JSON.stringify({
                    case_id: request.case_id,
                    parameters: request.parameters,
                }),
            }
        );
    },

    /**
     * Create a new investigation case
     */
    createCase: async (name: string, description?: string): Promise<Case> => {
        return apiRequest<Case>('/cases', {
            method: 'POST',
            body: JSON.stringify({ name, description }),
        });
    },

    /**
     * List all Fire Marshal agents
     */
    listAgents: async (): Promise<Agent[]> => {
        const response = await apiRequest<{ agents?: Agent[] }>('/agents');
        return response.agents || [];
    },

    /**
     * Execute a Pyro Query Language (PQL) query
     */
    executePQL: async (query: string, parameters?: Record<string, any>): Promise<any> => {
        return apiRequest<any>('/pql', {
            method: 'POST',
            body: JSON.stringify({ query, parameters }),
        });
    },

    /**
     * Get health status of PYRO Detector service
     */
    getHealth: async (): Promise<HealthStatus> => {
        return apiRequest<HealthStatus>('/health');
    },
};

