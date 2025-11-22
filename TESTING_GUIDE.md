# 🧪 Testing Guide - PYRO Detector Integration

🔥 **Complete Testing Guide for PYRO Detector Integration** 🔥

---

## 🎯 Testing Overview

This guide covers testing the complete integration chain: UI → Backend API → MCP Server → PYRO Platform.

---

## 📋 Pre-Testing Checklist

### Prerequisites
- [ ] PYRO Detector MCP server built (`cargo build --release`)
- [ ] Backend configured with `pyro_detector_path`
- [ ] PYRO Platform Ignition accessible
- [ ] Backend API running
- [ ] UI accessible

### Build Verification
```bash
# Build PYRO Detector
cd pyro-detector
cargo build --release

# Verify binary exists
ls target/release/pyro-detector
```

---

## 🧪 Test Scenarios

### 1. Backend API Tests

#### Test 1.1: Health Check
```bash
curl -X GET http://localhost:8080/api/v2/pyro-detector/health \
  -H "Authorization: Bearer <token>"
```

**Expected**: 200 OK with health status

#### Test 1.2: List Detonators
```bash
curl -X GET http://localhost:8080/api/v2/pyro-detector/detonators \
  -H "Authorization: Bearer <token>"
```

**Expected**: 200 OK with list of detonators

#### Test 1.3: Execute Detonator
```bash
curl -X POST http://localhost:8080/api/v2/pyro-detector/detonators/detonator-1/execute \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"case_id": "case-123", "parameters": {}}'
```

**Expected**: 200 OK with execution results

#### Test 1.4: Create Case
```bash
curl -X POST http://localhost:8080/api/v2/pyro-detector/cases \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Case", "description": "Test investigation"}'
```

**Expected**: 201 Created with case details

#### Test 1.5: List Agents
```bash
curl -X GET http://localhost:8080/api/v2/pyro-detector/agents \
  -H "Authorization: Bearer <token>"
```

**Expected**: 200 OK with list of agents

#### Test 1.6: Execute PQL
```bash
curl -X POST http://localhost:8080/api/v2/pyro-detector/pql \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT * FROM agents", "parameters": {}}'
```

**Expected**: 200 OK with query results

---

### 2. MCP Server Tests

#### Test 2.1: Direct MCP Communication
```bash
# Test JSON-RPC 2.0 communication
echo '{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}' | ./target/release/pyro-detector
```

**Expected**: JSON-RPC 2.0 response with health status

#### Test 2.2: List Detonators via MCP
```bash
echo '{"jsonrpc":"2.0","id":1,"method":"pyro_list_detonators","params":{}}' | ./target/release/pyro-detector
```

**Expected**: JSON-RPC 2.0 response with detonator list

---

### 3. UI Integration Tests

#### Test 3.1: Access UI
1. Navigate to `/ui/pyro-detector`
2. Verify page loads
3. Verify navigation menu shows "PYRO Detector"

**Expected**: Page loads, navigation visible

#### Test 3.2: Load Detonators
1. Open browser console
2. Navigate to PYRO Detector page
3. Check network tab for API calls

**Expected**: API call to `/api/v2/pyro-detector/detonators` succeeds

#### Test 3.3: Execute Detonator
1. Click on a detonator in the list
2. Verify API call is made
3. Verify graph updates (if results available)

**Expected**: Detonator executes, results displayed

#### Test 3.4: Investigation Controls
1. Click "Create Case" button
2. Click "List Agents" button
3. Click "Execute PQL Query" button

**Expected**: Each button triggers appropriate API call

---

### 4. End-to-End Tests

#### Test 4.1: Complete Workflow
1. **Create Case**: Click "Create Case" → Verify case created
2. **List Detonators**: Verify detonator list loads
3. **Execute Detonator**: Select detonator → Execute → Verify results
4. **View Graph**: Verify network graph displays results
5. **List Agents**: Click "List Agents" → Verify agents listed

**Expected**: Complete workflow executes successfully

#### Test 4.2: Error Handling
1. **Invalid Detonator**: Try to execute non-existent detonator
2. **Network Error**: Disconnect PYRO Platform → Verify error handling
3. **Invalid PQL**: Execute invalid PQL query → Verify error message

**Expected**: Appropriate error messages displayed

---

## 🔧 Test Configuration

### Backend Configuration
```json
{
  "pyro_detector_path": "./target/release/pyro-detector",
  "bind_addr": "0.0.0.0:8080"
}
```

### PYRO Detector Configuration
```json
{
  "pyro_api_url": "http://localhost:3001",
  "api_token": "your-token-here",
  "cdif_compliance": true
}
```

---

## 📊 Test Results Template

### Test Results
| Test ID | Description | Status | Notes |
|---------|-------------|--------|-------|
| 1.1 | Health Check | ⏳ | |
| 1.2 | List Detonators | ⏳ | |
| 1.3 | Execute Detonator | ⏳ | |
| 1.4 | Create Case | ⏳ | |
| 1.5 | List Agents | ⏳ | |
| 1.6 | Execute PQL | ⏳ | |
| 2.1 | Direct MCP | ⏳ | |
| 2.2 | MCP List Detonators | ⏳ | |
| 3.1 | Access UI | ⏳ | |
| 3.2 | Load Detonators | ⏳ | |
| 3.3 | Execute Detonator | ⏳ | |
| 3.4 | Investigation Controls | ⏳ | |
| 4.1 | Complete Workflow | ⏳ | |
| 4.2 | Error Handling | ⏳ | |

---

## 🐛 Troubleshooting

### Issue: MCP Server Not Found
**Symptom**: Backend returns "failed to start MCP server"

**Solution**:
1. Verify `pyro_detector_path` in config
2. Check binary exists at path
3. Verify binary has execute permissions

### Issue: API Returns 500 Error
**Symptom**: Backend returns internal server error

**Solution**:
1. Check backend logs
2. Verify MCP server can start
3. Check PYRO Platform connectivity
4. Verify authentication credentials

### Issue: UI Shows No Data
**Symptom**: Detonator list empty or errors

**Solution**:
1. Check browser console for errors
2. Verify API endpoints accessible
3. Check network tab for failed requests
4. Verify authentication token valid

### Issue: Graph Not Displaying
**Symptom**: Graph area empty

**Solution**:
1. Check detonator execution succeeded
2. Verify results contain nodes/edges
3. Check browser console for Sigma.js errors
4. Verify graph data structure correct

---

## ✅ Success Criteria

### Backend API
- ✅ All endpoints return 200/201 for valid requests
- ✅ Error handling returns appropriate status codes
- ✅ MCP communication works
- ✅ Authentication enforced

### UI
- ✅ Page loads without errors
- ✅ Detonator list displays
- ✅ Detonator execution works
- ✅ Graph visualization displays
- ✅ Controls function correctly

### Integration
- ✅ Complete workflow executes
- ✅ Data flows correctly through chain
- ✅ Error handling works
- ✅ Performance acceptable

---

## 📚 Related Documentation

- [Backend API Integration](BACKEND_API_INTEGRATION.md)
- [UI Integration Guide](UI_INTEGRATION_GUIDE.md)
- [Troubleshooting](pyro-detector/TROUBLESHOOTING.md)

---

🔥 **Testing Guide - PYRO Detector Integration** 🔥

*Complete testing guide for end-to-end integration*

**Status**: Ready for testing

