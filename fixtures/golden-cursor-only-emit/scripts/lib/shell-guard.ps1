# Shared shell-guard logic for deny-dangerous hooks (PowerShell).

$script:ShellGuardDefaultDomains = @(
    "github.com",
    "api.github.com",
    "raw.githubusercontent.com",
    "registry.npmjs.org",
    "registry.yarnpkg.com",
    "npmjs.org",
    "pnpm.io",
    "bun.sh",
    "nodejs.org",
    "localhost",
    "127.0.0.1"
)

function Get-ShellGuardRoot {
    if ($env:AGENT_PROJECT_ROOT) { return $env:AGENT_PROJECT_ROOT }
    if ($env:CURSOR_PROJECT_DIR) { return $env:CURSOR_PROJECT_DIR }
    if ($env:CODEX_PROJECT_DIR) { return $env:CODEX_PROJECT_DIR }
    return "."
}

function Get-ShellGuardAllowedDomainsFile([string]$Root) {
    foreach ($rel in @(".agents/harness/allowed-domains.txt", ".cursor/harness/allowed-domains.txt")) {
        $path = Join-Path $Root $rel
        if (Test-Path -LiteralPath $path) { return $path }
    }
    return $null
}

function Get-ShellGuardAllowedDomains([string]$Root) {
    $domains = [System.Collections.Generic.List[string]]::new()
    $file = Get-ShellGuardAllowedDomainsFile $Root
    if ($file) {
        Get-Content -LiteralPath $file | ForEach-Object {
            $line = ($_ -split '#')[0].Trim()
            if ($line) { $domains.Add($line.ToLowerInvariant()) }
        }
    }
    if ($domains.Count -eq 0) {
        foreach ($d in $script:ShellGuardDefaultDomains) { $domains.Add($d.ToLowerInvariant()) }
    }
    return $domains.ToArray()
}

function Test-ShellGuardHostAllowed([string]$HostName, [string[]]$Allowed) {
    $lower = $HostName.ToLowerInvariant()
    foreach ($a in $Allowed) {
        if ($lower -eq $a) { return $true }
        if ($lower.EndsWith(".$a")) { return $true }
    }
    return $false
}

function Get-ShellGuardExtractHosts([string]$Command) {
    $hosts = [System.Collections.Generic.List[string]]::new()
    $matches = [regex]::Matches($Command, 'https?://[^\s"''<>]+', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    foreach ($m in $matches) {
        $token = $m.Value
        $hostPart = ($token -replace '^https?://', '') -split '[/?#:]' | Select-Object -First 1
        if ($hostPart) { $hosts.Add($hostPart) }
    }
    return $hosts.ToArray()
}

function Test-ShellGuardOutboundCommand([string]$Command) {
    return $Command -match '(?i)(^|[;&|\s])(curl|wget|Invoke-WebRequest|Invoke-RestMethod|nc|netcat)(\s|$)'
}

function Test-ShellGuardEnvReadCommand([string]$Command) {
    if ($Command -match '(?i)(^|[;&|\s])(cat|type|Get-Content|more|less|head|tail)(\s|$).*(\\.env|id_rsa|\\.pem)') { return $true }
    if ($Command -match '(?i)(\\.env(\.local|\.production|\.development)?|id_rsa|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY)' -and
        $Command -match '(?i)(cat|type|Get-Content|more|less|head|tail)') { return $true }
    return $false
}

function Test-ShellGuardGitRemoteChange([string]$Command) {
    return $Command -match '(?i)git\s+remote\s+(add|set-url|remove)'
}

function Test-ShellGuardOutbound([string]$Command) {
    if (-not (Test-ShellGuardOutboundCommand $Command)) { return $true }

    $root = Get-ShellGuardRoot
    $allowed = Get-ShellGuardAllowedDomains $root
    $hosts = Get-ShellGuardExtractHosts $Command

    if ($hosts.Count -gt 0) {
        foreach ($h in $hosts) {
            if (-not (Test-ShellGuardHostAllowed $h $allowed)) {
                Write-Error "Blocked: outbound request to unapproved host '$h' — add to .agents/harness/allowed-domains.txt or ask the user."
                return $false
            }
        }
        return $true
    }

    if ($Command -match '(?i)(curl|wget|Invoke-WebRequest|Invoke-RestMethod)') {
        Write-Error "Blocked: outbound network command without a clear allowlisted URL — ask the user to run manually."
        return $false
    }
    return $true
}
