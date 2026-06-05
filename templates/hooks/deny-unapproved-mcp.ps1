# Block MCP tool calls to servers not on the project allowlist (beforeMCPExecution).
# Exit 2 = block; exit 0 = allow.
$ErrorActionPreference = "Stop"

$root = if ($env:AGENT_PROJECT_ROOT) { $env:AGENT_PROJECT_ROOT }
        elseif ($env:CURSOR_PROJECT_DIR) { $env:CURSOR_PROJECT_DIR }
        elseif ($env:CODEX_PROJECT_DIR) { $env:CODEX_PROJECT_DIR }
        else { "." }

$allowlistPath = $null
foreach ($rel in @(".agents/harness/mcp-allowlist.json", ".cursor/harness/mcp-allowlist.json")) {
    $candidate = Join-Path $root $rel
    if (Test-Path -LiteralPath $candidate) {
        $allowlistPath = $candidate
        break
    }
}

if (-not $allowlistPath) {
    Write-Host "deny-unapproved-mcp: no mcp-allowlist.json; allowing (enable agent_security_hardening to emit allowlist)"
    exit 0
}

$inputText = [Console]::In.ReadToEnd()
$server = ""

try {
    $json = $inputText | ConvertFrom-Json -ErrorAction Stop
    foreach ($key in @("server", "mcpServer", "serverName", "mcp_server")) {
        if ($json.PSObject.Properties.Name -contains $key -and $json.$key) {
            $server = [string]$json.$key
            break
        }
    }
} catch {
    if ($inputText -match '"(server|mcpServer|serverName)"\s*:\s*"([^"]*)"') {
        $server = $Matches[2]
    }
}

if ([string]::IsNullOrWhiteSpace($server)) {
    Write-Error "Blocked: MCP call with unknown server id — cannot verify allowlist."
    exit 2
}

$allowed = Get-Content -LiteralPath $allowlistPath -Raw | ConvertFrom-Json
if ($allowed -contains $server) { exit 0 }

Write-Error "Blocked: MCP server '$server' is not in $allowlistPath — ask the user before enabling new MCP servers."
exit 2
