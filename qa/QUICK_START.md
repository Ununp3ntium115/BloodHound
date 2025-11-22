# PYRO Detector SDLC Testing - Quick Start

## 🚀 Run All Tests

```bash
# Execute complete SDLC test suite
./qa/run-all-sdlc-tests.sh
```

## 📋 Run Individual Phases

### Development Phase
```bash
# Unit tests
cargo test --lib

# Integration tests
cargo test --test pyro_detector_integration_tests
```

### Pre-Release Phase
```bash
# Smoke tests
./qa/smoke/smoke_tests.sh

# QA tests
./qa/qa_test_suite.sh

# Regression tests
./qa/regression/regression_test_suite.sh
```

### Release Phase
```bash
# System tests
./qa/system/system_tests.sh

# Performance tests
./testing/scripts/test-25-load-test.sh
./testing/scripts/test-26-stress-test.sh

# Security tests
./testing/scripts/test-29-authentication-test.sh
```

### Post-Release Phase
```bash
# UA tests
cd testing/scripts && ./run-all-tests.sh

# Usability tests
./qa/usability/usability_tests.sh

# Monitoring tests
./qa/monitoring/monitoring_tests.sh
```

## ⚙️ Environment Setup

```bash
export MCP_BINARY="./target/release/pyro-detector"
export API_BASE="http://localhost:8080"
export AUTH_TOKEN="your-token"  # if required
```

## 📊 View Results

```bash
# Master summary
cat qa/results/sdlc/sdlc-test-summary.json | jq .

# Individual phase results
cat qa/results/qa/qa-test-suite.json | jq .
cat qa/results/smoke/smoke-tests.json | jq .
```

## 📚 Documentation

- **Framework**: `qa/SDLC_TESTING_FRAMEWORK.md`
- **Execution Guide**: `qa/SDLC_EXECUTION_GUIDE.md`
- **Master Index**: `qa/MASTER_TEST_INDEX.md`
- **README**: `qa/README.md`

---

**For complete details, see `qa/README.md`**

