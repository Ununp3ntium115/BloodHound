#!/bin/bash
# Test 01: List Detonators (MCP Method)
# Tests the pyro_list_detonators MCP method

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-01-list-detonators.log"
RESULT_FILE="$RESULTS_DIR/test-01-list-detonators.json"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR/logs"

# Initialize result
RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

# Log function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 01: List Detonators (MCP Method) ==="
log "Starting test at $(date)"

# Check if MCP server binary exists
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Using MCP binary: $MCP_BINARY"
    
    # Create JSON-RPC 2.0 request
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_list_detonators",
    "params": {}
}
EOF
)
    
    log "Sending request to MCP server..."
    log "Request: $REQUEST"
    
    # Send request and capture response
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -z "$RESPONSE" ]; then
        ERROR_MSG="No response from MCP server"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    else
        log "Response received: $RESPONSE"
        
        # Check if response is valid JSON
        if echo "$RESPONSE" | jq . >/dev/null 2>&1; then
            # Check for errors
            if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
                ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // .error')
                log "ERROR: MCP server returned error: $ERROR_MSG"
                RESULT="FAIL"
            else
                # Check if result contains detonators
                if echo "$RESPONSE" | jq -e '.result.detonators' >/dev/null 2>&1; then
                    DETONATOR_COUNT=$(echo "$RESPONSE" | jq '.result.detonators | length')
                    log "SUCCESS: Received $DETONATOR_COUNT detonators"
                    RESULT="PASS"
                else
                    ERROR_MSG="Response missing detonators field"
                    log "ERROR: $ERROR_MSG"
                    RESULT="FAIL"
                fi
            fi
        else
            ERROR_MSG="Invalid JSON response"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Write result JSON
cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-01-list-detonators",
    "test_name": "List Detonators (MCP Method)",
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
log "Result written to: $RESULT_FILE"

exit 0

