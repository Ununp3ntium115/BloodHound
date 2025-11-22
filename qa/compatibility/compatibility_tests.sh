#!/bin/bash
# Compatibility Tests - Cross-platform validation
# Tests compatibility across different platforms and environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/compatibility"
LOG_FILE="$RESULTS_DIR/compatibility-tests.log"
RESULT_FILE="$RESULTS_DIR/compatibility-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Compatibility Tests - Cross-Platform ==="
log "Starting compatibility tests at $(date)"

# Detect platform
PLATFORM=$(uname -s)
ARCH=$(uname -m)
log "Platform: $PLATFORM, Architecture: $ARCH"

# Compatibility Test 1: Platform Detection
log "Compatibility Test 1: Platform Detection"
if [ -n "$PLATFORM" ] && [ -n "$ARCH" ]; then
    log "  ✓ PASS: Platform detected ($PLATFORM/$ARCH)"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: Platform detection failed"
    FAILED=$((FAILED + 1))
fi

# Compatibility Test 2: Binary for Current Platform
log "Compatibility Test 2: Binary for Current Platform"
MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
if [ "$PLATFORM" = "Linux" ]; then
    MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
elif [ "$PLATFORM" = "Darwin" ]; then
    MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector}"
elif [[ "$PLATFORM" == MINGW* ]] || [[ "$PLATFORM" == MSYS* ]]; then
    MCP_BINARY="${MCP_BINARY:-./target/release/pyro-detector.exe}"
fi

if [ -f "$MCP_BINARY" ]; then
    log "  ✓ PASS: Binary exists for platform"
    PASSED=$((PASSED + 1))
else
    log "  ⊘ SKIP: Binary not found (may need to build for this platform)"
fi

# Compatibility Test 3: JSON Processing
log "Compatibility Test 3: JSON Processing"
if command -v jq >/dev/null 2>&1; then
    TEST_JSON='{"test":"value"}'
    if echo "$TEST_JSON" | jq . >/dev/null 2>&1; then
        log "  ✓ PASS: JSON processing works"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: JSON processing failed"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ⚠ WARN: jq not installed (required for some tests)"
fi

# Compatibility Test 4: Network Connectivity
log "Compatibility Test 4: Network Connectivity"
API_BASE="${API_BASE:-http://localhost:8080}"
if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$API_BASE/health" 2>>"$LOG_FILE" || echo "000")
    if [ "$HTTP_CODE" != "000" ]; then
        log "  ✓ PASS: Network connectivity works"
        PASSED=$((PASSED + 1))
    else
        log "  ⚠ WARN: Network connectivity test failed (API may not be running)"
    fi
else
    log "  ⚠ WARN: curl not installed (required for API tests)"
fi

# Compatibility Test 5: File System
log "Compatibility Test 5: File System"
TEST_DIR="./test_compatibility_$(date +%s)"
mkdir -p "$TEST_DIR"
if [ -d "$TEST_DIR" ]; then
    echo "test" > "$TEST_DIR/test.txt"
    if [ -f "$TEST_DIR/test.txt" ]; then
        rm -rf "$TEST_DIR"
        log "  ✓ PASS: File system operations work"
        PASSED=$((PASSED + 1))
    else
        log "  ✗ FAIL: File system operations failed"
        FAILED=$((FAILED + 1))
    fi
else
    log "  ✗ FAIL: Cannot create test directory"
    FAILED=$((FAILED + 1))
fi

# Compatibility Test 6: Environment Variables
log "Compatibility Test 6: Environment Variables"
export TEST_VAR="test_value"
if [ "$TEST_VAR" = "test_value" ]; then
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
    "test_suite": "compatibility_tests",
    "test_name": "Compatibility Tests - Cross-Platform",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "platform": "$PLATFORM",
    "architecture": "$ARCH",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Compatibility Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

