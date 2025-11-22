# 📖 Usage Examples - PYRO Detector

🔥 **Practical Usage Examples for PYRO Detector Integration** 🔥

---

## 🎯 Overview

This guide provides practical examples for using the PYRO Detector integration.

---

## 📋 Example Scenarios

### Scenario 1: Network Topology Mapping

#### Goal
Map network topology using Fire Marshal detonators.

#### Steps

1. **Access UI**
   ```
   Navigate to: http://localhost:8080/ui/pyro-detector
   ```

2. **Create Investigation Case**
   - Click "Create Case" button
   - Enter case name: "Network Topology Investigation"
   - Case created with ID

3. **List Available Detonators**
   - Detonator list loads automatically
   - Browse available Fire Marshal detonators

4. **Execute Network Topology Detonator**
   - Select "Network Topology Scan" detonator
   - Click to execute
   - Wait for results

5. **View Network Graph**
   - Network graph displays automatically
   - Nodes represent hosts/networks
   - Edges represent connections
   - Zoom, pan, and interact with graph

#### Expected Result
Network topology visualized as interactive graph.

---

### Scenario 2: Host Discovery Investigation

#### Goal
Discover active hosts on the network.

#### Steps

1. **Create Case**
   ```
   POST /api/v2/pyro-detector/cases
   {
     "name": "Host Discovery",
     "description": "Discover active hosts"
   }
   ```

2. **List Detonators**
   ```
   GET /api/v2/pyro-detector/detonators
   ```

3. **Execute Host Discovery Detonator**
   ```
   POST /api/v2/pyro-detector/detonators/host-discovery/execute
   {
     "case_id": "case-123",
     "parameters": {
       "target_range": "192.168.1.0/24"
     }
   }
   ```

4. **View Results**
   - Results displayed in graph
   - Each host as a node
   - Network connections as edges

#### Expected Result
List of discovered hosts visualized in graph.

---

### Scenario 3: Agent Management

#### Goal
List and manage Fire Marshal agents.

#### Steps

1. **List Agents**
   ```
   GET /api/v2/pyro-detector/agents
   ```

2. **View Agent Status**
   - Agent list displays in UI
   - Status shown for each agent
   - Last seen timestamp

3. **Execute PQL Query**
   ```
   POST /api/v2/pyro-detector/pql
   {
     "query": "SELECT * FROM agents WHERE status = 'active'",
     "parameters": {}
   }
   ```

#### Expected Result
Agent information displayed.

---

### Scenario 4: Service Enumeration

#### Goal
Enumerate services on discovered hosts.

#### Steps

1. **Execute Service Enumeration Detonator**
   - Select "Service Enumeration" detonator
   - Provide target host
   - Execute

2. **View Service Graph**
   - Services displayed as nodes
   - Host-service relationships as edges
   - Service details in properties

#### Expected Result
Service enumeration results visualized.

---

## 💻 Code Examples

### TypeScript/React (UI)

#### List Detonators
```typescript
import { pyroDetectorApi } from 'src/api/pyroDetector';

const detonators = await pyroDetectorApi.listDetonators();
console.log('Detonators:', detonators);
```

#### Execute Detonator
```typescript
const result = await pyroDetectorApi.executeDetonator({
  detonator_id: 'network-topology-scan',
  case_id: 'case-123',
  parameters: {}
});
console.log('Results:', result);
```

#### Create Case
```typescript
const newCase = await pyroDetectorApi.createCase(
  'Investigation Case',
  'Case description'
);
console.log('Case created:', newCase);
```

### Go (Backend)

#### Direct Handler Usage
```go
// Handler automatically called via route
// No direct usage needed
```

#### MCP Client Usage
```go
client := NewPyroDetectorClient(config)
result, err := client.callMCPMethod("pyro_list_detonators", map[string]interface{}{})
if err != nil {
    log.Fatal(err)
}
```

### cURL Examples

#### Health Check
```bash
curl -X GET http://localhost:8080/api/v2/pyro-detector/health \
  -H "Authorization: Bearer <token>"
```

#### List Detonators
```bash
curl -X GET http://localhost:8080/api/v2/pyro-detector/detonators \
  -H "Authorization: Bearer <token>"
```

#### Execute Detonator
```bash
curl -X POST http://localhost:8080/api/v2/pyro-detector/detonators/detonator-1/execute \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "case_id": "case-123",
    "parameters": {}
  }'
```

---

## 🎨 UI Usage Examples

### Basic Workflow

1. **Navigate to PYRO Detector**
   - Click "PYRO Detector" in navigation menu
   - Or go to `/ui/pyro-detector`

2. **Browse Detonators**
   - Left panel shows available detonators
   - Click detonator to see details

3. **Execute Investigation**
   - Click detonator to execute
   - Results appear in graph visualization
   - Status updates in left panel

4. **Interact with Graph**
   - Click nodes to view details
   - Zoom with mouse wheel
   - Pan by dragging
   - Click edges to see connections

### Advanced Usage

#### Filtering
- Filter nodes by type (host, network, service)
- Search for specific nodes
- Filter edges by connection type

#### Export
- Export graph as image
- Export data as JSON
- Export as report

---

## 🔄 Integration Patterns

### Pattern 1: Automated Investigation

```typescript
// Create case
const case = await pyroDetectorApi.createCase('Automated Investigation');

// List detonators
const detonators = await pyroDetectorApi.listDetonators();

// Execute each detonator
for (const detonator of detonators) {
  const result = await pyroDetectorApi.executeDetonator({
    detonator_id: detonator.id,
    case_id: case.id
  });
  
  // Process results
  console.log(`Detonator ${detonator.name} completed:`, result);
}
```

### Pattern 2: Real-time Monitoring

```typescript
// Poll for agent status
setInterval(async () => {
  const agents = await pyroDetectorApi.listAgents();
  console.log('Active agents:', agents.filter(a => a.status === 'active'));
}, 5000);
```

### Pattern 3: Query-based Analysis

```typescript
// Execute PQL query
const results = await pyroDetectorApi.executePQL(
  'SELECT * FROM detonators WHERE category = "network"',
  {}
);

// Process query results
console.log('Network detonators:', results);
```

---

## 📊 Expected Results

### Detonator List Response
```json
{
  "detonators": [
    {
      "id": "network-topology-scan",
      "name": "Network Topology Scan",
      "description": "Map network topology",
      "category": "network"
    }
  ]
}
```

### Detonator Execution Response
```json
{
  "id": "execution-123",
  "detonator_id": "network-topology-scan",
  "status": "completed",
  "timestamp": "2025-01-XXT00:00:00Z",
  "nodes": [
    {
      "id": "host-1",
      "label": "Host 1",
      "type": "host"
    }
  ],
  "edges": [
    {
      "id": "edge-1",
      "source": "host-1",
      "target": "network-1",
      "type": "connected"
    }
  ]
}
```

### Case Creation Response
```json
{
  "id": "case-123",
  "name": "Investigation Case",
  "description": "Case description",
  "created_at": "2025-01-XXT00:00:00Z",
  "status": "active"
}
```

---

## 🎯 Best Practices

### Performance
- Use case IDs for related investigations
- Batch operations where possible
- Cache detonator lists
- Poll health status periodically

### Error Handling
- Always handle API errors
- Check response status codes
- Display user-friendly error messages
- Log errors for debugging

### Security
- Never expose API tokens in UI
- Use secure token storage
- Validate all inputs
- Sanitize outputs

---

## 📚 Related Documentation

- [API Reference](pyro-detector/API_REFERENCE.md)
- [Integration Guide](COMPLETE_INTEGRATION_SUMMARY.md)
- [Testing Guide](TESTING_GUIDE.md)

---

🔥 **Usage Examples - PYRO Detector** 🔥

*Practical examples for using PYRO Detector integration*

**Status**: Ready for use

