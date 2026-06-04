# Validate harness artifacts in a target frontend repo.
# Usage: pwsh -File scripts/validate-target-harness.ps1 [-Strict] [-TargetRoot path]
param(
    [string]$TargetRoot = ".",
    [switch]$Strict
)

$ErrorActionPreference = "Stop"
Set-Location $TargetRoot

$ValidateScriptDir = Split-Path -Parent $PSCommandPath
$SecretPatternsLib = Join-Path $ValidateScriptDir "lib/secret-patterns.ps1"
if (Test-Path $SecretPatternsLib) { . $SecretPatternsLib }

if ((Test-Path "manifest/ARTIFACT_MANIFEST.md") -and (Test-Path "prompts/MASTER_BOOTSTRAP.md")) {
    Write-Host "Toolkit meta-repo detected; skip target harness validation (use CI validate-toolkit workflow)."
    exit 0
}

$script:Errors = 0
$script:Warnings = 0

function Warn([string]$Message) {
    Write-Warning $Message
    $script:Warnings++
}

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    $script:Errors++
}

function Test-EmitStrategyTools([string]$Strategy, [string]$AgentsContent) {
    if ([string]::IsNullOrWhiteSpace($Strategy)) { return }

    if ($Strategy -eq "cursor-only" -and (Test-Path "agents/ORCHESTRATION.md")) {
        Fail "emit_strategy cursor-only must not keep agents/ORCHESTRATION.md (canonical orchestration is .cursor/ORCHESTRATION.md)"
    }

    if ($Strategy -ne "full") {
        if ($AgentsContent -match '(?i)(\*\*Cursor\*\*|Cursor:)' -and $AgentsContent -match '(?i)(Codex|Gemini)') {
            Fail "emit_strategy $Strategy incompatible: Cursor and Codex/Gemini CLI both documented in AGENTS.md (use full)"
        }
    }

    if ($Strategy -eq "cursor-only") {
        if ($AgentsContent -match '(?i)(Codex|Gemini|Claude)') {
            Fail "emit_strategy cursor-only incompatible with Codex, Gemini, or Claude Code documented in AGENTS.md"
        }
        if ((Test-Path -LiteralPath ".agents/skills") -and $AgentsContent -match '(?i)(Codex|Gemini)') {
            Fail "emit_strategy cursor-only with .agents/skills/ requires Codex/Gemini in AGENTS.md (use full)"
        }
    }

    if ($Strategy -eq "portable-only") {
        if ($AgentsContent -match '(?i)Claude' -and -not (Test-Path "CLAUDE.md") -and -not (Test-Path -LiteralPath ".claude/rules")) {
            Fail "Claude Code documented in AGENTS.md but CLAUDE.md or .claude/rules/ missing (portable-only)"
        }
        if ((Test-Path -LiteralPath ".cursor/skills") -and -not (Test-Path -LiteralPath ".agents/skills")) {
            Fail "emit_strategy portable-only with .cursor/skills/ but no .agents/skills/ (canonical hub missing)"
        }
    }
}

function Get-FileHashHex([string]$Path) {
    $hash = Get-FileHash -Path $Path -Algorithm SHA256
    return $hash.Hash
}

function Test-Placeholders([string]$FilePath) {
    if (Select-String -Path $FilePath -Pattern '\{\{' -Quiet -ErrorAction SilentlyContinue) {
        Fail "Unreplaced placeholder in $FilePath"
    }
}

$HarnessPaths = @("AGENTS.md", "agents", ".agents", ".cursor", ".claude")

foreach ($base in $HarnessPaths) {
    if (-not (Test-Path -LiteralPath $base)) { continue }

    if ((Get-Item -LiteralPath $base).PSIsContainer -eq $false) {
        Test-Placeholders $base
        continue
    }

    Get-ChildItem -LiteralPath $base -Recurse -File -Include "*.md", "*.mdc", "*.sh", "*.ps1", "hooks.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "frontend-harness-bootstrap" } |
        ForEach-Object { Test-Placeholders $_.FullName }
}

if (Test-Path "AGENTS.md") {
    $lines = (Get-Content "AGENTS.md").Count
    if ($lines -gt 60) {
        Warn "AGENTS.md has $lines lines (target <= 60); move detail into skills"
    }

    $agentsContent = Get-Content "AGENTS.md" -Raw
    $emitStrategy = $null
    if ($agentsContent -match '(?i)emit\s*strategy[^a-z]*(full|portable-only|cursor-only)') {
        $emitStrategy = $Matches[1].ToLowerInvariant()
    }
    $hasPlatform = $agentsContent -match '(?i)platform\s*primary[^a-z]*(unix|windows)'

    if (Test-Path -LiteralPath ".cursor/hooks.json") {
        if (-not $emitStrategy) {
            Fail "AGENTS.md missing emit_strategy (required when .cursor/hooks.json exists)"
        }
        if (-not $hasPlatform) {
            Fail "AGENTS.md missing platform_primary (required when .cursor/hooks.json exists)"
        }
    }

    if ($emitStrategy) {
        Test-EmitStrategyTools $emitStrategy $agentsContent
        if ($emitStrategy -eq "full" -and -not (Test-Path -LiteralPath ".agents/skills")) {
            Fail "emit_strategy full but .agents/skills/ is missing"
        }
    }

    if (Test-Path -LiteralPath ".cursor/hooks.json") {
        $hooksJson = Get-Content ".cursor/hooks.json" -Raw
        if ($hooksJson -match 'verify-frontend\.ps1' -and $agentsContent -match '(?i)platform\s*primary\s*:\s*unix') {
            Warn "platform_primary unix but hooks.json uses verify-frontend.ps1"
        }
        if ($hooksJson -match 'verify-frontend\.sh' -and $agentsContent -match '(?i)platform\s*primary\s*:\s*windows') {
            Warn "platform_primary windows but hooks.json uses verify-frontend.sh"
        }
    }
}

try {
    git rev-parse --is-inside-work-tree 2>$null | Out-Null
    foreach ($envf in @(".env", ".env.local", ".env.production", ".env.development")) {
        $tracked = git ls-files --error-unmatch $envf 2>$null
        if ($LASTEXITCODE -eq 0) {
            Fail "Tracked env file must not be committed: $envf"
        }
    }
} catch { }

if (Get-Command Test-SecretScanFile -ErrorAction SilentlyContinue) {
    foreach ($base in $HarnessPaths) {
        if (-not (Test-Path -LiteralPath $base)) { continue }
        $files = @()
        if ((Get-Item -LiteralPath $base).PSIsContainer) {
            $files = Get-ChildItem -LiteralPath $base -Recurse -Include "*.md", "*.mdc" -File -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch 'frontend-harness-bootstrap' }
        } else {
            $files = @(Get-Item -LiteralPath $base)
        }
        foreach ($f in $files) {
            if (Test-SecretScanFile $f.FullName) {
                if ($Strict) { Fail "Possible secret literal in harness file: $($f.FullName)" }
                else { Warn "Possible secret literal in harness file: $($f.FullName)" }
            }
        }
    }
}

if (Test-Path -LiteralPath ".cursor/hooks.json") {
    $hooksJson = Get-Content ".cursor/hooks.json" -Raw
    foreach ($script in @(
            ".cursor/hooks/verify-frontend.sh",
            ".cursor/hooks/verify-frontend.ps1",
            ".cursor/hooks/deny-dangerous.sh",
            ".cursor/hooks/deny-dangerous.ps1",
            ".cursor/hooks/scan-secrets.sh",
            ".cursor/hooks/scan-secrets.ps1"
        )) {
        $base = Split-Path -Leaf $script
        if ($hooksJson -match [regex]::Escape($base) -and -not (Test-Path -LiteralPath $script)) {
            Fail "hooks.json references missing $script"
        }
    }
}

if ((Test-Path "agents/ORCHESTRATION.md") -and (Test-Path -LiteralPath ".claude/ORCHESTRATION.md")) {
    $hAgents = Get-FileHashHex "agents/ORCHESTRATION.md"
    $hClaude = Get-FileHashHex ".claude/ORCHESTRATION.md"
    if ($hAgents -ne $hClaude) {
        Warn "ORCHESTRATION.md differs between agents/ and .claude/ (run sync-skills.ps1 -Orchestration)"
    }
}

function Test-MirrorDir([string]$MirrorBase) {
    if (-not (Test-Path -LiteralPath ".agents/skills")) { return }
    if (-not (Test-Path -LiteralPath $MirrorBase)) { return }

    Get-ChildItem -LiteralPath ".agents/skills" -Filter "SKILL.md" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Directory.Name
        $mirror = Join-Path $MirrorBase "$name/SKILL.md"
        if ((Test-Path -LiteralPath $mirror) -and -not ((Get-FileHash $_.FullName).Hash -eq (Get-FileHash $mirror).Hash)) {
            Warn "Skill $name differs: canonical vs $MirrorBase mirror (run scripts/sync-skills.ps1)"
        }
    }
}

if ((Test-Path -LiteralPath ".agents/skills/frontend-verify") -or (Test-Path -LiteralPath ".cursor/skills/frontend-verify")) {
    if (-not (Test-Path -LiteralPath ".agents/skills/frontend-security/SKILL.md") -and
        -not (Test-Path -LiteralPath ".cursor/skills/frontend-security/SKILL.md")) {
        Fail "frontend-security skill missing (required P1 with frontend-verify)"
    }
}

Test-MirrorDir ".cursor/skills"
Test-MirrorDir ".claude/skills"

Write-Host "Validation complete: $($script:Errors) error(s), $($script:Warnings) warning(s)."
if ($script:Errors -gt 0) { exit 1 }
if ($Strict -and $script:Warnings -gt 0) { exit 1 }
exit 0
