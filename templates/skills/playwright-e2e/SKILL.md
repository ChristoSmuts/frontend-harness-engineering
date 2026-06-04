---
name: playwright-e2e
description: Runs and authors Playwright E2E tests using this repo's config, base URL, and test layout. Use when the user asks for E2E, browser tests, or Playwright—not for routine lint/typecheck after small edits.
disable-model-invocation: true
---

# Playwright E2E

## Config

- Config file: `{{PLAYWRIGHT_CONFIG_PATH}}`
- Test directory: `{{PLAYWRIGHT_TEST_DIR}}`

## Agent policy

- **Do not** run the full suite after every small UI change (context bloat).
- Prefer a **subset**:

```bash
{{PLAYWRIGHT_SUBSET_CMD}}
```

- Full suite: CI or explicit user request only.

## Authoring

- Use role/locator patterns already in the repo.
- Prefer `data-testid` conventions documented here: {{TESTID_CONVENTION}}

## Local run

```bash
{{PLAYWRIGHT_RUN_CMD}}
```
