# Scaffold harness growth artifacts and register skills in orchestration.
# Usage:
#   pwsh -File scripts/register-harness-growth.ps1 -Kind skill -Name my-skill -When "..." -Summary "..."
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("skill", "orchestration-row")]
    [string]$Kind,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$When = "",
    [string]$Summary = "",
    [switch]$NoSync,
    [switch]$NoValidate
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath ($env:AGENT_PROJECT_ROOT ?? ".")

$canonical = $env:CANONICAL_SKILLS_DIR
if ([string]::IsNullOrWhiteSpace($canonical)) { $canonical = ".agents/skills" }
if (-not (Test-Path -LiteralPath $canonical)) { $canonical = ".cursor/skills" }
if (-not (Test-Path -LiteralPath $canonical)) {
    throw "No canonical skills dir found"
}

$orch = $null
if (Test-Path "agents/ORCHESTRATION.md") { $orch = "agents/ORCHESTRATION.md" }
elseif (Test-Path ".cursor/ORCHESTRATION.md") { $orch = ".cursor/ORCHESTRATION.md" }

function Add-OrchestrationRow {
    param([string]$SkillName, [string]$WhenText)
    if (-not $orch) {
        Write-Host "No ORCHESTRATION.md found; skip orchestration row"
        return
    }
    $content = Get-Content -LiteralPath $orch -Raw
    if ($content -match "\| ``$([regex]::Escape($SkillName))`` \|") {
        Write-Host "Orchestration row for $SkillName already exists"
        return
    }
    $row = "| ``$SkillName`` | $WhenText |"
    $updated = $content -replace '(?m)^## MCP policy', "$row`n`n## MCP policy"
    if ($updated -eq $content) {
        Add-Content -LiteralPath $orch -Value $row
    } else {
        Set-Content -LiteralPath $orch -Value $updated -NoNewline
    }
    Write-Host "Added orchestration row for $SkillName in $orch"
}

if ($Kind -eq "skill") {
    if ([string]::IsNullOrWhiteSpace($When) -or [string]::IsNullOrWhiteSpace($Summary)) {
        throw "--When and --Summary required for -Kind skill"
    }
    $dest = Join-Path $canonical "$Name/SKILL.md"
    if (Test-Path -LiteralPath $dest) {
        Write-Host "Skill already exists: $dest"
    } else {
        New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
        @"
---
name: $Name
description: $Summary Use when $When
disable-model-invocation: true
---

# $Name

## When to use

- $When

## Instructions

<!-- Add project-specific guidance here (max ~15 lines per growth patch). -->

## Project-specific notes

- Created via harness self-improvement (failure ledger).
"@ | Set-Content -LiteralPath $dest
        Write-Host "Created $dest"
    }
    Add-OrchestrationRow -SkillName $Name -WhenText $When
}
elseif ($Kind -eq "orchestration-row") {
    if ([string]::IsNullOrWhiteSpace($When)) { throw "--When required for -Kind orchestration-row" }
    Add-OrchestrationRow -SkillName $Name -WhenText $When
}

$registerScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $NoSync -and (Test-Path (Join-Path $registerScriptDir "sync-skills.ps1"))) {
    pwsh -File (Join-Path $registerScriptDir "sync-skills.ps1") -AllMirrors -Orchestration 2>$null
}

if (-not $NoValidate -and (Test-Path (Join-Path $registerScriptDir "validate-target-harness.ps1"))) {
    pwsh -File (Join-Path $registerScriptDir "validate-target-harness.ps1")
}

Write-Host "register-harness-growth complete"
