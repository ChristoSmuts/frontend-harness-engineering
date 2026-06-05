#!/usr/bin/env bash
# Ensure fixture copies of maintenance scripts match the toolkit (CI).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT="$(cd "$SCRIPT_DIR/.." && pwd)"
MAINT=(
  validate-target-harness.sh
  validate-target-harness.ps1
  sync-skills.sh
  sync-skills.ps1
)

LIB_MAINT=(
  secret-patterns.sh
  secret-patterns.ps1
  normalize-target-path.sh
  normalize-target-path.ps1
  harness-integrity.sh
  harness-integrity.ps1
  shell-guard.sh
  shell-guard.ps1
)

ERRORS=0
for fixture_scripts in "$TOOLKIT"/fixtures/*/scripts; do
  [[ -d "$fixture_scripts" ]] || continue
  fixture_name=$(basename "$(dirname "$fixture_scripts")")
  for s in "${MAINT[@]}"; do
    toolkit_src="$TOOLKIT/scripts/$s"
    fixture_src="$fixture_scripts/$s"
    if [[ ! -f "$fixture_src" ]]; then
      echo "ERROR: $fixture_name missing scripts/$s" >&2
      ERRORS=$((ERRORS + 1))
      continue
    fi
    if ! cmp -s "$toolkit_src" "$fixture_src"; then
      echo "ERROR: $fixture_name/scripts/$s differs from toolkit/scripts/$s" >&2
      ERRORS=$((ERRORS + 1))
    fi
  done
  fixture_lib="$fixture_scripts/lib"
  for s in "${LIB_MAINT[@]}"; do
    toolkit_src="$TOOLKIT/scripts/lib/$s"
    fixture_src="$fixture_lib/$s"
    if [[ ! -f "$fixture_src" ]]; then
      echo "ERROR: $fixture_name missing scripts/lib/$s" >&2
      ERRORS=$((ERRORS + 1))
      continue
    fi
    if ! cmp -s "$toolkit_src" "$fixture_src"; then
      echo "ERROR: $fixture_name/scripts/lib/$s differs from toolkit/scripts/lib/$s" >&2
      ERRORS=$((ERRORS + 1))
    fi
  done
done

if [[ "$ERRORS" -gt 0 ]]; then
  echo "Re-copy maintenance scripts from toolkit or re-run emit-from-intake on fixtures." >&2
  exit 1
fi
echo "Fixture maintenance scripts match toolkit."
exit 0
