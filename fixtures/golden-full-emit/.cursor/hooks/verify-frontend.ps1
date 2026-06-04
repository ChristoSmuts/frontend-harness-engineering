# Frontend verify hook (Windows) — silent on success; stderr + exit 2 on failure.
$ErrorActionPreference = "Stop"
$root = $env:AGENT_PROJECT_ROOT
if (-not $root) { $root = $env:CURSOR_PROJECT_DIR }
if (-not $root) { $root = $env:CODEX_PROJECT_DIR }
if ($root) { Set-Location $root } else { Set-Location $PSScriptRoot\..\.. }


$lintCmd = "pnpm biome check --write ."
$typecheckCmd = "pnpm exec tsc --noEmit"

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
