#!/usr/bin/env bash
# Frontend verify hook — silent on success; stderr + exit 2 on failure (re-engage agent).
set -euo pipefail

cd "${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"

# {{MONOREPO_CD_BLOCK_START}}
# Monorepo: bootstrap removes this block when monorepo=no; when yes, replace with: cd "{{APP_PACKAGE_PATH}}"
# {{MONOREPO_CD_BLOCK_END}}

LINT_CMD="{{LINT_CMD}}"
TYPECHECK_CMD="{{TYPECHECK_CMD}}"

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
