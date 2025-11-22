# Changelog - PYRO Detector

All notable changes to PYRO Detector MCP Server will be documented in this file.

## [0.1.0] - 2025-01-XX

### Added
- Initial release of PYRO Detector MCP Server
- MCP protocol implementation (JSON-RPC 2.0)
- PYRO Platform Ignition API client
- CDIF compliance validation
- Fire Marshal terminology enforcement

### Features
- **Investigation Methods**:
  - `pyro_list_detonators` - List available detonators
  - `pyro_execute_detonator` - Execute Fire Marshal detonators
  - `pyro_create_case` - Create investigation cases

- **Agent Methods**:
  - `pyro_list_agents` - List all agents

- **Query Methods**:
  - `pyro_execute_pql` - Execute PQL queries

- **System Methods**:
  - `pyro_health` - System health check
  - `pyro_authenticate` - Authentication

### CDIF Compliance
- Fire Marshal terminology validation
- Evidence chain requirements
- Quantum verification support
- Court-admissible evidence support

### Documentation
- Complete README with API reference
- Integration guide for PYRO Platform Ignition
- Quick start guide
- Cursor setup instructions

### Configuration
- File-based configuration (`pyro-detector-config.json`)
- Environment variable support
- JWT token authentication
- Username/password authentication

---

## Future Releases

### [0.2.0] - Planned
- WebSocket support for real-time updates
- Batch detonator execution
- Query result streaming
- Enhanced error handling
- Performance metrics

### [0.3.0] - Planned
- Agent management operations
- Case workflow automation
- Evidence chain management
- Report generation
- Advanced PQL features

---

**Format**: [Semantic Versioning](https://semver.org/)
