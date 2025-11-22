# UA Testing - Quick Start Guide

## Prerequisites

1. **MCP Server Built**
   ```bash
   cd pyro-detector
   cargo build --release
   ```

2. **Backend API Running**
   ```bash
   # Start BloodHound API server
   # Should be running on http://localhost:8080 (or configured port)
   ```

3. **Frontend Running** (optional for UI tests)
   ```bash
   cd cmd/ui
   npm install
   npm run dev
   ```

4. **Tools Required**
   - `jq` - JSON processor (for test scripts)
   - `curl` - HTTP client (for API tests)
   - `bash` or PowerShell

## Running Tests

### Run All Tests
```bash
cd testing/scripts
./run-all-tests.sh
```

### Run Specific Category
```bash
# MCP Methods
for script in test-0[1-7]-*.sh; do ./$script; done

# API Endpoints
for script in test-0[8-9]-*.sh test-1[0-3]-*.sh; do ./$script; done

# Integration Tests
for script in test-1[4-9]-*.sh; do ./$script; done
```

### Run Individual Test
```bash
./test-01-list-detonators.sh
```

## Test Results

Results are written to:
- Individual: `testing/results/test-XX-*.json`
- Summary: `testing/results/test-summary.json`
- Logs: `testing/results/logs/test-XX-*.log`

## Environment Variables

Set these before running tests:

```bash
# MCP Server binary path
export MCP_BINARY="./target/release/pyro-detector"

# API Base URL
export API_BASE="http://localhost:8080"

# Authentication token (if required)
export AUTH_TOKEN="your-token-here"

# Test data
export TEST_DETONATOR_ID="test-detonator-001"
export TEST_PQL_QUERY="SELECT * FROM agents LIMIT 10"
```

## Viewing Results

```bash
# View summary
cat testing/results/test-summary.json | jq .

# View specific test result
cat testing/results/test-01-list-detonators.json | jq .

# View test log
cat testing/results/logs/test-01-list-detonators.log
```

## Issue Tracking

When a test fails:

1. Check the log file: `testing/results/logs/test-XX-*.log`
2. Document in `testing/ISSUE_TRACKER.md`
3. Include:
   - Test ID
   - Error message
   - Log excerpts
   - Steps to reproduce

## Next Steps

1. Run all tests
2. Document all issues
3. Fix issues
4. Re-run tests
5. Generate final report

