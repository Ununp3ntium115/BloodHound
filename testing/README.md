# PYRO Detector - UA Testing

🔥 **User Acceptance Testing Framework** 🔥

Complete testing infrastructure for PYRO Detector with comprehensive logging, 28+ test scripts, and issue tracking.

## 🚀 Quick Start

```bash
# 1. Set environment variables
export MCP_BINARY="./target/release/pyro-detector"
export API_BASE="http://localhost:8080"

# 2. Run all tests
cd testing/scripts
./run-all-tests.sh

# 3. Review results
cat ../results/test-summary.json | jq .
```

## 📚 Documentation

### Getting Started
- **[QUICK_START.md](scripts/QUICK_START.md)** - Quick start guide
- **[UA_TESTING_FRAMEWORK.md](UA_TESTING_FRAMEWORK.md)** - Complete framework guide
- **[MASTER_INDEX.md](MASTER_INDEX.md)** - Complete documentation index

### Status & Summary
- **[FINAL_UA_TESTING_SUMMARY.md](FINAL_UA_TESTING_SUMMARY.md)** - Final comprehensive summary
- **[UA_TESTING_STATUS.md](UA_TESTING_STATUS.md)** - Current status
- **[VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md)** - Pre-testing verification

### Issue Tracking
- **[ISSUE_TRACKER.md](ISSUE_TRACKER.md)** - Issue tracking system

## 📊 Test Scripts

**28+ test scripts** covering:
- ✅ MCP Methods (7 scripts)
- ✅ API Endpoints (6 scripts)
- ✅ Integration (6 scripts)
- ✅ Performance (4 scripts)
- ✅ Security (3 scripts)
- ✅ CDIF Compliance (2 scripts)

See **[TEST_SCRIPTS_SUMMARY.md](TEST_SCRIPTS_SUMMARY.md)** for complete list.

## 🔍 Logging

Comprehensive logging implemented:
- ✅ **MCP Server** (Rust) - File-based with rotation
- ✅ **Backend API** (Go) - Request/response tracking
- ✅ **UI** (React/TypeScript) - User action tracking

## 📋 Testing Workflow

1. **Pre-Testing**
   - Review [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md)
   - Set up environment
   - Verify prerequisites

2. **Execute Tests**
   - Run all tests: `./run-all-tests.sh`
   - Or run individual tests
   - Review results in `results/` directory

3. **Track Issues**
   - Document issues in [ISSUE_TRACKER.md](ISSUE_TRACKER.md)
   - Categorize (Critical/High/Medium/Low)
   - Include log excerpts

4. **Fix & Re-test**
   - Fix issues
   - Re-run tests
   - Verify fixes

5. **Final Steps**
   - Generate test report
   - Create signed executable
   - Final validation

## 📁 Directory Structure

```
testing/
├── README.md (this file)
├── MASTER_INDEX.md
├── UA_TESTING_FRAMEWORK.md
├── FINAL_UA_TESTING_SUMMARY.md
├── VERIFICATION_CHECKLIST.md
├── ISSUE_TRACKER.md
├── scripts/
│   ├── QUICK_START.md
│   ├── run-all-tests.sh
│   ├── test-*.sh (28+ scripts)
│   └── ...
└── results/
    ├── logs/
    └── test-summary.json (generated)
```

## ✅ Status

- **Logging**: ✅ 100% Complete
- **Test Scripts**: ✅ 28+ Created
- **Framework**: ✅ 100% Complete
- **Documentation**: ✅ 100% Complete

**Ready for UA Testing!**

---

For complete documentation, see **[MASTER_INDEX.md](MASTER_INDEX.md)**

