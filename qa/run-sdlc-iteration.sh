#!/bin/bash
# SDLC Iteration Cycle - Complete Iteration Execution
# Executes full SDLC iteration cycle: Test → Analyze → Fix → Validate → Document

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results/sdlc"
ITERATION_DIR="$RESULTS_DIR/iterations"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ITERATION_ID="iter_${TIMESTAMP}"

mkdir -p "$ITERATION_DIR/$ITERATION_ID"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║     🔄 PYRO Detector - SDLC Iteration Cycle 🔄              ║"
echo "║                                                              ║"
echo "║     Iteration ID: $ITERATION_ID                              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Phase 1: Test Execution
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 1: Test Execution"
echo "═══════════════════════════════════════════════════════════════"
echo ""

"$SCRIPT_DIR/run-all-sdlc-tests.sh" > "$ITERATION_DIR/$ITERATION_ID/phase1_test_execution.log" 2>&1
TEST_EXIT_CODE=$?

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✅ Phase 1: Test Execution - PASSED"
else
    echo "⚠️  Phase 1: Test Execution - FAILED (see log for details)"
fi

# Phase 2: Analysis
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 2: Analysis"
echo "═══════════════════════════════════════════════════════════════"
echo ""

if [ -f "$RESULTS_DIR/sdlc-test-summary.json" ]; then
    # Analyze results
    TOTAL_TESTS=$(jq -r '.total_passed + .total_failed' "$RESULTS_DIR/sdlc-test-summary.json" 2>/dev/null || echo "0")
    TOTAL_PASSED=$(jq -r '.total_passed' "$RESULTS_DIR/sdlc-test-summary.json" 2>/dev/null || echo "0")
    TOTAL_FAILED=$(jq -r '.total_failed' "$RESULTS_DIR/sdlc-test-summary.json" 2>/dev/null || echo "0")
    
    if [ "$TOTAL_TESTS" -gt 0 ]; then
        PASS_RATE=$(awk "BEGIN {printf \"%.2f\", ($TOTAL_PASSED / $TOTAL_TESTS) * 100}")
        echo "Test Results:"
        echo "  Total Tests: $TOTAL_TESTS"
        echo "  Passed: $TOTAL_PASSED"
        echo "  Failed: $TOTAL_FAILED"
        echo "  Pass Rate: ${PASS_RATE}%"
        
        {
            echo "{"
            echo "  \"iteration_id\": \"$ITERATION_ID\","
            echo "  \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\","
            echo "  \"total_tests\": $TOTAL_TESTS,"
            echo "  \"total_passed\": $TOTAL_PASSED,"
            echo "  \"total_failed\": $TOTAL_FAILED,"
            echo "  \"pass_rate\": $PASS_RATE"
            echo "}"
        } > "$ITERATION_DIR/$ITERATION_ID/phase2_analysis.json"
        
        echo "✅ Phase 2: Analysis - COMPLETE"
    else
        echo "⚠️  Phase 2: Analysis - No test results found"
    fi
else
    echo "⚠️  Phase 2: Analysis - Test summary not found"
fi

# Phase 3: Issue Tracking
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 3: Issue Tracking"
echo "═══════════════════════════════════════════════════════════════"
echo ""

ISSUE_TRACKER="$SCRIPT_DIR/../testing/ISSUE_TRACKER.md"
if [ -f "$ISSUE_TRACKER" ]; then
    ISSUE_COUNT=$(grep -c "^\*\*Issue" "$ISSUE_TRACKER" 2>/dev/null || echo "0")
    echo "Issue Tracker: $ISSUE_TRACKER"
    echo "  Total Issues: $ISSUE_COUNT"
    echo "✅ Phase 3: Issue Tracking - COMPLETE"
else
    echo "⚠️  Phase 3: Issue Tracking - Tracker not found"
fi

# Phase 4: Remediation (Manual - documented)
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 4: Remediation"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "ℹ️  Phase 4: Remediation - MANUAL PROCESS"
echo "   Review issues in: $ISSUE_TRACKER"
echo "   Fix identified issues"
echo "   Update code and tests"

# Phase 5: Validation (if fixes applied)
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 5: Validation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Have fixes been applied? Run validation tests? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running validation tests..."
    "$SCRIPT_DIR/run-all-sdlc-tests.sh" > "$ITERATION_DIR/$ITERATION_ID/phase5_validation.log" 2>&1
    VALIDATION_EXIT_CODE=$?
    
    if [ $VALIDATION_EXIT_CODE -eq 0 ]; then
        echo "✅ Phase 5: Validation - PASSED"
    else
        echo "⚠️  Phase 5: Validation - FAILED (see log for details)"
    fi
else
    echo "⏭️  Phase 5: Validation - SKIPPED (no fixes applied)"
fi

# Phase 6: Documentation
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Phase 6: Documentation"
echo "═══════════════════════════════════════════════════════════════"
echo ""

{
    echo "# SDLC Iteration Report - $ITERATION_ID"
    echo ""
    echo "**Date**: $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
    echo ""
    echo "## Iteration Summary"
    echo ""
    echo "### Test Results"
    echo "- Total Tests: $TOTAL_TESTS"
    echo "- Passed: $TOTAL_PASSED"
    echo "- Failed: $TOTAL_FAILED"
    echo "- Pass Rate: ${PASS_RATE}%"
    echo ""
    echo "### Issues"
    echo "- Total Issues: $ISSUE_COUNT"
    echo ""
    echo "### Status"
    if [ $TEST_EXIT_CODE -eq 0 ]; then
        echo "- Status: ✅ PASSED"
    else
        echo "- Status: ⚠️  FAILED"
    fi
    echo ""
    echo "## Files"
    echo "- Test Execution Log: phase1_test_execution.log"
    echo "- Analysis Results: phase2_analysis.json"
    if [ -f "$ITERATION_DIR/$ITERATION_ID/phase5_validation.log" ]; then
        echo "- Validation Log: phase5_validation.log"
    fi
    echo ""
} > "$ITERATION_DIR/$ITERATION_ID/ITERATION_REPORT.md"

echo "✅ Phase 6: Documentation - COMPLETE"
echo "   Report: $ITERATION_DIR/$ITERATION_ID/ITERATION_REPORT.md"

# Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  SDLC Iteration Cycle Summary                               ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo "║  Iteration ID: $ITERATION_ID                                  ║"
echo "║  Total Tests: $TOTAL_TESTS                                    ║"
echo "║  Passed: $TOTAL_PASSED                                        ║"
echo "║  Failed: $TOTAL_FAILED                                        ║"
echo "║  Pass Rate: ${PASS_RATE}%                                      ║"
echo "║  Issues: $ISSUE_COUNT                                          ║"
echo "║  Report: $ITERATION_DIR/$ITERATION_ID/ITERATION_REPORT.md     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ $TEST_EXIT_CODE -eq 0 ]; then
    exit 0
else
    exit 1
fi

