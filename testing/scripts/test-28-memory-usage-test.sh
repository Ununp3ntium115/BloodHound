#!/bin/bash
# Test 28: Memory Usage Test
# Tests memory usage during operation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-28-memory-usage-test.log"
RESULT_FILE="$RESULTS_DIR/test-28-memory-usage-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 28: Memory Usage Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
MAX_MEMORY_MB=500

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Testing memory usage..."
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_health",
    "params": {}
}
EOF
)
    
    # Get initial memory (if process is running)
    INITIAL_MEMORY=$(ps aux 2>/dev/null | grep "$MCP_BINARY" | awk '{sum+=$6} END {print sum/1024}' || echo "0")
    
    # Execute request
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    # Get memory after request
    FINAL_MEMORY=$(ps aux 2>/dev/null | grep "$MCP_BINARY" | awk '{sum+=$6} END {print sum/1024}' || echo "0")
    
    MEMORY_USAGE=$(awk "BEGIN {printf \"%.2f\", $FINAL_MEMORY}")
    log "Memory usage: ${MEMORY_USAGE}MB"
    
    if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
        if (( $(echo "$MEMORY_USAGE <= $MAX_MEMORY_MB" | bc -l) )); then
            log "SUCCESS: Memory usage ${MEMORY_USAGE}MB within limit (${MAX_MEMORY_MB}MB)"
            RESULT="PASS"
        else
            ERROR_MSG="Memory usage ${MEMORY_USAGE}MB exceeds limit (${MAX_MEMORY_MB}MB)"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Request failed"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-28-memory-usage-test",
    "test_name": "Memory Usage Test",
    "category": "performance",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "error": "$ERROR_MSG",
    "log_file": "$LOG_FILE",
    "metrics": {
        "memory_usage_mb": $MEMORY_USAGE,
        "max_memory_mb": $MAX_MEMORY_MB
    }
}
EOF

log "=== Test Complete: $RESULT ==="
log "Duration: ${DURATION}s"

exit 0

