# Shell conventions (Windows / PowerShell 7)

- **Platform primary:** `windows` — write every Shell-tool command as **PowerShell 7** (`pwsh`) syntax.
- **Do not use bash-only constructs:** `&&`, `||`, `export VAR=`, `$(cmd)` subshells, `<<'EOF'` heredocs, `2>/dev/null`, `rm -rf`, `chmod`, or backslash line continuations.
- **Sequence commands** with `;` or separate Shell invocations — not `&&` (avoids bash/PowerShell mixing).
- **Environment variables:** `$env:NAME = "value"` — not `export NAME=value`.
- **Paths:** quote paths with spaces (`'C:\path with spaces\file'`).
- **Harness scripts:** `pwsh -File scripts\validate-target-harness.ps1` — not `bash scripts/...` unless Git Bash is explicitly the shell.
- **Multi-line strings:** here-strings (`@'...'@` or `@"..."@`) — not bash heredocs.
- **Git commits:** `git commit -m "title" -m "body"` — not bash heredocs.
- **App commands** (`pnpm`, `npm`, `yarn`, `bun`) from AGENTS.md are shell-agnostic and fine as-is.
