---
name: shadcn-components
description: Adds and composes shadcn/ui components using this repo's components.json, Radix primitives, and Tailwind tokens. Use when adding UI components, dialogs, sheets, forms, data tables, or when the user mentions shadcn, Radix, or the design system.
disable-model-invocation: true
---

# shadcn/ui components

## Config

- `components.json` path: `components.json`
- UI output directory: `src/components`
- Tailwind / tokens: `src/app/globals.css`

## Adding components

Use the project's documented CLI (typical):

```bash
pnpm dlx shadcn@latest add
```

Example: `pnpm dlx shadcn@latest add button`

Do not hand-copy large primitive files if the CLI is the team standard.

## Conventions

- Compose from existing `components/ui/*` before creating one-off duplicates.
- Use `cn()` utility and design tokens—avoid hardcoded colors that bypass the theme.
- Match existing variant and size patterns in neighboring components.

## Accessibility

- Prefer Radix-based shadcn components for focus traps, labels, and keyboard behavior.
- Wire `aria-*` when extending custom interactive elements.