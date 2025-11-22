#!/bin/bash
# Run all analysis and generate comprehensive TODO list

set -e

echo "🩸 Running Complete Analysis Suite..."
echo "======================================"
echo ""

# 1. Gap Analysis
echo "📊 Step 1: Gap Analysis"
echo "----------------------"
./scripts/run-gap-analysis.sh > gap-analysis-output.json 2>&1 || true
echo ""

# 2. Code Analysis
echo "📦 Step 2: Code Structure Analysis"
echo "-----------------------------------"
cargo run --bin mcp-translator <<EOF > code-analysis.json 2>&1 || true
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "analyze_codebase",
  "params": {
    "directory_path": "./cmd/api/src",
    "language": "go"
  }
}
EOF
echo ""

# 3. Extract Functions
echo "🔍 Step 3: Function Extraction"
echo "-------------------------------"
echo "Extracting key functions..."
for file in cmd/api/src/bootstrap/server.go cmd/api/src/api/auth.go; do
    if [ -f "$file" ]; then
        echo "  - $file"
        cargo run --bin mcp-translator <<EOF > /dev/null 2>&1 || true
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "extract_functions",
  "params": {
    "file_path": "$file",
    "language": "go"
  }
}
EOF
    fi
done
echo ""

# 4. Generate TODO List
echo "📋 Step 4: Generating TODO List"
echo "--------------------------------"
./scripts/generate-todo-list.sh

echo ""
echo "✅ Analysis complete!"
echo ""
echo "📄 Results saved to:"
echo "   - gap-analysis-output.json"
echo "   - code-analysis.json"
echo "   - TODO.md (generated)"

