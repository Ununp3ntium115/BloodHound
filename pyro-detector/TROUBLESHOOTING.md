# PYRO Detector - Troubleshooting Guide

🔥 **Common Issues and Solutions** 🔥

## Quick Diagnostics

### Test 1: Binary Exists
```bash
ls -la target/release/pyro-detector  # Linux/Mac
dir target\release\pyro-detector.exe  # Windows
```

### Test 2: Configuration Valid
```bash
cat pyro-detector-config.json | jq .  # Linux/Mac
Get-Content pyro-detector-config.json | ConvertFrom-Json  # Windows
```

### Test 3: API Connectivity
```bash
curl http://localhost:3001/api/v2/fire-marshal/admin/health
```

### Test 4: Authentication
```bash
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_authenticate",
  "params": {}
}' | ./target/release/pyro-detector
```

---

## Common Issues

### Issue 1: "Binary not found"

**Symptoms**:
- Error: `pyro-detector: command not found`
- Error: `The system cannot find the file specified`

**Solutions**:
1. Build the project:
   ```bash
   cargo build --release
   ```

2. Use full path:
   ```bash
   /absolute/path/to/pyro-detector/target/release/pyro-detector
   ```

3. Add to PATH:
   ```bash
   export PATH=$PATH:/path/to/pyro-detector/target/release
   ```

---

### Issue 2: "Connection refused" or "Network error"

**Symptoms**:
- Error: `Failed to connect to PYRO Platform`
- Error: `Connection refused`
- Error: `Network error`

**Solutions**:
1. Verify PYRO Platform is running:
   ```bash
   curl http://localhost:3001/api/v2/fire-marshal/admin/health
   ```

2. Check API URL in config:
   ```json
   {
     "pyro_api_url": "http://localhost:3001"
   }
   ```

3. Check firewall/network:
   - Ensure port 3001 is accessible
   - Check firewall rules
   - Verify network connectivity

4. Try different URL:
   - `http://localhost:3001`
   - `http://127.0.0.1:3001`
   - `https://api.pyro-fire-marshal.com` (production)

---

### Issue 3: "Authentication failed"

**Symptoms**:
- Error: `Authentication failed`
- Error: `Unauthorized`
- Error: `Invalid credentials`

**Solutions**:
1. Check credentials in config:
   ```json
   {
     "api_token": "your-token-here"
   }
   ```
   OR
   ```json
   {
     "username": "fire.marshal",
     "password": "secure_password"
   }
   ```

2. Verify token is valid:
   ```bash
   curl -H "Authorization: Bearer YOUR_TOKEN" \
        http://localhost:3001/api/v2/fire-marshal/admin/health
   ```

3. Get new token:
   - Login to PYRO Platform
   - Generate new API token
   - Update configuration

4. Check token expiration:
   - Tokens may expire
   - Regenerate if expired

---

### Issue 4: "CDIF compliance error"

**Symptoms**:
- Error: `CDIF_COMPLIANCE_ERROR`
- Error: `Invalid terminology: 'hunt'`
- Error: `Missing evidence_chain`

**Solutions**:
1. Use correct terminology:
   - ✅ "investigation" (NOT "hunt")
   - ✅ "detonator" (NOT "artifact")
   - ✅ "agent" (NOT "client")

2. Include evidence_chain:
   ```json
   {
     "evidence_chain": {
       "case_id": "CASE-FM-2025-001",
       "quantum_verification": true
     }
   }
   ```

3. Disable CDIF compliance (not recommended):
   ```json
   {
     "cdif_compliance": false
   }
   ```

---

### Issue 5: "Method not found"

**Symptoms**:
- Error: `METHOD_NOT_FOUND`
- Error: `Unknown method: xyz`

**Solutions**:
1. Check method name spelling:
   - `pyro_list_detonators` (not `list_detonators`)
   - `pyro_execute_detonator` (not `execute_detonator`)

2. Verify JSON-RPC format:
   ```json
   {
     "jsonrpc": "2.0",
     "id": 1,
     "method": "pyro_list_detonators",
     "params": {}
   }
   ```

3. Check available methods:
   - See `API_REFERENCE.md` for complete list

---

### Issue 6: "Invalid params"

**Symptoms**:
- Error: `INVALID_PARAMS`
- Error: `Missing required parameter`

**Solutions**:
1. Check required parameters:
   - See `API_REFERENCE.md` for each method
   - Ensure all required params are present

2. Verify parameter types:
   - Strings should be quoted
   - Numbers should not be quoted
   - Objects should be valid JSON

3. Example fix:
   ```json
   {
     "detonator_id": "DET-RAN-001",  // ✅ Correct
     "case_id": "CASE-FM-2025-001"   // ✅ Correct
   }
   ```

---

### Issue 7: "Rate limit exceeded"

**Symptoms**:
- Error: `Rate limit exceeded`
- Error: `Too many requests`

**Solutions**:
1. Increase rate limit in config:
   ```json
   {
     "rate_limit_per_minute": 200
   }
   ```

2. Reduce request frequency:
   - Add delays between requests
   - Batch operations when possible

3. Check PYRO Platform limits:
   - Platform may have its own limits
   - Contact platform administrator

---

### Issue 8: "Timeout error"

**Symptoms**:
- Error: `Request timeout`
- Error: `Operation timed out`

**Solutions**:
1. Increase timeout in config:
   ```json
   {
     "timeout_seconds": 60
   }
   ```

2. Check network latency:
   ```bash
   ping api.pyro-fire-marshal.com
   ```

3. Optimize queries:
   - Reduce query complexity
   - Limit result sets
   - Use appropriate timeouts per operation

---

### Issue 9: "Cursor not detecting server"

**Symptoms**:
- Server not appearing in Cursor
- MCP connection failed

**Solutions**:
1. Verify binary path is absolute:
   ```json
   {
     "command": "/absolute/path/to/pyro-detector"
   }
   ```

2. Check file permissions:
   ```bash
   chmod +x target/release/pyro-detector
   ```

3. Verify Cursor MCP config:
   - Check JSON syntax
   - Ensure proper nesting
   - Restart Cursor after changes

4. Check Cursor logs:
   - Look for MCP errors
   - Verify server startup

---

### Issue 10: "Build errors"

**Symptoms**:
- `cargo build` fails
- Compilation errors

**Solutions**:
1. Update Rust:
   ```bash
   rustup update
   ```

2. Clean and rebuild:
   ```bash
   cargo clean
   cargo build --release
   ```

3. Check Rust version:
   ```bash
   rustc --version  # Should be 1.70+
   ```

4. Check workspace:
   - Ensure in correct directory
   - Verify `Cargo.toml` is valid

---

## Debug Mode

Enable debug logging:

```bash
export PYRO_LOG_LEVEL=DEBUG
./target/release/pyro-detector
```

Log levels:
- `ERROR` - Errors only
- `WARN` - Warnings and errors
- `INFO` - Informational messages (default)
- `DEBUG` - Debug information
- `TRACE` - Detailed tracing

---

## Diagnostic Commands

### Full Diagnostic
```bash
# 1. Check binary
ls -la target/release/pyro-detector

# 2. Check config
cat pyro-detector-config.json | jq .

# 3. Test API
curl http://localhost:3001/api/v2/fire-marshal/admin/health

# 4. Test authentication
echo '{"jsonrpc":"2.0","id":1,"method":"pyro_authenticate","params":{}}' | \
  ./target/release/pyro-detector

# 5. Test health
echo '{"jsonrpc":"2.0","id":2,"method":"pyro_health","params":{}}' | \
  ./target/release/pyro-detector
```

### Windows Diagnostic
```powershell
# 1. Check binary
Test-Path target\release\pyro-detector.exe

# 2. Check config
Get-Content pyro-detector-config.json | ConvertFrom-Json

# 3. Test API
Invoke-WebRequest -Uri http://localhost:3001/api/v2/fire-marshal/admin/health

# 4. Test authentication
$request = @{jsonrpc="2.0";id=1;method="pyro_authenticate";params=@{}} | ConvertTo-Json
$request | .\target\release\pyro-detector.exe
```

---

## Getting Help

### Check Logs
```bash
# Enable debug logging
export PYRO_LOG_LEVEL=DEBUG

# Run and capture output
./target/release/pyro-detector 2>&1 | tee debug.log
```

### Verify Configuration
```bash
# Validate JSON
cat pyro-detector-config.json | jq .

# Check environment
env | grep PYRO
```

### Test Individual Components
```bash
# Test API client only
cargo test --package pyro-detector

# Test specific method
echo '{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}' | \
  ./target/release/pyro-detector
```

---

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| `Connection refused` | PYRO Platform not running | Start PYRO Platform |
| `Authentication failed` | Invalid credentials | Check token/username/password |
| `CDIF_COMPLIANCE_ERROR` | Wrong terminology | Use Fire Marshal terms |
| `METHOD_NOT_FOUND` | Invalid method name | Check method spelling |
| `INVALID_PARAMS` | Missing/incorrect params | Check API reference |
| `Rate limit exceeded` | Too many requests | Reduce frequency or increase limit |
| `Timeout` | Request took too long | Increase timeout or optimize |

---

## Prevention Tips

1. **Always test connection** before using in production
2. **Use environment variables** for sensitive data
3. **Enable logging** for debugging
4. **Check API status** regularly
5. **Rotate tokens** periodically
6. **Monitor rate limits** to avoid issues
7. **Keep documentation** handy for reference
8. **Test after updates** to PYRO Platform

---

## Still Having Issues?

1. **Check Documentation**:
   - `API_REFERENCE.md` - Method details
   - `INTEGRATION_GUIDE.md` - Integration help
   - `README.md` - General documentation

2. **Review Examples**:
   - `examples/basic-usage.sh` - Basic examples
   - `examples/investigation-workflow.sh` - Workflow

3. **Enable Debug Logging**:
   ```bash
   export PYRO_LOG_LEVEL=DEBUG
   ```

4. **Check PYRO Platform**:
   - Verify platform is running
   - Check platform logs
   - Verify API version compatibility

---

🔥 **Most issues are configuration-related. Double-check your settings!** 🔥

