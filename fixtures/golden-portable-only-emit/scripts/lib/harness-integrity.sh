# shellcheck shell=bash
# Harness integrity checks for validate-target-harness.
# Source from validate scripts; do not execute directly.

# Hook scripts that may legitimately reference outbound-tool patterns.
HARNESS_INTEGRITY_GUARD_HOOKS=(
  deny-dangerous.sh
  deny-dangerous.ps1
  deny-unapproved-mcp.sh
  deny-unapproved-mcp.ps1
  verify-frontend.sh
  verify-frontend.ps1
  scan-secrets.sh
  scan-secrets.ps1
  harness-growth-stop.sh
  harness-growth-stop.ps1
)

harness_integrity_is_guard_hook() {
  local base
  base=$(basename "$1")
  local g
  for g in "${HARNESS_INTEGRITY_GUARD_HOOKS[@]}"; do
    [[ "$base" == "$g" ]] && return 0
  done
  return 1
}

# Allowed command path prefixes in hooks.json (relative to repo root).
HARNESS_INTEGRITY_ALLOWED_HOOK_PREFIXES=(
  ".cursor/hooks/"
  "scripts/"
)

harness_integrity_hook_path_allowed() {
  local path="$1"
  [[ -z "$path" ]] && return 1
  case "$path" in
    /*|*://*) return 1 ;;
  esac
  local prefix
  for prefix in "${HARNESS_INTEGRITY_ALLOWED_HOOK_PREFIXES[@]}"; do
    [[ "$path" == "$prefix"* ]] && return 0
  done
  return 1
}

# Suspicious patterns in hook scripts (ERE).
HARNESS_INTEGRITY_SUSPICIOUS_HOOK_PATTERNS=(
  'curl[[:space:]]'
  'wget[[:space:]]'
  'Invoke-WebRequest'
  'Invoke-RestMethod'
  'nc[[:space:]]'
  'netcat[[:space:]]'
  'base64[[:space:]]--decode'
  'eval[[:space:]]'
)

harness_integrity_scan_hook_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  harness_integrity_is_guard_hook "$file" && return 0

  local pat
  for pat in "${HARNESS_INTEGRITY_SUSPICIOUS_HOOK_PATTERNS[@]}"; do
    if grep -qEi "$pat" "$file" 2>/dev/null; then
      echo "$file: suspicious pattern ($pat)" >&2
      return 1
    fi
  done
  return 0
}

harness_integrity_scan_rules_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  case "$file" in
    *.mdc|*.md) ;;
    *) return 0 ;;
  esac
  # Shell-exfil examples in always-on rules are not expected.
  if grep -qEi 'curl[[:space:]]+-|wget[[:space:]]+http|Invoke-WebRequest[[:space:]]+-' "$file" 2>/dev/null; then
    echo "$file: suspicious shell exfil example in rule" >&2
    return 1
  fi
  return 0
}

# Extract hook command paths from hooks.json; prints one path per line.
harness_integrity_extract_hook_commands() {
  local hooks_json="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -r '.. | objects | select(has("command")) | .command' "$hooks_json" 2>/dev/null || true
  else
    grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]+"' "$hooks_json" 2>/dev/null \
      | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true
  fi
}
