import type { IntakeAnswers } from "@/lib/intake/types";

export type InferredField = keyof IntakeAnswers | "features.shadcn" | "features.playwright";

export interface InferenceResult {
  values: Partial<IntakeAnswers> & { features?: IntakeAnswers["features"] };
  inferred: InferredField[];
}

export function inferFromPackageJson(raw: string): InferenceResult {
  const inferred: InferredField[] = [];
  const values: InferenceResult["values"] = {};
  let pkg: Record<string, unknown>;
  try {
    pkg = JSON.parse(raw) as Record<string, unknown>;
  } catch {
    return { values: {}, inferred: [] };
  }

  if (typeof pkg.name === "string" && pkg.name) {
    values.project_name = pkg.name;
    inferred.push("project_name");
  }

  if (typeof pkg.packageManager === "string") {
    const pm = pkg.packageManager.split("@")[0];
    if (["pnpm", "npm", "yarn", "bun"].includes(pm)) {
      values.package_manager = pm as IntakeAnswers["package_manager"];
      inferred.push("package_manager");
    }
  }

  const deps = {
    ...(pkg.dependencies as Record<string, string> | undefined),
    ...(pkg.devDependencies as Record<string, string> | undefined),
  };
  const scripts = (pkg.scripts as Record<string, string> | undefined) ?? {};

  if (deps.next) {
    const ver = deps.next.replace(/^[\^~]/, "");
    values.framework = `Next.js ${ver.split(".")[0]} App Router`;
    inferred.push("framework");
    values.routes_path = "src/app";
    values.components_path = "src/components";
    values.shared_ui_path = "src/components/ui";
    values.api_client_path = "src/lib/api";
    inferred.push("routes_path", "components_path", "shared_ui_path", "api_client_path");
  } else if (deps.vite && deps.react) {
    values.framework = "Vite+React";
    inferred.push("framework");
    values.routes_path = "src/pages";
    values.components_path = "src/components";
    inferred.push("routes_path", "components_path");
  }

  if (deps.tailwindcss || deps["@tailwindcss/postcss"]) {
    values.styling = "Tailwind";
    inferred.push("styling");
  }

  const hasRadix = Object.keys(deps).some((k) => k.startsWith("@radix-ui/"));
  if (hasRadix || deps["class-variance-authority"]) {
    values.ui_library = "shadcn/ui";
    values.features = { ...values.features, shadcn: true };
    inferred.push("ui_library", "features.shadcn");
  }

  if (deps["@playwright/test"]) {
    values.features = { ...values.features, playwright: true };
    inferred.push("features.playwright");
  }

  const pm = values.package_manager ?? "pnpm";
  if (scripts.lint) {
    values.lint_cmd = scripts.lint.startsWith(pm) ? scripts.lint : `${pm} ${scripts.lint}`;
    inferred.push("lint_cmd");
  } else if (deps["@biomejs/biome"]) {
    values.lint_cmd = `${pm} biome check --write .`;
    inferred.push("lint_cmd");
  }

  if (scripts.typecheck) {
    values.typecheck_cmd = scripts.typecheck;
    inferred.push("typecheck_cmd");
  } else if (scripts.build?.includes("tsc")) {
    values.typecheck_cmd = scripts.build;
    inferred.push("typecheck_cmd");
  } else if (deps.typescript) {
    values.typecheck_cmd = `${pm} exec tsc --noEmit`;
    inferred.push("typecheck_cmd");
  }

  if (scripts.test && deps.vitest) {
    values.unit_test_single_cmd = `${pm} vitest run path/to/file.test.tsx`;
    inferred.push("unit_test_single_cmd");
  }

  values.install_cmd = `${pm} install`;
  if (!inferred.includes("package_manager")) inferred.push("install_cmd");
  else inferred.push("install_cmd");

  values.forbidden_paths = "`.next`, `dist`, `node_modules`";
  if (values.framework?.includes("Next")) {
    /* already set */
  }

  return { values, inferred };
}
