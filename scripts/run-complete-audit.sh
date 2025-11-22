#!/bin/bash
# Run complete audit: gap analysis + create agents + generate reports

set -e

echo "🔥 Pyro Complete Audit"
echo "====================="
echo ""

# Step 1: Run gap analysis
echo "📊 Step 1: Running gap analysis..."
cargo run --bin mcp-translator > gap-analysis-raw.json <<EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "gap_analysis",
  "params": {
    "go_source_path": "./cmd/api/src",
    "rust_source_path": "./pyro-core/src"
  }
}
EOF

echo "✅ Gap analysis complete"
echo ""

# Step 2: Create agents
echo "🤖 Step 2: Creating implementation agents..."
./scripts/agent-create.sh > agent-creation.json 2>&1
echo "✅ Agents created"
echo ""

# Step 3: Get roadmap
echo "🗺️  Step 3: Generating roadmap..."
./scripts/agent-roadmap.sh > roadmap.json 2>&1
echo "✅ Roadmap generated"
echo ""

# Step 4: Get status for all modules
echo "📈 Step 4: Getting status for all modules..."
./scripts/agent-all-status.sh > all-status.json 2>&1
echo "✅ Status collected"
echo ""

echo "✅ Complete audit finished!"
echo ""
echo "📄 Results saved to:"
echo "   - gap-analysis-raw.json"
echo "   - agent-creation.json"
echo "   - roadmap.json"
echo "   - all-status.json"
echo ""
echo "📊 View roadmap: cat roadmap.json | jq"
echo "📈 View status: cat all-status.json | jq"

