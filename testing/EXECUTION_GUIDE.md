# PYRO Detector - UA Testing Execution Guide

## Step-by-Step Execution Guide

### Phase 1: Pre-Testing Setup

#### 1.1 Build MCP Server
```bash
cd pyro-detector
cargo build --release
```

#### 1.2 Verify Binary
```bash
ls -lh ./target/release/pyro-detector
# or on Windows
dir target\release\pyro-detector.exe
```

#### 1.3 Start Backend API
```bash
# Start BloodHound API server
# Should be running on http://localhost:8080 (or configured port)
```

#### 1.4 Set Environment Variables
```bash
export MCP_BINARY="./target/release/pyro-detector"
export API_BASE="http://localhost:8080"
export AUTH_TOKEN="your-token-here"  # if authentication required
export TEST_DETONATOR_ID="test-detonator-001"  # optional
export TEST_PQL_QUERY="SELECT * FROM agents LIMIT 10"  # optional
```

### Phase 2: Execute Tests

#### 2.1 Run All Tests
```bash
cd testing/scripts
./run-all-tests.sh
```

This will:
- Execute all 28+ test scripts
- Generate individual result JSON files
- Create summary JSON file
- Log all output to files

#### 2.2 Run Specific Category

**MCP Methods:**
```bash
for script in test-0[1-7]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

**API Endpoints:**
```bash
for script in test-0[8-9]-*.sh test-1[0-3]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

**Integration Tests:**
```bash
for script in test-1[4-9]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

**Performance Tests:**
```bash
for script in test-2[5-8]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

**Security Tests:**
```bash
for script in test-2[9-9]-*.sh test-3[0-1]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

**CDIF Compliance:**
```bash
for script in test-3[2-3]-*.sh; do 
    echo "Running $script..."
    ./$script
done
```

### Phase 3: Review Results

#### 3.1 View Summary
```bash
cd testing/results
cat test-summary.json | jq .
```

#### 3.2 View Individual Results
```bash
# List all results
ls -1 test-*.json

# View specific result
cat test-01-list-detonators.json | jq .

# Count passes/fails
cat test-summary.json | jq '.passed, .failed, .skipped'
```

#### 3.3 Review Logs
```bash
cd logs
# List all logs
ls -1 test-*.log

# View specific log
cat test-01-list-detonators.log

# Search for errors
grep -i error test-*.log
```

### Phase 4: Document Issues

#### 4.1 Open Issue Tracker
```bash
# Edit the issue tracker
# File: testing/ISSUE_TRACKER.md
```

#### 4.2 Add New Issue
Use the template in `ISSUE_TRACKER.md`:

```markdown
### Issue #XXX: [Title]
**Status**: Open  
**Category**: [Critical/High/Medium/Low]  
**Component**: [MCP/Backend/UI/Integration]  
**Test Script**: test-XX-*.sh  
**Discovered**: YYYY-MM-DD

#### Description
[Detailed description]

#### Steps to Reproduce
1. [Step 1]
2. [Step 2]

#### Expected Behavior
[What should happen]

#### Actual Behavior
[What actually happens]

#### Logs
```
[Relevant log excerpts]
```
```

#### 4.3 Update Statistics
Update the statistics section in `ISSUE_TRACKER.md`:
- Total Issues
- By Category
- By Status

### Phase 5: Fix Issues

#### 5.1 Prioritize
- Critical: Fix immediately
- High: Fix before production
- Medium: Fix in next iteration
- Low: Fix when time permits

#### 5.2 Fix Issues
- Address each issue
- Test fixes
- Update issue status

#### 5.3 Re-test
```bash
# Re-run specific test
./test-XX-issue-name.sh

# Or re-run all tests
./run-all-tests.sh
```

### Phase 6: Generate Report

#### 6.1 Create Test Report
```bash
# Generate report from results
cat test-summary.json | jq '{
    timestamp: .timestamp,
    total: .total,
    passed: .passed,
    failed: .failed,
    skipped: .skipped,
    pass_rate: .pass_rate,
    results: [.results[] | {
        test_id: .test_id,
        result: .result,
        duration: .duration_seconds
    }]
}' > test-report.json
```

#### 6.2 Include Issues
- List all issues from `ISSUE_TRACKER.md`
- Include fixes applied
- Show verification results

### Phase 7: Create Signed Executable

#### 7.1 Follow Build Guide
See `pyro-detector/SIGNED_EXECUTABLE_BUILD.md`

#### 7.2 Build and Sign
```bash
# Windows
signtool.exe sign /f certificate.pfx /p password /t http://timestamp.digicert.com target/release/pyro-detector.exe

# macOS
codesign --sign "Developer ID" --timestamp target/release/pyro-detector

# Linux
gpg --armor --detach-sign target/release/pyro-detector
```

#### 7.3 Verify Signature
```bash
# Windows
signtool.exe verify /pa target/release/pyro-detector.exe

# macOS
codesign --verify target/release/pyro-detector

# Linux
gpg --verify pyro-detector.sig pyro-detector
```

### Phase 8: Final Validation

#### 8.1 Run All Tests Against Signed Binary
```bash
export MCP_BINARY="./target/release/pyro-detector"  # signed version
./run-all-tests.sh
```

#### 8.2 Verify All Tests Pass
```bash
cat test-summary.json | jq '.failed == 0'
```

#### 8.3 Final Checklist
- [ ] All tests pass
- [ ] No critical issues
- [ ] All high-priority issues fixed
- [ ] Signed executable created
- [ ] Signature verified
- [ ] Documentation complete

---

## Troubleshooting

### Test Script Fails
1. Check log file: `testing/results/logs/test-XX-*.log`
2. Verify environment variables
3. Check MCP server binary exists
4. Verify backend API is running

### No Response from MCP Server
1. Check binary path: `echo $MCP_BINARY`
2. Verify binary exists: `ls -lh $MCP_BINARY`
3. Check permissions: `chmod +x $MCP_BINARY`
4. Test manually: `echo '{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}' | $MCP_BINARY`

### API Tests Fail
1. Verify API is running: `curl $API_BASE/health`
2. Check authentication: Verify `AUTH_TOKEN` if required
3. Review API logs
4. Check network connectivity

### Logs Not Generated
1. Verify log directory exists: `mkdir -p testing/results/logs`
2. Check write permissions
3. Verify logging is enabled in code

---

## Best Practices

1. **Run tests in order**: Start with MCP methods, then API, then integration
2. **Document immediately**: Add issues to tracker as you find them
3. **Include context**: Always include log excerpts with issues
4. **Test fixes**: Re-run tests after fixing issues
5. **Keep logs**: Don't delete logs until testing is complete
6. **Version control**: Commit test results and issue tracker

---

**For quick reference, see `testing/QUICK_REFERENCE.md`**

