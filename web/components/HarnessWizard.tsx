"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { gsap } from "gsap";
import { useGSAP } from "@gsap/react";
import { AutocompleteField } from "@/components/AutocompleteField";
import { Band } from "@/components/Band";
import { EditorialHeadline } from "@/components/EditorialHeadline";
import { HairlineFieldset } from "@/components/HairlineFieldset";
import { PillButton } from "@/components/PillButton";
import { StepHeading } from "@/components/StepHeading";
import { StepIndicator, WIZARD_STEPS } from "@/components/StepIndicator";
import { mergeWebAnswers } from "@/lib/intake/schema";
import { canonicalSkillsForStrategy } from "@/lib/intake/defaults";
import {
  EMIT_STRATEGY_OPTIONS,
  FORBIDDEN_PATH_OPTIONS,
  FRAMEWORK_OPTIONS,
  PACKAGE_MANAGER_OPTIONS,
  STYLING_OPTIONS,
  TOOL_OPTIONS,
  UI_LIBRARY_OPTIONS,
  joinDelimited,
  joinForbiddenPaths,
  splitDelimited,
} from "@/lib/intake/options";
import type { IntakeAnswers } from "@/lib/intake/types";
import { inferFromPackageJson } from "@/lib/package-json/infer";

const STORAGE_KEY = "harness-wizard-answers";

const EMIT_STRATEGY_LABELS = EMIT_STRATEGY_OPTIONS.map((o) => o.label);

const EMPTY: Partial<IntakeAnswers> = {
  emit_strategy: "full",
  primary_tool: "Cursor",
  tools_in_use: ["Cursor"],
  framework: "Next.js 15 App Router",
  package_manager: "npm",
  project_name: "",
  lint_cmd: "npm run lint",
  typecheck_cmd: "npm run typecheck",
  install_cmd: "npm install",
  routes_path: "src/app",
  components_path: "src/components",
  shared_ui_path: "src/components/ui",
  api_client_path: "src/lib/api",
  forbidden_paths: "`.next`, `dist`, `node_modules`",
  styling: "Tailwind",
  ui_library: "shadcn/ui",
  features: { shadcn: true, harness_self_improve: true },
};

function Field({
  label,
  inferred,
  hint,
  id,
  children,
}: {
  label: string;
  inferred?: boolean;
  hint?: string;
  id?: string;
  children: React.ReactNode;
}) {
  return (
    <div>
      <div className="flex items-baseline justify-between mb-1">
        <label htmlFor={id} className="cursor-pointer">
          {label}
          {inferred ? (
            <span className="ml-2 text-[14px] font-normal text-copper-clay">inferred — confirm</span>
          ) : null}
        </label>
        {hint && <span className="text-[13px] text-ash-gray/60 italic">{hint}</span>}
      </div>
      {children}
    </div>
  );
}

export function HarnessWizard() {
  const [step, setStep] = useState(0);
  const container = useRef<HTMLDivElement>(null);

  useGSAP(() => {
    if (!container.current) return;

    // Animate content blocks entry
    gsap.fromTo(container.current.children,
      {
        y: 20,
        opacity: 0
      },
      {
        y: 0,
        opacity: 1,
        duration: 0.6,
        stagger: 0.1,
        ease: "power4.out"
      }
    );
  }, { dependencies: [step], scope: container });

  const [answers, setAnswers] = useState<Partial<IntakeAnswers>>(EMPTY);
  const [inferredFields, setInferredFields] = useState<Set<string>>(new Set());
  const [fileTree, setFileTree] = useState<string[]>([]);
  const [selectedFiles, setSelectedFiles] = useState<Set<string>>(new Set());
  const [downloading, setDownloading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    try {
      const raw = sessionStorage.getItem(STORAGE_KEY);
      if (raw) setAnswers(JSON.parse(raw) as Partial<IntakeAnswers>);
    } catch {
      /* ignore */
    }
  }, []);

  useEffect(() => {
    sessionStorage.setItem(STORAGE_KEY, JSON.stringify(answers));
  }, [answers]);

  // Handle dynamic command pre-population based on package manager
  const [prevPm, setPrevPm] = useState(answers.package_manager);
  useEffect(() => {
    if (answers.package_manager && answers.package_manager !== prevPm) {
      const pm = answers.package_manager;
      const patch: Partial<IntakeAnswers> = {};

      // Only update if current value matches the previous default or is empty
      const isDefault = (cmd: string | undefined, oldPm: string | undefined) => {
        if (!cmd) return true;
        if (!oldPm) return false;
        const defaults: Record<string, any> = {
          npm: { install: "npm install", lint: "npm run lint", typecheck: "npm run typecheck" },
          pnpm: { install: "pnpm install", lint: "pnpm run lint", typecheck: "pnpm run typecheck" },
          yarn: { install: "yarn install", lint: "yarn lint", typecheck: "yarn typecheck" },
          bun: { install: "bun install", lint: "bun run lint", typecheck: "bun run typecheck" },
        };
        return cmd === defaults[oldPm]?.install || cmd === defaults[oldPm]?.lint || cmd === defaults[oldPm]?.typecheck;
      };

      if (isDefault(answers.install_cmd, prevPm)) {
        patch.install_cmd = pm === "yarn" ? "yarn install" : `${pm} install`;
      }
      if (isDefault(answers.lint_cmd, prevPm)) {
        patch.lint_cmd = pm === "yarn" ? "yarn lint" : `${pm} run lint`;
      }
      if (isDefault(answers.typecheck_cmd, prevPm)) {
        patch.typecheck_cmd = pm === "yarn" ? "yarn typecheck" : `${pm} run typecheck`;
      }

      if (Object.keys(patch).length > 0) {
        setAnswers(prev => ({ ...prev, ...patch }));
      }
      setPrevPm(pm);
    }
  }, [answers.package_manager, prevPm]);

  const update = useCallback((patch: Partial<IntakeAnswers>) => {
    setAnswers((prev) => {
      const next = { ...prev, ...patch };
      if (patch.emit_strategy) {
        next.canonical_skills_dir = canonicalSkillsForStrategy(patch.emit_strategy);
      }
      return next;
    });
  }, []);

  const emitStrategyLabel =
    EMIT_STRATEGY_OPTIONS.find((o) => o.value === answers.emit_strategy)?.label ?? "";

  const onPackageJson = async (file: File | null) => {
    if (!file) return;
    const text = await file.text();
    const { values, inferred } = inferFromPackageJson(text);
    setAnswers((prev) => ({
      ...prev,
      ...values,
      features: { ...prev.features, ...values.features },
    }));
    setInferredFields(new Set(inferred));
  };

  const isInferred = (name: string) => inferredFields.has(name);

  const mergedPreview = useMemo(() => {
    try {
      return mergeWebAnswers(answers);
    } catch {
      return null;
    }
  }, [answers]);

  useEffect(() => {
    if (step !== 5 || !mergedPreview) return;
    fetch("/api/preview", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(mergedPreview),
    })
      .then((r) => r.json())
      .then((d: { paths?: string[] }) => {
        const paths = d.paths ?? [];
        setFileTree(paths);
        setSelectedFiles(new Set(paths));
      })
      .catch(() => setFileTree([]));
  }, [step, mergedPreview]);

  const download = async () => {
    setDownloading(true);
    setError(null);
    try {
      const payload = mergeWebAnswers(answers);
      const res = await fetch("/api/generate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...payload,
          includeFiles: Array.from(selectedFiles),
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error((err as { error?: string }).error ?? "Generate failed");
      }
      const blob = await res.blob();
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${payload.project_name.replace(/[^a-zA-Z0-9._-]+/g, "-")}-harness.zip`;
      a.click();
      URL.revokeObjectURL(url);
      setStep(6);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Download failed");
    } finally {
      setDownloading(false);
    }
  };

  const goToStep = (target: number) => {
    if (target < step) setStep(target);
  };

  return (
    <>
      {step !== 6 ? (
      <Band className="min-h-[80vh]">
        <header className="mb-[var(--spacing-68)]">
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-8">
            <div className="max-w-2xl">
              <p
                className="font-normal leading-[0.8] tracking-[-0.02em] text-obsidian-ink"
                style={{
                  fontSize: "clamp(60px, 10vw, var(--text-wordmark))",
                  letterSpacing: "var(--text-wordmark--letter-spacing)",
                }}
              >
                Harness Forge<span className="text-[0.25em] align-top ml-1">®</span>
              </p>
              <EditorialHeadline as="h1" className="mt-[var(--spacing-23)] !text-[var(--text-display)]">
                Agentic Harness Engineering
              </EditorialHeadline>
              <p className="mt-[var(--spacing-23)] text-[var(--text-body)] leading-[1.61] text-obsidian-ink/70 max-w-xl">
                Standardize how AI agents learn your stack, follow your rules, and maintain your code quality.
              </p>
            </div>
            {step === 0 && (
              <div className="flex flex-col gap-4 p-6 border border-ash-gray/20 bg-bone/20 rounded-sm md:max-w-xs">
                 <p className="text-[14px] font-bold uppercase tracking-wider text-ash-gray">Smart Start</p>
                 <p className="text-[15px] text-obsidian-ink/80">Upload <code className="bg-white px-1">package.json</code> to auto-detect your framework and tools.</p>
                 <label className="relative cursor-pointer">
                    <span className="inline-flex w-full items-center justify-center rounded-full border border-obsidian-ink py-2 text-[14px] font-bold hover:bg-obsidian-ink hover:text-white transition-colors">
                      {inferredFields.size > 0 ? "File uploaded" : "Select file"}
                    </span>
                    <input
                      type="file"
                      className="absolute inset-0 opacity-0 cursor-pointer"
                      accept="application/json,.json"
                      onChange={(e) => onPackageJson(e.target.files?.[0] ?? null)}
                    />
                 </label>
              </div>
            )}
          </div>
        </header>

        <div className="grid items-start gap-[var(--spacing-38)] lg:grid-cols-[minmax(0,1fr)_300px] lg:gap-[var(--spacing-119)]">
          <div className="min-w-0" ref={container}>
        {step === 0 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[0].title}
              description="Harness Forge standardizes how AI agents (like Cursor or Claude) understand your project's rules, folder structure, and tech stack."
            />

            <div className="mt-[var(--spacing-38)] space-y-[var(--spacing-23)]">
              <div className="p-6 border border-ash-gray/20 bg-bone/10 rounded-sm">
                <h3 className="text-[17px] font-bold text-obsidian-ink mb-2">Before you start</h3>
                <p className="text-[15px] text-obsidian-ink/70 leading-relaxed">
                  Make sure you have a project ready! If you're starting fresh, scaffold it first:
                </p>
                <code className="block mt-3 p-3 bg-obsidian-ink text-marble-white text-[14px] rounded-sm">
                  npx create-next-app@latest
                </code>
              </div>

              <div className="space-y-4">
                <h3 className="text-[17px] font-bold text-obsidian-ink">What you'll get</h3>
                <ul className="grid grid-cols-1 md:grid-cols-2 gap-4 text-[15px] text-obsidian-ink/70">
                  <li className="flex items-start gap-2">
                    <span className="text-copper-clay">✦</span>
                    <span><strong>Cursor Rules:</strong> Specialized .mdc files for architectural guardrails.</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-copper-clay">✦</span>
                    <span><strong>Claude Skills:</strong> A CLAUDE.md tailored for Claude Code CLI.</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-copper-clay">✦</span>
                    <span><strong>Shared Skills:</strong> Modular agent instructions for common tasks.</span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="text-copper-clay">✦</span>
                    <span><strong>Orchestration:</strong> A central map of your stack for all agents.</span>
                  </li>
                </ul>
              </div>
            </div>

            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton onClick={() => setStep(1)}>I'm ready, start setup</PillButton>
            </div>
          </div>
        )}

        {step === 1 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[1].title}
              description="Give your project a name and choose the package manager your team uses."
            />
            <HairlineFieldset legend="Identity">
              <Field id="project_name" label="What's your project's name?" inferred={isInferred("project_name")}>
                <input
                  id="project_name"
                  value={answers.project_name ?? ""}
                  onChange={(e) => update({ project_name: e.target.value })}
                  placeholder="e.g. my-awesome-app"
                />
              </Field>
              <AutocompleteField
                id="package_manager"
                label="Which package manager do you use?"
                inferred={isInferred("package_manager")}
                options={PACKAGE_MANAGER_OPTIONS}
                allowCustom={false}
                placeholder="Select package manager…"
                value={answers.package_manager ?? "pnpm"}
                onChange={(value) =>
                  update({ package_manager: value as IntakeAnswers["package_manager"] })
                }
              />
            </HairlineFieldset>
            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton variant="ghost" onClick={() => setStep(0)}>
                Back
              </PillButton>
              <PillButton onClick={() => setStep(2)} disabled={!answers.project_name}>
                Continue
              </PillButton>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[2].title}
              description="Describe the framework, styling approach, and component library so agents know your conventions."
            />
            <HairlineFieldset legend="Stack">
              <AutocompleteField
                id="framework"
                mode="multi"
                label="What framework are you building with?"
                inferred={isInferred("framework")}
                options={FRAMEWORK_OPTIONS}
                placeholder="Search frameworks (Next.js, Vite, etc.)…"
                value={splitDelimited(answers.framework)}
                onChange={(values) => update({ framework: joinDelimited(values) })}
              />
              <AutocompleteField
                id="styling"
                mode="multi"
                label="How do you style your components?"
                inferred={isInferred("styling")}
                options={STYLING_OPTIONS}
                placeholder="Search styling (Tailwind, CSS Modules, etc.)…"
                value={splitDelimited(answers.styling)}
                onChange={(values) => update({ styling: joinDelimited(values) })}
              />
              <AutocompleteField
                id="ui_library"
                mode="multi"
                label="Which UI or component library do you use?"
                inferred={isInferred("ui_library")}
                options={UI_LIBRARY_OPTIONS}
                placeholder="Search UI libraries or add your own…"
                value={splitDelimited(answers.ui_library)}
                onChange={(values) => update({ ui_library: joinDelimited(values) })}
              />
            </HairlineFieldset>
            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton variant="ghost" onClick={() => setStep(1)}>
                Back
              </PillButton>
              <PillButton onClick={() => setStep(3)}>Continue</PillButton>
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[3].title}
              description="Point agents at the right scripts and folder structure so they can run checks and edit files without breaking your build."
            />
            <HairlineFieldset legend="Commands and paths">
              <Field id="install_cmd" label="How do agents install dependencies?" inferred={isInferred("install_cmd")} hint="e.g. npm install">
                <input
                  id="install_cmd"
                  value={answers.install_cmd ?? ""}
                  onChange={(e) => update({ install_cmd: e.target.value })}
                />
              </Field>
              <Field id="lint_cmd" label="How do agents run the linter?" inferred={isInferred("lint_cmd")} hint="e.g. npm run lint">
                <input id="lint_cmd" value={answers.lint_cmd ?? ""} onChange={(e) => update({ lint_cmd: e.target.value })} />
              </Field>
              <Field id="typecheck_cmd" label="How do agents check types?" inferred={isInferred("typecheck_cmd")} hint="e.g. npm run typecheck">
                <input
                  id="typecheck_cmd"
                  value={answers.typecheck_cmd ?? ""}
                  onChange={(e) => update({ typecheck_cmd: e.target.value })}
                />
              </Field>
              <Field id="routes_path" label="Where are your routes/pages located?" inferred={isInferred("routes_path")} hint="e.g. src/app">
                <input
                  id="routes_path"
                  value={answers.routes_path ?? ""}
                  onChange={(e) => update({ routes_path: e.target.value })}
                />
              </Field>
              <Field id="components_path" label="Where are your components kept?" inferred={isInferred("components_path")} hint="e.g. src/components">
                <input
                  id="components_path"
                  value={answers.components_path ?? ""}
                  onChange={(e) => update({ components_path: e.target.value })}
                />
              </Field>
              <Field id="shared_ui_path" label="Where is your shared UI library?" inferred={isInferred("shared_ui_path")} hint="e.g. src/components/ui">
                <input
                  id="shared_ui_path"
                  value={answers.shared_ui_path ?? ""}
                  onChange={(e) => update({ shared_ui_path: e.target.value })}
                />
              </Field>
              <Field id="api_client_path" label="Where is your API client code?" inferred={isInferred("api_client_path")} hint="e.g. src/lib/api">
                <input
                  id="api_client_path"
                  value={answers.api_client_path ?? ""}
                  onChange={(e) => update({ api_client_path: e.target.value })}
                />
              </Field>
              <AutocompleteField
                id="forbidden_paths"
                mode="multi"
                label="Which folders should agents NEVER touch?"
                options={FORBIDDEN_PATH_OPTIONS}
                placeholder="Paths agents should not edit…"
                value={splitDelimited(answers.forbidden_paths)}
                onChange={(values) => update({ forbidden_paths: joinForbiddenPaths(values) })}
              />
            </HairlineFieldset>
            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton variant="ghost" onClick={() => setStep(2)}>
                Back
              </PillButton>
              <PillButton onClick={() => setStep(4)}>Continue</PillButton>
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[4].title}
              description="Choose which AI tools you use and which optional skills to include in your harness."
            />
            <HairlineFieldset legend="Configuration">
              <AutocompleteField
                id="emit_strategy"
                label="How should we organize the files?"
                options={EMIT_STRATEGY_LABELS}
                allowCustom={false}
                placeholder="Choose how files are organized…"
                value={emitStrategyLabel}
                onChange={(label) => {
                  const match = EMIT_STRATEGY_OPTIONS.find((o) => o.label === label);
                  if (match) update({ emit_strategy: match.value });
                }}
              />
              <AutocompleteField
                id="primary_tool"
                label="What's your main AI coding tool?"
                options={TOOL_OPTIONS}
                placeholder="Your main coding agent…"
                value={answers.primary_tool ?? "Cursor"}
                onChange={(value) => update({ primary_tool: value })}
              />
              <AutocompleteField
                id="tools_in_use"
                mode="multi"
                label="Which other AI tools do you use?"
                options={TOOL_OPTIONS}
                minItems={1}
                placeholder="Add every agent tool you use…"
                value={answers.tools_in_use ?? []}
                onChange={(tools) => update({ tools_in_use: tools })}
              />
              <div className="flex flex-col gap-2">
                <label className="flex items-center gap-2 font-normal">
                  <input
                    type="checkbox"
                    checked={answers.features?.shadcn ?? false}
                    onChange={(e) =>
                      update({ features: { ...answers.features, shadcn: e.target.checked } })
                    }
                  />
                  shadcn/ui skill
                </label>
                <label className="flex items-center gap-2 font-normal">
                  <input
                    type="checkbox"
                    checked={answers.features?.playwright ?? false}
                    onChange={(e) =>
                      update({ features: { ...answers.features, playwright: e.target.checked } })
                    }
                  />
                  Playwright E2E skill
                </label>
                <label className="flex items-center gap-2 font-normal">
                  <input
                    type="checkbox"
                    checked={answers.features?.harness_self_improve !== false}
                    onChange={(e) =>
                      update({
                        features: { ...answers.features, harness_self_improve: e.target.checked },
                      })
                    }
                  />
                  Harness self-improvement (failure ledger)
                </label>
              </div>
            </HairlineFieldset>
            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton variant="ghost" onClick={() => setStep(3)}>
                Back
              </PillButton>
              <PillButton onClick={() => setStep(5)}>Review</PillButton>
            </div>
          </div>
        )}

        {step === 5 && (
          <div className="max-w-4xl">
            <StepHeading
              title={WIZARD_STEPS[5].title}
              description="Confirm your choices, pick exactly which files you want, then download your custom harness."
            />
          <div className="flex flex-col lg:flex-row gap-[var(--spacing-38)]">
            <div className="lg:w-1/3">
              <HairlineFieldset legend="Summary">
                {mergedPreview ? (
                  <ul className="space-y-3 text-[17px]">
                    <li>
                      <strong>Project:</strong> {mergedPreview.project_name}
                    </li>
                    <li>
                      <strong>Framework:</strong> {mergedPreview.framework}
                    </li>
                    <li>
                      <strong>Layout:</strong> {mergedPreview.emit_strategy}
                    </li>
                    <li>
                      <strong>Tools:</strong> {mergedPreview.tools_in_use.join(", ")}
                    </li>
                  </ul>
                ) : (
                  <p className="text-copper-clay">Fix validation errors before generating.</p>
                )}
              </HairlineFieldset>
              {error ? <p className="mt-4 text-copper-clay">{error}</p> : null}
              <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
                <PillButton variant="ghost" onClick={() => setStep(4)}>
                  Back
                </PillButton>
                <PillButton
                  variant="accent"
                  disabled={!mergedPreview || downloading || selectedFiles.size === 0}
                  onClick={download}
                >
                  {downloading ? "Generating…" : "Download harness zip"}
                </PillButton>
              </div>
            </div>
            <div className="lg:w-2/3">
              <HairlineFieldset legend="Select files to include">
                <div className="mb-6 flex items-center gap-3 p-3 bg-bone/10 border border-ash-gray/20 rounded-sm">
                  <input
                    type="checkbox"
                    id="select-all"
                    checked={fileTree.length > 0 && selectedFiles.size === fileTree.length}
                    onChange={(e) => {
                      if (e.target.checked) {
                        setSelectedFiles(new Set(fileTree));
                      } else {
                        setSelectedFiles(new Set());
                      }
                    }}
                  />
                  <label htmlFor="select-all" className="text-[14px] font-bold cursor-pointer">
                    Select All ({selectedFiles.size} / {fileTree.length})
                  </label>
                </div>
                <ul className="max-h-96 overflow-y-auto font-mono text-[14px] leading-relaxed text-ash-gray space-y-1 border border-ash-gray/10 p-4 bg-bone/5">
                  {fileTree.map((p) => (
                    <li key={p} className="flex items-center gap-2 hover:bg-bone/10 py-0.5 px-1">
                      <input
                        type="checkbox"
                        id={`file-${p}`}
                        checked={selectedFiles.has(p)}
                        onChange={(e) => {
                          const next = new Set(selectedFiles);
                          if (e.target.checked) next.add(p);
                          else next.delete(p);
                          setSelectedFiles(next);
                        }}
                      />
                      <label htmlFor={`file-${p}`} className="cursor-pointer truncate" title={p}>
                        {p}
                      </label>
                    </li>
                  ))}
                </ul>
              </HairlineFieldset>
            </div>
          </div>
          </div>
        )}

          </div>

          <aside className="lg:sticky lg:top-[var(--spacing-38)] lg:self-start">
            <StepIndicator current={step} onStepClick={goToStep} />
          </aside>
        </div>
      </Band>
      ) : null}

      {step === 6 ? (
        <Band tone="dark">
          <div className="max-w-xl">
            <p className="text-[13px] font-bold uppercase tracking-[0.08em] text-bone/70">Complete</p>
            <h2 className="mt-[var(--spacing-15)] text-left text-[var(--text-heading-lg)] font-bold leading-[1.09] tracking-[-0.02em] text-marble-white">
              Your harness is ready
            </h2>
            <p className="mt-[var(--spacing-23)] text-[var(--text-body)] leading-[1.61] text-bone">
              Extract the zip into your project root. Open{" "}
              <code className="text-marble-white">HARNESS_NEXT_STEPS.md</code> inside the archive for
              setup guidance, security notes, and ideas for growing the harness over time.
            </p>
            <p className="mt-[var(--spacing-23)] text-[var(--text-caption)] leading-[1.61] text-bone/80">
              Your answers are saved in this browser session if you want to tweak settings and
              download again.
            </p>
            <PillButton
              className="mt-[var(--spacing-38)] border-marble-white text-marble-white"
              variant="ghost"
              onClick={() => setStep(0)}
            >
              Configure another project
            </PillButton>
          </div>
        </Band>
      ) : null}
    </>
  );
}
