#!/bin/bash
# Update progress tracking in TODO.md

echo "🩸 Updating Progress Tracking..."
echo ""

# Count completed items
COMPLETED=$(grep -c "\[x\]" TODO.md || echo "0")
TOTAL=$(grep -c "\[ \]" TODO.md || echo "115")

PERCENTAGE=$(echo "scale=1; ($COMPLETED * 100) / ($COMPLETED + $TOTAL)" | bc)

echo "📊 Current Progress:"
echo "   Completed: $COMPLETED"
echo "   Remaining: $TOTAL"
echo "   Progress: ${PERCENTAGE}%"
echo ""

# Update TODO.md with progress
sed -i "s/\*\*Overall Progress:.*/\*\*Overall Progress: $COMPLETED\/115 (${PERCENTAGE}%)\*\*/" TODO.md

echo "✅ Progress updated in TODO.md"

