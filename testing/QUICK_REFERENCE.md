# PYRO Detector - UA Testing Quick Reference

## 🚀 Quick Commands

### Setup Environment
```bash
export MCP_BINARY="./target/release/pyro-detector"
export API_BASE="http://localhost:8080"
export AUTH_TOKEN="your-token"  # if required
```

### Run Tests
```bash
# Run all tests
cd testing/scripts
./run-all-tests.sh

# Run specific category
for script in test-0[1-7]-*.sh; do ./$script; done  # MCP Methods
for script in test-0[8-9]-*.sh test-1[0-3]-*.sh; do ./$script; done  # API

# Run individual test
./test-01-list-detonators.sh
```

### View Results
```bash
# Summary
cat ../results/test-summary.json | jq .

# Specific test
cat ../results/test-01-list-detonators.json | jq .

# Logs
cat ../results/logs/test-01-list-detonators.log
```

## 📋 Test Script Categories

| Category | Scripts | Range |
|----------|---------|-------|
| MCP Methods | 7 | 01-07 |
| API Endpoints | 6 | 08-13 |
| Integration | 6 | 14-19 |
| Performance | 4 | 25-28 |
| Security | 3 | 29-31 |
| CDIF Compliance | 2 | 32-33 |

## 🔍 Log Locations

- **MCP Server**: `./logs/pyro-detector-YYYYMMDD.log`
- **Backend API**: Backend log path (configured)
- **UI**: Browser console (`[PYRO_DETECTOR_UI]`)
- **Test Logs**: `testing/results/logs/test-XX-*.log`

## 📊 Result Status

- **PASS**: Test completed successfully
- **FAIL**: Test failed with errors
- **SKIP**: Test skipped (prerequisites not met)
- **TIMEOUT**: Test exceeded time limit

## 🐛 Issue Tracking

1. Open `testing/ISSUE_TRACKER.md`
2. Add new issue using template
3. Categorize (Critical/High/Medium/Low)
4. Include log excerpts
5. Track status

## 📚 Key Files

- `testing/README.md` - Main entry
- `testing/QUICK_START.md` - Detailed guide
- `testing/MASTER_INDEX.md` - All docs
- `testing/ISSUE_TRACKER.md` - Track issues
- `PROJECT_UA_TESTING_COMPLETE.md` - Complete summary

## ✅ Pre-Testing Checklist

- [ ] MCP server built
- [ ] Backend API running
- [ ] Environment variables set
- [ ] `jq` installed
- [ ] `curl` installed
- [ ] Log directories writable

## 🎯 Testing Workflow

1. **Setup** → Set environment variables
2. **Execute** → Run `./run-all-tests.sh`
3. **Review** → Check `test-summary.json`
4. **Track** → Document issues in `ISSUE_TRACKER.md`
5. **Fix** → Address issues
6. **Re-test** → Verify fixes
7. **Build** → Create signed executable

---

**For detailed information, see `testing/README.md`**

