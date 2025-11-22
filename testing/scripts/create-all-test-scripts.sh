#!/bin/bash
# Generate all 33 test scripts from templates

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/templates"

# Test definitions: num:name:category:description
declare -a TESTS=(
    "01:list-detonators:mcp-methods:List all available Fire Marshal detonators"
    "02:execute-detonator:mcp-methods:Execute a Fire Marshal detonator"
    "03:create-case:mcp-methods:Create a new investigation case"
    "04:list-agents:mcp-methods:List all Fire Marshal agents"
    "05:execute-pql:mcp-methods:Execute a Pyro Query Language query"
    "06:health-check:mcp-methods:Check MCP server health status"
    "07:authenticate:mcp-methods:Authenticate with PYRO Platform"
    "08:api-list-detonators:api-endpoints:API endpoint - List detonators"
    "09:api-execute-detonator:api-endpoints:API endpoint - Execute detonator"
    "10:api-create-case:api-endpoints:API endpoint - Create case"
    "11:api-list-agents:api-endpoints:API endpoint - List agents"
    "12:api-execute-pql:api-endpoints:API endpoint - Execute PQL"
    "13:api-health:api-endpoints:API endpoint - Health check"
    "14:end-to-end-detector-flow:integration:End-to-end detonator execution flow"
    "15:end-to-end-case-creation:integration:End-to-end case creation flow"
    "16:end-to-end-pql-query:integration:End-to-end PQL query flow"
    "17:error-handling:integration:Error handling and recovery"
    "18:concurrent-requests:integration:Concurrent request handling"
    "19:timeout-handling:integration:Timeout handling"
    "20:ui-navigation:ui-workflows:UI navigation and routing"
    "21:ui-detector-list:ui-workflows:UI detonator list display"
    "22:ui-detector-execution:ui-workflows:UI detonator execution"
    "23:ui-graph-visualization:ui-workflows:UI graph visualization"
    "24:ui-error-display:ui-workflows:UI error display"
    "25:load-test:performance:Load testing with multiple requests"
    "26:stress-test:performance:Stress testing under high load"
    "27:response-time-test:performance:Response time measurement"
    "28:memory-usage-test:performance:Memory usage measurement"
    "29:authentication-test:security:Authentication validation"
    "30:authorization-test:security:Authorization validation"
    "31:data-validation-test:security:Data validation and sanitization"
    "32:cdif-terminology:cdif-compliance:CDIF terminology compliance"
    "33:cdif-evidence-chain:cdif-compliance:CDIF evidence chain validation"
)

echo "Generating 33 test scripts..."

for test_def in "${TESTS[@]}"; do
    IFS=':' read -r num name category desc <<< "$test_def"
    script_file="$SCRIPT_DIR/test-${num}-${name}.sh"
    
    if [ ! -f "$script_file" ]; then
        cat > "$script_file" << 'SCRIPT_TEMPLATE'
#!/bin/bash
# Test NUM: NAME
# CATEGORY: CATEGORY
# DESCRIPTION: DESC

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
LOG_FILE="$RESULTS_DIR/logs/test-NUM-NAME.log"
RESULT_FILE="$RESULTS_DIR/test-NUM-NAME.json"

mkdir -p "$RESULTS_DIR/logs"

RESULT="FAIL"
START_TIME=$(date +%s)
ERROR_MSG=""

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Test NUM: NAME ==="
log "Category: CATEGORY"
log "Description: DESC"
log "Starting test at $(date)"

# TODO: Implement test logic

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

cat > "$RESULT_FILE" <<EOF
{
    "test_id": "test-NUM-NAME",
    "test_name": "NAME",
    "category": "CATEGORY",
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
SCRIPT_TEMPLATE
        
        # Replace placeholders
        sed -i "s/NUM/${num}/g" "$script_file"
        sed -i "s/NAME/${name}/g" "$script_file"
        sed -i "s/CATEGORY/${category}/g" "$script_file"
        sed -i "s|DESC|${desc}|g" "$script_file"
        
        chmod +x "$script_file"
        echo "Created: $script_file"
    else
        echo "Skipped (exists): $script_file"
    fi
done

echo ""
echo "All test scripts generated!"
echo "Total: ${#TESTS[@]} scripts"

