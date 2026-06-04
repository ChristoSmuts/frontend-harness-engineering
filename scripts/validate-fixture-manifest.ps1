# Validate required paths for an emit profile.
# Usage: pwsh -File scripts/validate-fixture-manifest.ps1 [-Profile full] [-TargetRoot .]
param(
    [string]$Profile = "full",
    [string]$TargetRoot = "."
)

$ErrorActionPreference = "Stop"
$toolkit = Resolve-Path (Join-Path $PSScriptRoot "..")
$manifest = Join-Path $toolkit "manifest\emit-manifest.json"
Set-Location $TargetRoot

$json = Get-Content $manifest -Raw | ConvertFrom-Json
$intakePath = Join-Path $TargetRoot "intake.answers.json"
$intake = $null
if (Test-Path $intakePath) {
    $intake = Get-Content $intakePath -Raw | ConvertFrom-Json
}

function Test-FeatureRequired([string]$Feature) {
    if (-not $intake) { return $true }
    $val = $intake.features.$Feature
    if ($null -eq $val) { return $false }
    return [bool]$val
}

$errors = 0
foreach ($p in $json.profiles.$Profile.required_paths) {
    if (-not (Test-Path $p)) {
        Write-Host "ERROR: missing required path for profile ${Profile}: $p" -ForegroundColor Red
        $errors++
    }
}

foreach ($entry in $json.conditional_paths) {
    if ($entry.profiles -notcontains $Profile) { continue }
    if (-not (Test-FeatureRequired $entry.feature)) { continue }
    if (-not (Test-Path $entry.path)) {
        Write-Host "ERROR: missing conditional path (feature=$($entry.feature)) for profile ${Profile}: $($entry.path)" -ForegroundColor Red
        $errors++
    }
}

if ($errors -gt 0) { exit 1 }
Write-Host "Manifest validation OK (profile=$Profile)"
exit 0
