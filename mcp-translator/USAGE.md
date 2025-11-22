# MCP Translator Server - Usage Guide

## Integration with Cursor

The MCP Translator Server is now configured for use with Cursor. Here's how to use it:

### 1. Automatic Setup

The server is configured in `.cursor/mcp.json`. Cursor should automatically detect and load it.

### 2. Manual Setup (if needed)

If automatic setup doesn't work:

1. Open Cursor Settings (`Ctrl+,` or `Cmd+,`)
2. Navigate to "Features" → "MCP"
3. Add the configuration from `mcp-translator/cursor-mcp-config.json`

### 3. Using in Cursor Chat

Once configured, you can use natural language to translate code:

**Examples:**

```
"Translate the Go code in cmd/api/src/auth/auth.go to Cryptex structure"

"Convert the entire cmd/api/src directory to Cryptex using the MCP translator"

"Analyze the codebase structure in cmd/api/src and show me the function relationships"

"Extract all functions from cmd/api/src/main.go"
```

## Direct Usage (Command Line)

### Translate a Single File

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "translate_file",
  "params": {
    "file_path": "./cmd/api/src/main.go",
    "language": "go",
    "cryptex_path": "./cryptex/output"
  }
}' | cargo run --bin mcp-translator
```

### Translate a Directory

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go",
    "cryptex_path": "./cryptex/bloodhound",
    "recursive": true
  }
}' | cargo run --bin mcp-translator
```

### Analyze Codebase

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "analyze_codebase",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go"
  }
}' | cargo run --bin mcp-translator
```

## Supported Languages

- **Go** (`go`) - Full support
- **Rust** (`rust`) - Full support
- **JavaScript/TypeScript** (`javascript`, `js`) - Basic support
- **Python** (`python`, `py`) - Full support

## Output Structure

When translating, the MCP server creates:

```
cryptex_path/
  function_name_pyro_child_function/
    function.rs      # Original function code
    pseudocode.md    # Generated pseudocode with metadata
```

## Function Relationships

The translator automatically:
- Detects function call relationships
- Builds parent-child hierarchies
- Preserves call graphs
- Applies anarchist naming conventions

## Tips

1. **Start Small**: Translate individual files first to understand the output
2. **Analyze First**: Use `analyze_codebase` to understand structure before translating
3. **Check Output**: Review the generated Cryptex structure to ensure correctness
4. **Iterate**: Translate in chunks for large codebases

## Troubleshooting

### Server Not Responding

```bash
# Check if server builds
cargo build --bin mcp-translator

# Test server directly
cargo run --bin mcp-translator
```

### Translation Errors

- Verify file paths are correct
- Check language parameter matches file type
- Ensure output directory is writable
- Review error messages in response

### Performance

- Use `--release` build for production
- For large codebases, translate subdirectories separately
- Consider using `analyze_codebase` first to plan translation

