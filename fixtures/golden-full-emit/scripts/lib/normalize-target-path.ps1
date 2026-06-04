# Resolve target_path to an absolute directory (Windows PowerShell).
# Usage: . ./scripts/lib/normalize-target-path.ps1
#        Normalize-TargetPath -Path 'C:\dev\acme-web'

function Normalize-TargetPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Path -eq '~') {
        $Path = $HOME
    } elseif ($Path -like '~/*' -or $Path -like '~\*') {
        $Path = Join-Path $HOME $Path.Substring(2)
    }

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "target path does not exist: $Path"
    }
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "target path is not a directory: $Path"
    }

    (Resolve-Path -LiteralPath $Path).Path
}

function Test-ToolkitMetaRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Dir
    )

    $manifest = Join-Path $Dir 'manifest/ARTIFACT_MANIFEST.md'
    $bootstrap = Join-Path $Dir 'prompts/MASTER_BOOTSTRAP.md'
    (Test-Path -LiteralPath $manifest) -and (Test-Path -LiteralPath $bootstrap)
}
