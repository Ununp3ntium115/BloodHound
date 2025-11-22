#!/bin/bash
# Test 27: Response Time Test
# Tests response time for health check endpoint

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-27-response-time-test.log"
RESULT_FILE="$RESULTS_DIR/test-27-response-time-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 27: Response Time Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
MAX_RESPONSE_TIME_MS=1000

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Measuring response time..."
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_health",
    "params": {}
}
EOF
)
    
    REQ_START=$(date +%s%N)
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    REQ_END=$(date +%s%N)
    
    RESPONSE_TIME_MS=$(( (REQ_END - REQ_START) / 1000000 ))
    
    log "Response time: ${RESPONSE_TIME_MS}ms"
    
    if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        if [ $RESPONSE_TIME_MS -le $MAX_RESPONSE_TIME_MS ]; then
            log "SUCCESS: Response time ${RESPONSE_TIME_MS}ms within limit (${MAX_RESPONSE_TIME_MS}ms)"
            RESULT="PASS"
        else
            ERROR_MSG="Response time ${RESPONSE_TIME_MS}ms exceeds limit (${MAX_RESPONSE_TIME_MS}ms)"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Request failed"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-27-response-time-test",
    "test_name": "Response Time Test",
    "category": "performance",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "error": "$ERROR_MSG",
    "log_file": "$LOG_FILE",
    "metrics": {
        "response_time_ms": $RESPONSE_TIME_MS,
        "max_response_time_ms": $MAX_RESPONSE_TIME_MS
    }
}
EOF

log "=== Test Complete: $RESULT ==="
log "Duration: ${DURATION}s"

exit 0

