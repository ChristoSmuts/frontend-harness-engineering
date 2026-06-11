# shellcheck shell=bash
# Build placeholder map file from intake answers JSON (writes to out_map path).

build_answers_map_file() {
  local answers_json="$1"
  local out_map="$2"
  local toolkit_root="${3:-.}"

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for emit-from-intake" >&2
    return 1
  fi

  local emit_strategy delivery_mode canonical skills_dir harness_scripts_dir framework platform toolkit_sha bootstrap_date
  emit_strategy=$(jq -r '.emit_strategy' "$answers_json")
  delivery_mode=$(jq -r '.delivery_mode // "standard"' "$answers_json")
  canonical=$(jq -r '.canonical_skills_dir // ".agents/skills/"' "$answers_json")
  skills_dir=$(jq -r '.skills_dir // .canonical_skills_dir // ".agents/skills/"' "$answers_json")
  harness_scripts_dir=$(jq -r '.harness_scripts_dir // ".agent-scripts"' "$answers_json")
  harness_scripts_dir="${harness_scripts_dir%/}"
  framework=$(jq -r '.framework' "$answers_json")
  platform=$(jq -r '.platform_primary // "unix"' "$answers_json")

  toolkit_sha=$(jq -r '.toolkit_sha // ""' "$answers_json")
  if [[ -z "$toolkit_sha" || "$toolkit_sha" == "null" ]]; then
    if git -C "$toolkit_root" rev-parse --short HEAD >/dev/null 2>&1; then
      toolkit_sha=$(git -C "$toolkit_root" rev-parse --short HEAD)
    else
      toolkit_sha="unknown"
    fi
  fi

  bootstrap_date=$(jq -r '.bootstrap_date // ""' "$answers_json")
  if [[ -z "$bootstrap_date" || "$bootstrap_date" == "null" ]]; then
    bootstrap_date=$(date -u +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)
  fi

  local monorepo_flag app_pkg_path monorepo_skill_note cursor_harness_line
  monorepo_flag=$(jq -r '.monorepo // false' "$answers_json")
  app_pkg_path=$(jq -r '.app_package_path // ""' "$answers_json")
  monorepo_skill_note=""
  if [[ "$monorepo_flag" == "true" && -n "$app_pkg_path" && "$app_pkg_path" != "null" ]]; then
    monorepo_skill_note=" (or \`${app_pkg_path}\` in monorepos)"
  fi

  cursor_harness_line=""
  if [[ "$delivery_mode" != "agent-only" ]] && tool_selected "$answers_json" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
    cursor_harness_line=$'- **Cursor:** on stop, hooks run verify scripts; fix all reported errors before finishing'
  fi

  local harness_validate_block=""
  if [[ "$delivery_mode" != "agent-only" ]]; then
    harness_validate_block=$'- **Validate harness:** `bash '"${harness_scripts_dir}"'/validate-target-harness.sh` (Linux/macOS) or `pwsh -File '"${harness_scripts_dir}"'/validate-target-harness.ps1` (Windows/macOS with pwsh); use `--strict` in CI'
  fi

  local codex_hooks_block="# Codex hooks disabled — set features.codex_hooks true and trust repo in Codex"
  if [[ "$delivery_mode" != "agent-only" ]] && [[ "$(jq -r '.features.codex_hooks // false' "$answers_json")" == "true" ]]; then
    if [[ "$platform" == "windows" ]]; then
      codex_hooks_block='[hooks]\nstop = ["pwsh", "-File", ".cursor/hooks/verify-frontend.ps1"]'
    else
      codex_hooks_block='[hooks]\nstop = ["bash", ".cursor/hooks/verify-frontend.sh"]'
    fi
  fi
  codex_hooks_block="${codex_hooks_block//$'\n'/\\n}"

  : > "$out_map"
  jq -r '
    . as $a |
    ($a | to_entries[] | select(.value | type != "object" and type != "array")) |
    (.key | ascii_upcase) + "=" + (.value | tostring)
  ' "$answers_json" >> "$out_map"

  if ! grep -q '^UNIT_TEST_SINGLE_CMD=' "$out_map" 2>/dev/null; then
    echo "UNIT_TEST_SINGLE_CMD=N/A — no unit test runner configured" >> "$out_map"
  fi

  {
    echo "EMIT_STRATEGY=$emit_strategy"
    echo "CANONICAL_SKILLS_DIR=$canonical"
    echo "SKILLS_DIR=$skills_dir"
    echo "HARNESS_SCRIPTS_DIR=$harness_scripts_dir"
    echo "PLATFORM_PRIMARY=$platform"
    echo "TOOLKIT_SHA=$toolkit_sha"
    echo "BOOTSTRAP_DATE=$bootstrap_date"
    echo "CODEX_HOOKS_BLOCK=$codex_hooks_block"
    echo "FRAMEWORK=$framework"
    echo "MONOREPO_SKILL_NOTE=$monorepo_skill_note"
    echo "CURSOR_HARNESS_LINE=$cursor_harness_line"
    echo "HARNESS_VALIDATE_BLOCK=$harness_validate_block"
    echo "DELIVERY_MODE=$delivery_mode"
    echo "COMPONENTS_JSON_PATH=$(jq -r '.components_json_path // "components.json"' "$answers_json")"
    echo "TOKENS_PATH=$(jq -r '.tokens_path // "src/app/globals.css"' "$answers_json")"
    echo "SHADCN_ADD_CMD=$(jq -r '.shadcn_add_cmd // "pnpm dlx shadcn@latest add"' "$answers_json")"
    echo "SERVER_ACTIONS_PATTERN=$(jq -r '.server_actions_pattern // "src/app/actions/*.ts"' "$answers_json")"
    echo "PATH_ALIAS=$(jq -r '.path_alias // "@/"' "$answers_json")"
    echo "COMPONENT_NAMING=$(jq -r '.component_naming // "PascalCase files"' "$answers_json")"
    echo "UI_RULE_GLOBS=$(jq -r '.ui_rule_globs // "**/components/**, **/app/**"' "$answers_json")"
    echo "UI_LIBRARY_SPECIFIC_RULES=$(jq -r '.ui_library_specific_rules // "- Use existing primitives before adding new UI patterns."' "$answers_json")"
    echo "SKILL_SHADCN_WHEN=shadcn/ui components and primitives"
    echo "SKILL_NEXT_WHEN=App Router routes and RSC boundaries"
    echo "SKILL_VITE_WHEN=N/A — skill not installed"
    echo "SKILL_DATA_WHEN=N/A — skill not installed"
    echo "SKILL_FORMS_WHEN=N/A — skill not installed"
    echo "SKILL_E2E_WHEN=N/A — skill not installed"
    echo "SKILL_A11Y_WHEN=N/A — skill not installed"
    echo "SKILL_SECURITY_WHEN=auth, env, API keys, or security-sensitive UI/API work"
  } >> "$out_map"

  local public_prefix auth_stack
  public_prefix=$(jq -r '.public_env_prefix // ""' "$answers_json")
  if [[ -z "$public_prefix" || "$public_prefix" == "null" ]]; then
    if echo "$framework" | grep -qiE 'next|remix|nuxt|sveltekit|astro'; then
      public_prefix="NEXT_PUBLIC_"
    elif echo "$framework" | grep -qiE 'vite|vue'; then
      public_prefix="VITE_"
    else
      public_prefix="NEXT_PUBLIC_"
    fi
  fi
  auth_stack=$(jq -r '.auth_stack // "none (follow existing patterns)"' "$answers_json")
  {
    echo "PUBLIC_ENV_PREFIX=$public_prefix"
    echo "AUTH_STACK=$auth_stack"
    echo "SHELL_AGENTS_LINE=$(build_shell_agents_line "$answers_json")"
    echo "VERIFY_CMDS_BLOCK=$(build_verify_cmds_block "$answers_json" main)"
    echo "UNIT_VERIFY_CMDS_BLOCK=$(build_verify_cmds_block "$answers_json" unit)"
  } >> "$out_map"
}

build_shell_conventions_block() {
  local answers_json="$1"
  local toolkit_root="$2"
  local platform fragment harness_scripts_dir delivery_mode
  delivery_mode=$(jq -r '.delivery_mode // "standard"' "$answers_json")
  platform=$(jq -r '.platform_primary // "unix"' "$answers_json")
  if [[ "$delivery_mode" == "agent-only" ]]; then
    fragment="$toolkit_root/templates/fragments/SHELL_CONVENTIONS.agent-only.md"
    if [[ -f "$fragment" ]]; then
      cat "$fragment"
    else
      printf '%s' "follow project shell conventions in lint/typecheck commands above"
    fi
    return 0
  fi
  harness_scripts_dir=$(jq -r '.harness_scripts_dir // ".agent-scripts"' "$answers_json")
  harness_scripts_dir="${harness_scripts_dir%/}"
  fragment="$toolkit_root/templates/fragments/SHELL_CONVENTIONS.${platform}.md"
  [[ -f "$fragment" ]] || fragment="$toolkit_root/templates/fragments/SHELL_CONVENTIONS.unix.md"
  sed "s|{{HARNESS_SCRIPTS_DIR}}|${harness_scripts_dir}|g" "$fragment"
}

build_shell_agents_line() {
  local answers_json="$1"
  local platform emit_strategy delivery_mode
  delivery_mode=$(jq -r '.delivery_mode // "standard"' "$answers_json")
  if [[ "$delivery_mode" == "agent-only" ]]; then
    printf '%s' "follow project shell conventions; run lint/typecheck commands in this file before claiming done"
    return 0
  fi
  platform=$(jq -r '.platform_primary // "unix"' "$answers_json")
  emit_strategy=$(jq -r '.emit_strategy' "$answers_json")

  if tool_selected "$answers_json" "Cursor" && [[ "$emit_strategy" != "portable-only" ]]; then
    if [[ "$platform" == "windows" ]]; then
      printf '%s' "use PowerShell 7 syntax for Shell commands — see Cursor rule \`shell-conventions\`"
    else
      printf '%s' "use bash/sh syntax for Shell commands — see Cursor rule \`shell-conventions\`"
    fi
  elif tool_selected "$answers_json" "Claude" && [[ "$emit_strategy" == "full" || "$emit_strategy" == "portable-only" ]]; then
    if [[ "$platform" == "windows" ]]; then
      printf '%s' "use PowerShell 7 syntax for Shell commands — see Claude rule \`shell-conventions\`"
    else
      printf '%s' "use bash/sh syntax for Shell commands — see Claude rule \`shell-conventions\`"
    fi
  else
    if [[ "$platform" == "windows" ]]; then
      printf '%s' 'use PowerShell 7 syntax for Shell commands'
    else
      printf '%s' 'use bash/sh syntax for Shell commands'
    fi
  fi
}

build_verify_cmds_block() {
  local answers_json="$1"
  local kind="$2"
  local platform lint typecheck unit block
  platform=$(jq -r '.platform_primary // "unix"' "$answers_json")

  if [[ "$kind" == "unit" ]]; then
    unit=$(jq -r '.unit_test_single_cmd // "N/A — no unit test runner configured"' "$answers_json")
    if [[ "$platform" == "windows" ]]; then
      block=$'```\n'"${unit}"$'\n```'
    else
      block=$'```bash\n'"${unit}"$'\n```'
    fi
  else
    lint=$(jq -r '.lint_cmd' "$answers_json")
    typecheck=$(jq -r '.typecheck_cmd' "$answers_json")
    if [[ "$platform" == "windows" ]]; then
      block=$'```\n'"${lint}"$'\n'"${typecheck}"$'\n```'
    else
      block=$'```bash\n'"${lint}"$'\n'"${typecheck}"$'\n```'
    fi
  fi
  block="${block//$'\n'/\\n}"
  printf '%s' "$block"
}

build_harness_paths_block() {
  local answers_json="$1"
  local emit_strategy delivery_mode harness_owner platform canonical harness_scripts_dir
  emit_strategy=$(jq -r '.emit_strategy' "$answers_json")
  delivery_mode=$(jq -r '.delivery_mode // "standard"' "$answers_json")
  harness_owner=$(jq -r '.harness_owner' "$answers_json")
  platform=$(jq -r '.platform_primary // "unix"' "$answers_json")
  canonical=$(jq -r '.canonical_skills_dir // ".agents/skills/"' "$answers_json")
  harness_scripts_dir=$(jq -r '.harness_scripts_dir // ".agent-scripts"' "$answers_json")
  harness_scripts_dir="${harness_scripts_dir%/}"

  local lines=()
  if [[ "$delivery_mode" == "agent-only" ]]; then
    lines+=("- **Emit strategy:** ${emit_strategy} · **Delivery:** agent-only · **Harness owner:** ${harness_owner}")
    if [[ "$emit_strategy" == "full" ]]; then
      lines+=("- **Canonical skills:** \`${canonical}\` — edit here; mirrors pre-copied at emit")
    else
      lines+=("- **Canonical skills:** \`${canonical}\` — edit skills in place")
    fi
    lines+=("- **Shared entry:** \`AGENTS.md\` (this file)")
  else
    lines+=("- **Emit strategy:** ${emit_strategy} · **Harness owner:** ${harness_owner} · **Platform primary:** ${platform}")
    if [[ "$emit_strategy" == "full" ]]; then
      lines+=("- **Canonical skills:** \`${canonical}\` — edit here; run \`${harness_scripts_dir}/sync-skills.sh --all-mirrors\` after changes when using mirrors")
    else
      lines+=("- **Canonical skills:** \`${canonical}\` — edit here; run \`${harness_scripts_dir}/sync-skills.sh\` after skill edits")
    fi
    lines+=("- **Harness scripts:** \`${harness_scripts_dir}/\` — validate/sync (not app build scripts)")
    lines+=("- **Shared entry:** \`AGENTS.md\` (this file)")
  fi

  local tools
  tools=$(jq -r '.tools_in_use[]' "$answers_json")

  local has_cursor=false has_claude=false has_codex=false has_gemini=false
  while IFS= read -r t; do
    case "$t" in
      *Cursor*) has_cursor=true ;;
      *Claude*) has_claude=true ;;
      *Codex*) has_codex=true ;;
      *Gemini*) has_gemini=true ;;
    esac
  done <<< "$tools"

  if [[ "$emit_strategy" == "cursor-only" ]]; then
    lines+=("- **Orchestration:** \`.cursor/ORCHESTRATION.md\`")
    if [[ "$delivery_mode" == "agent-only" ]]; then
      lines+=("- **Cursor:** rules \`.cursor/rules/\`, skills \`${canonical}\`")
    else
      lines+=("- **Cursor:** rules \`.cursor/rules/\`, hooks \`.cursor/hooks.json\`, skills \`${canonical}\`")
    fi
  else
    if $has_cursor; then
      lines+=("- **Orchestration:** \`agents/ORCHESTRATION.md\` · Cursor: \`.cursor/ORCHESTRATION.md\`")
      if [[ "$delivery_mode" == "agent-only" ]]; then
        lines+=("- **Cursor:** rules \`.cursor/rules/\`, skills \`.cursor/skills/\` (mirror)")
      else
        lines+=("- **Cursor:** rules \`.cursor/rules/\`, skills \`.cursor/skills/\` (mirror), hooks \`.cursor/hooks.json\`")
      fi
    else
      lines+=("- **Orchestration:** \`agents/ORCHESTRATION.md\`")
    fi
    if $has_claude; then
      lines+=("- **Claude Code:** \`CLAUDE.md\`, rules \`.claude/rules/\`, skills \`.claude/skills/\` (mirror)")
    fi
    if $has_codex; then
      lines+=("- **Codex CLI:** skills \`${canonical}\` (canonical)")
    fi
    if $has_gemini; then
      lines+=("- **Gemini CLI:** skills \`${canonical}\` (canonical)")
    fi
  fi

  local out=""
  local line
  for line in "${lines[@]}"; do
    out+="${line}"$'\n'
  done
  printf '%s' "$out"
}

tool_selected() {
  local answers_json="$1"
  local needle="$2"
  jq -e --arg n "$needle" '.tools_in_use[] | select(test($n;"i"))' "$answers_json" >/dev/null 2>&1
}

feature_enabled() {
  local answers_json="$1"
  local key="$2"
  # Most features default to off when the key is missing.
  # For harness self-improvement we default on so older fixtures/answers still benefit.
  if [[ "$key" == "harness_self_improve" ]]; then
    [[ "$(jq -r --arg k "$key" '.features[$k] // true' "$answers_json")" == "true" ]]
  else
    [[ "$(jq -r --arg k "$key" '.features[$k] // false' "$answers_json")" == "true" ]]
  fi
}

framework_skill_matches() {
  local answers_json="$1"
  local pattern="$2"
  local fw
  fw=$(jq -r '.framework' "$answers_json")
  if [[ "$pattern" == "other" ]]; then
    [[ "$fw" =~ ^[Oo]ther$ ]] && return 0
    return 1
  fi
  echo "$fw" | grep -qiE "$pattern"
}
