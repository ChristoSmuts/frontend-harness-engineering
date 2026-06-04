#!/usr/bin/env bash
# Validate required paths for an emit profile (golden fixture / CI).
# Usage: ./scripts/validate-fixture-manifest.sh [--profile full] [TARGET_ROOT]
# When TARGET_ROOT/intake.answers.json exists, conditional_paths honor features.*.
set -euo pipefail

PROFILE="full"
ROOT="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) shift; PROFILE="${1:?}" ;;
    -h|--help)
      echo "Usage: $0 [--profile full|portable-only|cursor-only] [TARGET_ROOT]"
      exit 0
      ;;
    *) ROOT="$1" ;;
  esac
  shift
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$TOOLKIT/manifest/emit-manifest.json"

cd "$ROOT"
ERRORS=0
INTAKE_FILE="intake.answers.json"

feature_required() {
  local feature="$1"
  if [[ ! -f "$INTAKE_FILE" ]] || ! command -v jq >/dev/null 2>&1; then
    return 0
  fi
  [[ "$(jq -r --arg k "$feature" '.features[$k] // false' "$INTAKE_FILE")" == "true" ]]
}

read_manifest_paths() {
  if command -v jq >/dev/null 2>&1; then
    jq -r --arg p "$PROFILE" '.profiles[$p].required_paths[]?' "$MANIFEST"
    return
  fi
  case "$PROFILE" in
    full)
      printf '%s\n' \
        AGENTS.md HARNESS_CHANGELOG.md agents/ORCHESTRATION.md \
        .cursor/ORCHESTRATION.md .cursor/ORCHESTRATION.cursor-hooks.md \
        .cursor/rules/frontend-core.mdc .cursor/rules/typescript-react.mdc .cursor/rules/ui-components.mdc \
        .cursor/hooks.json .cursor/hooks/verify-frontend.sh .cursor/hooks/verify-frontend.ps1 \
        .agents/skills/frontend-verify/SKILL.md \
        .cursor/skills/frontend-verify/SKILL.md \
        scripts/validate-target-harness.sh scripts/validate-target-harness.ps1 \
        scripts/sync-skills.sh scripts/sync-skills.ps1
      ;;
    *)
      echo "jq required for profile: $PROFILE" >&2
      exit 1
      ;;
  esac
}

while IFS= read -r path; do
  [[ -z "$path" ]] && continue
  if [[ ! -e "$path" ]]; then
    echo "ERROR: missing required path for profile $PROFILE: $path" >&2
    ERRORS=$((ERRORS + 1))
  fi
done < <(read_manifest_paths)

if command -v jq >/dev/null 2>&1; then
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    path=$(jq -r '.path' <<<"$entry")
    feature=$(jq -r '.feature' <<<"$entry")
    profiles=$(jq -r '.profiles | join(" ")' <<<"$entry")
    if ! echo "$profiles" | grep -qw "$PROFILE"; then
      continue
    fi
    if ! feature_required "$feature"; then
      continue
    fi
    if [[ ! -e "$path" ]]; then
      echo "ERROR: missing conditional path (feature=$feature) for profile $PROFILE: $path" >&2
      ERRORS=$((ERRORS + 1))
    fi
  done < <(jq -c '.conditional_paths[]?' "$MANIFEST")
fi

if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi
echo "Manifest validation OK (profile=$PROFILE, root=$ROOT)"
exit 0
