# Setup script for PYRO Detector MCP Server (PowerShell)

Write-Host "🔥 PYRO Detector Setup" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
Write-Host ""

# Check if Rust is installed
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Rust/Cargo not found. Please install Rust first:" -ForegroundColor Red
    Write-Host "   Visit: https://rustup.rs/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Rust/Cargo found" -ForegroundColor Green
Write-Host ""

# Build the project
Write-Host "📦 Building PYRO Detector..." -ForegroundColor Cyan
cargo build --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Create config file if it doesn't exist
if (-not (Test-Path "pyro-detector-config.json")) {
    Write-Host "📝 Creating configuration file..." -ForegroundColor Cyan
    Copy-Item "pyro-detector-config.json.example" "pyro-detector-config.json"
    Write-Host "✅ Configuration file created: pyro-detector-config.json" -ForegroundColor Green
    Write-Host "   Please edit it with your PYRO Platform Ignition settings" -ForegroundColor Yellow
} else {
    Write-Host "✅ Configuration file already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Edit pyro-detector-config.json with your API settings"
Write-Host "2. Add to Cursor MCP configuration (see mcp-config.json)"
Write-Host "3. Test: .\target\release\pyro-detector.exe"
Write-Host ""
