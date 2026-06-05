# Deny dangerous shell patterns (stdin JSON from agent hooks — Cursor/Codex).
# Exit 2 = block; exit 0 = allow.
$ErrorActionPreference = "Stop"

$root = if ($env:AGENT_PROJECT_ROOT) { $env:AGENT_PROJECT_ROOT }
        elseif ($env:CURSOR_PROJECT_DIR) { $env:CURSOR_PROJECT_DIR }
        elseif ($env:CODEX_PROJECT_DIR) { $env:CODEX_PROJECT_DIR }
        else { "." }

$libCandidates = @(
    (Join-Path $root "scripts/lib/shell-guard.ps1"),
    (Join-Path (Split-Path -Parent $PSCommandPath) "..\..\scripts\lib\shell-guard.ps1")
)
foreach ($lib in $libCandidates) {
    if (Test-Path -LiteralPath $lib) {
        . $lib
        break
    }
}

$inputText = [Console]::In.ReadToEnd()

$cmd = ""
try {
    $json = $inputText | ConvertFrom-Json -ErrorAction Stop
    if ($json.PSObject.Properties.Name -contains "command") {
        $cmd = [string]$json.command
    } elseif ($json.PSObject.Properties.Name -contains "cmd") {
        $cmd = [string]$json.cmd
    }
} catch {
    if ($inputText -match '"command"\s*:\s*"([^"]*)"') {
        $cmd = $Matches[1]
    }
}

$denyPatterns = @(
    "prisma migrate",
    "db:migrate",
    "npm run migrate",
    "pnpm migrate",
    "deploy --prod",
    "vercel --prod",
    "rm -rf /",
    "rm -rf \",
    "git push --force",
    "git push -f",
    "git reset --hard"
)

foreach ($pat in $denyPatterns) {
    if ($cmd -match [regex]::Escape($pat)) {
        Write-Error "Blocked: $pat — ask the user to run this manually."
        exit 2
    }
}

if (Get-Command Test-ShellGuardEnvReadCommand -ErrorAction SilentlyContinue) {
    if (Test-ShellGuardEnvReadCommand $cmd) {
        Write-Error "Blocked: reading env or key material via shell — use .env.example and server-side secrets."
        exit 2
    }
}

if (Get-Command Test-ShellGuardGitRemoteChange -ErrorAction SilentlyContinue) {
    if (Test-ShellGuardGitRemoteChange $cmd) {
        Write-Error "Blocked: changing git remotes — ask the user to run this manually."
        exit 2
    }
}

if (Get-Command Test-ShellGuardOutbound -ErrorAction SilentlyContinue) {
    if (-not (Test-ShellGuardOutbound $cmd)) { exit 2 }
}

exit 0
