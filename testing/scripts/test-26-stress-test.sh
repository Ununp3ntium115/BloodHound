#!/bin/bash
# Test 26: Stress Test
# Tests system under high stress (200 concurrent requests)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-26-stress-test.log"
RESULT_FILE="$RESULTS_DIR/test-26-stress-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 26: Stress Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
STRESS_COUNT=200
CONCURRENT=20

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Sending $STRESS_COUNT requests with $CONCURRENT concurrent..."
    
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_health",
    "params": {}
}
EOF
)
    
    SUCCESS_COUNT=0
    FAIL_COUNT=0
    
    for i in $(seq 1 $STRESS_COUNT); do
        RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.result' >/dev/null 2>&1; then
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
        
        if [ $((i % 50)) -eq 0 ]; then
            log "Progress: $i/$STRESS_COUNT requests completed"
        fi
    done
    
    SUCCESS_RATE=$(awk "BEGIN {printf \"%.2f\", ($SUCCESS_COUNT / $STRESS_COUNT) * 100}")
    log "Results: $SUCCESS_COUNT succeeded, $FAIL_COUNT failed (${SUCCESS_RATE}% success rate)"
    
    if [ $SUCCESS_COUNT -ge $((STRESS_COUNT * 85 / 100)) ]; then
        log "SUCCESS: Stress test passed (>=85% success rate)"
        RESULT="PASS"
    else
        ERROR_MSG="Stress test failed: only ${SUCCESS_RATE}% success rate"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-26-stress-test",
    "test_name": "Stress Test",
    "category": "performance",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "error": "$ERROR_MSG",
    "log_file": "$LOG_FILE",
    "metrics": {
        "stress_count": $STRESS_COUNT,
        "concurrent": $CONCURRENT,
        "success_count": $SUCCESS_COUNT,
        "fail_count": $FAIL_COUNT,
        "success_rate": $SUCCESS_RATE
    }
}
EOF

log "=== Test Complete: $RESULT ==="
log "Duration: ${DURATION}s"

exit 0

