# PYRO Detector - Complete Documentation Index

🔥 **Master Navigation Guide** 🔥

## Quick Navigation

### 🚀 Getting Started
- **[QUICK_START.md](QUICK_START.md)** - Get started in 5 minutes
- **[CURSOR_SETUP.md](CURSOR_SETUP.md)** - Cursor IDE integration
- **[setup.sh](setup.sh)** / **[setup.ps1](setup.ps1)** - Automated setup

### 📖 Documentation
- **[README.md](README.md)** - Main documentation and overview
- **[API_REFERENCE.md](API_REFERENCE.md)** - Complete API method reference
- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Detailed integration guide
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Production deployment guide

### 🎯 Examples & Workflows
- **[examples/basic-usage.sh](examples/basic-usage.sh)** - Basic usage examples
- **[examples/investigation-workflow.sh](examples/investigation-workflow.sh)** - Complete workflow
- **[examples/README.md](examples/README.md)** - Examples documentation

### 🔧 Configuration
- **[pyro-detector-config.json.example](pyro-detector-config.json.example)** - Configuration template
- **[mcp-config.json](mcp-config.json)** - Cursor MCP configuration

### 🧪 Testing
- **[test-connection.sh](test-connection.sh)** - Connection test (Linux/Mac)
- **[test-connection.ps1](test-connection.ps1)** - Connection test (Windows)

### 📋 Reference
- **[SUMMARY.md](SUMMARY.md)** - Implementation summary
- **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** - Complete implementation summary
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## Documentation by Use Case

### I want to...

#### ...get started quickly
1. Read [QUICK_START.md](QUICK_START.md)
2. Run `./setup.sh` (or `.\setup.ps1` on Windows)
3. Configure credentials
4. Test with `./test-connection.sh`

#### ...integrate with Cursor
1. Read [CURSOR_SETUP.md](CURSOR_SETUP.md)
2. Copy `mcp-config.json` configuration
3. Add to Cursor MCP settings
4. Restart Cursor

#### ...understand the API
1. Read [API_REFERENCE.md](API_REFERENCE.md)
2. Check [examples/](examples/) for usage
3. Review [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

#### ...deploy to production
1. Read [DEPLOYMENT.md](DEPLOYMENT.md)
2. Build release: `cargo build --release`
3. Configure production settings
4. Deploy using chosen method

#### ...see examples
1. Check [examples/README.md](examples/README.md)
2. Run [examples/basic-usage.sh](examples/basic-usage.sh)
3. Try [examples/investigation-workflow.sh](examples/investigation-workflow.sh)

---

## MCP Methods Quick Reference

| Method | Purpose | Documentation |
|--------|---------|---------------|
| `pyro_list_detonators` | List available detonators | [API_REFERENCE.md](API_REFERENCE.md#pyro_list_detonators) |
| `pyro_execute_detonator` | Execute a detonator | [API_REFERENCE.md](API_REFERENCE.md#pyro_execute_detonator) |
| `pyro_create_case` | Create investigation case | [API_REFERENCE.md](API_REFERENCE.md#pyro_create_case) |
| `pyro_list_agents` | List all agents | [API_REFERENCE.md](API_REFERENCE.md#pyro_list_agents) |
| `pyro_execute_pql` | Execute PQL query | [API_REFERENCE.md](API_REFERENCE.md#pyro_execute_pql) |
| `pyro_health` | System health check | [API_REFERENCE.md](API_REFERENCE.md#pyro_health) |
| `pyro_authenticate` | Authentication | [API_REFERENCE.md](API_REFERENCE.md#pyro_authenticate) |

---

## File Structure

```
pyro-detector/
├── src/                          # Source code
│   ├── main.rs                  # Entry point
│   ├── lib.rs                   # Library exports
│   ├── mcp_server.rs            # MCP server
│   ├── api.rs                   # API client
│   ├── config.rs                # Configuration
│   ├── cdif.rs                  # CDIF compliance
│   ├── types.rs                 # Type definitions
│   └── logging.rs               # Logging system
├── examples/                     # Usage examples
│   ├── basic-usage.sh           # Basic examples
│   ├── investigation-workflow.sh # Complete workflow
│   └── README.md                # Examples guide
├── README.md                     # Main documentation
├── API_REFERENCE.md              # API reference
├── INTEGRATION_GUIDE.md          # Integration guide
├── QUICK_START.md                # Quick start
├── CURSOR_SETUP.md               # Cursor setup
├── DEPLOYMENT.md                 # Deployment guide
├── SUMMARY.md                    # Summary
├── FINAL_SUMMARY.md              # Final summary
├── CHANGELOG.md                  # Version history
├── INDEX.md                      # This file
├── setup.sh                      # Setup (Linux/Mac)
├── setup.ps1                     # Setup (Windows)
├── test-connection.sh            # Test (Linux/Mac)
├── test-connection.ps1          # Test (Windows)
├── mcp-config.json               # Cursor config
├── pyro-detector-config.json.example # Config example
├── Cargo.toml                    # Project config
└── .gitignore                   # Git ignore
```

---

## Key Concepts

### CDIF Compliance
- **CDIF** = Critical Digital Investigation Fire Marshal
- Enforces Fire Marshal terminology
- Requires evidence chain for operations
- Supports quantum verification

### Fire Marshal Terminology
- Investigation (NOT hunt)
- Detonator (NOT artifact)
- Agent (NOT client)
- Collection (NOT execution)
- Case (NOT session)

### MCP Protocol
- JSON-RPC 2.0 standard
- stdio transport (stdin/stdout)
- Request/response pattern
- Error handling built-in

---

## Support & Resources

### Documentation
- All docs in `pyro-detector/` directory
- Examples in `examples/` directory
- API reference in `API_REFERENCE.md`

### PYRO Platform
- [PYRO Platform Ignition](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition)
- [API Integration Guide](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/docs/api/API_INTEGRATION_GUIDE.md)
- [Fire Marshal API Reference](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/steering/FIRE_MARSHAL_API_REFERENCE.md)
- [CDIF Framework](https://github.com/Ununp3ntium115/PYRO_Platform_Ignition/blob/main/steering/cdif/00_CDIF_MASTER_FRAMEWORK.md)

---

## Status

✅ **Implementation**: 100% Complete  
✅ **Documentation**: 100% Complete  
✅ **Testing**: Build Verified  
✅ **CDIF Compliance**: 100%  
✅ **Production Ready**: Yes

---

🔥 **PYRO Detector - Complete Documentation Index** 🔥

*Last Updated: 2025-01-XX*

