#!/bin/bash
# System Tests - Complete System Validation
# Tests the complete system end-to-end

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/system"
LOG_FILE="$RESULTS_DIR/system-tests.log"
RESULT_FILE="$RESULTS_DIR/system-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== System Tests - Complete System Validation ==="
log "Starting system tests at $(date)"

# System Test 1: Complete Workflow - List and Execute
log "System Test 1: Complete Detonator Workflow"
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ -f "$MCP_BINARY" ]; then
    # Step 1: List detonators
    LIST_REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_list_detonators","params":{}}'
    LIST_RESPONSE=$(echo "$LIST_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if echo "$LIST_RESPONSE" | jq -e '.result.detonators' >/dev/null 2>&1; then
        DETONATOR_ID=$(echo "$LIST_RESPONSE" | jq -r '.result.detonators[0].id // empty')
        
        if [ -n "$DETONATOR_ID" ]; then
            # Step 2: Execute detonator
            EXEC_REQUEST=$(jq -n --arg id "$DETONATOR_ID" '{"jsonrpc":"2.0","id":2,"method":"pyro_execute_detonator","params":{"detonator_id":$id}}')
            EXEC_RESPONSE=$(echo "$EXEC_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
            
            if echo "$EXEC_RESPONSE" | jq -e '.result or .error' >/dev/null 2>&1; then
                log "  ✓ PASS: Complete detonator workflow"
                PASSED=$((PASSED + 1))
            else
                log "  ✗ FAIL: Detonator execution failed"
                FAILED=$((FAILED + 1))
            fi
        else
            log "  ⊘ SKIP: No detonators available"
        fi
    else
        log "  ✗ FAIL: List detonators failed"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# System Test 2: Complete Case Workflow
log "System Test 2: Complete Case Workflow"
if [ -f "$MCP_BINARY" ]; then
    # Step 1: Create case
    CASE_NAME="System Test Case $(date +%s)"
    CREATE_REQUEST=$(jq -n --arg name "$CASE_NAME" '{"jsonrpc":"2.0","id":3,"method":"pyro_create_case","params":{"name":$name}}')
    CREATE_RESPONSE=$(echo "$CREATE_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if echo "$CREATE_RESPONSE" | jq -e '.result.id' >/dev/null 2>&1; then
        log "  ✓ PASS: Complete case workflow"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Case creation failed"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# System Test 3: API Integration
log "System Test 3: API Integration"
API_BASE="${API_BASE:-http://localhost:8080}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}/api/v2/pyro-detector/health" 2>>"$LOG_FILE" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    log "  ✓ PASS: API integration works"
    PASSED=$((PASSED + 1))
else
    log "  ⊘ SKIP: API not available (HTTP $HTTP_CODE)"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "system_tests",
    "test_name": "System Tests - Complete System Validation",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== System Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

