# PYRO Detector - User Acceptance Testing Framework

## Overview

This document outlines the comprehensive User Acceptance (UA) testing framework for the PYRO Detector integration. The framework includes logging, test scripts, issue tracking, and validation procedures.

## Testing Objectives

1. **Functional Testing**: Verify all MCP methods, API endpoints, and UI workflows
2. **Integration Testing**: Verify end-to-end data flow (UI → Backend → MCP → PYRO Platform)
3. **Performance Testing**: Measure response times, throughput, and resource usage
4. **Error Handling**: Verify proper error handling and recovery
5. **Security Testing**: Verify authentication, authorization, and data protection
6. **Usability Testing**: Verify user experience and interface functionality

## Logging Infrastructure

### MCP Server Logging (Rust)
- **Location**: `./logs/pyro-detector-YYYYMMDD.log`
- **Format**: Structured JSON or text
- **Levels**: ERROR, WARN, INFO, DEBUG, TRACE
- **Rotation**: 10MB max file size, 10 files retained
- **Components**: MCP, API, Config, Health, CDIF

### Backend API Logging (Go)
- **Location**: Configured via `log_path` in config
- **Format**: Structured logging with slog
- **Components**: Request/Response, Errors, Performance, MCP Communication

### UI Logging (React/TypeScript)
- **Location**: Browser console + optional remote logging
- **Format**: Structured JSON
- **Components**: User Actions, API Calls, Errors, Performance, Graph Interactions

## Test Scripts

### Script Categories

1. **MCP Method Tests** (7 scripts)
   - `test-01-list-detonators.sh`
   - `test-02-execute-detonator.sh`
   - `test-03-create-case.sh`
   - `test-04-list-agents.sh`
   - `test-05-execute-pql.sh`
   - `test-06-health-check.sh`
   - `test-07-authenticate.sh`

2. **API Endpoint Tests** (6 scripts)
   - `test-08-api-list-detonators.sh`
   - `test-09-api-execute-detonator.sh`
   - `test-10-api-create-case.sh`
   - `test-11-api-list-agents.sh`
   - `test-12-api-execute-pql.sh`
   - `test-13-api-health.sh`

3. **Integration Tests** (6 scripts)
   - `test-14-end-to-end-detector-flow.sh`
   - `test-15-end-to-end-case-creation.sh`
   - `test-16-end-to-end-pql-query.sh`
   - `test-17-error-handling.sh`
   - `test-18-concurrent-requests.sh`
   - `test-19-timeout-handling.sh`

4. **UI Workflow Tests** (5 scripts)
   - `test-20-ui-navigation.sh`
   - `test-21-ui-detector-list.sh`
   - `test-22-ui-detector-execution.sh`
   - `test-23-ui-graph-visualization.sh`
   - `test-24-ui-error-display.sh`

5. **Performance Tests** (4 scripts)
   - `test-25-load-test.sh`
   - `test-26-stress-test.sh`
   - `test-27-response-time-test.sh`
   - `test-28-memory-usage-test.sh`

6. **Security Tests** (3 scripts)
   - `test-29-authentication-test.sh`
   - `test-30-authorization-test.sh`
   - `test-31-data-validation-test.sh`

7. **CDIF Compliance Tests** (2 scripts)
   - `test-32-cdif-terminology.sh`
   - `test-33-cdif-evidence-chain.sh`

## Issue Tracking

### Issue Categories
- **Critical**: System crashes, data loss, security vulnerabilities
- **High**: Major functionality broken, performance degradation
- **Medium**: Minor functionality issues, UI problems
- **Low**: Cosmetic issues, minor improvements

### Issue Documentation Format
```markdown
## Issue #XXX: [Title]

**Category**: [Critical/High/Medium/Low]
**Component**: [MCP/Backend/UI/Integration]
**Test Script**: test-XX-*.sh
**Status**: [Open/In Progress/Fixed/Verified]

### Description
[Detailed description of the issue]

### Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Logs
[Relevant log excerpts]

### Environment
- OS: [Operating System]
- Rust Version: [Version]
- Go Version: [Version]
- Node Version: [Version]

### Fix
[Description of fix, if applicable]
```

## Test Execution

### Running All Tests
```bash
./testing/run-all-tests.sh
```

### Running Specific Category
```bash
./testing/run-category.sh mcp-methods
./testing/run-category.sh api-endpoints
./testing/run-category.sh integration
./testing/run-category.sh ui-workflows
./testing/run-category.sh performance
./testing/run-category.sh security
./testing/run-category.sh cdif-compliance
```

### Running Individual Test
```bash
./testing/test-01-list-detonators.sh
```

## Test Results

### Results Format
- **PASS**: Test completed successfully
- **FAIL**: Test failed with errors
- **SKIP**: Test skipped (prerequisites not met)
- **TIMEOUT**: Test exceeded time limit

### Results Location
- Individual: `testing/results/test-XX-*.json`
- Summary: `testing/results/test-summary.json`
- Logs: `testing/results/logs/`

## Validation Criteria

### Production Readiness Checklist
- [ ] All 33+ test scripts pass
- [ ] No critical or high-priority issues
- [ ] Performance metrics within acceptable ranges
- [ ] Security tests pass
- [ ] CDIF compliance verified
- [ ] Documentation complete
- [ ] Logging comprehensive and functional
- [ ] Error handling robust
- [ ] Signed executable created

## Next Steps

1. Execute all test scripts
2. Document all issues found
3. Fix issues and re-test
4. Generate test report
5. Create signed executable
6. Final validation

