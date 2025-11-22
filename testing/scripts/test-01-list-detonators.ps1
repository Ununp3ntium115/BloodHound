# Test 01: List Detonators (MCP Method)
# Tests the pyro_list_detonators MCP method

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResultsDir = Join-Path $ScriptDir "..\results"
$LogFile = Join-Path $ResultsDir "logs\test-01-list-detonators.log"
$ResultFile = Join-Path $ResultsDir "test-01-list-detonators.json"

# Ensure results directory exists
New-Item -ItemType Directory -Force -Path $ResultsDir, (Join-Path $ResultsDir "logs") | Out-Null

# Initialize result
$Result = "FAIL"
$StartTime = Get-Date
$ErrorMsg = ""

# Log function
function Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Output $LogMessage | Tee-Object -FilePath $LogFile -Append
}

Log "=== Test 01: List Detonators (MCP Method) ==="
Log "Starting test at $(Get-Date)"

# Check if MCP server binary exists
$McpBinary = if ($env:MCP_BINARY) { $env:MCP_BINARY } else { ".\target\release\pyro-detector.exe" }
if (-not (Test-Path $McpBinary)) {
    $ErrorMsg = "MCP server binary not found at $McpBinary"
    Log "ERROR: $ErrorMsg"
    $Result = "SKIP"
} else {
    Log "Using MCP binary: $McpBinary"
    
    # Create JSON-RPC 2.0 request
    $Request = @{
        jsonrpc = "2.0"
        id = 1
        method = "pyro_list_detonators"
        params = @{}
    } | ConvertTo-Json -Compress
    
    Log "Sending request to MCP server..."
    Log "Request: $Request"
    
    # Send request and capture response
    try {
        $Response = $Request | & $McpBinary 2>&1
        
        if ([string]::IsNullOrWhiteSpace($Response)) {
            $ErrorMsg = "No response from MCP server"
            Log "ERROR: $ErrorMsg"
            $Result = "FAIL"
        } else {
            Log "Response received: $Response"
            
            # Check if response is valid JSON
            try {
                $ResponseObj = $Response | ConvertFrom-Json
                
                # Check for errors
                if ($ResponseObj.error) {
                    $ErrorMsg = if ($ResponseObj.error.message) { $ResponseObj.error.message } else { $ResponseObj.error }
                    Log "ERROR: MCP server returned error: $ErrorMsg"
                    $Result = "FAIL"
                } else {
                    # Check if result contains detonators
                    if ($ResponseObj.result.detonators) {
                        $DetonatorCount = $ResponseObj.result.detonators.Count
                        Log "SUCCESS: Received $DetonatorCount detonators"
                        $Result = "PASS"
                    } else {
                        $ErrorMsg = "Response missing detonators field"
                        Log "ERROR: $ErrorMsg"
                        $Result = "FAIL"
                    }
                }
            } catch {
                $ErrorMsg = "Invalid JSON response: $_"
                Log "ERROR: $ErrorMsg"
                $Result = "FAIL"
            }
        }
    } catch {
        $ErrorMsg = "Failed to execute MCP server: $_"
        Log "ERROR: $ErrorMsg"
        $Result = "FAIL"
    }
}

$EndTime = Get-Date
$Duration = ($EndTime - $StartTime).TotalSeconds

# Write result JSON
$ResultObj = @{
    test_id = "test-01-list-detonators"
    test_name = "List Detonators (MCP Method)"
    category = "mcp-methods"
    result = $Result
    duration_seconds = $Duration
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    error = $ErrorMsg
    log_file = $LogFile
} | ConvertTo-Json

$ResultObj | Out-File -FilePath $ResultFile -Encoding UTF8

Log "=== Test Complete: $Result ==="
Log "Duration: ${Duration}s"
Log "Result written to: $ResultFile"

exit 0

