#!/usr/bin/env bash
# Frontend verify hook — silent on success; stderr + exit 2 on failure (re-engage agent).
set -euo pipefail

cd "${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"

LINT_CMD="pnpm biome check --write ."
TYPECHECK_CMD="pnpm exec tsc --noEmit"

STATUS=0

run_check() {
  local label="$1"
  local cmd="$2"
  local out
  if ! out=$(eval "$cmd" 2>&1); then
    echo "${label} failed:" >&2
    echo "$out" >&2
    STATUS=2
  fi
}

run_check "Lint/format" "$LINT_CMD"
run_check "Typecheck" "$TYPECHECK_CMD"

exit $STATUS
