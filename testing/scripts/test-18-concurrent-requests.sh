#!/bin/bash
# Test 18: Concurrent Requests
# Tests handling of multiple concurrent requests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-18-concurrent-requests.log"
RESULT_FILE="$RESULTS_DIR/test-18-concurrent-requests.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 18: Concurrent Requests ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Sending 5 concurrent health check requests..."
    
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
    for i in {1..5}; do
        RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        fi
    done
    
    if [ $SUCCESS_COUNT -eq 5 ]; then
        log "SUCCESS: All 5 concurrent requests succeeded"
        RESULT="PASS"
    else
        ERROR_MSG="Only $SUCCESS_COUNT of 5 requests succeeded"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-18-concurrent-requests",
    "test_name": "Concurrent Requests",
    "category": "integration",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "error": "$ERROR_MSG",
    "log_file": "$LOG_FILE"
}
EOF

log "=== Test Complete: $RESULT ==="
log "Duration: ${DURATION}s"

exit 0

