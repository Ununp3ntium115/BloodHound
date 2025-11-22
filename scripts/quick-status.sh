#!/bin/bash
# Quick status check

echo "🩸 BloodSniffer Status Check"
echo "=============================="
echo ""

# Count TODOs
if [ -f "TODO.md" ]; then
    COMPLETED=$(grep -c "\[x\]" TODO.md 2>/dev/null || echo "0")
    REMAINING=$(grep -c "\[ \]" TODO.md 2>/dev/null || echo "115")
    TOTAL=$((COMPLETED + REMAINING))
    PERCENT=$((COMPLETED * 100 / TOTAL))
    
    echo "📊 Progress: $COMPLETED/$TOTAL ($PERCENT%)"
    echo ""
fi

# Check builds
echo "🔨 Build Status:"
if cargo build --message-format=short 2>&1 | grep -q "Finished"; then
    echo "   ✅ Build successful"
else
    echo "   ⚠️  Build issues detected"
fi
echo ""

# Check tests
echo "🧪 Test Status:"
TEST_COUNT=$(cargo test --no-run 2>&1 | grep -c "test result" || echo "0")
if [ "$TEST_COUNT" -gt 0 ]; then
    echo "   ✅ Tests configured"
else
    echo "   ⚠️  No tests found"
fi
echo ""

# Check modules
echo "📦 Module Status:"
MODULES=("bloodsniffer-core" "cryptex" "fire-marshal" "node-red-bridge" "mcp-translator")
for module in "${MODULES[@]}"; do
    if [ -d "$module" ]; then
        echo "   ✅ $module"
    else
        echo "   ❌ $module (missing)"
    fi
done
echo ""

echo "✅ Status check complete"

