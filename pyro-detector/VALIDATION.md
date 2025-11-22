# PYRO Detector - Validation & Testing Guide

🔥 **How to Validate Your Installation** 🔥

## Pre-Flight Checklist

Before using PYRO Detector, validate:

- [ ] PYRO Platform Ignition is running
- [ ] API is accessible
- [ ] Authentication credentials are valid
- [ ] Configuration is correct
- [ ] Binary is built and executable

## Validation Steps

### Step 1: Build Validation

```bash
cd pyro-detector
cargo build --release
```

**Expected**: Build completes without errors

**If errors**: See [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

### Step 2: Configuration Validation

```bash
# Linux/Mac
cat pyro-detector-config.json | jq .

# Windows
Get-Content pyro-detector-config.json | ConvertFrom-Json
```

**Expected**: Valid JSON with required fields

**Required fields**:
- `pyro_api_url`
- `api_token` OR (`username` AND `password`)

---

### Step 3: API Connectivity

```bash
# Test PYRO Platform API
curl http://localhost:3001/api/v2/fire-marshal/admin/health
```

**Expected**: JSON response with health status

**If fails**: 
- Check PYRO Platform is running
- Verify API URL
- Check network connectivity

---

### Step 4: Authentication Validation

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_authenticate",
  "params": {}
}' | ./target/release/pyro-detector
```

**Expected**: 
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "token": "eyJ0eXAi...",
    "success": true
  }
}
```

**If fails**: Check credentials in config

---

### Step 5: Health Check

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector
```

**Expected**: Health status response

---

### Step 6: Method Validation

Test each method:

#### List Detonators
```bash
echo '{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "pyro_list_detonators",
  "params": {}
}' | ./target/release/pyro-detector
```

#### List Agents
```bash
echo '{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "pyro_list_agents",
  "params": {}
}' | ./target/release/pyro-detector
```

---

## Automated Validation

### Run All Tests

```bash
# Linux/Mac
./test-connection.sh

# Windows
.\test-connection.ps1
```

### Expected Output

All tests should pass:
- ✅ Health check
- ✅ Authentication
- ✅ List detonators
- ✅ List agents

---

## CDIF Compliance Validation

### Test Terminology

```bash
# This should FAIL (wrong terminology)
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_execute_detonator",
  "params": {
    "artifact_id": "DET-001"  # Wrong: should be "detonator_id"
  }
}' | ./target/release/pyro-detector
```

**Expected**: CDIF compliance error

### Test Evidence Chain

```bash
# This should FAIL (missing evidence_chain)
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_execute_detonator",
  "params": {
    "detonator_id": "DET-001"
  }
}' | ./target/release/pyro-detector
```

**Expected**: CDIF compliance error (if enabled)

---

## Performance Validation

### Response Time Test

```bash
time echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector
```

**Expected**: < 100ms for local operations

### Concurrent Request Test

```bash
# Test multiple concurrent requests
for i in {1..10}; do
  echo '{"jsonrpc":"2.0","id":'$i',"method":"pyro_health","params":{}}' | \
    ./target/release/pyro-detector &
done
wait
```

**Expected**: All requests complete successfully

---

## Integration Validation

### Cursor Integration

1. Add to Cursor MCP config
2. Restart Cursor
3. Test in Cursor chat:
   ```
   @pyro-detector health
   ```

**Expected**: Health status response

### MCP Protocol Validation

```bash
# Test JSON-RPC 2.0 format
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector | jq '.jsonrpc'
```

**Expected**: `"2.0"`

---

## Error Handling Validation

### Test Invalid Method

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "invalid_method",
  "params": {}
}' | ./target/release/pyro-detector
```

**Expected**: Error response with `METHOD_NOT_FOUND`

### Test Invalid Params

```bash
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_execute_detonator",
  "params": {
    "invalid_param": "value"
  }
}' | ./target/release/pyro-detector
```

**Expected**: Error response with details

---

## Security Validation

### Test Token Masking

```bash
# Enable debug logging
export PYRO_LOG_LEVEL=DEBUG

# Trigger error (should mask token)
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | ./target/release/pyro-detector 2>&1 | grep -i token
```

**Expected**: No actual tokens in output

### Test Config Security

```bash
# Verify secrets not in committed files
git grep -i "password\|token\|secret" pyro-detector-config.json
```

**Expected**: No matches (if using example config)

---

## Production Readiness Validation

### Checklist

- [ ] All tests pass
- [ ] Configuration validated
- [ ] Authentication working
- [ ] CDIF compliance enabled
- [ ] Logging configured
- [ ] Monitoring set up
- [ ] Error handling tested
- [ ] Performance acceptable
- [ ] Security reviewed
- [ ] Documentation reviewed

---

## Validation Script

Create `validate.sh`:

```bash
#!/bin/bash
set -e

echo "🔥 PYRO Detector Validation"
echo "============================"

# Build
echo "1. Building..."
cargo build --release || exit 1

# Config
echo "2. Validating config..."
jq . pyro-detector-config.json > /dev/null || exit 1

# API
echo "3. Testing API..."
curl -s http://localhost:3001/api/v2/fire-marshal/admin/health > /dev/null || exit 1

# Auth
echo "4. Testing authentication..."
echo '{"jsonrpc":"2.0","id":1,"method":"pyro_authenticate","params":{}}' | \
  ./target/release/pyro-detector | jq -e '.result.success' > /dev/null || exit 1

# Health
echo "5. Testing health..."
echo '{"jsonrpc":"2.0","id":2,"method":"pyro_health","params":{}}' | \
  ./target/release/pyro-detector | jq -e '.result.success' > /dev/null || exit 1

echo "✅ All validations passed!"
```

---

## Continuous Validation

### Pre-Commit Hook

Add to `.git/hooks/pre-commit`:

```bash
#!/bin/bash
cd pyro-detector
cargo check || exit 1
cargo test || exit 1
```

### CI/CD Validation

```yaml
# .github/workflows/validate.yml
name: Validate
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/cargo@v1
        with:
          command: check
          args: --package pyro-detector
```

---

## Validation Results

### Success Criteria

✅ **All tests pass**  
✅ **No errors in logs**  
✅ **CDIF compliance working**  
✅ **Performance acceptable**  
✅ **Security validated**  
✅ **Documentation complete**  

### If Validation Fails

1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review error messages
3. Check configuration
4. Verify PYRO Platform status
5. Enable debug logging

---

🔥 **Validate before deploying to production!** 🔥

