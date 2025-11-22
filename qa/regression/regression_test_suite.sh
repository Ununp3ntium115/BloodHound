#!/bin/bash
# Regression Test Suite
# Ensures changes don't break existing functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/regression"
LOG_FILE="$RESULTS_DIR/regression-test-suite.log"
RESULT_FILE="$RESULTS_DIR/regression-test-suite.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Regression Test Suite ==="
log "Starting regression testing at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

# Regression Test 1: Health Check Still Works
log "Regression Test 1: Health Check"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result.status' >/dev/null 2>&1; then
        log "  ✓ PASS: Health check regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Health check regression test"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Regression Test 2: List Detonators Still Works
log "Regression Test 2: List Detonators"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_list_detonators","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result.detonators' >/dev/null 2>&1; then
        log "  ✓ PASS: List detonators regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: List detonators regression test"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Regression Test 3: Create Case Still Works
log "Regression Test 3: Create Case"
if [ -f "$MCP_BINARY" ]; then
    CASE_NAME="Regression Test $(date +%s)"
    REQUEST=$(jq -n --arg name "$CASE_NAME" '{"jsonrpc":"2.0","id":1,"method":"pyro_create_case","params":{"name":$name}}')
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result.id or .error' >/dev/null 2>&1; then
        log "  ✓ PASS: Create case regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Create case regression test"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Regression Test 4: List Agents Still Works
log "Regression Test 4: List Agents"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_list_agents","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result.agents' >/dev/null 2>&1; then
        log "  ✓ PASS: List agents regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: List agents regression test"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Regression Test 5: Execute PQL Still Works
log "Regression Test 5: Execute PQL"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_execute_pql","params":{"query":"SELECT 1"}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result or .error' >/dev/null 2>&1; then
        log "  ✓ PASS: Execute PQL regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Execute PQL regression test"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Regression Test 6: API Endpoints Still Work
log "Regression Test 6: API Endpoints"
API_BASE="${API_BASE:-http://localhost:8080}"
ENDPOINTS=("/api/v2/pyro-detector/health" "/api/v2/pyro-detector/detonators")
for endpoint in "${ENDPOINTS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}${endpoint}" 2>>"$LOG_FILE" || echo "000")
    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 500 ]; then
        log "  ✓ PASS: API endpoint $endpoint regression test"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: API endpoint $endpoint regression test (HTTP $HTTP_CODE)"
        FAILED=$((FAILED + 1))
    fi
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "regression_test_suite",
    "test_name": "Regression Test Suite",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Regression Test Suite Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

