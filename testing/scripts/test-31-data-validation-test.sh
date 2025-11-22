#!/bin/bash
# Test 31: Data Validation Test
# Tests input validation and sanitization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-31-data-validation-test.log"
RESULT_FILE="$RESULTS_DIR/test-31-data-validation-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 31: Data Validation Test ==="
log "Starting test at $(date)"

MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"

if [ ! -f "$MCP_BINARY" ]; then
    ERROR_MSG="MCP server binary not found at $MCP_BINARY"
    log "ERROR: $ERROR_MSG"
    RESULT="SKIP"
else
    log "Test 1: SQL injection attempt..."
    MALICIOUS_INPUT="'; DROP TABLE users; --"
    REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "pyro_create_case",
    "params": {
        "name": "$MALICIOUS_INPUT"
    }
}
EOF
)
    RESPONSE=$(echo "$REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    
    if [ -n "$RESPONSE" ] && echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
        log "SUCCESS: Malicious input correctly rejected"
        
        log "Test 2: XSS attempt..."
        XSS_INPUT="<script>alert('xss')</script>"
        XSS_REQUEST=$(cat <<EOF
{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "pyro_create_case",
    "params": {
        "name": "$XSS_INPUT"
    }
}
EOF
)
        XSS_RESPONSE=$(echo "$XSS_REQUEST" | "$MCP_BINARY" 2>>"$LOG_FILE" || true)
        
        if [ -n "$XSS_RESPONSE" ]; then
            # Check if input was sanitized or rejected
            if echo "$XSS_RESPONSE" | jq -e '.error' >/dev/null 2>&1 || ! echo "$XSS_RESPONSE" | grep -q "$XSS_INPUT" 2>/dev/null; then
                log "SUCCESS: XSS input correctly handled"
                RESULT="PASS"
            else
                ERROR_MSG="XSS input not properly sanitized"
                log "ERROR: $ERROR_MSG"
                RESULT="FAIL"
            fi
        else
            ERROR_MSG="No response for XSS test"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    else
        ERROR_MSG="Malicious input not properly validated"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-31-data-validation-test",
    "test_name": "Data Validation Test",
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

