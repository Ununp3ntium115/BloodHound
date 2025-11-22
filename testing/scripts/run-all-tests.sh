#!/bin/bash
# Run all test scripts and generate summary report

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
SUMMARY_FILE="$RESULTS_DIR/test-summary.json"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR/logs"

# Initialize counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0
TIMEOUT=0

# Array to store results
declare -a RESULTS=()

echo "=== Running All PYRO Detector Tests ==="
echo "Results directory: $RESULTS_DIR"
echo ""

# Find all test scripts
for test_script in "$SCRIPT_DIR"/test-*.sh; do
    if [ -f "$test_script" ] && [ -x "$test_script" ]; then
        TOTAL=$((TOTAL + 1))
        TEST_NAME=$(basename "$test_script" .sh)
        echo "[$TOTAL] Running $TEST_NAME..."
        
        # Run test with timeout
        if timeout 300 "$test_script" >/dev/null 2>&1; then
            # Check result file
            RESULT_FILE="$RESULTS_DIR/${TEST_NAME}.json"
            if [ -f "$RESULT_FILE" ]; then
                RESULT=$(jq -r '.result' "$RESULT_FILE" 2>/dev/null || echo "UNKNOWN")
                case "$RESULT" in
                    "PASS")
                        PASSED=$((PASSED + 1))
                        echo "  ✓ PASS"
                        ;;
                    "FAIL")
                        FAILED=$((FAILED + 1))
                        echo "  ✗ FAIL"
                        ;;
                    "SKIP")
                        SKIPPED=$((SKIPPED + 1))
                        echo "  ⊘ SKIP"
                        ;;
                    *)
                        echo "  ? UNKNOWN"
                        ;;
                esac
                RESULTS+=("$RESULT_FILE")
            else
                echo "  ? NO RESULT FILE"
            fi
        else
            TIMEOUT=$((TIMEOUT + 1))
            echo "  ⏱ TIMEOUT"
        fi
    fi
done

echo ""
echo "=== Test Summary ==="
echo "Total: $TOTAL"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
echo "Timeout: $TIMEOUT"
echo ""

# Generate summary JSON
{
    echo "{"
    echo "  \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"total\": $TOTAL,"
    echo "  \"passed\": $PASSED,"
    echo "  \"failed\": $FAILED,"
    echo "  \"skipped\": $SKIPPED,"
    echo "  \"timeout\": $TIMEOUT,"
    echo "  \"pass_rate\": $(awk "BEGIN {printf \"%.2f\", ($PASSED / $TOTAL) * 100}"),"
    echo "  \"results\": ["
    FIRST=true
    for result_file in "${RESULTS[@]}"; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo ","
        fi
        jq . "$result_file" 2>/dev/null || echo "{}"
    done
    echo "  ]"
    echo "}"
} > "$SUMMARY_FILE"

echo "Summary written to: $SUMMARY_FILE"

# Exit with error if any tests failed
if [ $FAILED -gt 0 ] || [ $TIMEOUT -gt 0 ]; then
    exit 1
fi

exit 0

