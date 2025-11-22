# Test script for PYRO Detector MCP Server (PowerShell)

Write-Host "🔥 PYRO Detector Connection Test" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Yellow
Write-Host ""

# Check if binary exists
if (-not (Test-Path "target\release\pyro-detector.exe")) {
    Write-Host "❌ Binary not found. Building..." -ForegroundColor Red
    cargo build --release
}

Write-Host "✅ Binary found" -ForegroundColor Green
Write-Host ""

# Test 1: Health check
Write-Host "Test 1: Health Check" -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
$healthRequest = @{
    jsonrpc = "2.0"
    id = 1
    method = "pyro_health"
    params = @{}
} | ConvertTo-Json

$healthRequest | .\target\release\pyro-detector.exe | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# Test 2: Authenticate
Write-Host "Test 2: Authentication" -ForegroundColor Cyan
Write-Host "---------------------" -ForegroundColor Cyan
$authRequest = @{
    jsonrpc = "2.0"
    id = 2
    method = "pyro_authenticate"
    params = @{}
} | ConvertTo-Json

$authRequest | .\target\release\pyro-detector.exe | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# Test 3: List detonators
Write-Host "Test 3: List Detonators" -ForegroundColor Cyan
Write-Host "----------------------" -ForegroundColor Cyan
$detonatorsRequest = @{
    jsonrpc = "2.0"
    id = 3
    method = "pyro_list_detonators"
    params = @{
        investigation_type = "ransomware"
    }
} | ConvertTo-Json

$detonatorsRequest | .\target\release\pyro-detector.exe | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

# Test 4: List agents
Write-Host "Test 4: List Agents" -ForegroundColor Cyan
Write-Host "------------------" -ForegroundColor Cyan
$agentsRequest = @{
    jsonrpc = "2.0"
    id = 4
    method = "pyro_list_agents"
    params = @{}
} | ConvertTo-Json

$agentsRequest | .\target\release\pyro-detector.exe | ConvertFrom-Json | ConvertTo-Json -Depth 10
Write-Host ""

Write-Host "✅ All tests completed!" -ForegroundColor Green
Write-Host ""

