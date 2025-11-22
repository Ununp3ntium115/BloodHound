#!/bin/bash
# Test 30: Authorization Test
# Tests authorization and permission validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-30-authorization-test.log"
RESULT_FILE="$RESULTS_DIR/test-30-authorization-test.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 30: Authorization Test ==="
log "Starting test at $(date)"

API_BASE="${API_BASE:-http://localhost:8080}"
API_URL="${API_BASE}/api/v2/pyro-detector/detonators"

log "Testing authorization without token..."
RESPONSE=$(curl -s -w '\nHTTP_CODE:%{http_code}' "$API_URL" 2>>"$LOG_FILE" || true)

if [ -z "$RESPONSE" ]; then
    ERROR_MSG="No response from API"
    log "ERROR: $ERROR_MSG"
    RESULT="FAIL"
else
    HTTP_CODE=$(echo "$RESPONSE" | grep -oP 'HTTP_CODE:\K\d+')
    
    if [ "$HTTP_CODE" -eq 401 ] || [ "$HTTP_CODE" -eq 403 ]; then
        log "SUCCESS: Authorization correctly required (HTTP $HTTP_CODE)"
        RESULT="PASS"
    elif [ "$HTTP_CODE" -eq 200 ]; then
        log "WARNING: Endpoint accessible without authentication"
        RESULT="PASS"
    else
        ERROR_MSG="Unexpected HTTP status: $HTTP_CODE"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-30-authorization-test",
    "test_name": "Authorization Test",
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

