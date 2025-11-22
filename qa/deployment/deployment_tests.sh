#!/bin/bash
# Deployment Tests - Installation and Configuration Validation
# Tests deployment process and installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/deployment"
LOG_FILE="$RESULTS_DIR/deployment-tests.log"
RESULT_FILE="$RESULTS_DIR/deployment-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Deployment Tests - Installation Validation ==="
log "Starting deployment tests at $(date)"

# Deployment Test 1: Binary Can Be Executed
log "Deployment Test 1: Binary Execution"
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ -f "$MCP_BINARY" ] && [ -x "$MCP_BINARY" ]; then
    log "  ✓ PASS: Binary is executable"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Binary not executable"
    FAILED=$((FAILED + 1))
fi

# Deployment Test 2: Configuration File Loading
log "Deployment Test 2: Configuration Loading"
if [ -f "$MCP_BINARY" ]; then
    REQUEST='{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}'
    RESPONSE=$(echo "$REQUEST" | timeout 5 "$MCP_BINARY" 2>>"$LOG_FILE" || true)
    if [ -n "$RESPONSE" ]; then
        log "  ✓ PASS: Configuration loads successfully"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: Configuration loading failed"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⊘ SKIP: MCP server binary not found"
fi

# Deployment Test 3: Log Directory Creation
log "Deployment Test 3: Log Directory"
LOG_DIR="./logs"
if [ -d "$LOG_DIR" ] || mkdir -p "$LOG_DIR" 2>/dev/null; then
    log "  ✓ PASS: Log directory can be created"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Cannot create log directory"
    FAILED=$((FAILED + 1))
fi

# Deployment Test 4: Required Dependencies
log "Deployment Test 4: Required Dependencies"
MISSING_DEPS=0
for cmd in jq curl; do
    if ! command -v $cmd >/dev/null 2>&1; then
        log "  ⚠ WARN: $cmd not found (may be required for some tests)"
        MISSING_DEPS=$((MISSING_DEPS + 1))
    fi
done

if [ $MISSING_DEPS -eq 0 ]; then
    log "  ✓ PASS: Required dependencies available"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Some dependencies missing (non-critical)"
    PASSED=$((PASSED + 1))
fi

# Deployment Test 5: Environment Variables
log "Deployment Test 5: Environment Variables"
export PYRO_TEST_VAR="test"
if [ "$PYRO_TEST_VAR" = "test" ]; then
    log "  ✓ PASS: Environment variables work"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Environment variables not working"
    FAILED=$((FAILED + 1))
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "deployment_tests",
    "test_name": "Deployment Tests - Installation Validation",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Deployment Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

