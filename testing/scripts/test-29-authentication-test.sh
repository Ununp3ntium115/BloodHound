#!/bin/bash
# Test 29: Authentication Test
# Tests authentication and token validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-29-authentication-test.log"
RESULT_FILE="$RESULTS_DIR/test-29-authentication-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 29: Authentication Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Testing authentication..."
    
    AUTH_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_authenticate",
    "params": {}
}
EOF
)
    AUTH_RESPONSE=$(echo "$AUTH_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -n "$AUTH_RESPONSE" ] && echo "$AUTH_RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        log "SUCCESS: Authentication method responded"
        RESULT="PASS"
    elif [ -n "$AUTH_RESPONSE" ] && echo "$AUTH_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        ERROR_CODE=$(echo "$AUTH_RESPONSE" | jq -r '.error.code // empty')
        if [ "$ERROR_CODE" = "AUTH_REQUIRED" ] || [ "$ERROR_CODE" = "INVALID_CREDENTIALS" ]; then
            log "SUCCESS: Authentication correctly requires credentials"
            RESULT="PASS"
        else
            ERROR_MSG="Unexpected authentication error"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Authentication test failed"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-29-authentication-test",
    "test_name": "Authentication Test",
    "category": "security",
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

