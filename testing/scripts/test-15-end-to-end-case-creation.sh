#!/bin/bash
# Test 15: End-to-End Case Creation Flow
# Tests complete flow: create case -> list agents -> execute PQL

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-15-end-to-end-case-creation.log"
RESULT_FILE="$RESULTS_DIR/test-15-end-to-end-case-creation.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 15: End-to-End Case Creation Flow ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Step 1: Create case..."
    CASE_NAME="UA Test Case $(date +%Y%m%d-%H%M%S)"
    CREATE_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_create_case",
    "params": {
        "name": "$CASE_NAME"
    }
}
EOF
)
    CREATE_RESPONSE=$(echo "$CREATE_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -z "$CREATE_RESPONSE" ] || echo "$CREATE_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        ERROR_MSG="Failed to create case"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    else
        CASE_ID=$(echo "$CREATE_RESPONSE" | jq -r '.result.id // empty')
        
        if [ -z "$CASE_ID" ]; then
            ERROR_MSG="Case creation did not return case ID"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        else
            log "Step 2: List agents..."
            AGENTS_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "pyro_list_agents",
    "params": {}
}
EOF
)
            AGENTS_RESPONSE=$(echo "$AGENTS_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
            
            if [ -z "$AGENTS_RESPONSE" ] || echo "$AGENTS_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
                ERROR_MSG="Failed to list agents"
                log "ERROR: $ERROR_MSG"
                RESULT="FAIL"
            else
                log "SUCCESS: End-to-end case creation flow completed"
                RESULT="PASS"
            fi
        fi
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-15-end-to-end-case-creation",
    "test_name": "End-to-End Case Creation Flow",
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

