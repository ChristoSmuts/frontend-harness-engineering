export type EmitStrategy = "full" | "portable-only" | "cursor-only";
export type DeliveryMode = "standard" | "agent-only";
export type PackageManager = "pnpm" | "npm" | "yarn" | "bun";
export type PlatformPrimary = "unix" | "windows";

export interface IntakeFeatures {
  shadcn?: boolean;
  playwright?: boolean;
  data_fetching?: boolean;
  forms_validation?: boolean;
  accessibility?: boolean;
  shell_guard?: boolean;
  secret_scan_hook?: boolean;
  codex_hooks?: boolean;
  harness_self_improve?: boolean;
  harness_ci_workflow?: boolean;
  agent_security_hardening?: boolean;
  gitleaks_ci?: boolean;
}

export interface IntakeAnswers {
  emit_strategy: EmitStrategy;
  delivery_mode: DeliveryMode;
  primary_tool: string;
  harness_owner: string;
  canonical_skills_dir: string;
  tools_in_use: string[];
  framework: string;
  package_manager: PackageManager;
  platform_primary: PlatformPrimary;
  toolkit_path: string;
  target_path: string;
  project_name: string;
  repo_type?: "greenfield" | "brownfield";
  monorepo?: boolean;
  app_package_path?: string;
  lint_cmd: string;
  typecheck_cmd: string;
  install_cmd: string;
  unit_test_single_cmd?: string;
  routes_path: string;
  components_path: string;
  shared_ui_path: string;
  api_client_path: string;
  forbidden_paths: string;
  styling: string;
  ui_library: string;
  scope_globs?: string;
  mcp_policy?: string;
  mcp_allowlist?: string[];
  public_env_prefix?: string;
  auth_stack?: string;
  features?: IntakeFeatures;
  source?: "web" | "bootstrap" | "emit-cli";
  toolkit_sha?: string;
  bootstrap_date?: string;
}
