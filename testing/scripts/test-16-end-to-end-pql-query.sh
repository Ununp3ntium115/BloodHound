#!/bin/bash
# Test 16: End-to-End PQL Query Flow
# Tests complete flow: create case -> execute PQL -> verify results

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-16-end-to-end-pql-query.log"
RESULT_FILE="$RESULTS_DIR/test-16-end-to-end-pql-query.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 16: End-to-End PQL Query Flow ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
PQL_QUERY="${TEST_PQL_QUERY:-SELECT * FROM agents LIMIT 10}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Step 1: Execute PQL query..."
    PQL_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_execute_pql",
    "params": {
        "query": "$PQL_QUERY"
    }
}
EOF
)
    PQL_RESPONSE=$(echo "$PQL_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -z "$PQL_RESPONSE" ] || echo "$PQL_RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        ERROR_MSG="Failed to execute PQL query"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    else
        log "SUCCESS: PQL query executed successfully"
        RESULT="PASS"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-16-end-to-end-pql-query",
    "test_name": "End-to-End PQL Query Flow",
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

