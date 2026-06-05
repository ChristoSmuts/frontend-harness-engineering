#!/usr/bin/env bash
# Scaffold harness growth artifacts and register skills in orchestration.
# Usage:
#   ./scripts/register-harness-growth.sh --kind skill --name my-skill --when "..." --summary "..."
#   ./scripts/register-harness-growth.sh --kind orchestration-row --name my-skill --when "..."
set -euo pipefail

ROOT="${AGENT_PROJECT_ROOT:-.}"
REGISTER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

KIND=""
NAME=""
WHEN=""
SUMMARY=""
SYNC=true
VALIDATE=true

usage() {
  echo "Usage: $0 --kind skill|orchestration-row --name <kebab-name> [--when \"...\"] [--summary \"...\"] [--no-sync] [--no-validate]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind) shift; KIND="${1:-}" ;;
    --name) shift; NAME="${1:-}" ;;
    --when) shift; WHEN="${1:-}" ;;
    --summary) shift; SUMMARY="${1:-}" ;;
    --no-sync) SYNC=false ;;
    --no-validate) VALIDATE=false ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
  shift
done

[[ -n "$KIND" && -n "$NAME" ]] || usage

CANONICAL="${CANONICAL_SKILLS_DIR:-.agents/skills}"
[[ -d "$CANONICAL" ]] || CANONICAL=".cursor/skills"
[[ -d "$CANONICAL" ]] || { echo "No canonical skills dir found" >&2; exit 1; }

ORCH=""
if [[ -f agents/ORCHESTRATION.md ]]; then
  ORCH="agents/ORCHESTRATION.md"
elif [[ -f .cursor/ORCHESTRATION.md ]]; then
  ORCH=".cursor/ORCHESTRATION.md"
fi

upsert_orchestration_row() {
  local skill_name="$1"
  local when_text="$2"
  [[ -n "$ORCH" ]] || { echo "No ORCHESTRATION.md found; skip orchestration row" >&2; return 0; }

  if grep -q "| \`${skill_name}\` |" "$ORCH" 2>/dev/null; then
    echo "Orchestration row for ${skill_name} already exists"
    return 0
  fi

  local tmp
  tmp=$(mktemp)
  awk -v name="$skill_name" -v when="$when_text" '
    /^## MCP policy/ && !done {
      print "| `" name "` | " when " |"
      done=1
    }
    { print }
  ' "$ORCH" > "$tmp"
  mv "$tmp" "$ORCH"
  echo "Added orchestration row for ${skill_name} in ${ORCH}"
}

if [[ "$KIND" == "skill" ]]; then
  [[ -n "$WHEN" && -n "$SUMMARY" ]] || { echo "--when and --summary required for --kind skill" >&2; exit 1; }
  dest="${CANONICAL%/}/${NAME}/SKILL.md"
  if [[ -f "$dest" ]]; then
    echo "Skill already exists: $dest"
  else
    mkdir -p "$(dirname "$dest")"
    cat > "$dest" <<EOF
---
name: ${NAME}
description: ${SUMMARY} Use when ${WHEN}
disable-model-invocation: true
---

# ${NAME}

## When to use

- ${WHEN}

## Instructions

<!-- Add project-specific guidance here (max ~15 lines per growth patch). -->

## Project-specific notes

- Created via harness self-improvement (failure ledger).
EOF
    echo "Created $dest"
  fi
  upsert_orchestration_row "$NAME" "$WHEN"
elif [[ "$KIND" == "orchestration-row" ]]; then
  [[ -n "$WHEN" ]] || { echo "--when required for --kind orchestration-row" >&2; exit 1; }
  upsert_orchestration_row "$NAME" "$WHEN"
else
  echo "Unknown --kind: $KIND (use skill or orchestration-row)" >&2
  exit 1
fi

if $SYNC; then
  if [[ -f "$REGISTER_SCRIPT_DIR/sync-skills.sh" ]]; then
    bash "$REGISTER_SCRIPT_DIR/sync-skills.sh" --all-mirrors --orchestration 2>/dev/null || true
  fi
fi

if $VALIDATE; then
  if [[ -f "$REGISTER_SCRIPT_DIR/validate-target-harness.sh" ]]; then
    bash "$REGISTER_SCRIPT_DIR/validate-target-harness.sh" . || exit 1
  fi
fi

echo "register-harness-growth complete"
