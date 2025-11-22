# PYRO Detector - Best Practices

🔥 **Recommended Practices for Optimal Usage** 🔥

## Configuration Best Practices

### 1. Use Environment Variables for Secrets

✅ **Good**:
```bash
export PYRO_API_TOKEN="your-secret-token"
```

❌ **Bad**:
```json
{
  "api_token": "your-secret-token"  // In committed file
}
```

### 2. Use Config Files for Non-Secrets

✅ **Good**:
```json
{
  "pyro_api_url": "http://localhost:3001",
  "timeout_seconds": 30,
  "cdif_compliance": true
}
```

### 3. Separate Configs by Environment

✅ **Good**:
- `pyro-detector-config.dev.json`
- `pyro-detector-config.prod.json`
- `pyro-detector-config.staging.json`

## Authentication Best Practices

### 1. Use JWT Tokens (Not Username/Password)

✅ **Good**:
```json
{
  "api_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

⚠️ **Acceptable** (for development only):
```json
{
  "username": "fire.marshal",
  "password": "secure_password"
}
```

### 2. Rotate Tokens Regularly

- Set token expiration reminders
- Rotate every 90 days
- Revoke old tokens

### 3. Use Least-Privilege Tokens

- Only grant necessary permissions
- Use read-only tokens when possible
- Separate tokens per environment

## CDIF Compliance Best Practices

### 1. Always Use Correct Terminology

✅ **Correct**:
- "investigation"
- "detonator"
- "agent"
- "case"
- "collection"

❌ **Incorrect**:
- "hunt"
- "artifact"
- "client"
- "session"
- "execution"

### 2. Include Evidence Chain

✅ **Always include**:
```json
{
  "evidence_chain": {
    "case_id": "CASE-FM-2025-001",
    "quantum_verification": true
  }
}
```

### 3. Enable CDIF Compliance

✅ **Always enable**:
```json
{
  "cdif_compliance": true,
  "fire_marshal_terminology": true
}
```

## Error Handling Best Practices

### 1. Always Check for Errors

✅ **Good**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "code": "ERROR_CODE",
    "message": "Error message"
  }
}
```

### 2. Handle CDIF Compliance Errors

✅ **Check for**:
- `CDIF_COMPLIANCE_ERROR`
- Terminology violations
- Missing evidence chain

### 3. Implement Retry Logic

✅ **For transient errors**:
- Network errors
- Timeout errors
- Rate limit errors

❌ **Don't retry**:
- Authentication errors
- Invalid parameter errors
- CDIF compliance errors

## Performance Best Practices

### 1. Set Appropriate Timeouts

✅ **Good**:
```json
{
  "timeout_seconds": 30  // For most operations
}
```

For long-running queries:
```json
{
  "timeout_seconds": 300  // For PQL queries
}
```

### 2. Use Rate Limiting

✅ **Configure appropriately**:
```json
{
  "rate_limit_per_minute": 100  // Standard
}
```

### 3. Batch Operations When Possible

✅ **Batch detonator execution**:
- Execute multiple detonators together
- Use case IDs to group operations
- Reduce API calls

## Security Best Practices

### 1. Never Commit Secrets

✅ **Use .gitignore**:
```
pyro-detector-config.json
*.token
*.secret
```

### 2. Use Secure Storage

✅ **For production**:
- Secret management systems
- Encrypted configuration
- Environment variables

### 3. Enable Logging Carefully

✅ **Good**:
```bash
export PYRO_LOG_LEVEL=INFO  # Production
```

⚠️ **Development only**:
```bash
export PYRO_LOG_LEVEL=DEBUG  # May log sensitive data
```

### 4. Sanitize Error Messages

✅ **Automatic in PYRO Detector**:
- Passwords masked
- Tokens masked
- Secrets hidden

## Code Organization Best Practices

### 1. Use Examples as Templates

✅ **Start with**:
- `examples/basic-usage.sh`
- `examples/investigation-workflow.sh`

### 2. Follow API Reference

✅ **Always check**:
- `API_REFERENCE.md` for method details
- Parameter requirements
- Response formats

### 3. Test Before Production

✅ **Always test**:
```bash
./test-connection.sh  # Before deploying
```

## Workflow Best Practices

### 1. Create Cases First

✅ **Workflow**:
1. Create investigation case
2. List available detonators
3. Execute detonators
4. Collect evidence
5. Generate reports

### 2. Use Case IDs Consistently

✅ **Good**:
```json
{
  "case_id": "CASE-FM-2025-001",
  "evidence_chain": {
    "case_id": "CASE-FM-2025-001"
  }
}
```

### 3. Track Evidence Chain

✅ **Always include**:
- Case ID
- Investigator
- Timestamp
- Location
- Quantum verification

## Integration Best Practices

### 1. Test Integration First

✅ **Before production**:
- Test all methods
- Verify authentication
- Check error handling
- Validate CDIF compliance

### 2. Monitor Performance

✅ **Track**:
- Response times
- Error rates
- Rate limit usage
- Authentication failures

### 3. Handle Updates Gracefully

✅ **When PYRO Platform updates**:
- Test compatibility
- Update configuration if needed
- Verify all methods still work
- Check for new features

## Documentation Best Practices

### 1. Document Your Configuration

✅ **Keep notes on**:
- API URLs per environment
- Token rotation schedule
- Custom configurations
- Integration points

### 2. Document Workflows

✅ **Record**:
- Common investigation workflows
- Detonator execution patterns
- Error handling procedures
- Troubleshooting steps

## Troubleshooting Best Practices

### 1. Enable Debug Logging

✅ **For debugging**:
```bash
export PYRO_LOG_LEVEL=DEBUG
```

### 2. Test Components Individually

✅ **Isolate issues**:
- Test API connectivity
- Test authentication
- Test each method separately
- Check configuration

### 3. Check Documentation

✅ **Always consult**:
- `TROUBLESHOOTING.md`
- `API_REFERENCE.md`
- `INTEGRATION_GUIDE.md`

## Production Deployment Best Practices

### 1. Use Production Configuration

✅ **Separate configs**:
- Development
- Staging
- Production

### 2. Implement Monitoring

✅ **Monitor**:
- Server health
- API connectivity
- Error rates
- Performance metrics

### 3. Set Up Alerts

✅ **Alert on**:
- Authentication failures
- High error rates
- API connectivity issues
- Performance degradation

### 4. Regular Maintenance

✅ **Schedule**:
- Token rotation
- Configuration review
- Security updates
- Performance optimization

## Summary

### ✅ Do:
- Use environment variables for secrets
- Enable CDIF compliance
- Include evidence chains
- Test before production
- Monitor performance
- Document workflows
- Use correct terminology
- Handle errors properly

### ❌ Don't:
- Commit secrets
- Disable CDIF compliance
- Skip evidence chains
- Ignore errors
- Use wrong terminology
- Skip testing
- Deploy without monitoring

---

🔥 **Follow these practices for optimal PYRO Detector usage!** 🔥

