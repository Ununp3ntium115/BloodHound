# MCP Translator Server

MCP (Model Context Protocol) server for translating source code into Cryptex structure with anarchist naming conventions.

## Overview

The MCP Translator Server automatically converts source code from various languages (Go, Rust, JavaScript, Python) into the Cryptex hierarchical file structure, organizing functions with anarchist-themed naming.

## Features

- **Multi-language Support**: Parse Go, Rust, JavaScript, and Python
- **Function Extraction**: Automatically extract functions, signatures, and relationships
- **Call Graph Analysis**: Build parent-child relationships based on function calls
- **Cryptex Translation**: Convert extracted functions to Cryptex structure
- **Anarchist Naming**: Apply Pyro/Fire Marshal themed naming conventions

## Usage

### As MCP Server

The server communicates via stdio using JSON-RPC 2.0 protocol:

```bash
cargo run --bin mcp-translator
```

### MCP Methods

#### `translate_file`

Translate a single source file to Cryptex:

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "translate_file",
  "params": {
    "file_path": "./src/main.go",
    "language": "go",
    "cryptex_path": "./cryptex_output"
  }
}
```

#### `translate_directory`

Translate an entire directory:

```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api",
    "language": "go",
    "cryptex_path": "./cryptex_output",
    "recursive": true
  }
}
```

#### `analyze_codebase`

Analyze codebase structure:

```json
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "analyze_codebase",
  "params": {
    "directory_path": "./cmd/api",
    "language": "go"
  }
}
```

#### `extract_functions`

Extract functions from a file:

```json
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "extract_functions",
  "params": {
    "file_path": "./src/main.go",
    "language": "go"
  }
}
```

## Example: Translating BloodHound Go Code

```bash
# Start MCP server
cargo run --bin mcp-translator

# In another process, send request:
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

## Output Structure

The translator creates a Cryptex structure like:

```
cryptex_output/
  extract_data_pyro_parse_nodes/
    function.rs
    pseudocode.md
  extract_data_pyro_parse_nodes_flame_parse_edges/
    function.rs
    pseudocode.md
```

Each function directory contains:
- `function.rs` - The original function code
- `pseudocode.md` - Generated pseudocode with function metadata

## Integration with Cursor/Claude

Configure the MCP server in your Cursor settings:

```json
{
  "mcpServers": {
    "cryptex-translator": {
      "command": "cargo",
      "args": ["run", "--bin", "mcp-translator"],
      "cwd": "/path/to/pyro"
    }
  }
}
```

Then use it in Cursor to translate codebases automatically!

## Principles

- **Autonomous Translation** - No manual intervention needed
- **Preserve Relationships** - Maintain function call hierarchies
- **Anarchist Branding** - Apply themed naming automatically
- **Code Sovereignty** - Keep original code structure intact

