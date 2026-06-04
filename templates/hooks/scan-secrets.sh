#!/usr/bin/env bash
# Scan changed files for high-confidence secret literals (Cursor stop hook).
# Exit 0 = allow; exit 2 = block (re-engage agent).
set -euo pipefail

ROOT="${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"
cd "$ROOT"

LIB=""
for candidate in \
  "$ROOT/scripts/lib/secret-patterns.sh" \
  "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/secret-patterns.sh"; do
  if [[ -f "$candidate" ]]; then
    LIB="$candidate"
    break
  fi
done

if [[ -z "$LIB" ]]; then
  echo "scan-secrets: secret-patterns.sh not found; skipping" >&2
  exit 0
fi
# shellcheck disable=SC1090,SC1091
source "$LIB"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

mapfile -t files < <(
  {
    git diff --name-only 2>/dev/null || true
    git diff --cached --name-only 2>/dev/null || true
  } | sort -u
)

if [[ "${#files[@]}" -eq 0 ]]; then
  exit 0
fi

failed=0
for rel in "${files[@]}"; do
  [[ -n "$rel" ]] || continue
  [[ -f "$rel" ]] || continue
  if ! secret_scan_file "$rel"; then
    failed=1
  fi
done

if [[ "$failed" -eq 1 ]]; then
  echo "Blocked: possible secret in changed files — remove literals; use env vars and server-side secrets." >&2
  exit 2
fi
exit 0
