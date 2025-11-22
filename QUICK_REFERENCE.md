# 🔥 Quick Reference Card

**BloodHound Workspace - Quick Commands and Links**

---

## 🚀 PYRO Detector (Complete)

### Build & Run
```bash
cd pyro-detector
cargo build --release
cargo run --bin pyro-detector
```

### Configure
```bash
cp pyro-detector-config.json.example pyro-detector-config.json
# Edit with your PYRO Platform settings
```

### Test
```bash
./test-connection.sh  # Linux/Mac
.\test-connection.ps1  # Windows
```

### Documentation
- **Start**: [`pyro-detector/README_START_HERE.md`](pyro-detector/README_START_HERE.md)
- **Quick Start**: [`pyro-detector/QUICK_START.md`](pyro-detector/QUICK_START.md)
- **API**: [`pyro-detector/API_REFERENCE.md`](pyro-detector/API_REFERENCE.md)

---

## 🔧 MCP Translator

### Build & Run
```bash
cargo build --package mcp-translator --release
cargo run --bin mcp-translator
```

### Documentation
- **README**: [`mcp-translator/README.md`](mcp-translator/README.md)
- **Usage**: [`mcp-translator/USAGE.md`](mcp-translator/USAGE.md)

---

## 🏗️ Workspace

### Build All
```bash
cargo build --workspace --release
```

### Test All
```bash
cargo test --workspace
```

### Documentation
- **Overview**: [`WORKSPACE_OVERVIEW.md`](WORKSPACE_OVERVIEW.md)
- **Integration**: [`PYRO_DETECTOR_INTEGRATION.md`](PYRO_DETECTOR_INTEGRATION.md)

---

## 📋 MCP Methods (PYRO Detector)

1. `pyro_list_detonators` - List detonators
2. `pyro_execute_detonator` - Execute detonator
3. `pyro_create_case` - Create case
4. `pyro_list_agents` - List agents
5. `pyro_execute_pql` - Execute PQL
6. `pyro_health` - Health check
7. `pyro_authenticate` - Authenticate

---

## 🔥 Fire Marshal Terminology

| ✅ Correct | ❌ Incorrect |
|------------|--------------|
| investigation | hunt |
| detonator | artifact |
| agent | client |
| case | session |
| collection | execution |

---

## 📁 Key Directories

- `pyro-detector/` - PYRO Detector (complete)
- `mcp-translator/` - MCP Translator
- `pyro-core/` - Pyro core
- `cryptex/` - Cryptex system
- `fire-marshal/` - Fire Marshal
- `node-red-bridge/` - Node-RED bridge
- `steering/` - Steering documents

---

## 🎯 Common Tasks

### Set Up PYRO Detector in Cursor
1. Read [`pyro-detector/CURSOR_SETUP.md`](pyro-detector/CURSOR_SETUP.md)
2. Copy `mcp-config.json`
3. Add to Cursor MCP settings
4. Restart Cursor

### Deploy PYRO Detector
1. Read [`pyro-detector/DEPLOYMENT.md`](pyro-detector/DEPLOYMENT.md)
2. Build release version
3. Configure production
4. Deploy

### Troubleshoot Issues
1. Read [`pyro-detector/TROUBLESHOOTING.md`](pyro-detector/TROUBLESHOOTING.md)
2. Check [`pyro-detector/FAQ.md`](pyro-detector/FAQ.md)
3. Validate: [`pyro-detector/VALIDATION.md`](pyro-detector/VALIDATION.md)

---

## 📚 Essential Documentation

### PYRO Detector
- `README_START_HERE.md` - Start here
- `QUICK_START.md` - Quick start
- `API_REFERENCE.md` - API reference
- `MASTER_INDEX.md` - All docs

### Workspace
- `WORKSPACE_OVERVIEW.md` - Overview
- `MASTER_PROJECT_INDEX.md` - Master index
- `README.md` - Main README

---

## ✅ Status

- **PYRO Detector**: ✅ Complete
- **MCP Translator**: 🟢 Active
- **Workspace**: ✅ Ready

---

🔥 **Quick Reference Card** 🔥

*Keep this handy for quick access!*

