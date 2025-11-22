#!/bin/bash
# Example script to translate BloodHound Go codebase to Cryptex

echo "🔧 Translating BloodHound codebase to Cryptex structure..."

# Translate the API directory
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "translate_directory",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go",
    "cryptex_path": "./cryptex/bloodhound-api",
    "recursive": true
  }
}
EOF

echo ""
echo "✅ Translation complete! Check ./cryptex/bloodhound-api"

