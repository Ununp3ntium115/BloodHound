#!/bin/bash
# Translate entire BloodHound codebase to Cryptex

echo "🔥 Starting full BloodHound codebase translation..."
echo ""

# Define modules to translate
declare -a modules=(
    "bootstrap:cmd/api/src/bootstrap"
    "api:cmd/api/src/api"
    "auth:cmd/api/src/auth"
    "database:cmd/api/src/database"
    "services:cmd/api/src/services"
    "model:cmd/api/src/model"
    "config:cmd/api/src/config"
)

# Translate each module
for module_info in "${modules[@]}"; do
    IFS=':' read -r module_name module_path <<< "$module_info"
    
    echo "📦 Translating $module_name module..."
    
    # Create output directory
    mkdir -p "cryptex/pyro/$module_name"
    
    # Translate using MCP server
    cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": $RANDOM,
  "method": "translate_directory",
  "params": {
    "directory_path": "./$module_path",
    "language": "go",
    "cryptex_path": "./cryptex/pyro/$module_name",
    "recursive": true
  }
}
EOF
    
    echo "   ✅ $module_name complete"
    echo ""
done

echo "🔥 Full translation complete!"
echo "   Check: cryptex/pyro/"

