# PYRO Detector View - Network Mapping Interface

🔥 **Zenmap-like Network Visualization for PYRO Platform Ignition** 🔥

## Overview

The PYRO Detector view provides a Zenmap-like interface for visualizing network topology, investigations, and Fire Marshal detonator results. It integrates with the PYRO Platform Ignition via the PYRO Detector MCP server.

## Features

### Network Visualization
- **Interactive Graph**: Sigma.js-based network graph visualization
- **Node Types**: Hosts, networks, services, agents
- **Edge Visualization**: Connections and relationships
- **Zoom & Pan**: Full graph navigation controls

### Fire Marshal Integration
- **Detonator List**: Browse available Fire Marshal detonators
- **Execute Detonators**: Run investigations and view results
- **Case Management**: Create and manage investigation cases
- **Agent Coordination**: List and manage agents
- **PQL Queries**: Execute Pyro Query Language queries

### Investigation Controls
- Create new cases
- List agents
- Execute PQL queries
- View detonator status and results

## Integration Points

### PYRO Detector MCP Server
The view integrates with the PYRO Detector MCP server (located at `pyro-detector/`) via:

1. **MCP Methods**:
   - `pyro_list_detonators` - List available detonators
   - `pyro_execute_detonator` - Execute Fire Marshal detonators
   - `pyro_create_case` - Create investigation cases
   - `pyro_list_agents` - List all agents
   - `pyro_execute_pql` - Execute PQL queries
   - `pyro_health` - System health check

2. **API Client**: 
   - Located in `pyro-detector/src/api.rs`
   - Handles authentication and API calls
   - Returns structured data for visualization

## Component Structure

```
PyroDetector/
├── PyroDetectorView.tsx    # Main view component
├── index.ts                 # Export
└── README.md               # This file
```

## Usage

### Accessing the View
1. Navigate to `/ui/pyro-detector` in the application
2. Or click "PYRO Detector" in the main navigation

### Using the Interface
1. **Select a Detonator**: Choose from the list of available Fire Marshal detonators
2. **Execute**: Click on a detonator to execute it and view results
3. **Visualize**: Network topology appears in the graph visualization
4. **Interact**: Click nodes/edges to view details, zoom, pan

## Implementation Status

### ✅ Completed
- Route definition and registration
- Navigation menu integration
- Basic view structure
- Graph visualization setup
- Detonator list UI
- Investigation controls UI

### 🔄 TODO
- [ ] Connect to PYRO Detector MCP server API
- [ ] Implement actual API calls (replace placeholders)
- [ ] Add node/edge detail panels
- [ ] Implement context menu actions
- [ ] Add filtering and search
- [ ] Add export functionality
- [ ] Add real-time updates
- [ ] Add error handling
- [ ] Add loading states
- [ ] Add unit tests

## API Integration

### Current State
The component currently uses placeholder data. To integrate with the actual PYRO Detector MCP server:

1. **Create API Client**: 
   ```typescript
   // src/api/pyroDetector.ts
   export const pyroDetectorApi = {
     listDetonators: () => fetch('/api/pyro-detector/list-detonators'),
     executeDetonator: (id: string) => fetch(`/api/pyro-detector/execute/${id}`),
     // ... other methods
   };
   ```

2. **Update Queries**: Replace placeholder `useQuery` calls with actual API calls

3. **Handle Responses**: Transform API responses into graph data structures

## Graph Data Structure

### Nodes
```typescript
interface NetworkNode {
  id: string;
  label: string;
  type: 'host' | 'network' | 'service' | 'agent';
  properties?: Record<string, any>;
}
```

### Edges
```typescript
interface NetworkEdge {
  id: string;
  source: string;
  target: string;
  type: string;
  properties?: Record<string, any>;
}
```

## Styling

The component uses Material-UI (MUI) for styling and follows the application's theme system:
- Dark mode support
- Responsive layout
- Consistent with other views

## Dependencies

- `@mui/material` - UI components
- `@react-sigma/core` - Graph visualization
- `graphology` - Graph data structure
- `@tanstack/react-query` - Data fetching
- `bh-shared-ui` - Shared UI components

## Related Documentation

- [PYRO Detector MCP Server](../pyro-detector/README_START_HERE.md)
- [PYRO Detector API Reference](../pyro-detector/API_REFERENCE.md)
- [Sigma.js Documentation](https://github.com/jacomyal/sigma.js)

## Notes

- The icon in the navigation uses `AppIcon.Radar` - this may need to be changed if that icon doesn't exist
- The component is designed to be extensible for future features
- Graph visualization follows the same patterns as the Explore view

---

🔥 **PYRO Detector View - Network Mapping Interface** 🔥

*Zenmap-like visualization for PYRO Platform Ignition*

