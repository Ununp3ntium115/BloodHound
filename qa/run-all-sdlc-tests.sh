#!/bin/bash
# Run All SDLC Tests - Comprehensive Test Execution
# Executes all testing phases in the SDLC

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results/sdlc"
SUMMARY_FILE="$RESULTS_DIR/sdlc-test-summary.json"

mkdir -p "$RESULTS_DIR"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🔥 PYRO Detector - Complete SDLC Test Suite 🔥          ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

START_TIME=$(date +%s)
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0

declare -a TEST_SUITES=(
    "smoke:Smoke Tests:qa/smoke/smoke_tests.sh"
    "sanity:Sanity Tests:qa/sanity/sanity_tests.sh"
    "unit:Unit Tests:cargo test --lib"
    "integration:Integration Tests:qa/integration/pyro_detector_integration_tests.rs"
    "qa:QA Test Suite:qa/qa_test_suite.sh"
    "regression:Regression Tests:qa/regression/regression_test_suite.sh"
    "compatibility:Compatibility Tests:qa/compatibility/compatibility_tests.sh"
    "usability:Usability Tests:qa/usability/usability_tests.sh"
    "accessibility:Accessibility Tests:qa/accessibility/accessibility_tests.sh"
    "documentation:Documentation Tests:qa/documentation/doc_tests.sh"
    "deployment:Deployment Tests:qa/deployment/deployment_tests.sh"
    "rollback:Rollback Tests:qa/rollback/rollback_tests.sh"
    "monitoring:Monitoring Tests:qa/monitoring/monitoring_tests.sh"
    "dr:Disaster Recovery Tests:qa/disaster_recovery/dr_tests.sh"
    "ua:User Acceptance Tests:testing/scripts/run-all-tests.sh"
    "performance:Performance Tests:testing/scripts/test-25-load-test.sh testing/scripts/test-26-stress-test.sh testing/scripts/test-27-response-time-test.sh testing/scripts/test-28-memory-usage-test.sh"
    "security:Security Tests:testing/scripts/test-29-authentication-test.sh testing/scripts/test-30-authorization-test.sh testing/scripts/test-31-data-validation-test.sh"
)

SUITE_COUNT=0
SUITE_RESULTS=()

for suite_def in "${TEST_SUITES[@]}"; do
    IFS=':' read -r id name scripts <<< "$suite_def"
    SUITE_COUNT=$((SUITE_COUNT + 1))
    
    echo "[$SUITE_COUNT/${#TEST_SUITES[@]}] Running $name..."
    
    SUITE_PASSED=0
    SUITE_FAILED=0
    
    # Handle different script types
    if [[ "$scripts" == "cargo"* ]]; then
        # Rust unit tests
        if cargo test --lib 2>>"$RESULTS_DIR/${id}.log" >/dev/null 2>&1; then
            SUITE_PASSED=$((SUITE_PASSED + 1))
            echo "  ✓ PASS: $name"
        else
            SUITE_FAILED=$((SUITE_FAILED + 1))
            echo "  ✗ FAIL: $name"
        fi
    elif [[ "$scripts" == *.rs ]]; then
        # Rust integration tests
        if cargo test --test "$(basename $scripts .rs)" 2>>"$RESULTS_DIR/${id}.log" >/dev/null 2>&1; then
            SUITE_PASSED=$((SUITE_PASSED + 1))
            echo "  ✓ PASS: $name"
        else
            SUITE_FAILED=$((SUITE_FAILED + 1))
            echo "  ✗ FAIL: $name"
        fi
    else
        # Bash scripts
        for script in $scripts; do
            if [ -f "$script" ] && [ -x "$script" ]; then
                if "$script" >>"$RESULTS_DIR/${id}.log" 2>&1; then
                    SUITE_PASSED=$((SUITE_PASSED + 1))
                else
                    SUITE_FAILED=$((SUITE_FAILED + 1))
                fi
            else
                echo "  ⊘ SKIP: Script not found: $script"
                TOTAL_SKIPPED=$((TOTAL_SKIPPED + 1))
            fi
        done
        
        if [ $SUITE_FAILED -eq 0 ] && [ $SUITE_PASSED -gt 0 ]; then
            echo "  ✓ PASS: $name"
        elif [ $SUITE_FAILED -gt 0 ]; then
            echo "  ✗ FAIL: $name"
        else
            echo "  ⊘ SKIP: $name"
        fi
    fi
    
    TOTAL_PASSED=$((TOTAL_PASSED + SUITE_PASSED))
    TOTAL_FAILED=$((TOTAL_FAILED + SUITE_FAILED))
    
    SUITE_RESULTS+=("{\"id\":\"$id\",\"name\":\"$name\",\"passed\":$SUITE_PASSED,\"failed\":$SUITE_FAILED}")
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SDLC Test Suite Summary                                     ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Total Suites: ${#TEST_SUITES[@]}                                    ║"
echo "║  Passed: $TOTAL_PASSED                                        ║"
echo "║  Failed: $TOTAL_FAILED                                        ║"
echo "║  Skipped: $TOTAL_SKIPPED                                     ║"
echo "║  Duration: ${DURATION}s                                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"

# Generate summary JSON
{
    echo "{"
    echo "  \"test_suite\": \"sdlc_complete\","
    echo "  \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"duration_seconds\": $DURATION,"
    echo "  \"total_suites\": ${#TEST_SUITES[@]},"
    echo "  \"total_passed\": $TOTAL_PASSED,"
    echo "  \"total_failed\": $TOTAL_FAILED,"
    echo "  \"total_skipped\": $TOTAL_SKIPPED,"
    echo "  \"pass_rate\": $(awk "BEGIN {printf \"%.2f\", ($TOTAL_PASSED / ($TOTAL_PASSED + $TOTAL_FAILED)) * 100}"),"
    echo "  \"suites\": ["
    FIRST=true
    for result in "${SUITE_RESULTS[@]}"; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            echo ","
        fi
        echo -n "    $result"
    done
    echo ""
    echo "  ]"
    echo "}"
} > "$SUMMARY_FILE"

echo ""
echo "Summary written to: $SUMMARY_FILE"

if [ $TOTAL_FAILED -gt 0 ]; then
    exit 1
fi

exit 0

