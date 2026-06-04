#!/usr/bin/env bash
# Refresh golden-full-emit canonical skills from templates + sync mirrors (maintainer/CI helper).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE="$TOOLKIT/fixtures/golden-full-emit"
ANSWERS="$FIXTURE/intake.answers.json"
REFRESH_ROOT="$(mktemp -d)"

cleanup() { rm -rf "$REFRESH_ROOT"; }
trap cleanup EXIT

bash "$TOOLKIT/scripts/emit-from-intake.sh" \
  --answers "$ANSWERS" \
  --target "$REFRESH_ROOT" \
  --toolkit "$TOOLKIT" \
  --no-strict

for skill_path in "$REFRESH_ROOT"/.agents/skills/*/SKILL.md; do
  [[ -f "$skill_path" ]] || continue
  name="$(basename "$(dirname "$skill_path")")"
  cp "$skill_path" "$FIXTURE/.agents/skills/$name/SKILL.md"
  cp "$REFRESH_ROOT/.cursor/skills/$name/SKILL.md" "$FIXTURE/.cursor/skills/$name/SKILL.md"
  cp "$REFRESH_ROOT/.claude/skills/$name/SKILL.md" "$FIXTURE/.claude/skills/$name/SKILL.md"
done

for hook in verify-frontend.sh deny-dangerous.sh scan-secrets.sh; do
  [[ -f "$REFRESH_ROOT/.cursor/hooks/$hook" ]] || continue
  cp "$REFRESH_ROOT/.cursor/hooks/$hook" "$FIXTURE/.cursor/hooks/$hook"
done

(
  cd "$FIXTURE"
  bash scripts/sync-skills.sh --all-mirrors
)

bash "$TOOLKIT/scripts/normalize-harness-text-lf.sh" "$FIXTURE"

echo "Refreshed skills and mirrors under $FIXTURE"
