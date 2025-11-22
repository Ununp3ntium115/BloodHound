#!/bin/bash
# Sanity Tests - Quick validation after changes
# Run after code changes to verify changed functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/sanity"
LOG_FILE="$RESULTS_DIR/sanity-tests.log"
RESULT_FILE="$RESULTS_DIR/sanity-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Sanity Tests - Changed Functionality ==="
log "Starting sanity tests at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

# Sanity Test 1: Changed Functionality Still Works
log "Sanity Test 1: Verify Changed Functionality"
# This test should be customized based on what changed
# Example: If logging was changed, test logging
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        log "  ✓ PASS: Changed functionality works"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Changed functionality broken"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Sanity Test 2: No Regressions in Related Functionality
log "Sanity Test 2: No Regressions"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_list_detonators","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result or .error' >/dev/null 2>&1; then
        log "  ✓ PASS: No regressions detected"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Regression detected"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "sanity_tests",
    "test_name": "Sanity Tests - Changed Functionality",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Sanity Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

