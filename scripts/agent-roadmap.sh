#!/bin/bash
# Get implementation roadmap

echo "🔥 Pyro Implementation Roadmap"
echo "============================"
echo ""

cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "get_roadmap",
  "params": {}
}
EOF

echo ""
echo "📊 Use './scripts/agent-plan.sh <module>' for detailed plan"

