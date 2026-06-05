# Sync SKILL.md from canonical skills dir to mirror directories.
# Usage: pwsh -File scripts/sync-skills.ps1 [-Canonical .agents/skills] [-Cursor] [-Claude] [-Orchestration] [-AllMirrors]
param(
    [string]$Canonical = ".agents/skills",
    [switch]$Cursor,
    [switch]$Claude,
    [switch]$Orchestration,
    [switch]$AllMirrors
)

$ErrorActionPreference = "Stop"
$root = if ($env:AGENT_PROJECT_ROOT) { $env:AGENT_PROJECT_ROOT } else { "." }
Set-Location $root

if ($env:CANONICAL_SKILLS_DIR -and $Canonical -eq ".agents/skills") {
    $Canonical = $env:CANONICAL_SKILLS_DIR
}

if ($AllMirrors) {
    $Cursor = $true
    $Claude = $true
}

if (-not (Test-Path $Canonical)) {
    Write-Error "Missing canonical dir: $Canonical"
    exit 1
}

if (Test-Path ".cursor/skills") { $Cursor = $true }
if (Test-Path ".claude/skills") { $Claude = $true }

if (-not $Cursor -and -not $Claude) {
    Write-Error "No mirror dirs found. Create .cursor/skills or .claude/skills, or pass -Cursor / -Claude."
    exit 1
}

function Sync-SkillDir([string]$Dest) {
    New-Item -ItemType Directory -Force -Path $Dest | Out-Null
    Get-ChildItem "$Canonical/*/SKILL.md" -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Directory.Name
        $targetDir = Join-Path $Dest $name
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        Copy-Item $_.FullName (Join-Path $targetDir "SKILL.md") -Force
        Write-Host "Synced $name -> $Dest/$name/SKILL.md"
    }
}

if ($Cursor) { Sync-SkillDir ".cursor/skills" }
if ($Claude) { Sync-SkillDir ".claude/skills" }

if ($Orchestration -and (Test-Path "agents/ORCHESTRATION.md")) {
    if (Test-Path ".claude") {
        Copy-Item "agents/ORCHESTRATION.md" ".claude/ORCHESTRATION.md" -Force
        Write-Host "Synced orchestration -> .claude/ORCHESTRATION.md"
    }
    if (Test-Path ".cursor") {
        $cursorHooks = ".cursor/ORCHESTRATION.cursor-hooks.md"
        if (Test-Path $cursorHooks) {
            Get-Content "agents/ORCHESTRATION.md", $cursorHooks | Set-Content ".cursor/ORCHESTRATION.md"
        } else {
            Copy-Item "agents/ORCHESTRATION.md" ".cursor/ORCHESTRATION.md" -Force
        }
        Write-Host "Synced orchestration -> .cursor/ORCHESTRATION.md"
    }
}

Write-Host "Done (canonical: $Canonical)."
