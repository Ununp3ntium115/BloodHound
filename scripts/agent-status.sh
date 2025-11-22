#!/bin/bash
# Get agent status for a module

if [ -z "$1" ]; then
    echo "Usage: $0 <module>"
    echo "Example: $0 auth"
    echo ""
    echo "Available modules: auth, api, database, graphify, datapipe, upload, queries, analysis, config, bootstrap, utils"
    exit 1
fi

MODULE=$1

echo "🔥 Agent Status: $MODULE"
echo "========================"
echo ""

cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_agents",
  "params": {
    "module": "$MODULE"
  }
}
EOF

