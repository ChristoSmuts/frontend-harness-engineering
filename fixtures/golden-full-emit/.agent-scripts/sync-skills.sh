#!/usr/bin/env bash
# Sync SKILL.md from canonical skills dir to mirror directories.
# Usage: ./scripts/sync-skills.sh [--canonical DIR] [--orchestration] [--cursor] [--claude] [--all-mirrors]
# Env: CANONICAL_SKILLS_DIR overrides default .agents/skills
set -euo pipefail

ROOT="${AGENT_PROJECT_ROOT:-.}"
cd "$ROOT"

CANONICAL="${CANONICAL_SKILLS_DIR:-.agents/skills}"
SYNC_CURSOR=false
SYNC_CLAUDE=false
SYNC_ORCH=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --canonical)
      shift
      CANONICAL="${1:?--canonical requires a directory path}"
      ;;
    --canonical=*)
      CANONICAL="${1#--canonical=}"
      ;;
    --cursor) SYNC_CURSOR=true ;;
    --claude) SYNC_CLAUDE=true ;;
    --orchestration) SYNC_ORCH=true ;;
    --all-mirrors) SYNC_CURSOR=true; SYNC_CLAUDE=true ;;
    -h|--help)
      echo "Usage: $0 [--canonical DIR] [--cursor] [--claude] [--orchestration] [--all-mirrors]"
      echo "Copies from canonical skills dir to mirror skill dirs. Auto-enables mirrors that exist."
      echo "Default canonical: .agents/skills (override with --canonical or CANONICAL_SKILLS_DIR)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

[[ -d "$CANONICAL" ]] || { echo "Missing canonical dir: $CANONICAL" >&2; exit 1; }

[[ -d ".cursor/skills" ]] && SYNC_CURSOR=true
[[ -d ".claude/skills" ]] && SYNC_CLAUDE=true

if ! $SYNC_CURSOR && ! $SYNC_CLAUDE; then
  echo "No mirror dirs found. Create .cursor/skills or .claude/skills, or pass --cursor / --claude." >&2
  exit 1
fi

sync_skill_dir() {
  local dest="$1"
  mkdir -p "$dest"
  for skill_path in "$CANONICAL"/*/SKILL.md; do
    [[ -f "$skill_path" ]] || continue
    local name
    name=$(basename "$(dirname "$skill_path")")
    mkdir -p "$dest/$name"
    cp "$skill_path" "$dest/$name/SKILL.md"
    echo "Synced $name -> $dest/$name/SKILL.md"
  done
}

$SYNC_CURSOR && sync_skill_dir ".cursor/skills"
$SYNC_CLAUDE && sync_skill_dir ".claude/skills"

if $SYNC_ORCH && [[ -f "agents/ORCHESTRATION.md" ]]; then
  if [[ -d ".claude" ]]; then
    cp "agents/ORCHESTRATION.md" ".claude/ORCHESTRATION.md"
    echo "Synced orchestration -> .claude/ORCHESTRATION.md"
  fi
  if [[ -d ".cursor" ]]; then
    if [[ -f ".cursor/ORCHESTRATION.cursor-hooks.md" ]]; then
      cat "agents/ORCHESTRATION.md" ".cursor/ORCHESTRATION.cursor-hooks.md" > ".cursor/ORCHESTRATION.md"
    else
      cp "agents/ORCHESTRATION.md" ".cursor/ORCHESTRATION.md"
    fi
    echo "Synced orchestration -> .cursor/ORCHESTRATION.md"
  fi
fi

echo "Done (canonical: $CANONICAL)."
