import { z } from "zod";
import type { IntakeAnswers } from "./types";
import { WEB_DEFAULTS, canonicalSkillsForStrategy } from "./defaults";

const featuresSchema = z
  .object({
    shadcn: z.boolean().optional(),
    playwright: z.boolean().optional(),
    data_fetching: z.boolean().optional(),
    forms_validation: z.boolean().optional(),
    accessibility: z.boolean().optional(),
    harness_self_improve: z.boolean().optional(),
    agent_security_hardening: z.boolean().optional(),
  })
  .optional();

export const intakeAnswersSchema = z
  .object({
    emit_strategy: z.enum(["full", "portable-only", "cursor-only"]),
    delivery_mode: z.enum(["standard", "agent-only"]).default("agent-only"),
    primary_tool: z.string().min(1),
    harness_owner: z.string().min(1),
    canonical_skills_dir: z.string().min(1),
    tools_in_use: z.array(z.string()).min(1),
    framework: z.string().min(1),
    package_manager: z.enum(["pnpm", "npm", "yarn", "bun"]),
    platform_primary: z.enum(["unix", "windows"]).default("unix"),
    toolkit_path: z.string().min(1),
    target_path: z.string().min(1),
    project_name: z.string().min(1),
    repo_type: z.enum(["greenfield", "brownfield"]).optional(),
    monorepo: z.boolean().optional(),
    lint_cmd: z.string().min(1),
    typecheck_cmd: z.string().min(1),
    install_cmd: z.string().min(1),
    unit_test_single_cmd: z.string().optional(),
    routes_path: z.string().min(1),
    components_path: z.string().min(1),
    shared_ui_path: z.string().min(1),
    api_client_path: z.string().min(1),
    forbidden_paths: z.string().min(1),
    styling: z.string().min(1),
    ui_library: z.string().min(1),
    features: featuresSchema,
    source: z.enum(["web", "bootstrap", "emit-cli"]).optional(),
  })
  .superRefine((data, ctx) => {
    const hasCursor = data.tools_in_use.some((t) => /cursor/i.test(t));
    const hasCli = data.tools_in_use.some((t) => /codex|gemini/i.test(t));
    if (hasCursor && hasCli && data.emit_strategy !== "full") {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "Cursor + Codex/Gemini requires emit_strategy full",
        path: ["emit_strategy"],
      });
    }
    if (!hasCursor && data.emit_strategy === "cursor-only") {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "cursor-only requires Cursor in tools_in_use",
        path: ["emit_strategy"],
      });
    }
    if (data.emit_strategy === "cursor-only" && !/^\.cursor\/skills/.test(data.canonical_skills_dir)) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        message: "cursor-only requires canonical_skills_dir under .cursor/skills",
        path: ["canonical_skills_dir"],
      });
    }
  });

export function mergeWebAnswers(partial: Partial<IntakeAnswers>): IntakeAnswers {
  const emitStrategy = partial.emit_strategy ?? "full";
  const merged = {
    ...WEB_DEFAULTS,
    ...partial,
    emit_strategy: emitStrategy,
    delivery_mode: "agent-only" as const,
    source: "web" as const,
    canonical_skills_dir:
      partial.canonical_skills_dir ?? canonicalSkillsForStrategy(emitStrategy),
    features: { ...WEB_DEFAULTS.features, ...partial.features },
    bootstrap_date: partial.bootstrap_date ?? new Date().toISOString().slice(0, 10),
  };
  return intakeAnswersSchema.parse(merged) as IntakeAnswers;
}
