# 🔄 SDLC Iteration Cycle - Quick Reference

**Continuous Improvement Process for PYRO Detector Testing**

---

## 🚀 Quick Start

### Run Complete Iteration Cycle
```bash
./qa/run-sdlc-iteration.sh
```

### Run Individual Phases
```bash
# Phase 1: Execute Tests
./qa/run-all-sdlc-tests.sh

# Phase 2: Analyze Results
./qa/analyze-results.sh

# Phase 3: Issue Tracking
# (Manual - review testing/ISSUE_TRACKER.md)

# Phase 4: Remediation
# (Manual - fix issues)

# Phase 5: Validate Fixes
./qa/validate-fixes.sh

# Phase 6: Document Iteration
./qa/document-iteration.sh
```

---

## 📊 Iteration Phases

1. **Test Execution** - Run all SDLC test suites
2. **Analysis** - Analyze results and identify issues
3. **Issue Tracking** - Track and prioritize issues
4. **Remediation** - Fix identified issues
5. **Validation** - Re-test to verify fixes
6. **Documentation** - Document iteration results

---

## 📁 Results Location

- **Test Results**: `qa/results/sdlc/`
- **Iteration Reports**: `qa/results/sdlc/iterations/`
- **Analysis**: `qa/results/sdlc/analysis.json`
- **Issue Tracker**: `testing/ISSUE_TRACKER.md`

---

## 📚 Documentation

- `SDLC_ITERATION_CYCLE.md` - Complete iteration guide
- `SDLC_EXECUTION_GUIDE.md` - Test execution guide
- `SDLC_TESTING_FRAMEWORK.md` - Framework overview

---

🔥 **SDLC Iteration Cycle - Continuous Improvement** 🔥

