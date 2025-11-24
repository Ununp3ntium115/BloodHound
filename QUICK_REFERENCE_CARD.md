# ⚡ PYRO Detector - Quick Reference Card

**Essential Commands and Information at a Glance**

---

## 🚀 Quick Start

```bash
# Build PYRO Detector
cd pyro-detector && cargo build --release

# Configure (add to bhapi.json)
{
  "pyro_detector_path": "./target/release/pyro-detector"
}

# Access UI
http://localhost:8080/ui/pyro-detector
```

---

## 🧪 Testing Commands

### Run All Tests
```bash
./qa/run-all-sdlc-tests.sh
```

### Run Specific Phase
```bash
./qa/smoke/smoke_tests.sh          # Smoke tests
./qa/qa_test_suite.sh              # QA tests
./qa/regression/regression_test_suite.sh  # Regression
cd testing/scripts && ./run-all-tests.sh  # UA tests
```

### Rust Tests
```bash
cargo test --lib                   # Unit tests
cargo test --test pyro_detector_integration_tests  # Integration
```

---

## 🔄 Iteration Cycle

### Complete Iteration
```bash
./qa/run-sdlc-iteration.sh
```

### Individual Phases
```bash
./qa/run-all-sdlc-tests.sh      # Phase 1: Test Execution
./qa/analyze-results.sh          # Phase 2: Analysis
# Phase 3: Issue Tracking (review testing/ISSUE_TRACKER.md)
# Phase 4: Remediation (manual fixes)
./qa/validate-fixes.sh          # Phase 5: Validation
./qa/document-iteration.sh      # Phase 6: Documentation
```

---

## 📁 Key Directories

```
pyro-detector/          # MCP server (Rust)
qa/                     # SDLC testing framework
testing/                # UA testing scripts
cmd/api/src/api/v2/     # Backend API (Go)
cmd/ui/src/views/       # Frontend UI (React)
```

---

## 📚 Essential Documentation

### Start Here
- `README_PYRO_DETECTOR_COMPLETE.md` - Master hub
- `QUICK_START_COMPLETE.md` - 5-minute setup
- `PROJECT_FINAL_STATUS.md` - Complete status

### Testing
- `qa/FIRST_ITERATION_GUIDE.md` - First iteration
- `qa/SDLC_EXECUTION_GUIDE.md` - Test execution
- `qa/README.md` - SDLC framework

### Deployment
- `DEPLOYMENT_READY.md` - Deployment checklist
- `pyro-detector/SIGNED_EXECUTABLE_BUILD.md` - Build guide

---

## 🔧 Common Tasks

### Development
```bash
# Build
cd pyro-detector && cargo build --release

# Test
cargo test

# Run
./target/release/pyro-detector
```

### Testing
```bash
# All SDLC tests
./qa/run-all-sdlc-tests.sh

# Specific phase
./qa/smoke/smoke_tests.sh
```

### Analysis
```bash
# Analyze results
./qa/analyze-results.sh

# View summary
cat qa/results/sdlc/sdlc-test-summary.json | jq .
```

---

## 📊 Test Phases (19 Total)

1. Unit Tests
2. Integration Tests
3. System Tests
4. QA Tests
5. UA Tests (28 scripts)
6. Performance Tests
7. Security Tests
8. Regression Tests
9. Smoke Tests
10. Sanity Tests
11. Compatibility Tests
12. Usability Tests
13. Accessibility Tests
14. Documentation Tests
15. Deployment Tests
16. Rollback Tests
17. Monitoring Tests
18. Disaster Recovery Tests
19. Code Review

---

## 🎯 Quick Status Check

```bash
# Check git status
git status

# View recent commits
git log --oneline -5

# Check test results
cat qa/results/sdlc/sdlc-test-summary.json | jq .

# View iteration report
cat qa/results/sdlc/iterations/*/ITERATION_REPORT.md
```

---

## 🔍 Troubleshooting

### Build Issues
```bash
# Check Rust installation
rustc --version
cargo --version

# Clean and rebuild
cd pyro-detector
cargo clean
cargo build --release
```

### Test Issues
```bash
# Make scripts executable
chmod +x qa/*.sh
chmod +x qa/**/*.sh

# Check logs
cat qa/results/sdlc/*.log
```

### Runtime Issues
```bash
# Check config
cat bhapi.json | jq .pyro_detector_path

# Check binary
ls -lh ./target/release/pyro-detector

# Check logs
tail -f logs/pyro-detector.log
```

---

## 📈 Metrics

### Project Stats
- **Files**: 272+ files
- **Lines**: ~35,000+ lines
- **Test Scripts**: 50+ scripts
- **Documentation**: 41+ files

### Test Coverage
- **SDLC Phases**: 19/19 (100%)
- **Test Scripts**: 50+ scripts
- **Documentation**: 100% complete

---

## 🚨 Important Files

### Configuration
- `bhapi.json` - Backend configuration
- `pyro-detector/config.yaml` - MCP server config

### Results
- `qa/results/sdlc/sdlc-test-summary.json` - Test summary
- `qa/results/sdlc/analysis.json` - Analysis results
- `qa/results/sdlc/iterations/` - Iteration reports

### Issue Tracking
- `testing/ISSUE_TRACKER.md` - Issue tracker

---

## 💡 Pro Tips

1. **Always check logs first** when troubleshooting
2. **Run smoke tests** before full test suite
3. **Use iteration cycle** for continuous improvement
4. **Track issues** in `testing/ISSUE_TRACKER.md`
5. **Review documentation** before asking questions

---

## 🔗 Quick Links

- **Master Hub**: `README_PYRO_DETECTOR_COMPLETE.md`
- **Navigation**: `NAVIGATION_INDEX.md`
- **Status**: `PROJECT_FINAL_STATUS.md`
- **Deployment**: `DEPLOYMENT_READY.md`

---

⚡ **Quick Reference Card - Essential Commands** ⚡

*Keep this handy for quick access to common commands and information.*

