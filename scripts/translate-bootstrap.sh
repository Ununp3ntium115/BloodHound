#!/bin/bash
# Translate bootstrap module to Cryptex structure

echo "🔥 Translating bootstrap module to Cryptex..."

# Create output directory
mkdir -p cryptex/pyro/bootstrap

# Translate using MCP server
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src/bootstrap",
    "language": "go",
    "cryptex_path": "./cryptex/pyro/bootstrap",
    "recursive": true
  }
}
EOF

echo ""
echo "✅ Bootstrap translation complete!"
echo "   Check: cryptex/pyro/bootstrap/"

