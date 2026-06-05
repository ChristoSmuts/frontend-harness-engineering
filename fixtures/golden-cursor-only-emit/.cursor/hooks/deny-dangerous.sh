#!/usr/bin/env bash
# Deny dangerous shell patterns (stdin JSON from agent hooks — Cursor/Codex).
# Exit 2 = block; exit 0 = allow.
set -euo pipefail

ROOT="${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"
LIB=""
for candidate in \
  "$ROOT/scripts/lib/shell-guard.sh" \
  "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/shell-guard.sh"; do
  if [[ -f "$candidate" ]]; then
    LIB="$candidate"
    break
  fi
done
if [[ -n "$LIB" ]]; then
  # shellcheck disable=SC1090,SC1091
  source "$LIB"
fi

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
  CMD=$(echo "$INPUT" | jq -r '.command // .cmd // empty' 2>/dev/null || true)
else
  CMD=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 | sed 's/"command":"//;s/"$//' || true)
fi

deny_patterns=(
  'prisma migrate'
  'db:migrate'
  'npm run migrate'
  'pnpm migrate'
  'deploy --prod'
  'vercel --prod'
  'rm -rf /'
  "rm -rf \\\\"
  'git push --force'
  'git push -f'
  'git reset --hard'
)

for pat in "${deny_patterns[@]}"; do
  if echo "$CMD" | grep -qiF "$pat"; then
    echo "Blocked: $pat — ask the user to run this manually." >&2
    exit 2
  fi
done

if declare -f shell_guard_is_env_read_command >/dev/null 2>&1; then
  if shell_guard_is_env_read_command "$CMD"; then
    echo "Blocked: reading env or key material via shell — use .env.example and server-side secrets." >&2
    exit 2
  fi
fi

if declare -f shell_guard_is_git_remote_change >/dev/null 2>&1; then
  if shell_guard_is_git_remote_change "$CMD"; then
    echo "Blocked: changing git remotes — ask the user to run this manually." >&2
    exit 2
  fi
fi

if declare -f shell_guard_check_outbound >/dev/null 2>&1; then
  shell_guard_check_outbound "$CMD" || exit 2
fi

exit 0
