#!/usr/bin/env bash
# Deny dangerous shell patterns (stdin JSON from Cursor hooks — adjust per harness docs).
# Exit 2 = block; exit 0 = allow.
set -euo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | head -1 || true)

deny_patterns=(
  'prisma migrate'
  'db:migrate'
  'npm run migrate'
  'pnpm migrate'
  'deploy --prod'
  'vercel --prod'
  'rm -rf /'
  'rm -rf \\'
)

for pat in "${deny_patterns[@]}"; do
  if echo "$CMD" | grep -qiF "$pat"; then
    echo "Blocked: $pat — ask the user to run this manually." >&2
    exit 2
  fi
done

exit 0
