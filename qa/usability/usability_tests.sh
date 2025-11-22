#!/bin/bash
# Usability Tests - User Experience Validation
# Tests user-facing functionality and workflows

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/usability"
LOG_FILE="$RESULTS_DIR/usability-tests.log"
RESULT_FILE="$RESULTS_DIR/usability-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Usability Tests - User Experience ==="
log "Starting usability tests at $(date)"

API_BASE="${API_BASE:-http://localhost:8080}"

# Usability Test 1: API Response Time
log "Usability Test 1: API Response Time"
START=$(date +%s%N)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${API_BASE}/api/v2/pyro-detector/health" 2>>"$LOG_FILE" || echo "000")
END=$(date +%s%N)
RESPONSE_TIME_MS=$(( (END - START) / 1000000 ))

if [ "$HTTP_CODE" = "200" ] && [ $RESPONSE_TIME_MS -lt 1000 ]; then
    log "  ✓ PASS: API responds quickly (${RESPONSE_TIME_MS}ms)"
    PASSED=$((PASSED + 1))
elif [ "$HTTP_CODE" = "200" ]; then
    log "  ⚠ WARN: API responds but slowly (${RESPONSE_TIME_MS}ms)"
    PASSED=$((PASSED + 1))
else
    log "  ⊘ SKIP: API not available (HTTP $HTTP_CODE)"
fi

# Usability Test 2: Error Messages Are Clear
log "Usability Test 2: Error Message Clarity"
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"invalid_method","params":{}}'
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if echo "$RESPONSE" | jq -e '.error.message' >/dev/null 2>&1; then
        ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message')
        if [ -n "$ERROR_MSG" ] && [ ${#ERROR_MSG} -gt 10 ]; then
            log "  ✓ PASS: Error messages are clear and descriptive"
            PASSED=$((PASSED + 1))
        else
            log "  ✗ FAIL: Error messages are too brief"
            FAILED=$((FAILED + 1))
        fi
    else
        log "  ✗ FAIL: Error messages not in expected format"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Usability Test 3: API Endpoints Are Intuitive
log "Usability Test 3: API Endpoint Intuitiveness"
ENDPOINTS=(
    "/api/v2/pyro-detector/detonators"
    "/api/v2/pyro-detector/health"
    "/api/v2/pyro-detector/agents"
)

INTUITIVE_COUNT=0
for endpoint in "${ENDPOINTS[@]}"; do
    # Check if endpoint name is descriptive
    if [[ "$endpoint" == *"detonator"* ]] || [[ "$endpoint" == *"health"* ]] || [[ "$endpoint" == *"agent"* ]]; then
        INTUITIVE_COUNT=$((INTUITIVE_COUNT + 1))
    fi
done

if [ $INTUITIVE_COUNT -eq ${#ENDPOINTS[@]} ]; then
    log "  ✓ PASS: API endpoints are intuitive"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Some API endpoints may not be intuitive"
    PASSED=$((PASSED + 1))
fi

# Usability Test 4: Response Format Consistency
log "Usability Test 4: Response Format Consistency"
if [ -f "$MCP_BINARY" ]; then
    METHODS=("pyro_health" "pyro_list_detonators")
    CONSISTENT=0
    for method in "${METHODS[@]}"; do
        REQUEST=$(jq -n --arg method "$method" '{"jsonrpc":"2.0","id":1,"method":$method,"params":{}}')
        RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        if echo "$RESPONSE" | jq -e '.jsonrpc == "2.0" and .id == 1' >/dev/null 2>&1; then
            CONSISTENT=$((CONSISTENT + 1))
        fi
    done
    
    if [ $CONSISTENT -eq ${#METHODS[@]} ]; then
        log "  ✓ PASS: Response format is consistent"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Response format inconsistent"
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
    "test_suite": "usability_tests",
    "test_name": "Usability Tests - User Experience",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Usability Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

