# Shared high-confidence secret literal patterns for harness validate and scan-secrets hooks.
# Dot-source from other scripts.

$SecretPatterns = @(
    @{ Label = 'Stripe live secret'; Regex = 'sk_live_[0-9a-zA-Z]{20,}' }
    @{ Label = 'Stripe test secret'; Regex = 'sk_test_[0-9a-zA-Z]{20,}' }
    @{ Label = 'AWS access key id'; Regex = 'AKIA[0-9A-Z]{16}' }
    @{ Label = 'Private key block'; Regex = 'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' }
    @{ Label = 'Hardcoded password assignment'; Regex = 'password\s*=\s*["''][^"'']{8,}["'']' }
    @{ Label = 'Hardcoded API key assignment'; Regex = 'api[_-]?key\s*=\s*["''][^"'']{8,}["'']' }
)

function Test-SecretShouldSkipPath([string]$RelativePath) {
    if ($RelativePath -match '(^|[\\/])node_modules([\\/]|$)|(^|[\\/])\.next([\\/]|$)|(^|[\\/])dist([\\/]|$)') { return $true }
    if ($RelativePath -match '\.(lock|min\.js|min\.css|map|png|jpe?g|gif|webp|ico|woff2?)$') { return $true }
    if ($RelativePath -in @('package-lock.json', 'pnpm-lock.yaml', 'yarn.lock', 'bun.lockb')) { return $true }
    return $false
}

# Returns $true if file contains a high-confidence secret pattern.
function Test-SecretScanFile([string]$FilePath) {
    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) { return $false }
    $rel = $FilePath -replace '\\', '/'
    if (Test-SecretShouldSkipPath $rel) { return $false }

    $content = Get-Content -LiteralPath $FilePath -Raw -ErrorAction SilentlyContinue
    if ([string]::IsNullOrEmpty($content)) { return $false }

    $lineNum = 0
    foreach ($line in ($content -split "`n")) {
        $lineNum++
        foreach ($pat in $SecretPatterns) {
            if ($line -match $pat.Regex) {
                Write-Host "$FilePath`: $($pat.Label) (line $lineNum)" -ForegroundColor Red
                return $true
            }
        }
    }
    return $false
}
