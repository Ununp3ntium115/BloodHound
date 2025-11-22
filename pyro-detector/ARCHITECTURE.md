# PYRO Detector - Architecture Overview

🔥 **System Architecture and Design** 🔥

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Cursor    │  │  Other MCP   │  │   Custom     │     │
│  │     IDE      │  │   Clients    │  │   Clients    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                 │
│                    MCP Protocol                              │
│                  (JSON-RPC 2.0)                             │
│                  stdio transport                            │
│                            │                                 │
└────────────────────────────┼─────────────────────────────────┘
                             │
┌────────────────────────────▼─────────────────────────────────┐
│              PYRO Detector MCP Server                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              MCP Server Layer                        │  │
│  │  - Request routing                                    │  │
│  │  - Response formatting                                │  │
│  │  - Error handling                                     │  │
│  │  - JSON-RPC 2.0 protocol                             │  │
│  └───────────────────┬──────────────────────────────────┘  │
│                      │                                      │
│  ┌───────────────────▼──────────────────────────────────┐  │
│  │          CDIF Compliance Layer                       │  │
│  │  - Terminology validation                           │  │
│  │  - Evidence chain validation                        │  │
│  │  - Quantum verification                             │  │
│  └───────────────────┬──────────────────────────────────┘  │
│                      │                                      │
│  ┌───────────────────▼──────────────────────────────────┐  │
│  │            API Client Layer                          │  │
│  │  - HTTP client (reqwest)                            │  │
│  │  - Authentication                                    │  │
│  │  - Request/response handling                         │  │
│  │  - Error handling                                    │  │
│  └───────────────────┬──────────────────────────────────┘  │
│                      │                                      │
│  ┌───────────────────▼──────────────────────────────────┐  │
│  │         Configuration Layer                          │  │
│  │  - Config file loading                               │  │
│  │  - Environment variables                            │  │
│  │  - Default values                                   │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Utility Layer                                │  │
│  │  - Logging                                           │  │
│  │  - Health checking                                   │  │
│  │  - Validation                                        │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────┬─────────────────────────────────┘
                             │
                    HTTP/REST API
                  (JWT Authentication)
                             │
┌────────────────────────────▼─────────────────────────────────┐
│          PYRO Platform Ignition (Backend)                    │
│  - Investigation API                                          │
│  - Detonator Registry                                         │
│  - Agent Management                                           │
│  - PQL Query Engine                                           │
│  - Evidence Management                                        │
└──────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. MCP Server Layer (`mcp_server.rs`)

**Responsibilities**:
- Handle JSON-RPC 2.0 protocol
- Route requests to appropriate handlers
- Format responses
- Handle errors

**Key Functions**:
- `run()` - Main server loop
- `handle_request()` - Request routing
- `handle_*()` - Method handlers

### 2. CDIF Compliance Layer (`cdif.rs`)

**Responsibilities**:
- Validate Fire Marshal terminology
- Convert invalid terms
- Validate evidence chain
- Enforce CDIF standards

**Key Functions**:
- `validate_terminology()` - Check terminology
- `convert_to_fire_marshal()` - Convert terms
- `CdifCompliance::validate()` - Full validation

### 3. API Client Layer (`api.rs`)

**Responsibilities**:
- HTTP communication with PYRO Platform
- Authentication management
- Request/response handling
- Error handling

**Key Functions**:
- `authenticate()` - Get/refresh token
- `list_detonators()` - List detonators
- `execute_detonator()` - Execute detonator
- `create_case()` - Create case
- `list_agents()` - List agents
- `execute_pql_query()` - Execute PQL

### 4. Configuration Layer (`config.rs`)

**Responsibilities**:
- Load configuration from file
- Load from environment variables
- Provide defaults
- Validate configuration

**Key Functions**:
- `load()` - Load configuration
- `from_env()` - Load from environment
- `get_token()` - Get auth token

### 5. Type System (`types.rs`)

**Responsibilities**:
- Define all data structures
- Serialization/deserialization
- Type safety

**Key Types**:
- `InvestigationCase`
- `Detonator`
- `Agent`
- `PqlQueryRequest`
- `DetonatorExecutionRequest`

### 6. Logging Layer (`logging.rs`)

**Responsibilities**:
- Structured logging
- Log levels
- Timestamp formatting

**Key Functions**:
- `Logger::log()` - Log message
- `Logger::error()` - Log error
- `Logger::info()` - Log info

### 7. Utility Layer (`utils.rs`)

**Responsibilities**:
- JSON-RPC validation
- Error formatting
- URL validation
- Message sanitization

## Data Flow

### Request Flow

```
1. Client sends JSON-RPC request via stdio
   ↓
2. MCP Server receives and parses
   ↓
3. CDIF Compliance validates (if enabled)
   ↓
4. API Client formats HTTP request
   ↓
5. Authentication (if needed)
   ↓
6. HTTP request to PYRO Platform
   ↓
7. Response received
   ↓
8. Error handling (if needed)
   ↓
9. Response formatted as JSON-RPC
   ↓
10. Response sent via stdio
```

### Error Flow

```
1. Error occurs (API, validation, etc.)
   ↓
2. Error caught and categorized
   ↓
3. Error sanitized (remove secrets)
   ↓
4. Error formatted as JSON-RPC error
   ↓
5. Error logged (if enabled)
   ↓
6. Error response sent to client
```

## Design Patterns

### 1. Request Handler Pattern

Each MCP method has a dedicated handler:
- `handle_list_detonators()`
- `handle_execute_detonator()`
- `handle_create_case()`
- etc.

### 2. Builder Pattern

Configuration uses builder-like pattern:
```rust
let config = DetectorConfig::from_env();
```

### 3. Strategy Pattern

CDIF compliance is optional and configurable:
```rust
if config.cdif_compliance {
    cdif.validate()?;
}
```

### 4. Adapter Pattern

PYRO Detector adapts PYRO Platform API to MCP protocol.

## Security Architecture

### Authentication Flow

```
1. Check for existing token
   ↓
2. If missing, check config token
   ↓
3. If missing, login with username/password
   ↓
4. Cache token
   ↓
5. Use token for requests
   ↓
6. Auto-refresh if expired
```

### Credential Storage

- **Never in code**: All credentials external
- **Config file**: For non-secrets
- **Environment**: For secrets (recommended)
- **Memory only**: Tokens cached in memory

### Error Sanitization

- Passwords masked: `***`
- Tokens masked: `***`
- Secrets removed from logs
- Safe error messages

## Performance Considerations

### Optimization Strategies

1. **Token Caching**: Avoid re-authentication
2. **Connection Pooling**: Reuse HTTP connections
3. **Request Batching**: Group operations
4. **Lazy Loading**: Load config on demand

### Bottlenecks

1. **Network Latency**: PYRO Platform API calls
2. **Authentication**: Token refresh overhead
3. **CDIF Validation**: Minimal overhead
4. **stdio I/O**: Negligible overhead

## Scalability

### Horizontal Scaling

- Multiple instances can run
- Each connects independently
- No shared state
- Load balance MCP requests

### Vertical Scaling

- Increase memory for concurrent requests
- Increase CPU for processing
- Adjust rate limits
- Optimize timeouts

## Error Handling Strategy

### Error Categories

1. **Protocol Errors**: Invalid JSON-RPC
2. **Method Errors**: Unknown method
3. **Parameter Errors**: Invalid params
4. **API Errors**: PYRO Platform errors
5. **Network Errors**: Connection issues
6. **CDIF Errors**: Compliance violations

### Error Response Format

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "data": {
      "details": "Additional info"
    }
  }
}
```

## Testing Architecture

### Unit Tests

- Individual components
- Utility functions
- Type validation

### Integration Tests

- API client
- MCP server
- End-to-end workflows

### Validation Tests

- CDIF compliance
- Terminology validation
- Evidence chain validation

## Deployment Architecture

### Development

```
Developer Machine
    ↓
PYRO Detector (local)
    ↓
PYRO Platform (localhost:3001)
```

### Production

```
Production Server
    ↓
PYRO Detector (systemd/Docker)
    ↓
PYRO Platform (production API)
```

### Multi-Instance

```
Load Balancer
    ├──→ PYRO Detector Instance 1
    ├──→ PYRO Detector Instance 2
    └──→ PYRO Detector Instance 3
            ↓
    PYRO Platform (shared)
```

## Future Enhancements

### Planned Features

1. **WebSocket Support**: Real-time updates
2. **Batch Operations**: Execute multiple detonators
3. **Query Streaming**: Stream PQL results
4. **Caching**: Cache detonator lists
5. **Metrics**: Performance metrics
6. **Tracing**: Request tracing

---

🔥 **Architecture designed for reliability, security, and performance!** 🔥

