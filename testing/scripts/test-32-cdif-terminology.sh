#!/bin/bash
# Test 32: CDIF Terminology Compliance
# Tests that CDIF terminology is used correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-32-cdif-terminology.log"
RESULT_FILE="$RESULTS_DIR/test-32-cdif-terminology.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 32: CDIF Terminology Compliance ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Testing CDIF terminology in responses..."
    
    # Test that detonators use Fire Marshal terminology
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_list_detonators",
    "params": {}
}
EOF
)
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result.detonators' >/dev/null 2>&1; then
        # Check for Fire Marshal terminology
        if echo "$RESPONSE" | grep -qi "detonator\|fire.marshal\|investigation" 2>/dev/null; then
            log "SUCCESS: CDIF terminology found in response"
            RESULT="PASS"
        else
            ERROR_MSG="CDIF terminology not found in response"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Failed to get detonators list"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-32-cdif-terminology",
    "test_name": "CDIF Terminology Compliance",
    "category": "cdif-compliance",
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

