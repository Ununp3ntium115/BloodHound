# PYRO Detector - SDLC Testing Execution Guide

## Complete SDLC Testing Workflow

### Phase 1: Development Testing

#### 1.1 Unit Tests (On Every Commit)
```bash
# Rust unit tests
cargo test --lib

# Go unit tests (if applicable)
go test ./...
```

#### 1.2 Integration Tests (On Pull Request)
```bash
# Rust integration tests
cargo test --test pyro_detector_integration_tests

# Run integration test suite
./qa/integration/pyro_detector_integration_tests.sh
```

#### 1.3 Code Review
- Use `qa/code_review/CODE_REVIEW_CHECKLIST.md`
- Run linters and formatters
- Verify all checklist items

### Phase 2: Pre-Release Testing

#### 2.1 Smoke Tests (After Build)
```bash
./qa/smoke/smoke_tests.sh
```

#### 2.2 Sanity Tests (After Changes)
```bash
./qa/sanity/sanity_tests.sh
```

#### 2.3 Regression Tests
```bash
./qa/regression/regression_test_suite.sh
```

#### 2.4 QA Tests
```bash
./qa/qa_test_suite.sh
```

### Phase 3: Release Testing

#### 3.1 System Tests
```bash
./qa/system/system_tests.sh
```

#### 3.2 Performance Tests
```bash
./testing/scripts/test-25-load-test.sh
./testing/scripts/test-26-stress-test.sh
./testing/scripts/test-27-response-time-test.sh
./testing/scripts/test-28-memory-usage-test.sh
```

#### 3.3 Security Tests
```bash
./testing/scripts/test-29-authentication-test.sh
./testing/scripts/test-30-authorization-test.sh
./testing/scripts/test-31-data-validation-test.sh
```

#### 3.4 Compatibility Tests
```bash
./qa/compatibility/compatibility_tests.sh
```

### Phase 4: Post-Release Testing

#### 4.1 User Acceptance Tests
```bash
cd testing/scripts
./run-all-tests.sh
```

#### 4.2 Usability Tests
```bash
./qa/usability/usability_tests.sh
```

#### 4.3 Accessibility Tests
```bash
./qa/accessibility/accessibility_tests.sh
```

#### 4.4 Monitoring Validation
```bash
./qa/monitoring/monitoring_tests.sh
```

#### 4.5 Rollback Validation
```bash
./qa/rollback/rollback_tests.sh
```

### Phase 5: Documentation & Deployment

#### 5.1 Documentation Tests
```bash
./qa/documentation/doc_tests.sh
```

#### 5.2 Deployment Tests
```bash
./qa/deployment/deployment_tests.sh
```

#### 5.3 Disaster Recovery Tests
```bash
./qa/disaster_recovery/dr_tests.sh
```

## Master Test Execution

### Run All SDLC Tests
```bash
./qa/run-all-sdlc-tests.sh
```

This executes all test phases in sequence and generates a comprehensive summary.

## Test Results

Results are stored in:
- `qa/results/{phase}/` - Individual phase results
- `qa/results/sdlc/sdlc-test-summary.json` - Master summary

## Continuous Integration

### CI/CD Integration Example

```yaml
# .github/workflows/sdlc-tests.yml
name: SDLC Tests

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run unit tests
        run: cargo test --lib
  
  integration-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run integration tests
        run: cargo test --test pyro_detector_integration_tests
  
  smoke-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: cargo build --release
      - name: Run smoke tests
        run: ./qa/smoke/smoke_tests.sh
  
  qa-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run QA tests
        run: ./qa/qa_test_suite.sh
  
  regression-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run regression tests
        run: ./qa/regression/regression_test_suite.sh
```

## Test Execution Matrix

| Phase | Trigger | Frequency | Duration | Critical |
|-------|---------|-----------|----------|----------|
| Unit | Commit | Every | < 1 min | Yes |
| Integration | PR | Every | < 5 min | Yes |
| Smoke | Build | Every | < 2 min | Yes |
| Sanity | Change | Every | < 2 min | Yes |
| Regression | Pre-release | Daily | < 10 min | Yes |
| QA | Pre-release | Daily | < 15 min | Yes |
| System | Release | Weekly | < 20 min | Yes |
| Performance | Release | Weekly | < 30 min | Medium |
| Security | Release | Weekly | < 15 min | Yes |
| Compatibility | Release | Weekly | < 10 min | Medium |
| UA | Post-release | Weekly | < 60 min | High |
| Usability | Post-release | Monthly | < 30 min | Medium |
| Accessibility | Post-release | Monthly | < 15 min | Medium |
| Documentation | Release | Every | < 5 min | Low |
| Deployment | Release | Every | < 10 min | Yes |
| Rollback | Release | Every | < 5 min | Yes |
| Monitoring | Post-release | Daily | < 5 min | High |
| DR | Post-release | Monthly | < 15 min | High |

## Success Criteria

### Development Phase
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Code review checklist complete
- [ ] No linter errors

### Pre-Release Phase
- [ ] All smoke tests pass
- [ ] All sanity tests pass
- [ ] All regression tests pass
- [ ] All QA tests pass

### Release Phase
- [ ] All system tests pass
- [ ] Performance within limits
- [ ] Security tests pass
- [ ] Compatibility verified

### Post-Release Phase
- [ ] UA tests pass
- [ ] Usability acceptable
- [ ] Monitoring functional
- [ ] Rollback validated

## Troubleshooting

### Tests Fail
1. Check logs in `qa/results/{phase}/`
2. Review error messages
3. Verify environment setup
4. Check prerequisites

### Performance Issues
1. Review performance test results
2. Check resource usage
3. Optimize bottlenecks
4. Re-run tests

### Security Issues
1. Review security test results
2. Address vulnerabilities
3. Re-run security tests
4. Document fixes

---

**For complete framework details, see `SDLC_TESTING_FRAMEWORK.md`**

