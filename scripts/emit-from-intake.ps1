# Emit harness artifacts from intake answers JSON (PowerShell).
# Usage: pwsh -File scripts/emit-from-intake.ps1 -Answers path/to/answers.json [-Target path] [-Toolkit .] [-Merge] [-NoStrict]
#   -Target optional when answers JSON includes target_path
param(
    [Parameter(Mandatory = $true)]
    [string]$Answers,
    [string]$Target = "",
    [string]$Toolkit = "",
    [switch]$Merge,
    [switch]$NoStrict
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Toolkit) { $Toolkit = (Resolve-Path (Join-Path $scriptDir "..")).Path }

. (Join-Path $scriptDir "lib/normalize-target-path.ps1")

if (-not $Target) {
    if (-not (Test-Path -LiteralPath $Answers)) {
        throw "Missing answers file: $Answers"
    }
    $Target = (Get-Content -LiteralPath $Answers -Raw | ConvertFrom-Json).target_path
    if (-not $Target) {
        throw "Missing -Target or target_path in answers JSON"
    }
}

$normalizedTarget = Normalize-TargetPath -Path $Target

$bash = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bash) {
    Write-Error "emit-from-intake.ps1 requires bash (Git Bash) to run emit-from-intake.sh. Install Git for Windows or run from Linux/macOS CI."
    exit 1
}

$emitSh = Join-Path $scriptDir "emit-from-intake.sh"
$bashTarget = $normalizedTarget
$cygpath = Get-Command cygpath -ErrorAction SilentlyContinue
if ($cygpath) {
    $bashTarget = & $cygpath.Source -u $normalizedTarget
}

$bashArgs = @(
    $emitSh,
    "--answers", $Answers,
    "--target", $bashTarget,
    "--toolkit", $Toolkit
)
if ($Merge) { $bashArgs += "--merge" }
if ($NoStrict) { $bashArgs += "--no-strict" }

& $bash.Source @bashArgs
exit $LASTEXITCODE
