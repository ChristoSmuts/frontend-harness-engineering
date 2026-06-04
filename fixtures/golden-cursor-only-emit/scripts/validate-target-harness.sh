#!/usr/bin/env bash
# Validate harness artifacts in a target frontend repo.
# Usage: ./scripts/validate-target-harness.sh [--strict] [TARGET_ROOT]
# Exit 1 on errors; exit 0 with warnings only (unless --strict).
set -euo pipefail

STRICT=false
ROOT="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true ;;
    -h|--help)
      echo "Usage: $0 [--strict] [TARGET_ROOT]"
      exit 0
      ;;
    *)
      ROOT="$1"
      ;;
  esac
  shift
done

VALIDATE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/normalize-target-path.sh
source "$VALIDATE_SCRIPT_DIR/lib/normalize-target-path.sh"

if [[ "$ROOT" != "." ]]; then
  ROOT=$(normalize_target_path "$ROOT") || exit 1
fi

cd "$ROOT"
# shellcheck source=lib/secret-patterns.sh
if [[ -f "$VALIDATE_SCRIPT_DIR/lib/secret-patterns.sh" ]]; then
  # shellcheck disable=SC1091
  source "$VALIDATE_SCRIPT_DIR/lib/secret-patterns.sh"
fi

if [[ -f "manifest/ARTIFACT_MANIFEST.md" && -f "prompts/MASTER_BOOTSTRAP.md" ]]; then
  echo "Toolkit meta-repo detected; skip target harness validation (use CI validate-toolkit workflow)."
  exit 0
fi

ERRORS=0
WARNINGS=0

warn() { echo "WARN: $*" >&2; WARNINGS=$((WARNINGS + 1)); }
fail() { echo "ERROR: $*" >&2; ERRORS=$((ERRORS + 1)); }

agents_mentions() {
  [[ -f AGENTS.md ]] && grep -qiE "$1" AGENTS.md
}

check_emit_strategy_tools() {
  local strategy="$1"
  [[ -n "$strategy" ]] || return 0

  if [[ "$strategy" == "cursor-only" && -f agents/ORCHESTRATION.md ]]; then
    fail "emit_strategy cursor-only must not keep agents/ORCHESTRATION.md (canonical orchestration is .cursor/ORCHESTRATION.md)"
  fi

  if [[ "$strategy" != "full" ]]; then
    if agents_mentions '(\*\*Cursor\*\*|Cursor:)' && agents_mentions '(Codex|Gemini)'; then
      fail "emit_strategy $strategy incompatible: Cursor and Codex/Gemini CLI both documented in AGENTS.md (use full)"
    fi
  fi

  if [[ "$strategy" == "cursor-only" ]]; then
    if agents_mentions '(Codex|Gemini|Claude)'; then
      fail "emit_strategy cursor-only incompatible with Codex, Gemini, or Claude Code documented in AGENTS.md"
    fi
    if [[ -d .agents/skills ]] && agents_mentions '(Codex|Gemini)'; then
      fail "emit_strategy cursor-only with .agents/skills/ requires Codex/Gemini in AGENTS.md (use full)"
    fi
  fi

  if [[ "$strategy" == "portable-only" ]]; then
    if agents_mentions 'Claude' && [[ ! -f CLAUDE.md && ! -d .claude/rules ]]; then
      fail "Claude Code documented in AGENTS.md but CLAUDE.md or .claude/rules/ missing (portable-only)"
    fi
    if [[ -d .cursor/skills ]] && [[ ! -d .agents/skills ]]; then
      fail "emit_strategy portable-only with .cursor/skills/ but no .agents/skills/ (canonical hub missing)"
    fi
  fi
}

file_hash() {
  local f="$1"
  if command -v md5sum >/dev/null 2>&1; then
    md5sum "$f" | cut -d' ' -f1
  else
    shasum -a 256 "$f" | cut -d' ' -f1
  fi
}

HARNESS_PATHS=(
  "AGENTS.md"
  "agents"
  ".agents"
  ".cursor"
  ".claude"
)

check_placeholders() {
  local f="$1"
  if grep -q '{{' "$f" 2>/dev/null; then
    fail "Unreplaced placeholder in $f"
  fi
}

for base in "${HARNESS_PATHS[@]}"; do
  [[ -e "$base" ]] || continue
  if [[ -f "$base" ]]; then
    check_placeholders "$base"
  else
    while IFS= read -r -d '' f; do
      case "$f" in
        *frontend-harness-bootstrap*) continue ;;
      esac
      case "$f" in
        *.md|*.mdc|*.sh|*.ps1|*/hooks.json) check_placeholders "$f" ;;
      esac
    done < <(find "$base" -type f \( -name '*.md' -o -name '*.mdc' -o -name '*.sh' -o -name '*.ps1' -o -name 'hooks.json' \) -print0 2>/dev/null)
  fi
done

if [[ -f AGENTS.md ]]; then
  lines=$(wc -l < AGENTS.md | tr -d ' ')
  if [[ "$lines" -gt 60 ]]; then
    warn "AGENTS.md has $lines lines (target <= 60); move detail into skills"
  fi

  emit_strategy=""
  if grep -qiE 'emit[[:space:]]*strategy[^a-z]*(full|portable-only|cursor-only)' AGENTS.md; then
    emit_strategy=$(grep -oiE 'emit[[:space:]]*strategy[^a-z]*(full|portable-only|cursor-only)' AGENTS.md | head -1 | grep -oiE '(full|portable-only|cursor-only)$')
  fi

  has_platform=false
  if grep -qiE 'platform[[:space:]]*primary[^a-z]*(unix|windows)' AGENTS.md; then
    has_platform=true
  fi

  if [[ -f .cursor/hooks.json ]]; then
    if [[ -z "$emit_strategy" ]]; then
      fail "AGENTS.md missing emit_strategy (required when .cursor/hooks.json exists)"
    fi
    if ! $has_platform; then
      fail "AGENTS.md missing platform_primary (required when .cursor/hooks.json exists)"
    fi
  fi

  if [[ -n "$emit_strategy" ]]; then
    check_emit_strategy_tools "$emit_strategy"
    case "$emit_strategy" in
      full)
        if [[ ! -d .agents/skills ]]; then
          fail "emit_strategy full but .agents/skills/ is missing"
        fi
        ;;
    esac
  fi

  if [[ -f .cursor/hooks.json ]]; then
    if grep -qi 'verify-frontend\.ps1' .cursor/hooks.json && grep -qiE 'platform[[:space:]]*primary[[:space:]]*:[[:space:]]*unix' AGENTS.md; then
      warn "platform_primary unix but hooks.json uses verify-frontend.ps1"
    elif grep -qi 'verify-frontend\.sh' .cursor/hooks.json && grep -qiE 'platform[[:space:]]*primary[[:space:]]*:[[:space:]]*windows' AGENTS.md; then
      warn "platform_primary windows but hooks.json uses verify-frontend.sh"
    fi
  fi
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for envf in .env .env.local .env.production .env.development; do
    if git ls-files --error-unmatch "$envf" >/dev/null 2>&1; then
      fail "Tracked env file must not be committed: $envf"
    fi
  done
fi

if declare -f secret_scan_file >/dev/null 2>&1; then
  for base in "${HARNESS_PATHS[@]}"; do
    [[ -e "$base" ]] || continue
    if [[ -f "$base" ]]; then
      if ! secret_scan_file "$base"; then
        if $STRICT; then fail "Possible secret literal in harness file: $base"
        else warn "Possible secret literal in harness file: $base"
        fi
      fi
      continue
    fi
    while IFS= read -r -d '' f; do
      case "$f" in
        *frontend-harness-bootstrap*) continue ;;
      esac
      case "$f" in
        *.md|*.mdc) ;;
        *) continue ;;
      esac
      if ! secret_scan_file "$f"; then
        if $STRICT; then fail "Possible secret literal in harness file: $f"
        else warn "Possible secret literal in harness file: $f"
        fi
      fi
    done < <(find "$base" -type f \( -name '*.md' -o -name '*.mdc' \) -print0 2>/dev/null)
  done
fi

if [[ -f .cursor/hooks.json ]]; then
  hooks_json=$(cat .cursor/hooks.json)
  for script in .cursor/hooks/verify-frontend.sh .cursor/hooks/verify-frontend.ps1 .cursor/hooks/deny-dangerous.sh .cursor/hooks/deny-dangerous.ps1 .cursor/hooks/scan-secrets.sh .cursor/hooks/scan-secrets.ps1; do
    base=$(basename "$script")
    if echo "$hooks_json" | grep -q "$base" && [[ ! -f "$script" ]]; then
      fail "hooks.json references missing $script"
    fi
  done
fi

has_verify=false
has_security=false
[[ -f .agents/skills/frontend-verify/SKILL.md ]] && has_verify=true
[[ -f .cursor/skills/frontend-verify/SKILL.md ]] && has_verify=true
[[ -f .agents/skills/frontend-security/SKILL.md ]] && has_security=true
[[ -f .cursor/skills/frontend-security/SKILL.md ]] && has_security=true
if $has_verify && ! $has_security; then
  fail "frontend-security skill missing (required P1 with frontend-verify)"
fi

if [[ -f agents/ORCHESTRATION.md ]] && [[ -f .claude/ORCHESTRATION.md ]]; then
  h_agents=$(file_hash "agents/ORCHESTRATION.md")
  h_claude=$(file_hash ".claude/ORCHESTRATION.md")
  if [[ "$h_agents" != "$h_claude" ]]; then
    warn "ORCHESTRATION.md differs between agents/ and .claude/ (run sync-skills.sh --orchestration)"
  fi
fi

check_mirror_dir() {
  local mirror_base="$1"
  [[ -d .agents/skills ]] || return 0
  [[ -d "$mirror_base" ]] || return 0
  for skill in .agents/skills/*/SKILL.md; do
    [[ -f "$skill" ]] || continue
    local name mirror
    name=$(basename "$(dirname "$skill")")
    mirror="$mirror_base/$name/SKILL.md"
    if [[ -f "$mirror" ]] && ! cmp -s "$skill" "$mirror"; then
      warn "Skill $name differs: canonical vs $mirror_base mirror (run scripts/sync-skills.sh)"
    fi
  done
}

check_mirror_dir ".cursor/skills"
check_mirror_dir ".claude/skills"

echo "Validation complete: $ERRORS error(s), $WARNINGS warning(s)."
if [[ "$ERRORS" -gt 0 ]]; then
  exit 1
fi
if $STRICT && [[ "$WARNINGS" -gt 0 ]]; then
  exit 1
fi
exit 0
