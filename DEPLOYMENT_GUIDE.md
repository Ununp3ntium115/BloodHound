# 🚀 Deployment Guide - PYRO Detector Integration

🔥 **Complete Deployment Guide for PYRO Detector** 🔥

---

## 📋 Deployment Overview

This guide covers deploying the complete PYRO Detector integration in production.

---

## 🏗️ Architecture

### Components to Deploy
1. **PYRO Detector MCP Server** (Rust binary)
2. **Backend API** (Go - BloodHound API)
3. **Frontend UI** (React - BloodHound UI)
4. **PYRO Platform Ignition** (External service)

---

## 📦 Deployment Steps

### Step 1: Build PYRO Detector

```bash
cd pyro-detector
cargo build --release

# Verify binary
ls -lh target/release/pyro-detector
```

**Output**: `pyro-detector` binary in `target/release/`

### Step 2: Configure Backend

#### Option A: Configuration File
Edit `bhapi.json`:
```json
{
  "pyro_detector_path": "/opt/bloodhound/pyro-detector",
  "bind_addr": "0.0.0.0:8080"
}
```

#### Option B: Environment Variable
```bash
export BHE_PYRO_DETECTOR_PATH="/opt/bloodhound/pyro-detector"
```

### Step 3: Deploy Binary

#### Linux/Mac
```bash
# Copy binary to deployment location
cp target/release/pyro-detector /opt/bloodhound/
chmod +x /opt/bloodhound/pyro-detector

# Verify
/opt/bloodhound/pyro-detector --version
```

#### Windows
```powershell
# Copy binary to deployment location
Copy-Item target\release\pyro-detector.exe C:\BloodHound\
```

### Step 4: Configure PYRO Detector

Create config file at `pyro-detector-config.json`:
```json
{
  "pyro_api_url": "https://pyro-platform.example.com",
  "api_token": "your-api-token",
  "cdif_compliance": true,
  "log_level": "info"
}
```

### Step 5: Deploy Backend

#### Standard Deployment
```bash
# Build backend (if needed)
# Deploy with existing BloodHound deployment
# Ensure config includes pyro_detector_path
```

#### Docker Deployment
```dockerfile
# Add to Dockerfile
COPY pyro-detector /opt/bloodhound/pyro-detector
RUN chmod +x /opt/bloodhound/pyro-detector
```

### Step 6: Deploy Frontend

#### Standard Deployment
```bash
# Build frontend
cd cmd/ui
yarn build

# Deploy build artifacts
# Frontend already includes PYRO Detector routes
```

#### Docker Deployment
```dockerfile
# Frontend build included in existing deployment
# No additional steps needed
```

---

## 🔧 Configuration

### Backend Configuration

#### Required Settings
```json
{
  "pyro_detector_path": "/path/to/pyro-detector"
}
```

#### Optional Settings
```json
{
  "pyro_detector_path": "/path/to/pyro-detector",
  "pyro_detector_timeout": 30,
  "pyro_detector_retries": 3
}
```

### PYRO Detector Configuration

#### Required Settings
```json
{
  "pyro_api_url": "https://pyro-platform.example.com",
  "api_token": "your-token"
}
```

#### Optional Settings
```json
{
  "pyro_api_url": "https://pyro-platform.example.com",
  "api_token": "your-token",
  "cdif_compliance": true,
  "log_level": "info",
  "timeout": 30
}
```

---

## 🔒 Security Considerations

### Authentication
- ✅ All API endpoints require authentication
- ✅ PYRO Platform API uses JWT tokens
- ✅ Store tokens securely (environment variables, secrets)

### Network Security
- ✅ Use HTTPS for API communication
- ✅ Restrict access to PYRO Detector binary
- ✅ Firewall rules for PYRO Platform access

### File Permissions
```bash
# Restrict binary permissions
chmod 750 /opt/bloodhound/pyro-detector
chown bloodhound:bloodhound /opt/bloodhound/pyro-detector
```

---

## 📊 Monitoring

### Health Checks

#### Backend Health
```bash
curl http://localhost:8080/health
```

#### PYRO Detector Health
```bash
curl http://localhost:8080/api/v2/pyro-detector/health \
  -H "Authorization: Bearer <token>"
```

### Logging

#### Backend Logs
- Check standard BloodHound logs
- Look for PYRO Detector related errors

#### PYRO Detector Logs
- Check `log_level` in config
- Logs output to stderr

### Metrics
- Monitor API endpoint response times
- Track MCP server execution times
- Monitor error rates

---

## 🔄 Updates

### Updating PYRO Detector

1. **Build New Version**
   ```bash
   cd pyro-detector
   cargo build --release
   ```

2. **Backup Current Binary**
   ```bash
   cp /opt/bloodhound/pyro-detector /opt/bloodhound/pyro-detector.backup
   ```

3. **Deploy New Binary**
   ```bash
   cp target/release/pyro-detector /opt/bloodhound/
   chmod +x /opt/bloodhound/pyro-detector
   ```

4. **Restart Backend** (if needed)
   ```bash
   systemctl restart bloodhound-api
   ```

5. **Verify**
   ```bash
   curl http://localhost:8080/api/v2/pyro-detector/health
   ```

---

## 🐛 Troubleshooting

### Issue: Binary Not Found
**Symptom**: Backend can't find PYRO Detector binary

**Solution**:
1. Verify path in configuration
2. Check file permissions
3. Verify binary exists

### Issue: Permission Denied
**Symptom**: Can't execute binary

**Solution**:
```bash
chmod +x /opt/bloodhound/pyro-detector
```

### Issue: PYRO Platform Connection Failed
**Symptom**: API calls to PYRO Platform fail

**Solution**:
1. Verify `pyro_api_url` correct
2. Check network connectivity
3. Verify API token valid
4. Check firewall rules

### Issue: MCP Communication Errors
**Symptom**: Backend can't communicate with MCP server

**Solution**:
1. Test binary directly: `echo '{"jsonrpc":"2.0","id":1,"method":"pyro_health","params":{}}' | ./pyro-detector`
2. Check binary output
3. Verify JSON-RPC format

---

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] PYRO Detector built and tested
- [ ] Configuration files prepared
- [ ] PYRO Platform accessible
- [ ] Network connectivity verified
- [ ] Security settings configured

### Deployment
- [ ] Binary deployed to correct location
- [ ] Permissions set correctly
- [ ] Backend configuration updated
- [ ] Frontend deployed (if needed)
- [ ] Configuration files in place

### Post-Deployment
- [ ] Health checks passing
- [ ] API endpoints responding
- [ ] UI accessible
- [ ] End-to-end test successful
- [ ] Monitoring configured
- [ ] Logging verified

---

## 🎯 Production Best Practices

### Performance
- Use release builds (`cargo build --release`)
- Monitor response times
- Implement caching where appropriate
- Optimize MCP server execution

### Reliability
- Implement retry logic
- Add circuit breakers
- Monitor error rates
- Set up alerts

### Security
- Use HTTPS everywhere
- Store secrets securely
- Implement rate limiting
- Regular security updates

### Monitoring
- Log all API calls
- Track performance metrics
- Monitor error rates
- Set up alerts

---

## 📚 Related Documentation

- [PYRO Detector Deployment](pyro-detector/DEPLOYMENT.md)
- [Testing Guide](TESTING_GUIDE.md)
- [Troubleshooting](pyro-detector/TROUBLESHOOTING.md)

---

🔥 **Deployment Guide - PYRO Detector Integration** 🔥

*Complete deployment guide for production*

**Status**: Ready for deployment

