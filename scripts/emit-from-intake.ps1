# Emit harness artifacts from intake answers JSON (PowerShell).
# Usage: pwsh -File scripts/emit-from-intake.ps1 -Answers intake/answers.json [-Target path] [-Toolkit .] [-Merge] [-NoStrict]
#   -Target optional when answers JSON includes target_path
param(
    [Parameter(Mandatory = $true)]
    [string]$Answers,
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$Toolkit = "",
    [switch]$Merge,
    [switch]$NoStrict
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Toolkit) { $Toolkit = Resolve-Path (Join-Path $scriptDir "..") }

$bash = Get-Command bash -ErrorAction SilentlyContinue
if ($bash) {
    $args = @(
        (Join-Path $scriptDir "emit-from-intake.sh"),
        "--answers", $Answers,
        "--target", $Target,
        "--toolkit", $Toolkit
    )
    if ($Merge) { $args += "--merge" }
    if ($NoStrict) { $args += "--no-strict" }
    & $bash.Source @args
    exit $LASTEXITCODE
}

Write-Error "emit-from-intake.ps1 requires bash (Git Bash) to run emit-from-intake.sh. Install Git for Windows or run from Linux/macOS CI."
exit 1
