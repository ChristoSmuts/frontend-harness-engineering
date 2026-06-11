#!/usr/bin/env bash
# Emit harness artifacts from intake answers JSON.
# Usage: ./scripts/emit-from-intake.sh --answers intake/answers.json [--target /path/to/repo] [--toolkit .] [--merge] [--no-strict]
#   --target defaults to answers JSON target_path; paths normalized (macOS/Linux/Windows)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=lib/substitute-placeholders.sh
source "$SCRIPT_DIR/lib/substitute-placeholders.sh"
# shellcheck source=lib/mdc-to-claude-md.sh
source "$SCRIPT_DIR/lib/mdc-to-claude-md.sh"
# shellcheck source=lib/build-answers-map.sh
source "$SCRIPT_DIR/lib/build-answers-map.sh"
# shellcheck source=lib/normalize-text-lf.sh
source "$SCRIPT_DIR/lib/normalize-text-lf.sh"
# shellcheck source=lib/normalize-target-path.sh
source "$SCRIPT_DIR/lib/normalize-target-path.sh"

ANSWERS=""
TARGET=""
TOOLKIT="$TOOLKIT_ROOT"
MERGE=false
STRICT=true

usage() {
  echo "Usage: $0 --answers FILE [--target DIR] [--toolkit DIR] [--merge] [--no-strict]"
  echo "  --target defaults to answers JSON target_path when omitted"
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

[[ -n "$ANSWERS" ]] || usage

if [[ "$ANSWERS" != /* ]]; then
  ANSWERS="$(cd "$(dirname "$ANSWERS")" && pwd)/$(basename "$ANSWERS")"
fi
if [[ "$TOOLKIT" != /* ]]; then
  TOOLKIT="$(cd "$TOOLKIT" && pwd)"
fi

[[ -f "$ANSWERS" ]] || { echo "Missing answers file: $ANSWERS" >&2; exit 1; }
[[ -d "$TOOLKIT/templates" ]] || { echo "Toolkit templates/ not found at $TOOLKIT" >&2; exit 1; }

command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

if [[ -z "$TARGET" ]]; then
  TARGET=$(jq -r '.target_path // empty' "$ANSWERS")
fi
[[ -n "$TARGET" ]] || { echo "Missing --target or target_path in answers JSON" >&2; usage; }

TARGET=$(normalize_target_path "$TARGET") || exit 1

if is_toolkit_meta_repo "$TARGET"; then
  echo "ERROR: target_path must not be the Frontend Harness Engineering toolkit root ($TARGET)" >&2
  echo "Provide the frontend app repo path, not this meta-repo." >&2
  exit 1
fi

if ! reject_emit_target_under_toolkit "$TARGET" "$TOOLKIT"; then
  exit 1
fi

cd "$TARGET"

map_tmp=$(mktemp)
build_answers_map_file "$ANSWERS" "$map_tmp" "$TOOLKIT"
HARNESS_PATHS_FILE=$(mktemp)
SHELL_CONVENTIONS_FILE=$(mktemp)
build_harness_paths_block "$ANSWERS" > "$HARNESS_PATHS_FILE"
build_shell_conventions_block "$ANSWERS" "$TOOLKIT" > "$SHELL_CONVENTIONS_FILE"
echo "HARNESS_PATHS=__MULTILINE_FILE__" >> "$map_tmp"
echo "SHELL_CONVENTIONS_BLOCK=__MULTILINE_SHELL__" >> "$map_tmp"

emit_strategy=$(jq -r '.emit_strategy' "$ANSWERS")
delivery_mode=$(jq -r '.delivery_mode // "standard"' "$ANSWERS")
agent_only=false
[[ "$delivery_mode" == "agent-only" ]] && agent_only=true
platform=$(jq -r '.platform_primary // "unix"' "$ANSWERS")
canonical=$(jq -r '.canonical_skills_dir // ".agents/skills/"' "$ANSWERS")
harness_scripts_dir=$(jq -r '.harness_scripts_dir // ".agent-scripts"' "$ANSWERS")
harness_scripts_dir="${harness_scripts_dir%/}"
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
  substitute_from_map_file "$template" "$dest" "$map_tmp" "$HARNESS_PATHS_FILE" "$SHELL_CONVENTIONS_FILE"
  echo "emit $rel_dest"
}

# Maintenance scripts (standard delivery only)
if ! $agent_only; then
  for s in validate-target-harness.sh validate-target-harness.ps1 sync-skills.sh sync-skills.ps1 register-harness-growth.sh register-harness-growth.ps1; do
    dest="${harness_scripts_dir}/$s"
    if should_skip "$dest"; then continue; fi
    mkdir -p "$harness_scripts_dir"
    cp "$TOOLKIT/scripts/$s" "$dest"
    chmod +x "$dest" 2>/dev/null || true
  done
  mkdir -p "${harness_scripts_dir}/lib"
  for s in secret-patterns.sh secret-patterns.ps1 normalize-target-path.sh normalize-target-path.ps1 \
    harness-integrity.sh harness-integrity.ps1 shell-guard.sh shell-guard.ps1; do
    dest="${harness_scripts_dir}/lib/$s"
    if should_skip "$dest"; then continue; fi
    cp "$TOOLKIT/scripts/lib/$s" "$dest"
    chmod +x "$dest" 2>/dev/null || true
  done
fi

# Core artifacts
emit_substitute "$TOOLKIT/templates/AGENTS.md.template" "AGENTS.md"
emit_substitute "$TOOLKIT/templates/HARNESS_CHANGELOG.md.template" "HARNESS_CHANGELOG.md"

if [[ "$emit_strategy" != "cursor-only" ]]; then
  emit_substitute "$TOOLKIT/templates/ORCHESTRATION.shared.md.template" "agents/ORCHESTRATION.md"
fi

# Failure ledger + stop-hook back-pressure (self-improvement loop)
if feature_enabled "$ANSWERS" "harness_self_improve"; then
  ledger_dest=".agents/harness/failure-ledger.json"
  [[ "$emit_strategy" == "cursor-only" ]] && ledger_dest=".cursor/harness/failure-ledger.json"
  emit_substitute "$TOOLKIT/templates/harness/failure-ledger.json.template" "$ledger_dest"
fi

if tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  mkdir -p .cursor
  if ! $agent_only; then
    emit_substitute "$TOOLKIT/templates/ORCHESTRATION.cursor-hooks.md.template" ".cursor/ORCHESTRATION.cursor-hooks.md"
  fi
  if [[ "$emit_strategy" == "cursor-only" ]]; then
    if $agent_only; then
      emit_substitute "$TOOLKIT/templates/ORCHESTRATION.shared.md.template" ".cursor/ORCHESTRATION.md"
    else
      orch_tmp=$(mktemp)
      substitute_from_map_file "$TOOLKIT/templates/ORCHESTRATION.shared.md.template" "$orch_tmp" "$map_tmp" "$HARNESS_PATHS_FILE"
      cat "$orch_tmp" .cursor/ORCHESTRATION.cursor-hooks.md > .cursor/ORCHESTRATION.md
      rm -f "$orch_tmp"
      echo "emit .cursor/ORCHESTRATION.md"
    fi
  elif [[ -f agents/ORCHESTRATION.md ]]; then
    if $agent_only; then
      cp agents/ORCHESTRATION.md .cursor/ORCHESTRATION.md
      echo "emit .cursor/ORCHESTRATION.md"
    elif [[ -f .cursor/ORCHESTRATION.cursor-hooks.md ]]; then
      cat agents/ORCHESTRATION.md .cursor/ORCHESTRATION.cursor-hooks.md > .cursor/ORCHESTRATION.md
      echo "emit .cursor/ORCHESTRATION.md"
    fi
  fi
fi

if tool_selected "$ANSWERS" "Claude" && [[ "$emit_strategy" == "full" || "$emit_strategy" == "portable-only" ]]; then
  emit_substitute "$TOOLKIT/templates/CLAUDE.md.template" "CLAUDE.md"
fi

if tool_selected "$ANSWERS" "Gemini"; then
  emit_substitute "$TOOLKIT/templates/GEMINI.md.template" "GEMINI.md"
fi

if ! $agent_only && tool_selected "$ANSWERS" "Codex" && feature_enabled "$ANSWERS" "codex_hooks"; then
  emit_substitute "$TOOLKIT/templates/codex/config.toml.template" ".codex/config.toml"
fi

if ! $agent_only && feature_enabled "$ANSWERS" "harness_ci_workflow"; then
  emit_substitute "$TOOLKIT/templates/github/workflows/harness-validate.yml.template" ".github/workflows/harness-validate.yml"
fi

if ! $agent_only && feature_enabled "$ANSWERS" "gitleaks_ci"; then
  emit_substitute "$TOOLKIT/templates/github/workflows/secret-scan.yml.template" ".github/workflows/secret-scan.yml"
fi

# Agent security hardening — allowlists + MCP hook
if feature_enabled "$ANSWERS" "agent_security_hardening"; then
  harness_dir=".agents/harness"
  [[ "$emit_strategy" == "cursor-only" ]] && harness_dir=".cursor/harness"
  mkdir -p "$harness_dir"
  if should_skip "$harness_dir/allowed-domains.txt"; then
    :
  else
    cp "$TOOLKIT/templates/harness/allowed-domains.txt.template" "$harness_dir/allowed-domains.txt"
    echo "emit $harness_dir/allowed-domains.txt"
  fi
  if should_skip "$harness_dir/mcp-allowlist.json"; then
    :
  else
    mcp_list=$(jq -c '.mcp_allowlist // empty' "$ANSWERS")
    if [[ -n "$mcp_list" && "$mcp_list" != "null" && "$mcp_list" != "[]" ]]; then
      printf '%s\n' "$mcp_list" > "$harness_dir/mcp-allowlist.json"
    else
      cp "$TOOLKIT/templates/harness/mcp-allowlist.json.template" "$harness_dir/mcp-allowlist.json"
    fi
    echo "emit $harness_dir/mcp-allowlist.json"
  fi
fi

# Cursor rules
if tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  for rule in frontend-core frontend-security shell-conventions typescript-react ui-components; do
    emit_substitute "$TOOLKIT/templates/rules/${rule}.mdc.template" ".cursor/rules/${rule}.mdc"
  done
fi

# Claude rules
if tool_selected "$ANSWERS" "Claude" && [[ "$emit_strategy" == "full" || "$emit_strategy" == "portable-only" ]]; then
  for rule in frontend-core frontend-security shell-conventions typescript-react ui-components; do
    mdc_template_to_claude_md "$TOOLKIT/templates/rules/${rule}.mdc.template" ".claude/rules/${rule}.md" "$map_tmp" "$HARNESS_PATHS_FILE" "$SHELL_CONVENTIONS_FILE"
    echo "emit .claude/rules/${rule}.md"
  done
  if [[ -f agents/ORCHESTRATION.md ]]; then
    mkdir -p .claude
    cp agents/ORCHESTRATION.md .claude/ORCHESTRATION.md
  fi
fi

# Hooks (standard delivery only)
if ! $agent_only && tool_selected "$ANSWERS" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
  shell_guard_on=false
  secret_scan_on=true
  feature_enabled "$ANSWERS" "shell_guard" && shell_guard_on=true
  [[ "$(jq -r '.features.secret_scan_hook // "true"' "$ANSWERS")" == "false" ]] && secret_scan_on=false

  hooks_name="hooks.json.template"
  if [[ "$platform" == "windows" ]]; then
    if $shell_guard_on && $secret_scan_on; then hooks_name="hooks.windows.json.template"
    elif $shell_guard_on; then hooks_name="hooks.windows.no-secret-scan.json.template"
    elif $secret_scan_on; then hooks_name="hooks.windows.no-shell-guard.json.template"
    else hooks_name="hooks.windows.verify-only.json.template"
    fi
  else
    if $shell_guard_on && $secret_scan_on; then hooks_name="hooks.json.template"
    elif $shell_guard_on; then hooks_name="hooks.no-secret-scan.json.template"
    elif $secret_scan_on; then hooks_name="hooks.no-shell-guard.json.template"
    else hooks_name="hooks.verify-only.json.template"
    fi
  fi
  hooks_tpl="$TOOLKIT/templates/hooks/$hooks_name"
  cp "$hooks_tpl" .cursor/hooks.json
  mkdir -p .cursor/hooks
  for hook_script in verify-frontend.sh verify-frontend.ps1 harness-growth-stop.sh harness-growth-stop.ps1; do
    cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
    chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
  done
  if $shell_guard_on; then
    for hook_script in deny-dangerous.sh deny-dangerous.ps1; do
      cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
      chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
    done
  fi
  if $secret_scan_on; then
    for hook_script in scan-secrets.sh scan-secrets.ps1; do
      cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
      chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
    done
  fi
  if feature_enabled "$ANSWERS" "agent_security_hardening"; then
    for hook_script in deny-unapproved-mcp.sh deny-unapproved-mcp.ps1; do
      cp "$TOOLKIT/templates/hooks/$hook_script" ".cursor/hooks/$hook_script" 2>/dev/null || true
      chmod +x ".cursor/hooks/$hook_script" 2>/dev/null || true
    done
    mcp_hook_cmd=".cursor/hooks/deny-unapproved-mcp.sh"
    [[ "$platform" == "windows" ]] && mcp_hook_cmd=".cursor/hooks/deny-unapproved-mcp.ps1"
    if command -v jq >/dev/null 2>&1; then
      tmp_hooks=$(mktemp)
      jq --arg cmd "$mcp_hook_cmd" '
        .hooks.beforeMCPExecution = (
          (.hooks.beforeMCPExecution // []) + [{
            "command": $cmd,
            "timeout": 10,
            "failClosed": true
          }]
        )
      ' .cursor/hooks.json > "$tmp_hooks"
      mv "$tmp_hooks" .cursor/hooks.json
    fi
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
for key in SKILL_SHADCN_WHEN SKILL_NEXT_WHEN SKILL_VITE_WHEN SKILL_DATA_WHEN SKILL_FORMS_WHEN SKILL_E2E_WHEN SKILL_A11Y_WHEN SKILL_SECURITY_WHEN; do
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

# LF-only text (avoid CRLF drift vs golden fixtures and Linux CI)
normalize_text_lf_tree .

# Sync mirrors for full emit
if [[ "$emit_strategy" == "full" ]]; then
  if $agent_only; then
    canonical_dir="${canonical%/}"
    if [[ -d "$canonical_dir" ]]; then
      if tool_selected "$ANSWERS" "Cursor"; then
        mkdir -p .cursor/skills
        for skill_path in "$canonical_dir"/*/SKILL.md; do
          [[ -f "$skill_path" ]] || continue
          name=$(basename "$(dirname "$skill_path")")
          mkdir -p ".cursor/skills/$name"
          cp "$skill_path" ".cursor/skills/$name/SKILL.md"
          echo "mirror $name -> .cursor/skills/$name/SKILL.md"
        done
      fi
      if tool_selected "$ANSWERS" "Claude"; then
        mkdir -p .claude/skills
        for skill_path in "$canonical_dir"/*/SKILL.md; do
          [[ -f "$skill_path" ]] || continue
          name=$(basename "$(dirname "$skill_path")")
          mkdir -p ".claude/skills/$name"
          cp "$skill_path" ".claude/skills/$name/SKILL.md"
          echo "mirror $name -> .claude/skills/$name/SKILL.md"
        done
      fi
      if [[ -f agents/ORCHESTRATION.md && -d .cursor ]]; then
        cp agents/ORCHESTRATION.md .cursor/ORCHESTRATION.md
        echo "emit .cursor/ORCHESTRATION.md (agent-only full)"
      fi
    fi
  elif [[ -f "${harness_scripts_dir}/sync-skills.sh" ]]; then
    bash "${harness_scripts_dir}/sync-skills.sh" --all-mirrors --orchestration
  else
    bash "$TOOLKIT/scripts/sync-skills.sh" --all-mirrors --orchestration
  fi
fi

# Validate (standard delivery only)
if ! $agent_only; then
  validate_args=()
  $STRICT && validate_args+=(--strict)
  if [[ -f "${harness_scripts_dir}/validate-target-harness.sh" ]]; then
    bash "${harness_scripts_dir}/validate-target-harness.sh" "${validate_args[@]}" .
  elif [[ -f "$TOOLKIT/scripts/validate-target-harness.sh" ]]; then
    bash "$TOOLKIT/scripts/validate-target-harness.sh" "${validate_args[@]}" .
  fi
fi

rm -f "$map_tmp" "$HARNESS_PATHS_FILE" "$SHELL_CONVENTIONS_FILE"
echo "Emit complete -> $TARGET (emit_strategy=$emit_strategy delivery_mode=$delivery_mode)"
