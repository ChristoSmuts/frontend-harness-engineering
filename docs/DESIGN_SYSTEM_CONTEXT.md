# Design system context for agents

Keep design system knowledge in **skills and scoped rules**, not in bloated `AGENTS.md`.

## Where context lives

| Topic | Location |
|-------|----------|
| Stack summary | `AGENTS.md` (short) |
| shadcn/Radix usage | skill `shadcn-components` |
| Tokens, Tailwind, UI globs | `.cursor/rules/ui-components.mdc` / `.claude/rules/` |
| Figma / design MCP | `{{MCP_POLICY}}` in orchestration — enable only for design tasks |

## Figma and MCP

- Enable Figma (or browser) MCP **only** for design-to-code or token extraction tasks.
- Disable or close MCP when done to save context.
- Prefer **Code Connect** and checked-in token paths in skills over pasting large design exports into chat.

## When to extend harness

| Signal | Action |
|--------|--------|
| Agent invents colors outside tokens | Add token paths to UI rule or `shadcn-components` skill |
| Wrong primitive (custom button vs shadcn) | Strengthen skill “reuse primitives” section |
| Repeated a11y misses | Enable `accessibility` skill; PR checklist in intake H |

## Framework upgrades

When upgrading Next/React:

1. Update versions in `AGENTS.md` stack line.
2. Revise `next-app-router` or `vite-react` skill sections.
3. Re-run lint/typecheck commands in verify hook if scripts changed.
4. Log in `HARNESS_CHANGELOG.md`.

## See also

- [HARNESS_GROWTH.md](HARNESS_GROWTH.md)
- [FRAMEWORK_MAPPING.md](FRAMEWORK_MAPPING.md)
