# 🏗️ Architecture Diagram - PYRO Detector Integration

🔥 **Complete System Architecture** 🔥

---

## 📊 System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    BloodHound Workspace                          │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  React UI (TypeScript/React)                              │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  PyroDetectorView Component                         │  │  │
│  │  │  - Network Graph (Sigma.js)                        │  │  │
│  │  │  - Detonator List                                   │  │  │
│  │  │  - Investigation Controls                          │  │  │
│  │  │  - Status Display                                  │  │  │
│  │  └──────────────────┬─────────────────────────────────┘  │  │
│  │                     │                                       │  │
│  │  ┌──────────────────▼─────────────────────────────────┐  │  │
│  │  │  TypeScript API Client                              │  │  │
│  │  │  (pyroDetector.ts)                                 │  │  │
│  │  │  - listDetonators()                                │  │  │
│  │  │  - executeDetonator()                              │  │  │
│  │  │  - createCase()                                    │  │  │
│  │  │  - listAgents()                                    │  │  │
│  │  │  - executePQL()                                     │  │  │
│  │  │  - getHealth()                                      │  │  │
│  │  └──────────────────┬─────────────────────────────────┘  │  │
│  └──────────────────────┼──────────────────────────────────────┘  │
│                         │ HTTP/REST                                │
│                         │ /api/v2/pyro-detector/*                  │
│                         ▼                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Backend API (Go)                                         │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  API Handlers (pyro_detector.go)                   │  │  │
│  │  │  - ListDetonators()                               │  │  │
│  │  │  - ExecuteDetonator()                             │  │  │
│  │  │  - CreateCase()                                   │  │  │
│  │  │  - ListAgents()                                   │  │  │
│  │  │  - ExecutePQL()                                   │  │  │
│  │  │  - GetPyroDetectorHealth()                        │  │  │
│  │  └──────────────────┬────────────────────────────────┘  │  │
│  │                     │                                       │  │
│  │  ┌──────────────────▼─────────────────────────────────┐  │  │
│  │  │  MCP Client (PyroDetectorClient)                    │  │  │
│  │  │  - callMCPMethod()                                 │  │  │
│  │  │  - stdio communication                             │  │  │
│  │  │  - JSON-RPC 2.0 protocol                           │  │  │
│  │  └──────────────────┬─────────────────────────────────┘  │  │
│  └──────────────────────┼──────────────────────────────────────┘  │
│                         │ stdio                                    │
│                         │ JSON-RPC 2.0                             │
│                         ▼                                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  PYRO Detector MCP Server (Rust)                         │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  MCP Server (mcp_server.rs)                        │  │  │
│  │  │  - Handle JSON-RPC 2.0 requests                   │  │  │
│  │  │  - Route to appropriate handlers                   │  │  │
│  │  │  - Return JSON-RPC 2.0 responses                   │  │  │
│  │  └──────────────────┬─────────────────────────────────┘  │  │
│  │                     │                                       │  │
│  │  ┌──────────────────▼─────────────────────────────────┐  │  │
│  │  │  API Client (api.rs)                                │  │  │
│  │  │  - PYRO Platform API integration                    │  │  │
│  │  │  - Authentication (JWT)                              │  │  │
│  │  │  - Error handling                                    │  │  │
│  │  │  - Request/response transformation                 │  │  │
│  │  └──────────────────┬─────────────────────────────────┘  │  │
│  │                     │                                       │  │
│  │  ┌──────────────────▼─────────────────────────────────┐  │  │
│  │  │  CDIF Compliance (cdif.rs)                        │  │  │
│  │  │  - Terminology validation                          │  │  │
│  │  │  - Evidence chain requirements                     │  │  │
│  │  │  - Quantum verification                            │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  └──────────────────────┬──────────────────────────────────────┘  │
│                         │ HTTP/REST                                │
│                         │ PYRO Platform API                         │
│                         ▼                                          │
└──────────────────────────┼──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              PYRO Platform Ignition (External)                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Fire Marshal Platform                                    │  │
│  │  - 284+ Detonators                                        │  │
│  │  - Investigation Management                              │  │
│  │  - Agent Coordination                                    │  │
│  │  - PQL Query Engine                                       │  │
│  │  - Evidence Chain Management                             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Request Flow
```
User Action (UI)
    ↓
TypeScript API Client
    ↓
HTTP Request (/api/v2/pyro-detector/*)
    ↓
Go Backend Handler
    ↓
MCP Client (stdio)
    ↓
PYRO Detector MCP Server (Rust)
    ↓
PYRO Platform API Client
    ↓
PYRO Platform Ignition
```

### Response Flow
```
PYRO Platform Ignition
    ↓
PYRO Detector MCP Server
    ↓
MCP Client
    ↓
Go Backend Handler
    ↓
HTTP Response
    ↓
TypeScript API Client
    ↓
UI Update (Graph Visualization)
```

---

## 🧩 Component Details

### UI Component (React)
- **Technology**: React + TypeScript
- **Visualization**: Sigma.js
- **State Management**: React Query
- **Styling**: Material-UI

### API Client (TypeScript)
- **Location**: `cmd/ui/src/api/pyroDetector.ts`
- **Functions**: 6 API functions
- **Type Safety**: Complete
- **Error Handling**: Comprehensive

### Backend API (Go)
- **Location**: `cmd/api/src/api/v2/pyro_detector.go`
- **Handlers**: 6 HTTP handlers
- **Protocol**: REST
- **Authentication**: Required

### MCP Client (Go)
- **Location**: `cmd/api/src/api/v2/pyro_detector.go`
- **Protocol**: stdio (JSON-RPC 2.0)
- **Communication**: Process execution
- **Error Handling**: Complete

### MCP Server (Rust)
- **Location**: `pyro-detector/src/mcp_server.rs`
- **Protocol**: JSON-RPC 2.0
- **Transport**: stdio
- **Methods**: 7 methods

### API Client (Rust)
- **Location**: `pyro-detector/src/api.rs`
- **Protocol**: HTTP/REST
- **Authentication**: JWT
- **Error Handling**: Complete

---

## 🔐 Security Layers

### Layer 1: UI
- React component security
- Input validation
- XSS prevention

### Layer 2: Backend API
- Authentication required
- Authorization checks
- Input validation
- Error sanitization

### Layer 3: MCP Server
- Process isolation
- Input validation
- CDIF compliance

### Layer 4: PYRO Platform
- JWT authentication
- API key management
- Evidence chain validation

---

## 📊 Performance Considerations

### UI
- React Query caching
- Lazy loading
- Graph optimization

### Backend
- Request rate limiting
- Connection pooling
- Error handling

### MCP Server
- Process management
- Response caching (future)
- Connection reuse (future)

### PYRO Platform
- API rate limits
- Response caching
- Connection pooling

---

## 🔄 Error Handling

### UI Layer
- User-friendly error messages
- Loading states
- Retry mechanisms

### Backend Layer
- HTTP status codes
- Error logging
- Error sanitization

### MCP Layer
- JSON-RPC error responses
- Process error handling
- Timeout handling

### API Layer
- HTTP error responses
- Retry logic
- Error transformation

---

## 📈 Scalability

### Horizontal Scaling
- Backend: Stateless, can scale horizontally
- MCP Server: Process-based, can scale
- UI: Static assets, CDN-ready

### Vertical Scaling
- All components support vertical scaling
- Resource usage optimized
- Memory management implemented

---

## 🔧 Configuration Points

### UI Configuration
- API endpoint URLs
- Authentication tokens
- Feature flags

### Backend Configuration
- `pyro_detector_path`: Path to MCP server binary
- Rate limiting
- Timeout settings

### MCP Server Configuration
- `pyro_api_url`: PYRO Platform URL
- `api_token`: Authentication token
- `cdif_compliance`: Compliance mode

---

## 📚 Related Documentation

- [Complete Integration Summary](COMPLETE_INTEGRATION_SUMMARY.md)
- [Backend API Integration](BACKEND_API_INTEGRATION.md)
- [UI Integration Guide](UI_INTEGRATION_GUIDE.md)
- [PYRO Detector Architecture](pyro-detector/ARCHITECTURE.md)

---

🔥 **Architecture Diagram - PYRO Detector Integration** 🔥

*Complete system architecture and data flow*

**Status**: ✅ **COMPLETE**

