# Orchestration — Fixture App

How coding agents should work in this frontend repo.

## Context strategy

| Task | Approach |
|------|----------|
| Find files / map an area | Explore sub-agent |
| Implement UI change | Parent reads cited files only |

## Cursor hooks

Stop hook runs `.cursor/hooks/verify-frontend.sh` (silent on success).
