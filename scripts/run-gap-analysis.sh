#!/bin/bash
# Run gap analysis between Go source and Rust implementation

echo "🩸 Running Gap Analysis..."
echo ""

# Build MCP translator
cargo build --bin mcp-translator

# Run gap analysis
cargo run --bin mcp-translator <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "gap_analysis",
  "params": {
    "go_source_path": "./cmd/api/src",
    "rust_source_path": "./bloodsniffer-core/src"
  }
}
EOF

echo ""
echo "✅ Gap analysis complete!"
echo "   Check output for missing functions and coverage"

