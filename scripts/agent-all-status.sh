#!/bin/bash
# Get status for all agents

echo "🔥 All Agent Status"
echo "==================="
echo ""

cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_agents",
  "params": {}
}
EOF

