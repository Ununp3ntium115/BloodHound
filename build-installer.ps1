# PowerShell script to build Pyro installer (MSI/EXE)
# For Windows builds

param(
    [string]$BuildType = "release",
    [switch]$CreateMSI = $false,
    [switch]$CreateEXE = $true
)

Write-Host "🩸 Building BloodSniffer - Autonomous Data Liberation System" -ForegroundColor Red

# Build Rust project
Write-Host "`nBuilding Rust project..." -ForegroundColor Yellow
cargo build --$BuildType

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build successful!" -ForegroundColor Green

# Create output directory
$OutputDir = "dist"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

# Copy binaries
Write-Host "`nCopying binaries..." -ForegroundColor Yellow
$BinDir = "target\$BuildType"

if (Test-Path "$BinDir\bloodsniffer.exe") {
    Copy-Item "$BinDir\bloodsniffer.exe" "$OutputDir\" -Force
    Write-Host "  ✓ bloodsniffer.exe" -ForegroundColor Green
}

if (Test-Path "$BinDir\fire-marshal.exe") {
    Copy-Item "$BinDir\fire-marshal.exe" "$OutputDir\" -Force
    Write-Host "  ✓ fire-marshal.exe" -ForegroundColor Green
}

# Create EXE installer using Inno Setup (if available)
if ($CreateEXE) {
    Write-Host "`nCreating EXE installer..." -ForegroundColor Yellow
    if (Test-Path "installer\pyro.iss") {
        $InnoCompiler = Get-Command "iscc" -ErrorAction SilentlyContinue
        if ($InnoCompiler) {
            & iscc "installer\pyro.iss"
            Write-Host "  ✓ EXE installer created" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ Inno Setup not found, skipping EXE installer" -ForegroundColor Yellow
        }
    }
}

# Create MSI installer using WiX (if available)
if ($CreateMSI) {
    Write-Host "`nCreating MSI installer..." -ForegroundColor Yellow
    $WixCompiler = Get-Command "candle" -ErrorAction SilentlyContinue
    if ($WixCompiler) {
        Write-Host "  ⚠ WiX Toolset found, but MSI creation not yet implemented" -ForegroundColor Yellow
    } else {
        Write-Host "  ⚠ WiX Toolset not found, skipping MSI installer" -ForegroundColor Yellow
    }
}

Write-Host "`n🩸 Build complete! Output in: $OutputDir" -ForegroundColor Green

