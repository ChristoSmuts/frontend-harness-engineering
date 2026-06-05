# Harness integrity checks for validate-target-harness.ps1

$script:HarnessIntegrityGuardHooks = @(
    "deny-dangerous.sh",
    "deny-dangerous.ps1",
    "deny-unapproved-mcp.sh",
    "deny-unapproved-mcp.ps1",
    "verify-frontend.sh",
    "verify-frontend.ps1",
    "scan-secrets.sh",
    "scan-secrets.ps1",
    "harness-growth-stop.sh",
    "harness-growth-stop.ps1"
)

$script:HarnessIntegrityAllowedHookPrefixes = @(
    ".cursor/hooks/",
    ".agent-scripts/",
    "scripts/"
)

function Test-HarnessIntegrityGuardHook([string]$Path) {
    $base = Split-Path -Leaf $Path
    return $script:HarnessIntegrityGuardHooks -contains $base
}

function Test-HarnessIntegrityHookPathAllowed([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    if ($Path -match '^/|^[A-Za-z]:|://') { return $false }
    foreach ($prefix in $script:HarnessIntegrityAllowedHookPrefixes) {
        if ($Path.StartsWith($prefix)) { return $true }
    }
    return $false
}

$script:HarnessIntegritySuspiciousHookPatterns = @(
    'curl\s',
    'wget\s',
    'Invoke-WebRequest',
    'Invoke-RestMethod',
    'nc\s',
    'netcat\s',
    'base64\s--decode',
    'eval\s'
)

function Test-HarnessIntegrityHookFile([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath)) { return $true }
    if (Test-HarnessIntegrityGuardHook $FilePath) { return $true }

    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return $true }

    foreach ($pat in $script:HarnessIntegritySuspiciousHookPatterns) {
        if ($content -match $pat) {
            Write-Host "$FilePath`: suspicious pattern ($pat)" -ForegroundColor Yellow
            return $false
        }
    }
    return $true
}

function Test-HarnessIntegrityRulesFile([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath)) { return $true }
    if ($FilePath -notmatch '\.(mdc|md)$') { return $true }

    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue
    if ($content -match 'curl\s+-|wget\s+http|Invoke-WebRequest\s+-') {
        Write-Host "$FilePath`: suspicious shell exfil example in rule" -ForegroundColor Yellow
        return $false
    }
    return $true
}

function Get-HarnessIntegrityHookCommands([string]$HooksJsonPath) {
    if (-not (Test-Path -LiteralPath $HooksJsonPath)) { return @() }
    try {
        $json = Get-Content -LiteralPath $HooksJsonPath -Raw | ConvertFrom-Json
        $commands = [System.Collections.Generic.List[string]]::new()
        function Walk-Object($obj) {
            if ($null -eq $obj) { return }
            if ($obj -is [string] -or $obj -is [ValueType]) { return }
            if ($obj.PSObject.Properties.Name -contains "command") {
                $commands.Add([string]$obj.command)
            }
            if ($obj -is [System.Array]) {
                foreach ($item in $obj) { Walk-Object $item }
                return
            }
            foreach ($prop in $obj.PSObject.Properties) {
                Walk-Object $prop.Value
            }
        }
        Walk-Object $json
        return $commands.ToArray()
    } catch {
        return @()
    }
}
