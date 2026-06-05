# Scan changed files for high-confidence secret literals (Cursor stop hook).
# Exit 0 = allow; exit 2 = block (re-engage agent).
$ErrorActionPreference = "Stop"

$Root = $env:AGENT_PROJECT_ROOT
if ([string]::IsNullOrWhiteSpace($Root)) { $Root = $env:CURSOR_PROJECT_DIR }
if ([string]::IsNullOrWhiteSpace($Root)) { $Root = $env:CODEX_PROJECT_DIR }
if ([string]::IsNullOrWhiteSpace($Root)) { $Root = "." }
Set-Location $Root

$libCandidates = @(
    (Join-Path $Root ".agent-scripts/lib/secret-patterns.ps1")
    (Join-Path $Root "scripts/lib/secret-patterns.ps1")
    (Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) ".agent-scripts/lib/secret-patterns.ps1")
    (Join-Path (Split-Path $PSScriptRoot -Parent | Split-Path -Parent) "scripts/lib/secret-patterns.ps1")
)
$libPath = $libCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $libPath) {
    Write-Host "scan-secrets: secret-patterns.ps1 not found; skipping" -ForegroundAction Yellow
    exit 0
}
. $libPath

try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
} catch {
    exit 0
}

$files = @()
$files += git diff --name-only 2>$null
$files += git diff --cached --name-only 2>$null
$files = $files | Where-Object { $_ } | Sort-Object -Unique

if ($files.Count -eq 0) { exit 0 }

$failed = $false
foreach ($rel in $files) {
    if (-not (Test-Path -LiteralPath $rel -PathType Leaf)) { continue }
    if (Test-SecretScanFile $rel) { $failed = $true }
}

if ($failed) {
    Write-Error "Blocked: possible secret in changed files — remove literals; use env vars and server-side secrets."
    exit 2
}
exit 0
