#!/usr/bin/env bash
# Harness growth stop hook — silent on success; stderr + exit 2 when repeat failures need harness fixes.
set -euo pipefail

cd "${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"

ledger=""
for candidate in .agents/harness/failure-ledger.json .cursor/harness/failure-ledger.json; do
  if [[ -f "$candidate" ]]; then
    ledger="$candidate"
    break
  fi
done

[[ -n "$ledger" ]] || exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

open_entries=$(jq -r '
  .entries[]
  | select(.fix_status == "open" and (.count | tonumber) >= 2)
  | "\(.id)\t\(.summary)"
' "$ledger" 2>/dev/null || true)

if [[ -z "$open_entries" ]]; then
  exit 0
fi

echo "Harness growth required — open failure ledger entries (count >= 2):" >&2
while IFS=$'\t' read -r id summary; do
  [[ -n "$id" ]] || continue
  echo "  - ${id}: ${summary}" >&2
done <<< "$open_entries"
echo "Load skill harness-self-improve, apply minimal fix, sync, validate, update HARNESS_CHANGELOG.md." >&2
exit 2
