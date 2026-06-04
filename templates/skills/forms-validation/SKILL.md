---
name: forms-validation
description: Builds forms with this project's validation stack (Zod, React Hook Form, etc.) and accessible labels and errors. Use when adding or editing forms, inputs, or client-side validation schemas.
disable-model-invocation: true
---

# Forms and validation

## Stack

- Validation: **{{VALIDATION_LIB}}**
- Forms: **{{FORM_LIB}}**
- Reference implementation: `{{FORMS_REFERENCE_PATH}}`

## Conventions

- Define schemas once; infer TypeScript types from schema where the repo does.
- Associate every input with a label; show inline errors from resolver/state.
- Submit handlers: loading/disabled state on button; handle server errors without losing field state.

## shadcn Form

If using shadcn Form + RHF, follow patterns in existing `FormField` usage—copy a nearby form before inventing new structure.

## Security

- Do not log passwords, tokens, or OTP values in `console.*` or error reports.
- Login/signup and auth flows: follow skill **`frontend-security`** and existing auth patterns.
