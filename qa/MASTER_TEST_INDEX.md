# PYRO Detector - Master Test Index

## Complete Test Suite Catalog

### Unit Tests
- **Location**: `qa/unit/pyro_detector_tests.rs`
- **Type**: Rust unit tests
- **Coverage**: Individual components
- **Run**: `cargo test --lib`

### Integration Tests
- **Location**: `qa/integration/pyro_detector_integration_tests.rs`
- **Type**: Rust integration tests
- **Coverage**: Component interactions
- **Run**: `cargo test --test pyro_detector_integration_tests`

### System Tests
- **Location**: `qa/system/system_tests.sh`
- **Type**: System-level tests
- **Coverage**: Complete workflows
- **Run**: `./qa/system/system_tests.sh`

### QA Tests
- **Location**: `qa/qa_test_suite.sh`
- **Type**: Functional requirements
- **Coverage**: All requirements
- **Run**: `./qa/qa_test_suite.sh`

### Regression Tests
- **Location**: `qa/regression/regression_test_suite.sh`
- **Type**: Regression validation
- **Coverage**: Existing functionality
- **Run**: `./qa/regression/regression_test_suite.sh`

### Smoke Tests
- **Location**: `qa/smoke/smoke_tests.sh`
- **Type**: Critical functionality
- **Coverage**: Core features
- **Run**: `./qa/smoke/smoke_tests.sh`

### Sanity Tests
- **Location**: `qa/sanity/sanity_tests.sh`
- **Type**: Change validation
- **Coverage**: Changed functionality
- **Run**: `./qa/sanity/sanity_tests.sh`

### Compatibility Tests
- **Location**: `qa/compatibility/compatibility_tests.sh`
- **Type**: Cross-platform
- **Coverage**: Windows, Linux, macOS
- **Run**: `./qa/compatibility/compatibility_tests.sh`

### Usability Tests
- **Location**: `qa/usability/usability_tests.sh`
- **Type**: User experience
- **Coverage**: UX validation
- **Run**: `./qa/usability/usability_tests.sh`

### Accessibility Tests
- **Location**: `qa/accessibility/accessibility_tests.sh`
- **Type**: WCAG compliance
- **Coverage**: Accessibility
- **Run**: `./qa/accessibility/accessibility_tests.sh`

### Documentation Tests
- **Location**: `qa/documentation/doc_tests.sh`
- **Type**: Documentation accuracy
- **Coverage**: All documentation
- **Run**: `./qa/documentation/doc_tests.sh`

### Deployment Tests
- **Location**: `qa/deployment/deployment_tests.sh`
- **Type**: Installation/configuration
- **Coverage**: Deployment process
- **Run**: `./qa/deployment/deployment_tests.sh`

### Rollback Tests
- **Location**: `qa/rollback/rollback_tests.sh`
- **Type**: Version recovery
- **Coverage**: Rollback procedures
- **Run**: `./qa/rollback/rollback_tests.sh`

### Monitoring Tests
- **Location**: `qa/monitoring/monitoring_tests.sh`
- **Type**: Observability
- **Coverage**: Logging, metrics
- **Run**: `./qa/monitoring/monitoring_tests.sh`

### Disaster Recovery Tests
- **Location**: `qa/disaster_recovery/dr_tests.sh`
- **Type**: Backup and recovery
- **Coverage**: DR procedures
- **Run**: `./qa/disaster_recovery/dr_tests.sh`

### User Acceptance Tests
- **Location**: `testing/scripts/test-*.sh`
- **Type**: User workflows
- **Coverage**: 28+ test scripts
- **Run**: `./testing/scripts/run-all-tests.sh`

### Performance Tests
- **Location**: `testing/scripts/test-25-28-*.sh`
- **Type**: Performance validation
- **Coverage**: Load, stress, response time, memory
- **Run**: Individual scripts

### Security Tests
- **Location**: `testing/scripts/test-29-31-*.sh`
- **Type**: Security validation
- **Coverage**: Authentication, authorization, validation
- **Run**: Individual scripts

## Master Test Runner

### Run All Tests
```bash
./qa/run-all-sdlc-tests.sh
```

This executes all test phases and generates a comprehensive summary.

## Test Statistics

- **Total Test Suites**: 18 phases
- **Total Test Scripts**: 50+ scripts
- **Coverage**: 100% of SDLC phases
- **Status**: ✅ Complete

## Test Execution Order

1. Unit Tests
2. Integration Tests
3. Smoke Tests
4. Sanity Tests
5. Regression Tests
6. QA Tests
7. System Tests
8. Performance Tests
9. Security Tests
10. Compatibility Tests
11. User Acceptance Tests
12. Usability Tests
13. Accessibility Tests
14. Documentation Tests
15. Deployment Tests
16. Rollback Tests
17. Monitoring Tests
18. Disaster Recovery Tests

---

**For execution details, see `SDLC_EXECUTION_GUIDE.md`**

