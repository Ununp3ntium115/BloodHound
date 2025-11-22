# Setting up MCP Translator Server in Cursor

## Quick Setup

1. **Open Cursor Settings**
   - Press `Ctrl+,` (Windows/Linux) or `Cmd+,` (Mac)
   - Go to "Features" → "MCP"

2. **Add MCP Server Configuration**

   Add this configuration to your Cursor MCP settings:

   ```json
   {
     "mcpServers": {
       "cryptex-translator": {
         "command": "cargo",
         "args": [
           "run",
           "--release",
           "--bin",
           "mcp-translator"
         ],
         "cwd": "${workspaceFolder}",
         "env": {
           "RUST_LOG": "info"
         }
       }
     }
   }
   ```

3. **Build the MCP Server**

   ```bash
   cargo build --release --bin mcp-translator
   ```

4. **Restart Cursor**

   Restart Cursor to load the MCP server.

## Using the MCP Server

Once configured, you can use the MCP server in Cursor:

### Translate a File

Ask Cursor: "Translate `cmd/api/src/main.go` to Cryptex structure"

### Translate a Directory

Ask Cursor: "Translate the `cmd/api/src` directory to Cryptex using the MCP translator"

### Analyze Codebase

Ask Cursor: "Analyze the Go codebase structure using the MCP translator"

## Available MCP Methods

The server provides these methods:

1. **translate_file** - Translate single source file
2. **translate_directory** - Translate entire directory
3. **analyze_codebase** - Analyze codebase structure
4. **extract_functions** - Extract functions from file

## Example Usage in Cursor

```
User: Use the MCP translator to convert the BloodHound Go codebase 
      in cmd/api/src to Cryptex structure

Cursor: [Uses MCP server to translate code]
```

## Troubleshooting

### Server Not Starting

- Check that Rust/Cargo is installed: `cargo --version`
- Build the server: `cargo build --release --bin mcp-translator`
- Check Cursor MCP logs in the output panel

### Translation Fails

- Ensure source files exist at the specified path
- Check that the language parameter matches the file type
- Verify write permissions for the cryptex output directory

### Performance Issues

- Use `--release` build for better performance
- For large codebases, translate in smaller chunks
- Consider using `analyze_codebase` first to understand structure

