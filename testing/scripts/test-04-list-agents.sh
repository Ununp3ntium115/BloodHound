#!/bin/bash
# Test 04: List Agents (MCP Method)
# Tests the pyro_list_agents MCP method

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-04-list-agents.log"
RESULT_FILE="$RESULTS_DIR/test-04-list-agents.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 04: List Agents (MCP Method) ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Using MCP binary: $MCP_BINARY"
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_list_agents",
    "params": {}
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
        elif echo "$RESPONSE" | jq -e '.result.agents' >/dev/null 2>&1; then
            AGENT_COUNT=$(echo "$RESPONSE" | jq '.result.agents | length')
            log "SUCCESS: Received $AGENT_COUNT agents"
            RESULT="PASS"
        else
            ERROR_MSG="Response missing agents field"
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
    "test_id": "test-04-list-agents",
    "test_name": "List Agents (MCP Method)",
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

