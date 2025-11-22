# PYRO Detector - Signed Executable Build Guide

## Overview

This guide covers the process for building a code-signed executable for the PYRO Detector MCP server.

## Prerequisites

### Windows Code Signing

1. **Code Signing Certificate**
   - Obtain a code signing certificate from a trusted Certificate Authority (CA)
   - Options: DigiCert, Sectigo, GlobalSign, etc.
   - Certificate must support code signing (not just SSL/TLS)

2. **Tools Required**
   - `signtool.exe` (Windows SDK)
   - `osslsigncode` (for cross-platform signing)
   - Rust toolchain with Windows target

### Linux/macOS Code Signing

1. **macOS**
   - Apple Developer Certificate
   - `codesign` tool (built-in)

2. **Linux**
   - GPG signing for packages
   - `osslsigncode` for Windows executables

## Build Process

### 1. Build Release Binary

```bash
cd pyro-detector
cargo build --release --target x86_64-pc-windows-msvc
```

For other targets:
```bash
# Linux
cargo build --release --target x86_64-unknown-linux-gnu

# macOS
cargo build --release --target x86_64-apple-darwin
```

### 2. Windows Code Signing

#### Using signtool.exe

```powershell
# Sign the executable
signtool.exe sign /f "path\to\certificate.pfx" /p "certificate_password" /t http://timestamp.digicert.com /d "PYRO Detector" /du "https://pyro-platform.com" target\release\pyro-detector.exe

# Verify signature
signtool.exe verify /pa /v target\release\pyro-detector.exe
```

#### Using osslsigncode (Cross-platform)

```bash
# Sign executable
osslsigncode sign -certs certificate.pem -key private_key.pem -n "PYRO Detector" -i "https://pyro-platform.com" -t http://timestamp.digicert.com -in target/release/pyro-detector.exe -out target/release/pyro-detector-signed.exe

# Verify signature
osslsigncode verify target/release/pyro-detector-signed.exe
```

### 3. macOS Code Signing

```bash
# Sign the binary
codesign --sign "Developer ID Application: Your Name" --timestamp --options runtime target/release/pyro-detector

# Verify signature
codesign --verify --verbose target/release/pyro-detector
```

### 4. Linux Package Signing

```bash
# Create GPG signature
gpg --armor --detach-sign --output pyro-detector.sig target/release/pyro-detector

# Verify signature
gpg --verify pyro-detector.sig target/release/pyro-detector
```

## Automated Build Script

### Windows (PowerShell)

```powershell
# build-signed.ps1
$ErrorActionPreference = "Stop"

Write-Output "Building PYRO Detector release binary..."
cargo build --release --target x86_64-pc-windows-msvc

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

Write-Output "Signing executable..."
$CertPath = $env:CODE_SIGN_CERT
$CertPassword = $env:CODE_SIGN_PASSWORD

if (-not $CertPath -or -not $CertPassword) {
    Write-Warning "Code signing certificate not configured. Skipping signing."
    exit 0
}

signtool.exe sign /f $CertPath /p $CertPassword /t http://timestamp.digicert.com /d "PYRO Detector" /du "https://pyro-platform.com" target\x86_64-pc-windows-msvc\release\pyro-detector.exe

if ($LASTEXITCODE -eq 0) {
    Write-Output "✅ Executable signed successfully"
    signtool.exe verify /pa /v target\x86_64-pc-windows-msvc\release\pyro-detector.exe
} else {
    Write-Error "Code signing failed"
    exit 1
}
```

### Linux/macOS (Bash)

```bash
#!/bin/bash
# build-signed.sh

set -e

echo "Building PYRO Detector release binary..."
cargo build --release

if [ $? -ne 0 ]; then
    echo "Build failed"
    exit 1
fi

# macOS signing
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -n "$APPLE_DEVELOPER_ID" ]; then
        echo "Signing executable..."
        codesign --sign "$APPLE_DEVELOPER_ID" --timestamp --options runtime target/release/pyro-detector
        
        echo "Verifying signature..."
        codesign --verify --verbose target/release/pyro-detector
        echo "✅ Executable signed successfully"
    else
        echo "⚠️  Apple Developer ID not configured. Skipping signing."
    fi
fi

# Linux GPG signing
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -n "$GPG_KEY_ID" ]; then
        echo "Signing executable with GPG..."
        gpg --armor --detach-sign --output target/release/pyro-detector.sig target/release/pyro-detector
        echo "✅ Signature created: target/release/pyro-detector.sig"
    else
        echo "⚠️  GPG key not configured. Skipping signing."
    fi
fi
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build and Sign

on:
  release:
    types: [created]

jobs:
  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions-rs/toolchain@v1
        with:
          toolchain: stable
          target: x86_64-pc-windows-msvc
      
      - name: Build
        run: cargo build --release --target x86_64-pc-windows-msvc
      
      - name: Sign
        uses: certificate-action/sign-windows@v1
        with:
          certificate: ${{ secrets.CODE_SIGN_CERT }}
          password: ${{ secrets.CODE_SIGN_PASSWORD }}
          file: target/x86_64-pc-windows-msvc/release/pyro-detector.exe
      
      - name: Upload
        uses: actions/upload-artifact@v3
        with:
          name: pyro-detector-windows
          path: target/x86_64-pc-windows-msvc/release/pyro-detector.exe
```

## Verification

### Windows

```powershell
# Verify signature
signtool.exe verify /pa /v pyro-detector.exe

# Check certificate details
Get-AuthenticodeSignature pyro-detector.exe | Format-List
```

### macOS

```bash
# Verify signature
codesign --verify --verbose pyro-detector

# Check certificate
codesign -d --verbose=4 pyro-detector
```

### Linux

```bash
# Verify GPG signature
gpg --verify pyro-detector.sig pyro-detector
```

## Distribution

### Windows

1. Create installer (MSI/EXE) with signed executable
2. Sign the installer itself
3. Distribute with checksums

### macOS

1. Create DMG or PKG
2. Sign the package
3. Notarize with Apple (for distribution outside App Store)

### Linux

1. Create DEB/RPM package
2. Sign package with GPG
3. Distribute with signature file

## Security Best Practices

1. **Certificate Storage**
   - Store certificates securely (keychain, HSM, or secure vault)
   - Never commit certificates to version control
   - Use environment variables or secrets management

2. **Timestamping**
   - Always use timestamp servers
   - Ensures signature remains valid after certificate expiration

3. **Verification**
   - Always verify signatures after signing
   - Include verification in CI/CD pipeline

4. **Certificate Renewal**
   - Monitor certificate expiration
   - Re-sign executables before expiration

## Troubleshooting

### Common Issues

1. **"Certificate not found"**
   - Check certificate path
   - Verify certificate format (PFX, PEM, etc.)

2. **"Invalid password"**
   - Verify certificate password
   - Check for special characters

3. **"Timestamp server unavailable"**
   - Try alternative timestamp servers
   - Check network connectivity

4. **"Signature verification failed"**
   - Rebuild and re-sign
   - Check for file corruption

## Next Steps

After building the signed executable:

1. Run all UA tests against signed binary
2. Verify signature on target systems
3. Create distribution package
4. Publish release with checksums
5. Document signing process for team

---

**Note**: Code signing certificates are required for production distribution. For development/testing, unsigned binaries are acceptable.

