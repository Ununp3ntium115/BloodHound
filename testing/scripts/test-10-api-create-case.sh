#!/bin/bash
# Test 10: API Create Case
# Tests the POST /api/v2/pyro-detector/cases endpoint

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-10-api-create-case.log"
RESULT_FILE="$RESULTS_DIR/test-10-api-create-case.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test 10: API Create Case ==="
log "Starting test at $(date)"

API_BASE="${API_BASE:-http://localhost:8080}"
API_URL="${API_BASE}/api/v2/pyro-detector/cases"
AUTH_TOKEN="${AUTH_TOKEN:-}"
CASE_NAME="UA Test Case $(date +%Y%m%d-%H%M%S)"

log "API URL: $API_URL"

REQUEST_BODY=$(jq -n --arg name "$CASE_NAME" '{name: $name, description: "UA Testing case"}')

CURL_CMD="curl -s -w '\nHTTP_CODE:%{http_code}' -X POST -H 'Content-Type: application/json'"
if [ -n "$AUTH_TOKEN" ]; then
    CURL_CMD="$CURL_CMD -H 'Authorization: Bearer $AUTH_TOKEN'"
fi
CURL_CMD="$CURL_CMD -d '$REQUEST_BODY' '$API_URL'"

log "Sending HTTP POST request..."
RESPONSE=$(eval $CURL_CMD 2>>"$LOG_FILE" || true)

if [ -z "$RESPONSE" ]; then
    ERROR_MSG="No response from API"
    log "ERROR: $ERROR_MSG"
    RESULT="FAIL"
else
    HTTP_CODE=$(echo "$RESPONSE" | grep -oP 'HTTP_CODE:\K\d+')
    BODY=$(echo "$RESPONSE" | sed 's/HTTP_CODE:.*//')
    
    log "HTTP Status: $HTTP_CODE"
    
    if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 201 ]; then
        if echo "$BODY" | jq . >/dev/null 2>&1; then
            CASE_ID=$(echo "$BODY" | jq -r '.id // empty')
            if [ -n "$CASE_ID" ]; then
                log "SUCCESS: Case created with ID: $CASE_ID"
                RESULT="PASS"
            else
                ERROR_MSG="Response missing case ID"
                log "ERROR: $ERROR_MSG"
                RESULT="FAIL"
            fi
        else
            ERROR_MSG="Invalid JSON in response"
            log "ERROR: $ERROR_MSG"
            RESULT="FAIL"
        fi
    elif [ "$HTTP_CODE" -eq 401 ] || [ "$HTTP_CODE" -eq 403 ]; then
        ERROR_MSG="Authentication/Authorization failed (HTTP $HTTP_CODE)"
        log "ERROR: $ERROR_MSG"
        RESULT="SKIP"
    else
        ERROR_MSG="HTTP $HTTP_CODE: $(echo "$BODY" | jq -r '.message // .error // "Unknown error"' 2>/dev/null || echo "$BODY")"
        log "ERROR: $ERROR_MSG"
        RESULT="FAIL"
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-10-api-create-case",
    "test_name": "API Create Case",
    "category": "api-endpoints",
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

