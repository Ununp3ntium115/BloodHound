# PYRO Detector Integration Guide

🔥 **Complete Integration Guide for PYRO Platform Ignition** 🔥

## Overview

PYRO Detector is an MCP server that acts as a **detonator** service - a 3rd party package that integrates with PYRO Platform Ignition. It provides seamless access to Fire Marshal investigations, detonators, agents, and PQL queries.

## Architecture

```
┌─────────────────┐
│  Cursor / MCP   │
│     Client      │
└────────┬────────┘
         │ MCP Protocol (JSON-RPC 2.0)
         │
┌────────▼────────┐
│ PYRO Detector   │  ← Detonator Service (3rd Party)
│   MCP Server    │
└────────┬────────┘
         │ HTTP/REST API
         │
┌────────▼────────┐
│ PYRO Platform   │
│   Ignition      │
│   (Backend)     │
└─────────────────┘
```

## CDIF Compliance

PYRO Detector is fully CDIF (Critical Digital Investigation Fire Marshal) compliant:

### Terminology Standards

| ❌ Invalid | ✅ Correct (CDIF) |
|------------|-------------------|
| hunt | investigation |
| artifact | detonator |
| client | agent |
| execution | collection |
| session | case |

### Compliance Features

- ✅ **Fire Marshal Terminology**: Automatic validation and conversion
- ✅ **Evidence Chain**: Required for all operations
- ✅ **Quantum Verification**: BLAKE3 + SHA3-256 support
- ✅ **Court Admissibility**: Evidence chain integrity

## Setup

### 1. Build the Detector

```bash
cd pyro-detector
cargo build --release
```

### 2. Configure

Create `pyro-detector-config.json`:

```json
{
  "pyro_api_url": "http://localhost:3001",
  "api_token": "your-jwt-token",
  "cdif_compliance": true,
  "fire_marshal_terminology": true
}
```

### 3. Add to Cursor MCP

Edit your Cursor MCP configuration (usually `~/.cursor/mcp.json` or in Cursor settings):

```json
{
  "mcpServers": {
    "pyro-detector": {
      "command": "/path/to/pyro-detector/target/release/pyro-detector",
      "args": [],
      "env": {
        "PYRO_API_URL": "http://localhost:3001",
        "PYRO_API_TOKEN": "your-token-here"
      }
    }
  }
}
```

## API Methods

### Investigation Operations

#### List Detonators
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware",
    "platform": "windows"
  }
}
```

#### Execute Detonator
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_execute_detonator",
  "params": {
    "detonator_id": "DET-RAN-001",
    "case_id": "CASE-FM-2025-001",
    "parameters": {
      "scan_depth": "deep"
    }
  }
}
```

#### Create Case
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "Ransomware Investigation",
    "investigation_type": "ransomware",
    "priority": "P0"
  }
}
```

### Agent Operations

#### List Agents
```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "pyro_list_agents",
  "params": {}
}
```

### Query Operations

#### Execute PQL Query
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "pyro_execute_pql",
  "params": {
    "query": "SELECT * FROM processes WHERE suspicious = true",
    "target_agents": ["agent-001"],
    "timeout_seconds": 300
  }
}
```

### System Operations

#### Health Check
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "pyro_health",
  "params": {}
}
```

#### Authenticate
```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "pyro_authenticate",
  "params": {}
}
```

## Usage Examples

### Example 1: Complete Investigation Workflow

```bash
# 1. Create case
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "Ransomware Investigation",
    "investigation_type": "ransomware"
  }
}' | pyro-detector

# 2. List available detonators
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware"
  }
}' | pyro-detector

# 3. Execute detonator
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_execute_detonator",
  "params": {
    "detonator_id": "DET-RAN-001",
    "case_id": "CASE-FM-2025-001"
  }
}' | pyro-detector
```

### Example 2: Agent Discovery and PQL Query

```bash
# 1. List agents
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_list_agents",
  "params": {}
}' | pyro-detector

# 2. Execute PQL query on agents
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_execute_pql",
  "params": {
    "query": "SELECT process_name, pid FROM processes WHERE suspicious = true",
    "target_agents": ["agent-001", "agent-002"]
  }
}' | pyro-detector
```

## Error Handling

All errors follow CDIF standards:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": "CDIF_COMPLIANCE_ERROR",
    "message": "CDIF compliance validation failed",
    "details": [
      "Invalid terminology: 'hunt'. Use 'investigation' instead (CDIF compliance)"
    ]
  }
}
```

## Authentication

### Option 1: JWT Token (Recommended)

```json
{
  "api_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### Option 2: Username/Password

```json
{
  "username": "fire.marshal",
  "password": "secure_password"
}
```

The detector will automatically authenticate and cache the token.

## CDIF Validation

PYRO Detector automatically validates:

1. **Terminology**: Converts invalid terms to Fire Marshal standards
2. **Evidence Chain**: Ensures evidence chain is present
3. **Quantum Verification**: Validates quantum hash requirements
4. **Court Admissibility**: Checks evidence integrity

## Performance

- **Response Time**: <100ms for most operations
- **Rate Limiting**: 100 requests/minute (configurable)
- **Concurrent Requests**: Supports multiple concurrent investigations
- **Timeout**: 30 seconds default (configurable)

## Troubleshooting

### Connection Issues

```bash
# Test API connection
curl http://localhost:3001/api/v2/fire-marshal/admin/health
```

### Authentication Issues

```bash
# Test authentication
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_authenticate",
  "params": {}
}' | pyro-detector
```

### CDIF Compliance Errors

If you get CDIF compliance errors, ensure:
1. Using correct terminology (investigation, detonator, agent)
2. Evidence chain is included in requests
3. Fire Marshal terminology is enabled in config

## Integration with PYRO Platform Ignition

See the main PYRO Platform Ignition documentation:
- [API Reference](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/docs/api/API_INTEGRATION_GUIDE.md)
- [CDIF Framework](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/steering/cdif/00_CDIF_MASTER_FRAMEWORK.md)
- [Fire Marshal API](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/steering/FIRE_MARSHAL_API_REFERENCE.md)

## Support

For issues:
1. Check PYRO Platform Ignition is running
2. Verify API URL and authentication
3. Check CDIF compliance settings
4. Review error messages for details

---

🔥 **PYRO Detector - Detonator Service for PYRO Platform Ignition** 🔥

