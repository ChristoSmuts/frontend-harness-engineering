# Shell conventions (Unix / bash)

- **Platform primary:** `unix` — write every Shell-tool command as **bash/sh** syntax.
- **Chaining:** `&&`, `||`, and heredocs (`<<'EOF'`) are fine.
- **Environment variables:** `export VAR=value` or inline `VAR=value cmd`.
- **Harness scripts:** `bash {{HARNESS_SCRIPTS_DIR}}/validate-target-harness.sh` (add `--strict` in CI).
- **App commands** (`pnpm`, `npm`, `yarn`, `bun`) from AGENTS.md are shell-agnostic and fine as-is.
