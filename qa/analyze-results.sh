#!/bin/bash
# Analyze SDLC Test Results
# Analyzes test results and generates insights

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results/sdlc"
SUMMARY_FILE="$RESULTS_DIR/sdlc-test-summary.json"
ANALYSIS_FILE="$RESULTS_DIR/analysis.json"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     📊 SDLC Test Results Analysis 📊                         ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$SUMMARY_FILE" ]; then
    echo "❌ Error: Test summary not found: $SUMMARY_FILE"
    echo "   Run ./qa/run-all-sdlc-tests.sh first"
    exit 1
fi

# Extract metrics
TOTAL_TESTS=$(jq -r '.total_passed + .total_failed' "$SUMMARY_FILE")
TOTAL_PASSED=$(jq -r '.total_passed' "$SUMMARY_FILE")
TOTAL_FAILED=$(jq -r '.total_failed' "$SUMMARY_FILE")
TOTAL_SKIPPED=$(jq -r '.total_skipped' "$SUMMARY_FILE")
PASS_RATE=$(jq -r '.pass_rate' "$SUMMARY_FILE")
DURATION=$(jq -r '.duration_seconds' "$SUMMARY_FILE")

echo "Test Metrics:"
echo "  Total Tests: $TOTAL_TESTS"
echo "  Passed: $TOTAL_PASSED"
echo "  Failed: $TOTAL_FAILED"
echo "  Skipped: $TOTAL_SKIPPED"
echo "  Pass Rate: ${PASS_RATE}%"
echo "  Duration: ${DURATION}s"
echo ""

# Analyze suites
echo "Suite Analysis:"
jq -r '.suites[] | "  \(.name): \(.passed) passed, \(.failed) failed"' "$SUMMARY_FILE"
echo ""

# Identify failing suites
FAILING_SUITES=$(jq -r '.suites[] | select(.failed > 0) | .name' "$SUMMARY_FILE" | tr '\n' ',' | sed 's/,$//')

if [ -n "$FAILING_SUITES" ]; then
    echo "⚠️  Failing Suites:"
    echo "  $FAILING_SUITES"
    echo ""
fi

# Generate analysis
{
    echo "{"
    echo "  \"analysis_timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"summary\": {"
    echo "    \"total_tests\": $TOTAL_TESTS,"
    echo "    \"total_passed\": $TOTAL_PASSED,"
    echo "    \"total_failed\": $TOTAL_FAILED,"
    echo "    \"total_skipped\": $TOTAL_SKIPPED,"
    echo "    \"pass_rate\": $PASS_RATE,"
    echo "    \"duration_seconds\": $DURATION"
    echo "  },"
    echo "  \"recommendations\": ["
    
    if (( $(echo "$PASS_RATE < 95" | bc -l) )); then
        echo "    \"Pass rate below 95%. Review failing tests.\","
    fi
    
    if [ "$TOTAL_FAILED" -gt 0 ]; then
        echo "    \"$TOTAL_FAILED test(s) failed. Investigate and fix.\","
    fi
    
    if [ "$TOTAL_SKIPPED" -gt 0 ]; then
        echo "    \"$TOTAL_SKIPPED test(s) skipped. Review and enable.\","
    fi
    
    echo "    \"Review test logs for detailed failure information.\""
    echo "  ]"
    echo "}"
} > "$ANALYSIS_FILE"

echo "✅ Analysis complete: $ANALYSIS_FILE"

