# BloodSniffer - Autonomous Data Liberation System

🩸 **"No gods, no masters, only autonomous systems"** 🩸

BloodSniffer is a complete re-engineering of BloodHound from the ground up using Rust, with anarchist branding and autonomous architecture.

## Components

### 🩸 BloodSniffer Core
Main application server providing REST API for data extraction and processing.

### 📁 Cryptex
Hierarchical file structure system that maps functions to a tree/index system using anarchist naming conventions. Each function is stored with its code and pseudocode documentation.

### 🔗 Node-RED Bridge
Integration layer for connecting to Node-RED flows for autonomous data pipelines.

### 🚒 Fire Marshal
Data flow orchestration and monitoring component.

### 🔧 MCP Translator Server
MCP server for automatically translating source code (Go, Rust, JavaScript, Python) into Cryptex structure.

## Architecture

```
┌──────────────────┐
│  BloodSniffer    │
└──────┬───────────┘
       │
       ├──► Cryptex (File Structure)
       │    └──► Functions organized in tree
       │
       ├──► ReDB (Database)
       │    └──► Persistent storage
       │
       ├──► Node-RED Bridge
       │    └──► Data pipeline integration
       │
       └──► MCP Translator
            └──► Source code → Cryptex conversion
```

## Features

- **Rust Native** - Built from the ground up in Rust for performance and safety
- **Anarchist Branding** - BloodSniffer/Fire Marshal themed with autonomous principles
- **Cryptex Structure** - Hierarchical function mapping with anarchist naming
- **ReDB Integration** - Embedded database for data storage
- **Node-RED Integration** - Connect to external data flows
- **BloodHound Data Extraction** - Import and process BloodHound JSON data
- **MCP Translator** - Automatically convert source code to Cryptex structure

## Building

### Windows (MSI/EXE)

```powershell
# Build release binaries
.\build-installer.ps1 -BuildType release

# Create EXE installer (requires Inno Setup)
.\build-installer.ps1 -CreateEXE

# Create MSI installer (requires WiX Toolset)
.\build-installer.ps1 -CreateMSI
```

### Linux/macOS

```bash
# Build release binaries
chmod +x build-installer.sh
./build-installer.sh release
```

### Manual Build

```bash
# Build all components
cargo build --release

# Run BloodSniffer server
cargo run --bin bloodsniffer

# Run Fire Marshal
cargo run --bin fire-marshal

# Run MCP Translator Server
cargo run --bin mcp-translator
```

## Using MCP Translator

### Translate BloodHound Go Codebase

```bash
# Start MCP server and translate
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go",
    "cryptex_path": "./cryptex/bloodhound",
    "recursive": true
  }
}' | cargo run --bin mcp-translator
```

### Available MCP Methods

- `translate_file` - Translate single file
- `translate_directory` - Translate entire directory
- `analyze_codebase` - Analyze codebase structure
- `extract_functions` - Extract functions from file

See [mcp-translator/README.md](mcp-translator/README.md) for details.

## Cryptex Structure

Cryptex organizes functions using the naming pattern:
```
[parent_function]_[anarchist_term]_[function_name]
```

Example:
- `extract_data_bloodsniffer_parse_nodes/`
- `extract_data_bloodsniffer_parse_nodes_flame_parse_edges/`

Each function directory contains:
- `function.rs` - Implementation code
- `pseudocode.md` - Human-readable description

## API Endpoints

### BloodSniffer Core (Port 3000)
- `GET /` - System information
- `GET /health` - Health check
- `POST /api/cryptex` - Add function to cryptex
- `GET /api/cryptex/:path` - Get function by path
- `POST /api/extract` - Extract BloodHound data and create functions
- `POST /api/pipeline` - Create data pipeline

### Fire Marshal (Port 3001)
- `GET /` - System information
- `GET /health` - Health check
- `GET /api/monitor` - Get monitoring statistics
- `POST /api/orchestrate` - Orchestrate data flow

## Configuration

Create `bloodsniffer.toml`:

```toml
[server]
host = "127.0.0.1"
port = 3000

[database]
path = "./data/bloodsniffer.redb"

[node_red]
mqtt_broker = "tcp://localhost:1883"
http_endpoint = "http://localhost:1880/bloodsniffer"

[cryptex]
default_theme = "anarchist"
```

## Principles

1. **Autonomous operation** - No central control
2. **Data sovereignty** - Encrypt and compartmentalize
3. **Horizontal organization** - Peer-to-peer architecture
4. **Mutual aid** - Share resources without hierarchy
5. **Direct action** - Execute without permission
6. **Decentralization** - Distribute power and data

## Installation

### Windows

1. Download `bloodsniffer-setup-0.1.0.exe` from releases
2. Run the installer
3. BloodSniffer will be installed to `C:\Program Files\BloodSniffer`
4. Start BloodSniffer from Start Menu or command line

### Linux/macOS

1. Extract the release archive
2. Copy binaries to `/usr/local/bin` or desired location
3. Run `bloodsniffer` or `fire-marshal` from command line

## License

Apache-2.0

