# Frontend verify hook (Windows) — silent on success; stderr + exit 2 on failure.
$ErrorActionPreference = "Stop"
$root = $env:AGENT_PROJECT_ROOT
if (-not $root) { $root = $env:CURSOR_PROJECT_DIR }
if (-not $root) { $root = $env:CODEX_PROJECT_DIR }
if ($root) { Set-Location $root } else { Set-Location $PSScriptRoot\..\.. }

# {{MONOREPO_CD_BLOCK_START}}
# Monorepo: bootstrap removes this block when monorepo=no; when yes, replace with: Set-Location "{{APP_PACKAGE_PATH}}"
# {{MONOREPO_CD_BLOCK_END}}

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
