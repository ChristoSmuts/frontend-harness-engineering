# Frontend verify hook (Windows) — silent on success; stderr + exit 2 on failure.
$ErrorActionPreference = "Stop"
Set-Location $env:CURSOR_PROJECT_DIR
if (-not $env:CURSOR_PROJECT_DIR) { Set-Location $PSScriptRoot\..\.. }

$lintCmd = "{{LINT_CMD}}"
$typecheckCmd = "{{TYPECHECK_CMD}}"

function Invoke-Check($label, $cmd) {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $out = Invoke-Expression $cmd 2>&1 | Out-String
    $code = $LASTEXITCODE
    $ErrorActionPreference = $prev
    if ($code -ne 0) {
        Write-Error "${label} failed:`n$out"
        exit 2
    }
}

Invoke-Check "Lint/format" $lintCmd
Invoke-Check "Typecheck" $typecheckCmd
exit 0
