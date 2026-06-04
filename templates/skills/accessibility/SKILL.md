---
name: accessibility
description: Applies this team's accessibility checklist for interactive UI (labels, focus, keyboard, contrast). Use for PR a11y review, form work, modals, or when the user mentions accessibility or WCAG.
disable-model-invocation: true
---

# Accessibility

## Checklist (interactive UI)

- [ ] Visible focus styles on keyboard navigation
- [ ] Buttons/links have accessible names (text or `aria-label`)
- [ ] Form fields have associated `<label>` or `aria-labelledby`
- [ ] Modals: focus trap, Escape to close, return focus on close
- [ ] Images: meaningful `alt` or decorative `alt=""`
- [ ] Color contrast meets team bar (do not rely on color alone for state)

## Project patterns

{{A11Y_PROJECT_PATTERNS}}

## Tools (optional)

Run only when user asks—do not block every task:

```bash
{{A11Y_CMD_OPTIONAL}}
```
