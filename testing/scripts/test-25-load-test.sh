#!/bin/bash
# Test 25: Load Test
# Tests system under moderate load (50 requests)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-25-load-test.log"
RESULT_FILE="$RESULTS_DIR/test-25-load-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 25: Load Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
LOAD_COUNT=50

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Sending $LOAD_COUNT requests..."
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_health",
    "params": {}
}
EOF
)
    
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    
    for i in $(seq 1 $LOAD_COUNT); do
        RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done
    
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESS_COUNT / $LOAD_COUNT) * 100}")
    log "Results: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed (${SUCCESS_RATE}% success rate)"
    
    if [ $SUCCESS_COUNT -ge $((LOAD_COUNT * 90 / 100)) ]; then
        log "SUCCESS: Load test passed (>=90% success rate)"
        RESULT="PASS"
    else
        ERROR_MSG="Load test failed: only ${SUCCESS_RATE}% success rate"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-25-load-test",
    "test_name": "Load Test",
    "category": "performance",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "error": "$ERROR_MSG",
    "log_file": "$LOG_FILE",
    "metrics": {
        "load_count": $LOAD_COUNT,
        "success_count": $SUCCESS_COUNT,
        "fail_count": $FAIL_COUNT,
        "success_rate": $SUCCESS_RATE
    }
}
EOF

log "=== Test Complete: $RESULT ==="
log "Duration: ${DURATION}s"

exit 0

