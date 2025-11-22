#!/bin/bash
# Analyze BloodHound codebase structure

echo "🔍 Analyzing BloodHound codebase structure..."
echo ""

# Analyze main API directory
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "analyze_codebase",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go"
  }
}
EOF

echo ""
echo "✅ Analysis complete!"

