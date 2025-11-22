# Run all test scripts and generate summary report

$ErrorActionPreference = "Continue"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ResultsDir = Join-Path $ScriptDir "..\results"
$SummaryFile = Join-Path $ResultsDir "test-summary.json"

# Ensure results directory exists
New-Item -ItemType Directory -Force -Path $ResultsDir, (Join-Path $ResultsDir "logs") | Out-Null

# Initialize counters
$Total = 0
$Passed = 0
$Failed = 0
$Skipped = 0
$Timeout = 0

# Array to store results
$Results = @()

Write-Output "=== Running All PYRO Detector Tests ==="
Write-Output "Results directory: $ResultsDir"
Write-Output ""

# Find all test scripts
Get-ChildItem -Path $ScriptDir -Filter "test-*.ps1" | ForEach-Object {
    $Total++
    $TestName = $_.BaseName
    Write-Output "[$Total] Running $TestName..."
    
    # Run test
    try {
        & $_.FullName | Out-Null
        
        # Check result file
        $ResultFile = Join-Path $ResultsDir "$TestName.json"
        if (Test-Path $ResultFile) {
            $ResultObj = Get-Content $ResultFile | ConvertFrom-Json
            $Result = $ResultObj.result
            
            switch ($Result) {
                "PASS" {
                    $Passed++
                    Write-Output "  ✓ PASS"
                }
                "FAIL" {
                    $Failed++
                    Write-Output "  ✗ FAIL"
                }
                "SKIP" {
                    $Skipped++
                    Write-Output "  ⊘ SKIP"
                }
                default {
                    Write-Output "  ? UNKNOWN"
                }
            }
            $Results += $ResultFile
        } else {
            Write-Output "  ? NO RESULT FILE"
        }
    } catch {
        $Timeout++
        Write-Output "  ⏱ TIMEOUT or ERROR"
    }
}

Write-Output ""
Write-Output "=== Test Summary ==="
Write-Output "Total: $Total"
Write-Output "Passed: $Passed"
Write-Output "Failed: $Failed"
Write-Output "Skipped: $Skipped"
Write-Output "Timeout: $Timeout"
Write-Output ""

# Generate summary JSON
$PassRate = if ($Total -gt 0) { [math]::Round(($Passed / $Total) * 100, 2) } else { 0 }

$SummaryObj = @{
    timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    total = $Total
    passed = $Passed
    failed = $Failed
    skipped = $Skipped
    timeout = $Timeout
    pass_rate = $PassRate
    results = $Results | ForEach-Object {
        if (Test-Path $_) {
            Get-Content $_ | ConvertFrom-Json
        }
    }
} | ConvertTo-Json -Depth 10

$SummaryObj | Out-File -FilePath $SummaryFile -Encoding UTF8

Write-Output "Summary written to: $SummaryFile"

# Exit with error if any tests failed
if ($Failed -gt 0 -or $Timeout -gt 0) {
    exit 1
}

exit 0

