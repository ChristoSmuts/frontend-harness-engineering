#!/usr/bin/env bash
# Deny dangerous shell patterns (stdin JSON from agent hooks — Cursor/Codex).
# Exit 2 = block; exit 0 = allow.
set -euo pipefail

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
  'rm -rf \\'
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

exit 0
