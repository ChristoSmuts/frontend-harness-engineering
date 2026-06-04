# Deny dangerous shell patterns (stdin JSON from agent hooks — Cursor/Codex).
# Exit 2 = block; exit 0 = allow.
$ErrorActionPreference = "Stop"
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

exit 0
