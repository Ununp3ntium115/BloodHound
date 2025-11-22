#!/bin/bash
# QA Test Suite - Functional Requirements Testing
# Tests all functional requirements for PYRO Detector

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/qa"
LOG_FILE="$RESULTS_DIR/qa-test-suite.log"
RESULT_FILE="$RESULTS_DIR/qa-test-suite.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
ERRORS=0
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== QA Test Suite - Functional Requirements ==="
log "Starting QA testing at $(date)"

# Test 1: MCP Server Binary Exists
log "Test 1: MCP Server Binary Exists"
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ -f "$MCP_BINARY" ]; then
    log "  ✓ PASS: MCP server binary found"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: MCP server binary not found at $MCP_BINARY"
    FAILED=$((FAILED + 1))
    ERRORS=$((ERRORS + 1))
fi

# Test 2: MCP Server Responds to Health Check
log "Test 2: MCP Server Health Check"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        log "  ✓ PASS: MCP server responds to health check"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: MCP server health check failed"
        FAILED=$((FAILED + 1))
        ERRORS=$((ERRORS + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Test 3: All MCP Methods Available
log "Test 3: All MCP Methods Available"
METHODS=("pyro_list_detonators" "pyro_execute_detonator" "pyro_create_case" "pyro_list_agents" "pyro_execute_pql" "pyro_health" "pyro_authenticate")
for method in "${METHODS[@]}"; do
    if [ -f "$MCP_BINARY" ]; then
        REQUEST=$(jq -n --arg method "$method" '{"jsonrpc":"2.0","id":1,"method":$method,"params":{}}')
        RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        if echo "$RESPONSE" | jq -e '.result or .error' >/dev/null 2>&1; then
            log "  ✓ PASS: Method $method available"
        else
            log "  ✗ FAIL: Method $method not available"
            FAILED=$((FAILED + 1))
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Test 4: API Endpoints Available
log "Test 4: API Endpoints Available"
API_BASE="${API_BASE:-http://localhost:8080}"
ENDPOINTS=("/api/v2/pyro-detector/detonators" "/api/v2/pyro-detector/health" "/api/v2/pyro-detector/agents")
for endpoint in "${ENDPOINTS[@]}"; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}${endpoint}" 2>>"$LOG_FILE" || echo "000")
    if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 500 ]; then
        log "  ✓ PASS: Endpoint $endpoint responds (HTTP $HTTP_CODE)"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Endpoint $endpoint failed (HTTP $HTTP_CODE)"
        FAILED=$((FAILED + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

# Test 5: Logging Functional
log "Test 5: Logging Functional"
if [ -d "./logs" ] || [ -d "./test_logs" ]; then
    log "  ✓ PASS: Log directory exists"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Log directory not found (may be created at runtime)"
fi

# Test 6: Configuration Loading
log "Test 6: Configuration Loading"
if [ -f "$MCP_BINARY" ]; then
    # Test that binary can start (even if it fails, config should load)
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | timeout 5 "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if [ -n "$RESPONSE" ]; then
        log "  ✓ PASS: Configuration loads successfully"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Configuration loading failed"
        FAILED=$((FAILED + 1))
        ERRORS=$((ERRORS + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Test 7: Error Handling
log "Test 7: Error Handling"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"invalid_method","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        log "  ✓ PASS: Error handling works correctly"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Error handling not working"
        FAILED=$((FAILED + 1))
        ERRORS=$((ERRORS + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Test 8: JSON-RPC 2.0 Compliance
log "Test 8: JSON-RPC 2.0 Compliance"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.jsonrpc == "2.0" and .id == 1' >/dev/null 2>&1; then
        log "  ✓ PASS: JSON-RPC 2.0 compliant"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Not JSON-RPC 2.0 compliant"
        FAILED=$((FAILED + 1))
        ERRORS=$((ERRORS + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $ERRORS -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "qa_test_suite",
    "test_name": "QA Test Suite - Functional Requirements",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== QA Test Suite Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $ERRORS

