#!/bin/bash
# Validate Fixes - Re-run tests after fixes
# Validates that fixes have resolved issues

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results/sdlc"
VALIDATION_FILE="$RESULTS_DIR/validation-$(date +%Y%m%d_%H%M%S).json"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     ✅ SDLC Fix Validation ✅                                 ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo "Running validation tests..."
"$SCRIPT_DIR/run-all-sdlc-tests.sh" > "$RESULTS_DIR/validation.log" 2>&1
VALIDATION_EXIT_CODE=$?

if [ -f "$RESULTS_DIR/sdlc-test-summary.json" ]; then
    TOTAL_TESTS=$(jq -r '.total_passed + .total_failed' "$RESULTS_DIR/sdlc-test-summary.json")
    TOTAL_PASSED=$(jq -r '.total_passed' "$RESULTS_DIR/sdlc-test-summary.json")
    TOTAL_FAILED=$(jq -r '.total_failed' "$RESULTS_DIR/sdlc-test-summary.json")
    PASS_RATE=$(jq -r '.pass_rate' "$RESULTS_DIR/sdlc-test-summary.json")
    
    {
        echo "{"
        echo "  \"validation_timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\","
        echo "  \"exit_code\": $VALIDATION_EXIT_CODE,"
        echo "  \"total_tests\": $TOTAL_TESTS,"
        echo "  \"total_passed\": $TOTAL_PASSED,"
        echo "  \"total_failed\": $TOTAL_FAILED,"
        echo "  \"pass_rate\": $PASS_RATE,"
        echo "  \"status\": \"$([ $VALIDATION_EXIT_CODE -eq 0 ] && echo 'PASSED' || echo 'FAILED')\""
        echo "}"
    } > "$VALIDATION_FILE"
    
    echo "Validation Results:"
    echo "  Total Tests: $TOTAL_TESTS"
    echo "  Passed: $TOTAL_PASSED"
    echo "  Failed: $TOTAL_FAILED"
    echo "  Pass Rate: ${PASS_RATE}%"
    echo ""
    
    if [ $VALIDATION_EXIT_CODE -eq 0 ]; then
        echo "✅ Validation: PASSED"
    else
        echo "⚠️  Validation: FAILED"
        echo "   Review: $RESULTS_DIR/validation.log"
    fi
    
    echo ""
    echo "Results saved to: $VALIDATION_FILE"
else
    echo "❌ Error: Test summary not found"
    exit 1
fi

exit $VALIDATION_EXIT_CODE

