#!/bin/bash
# Smoke Tests - Quick validation of critical functionality
# Run after every build to ensure basic functionality works

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/smoke"
LOG_FILE="$RESULTS_DIR/smoke-tests.log"
RESULT_FILE="$RESULTS_DIR/smoke-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Smoke Tests - Critical Functionality ==="
log "Starting smoke tests at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

# Smoke Test 1: Binary Exists and Executable
log "Smoke Test 1: Binary Exists"
if [ -f "$MCP_BINARY" ] && [ -x "$MCP_BINARY" ]; then
    log "  ✓ PASS: Binary exists and is executable"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Binary missing or not executable"
    FAILED=$((FAILED + 1))
    RESULT="FAIL"
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "smoke_tests",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "passed": $PASSED,
    "failed": $FAILED,
    "error": "Binary not found or not executable"
}
EOF
    exit 1
fi

# Smoke Test 2: Health Check Responds
log "Smoke Test 2: Health Check"
REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
RESPONSE=$(echo "$REQUEST" | timeout 5 "$MCP_BINARY" 2>>"$LOG_FILE" || true)

if [ -z "$RESPONSE" ]; then
    log "  ✗ FAIL: No response from health check"
    FAILED=$((FAILED + 1))
elif echo "$RESPONSE" | jq -e '.result or .error' >/dev/null 2>&1; then
    log "  ✓ PASS: Health check responds"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Invalid response from health check"
    FAILED=$((FAILED + 1))
fi

# Smoke Test 3: JSON-RPC Format Valid
log "Smoke Test 3: JSON-RPC Format"
if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq . >/dev/null 2>&1; then
    if echo "$RESPONSE" | jq -e '.jsonrpc == "2.0"' >/dev/null 2>&1; then
        log "  ✓ PASS: Valid JSON-RPC 2.0 format"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Invalid JSON-RPC format"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ✗ FAIL: Invalid JSON response"
    FAILED=$((FAILED + 1))
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "smoke_tests",
    "test_name": "Smoke Tests - Critical Functionality",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Smoke Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

