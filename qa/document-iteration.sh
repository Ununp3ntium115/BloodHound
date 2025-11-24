#!/bin/bash
# Document SDLC Iteration
# Creates comprehensive documentation for iteration results

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results/sdlc"
ITERATION_DIR="$RESULTS_DIR/iterations"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$ITERATION_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     📝 SDLC Iteration Documentation 📝                       ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Get latest iteration
LATEST_ITERATION=$(ls -t "$ITERATION_DIR" 2>/dev/null | head -1)

if [ -z "$LATEST_ITERATION" ]; then
    echo "⚠️  No iterations found. Run ./qa/run-sdlc-iteration.sh first."
    exit 1
fi

ITERATION_PATH="$ITERATION_DIR/$LATEST_ITERATION"
REPORT_FILE="$ITERATION_PATH/ITERATION_REPORT.md"

if [ -f "$REPORT_FILE" ]; then
    echo "✅ Iteration report exists: $REPORT_FILE"
    echo ""
    cat "$REPORT_FILE"
else
    echo "⚠️  Iteration report not found: $REPORT_FILE"
fi

# Generate summary
SUMMARY_FILE="$RESULTS_DIR/iteration-summary.md"
{
    echo "# SDLC Iteration Summary"
    echo ""
    echo "**Last Updated**: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    echo "## Latest Iteration"
    echo ""
    echo "- **Iteration ID**: $LATEST_ITERATION"
    echo "- **Report**: $REPORT_FILE"
    echo ""
    echo "## All Iterations"
    echo ""
    for iter in $(ls -t "$ITERATION_DIR" 2>/dev/null); do
        if [ -f "$ITERATION_DIR/$iter/ITERATION_REPORT.md" ]; then
            echo "- [$iter]($ITERATION_DIR/$iter/ITERATION_REPORT.md)"
        fi
    done
    echo ""
} > "$SUMMARY_FILE"

echo ""
echo "✅ Summary created: $SUMMARY_FILE"

