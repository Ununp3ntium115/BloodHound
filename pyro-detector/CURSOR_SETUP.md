# Cursor MCP Setup for PYRO Detector

🔥 **Complete Cursor Integration Guide** 🔥

## Overview

This guide shows you how to integrate PYRO Detector MCP server with Cursor IDE.

## Method 1: Cursor Settings UI

1. Open Cursor
2. Go to **Settings** (Ctrl+, or Cmd+,)
3. Search for "MCP" or "Model Context Protocol"
4. Click **Add Server** or **Edit MCP Servers**
5. Add the following configuration:

```json
{
  "command": "/absolute/path/to/pyro-detector/target/release/pyro-detector",
  "args": [],
  "env": {
    "PYRO_API_URL": "http://localhost:3001",
    "PYRO_API_TOKEN": "your-jwt-token-here"
  }
}
```

6. Save and restart Cursor

## Method 2: Configuration File

### Windows

Edit: `%APPDATA%\Cursor\User\globalStorage\saoudrizwan.claude-dev\settings\cline_mcp_settings.json`

### macOS

Edit: `~/Library/Application Support/Cursor/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

### Linux

Edit: `~/.config/Cursor/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

Add:

```json
{
  "mcpServers": {
    "pyro-detector": {
      "command": "/absolute/path/to/pyro-detector/target/release/pyro-detector",
      "args": [],
      "env": {
        "PYRO_API_URL": "http://localhost:3001",
        "PYRO_API_TOKEN": "your-jwt-token-here",
        "PYRO_CDIF_COMPLIANCE": "true",
        "PYRO_FIRE_MARSHAL_TERMINOLOGY": "true"
      }
    }
  }
}
```

## Method 3: Using Config File

1. Copy `mcp-config.json` from this directory
2. Merge it into your Cursor MCP configuration
3. Update paths and credentials
4. Restart Cursor

## Verification

After setup, you should see PYRO Detector in Cursor's MCP server list. You can test it by:

1. Opening a chat in Cursor
2. Typing: `@pyro-detector health`
3. You should get a response with system health

## Usage Examples

### In Cursor Chat

```
@pyro-detector list detonators for ransomware investigation

@pyro-detector create case for ransomware with priority P0

@pyro-detector execute detonator DET-RAN-001 on case CASE-FM-2025-001

@pyro-detector list all agents
```

### Available Commands

- `@pyro-detector health` - Check system health
- `@pyro-detector list detonators [type] [platform]` - List detonators
- `@pyro-detector create case [name] [type]` - Create investigation case
- `@pyro-detector execute detonator [id] [case]` - Execute detonator
- `@pyro-detector list agents` - List agents
- `@pyro-detector execute pql [query]` - Execute PQL query

## Troubleshooting

### Server Not Appearing

1. Check the path to `pyro-detector` is correct and absolute
2. Verify the binary exists: `ls -la target/release/pyro-detector`
3. Check Cursor logs for errors

### Connection Errors

1. Verify PYRO Platform Ignition is running:
   ```bash
   curl http://localhost:3001/api/v2/fire-marshal/admin/health
   ```

2. Check authentication token is valid

3. Verify API URL is correct

### Permission Errors

On Linux/Mac, ensure the binary is executable:
```bash
chmod +x target/release/pyro-detector
```

## Advanced Configuration

### Using Config File Instead of Environment

You can use a config file instead of environment variables:

```json
{
  "command": "/path/to/pyro-detector",
  "args": ["--config", "/path/to/pyro-detector-config.json"],
  "env": {}
}
```

### Multiple Environments

You can create multiple server configurations for different environments:

```json
{
  "mcpServers": {
    "pyro-detector-dev": {
      "command": "/path/to/pyro-detector",
      "env": {
        "PYRO_API_URL": "http://localhost:3001"
      }
    },
    "pyro-detector-prod": {
      "command": "/path/to/pyro-detector",
      "env": {
        "PYRO_API_URL": "https://api.pyro-fire-marshal.com",
        "PYRO_API_TOKEN": "prod-token"
      }
    }
  }
}
```

## Security Notes

- Never commit `pyro-detector-config.json` with real credentials
- Use environment variables for sensitive data
- Rotate API tokens regularly
- Use least-privilege API tokens

## Next Steps

- See [QUICK_START.md](QUICK_START.md) for basic usage
- Read [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for advanced features
- Check [README.md](README.md) for complete documentation

---

🔥 **PYRO Detector - Ready for Cursor Integration** 🔥

