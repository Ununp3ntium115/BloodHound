# PYRO Detector - Quick Start Guide

🔥 **Get Started in 5 Minutes** 🔥

## Prerequisites

- Rust installed (https://rustup.rs/)
- PYRO Platform Ignition running (http://localhost:3001)
- Valid API credentials

## Step 1: Build

```bash
cd pyro-detector
cargo build --release
```

Or use the setup script:

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**
```powershell
.\setup.ps1
```

## Step 2: Configure

Create `pyro-detector-config.json`:

```json
{
  "pyro_api_url": "http://localhost:3001",
  "api_token": "your-jwt-token-here",
  "cdif_compliance": true,
  "fire_marshal_terminology": true
}
```

Or use environment variables:

```bash
export PYRO_API_URL="http://localhost:3001"
export PYRO_API_TOKEN="your-token"
```

## Step 3: Test

```bash
# Test health check
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector
```

## Step 4: Add to Cursor

1. Open Cursor Settings
2. Go to MCP (Model Context Protocol) settings
3. Add server configuration:

```json
{
  "mcpServers": {
    "pyro-detector": {
      "command": "/absolute/path/to/pyro-detector/target/release/pyro-detector",
      "args": [],
      "env": {
        "PYRO_API_URL": "http://localhost:3001",
        "PYRO_API_TOKEN": "your-token"
      }
    }
  }
}
```

4. Restart Cursor

## Step 5: Use in Cursor

Now you can use PYRO Detector in Cursor:

```
@pyro-detector list detonators for ransomware investigation
@pyro-detector execute detonator DET-RAN-001 on case CASE-FM-2025-001
@pyro-detector create new investigation case for ransomware
```

## Example Workflow

### 1. Create Investigation Case

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "Ransomware Investigation",
    "investigation_type": "ransomware",
    "priority": "P0"
  }
}
```

### 2. List Available Detonators

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_list_detonators",
  "params": {
    "investigation_type": "ransomware",
    "platform": "windows"
  }
}
```

### 3. Execute Detonator

```json
{
  "jsonrpc": "2.0",
  "id": 3,
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

## Troubleshooting

### Connection Issues

```bash
# Test PYRO Platform connection
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
}' | ./target/release/pyro-detector
```

### CDIF Compliance Errors

Ensure you're using correct terminology:
- ✅ "investigation" (not "hunt")
- ✅ "detonator" (not "artifact")
- ✅ "agent" (not "client")

## Next Steps

- Read [README.md](README.md) for complete documentation
- See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for advanced usage
- Check PYRO Platform Ignition API docs for endpoint details

---

🔥 **Ready to investigate!** 🔥
