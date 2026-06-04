# shellcheck shell=bash
# Shared high-confidence secret literal patterns for harness validate and scan-secrets hooks.
# Source from other scripts; do not execute directly.

# Patterns: "label|regex" — regex uses grep -E (ERE)
SECRET_PATTERNS=(
  'Stripe live secret|sk_live_[0-9a-zA-Z]{20,}'
  'Stripe test secret|sk_test_[0-9a-zA-Z]{20,}'
  'AWS access key id|AKIA[0-9A-Z]{16}'
  'Private key block|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY'
  'Hardcoded password assignment|password[[:space:]]*=[[:space:]]*["'\''][^"'\'']{8,}["'\'']'
  'Hardcoded API key assignment|api[_-]?key[[:space:]]*=[[:space:]]*["'\''][^"'\'']{8,}["'\'']'
)

secret_should_skip_path() {
  local rel="$1"
  case "$rel" in
    node_modules/*|*/node_modules/*|.next/*|*/.next/*|dist/*|*/dist/*) return 0 ;;
    package-lock.json|pnpm-lock.yaml|bun.lockb|*.lock) return 0 ;;
    *.min.js|*.min.css|*.map|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.ico|*.woff|*.woff2) return 0 ;;
  esac
  return 1
}

# Scan one file; prints "path: label (line N)" to stderr. Returns 1 if any match.
secret_scan_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  secret_should_skip_path "$file" && return 0

  local found=0 label regex
  for entry in "${SECRET_PATTERNS[@]}"; do
    label="${entry%%|*}"
    regex="${entry#*|}"
    while IFS= read -r match_line; do
      [[ -n "$match_line" ]] || continue
      echo "$file: $label (line ${match_line%%:*})" >&2
      found=1
    done < <(grep -nEi "$regex" "$file" 2>/dev/null || true)
  done
  [[ "$found" -eq 1 ]] && return 1
  return 0
}
