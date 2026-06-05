# Harness growth stop hook — silent on success; stderr + exit 2 when repeat failures need harness fixes.
$ErrorActionPreference = "Stop"
Set-Location -LiteralPath ($env:AGENT_PROJECT_ROOT ?? $env:CURSOR_PROJECT_DIR ?? $env:CODEX_PROJECT_DIR ?? ".")

$ledger = $null
foreach ($candidate in @(".agents/harness/failure-ledger.json", ".cursor/harness/failure-ledger.json")) {
    if (Test-Path -LiteralPath $candidate) {
        $ledger = $candidate
        break
    }
}
if (-not $ledger) { exit 0 }

try {
    $data = Get-Content -LiteralPath $ledger -Raw | ConvertFrom-Json
} catch {
    exit 0
}

$open = @($data.entries | Where-Object {
        $_.fix_status -eq "open" -and [int]$_.count -ge 2
    })

if ($open.Count -eq 0) { exit 0 }

Write-Host "Harness growth required — open failure ledger entries (count >= 2):" -ForegroundColor Yellow
foreach ($entry in $open) {
    Write-Host "  - $($entry.id): $($entry.summary)"
}
Write-Host "Load skill harness-self-improve, apply minimal fix, sync, validate, update HARNESS_CHANGELOG.md."
exit 2
