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
 * PYRO Detector View - Network Mapping and Visualization
 * 
 * A Zenmap-like interface for visualizing network topology, investigations,
 * and Fire Marshal detonator results. Integrates with PYRO Platform Ignition
 * via the PYRO Detector MCP server.
 */

import { Box, Paper, Typography, Grid, Card, CardContent, Button, Chip, CircularProgress } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import { SigmaContainer } from '@react-sigma/core';
import '@react-sigma/core/lib/react-sigma.min.css';
import { MultiDirectedGraph } from 'graphology';
import { Attributes } from 'graphology-types';
import { FC, useState, useCallback, useMemo, useRef } from 'react';
import { useQuery } from '@tanstack/react-query';
import SigmaChart from 'src/components/SigmaChart';
import { useAppSelector } from 'src/store';

interface DetonatorResult {
    id: string;
    name: string;
    status: 'running' | 'completed' | 'failed';
    timestamp: string;
    nodes?: NetworkNode[];
    edges?: NetworkEdge[];
}

interface NetworkNode {
    id: string;
    label: string;
    type: 'host' | 'network' | 'service' | 'agent';
    properties?: Record<string, any>;
}

interface NetworkEdge {
    id: string;
    source: string;
    target: string;
    type: string;
    properties?: Record<string, any>;
}

const PyroDetectorView: FC = () => {
    const theme = useTheme();
    const darkMode = useAppSelector((state) => state.global.view.darkMode);
    
    const [selectedDetonator, setSelectedDetonator] = useState<string | null>(null);
    const [graphologyGraph, setGraphologyGraph] = useState<MultiDirectedGraph<Attributes, Attributes, Attributes>>(
        new MultiDirectedGraph()
    );
    const [highlightedItem, setHighlightedItem] = useState<string | null>(null);
    
    const sigmaChartRef = useRef<any>(null);

    // TODO: Replace with actual API call to PYRO Detector MCP server
    // This would call the pyro_list_detonators and pyro_execute_detonator methods
    const { data: detonators, isLoading: detonatorsLoading } = useQuery({
        queryKey: ['pyro-detectors'],
        queryFn: async () => {
            // Placeholder - would call PYRO Detector MCP server
            // Example: await pyroDetectorClient.listDetonators()
            return [
                { id: '1', name: 'Network Topology Scan', description: 'Map network topology' },
                { id: '2', name: 'Host Discovery', description: 'Discover active hosts' },
                { id: '3', name: 'Service Enumeration', description: 'Enumerate services' },
            ];
        },
    });

    // TODO: Replace with actual API call to get detonator results
    const { data: detonatorResults, isLoading: resultsLoading } = useQuery({
        queryKey: ['pyro-detector-results', selectedDetonator],
        queryFn: async () => {
            if (!selectedDetonator) return null;
            // Placeholder - would call PYRO Detector MCP server
            // Example: await pyroDetectorClient.executeDetonator(selectedDetonator)
            return {
                id: selectedDetonator,
                name: 'Network Topology Scan',
                status: 'completed' as const,
                timestamp: new Date().toISOString(),
                nodes: [
                    { id: 'node1', label: 'Host 1', type: 'host' },
                    { id: 'node2', label: 'Host 2', type: 'host' },
                    { id: 'node3', label: 'Network Segment', type: 'network' },
                ],
                edges: [
                    { id: 'edge1', source: 'node1', target: 'node3', type: 'connected' },
                    { id: 'edge2', source: 'node2', target: 'node3', type: 'connected' },
                ],
            };
        },
        enabled: !!selectedDetonator,
    });

    // Build graph from detonator results
    useMemo(() => {
        if (!detonatorResults?.nodes || !detonatorResults?.edges) {
            setGraphologyGraph(new MultiDirectedGraph());
            return;
        }

        const graph = new MultiDirectedGraph();
        
        // Add nodes
        detonatorResults.nodes.forEach((node) => {
            graph.addNode(node.id, {
                label: node.label,
                type: node.type,
                size: node.type === 'host' ? 15 : 20,
                color: node.type === 'host' ? theme.palette.primary.main : theme.palette.secondary.main,
                ...node.properties,
            });
        });

        // Add edges
        detonatorResults.edges.forEach((edge) => {
            graph.addEdge(edge.source, edge.target, {
                label: edge.type,
                type: edge.type,
                ...edge.properties,
            });
        });

        setGraphologyGraph(graph);
    }, [detonatorResults, theme]);

    const handleNodeClick = useCallback((id: string) => {
        setHighlightedItem(id);
    }, []);

    const handleEdgeClick = useCallback((id: string) => {
        setHighlightedItem(id);
    }, []);

    const handleStageClick = useCallback(() => {
        setHighlightedItem(null);
    }, []);

    const handleContextMenu = useCallback((event: any) => {
        // Handle context menu for nodes
        console.log('Context menu:', event);
    }, []);

    const handleExecuteDetonator = useCallback((detonatorId: string) => {
        setSelectedDetonator(detonatorId);
    }, []);

    return (
        <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column', p: 2 }}>
            <Typography variant="h4" gutterBottom>
                🔥 PYRO Detector - Network Mapping
            </Typography>
            <Typography variant="body2" color="text.secondary" gutterBottom>
                Zenmap-like network visualization and investigation tool integrated with PYRO Platform Ignition
            </Typography>

            <Grid container spacing={2} sx={{ mt: 1, flex: 1, minHeight: 0 }}>
                {/* Left Panel - Detonators and Controls */}
                <Grid item xs={12} md={3}>
                    <Paper sx={{ p: 2, height: '100%', overflow: 'auto' }}>
                        <Typography variant="h6" gutterBottom>
                            Fire Marshal Detonators
                        </Typography>
                        
                        {detonatorsLoading ? (
                            <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
                                <CircularProgress size={24} />
                            </Box>
                        ) : (
                            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                                {detonators?.map((detonator: any) => (
                                    <Card 
                                        key={detonator.id}
                                        sx={{ 
                                            cursor: 'pointer',
                                            border: selectedDetonator === detonator.id ? 2 : 1,
                                            borderColor: selectedDetonator === detonator.id 
                                                ? theme.palette.primary.main 
                                                : 'divider',
                                        }}
                                        onClick={() => handleExecuteDetonator(detonator.id)}
                                    >
                                        <CardContent>
                                            <Typography variant="subtitle1" fontWeight="bold">
                                                {detonator.name}
                                            </Typography>
                                            <Typography variant="body2" color="text.secondary">
                                                {detonator.description}
                                            </Typography>
                                            {selectedDetonator === detonator.id && (
                                                <Chip 
                                                    label="Active" 
                                                    color="primary" 
                                                    size="small" 
                                                    sx={{ mt: 1 }}
                                                />
                                            )}
                                        </CardContent>
                                    </Card>
                                ))}
                            </Box>
                        )}

                        {/* Investigation Controls */}
                        <Box sx={{ mt: 3 }}>
                            <Typography variant="h6" gutterBottom>
                                Investigation Controls
                            </Typography>
                            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                                <Button 
                                    variant="outlined" 
                                    fullWidth
                                    onClick={() => {
                                        // TODO: Create new case via PYRO Detector
                                        console.log('Create new case');
                                    }}
                                >
                                    Create Case
                                </Button>
                                <Button 
                                    variant="outlined" 
                                    fullWidth
                                    onClick={() => {
                                        // TODO: List agents via PYRO Detector
                                        console.log('List agents');
                                    }}
                                >
                                    List Agents
                                </Button>
                                <Button 
                                    variant="outlined" 
                                    fullWidth
                                    onClick={() => {
                                        // TODO: Execute PQL query via PYRO Detector
                                        console.log('Execute PQL');
                                    }}
                                >
                                    Execute PQL Query
                                </Button>
                            </Box>
                        </Box>

                        {/* Status */}
                        {detonatorResults && (
                            <Box sx={{ mt: 3 }}>
                                <Typography variant="h6" gutterBottom>
                                    Status
                                </Typography>
                                <Chip 
                                    label={detonatorResults.status}
                                    color={detonatorResults.status === 'completed' ? 'success' : 'default'}
                                    sx={{ mb: 1 }}
                                />
                                <Typography variant="caption" display="block" color="text.secondary">
                                    {new Date(detonatorResults.timestamp).toLocaleString()}
                                </Typography>
                                <Typography variant="caption" display="block" color="text.secondary">
                                    Nodes: {detonatorResults.nodes?.length || 0}
                                </Typography>
                                <Typography variant="caption" display="block" color="text.secondary">
                                    Edges: {detonatorResults.edges?.length || 0}
                                </Typography>
                            </Box>
                        )}
                    </Paper>
                </Grid>

                {/* Right Panel - Network Visualization */}
                <Grid item xs={12} md={9}>
                    <Paper sx={{ p: 2, height: '100%', position: 'relative' }}>
                        {resultsLoading ? (
                            <Box sx={{ 
                                display: 'flex', 
                                justifyContent: 'center', 
                                alignItems: 'center', 
                                height: '100%' 
                            }}>
                                <CircularProgress />
                            </Box>
                        ) : graphologyGraph.order === 0 ? (
                            <Box sx={{ 
                                display: 'flex', 
                                justifyContent: 'center', 
                                alignItems: 'center', 
                                height: '100%',
                                flexDirection: 'column',
                                gap: 2
                            }}>
                                <Typography variant="h6" color="text.secondary">
                                    Select a detonator to visualize network topology
                                </Typography>
                                <Typography variant="body2" color="text.secondary">
                                    Results will appear here as a network graph
                                </Typography>
                            </Box>
                        ) : (
                            <Box sx={{ height: '100%', minHeight: 400 }}>
                                <SigmaChart
                                    ref={sigmaChartRef}
                                    graph={graphologyGraph}
                                    highlightedItem={highlightedItem}
                                    onClickNode={handleNodeClick}
                                    onClickEdge={handleEdgeClick}
                                    onClickStage={handleStageClick}
                                    handleContextMenu={handleContextMenu}
                                    showNodeLabels={true}
                                    showEdgeLabels={true}
                                />
                            </Box>
                        )}
                    </Paper>
                </Grid>
            </Grid>
        </Box>
    );
};

export default PyroDetectorView;

