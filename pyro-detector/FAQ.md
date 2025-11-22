# PYRO Detector - Frequently Asked Questions

🔥 **Common Questions and Answers** 🔥

## General Questions

### Q: What is PYRO Detector?

**A**: PYRO Detector is an MCP (Model Context Protocol) server that acts as a **detonator service** - a 3rd party package that integrates PYRO Platform Ignition with Cursor and other MCP clients. It provides seamless access to Fire Marshal investigations, detonators, agents, and PQL queries.

### Q: Why do I need PYRO Detector?

**A**: PYRO Detector provides:
- Easy integration with Cursor and MCP clients
- Automatic CDIF compliance validation
- Fire Marshal terminology enforcement
- Simplified API access
- Evidence chain management

### Q: Is PYRO Detector required to use PYRO Platform Ignition?

**A**: No. PYRO Detector is optional. You can:
- Use PYRO Detector for MCP client integration (Cursor, etc.)
- Use direct HTTP/REST API for custom integrations
- Use both approaches simultaneously

---

## Installation & Setup

### Q: How do I install PYRO Detector?

**A**: 
```bash
cd pyro-detector
cargo build --release
```

See [QUICK_START.md](QUICK_START.md) for complete instructions.

### Q: What are the system requirements?

**A**:
- Rust 1.70+ installed
- PYRO Platform Ignition API accessible
- Network connectivity
- Valid API credentials

### Q: Do I need to install Rust?

**A**: Yes, if building from source. Install from https://rustup.rs/

### Q: Can I use pre-built binaries?

**A**: Currently, you need to build from source. Pre-built binaries may be available in future releases.

---

## Configuration

### Q: How do I configure PYRO Detector?

**A**: Two methods:
1. **Config file**: `pyro-detector-config.json`
2. **Environment variables**: `PYRO_API_URL`, `PYRO_API_TOKEN`, etc.

See [README.md](README.md#configuration) for details.

### Q: Where should I store my API token?

**A**: 
- ✅ **Good**: Environment variables
- ✅ **Good**: Secret management systems
- ❌ **Bad**: Committed to git
- ❌ **Bad**: In plain text files

### Q: Can I use username/password instead of a token?

**A**: Yes, but tokens are recommended:
```json
{
  "username": "fire.marshal",
  "password": "secure_password"
}
```

---

## Cursor Integration

### Q: How do I add PYRO Detector to Cursor?

**A**: See [CURSOR_SETUP.md](CURSOR_SETUP.md) for complete instructions.

Quick version:
1. Add to Cursor MCP settings
2. Set absolute path to binary
3. Configure environment variables
4. Restart Cursor

### Q: PYRO Detector doesn't appear in Cursor

**A**: Check:
1. Binary path is absolute and correct
2. Binary is executable (`chmod +x`)
3. JSON syntax in MCP config is valid
4. Restart Cursor after changes
5. Check Cursor logs for errors

### Q: Can I use PYRO Detector without Cursor?

**A**: Yes! PYRO Detector works with any MCP client, or you can use it directly via stdio.

---

## CDIF Compliance

### Q: What is CDIF?

**A**: CDIF = **C**ritical **D**igital **I**nvestigation **F**ire Marshal. It's the framework that ensures Fire Marshal Cryptex v2.0 compliance, including proper terminology and evidence chain requirements.

### Q: Why do I get CDIF compliance errors?

**A**: You're using incorrect terminology. Use:
- ✅ "investigation" (not "hunt")
- ✅ "detonator" (not "artifact")
- ✅ "agent" (not "client")
- ✅ "case" (not "session")

### Q: Can I disable CDIF compliance?

**A**: Yes, but not recommended:
```json
{
  "cdif_compliance": false
}
```

**Warning**: This may result in non-compliant evidence.

### Q: What is evidence chain?

**A**: Evidence chain tracks the custody and integrity of evidence, required for court-admissible evidence. It includes:
- Case ID
- Investigator information
- Timestamps
- Quantum verification hashes

---

## API & Methods

### Q: What MCP methods are available?

**A**: 7 methods:
1. `pyro_list_detonators` - List detonators
2. `pyro_execute_detonator` - Execute detonator
3. `pyro_create_case` - Create case
4. `pyro_list_agents` - List agents
5. `pyro_execute_pql` - Execute PQL query
6. `pyro_health` - Health check
7. `pyro_authenticate` - Authenticate

See [API_REFERENCE.md](API_REFERENCE.md) for details.

### Q: How do I execute a detonator?

**A**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_execute_detonator",
  "params": {
    "detonator_id": "DET-RAN-001",
    "case_id": "CASE-FM-2025-001"
  }
}
```

### Q: What is a detonator?

**A**: A detonator is a Fire Marshal investigation module (NOT "artifact"). It's a purpose-built tool for specific investigation types (ransomware, APT, etc.).

### Q: How do I create an investigation case?

**A**:
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_create_case",
  "params": {
    "case_id": "CASE-FM-2025-001",
    "case_name": "My Investigation",
    "investigation_type": "ransomware"
  }
}
```

---

## Troubleshooting

### Q: Connection refused error

**A**: 
1. Verify PYRO Platform is running
2. Check API URL in config
3. Test: `curl http://localhost:3001/api/v2/fire-marshal/admin/health`
4. Check firewall/network

### Q: Authentication failed

**A**:
1. Check token/credentials in config
2. Verify token is valid and not expired
3. Test authentication: `pyro_authenticate` method
4. Regenerate token if needed

### Q: Method not found

**A**:
1. Check method name spelling
2. Ensure JSON-RPC 2.0 format
3. See [API_REFERENCE.md](API_REFERENCE.md) for correct names

### Q: Rate limit exceeded

**A**:
1. Increase `rate_limit_per_minute` in config
2. Reduce request frequency
3. Batch operations when possible

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more.

---

## Performance

### Q: How fast is PYRO Detector?

**A**: PYRO Detector adds minimal overhead (~1-2ms for stdio). Most time is spent in PYRO Platform API calls.

### Q: Can I run multiple instances?

**A**: Yes! Each instance connects independently to PYRO Platform. Useful for:
- Load balancing
- Different environments
- Multiple users

### Q: What are the rate limits?

**A**: Default: 100 requests/minute (configurable). PYRO Platform may have its own limits.

---

## Security

### Q: Is my data secure?

**A**: Yes, if you:
- Use HTTPS for API connections
- Store tokens securely
- Don't commit secrets to git
- Use environment variables
- Rotate tokens regularly

### Q: Does PYRO Detector store credentials?

**A**: No. Credentials are:
- Read from config/env at startup
- Used for authentication
- Not stored persistently
- Not logged (sanitized in errors)

### Q: Can I use it over insecure networks?

**A**: Not recommended. Always use HTTPS in production. For development, HTTP on localhost is acceptable.

---

## Development

### Q: Can I extend PYRO Detector?

**A**: Yes! It's open source. You can:
- Add new MCP methods
- Extend API client
- Add custom features
- Contribute back

### Q: How do I contribute?

**A**:
1. Fork the repository
2. Make changes
3. Test thoroughly
4. Submit pull request

### Q: Where is the source code?

**A**: In `pyro-detector/src/` directory.

---

## PYRO Platform Integration

### Q: What PYRO Platform version do I need?

**A**: PYRO Platform Ignition v6.0.0-alpha or later. Check API compatibility.

### Q: Can I use it with older PYRO versions?

**A**: May work, but not guaranteed. API endpoints may differ.

### Q: How do I know if my PYRO Platform is compatible?

**A**: Test health endpoint:
```bash
curl http://localhost:3001/api/v2/fire-marshal/admin/health
```

---

## Evidence & Compliance

### Q: What is quantum verification?

**A**: Quantum verification uses BLAKE3 + SHA3-256 hashes to ensure evidence integrity, making it resistant to quantum computing attacks.

### Q: Is evidence court-admissible?

**A**: Yes, when:
- Evidence chain is complete
- Quantum verification enabled
- CDIF compliance maintained
- Proper documentation

### Q: How do I ensure evidence is court-admissible?

**A**:
1. Always include `evidence_chain` in requests
2. Enable `quantum_verification: true`
3. Maintain CDIF compliance
4. Document all operations

---

## Best Practices

### Q: What are the best practices?

**A**: See [BEST_PRACTICES.md](BEST_PRACTICES.md) for complete guide. Key points:
- Use environment variables for secrets
- Enable CDIF compliance
- Include evidence chains
- Test before production
- Monitor performance

### Q: How often should I rotate tokens?

**A**: Every 90 days, or immediately if compromised.

### Q: Should I use one token or multiple?

**A**: Use separate tokens for:
- Development
- Staging
- Production
- Different users/teams

---

## Support

### Q: Where can I get help?

**A**:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Review [API_REFERENCE.md](API_REFERENCE.md)
3. See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
4. Check PYRO Platform documentation

### Q: How do I report bugs?

**A**: 
1. Check if it's a known issue
2. Gather error logs
3. Check configuration
4. Report with details

### Q: Is there a community?

**A**: Check PYRO Platform Ignition repository for community resources.

---

## Miscellaneous

### Q: Can I use PYRO Detector with other MCP clients?

**A**: Yes! Any MCP-compatible client can use PYRO Detector.

### Q: Is PYRO Detector open source?

**A**: Yes, Apache 2.0 license.

### Q: Can I use it commercially?

**A**: Yes, but check PYRO Platform Ignition license for platform usage.

### Q: What's the difference between PYRO Detector and direct API?

**A**: See [COMPARISON.md](COMPARISON.md) for detailed comparison.

**Quick answer**: PYRO Detector provides MCP protocol, CDIF compliance, and simplified integration. Direct API gives more control but requires manual CDIF compliance.

---

## Still Have Questions?

1. Check [INDEX.md](INDEX.md) for documentation navigation
2. Review [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
3. See [API_REFERENCE.md](API_REFERENCE.md) for method details
4. Check PYRO Platform Ignition documentation

---

🔥 **Can't find your answer? Check the documentation or create an issue!** 🔥

