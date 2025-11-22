#!/bin/bash
# Test 14: End-to-End Detonator Flow
# Tests complete flow: list detonators -> execute detonator -> get results

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-14-end-to-end-detector-flow.log"
RESULT_FILE="$RESULTS_DIR/test-14-end-to-end-detector-flow.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 14: End-to-End Detonator Flow ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Step 1: List detonators..."
    LIST_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_list_detonators",
    "params": {}
}
EOF
)
    LIST_RESPONSE=$(echo "$LIST_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -z "$LIST_RESPONSE" ] || echo "$LIST_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        ERROR_MSG="Failed to list detonators"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    else
        DETONATOR_ID=$(echo "$LIST_RESPONSE" | jq -r '.result.detonators[0].id // empty')
        
        if [ -z "$DETONATOR_ID" ]; then
            ERROR_MSG="No detonators available"
            log "ERROR: $ERROR_MSG"
            RESULT="SKIP"
        else
            log "Step 2: Execute detonator $DETONATOR_ID..."
            EXEC_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "pyro_execute_detonator",
    "params": {
        "detonator_id": "$DETONATOR_ID"
    }
}
EOF
)
            EXEC_RESPONSE=$(echo "$EXEC_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
            
            if [ -z "$EXEC_RESPONSE" ] || echo "$EXEC_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
                ERROR_MSG="Failed to execute detonator"
                log "ERROR: $ERROR_MSG"
                RESULT="FAIL"
            else
                log "SUCCESS: End-to-end flow completed"
                RESULT="PASS"
            fi
        fi
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-14-end-to-end-detector-flow",
    "test_name": "End-to-End Detonator Flow",
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

