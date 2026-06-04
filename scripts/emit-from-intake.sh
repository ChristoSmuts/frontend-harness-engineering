#!/usr/bin/env bash
# Emit harness artifacts from intake answers JSON.
# Usage: ./scripts/emit-from-intake.sh --answers intake/answers.json --target /path/to/repo [--toolkit .] [--merge] [--no-strict]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/substitute-placeholders.sh
source "$SCRIPT_DIR/lib/substitute-placeholders.sh"
# shellcheck source=lib/mdc-to-claude-md.sh
source "$SCRIPT_DIR/lib/mdc-to-claude-md.sh"
# shellcheck source=lib/build-answers-map.sh
source "$SCRIPT_DIR/lib/build-answers-map.sh"

ANSWERS=""
TARGET=""
TOOLKIT="$TOOLKIT_ROOT"
MERGE=false
STRICT=true

usage() {
  echo "Usage: $0 --answers FILE --target DIR [--toolkit DIR] [--merge] [--no-strict]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --answers) shift; ANSWERS="${1:?}" ;;
    --target) shift; TARGET="${1:?}" ;;
    --toolkit) shift; TOOLKIT="${1:?}" ;;
    --merge) MERGE=true ;;
    --no-strict) STRICT=false ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
  shift
done

[[ -n "$ANSWERS" && -n "$TARGET" ]] || usage

if [[ "$ANSWERS" != /* ]]; then
  ANSWERS="$(cd "$(dirname "$ANSWERS")" && pwd)/$(basename "$ANSWERS")"
fi
if [[ "$TOOLKIT" != /* ]]; then
  TOOLKIT="$(cd "$TOOLKIT" && pwd)"
fi

[[ -f "$ANSWERS" ]] || { echo "Missing answers file: $ANSWERS" >&2; exit 1; }
[[ -d "$TOOLKIT/templates" ]] || { echo "Toolkit templates/ not found at $TOOLKIT" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

mkdir -p "$TARGET"
if [[ "$TARGET" != /* ]]; then
  TARGET="$(cd "$TARGET" && pwd)"
fi
cd "$TARGET"

MAP_FILE=""
map_tmp=$(mktemp)
build_answers_map_file "$ANSWERS" "$map_tmp" "$TOOLKIT"
HARNESS_PATHS_FILE=$(mktemp)
build_harness_paths_block "$ANSWERS" > "$HARNESS_PATHS_FILE"
echo "HARNESS_PATHS=__MULTILINE_FILE__" >> "$map_tmp"

emit_strategy=$(jq -r '.emit_strategy' "$ANSWERS")
platform=$(jq -r '.platform_primary // "unix"' "$ANSWERS")
canonical=$(jq -r '.canonical_skills_dir // ".agents/skills/"' "$ANSWERS")
monorepo=$(jq -r '.monorepo // false' "$ANSWERS")
app_path=$(jq -r '.app_package_path // ""' "$ANSWERS")

should_skip() {
  local rel="$1"
  if ! $MERGE; then return 1; fi
  local policy
  policy=$(jq -r --arg p "$rel" '.merge_policy[$p] // "create"' "$ANSWERS")
  [[ "$policy" == "skip" ]]
}

emit_substitute() {
  local template="$1"
  local dest="$2"
  local rel_dest="${dest#./}"
  if should_skip "$rel_dest"; then
    echo "skip $rel_dest (merge_policy)"
    return 0
  fi
  substitute_from_map_file "$template" "$dest" "$map_tmp" "$HARNESS_PATHS_FILE"
  echo "emit $rel_dest"
}

# Maintenance scripts (no substitution)
for s in validate-target-harness.sh validate-target-harness.ps1 sync-skills.sh sync-skills.ps1; do
  dest="scripts/$s"
  if should_skip "$dest"; then continue; fi
  mkdir -p scripts
  cp "$TOOLKIT/scripts/$s" "$dest"
  chmod +x "$dest" 2>/dev/null || true
done

# Core artifacts
emit_substitute "$TOOLKIT/templates/AGENTS.md.template" "AGENTS.md"
emit_substitute "$TOOLKIT/templates/HARNESS_CHANGELOG.md.template" "HARNESS_CHANGELOG.md"

if [[ "$emit_strategy" != "cursor-only" ]]; then
  emit_substitute "$TOOLKIT/templates/ORCHESTRATION.shared.md.template" "agents/ORCHESTRATION.md"
fi

if tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  emit_substitute "$TOOLKIT/templates/ORCHESTRATION.cursor-hooks.md.template" ".cursor/ORCHESTRATION.cursor-hooks.md"
  mkdir -p .curso
  if [[ "$emit_strategy" == "cursor-only" ]]; then
    orch_tmp=$(mktemp)
    substitute_from_map_file "$TOOLKIT/templates/ORCHESTRATION.shared.md.template" "$orch_tmp" "$map_tmp" "$HARNESS_PATHS_FILE"
    cat "$orch_tmp" .cursor/ORCHESTRATION.cursor-hooks.md > .cursor/ORCHESTRATION.md
    rm -f "$orch_tmp"
    echo "emit .cursor/ORCHESTRATION.md"
  elif [[ -f agents/ORCHESTRATION.md && -f .cursor/ORCHESTRATION.cursor-hooks.md ]]; then
    cat agents/ORCHESTRATION.md .cursor/ORCHESTRATION.cursor-hooks.md > .cursor/ORCHESTRATION.md
  fi
fi

if tool_selected "$ANSWERS" "Claude" && [[ "$emit_strategy" == "full" || "$emit_strategy" == "portable-only" ]]; then
  emit_substitute "$TOOLKIT/templates/CLAUDE.md.template" "CLAUDE.md"
fi

if tool_selected "$ANSWERS" "Gemini" ]]; then
  emit_substitute "$TOOLKIT/templates/GEMINI.md.template" "GEMINI.md"
fi

if tool_selected "$ANSWERS" "Codex" && feature_enabled "$ANSWERS" "codex_hooks"; then
  emit_substitute "$TOOLKIT/templates/codex/config.toml.template" ".codex/config.toml"
fi

if feature_enabled "$ANSWERS" "harness_ci_workflow"; then
  emit_substitute "$TOOLKIT/templates/github/workflows/harness-validate.yml.template" ".github/workflows/harness-validate.yml"
fi

# Cursor rules
if tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  for rule in frontend-core typescript-react ui-components; do
    emit_substitute "$TOOLKIT/templates/rules/${rule}.mdc.template" ".cursor/rules/${rule}.mdc"
  done
fi

# Claude rules
if tool_selected "$ANSWERS" "Claude" && [[ "$emit_strategy" == "full" || "$emit_strategy" == "portable-only" ]]; then
  for rule in frontend-core typescript-react ui-components; do
    mdc_template_to_claude_md "$TOOLKIT/templates/rules/${rule}.mdc.template" ".claude/rules/${rule}.md" "$map_tmp"
    echo "emit .claude/rules/${rule}.md"
  done
  if [[ -f agents/ORCHESTRATION.md ]]; then
    mkdir -p .claude
    cp agents/ORCHESTRATION.md .claude/ORCHESTRATION.md
  fi
fi

# Hooks
if tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  shell_guard_on=false
  feature_enabled "$ANSWERS" "shell_guard" && shell_guard_on=true
  hooks_tpl="$TOOLKIT/templates/hooks/hooks.json.template"
  if [[ "$platform" == "windows" ]]; then
    hooks_tpl="$TOOLKIT/templates/hooks/hooks.windows.json.template"
    if ! $shell_guard_on; then
      hooks_tpl="$TOOLKIT/templates/hooks/hooks.windows.no-shell-guard.json.template"
    fi
  elif ! $shell_guard_on; then
    hooks_tpl="$TOOLKIT/templates/hooks/hooks.no-shell-guard.json.template"
  fi
  cp "$hooks_tpl" .cursor/hooks.json
  mkdir -p .cursor/hooks
  for hook_script in verify-frontend.sh verify-frontend.ps1; do
    cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
    chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
  done
  if $shell_guard_on; then
    for hook_script in deny-dangerous.sh deny-dangerous.ps1; do
      cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
      chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
    done
  fi
  for hook_script in verify-frontend.sh verify-frontend.ps1; do
    [[ -f ".cursor/hooks/$hook_script" ]] || continue
    substitute_inplace_file ".cursor/hooks/$hook_script" "$map_tmp" "$HARNESS_PATHS_FILE"
    if [[ "$monorepo" == "true" && -n "$app_path" && "$app_path" != "null" ]]; then
      inject_monorepo_cd ".cursor/hooks/$hook_script" "$app_path"
    else
      remove_monorepo_block ".cursor/hooks/$hook_script"
    fi
  done
  echo "emit .cursor/hooks.json"
fi

# Skills — canonical di
skills_canonical="$canonical"
[[ "$emit_strategy" == "cursor-only" ]] && skills_canonical=".cursor/skills/"

framework_skill_emitted=false
manifest_skills="$TOOLKIT/manifest/emit-manifest.json"
skill_count=$(jq '.skills | length' "$manifest_skills")

for ((i = 0; i < skill_count; i++)); do
  name=$(jq -r ".skills[$i].name" "$manifest_skills")
  tpl=$(jq -r ".skills[$i].template" "$manifest_skills")
  always=$(jq -r ".skills[$i].always // false" "$manifest_skills")
  feat=$(jq -r ".skills[$i].feature // empty" "$manifest_skills")
  fw_match=$(jq -r ".skills[$i].framework_match // empty" "$manifest_skills")

  include=false
  if [[ "$always" == "true" ]]; then include=true; fi
  if [[ -n "$feat" ]] && feature_enabled "$ANSWERS" "$feat"; then include=true; fi
  if [[ -n "$fw_match" ]]; then
    if framework_skill_matches "$ANSWERS" "$fw_match"; then
      if [[ "$fw_match" != "other" ]]; then
        if ! $framework_skill_emitted; then
          include=true
          framework_skill_emitted=true
        else
          include=false
        fi
      else
        if ! $framework_skill_emitted; then include=true; fi
      fi
    fi
  fi

  if ! $include; then continue; fi
  dest="${skills_canonical%/}/${name}/SKILL.md"
  if should_skip "$dest"; then continue; fi
  emit_substitute "$TOOLKIT/$tpl" "$dest"
done

# SKILL_*_WHEN rows for orchestration — minimal defaults
for key in SKILL_SHADCN_WHEN SKILL_NEXT_WHEN SKILL_VITE_WHEN SKILL_DATA_WHEN SKILL_FORMS_WHEN SKILL_E2E_WHEN SKILL_A11Y_WHEN; do
  if ! grep -q "^${key}=" "$map_tmp" 2>/dev/null; then
    echo "${key}=When task matches skill name in ORCHESTRATION.md" >> "$map_tmp"
  fi
done
if [[ -f agents/ORCHESTRATION.md ]]; then
  substitute_inplace_file agents/ORCHESTRATION.md "$map_tmp" "$HARNESS_PATHS_FILE"
fi
if [[ -f .cursor/ORCHESTRATION.md && "$emit_strategy" == "cursor-only" ]]; then
  substitute_inplace_file .cursor/ORCHESTRATION.md "$map_tmp" "$HARNESS_PATHS_FILE"
fi

# Sync mirrors for full emit
if [[ "$emit_strategy" == "full" ]]; then
  bash scripts/sync-skills.sh --all-mirrors --orchestration 2>/dev/null || bash "$TOOLKIT/scripts/sync-skills.sh" --all-mirrors --orchestration
fi

# Validate
validate_args=()
$STRICT && validate_args+=(--strict)
if [[ -f scripts/validate-target-harness.sh ]]; then
  bash scripts/validate-target-harness.sh "${validate_args[@]}" .
elif [[ -f "$TOOLKIT/scripts/validate-target-harness.sh" ]]; then
  bash "$TOOLKIT/scripts/validate-target-harness.sh" "${validate_args[@]}" .
fi

rm -f "$map_tmp" "$HARNESS_PATHS_FILE"
echo "Emit complete -> $TARGET (emit_strategy=$emit_strategy)"
