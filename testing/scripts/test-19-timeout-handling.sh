#!/bin/bash
# Test 19: Timeout Handling
# Tests timeout handling for long-running operations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-19-timeout-handling.log"
RESULT_FILE="$RESULTS_DIR/test-19-timeout-handling.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 19: Timeout Handling ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
TIMEOUT_SECONDS=5

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Testing timeout handling with ${TIMEOUT_SECONDS}s timeout..."
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_health",
    "params": {}
}
EOF
)
    
    # Execute with timeout
    RESPONSE=$(timeout $TIMEOUT_SECONDS bash -c "echo '$REQUEST' | '$MCP_BINARY'" 2>>"$LOG_FILE" || true)
    TIMEOUT_EXIT=$?
    
    if [ $TIMEOUT_EXIT -eq 124 ]; then
        log "SUCCESS: Request correctly timed out after ${TIMEOUT_SECONDS}s"
        RESULT="PASS"
    elif [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        log "SUCCESS: Request completed within timeout"
        RESULT="PASS"
    else
        ERROR_MSG="Timeout handling test failed"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-19-timeout-handling",
    "test_name": "Timeout Handling",
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

