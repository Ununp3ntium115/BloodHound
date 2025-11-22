#!/bin/bash
# Create agents from gap analysis

echo "🔥 Creating implementation agents..."
echo ""

cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "create_agents",
  "params": {
    "go_source_path": "./cmd/api/src",
    "rust_source_path": "./pyro-core/src"
  }
}
EOF

echo ""
echo "✅ Agents created!"
echo "   Use './scripts/agent-roadmap.sh' to view the roadmap"
echo "   Use './scripts/agent-status.sh <module>' to check status"

