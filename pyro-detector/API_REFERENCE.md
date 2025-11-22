# PYRO Detector - Complete API Reference

🔥 **MCP Methods Reference for PYRO Platform Ignition** 🔥

## Overview

PYRO Detector provides MCP methods to interact with PYRO Platform Ignition. All methods use JSON-RPC 2.0 protocol.

**Base Protocol**: JSON-RPC 2.0  
**Transport**: stdio (stdin/stdout)  
**Content-Type**: application/json

---

## Authentication

All methods (except `pyro_authenticate`) require authentication. Configure via:
- `PYRO_API_TOKEN` environment variable
- `api_token` in config file
- `username`/`password` in config file

---

## Method Reference

### Investigation Methods

#### `pyro_list_detonators`

List all available Fire Marshal detonators.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware",  // optional
    "platform": "windows",              // optional
    "category": "process"               // optional
  }
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "detonators": [
      {
        "id": "DET-RAN-001",
        "name": "Fire.Marshal.Windows.Investigation.RansomwareProcessHunter",
        "description": "Identifies active ransomware processes",
        "investigation_type": "ransomware",
        "category": "process",
        "platform": "windows",
        "fire_marshal_certified": true,
        "performance": {
          "execution_time_ms": 127,
          "improvement_factor": "25x_faster"
        }
      }
    ],
    "count": 284
  }
}
```

**Parameters**:
- `investigation_type` (optional): Filter by type (ransomware, apt, insider-threat, malware, phishing, data-breach)
- `platform` (optional): Filter by platform (windows, linux, macos, cross-platform)
- `category` (optional): Filter by category (process, network, memory, registry, filesystem)

---

#### `pyro_execute_detonator`

Execute a Fire Marshal detonator.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_execute_detonator",
  "params": {
    "detonator_id": "DET-RAN-001",
    "investigation_type": "ransomware",
    "target_systems": ["windows-endpoint-01"],
    "parameters": {
      "scan_depth": "deep",
      "include_memory": true,
      "quantum_verification": true
    },
    "evidence_chain": {
      "case_id": "CASE-FM-2025-001",
      "investigator": "fire.marshal.001",
      "location": "lat:40.7128,lng:-74.0060",
      "quantum_verification": true
    },
    "case_id": "CASE-FM-2025-001"
  }
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "execution": {
      "execution_id": "EXEC-FM-20250129-001",
      "detonator": {
        "id": "DET-RAN-001",
        "name": "Fire.Marshal.Windows.Investigation.RansomwareProcessHunter",
        "status": "completed",
        "performance": {
          "execution_time_ms": 127,
          "improvement_factor": "25x_faster"
        }
      },
      "investigation_results": {
        "findings": [
          {
            "severity": "critical",
            "type": "ransomware_process",
            "description": "Active ransomware process detected"
          }
        ],
        "evidence_chain": {
          "quantum_verification": "blake3_sha3_verified",
          "chain_integrity": "intact",
          "court_admissible": true
        }
      },
      "fire_marshal_certified": true,
      "timestamp": "2025-01-29T10:15:30.123Z"
    },
    "success": true
  }
}
```

**Parameters**:
- `detonator_id` (required): ID of detonator to execute
- `investigation_type` (optional): Type of investigation
- `target_systems` (optional): List of target system IDs
- `parameters` (optional): Detonator-specific parameters
- `evidence_chain` (optional): Evidence chain information (CDIF requirement)
- `case_id` (optional): Associated case ID

**CDIF Compliance**: Requires `evidence_chain` for court-admissible evidence.

---

#### `pyro_create_case`

Create a new investigation case.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "Ransomware Investigation - Company XYZ",
    "investigation_type": "ransomware",
    "priority": "P0",
    "status": "active",
    "investigator": {
      "name": "Fire Marshal John Doe",
      "badge_number": "FM-001",
      "certification": "GCFA, GCFE, GCIH"
    }
  }
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "case": {
      "case_id": "CASE-FM-2025-001",
      "case_number": "FM-RAN-20250129-001",
      "case_name": "Ransomware Investigation - Company XYZ",
      "investigation_type": "ransomware",
      "priority": "P0",
      "status": "active",
      "investigator": {
        "name": "Fire Marshal John Doe",
        "badge_number": "FM-001"
      },
      "created_at": "2025-01-29T10:15:30.123Z",
      "updated_at": "2025-01-29T10:15:30.123Z"
    },
    "success": true
  }
}
```

**Parameters**:
- `case_id` (required): Unique case identifier
- `case_name` (required): Human-readable case name
- `investigation_type` (required): Type of investigation
- `priority` (optional): Priority level (P0, P1, P2, P3)
- `status` (optional): Case status (active, closed, archived)
- `investigator` (optional): Investigator information

---

### Agent Methods

#### `pyro_list_agents`

List all available agents.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "pyro_list_agents",
  "params": {}
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "agents": [
      {
        "agent_id": "agent-001",
        "name": "Windows Endpoint 01",
        "platform": "windows",
        "status": "online",
        "last_seen": "2025-01-29T10:15:00.000Z",
        "capabilities": ["process_analysis", "memory_dump", "network_capture"]
      }
    ],
    "count": 15
  }
}
```

---

### Query Methods

#### `pyro_execute_pql`

Execute a PQL (Pyro Query Language) query.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "pyro_execute_pql",
  "params": {
    "query": "SELECT process_name, pid FROM processes WHERE suspicious = true",
    "target_agents": ["agent-001", "agent-002"],
    "timeout_seconds": 300,
    "max_results": 10000
  }
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 5,
  "result": {
    "query": {
      "query_id": "QUERY-20250129-001",
      "status": "completed",
      "results": [
        {
          "process_name": "suspicious.exe",
          "pid": 1337
        }
      ],
      "progress": 100.0,
      "error": null
    },
    "success": true
  }
}
```

**Parameters**:
- `query` (required): PQL query string
- `target_agents` (optional): List of agent IDs to query
- `timeout_seconds` (optional): Query timeout (default: 300)
- `max_results` (optional): Maximum results to return (default: 10000)

---

### System Methods

#### `pyro_health`

Get system health status.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "pyro_health",
  "params": {}
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 6,
  "result": {
    "health": {
      "system_status": "healthy",
      "version": "Fire Marshal Cryptex v2.0.0",
      "uptime_seconds": 847392,
      "health_checks": {
        "database_connection": "healthy",
        "detonator_registry": "healthy",
        "evidence_chain": "healthy",
        "quantum_verification": "healthy",
        "api_gateway": "healthy"
      }
    },
    "success": true
  }
}
```

---

#### `pyro_authenticate`

Authenticate and get JWT token.

**Request**:
```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "pyro_authenticate",
  "params": {}
}
```

**Response**:
```json
{
  "jsonrpc": "2.0",
  "id": 7,
  "result": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "success": true
  }
}
```

**Note**: Requires `username` and `password` in configuration.

---

## Error Responses

All methods may return errors in this format:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "data": {
      "details": "Additional error details",
      "trace_id": "TRC-FM-20250129-001"
    }
  }
}
```

### Common Error Codes

- `METHOD_NOT_FOUND` - Unknown method
- `INVALID_PARAMS` - Invalid request parameters
- `AUTHENTICATION_FAILED` - Authentication error
- `CDIF_COMPLIANCE_ERROR` - CDIF compliance validation failed
- `API_ERROR` - PYRO Platform API error
- `NETWORK_ERROR` - Network/connection error

---

## CDIF Compliance

### Terminology Requirements

All requests must use Fire Marshal terminology:
- ✅ "investigation" (NOT "hunt")
- ✅ "detonator" (NOT "artifact")
- ✅ "agent" (NOT "client")
- ✅ "collection" (NOT "execution")
- ✅ "case" (NOT "session")

### Evidence Chain Requirements

Operations requiring court-admissible evidence must include `evidence_chain`:
- Case creation
- Detonator execution
- Evidence collection

### Quantum Verification

When `quantum_verification: true` is set:
- Evidence includes BLAKE3 + SHA3-256 hashes
- Chain integrity is verified
- Court-admissible evidence is generated

---

## Rate Limiting

Default rate limits:
- **Investigation endpoints**: 100 requests/minute
- **Query endpoints**: 50 requests/minute
- **System endpoints**: 300 requests/minute

Configure via `rate_limit_per_minute` in config.

---

## Best Practices

1. **Always include case_id** for operations that generate evidence
2. **Use evidence_chain** for court-admissible evidence
3. **Enable quantum_verification** for critical investigations
4. **Handle errors gracefully** - check error responses
5. **Cache authentication tokens** - don't re-authenticate for every request
6. **Use appropriate timeouts** - set realistic query timeouts
7. **Follow CDIF standards** - use correct terminology

---

## Examples

See `examples/` directory for complete examples:
- `basic-usage.sh` - Basic method usage
- `investigation-workflow.sh` - Complete investigation workflow

---

**Version**: 0.1.0  
**Last Updated**: 2025-01-XX

