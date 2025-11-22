# 🚀 Quick Start - PYRO Detector Integration

🔥 **Get Started in 5 Minutes** 🔥

---

## ✅ Everything is Ready!

The complete integration is in place. Follow these steps to get started.

---

## 📋 Quick Start Steps

### Step 1: Build PYRO Detector (2 minutes)
```bash
cd pyro-detector
cargo build --release
```

**Verify**: Check `target/release/pyro-detector` exists

### Step 2: Configure Backend (1 minute)
Edit `bhapi.json`:
```json
{
  "pyro_detector_path": "./target/release/pyro-detector"
}
```

### Step 3: Start Backend (1 minute)
```bash
# Start your BloodHound backend
# It will automatically use PYRO Detector
```

### Step 4: Access UI (30 seconds)
Navigate to: `http://localhost:8080/ui/pyro-detector`

Or click "PYRO Detector" in the navigation menu.

### Step 5: Use It! (30 seconds)
1. Browse detonators in left panel
2. Click detonator to execute
3. View results in network graph
4. Use investigation controls

---

## 🎯 What You Get

### UI Features
- ✅ Network graph visualization (Zenmap-like)
- ✅ Detonator list and execution
- ✅ Investigation case management
- ✅ Agent coordination
- ✅ PQL query execution
- ✅ Real-time status display

### API Features
- ✅ 6 REST API endpoints
- ✅ Complete authentication
- ✅ Error handling
- ✅ MCP server integration

### MCP Server Features
- ✅ 7 MCP methods
- ✅ CDIF compliance (100%)
- ✅ PYRO Platform integration
- ✅ Production ready

---

## 📚 Documentation

### Start Here
- **[Master Summary](MASTER_SUMMARY.md)** - Complete overview
- **[PYRO Detector README](pyro-detector/README_START_HERE.md)** - MCP server docs

### Guides
- **[Testing Guide](TESTING_GUIDE.md)** - How to test
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)** - Production deployment
- **[Usage Examples](USAGE_EXAMPLES.md)** - Practical examples

### Integration
- **[Complete Integration Summary](COMPLETE_INTEGRATION_SUMMARY.md)** - Full details
- **[Backend API Integration](BACKEND_API_INTEGRATION.md)** - Backend docs
- **[UI Integration Guide](UI_INTEGRATION_GUIDE.md)** - Frontend docs

---

## 🔧 Configuration

### Minimal Configuration
```json
{
  "pyro_detector_path": "./target/release/pyro-detector"
}
```

### Full Configuration
```json
{
  "pyro_detector_path": "./target/release/pyro-detector",
  "pyro_api_url": "http://localhost:3001",
  "api_token": "your-token",
  "cdif_compliance": true
}
```

---

## ✅ Verification

### Quick Check
```bash
# Check binary exists
ls target/release/pyro-detector

# Check backend config
grep pyro_detector_path bhapi.json

# Check UI route
grep PYRO_DETECTOR cmd/ui/src/routes/constants.ts
```

### Health Check
```bash
curl http://localhost:8080/api/v2/pyro-detector/health \
  -H "Authorization: Bearer <token>"
```

---

## 🎉 You're Ready!

Everything is integrated and ready to use. Start investigating! 🔥

---

🔥 **Quick Start - PYRO Detector Integration** 🔥

*Get started in 5 minutes*

**Status**: ✅ **READY**

