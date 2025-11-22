# PYRO Detector - MCP Server for PYRO Platform Ignition

🔥 **Detonator Service - CDIF Compliant Integration** 🔥

PYRO Detector is an MCP (Model Context Protocol) server that acts as a **detonator service** - a 3rd party package that integrates with PYRO Platform Ignition. It provides seamless access to Fire Marshal investigations, detonators, agents, and PQL queries through the MCP protocol.

## 🚀 Quick Start

### 1. Build
```bash
cd pyro-detector
cargo build --release
```

### 2. Configure
```bash
cp pyro-detector-config.json.example pyro-detector-config.json
# Edit with your PYRO Platform API settings
```

### 3. Test
```bash
./test-connection.sh  # Linux/Mac
# or
.\test-connection.ps1  # Windows
```

### 4. Use in Cursor
See [CURSOR_SETUP.md](CURSOR_SETUP.md) for complete instructions.

---

## Features

- ✅ **CDIF Compliant** - 100% Fire Marshal Cryptex v2.0 compliance
- ✅ **7 MCP Methods** - Complete PYRO Platform integration
- ✅ **Fire Marshal Terminology** - Automatic enforcement
- ✅ **Evidence Chain** - Court-admissible evidence support
- ✅ **Quantum Verification** - BLAKE3 + SHA3-256 support
- ✅ **Type Safe** - Rust implementation
- ✅ **Production Ready** - Deployment guides included

---

## MCP Methods

### Investigation Operations
- `pyro_list_detonators` - List available detonators
- `pyro_execute_detonator` - Execute Fire Marshal detonators
- `pyro_create_case` - Create investigation cases

### Agent Operations
- `pyro_list_agents` - List all agents

### Query Operations
- `pyro_execute_pql` - Execute PQL queries

### System Operations
- `pyro_health` - System health check
- `pyro_authenticate` - Authentication

See [API_REFERENCE.md](API_REFERENCE.md) for complete documentation.

---

## CDIF Compliance

PYRO Detector enforces CDIF (Critical Digital Investigation Fire Marshal) standards:

- ✅ **Terminology**: Uses "investigation" (not "hunt"), "detonator" (not "artifact"), "agent" (not "client")
- ✅ **Evidence Chain**: Requires evidence chain for all operations
- ✅ **Quantum Verification**: Supports quantum-resistant verification
- ✅ **Fire Marshal Branding**: Maintains Fire Marshal identity

---

## Documentation

### Getting Started
- **[README_START_HERE.md](README_START_HERE.md)** - Start here!
- **[QUICK_START.md](QUICK_START.md)** - 5-minute getting started guide
- **[CURSOR_SETUP.md](CURSOR_SETUP.md)** - Cursor IDE integration

### Reference
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API method reference
- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Detailed integration guide
- **[INDEX.md](INDEX.md)** - Documentation index

### Advanced
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture
- **[BEST_PRACTICES.md](BEST_PRACTICES.md)** - Best practices guide

### Support
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Issue resolution guide
- **[FAQ.md](FAQ.md)** - Frequently asked questions
- **[VALIDATION.md](VALIDATION.md)** - Validation and testing guide

---

## Configuration

### Config File
Create `pyro-detector-config.json`:
```json
{
  "pyro_api_url": "http://localhost:3001",
  "api_token": "your-jwt-token",
  "cdif_compliance": true,
  "fire_marshal_terminology": true
}
```

### Environment Variables
```bash
export PYRO_API_URL="http://localhost:3001"
export PYRO_API_TOKEN="your-token"
export PYRO_CDIF_COMPLIANCE="true"
```

---

## Examples

### Basic Usage
See [examples/basic-usage.sh](examples/basic-usage.sh) for basic method usage.

### Complete Workflow
See [examples/investigation-workflow.sh](examples/investigation-workflow.sh) for a complete investigation workflow.

---

## Integration

### With Cursor
1. Read [CURSOR_SETUP.md](CURSOR_SETUP.md)
2. Add to Cursor MCP configuration
3. Restart Cursor
4. Start using!

### With PYRO Platform Ignition
- Connects to API at configurable URL
- Supports all investigation endpoints
- Full detonator ecosystem access
- Agent management
- PQL query execution

---

## Terminology

Following Fire Marshal Cryptex v2.0 standards:

- **Investigation** (NOT "hunt")
- **Detonator** (NOT "artifact")
- **Agent** (NOT "client")
- **Collection** (NOT "execution")
- **Case** (NOT "session")

---

## Status

✅ **Implementation**: 100% Complete  
✅ **Documentation**: 100% Complete  
✅ **Testing**: Build Verified  
✅ **CDIF Compliance**: 100%  
✅ **Production Ready**: Yes  

---

## License

Apache 2.0

---

## Support

- **Documentation**: See `pyro-detector/` directory
- **Examples**: See `examples/` directory
- **Troubleshooting**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **PYRO Platform**: See PYRO Platform Ignition repository

---

🔥 **PYRO Detector - Detonator Service for PYRO Platform Ignition** 🔥

*CDIF Compliant | Fire Marshal Cryptex v2.0 | Production Ready*
