# PYRO Detector - Deployment Guide

🔥 **Production Deployment Guide** 🔥

## Overview

This guide covers deploying PYRO Detector MCP Server in production environments.

## Prerequisites

- Rust 1.70+ installed
- PYRO Platform Ignition API accessible
- Valid API credentials
- Network connectivity to PYRO Platform

## Build for Production

### Standard Build

```bash
cd pyro-detector
cargo build --release
```

### Optimized Build

```bash
# Set optimization flags
export RUSTFLAGS="-C target-cpu=native"
cargo build --release --features "optimize"
```

### Cross-Platform Build

```bash
# Linux
cargo build --release --target x86_64-unknown-linux-gnu

# Windows
cargo build --release --target x86_64-pc-windows-msvc

# macOS
cargo build --release --target x86_64-apple-darwin
```

## Configuration

### Production Configuration

Create `pyro-detector-config.json`:

```json
{
  "pyro_api_url": "https://api.pyro-fire-marshal.com",
  "api_token": "production-jwt-token",
  "timeout_seconds": 60,
  "rate_limit_per_minute": 100,
  "cdif_compliance": true,
  "fire_marshal_terminology": true
}
```

### Environment Variables

```bash
export PYRO_API_URL="https://api.pyro-fire-marshal.com"
export PYRO_API_TOKEN="production-token"
export PYRO_TIMEOUT_SECONDS="60"
export PYRO_RATE_LIMIT="100"
export PYRO_CDIF_COMPLIANCE="true"
export PYRO_LOG_LEVEL="INFO"
```

### Security Best Practices

1. **Never commit credentials**:
   - Add `pyro-detector-config.json` to `.gitignore`
   - Use environment variables in production
   - Rotate tokens regularly

2. **Use secure storage**:
   - Store tokens in secret management systems
   - Use encrypted configuration files
   - Implement token rotation

3. **Network security**:
   - Use HTTPS for API connections
   - Implement network isolation
   - Use VPN or private networks

## Deployment Methods

### Method 1: Direct Binary

1. Build binary:
   ```bash
   cargo build --release
   ```

2. Copy to deployment location:
   ```bash
   cp target/release/pyro-detector /usr/local/bin/
   ```

3. Set permissions:
   ```bash
   chmod +x /usr/local/bin/pyro-detector
   ```

4. Configure:
   ```bash
   cp pyro-detector-config.json /etc/pyro-detector/config.json
   ```

### Method 2: Systemd Service (Linux)

Create `/etc/systemd/system/pyro-detector.service`:

```ini
[Unit]
Description=PYRO Detector MCP Server
After=network.target

[Service]
Type=simple
User=pyro
WorkingDirectory=/opt/pyro-detector
ExecStart=/usr/local/bin/pyro-detector
Restart=always
RestartSec=10
Environment="PYRO_API_URL=https://api.pyro-fire-marshal.com"
Environment="PYRO_API_TOKEN=your-token"
Environment="PYRO_LOG_LEVEL=INFO"

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable pyro-detector
sudo systemctl start pyro-detector
sudo systemctl status pyro-detector
```

### Method 3: Docker Container

Create `Dockerfile`:

```dockerfile
FROM rust:1.70 as builder
WORKDIR /app
COPY . .
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/pyro-detector /usr/local/bin/pyro-detector
ENTRYPOINT ["/usr/local/bin/pyro-detector"]
```

Build and run:
```bash
docker build -t pyro-detector .
docker run -e PYRO_API_URL=https://api.pyro-fire-marshal.com \
           -e PYRO_API_TOKEN=your-token \
           pyro-detector
```

### Method 4: Kubernetes Deployment

Create `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pyro-detector
spec:
  replicas: 2
  selector:
    matchLabels:
      app: pyro-detector
  template:
    metadata:
      labels:
        app: pyro-detector
    spec:
      containers:
      - name: pyro-detector
        image: pyro-detector:latest
        env:
        - name: PYRO_API_URL
          valueFrom:
            configMapKeyRef:
              name: pyro-config
              key: api_url
        - name: PYRO_API_TOKEN
          valueFrom:
            secretKeyRef:
              name: pyro-secrets
              key: api_token
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "500m"
```

## Monitoring

### Health Checks

```bash
# Check if server is running
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_health",
  "params": {}
}' | pyro-detector
```

### Logging

Set log level via environment:
```bash
export PYRO_LOG_LEVEL=DEBUG  # ERROR, WARN, INFO, DEBUG, TRACE
```

Logs are written to stderr.

### Metrics

Monitor:
- Request count
- Response times
- Error rates
- Authentication failures
- CDIF compliance violations

## Scaling

### Horizontal Scaling

Run multiple instances:
- Each instance connects to same PYRO Platform
- Load balance MCP requests
- Use shared configuration

### Vertical Scaling

Increase resources:
- More memory for concurrent requests
- More CPU for processing
- Adjust rate limits

## Troubleshooting

### Connection Issues

```bash
# Test API connectivity
curl https://api.pyro-fire-marshal.com/api/v2/fire-marshal/admin/health
```

### Authentication Issues

```bash
# Test authentication
echo '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "pyro_authenticate",
  "params": {}
}' | pyro-detector
```

### Performance Issues

1. Check rate limits
2. Monitor API response times
3. Review log levels
4. Check network latency

## Backup and Recovery

### Configuration Backup

```bash
# Backup configuration
cp pyro-detector-config.json pyro-detector-config.json.backup
```

### Recovery

1. Restore configuration
2. Verify API connectivity
3. Test authentication
4. Restart service

## Updates

### Update Process

1. Build new version:
   ```bash
   cargo build --release
   ```

2. Backup current version:
   ```bash
   cp target/release/pyro-detector target/release/pyro-detector.backup
   ```

3. Deploy new version:
   ```bash
   cp target/release/pyro-detector /usr/local/bin/
   ```

4. Restart service:
   ```bash
   sudo systemctl restart pyro-detector
   ```

5. Verify:
   ```bash
   sudo systemctl status pyro-detector
   ```

## Security Checklist

- [ ] API tokens stored securely
- [ ] HTTPS enabled for API connections
- [ ] Network isolation configured
- [ ] Logs don't contain sensitive data
- [ ] Rate limiting configured
- [ ] Authentication working
- [ ] CDIF compliance enabled
- [ ] Fire Marshal terminology enforced
- [ ] Regular security updates
- [ ] Monitoring and alerting configured

## Support

For deployment issues:
1. Check logs: `journalctl -u pyro-detector`
2. Verify configuration
3. Test API connectivity
4. Review error messages
5. Check PYRO Platform status

---

🔥 **PYRO Detector - Production Ready** 🔥

