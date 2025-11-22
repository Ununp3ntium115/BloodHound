# 🔥 Backend API Integration - PYRO Detector

**Complete Backend API Integration for PYRO Detector**

---

## ✅ Integration Complete

The backend API has been successfully integrated to connect the UI with the PYRO Detector MCP server.

---

## 📦 What Was Created

### 1. Backend API Handlers ✅
**File**: `cmd/api/src/api/v2/pyro_detector.go`

**Handlers Created**:
- `ListDetonators` - List available Fire Marshal detonators
- `ExecuteDetonator` - Execute a Fire Marshal detonator
- `CreateCase` - Create a new investigation case
- `ListAgents` - List all Fire Marshal agents
- `ExecutePQL` - Execute a Pyro Query Language query
- `GetPyroDetectorHealth` - Get health status

**MCP Client**:
- `PyroDetectorClient` - Communicates with MCP server via stdio
- `callMCPMethod` - Sends JSON-RPC 2.0 requests to MCP server

### 2. Configuration ✅
**File**: `cmd/api/src/config/config.go`
- Added `PyroDetectorPath` field to `Configuration` struct
- Configurable path to PYRO Detector MCP server binary

### 3. Route Registration ✅
**File**: `cmd/api/src/api/registration/v2.go`

**Routes Registered**:
- `GET /api/v2/pyro-detector/detonators` - List detonators
- `POST /api/v2/pyro-detector/detonators/{id}/execute` - Execute detonator
- `POST /api/v2/pyro-detector/cases` - Create case
- `GET /api/v2/pyro-detector/agents` - List agents
- `POST /api/v2/pyro-detector/pql` - Execute PQL query
- `GET /api/v2/pyro-detector/health` - Health check

### 4. TypeScript API Client ✅
**File**: `cmd/ui/src/api/pyroDetector.ts`

**Client Functions**:
- `listDetonators()` - List detonators
- `executeDetonator()` - Execute detonator
- `createCase()` - Create case
- `listAgents()` - List agents
- `executePQL()` - Execute PQL query
- `getHealth()` - Get health status

### 5. UI Component Updates ✅
**File**: `cmd/ui/src/views/PyroDetector/PyroDetectorView.tsx`
- Replaced placeholder data with real API calls
- Integrated React Query for data fetching
- Added mutation handling for detonator execution
- Connected all investigation controls to API

---

## 🔄 Integration Flow

```
┌─────────────────┐
│  React UI       │
│  (PyroDetector) │
└────────┬────────┘
         │ HTTP/REST
         │ /api/v2/pyro-detector/*
         ▼
┌─────────────────┐
│  Backend API    │
│  (Go Handlers)  │
└────────┬────────┘
         │ stdio
         │ JSON-RPC 2.0
         ▼
┌─────────────────┐
│  PYRO Detector  │
│  MCP Server     │
│  (Rust)         │
└────────┬────────┘
         │ HTTP/REST
         ▼
┌─────────────────┐
│  PYRO Platform  │
│  Ignition       │
└─────────────────┘
```

---

## 📁 Files Created/Modified

### Backend
- ✅ `cmd/api/src/api/v2/pyro_detector.go` - API handlers (NEW)
- ✅ `cmd/api/src/config/config.go` - Configuration (MODIFIED)
- ✅ `cmd/api/src/api/registration/v2.go` - Route registration (MODIFIED)

### Frontend
- ✅ `cmd/ui/src/api/pyroDetector.ts` - API client (NEW)
- ✅ `cmd/ui/src/views/PyroDetector/PyroDetectorView.tsx` - Component updates (MODIFIED)

---

## 🔧 Configuration

### Backend Configuration
Add to `bhapi.json`:
```json
{
  "pyro_detector_path": "./target/release/pyro-detector"
}
```

Or set via environment variable:
```bash
export BHE_PYRO_DETECTOR_PATH="./target/release/pyro-detector"
```

### Default Path
If not configured, defaults to: `./target/release/pyro-detector`

---

## 🚀 API Endpoints

### List Detonators
```http
GET /api/v2/pyro-detector/detonators
Authorization: Bearer <token>
```

**Response**:
```json
{
  "detonators": [
    {
      "id": "detonator-1",
      "name": "Network Topology Scan",
      "description": "Map network topology"
    }
  ]
}
```

### Execute Detonator
```http
POST /api/v2/pyro-detector/detonators/{detonator_id}/execute
Authorization: Bearer <token>
Content-Type: application/json

{
  "case_id": "case-123",
  "parameters": {}
}
```

### Create Case
```http
POST /api/v2/pyro-detector/cases
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Investigation Case",
  "description": "Case description"
}
```

### List Agents
```http
GET /api/v2/pyro-detector/agents
Authorization: Bearer <token>
```

### Execute PQL
```http
POST /api/v2/pyro-detector/pql
Authorization: Bearer <token>
Content-Type: application/json

{
  "query": "SELECT * FROM agents",
  "parameters": {}
}
```

### Health Check
```http
GET /api/v2/pyro-detector/health
Authorization: Bearer <token>
```

---

## ✅ Verification

- ✅ Backend handlers created
- ✅ Routes registered
- ✅ Configuration added
- ✅ TypeScript client created
- ✅ UI component updated
- ✅ No linter errors

---

## 🔄 Next Steps

### Testing
- [ ] Test API endpoints with actual MCP server
- [ ] Verify MCP communication works
- [ ] Test error handling
- [ ] Test authentication

### Enhancements
- [ ] Add request/response validation
- [ ] Add rate limiting
- [ ] Add caching
- [ ] Add WebSocket support for real-time updates
- [ ] Improve error messages

### Documentation
- [ ] API documentation
- [ ] Integration examples
- [ ] Troubleshooting guide

---

## 📚 Related Documentation

- [PYRO Detector MCP Server](../pyro-detector/README_START_HERE.md)
- [UI Integration Guide](UI_INTEGRATION_GUIDE.md)
- [PYRO Detector UI Integration](PYRO_DETECTOR_UI_INTEGRATION.md)

---

🔥 **Backend API Integration - Complete** 🔥

*Full integration from UI to MCP server to PYRO Platform*

**Status**: ✅ **COMPLETE**  
**Next**: Testing and validation

