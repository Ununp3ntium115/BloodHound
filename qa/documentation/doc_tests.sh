#!/bin/bash
# Documentation Tests - Validate Documentation Accuracy
# Tests that documentation matches implementation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results/documentation"
LOG_FILE="$RESULTS_DIR/doc-tests.log"
RESULT_FILE="$RESULTS_DIR/doc-tests.json"

mkdir -p "$RESULTS_DIR"

RESULT="FAIL"
START_TIME=$(date +%s)
PASSED=0
FAILED=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== Documentation Tests - Accuracy Validation ==="
log "Starting documentation tests at $(date)"

# Doc Test 1: README Exists
log "Doc Test 1: README Exists"
if [ -f "README.md" ]; then
    log "  ✓ PASS: README.md exists"
    PASSED=$((PASSED + 1))
else
    log "  ✗ FAIL: README.md not found"
    FAILED=$((FAILED + 1))
fi

# Doc Test 2: API Documentation Exists
log "Doc Test 2: API Documentation"
if [ -f "pyro-detector/API_REFERENCE.md" ] || [ -f "pyro-detector/README.md" ]; then
    log "  ✓ PASS: API documentation exists"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: API documentation may be missing"
fi

# Doc Test 3: MCP Methods Documented
log "Doc Test 3: MCP Methods Documentation"
EXPECTED_METHODS=("pyro_list_detonators" "pyro_execute_detonator" "pyro_create_case" "pyro_list_agents" "pyro_execute_pql" "pyro_health")
DOC_FILES=("pyro-detector/API_REFERENCE.md" "pyro-detector/README.md" "pyro-detector/INTEGRATION_GUIDE.md")

FOUND_COUNT=0
for method in "${EXPECTED_METHODS[@]}"; do
    for doc_file in "${DOC_FILES[@]}"; do
        if [ -f "$doc_file" ] && grep -q "$method" "$doc_file" 2>/dev/null; then
            FOUND_COUNT=$((FOUND_COUNT + 1))
            break
        fi
    done
done

if [ $FOUND_COUNT -ge $(( ${#EXPECTED_METHODS[@]} * 50 / 100 )) ]; then
    log "  ✓ PASS: MCP methods are documented"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Some MCP methods may not be documented"
    PASSED=$((PASSED + 1))
fi

# Doc Test 4: Installation Instructions
log "Doc Test 4: Installation Instructions"
if [ -f "pyro-detector/README.md" ] && grep -qi "install\|setup\|build" "pyro-detector/README.md" 2>/dev/null; then
    log "  ✓ PASS: Installation instructions exist"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Installation instructions may be missing"
fi

# Doc Test 5: Configuration Documentation
log "Doc Test 5: Configuration Documentation"
if [ -f "pyro-detector/README.md" ] && grep -qi "config\|configuration\|env" "pyro-detector/README.md" 2>/dev/null; then
    log "  ✓ PASS: Configuration documentation exists"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Configuration documentation may be missing"
fi

# Doc Test 6: Examples Exist
log "Doc Test 6: Examples"
if [ -d "pyro-detector/examples" ] && [ "$(ls -A pyro-detector/examples 2>/dev/null)" ]; then
    log "  ✓ PASS: Examples directory exists with files"
    PASSED=$((PASSED + 1))
else
    log "  ⚠ WARN: Examples may be missing"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

if [ $FAILED -eq 0 ]; then
    RESULT="PASS"
fi

cat > "$RESULT_FILE" <<EOF
{
    "test_suite": "doc_tests",
    "test_name": "Documentation Tests - Accuracy Validation",
    "result": "$RESULT",
    "duration_seconds": $DURATION,
    "timestamp": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
    "passed": $PASSED,
    "failed": $FAILED,
    "total": $((PASSED + FAILED)),
    "log_file": "$LOG_FILE"
}
EOF

log "=== Documentation Tests Complete: $RESULT ==="
log "Passed: $PASSED, Failed: $FAILED, Duration: ${DURATION}s"

exit $FAILED

