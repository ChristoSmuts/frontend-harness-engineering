#!/usr/bin/env bash
# Block MCP tool calls to servers not on the project allowlist (beforeMCPExecution).
# Exit 2 = block; exit 0 = allow.
set -euo pipefail

ROOT="${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"
cd "$ROOT"

ALLOWLIST=""
for candidate in \
  ".agents/harness/mcp-allowlist.json" \
  ".cursor/harness/mcp-allowlist.json"; do
  if [[ -f "$candidate" ]]; then
    ALLOWLIST="$candidate"
    break
  fi
done

if [[ -z "$ALLOWLIST" ]]; then
  echo "deny-unapproved-mcp: no mcp-allowlist.json; allowing (enable agent_security_hardening to emit allowlist)" >&2
  exit 0
fi

INPUT=$(cat)

server=""
if command -v jq >/dev/null 2>&1; then
  server=$(echo "$INPUT" | jq -r '
    .server // .mcpServer // .serverName // .mcp_server //
    .tool_input.server // .toolInput.server // empty
  ' 2>/dev/null || true)
  if [[ -z "$server" ]]; then
    server=$(echo "$INPUT" | jq -r '
      .. | objects | select(has("server") or has("mcpServer") or has("serverName")) |
      (.server // .mcpServer // .serverName // empty)
    ' 2>/dev/null | head -1 || true)
  fi
else
  server=$(echo "$INPUT" | grep -oE '"(server|mcpServer|serverName)"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 | sed -E 's/.*"[^"]*"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' || true)
fi

if [[ -z "$server" ]]; then
  echo "Blocked: MCP call with unknown server id — cannot verify allowlist." >&2
  exit 2
fi

if command -v jq >/dev/null 2>&1; then
  if jq -e --arg s "$server" 'index($s) != null' "$ALLOWLIST" >/dev/null 2>&1; then
    exit 0
  fi
else
  if grep -qF "\"$server\"" "$ALLOWLIST" 2>/dev/null; then
    exit 0
  fi
fi

echo "Blocked: MCP server '$server' is not in $ALLOWLIST — ask the user before enabling new MCP servers." >&2
exit 2
