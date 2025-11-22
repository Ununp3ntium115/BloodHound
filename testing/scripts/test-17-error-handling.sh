#!/bin/bash
# Test 17: Error Handling
# Tests error handling and recovery for invalid requests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-17-error-handling.log"
RESULT_FILE="$RESULTS_DIR/test-17-error-handling.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 17: Error Handling ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Test 1: Invalid method..."
    INVALID_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "invalid_method",
    "params": {}
}
EOF
)
    INVALID_RESPONSE=$(echo "$INVALID_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -n "$INVALID_RESPONSE" ] && echo "$INVALID_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        log "SUCCESS: Invalid method correctly returned error"
        
        log "Test 2: Missing required parameter..."
        MISSING_PARAM_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "pyro_execute_detonator",
    "params": {}
}
EOF
)
        MISSING_PARAM_RESPONSE=$(echo "$MISSING_PARAM_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        
        if [ -n "$MISSING_PARAM_RESPONSE" ] && echo "$MISSING_PARAM_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
            log "SUCCESS: Missing parameter correctly returned error"
            RESULT="PASS"
        else
            ERROR_MSG="Missing parameter did not return error"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Invalid method did not return error"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-17-error-handling",
    "test_name": "Error Handling",
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

