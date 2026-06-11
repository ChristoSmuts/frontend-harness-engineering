import type { IntakeAnswers } from "./types";

export const WEB_DEFAULTS: Partial<IntakeAnswers> = {
  delivery_mode: "agent-only",
  source: "web",
  toolkit_path: "web-bundle",
  target_path: ".",
  harness_owner: "solo",
  canonical_skills_dir: ".agents/skills/",
  platform_primary: "unix",
  repo_type: "greenfield",
  monorepo: false,
  scope_globs: "src/**",
  features: {
    shadcn: false,
    playwright: false,
    harness_self_improve: true,
    harness_ci_workflow: false,
    shell_guard: false,
    secret_scan_hook: false,
    codex_hooks: false,
    agent_security_hardening: false,
    gitleaks_ci: false,
  },
};

export function canonicalSkillsForStrategy(emitStrategy: IntakeAnswers["emit_strategy"]): string {
  return emitStrategy === "cursor-only" ? ".cursor/skills/" : ".agents/skills/";
}
