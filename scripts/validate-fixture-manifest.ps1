# Validate required paths for an emit profile.
# Usage: pwsh -File scripts/validate-fixture-manifest.ps1 [-Profile full] [-TargetRoot .]
param(
    [string]$Profile = "full",
    [string]$TargetRoot = "."
)

$ErrorActionPreference = "Stop"
$toolkit = Resolve-Path (Join-Path $PSScriptRoot "..")
$manifest = Join-Path $toolkit "manifest\emit-manifest.json"
$targetResolved = if ($TargetRoot -eq ".") {
    (Get-Location).Path
} else {
    (Resolve-Path -LiteralPath $TargetRoot).Path
}
Set-Location -LiteralPath $targetResolved

$json = Get-Content $manifest -Raw | ConvertFrom-Json
$intakePath = Join-Path $targetResolved "intake.answers.json"
$intake = $null
if (Test-Path -LiteralPath $intakePath) {
    $intake = Get-Content -LiteralPath $intakePath -Raw | ConvertFrom-Json
}

function Test-FeatureRequired([string]$Feature) {
    if (-not $intake) { return $false }
    $val = $intake.features.$Feature
    if ($null -eq $val) { return $false }
    return [bool]$val
}

$errors = 0
foreach ($p in $json.profiles.$Profile.required_paths) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Host "ERROR: missing required path for profile ${Profile}: $p" -ForegroundColor Red
        $errors++
    }
}

foreach ($entry in $json.conditional_paths) {
    if ($entry.profiles -notcontains $Profile) { continue }
    if (-not (Test-FeatureRequired $entry.feature)) { continue }
    if (-not (Test-Path -LiteralPath $entry.path)) {
        Write-Host "ERROR: missing conditional path (feature=$($entry.feature)) for profile ${Profile}: $($entry.path)" -ForegroundColor Red
        $errors++
    }
}

$forbidden = $json.profiles.$Profile.forbidden_paths
if ($forbidden) {
    foreach ($fp in $forbidden) {
        if (Test-Path -LiteralPath $fp) {
            Write-Host "ERROR: forbidden path present for profile ${Profile}: $fp" -ForegroundColor Red
            $errors++
        }
    }
}

if ($errors -gt 0) { exit 1 }
Write-Host "Manifest validation OK (profile=$Profile)"
exit 0
