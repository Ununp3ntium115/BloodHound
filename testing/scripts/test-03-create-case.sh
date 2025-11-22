#!/bin/bash
# Test 03: Create Case (MCP Method)
# Tests the pyro_create_case MCP method

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-03-create-case.log"
RESULT_FILE="$RESULTS_DIR/test-03-create-case.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 03: Create Case (MCP Method) ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
CASE_NAME="UA Test Case $(date +%Y%m%d-%H%M%S)"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Using MCP binary: $MCP_BINARY"
    log "Creating case: $CASE_NAME"
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_create_case",
    "params": {
        "name": "$CASE_NAME",
        "description": "UA Testing case"
    }
}
EOF
)
    
    log "Sending request to MCP server..."
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -z "$RESPONSE" ]; then
        ERROR_MSG="No response from MCP server"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    elif echo "$RESPONSE" | jq . >/dev/null 2>&1; then
        if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
            ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // .error')
            log "ERROR: MCP server returned error: $ERROR_MSG"
            RESULT="FAIL"
        elif echo "$RESPONSE" | jq -e '.result.id' >/dev/null 2>&1; then
            CASE_ID=$(echo "$RESPONSE" | jq -r '.result.id')
            log "SUCCESS: Case created with ID: $CASE_ID"
            RESULT="PASS"
        else
            ERROR_MSG="Response missing case ID"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Invalid JSON response"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-03-create-case",
    "test_name": "Create Case (MCP Method)",
    "category": "mcp-methods",
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

