"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
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
  package_manager: "pnpm",
  project_name: "",
  lint_cmd: "pnpm biome check --write .",
  typecheck_cmd: "pnpm exec tsc --noEmit",
  install_cmd: "pnpm install",
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
  children,
}: {
  label: string;
  inferred?: boolean;
  children: React.ReactNode;
}) {
  return (
    <div>
      <label>
        {label}
        {inferred ? (
          <span className="ml-2 text-[14px] font-normal text-copper-clay">inferred — confirm</span>
        ) : null}
      </label>
      {children}
    </div>
  );
}

export function HarnessWizard() {
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState<Partial<IntakeAnswers>>(EMPTY);
  const [inferredFields, setInferredFields] = useState<Set<string>>(new Set());
  const [fileTree, setFileTree] = useState<string[]>([]);
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
      .then((d: { paths?: string[] }) => setFileTree(d.paths ?? []))
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
        body: JSON.stringify(payload),
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
      <Band>
        <header className="mb-[var(--spacing-68)] max-w-3xl">
          <p
            className="font-normal leading-[0.85] tracking-[-0.02em] text-obsidian-ink"
            style={{ fontSize: "clamp(52px, 10vw, var(--text-wordmark))" }}
          >
            Harness
          </p>
          <EditorialHeadline as="h1" className="mt-[var(--spacing-23)] !text-[var(--text-heading-lg)]">
            Configure your coding agents
          </EditorialHeadline>
          <p className="mt-[var(--spacing-23)] text-[var(--text-body)] leading-[1.61] text-obsidian-ink/80">
            Tell us about your frontend project and download a tailored harness — rules, skills, and
            orchestration files your AI agents can read from day one.
          </p>
        </header>

        <div className="grid items-start gap-[var(--spacing-38)] lg:grid-cols-[minmax(0,1fr)_260px] lg:gap-[var(--spacing-68)]">
          <div className="min-w-0">
        {step === 0 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[0].title}
              description="Walk through a short questionnaire about your stack, then download a zip you can extract into any frontend repository."
            />
            <HairlineFieldset legend="Optional: package.json">
              <p className="text-ash-gray">Upload to pre-fill stack and commands. We never store your file.</p>
              <input
                type="file"
                accept="application/json,.json"
                onChange={(e) => onPackageJson(e.target.files?.[0] ?? null)}
              />
            </HairlineFieldset>
            <div className="mt-[var(--spacing-38)] flex gap-[var(--spacing-13)]">
              <PillButton onClick={() => setStep(1)}>Start questionnaire</PillButton>
            </div>
          </div>
        )}

        {step === 1 && (
          <div className="max-w-xl">
            <StepHeading
              title={WIZARD_STEPS[1].title}
              description="Give your project a name and choose the package manager your team uses."
            />
            <HairlineFieldset legend="Project identity">
              <Field label="Project name" inferred={isInferred("project_name")}>
                <input
                  value={answers.project_name ?? ""}
                  onChange={(e) => update({ project_name: e.target.value })}
                />
              </Field>
              <AutocompleteField
                label="Package manager"
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
            <HairlineFieldset legend="Framework and UI">
              <AutocompleteField
                mode="multi"
                label="Framework"
                inferred={isInferred("framework")}
                options={FRAMEWORK_OPTIONS}
                placeholder="Search frameworks or add your own…"
                value={splitDelimited(answers.framework)}
                onChange={(values) => update({ framework: joinDelimited(values) })}
              />
              <AutocompleteField
                mode="multi"
                label="Styling"
                inferred={isInferred("styling")}
                options={STYLING_OPTIONS}
                placeholder="Search styling tools or add your own…"
                value={splitDelimited(answers.styling)}
                onChange={(values) => update({ styling: joinDelimited(values) })}
              />
              <AutocompleteField
                mode="multi"
                label="UI library"
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
              description="Point agents at the right scripts and folder structure so they run checks and edit files in the correct places."
            />
            <HairlineFieldset legend="Commands and paths">
              <Field label="Install command" inferred={isInferred("install_cmd")}>
                <input
                  value={answers.install_cmd ?? ""}
                  onChange={(e) => update({ install_cmd: e.target.value })}
                />
              </Field>
              <Field label="Lint command" inferred={isInferred("lint_cmd")}>
                <input value={answers.lint_cmd ?? ""} onChange={(e) => update({ lint_cmd: e.target.value })} />
              </Field>
              <Field label="Typecheck command" inferred={isInferred("typecheck_cmd")}>
                <input
                  value={answers.typecheck_cmd ?? ""}
                  onChange={(e) => update({ typecheck_cmd: e.target.value })}
                />
              </Field>
              <Field label="Routes path" inferred={isInferred("routes_path")}>
                <input
                  value={answers.routes_path ?? ""}
                  onChange={(e) => update({ routes_path: e.target.value })}
                />
              </Field>
              <Field label="Components path" inferred={isInferred("components_path")}>
                <input
                  value={answers.components_path ?? ""}
                  onChange={(e) => update({ components_path: e.target.value })}
                />
              </Field>
              <Field label="Shared UI path" inferred={isInferred("shared_ui_path")}>
                <input
                  value={answers.shared_ui_path ?? ""}
                  onChange={(e) => update({ shared_ui_path: e.target.value })}
                />
              </Field>
              <Field label="API client path" inferred={isInferred("api_client_path")}>
                <input
                  value={answers.api_client_path ?? ""}
                  onChange={(e) => update({ api_client_path: e.target.value })}
                />
              </Field>
              <AutocompleteField
                mode="multi"
                label="Forbidden paths"
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
            <HairlineFieldset legend="Agents and layout">
              <AutocompleteField
                label="Harness layout"
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
                label="Primary tool"
                options={TOOL_OPTIONS}
                placeholder="Your main coding agent…"
                value={answers.primary_tool ?? "Cursor"}
                onChange={(value) => update({ primary_tool: value })}
              />
              <AutocompleteField
                mode="multi"
                label="Tools in use"
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
          <div>
            <StepHeading
              title={WIZARD_STEPS[5].title}
              description="Confirm your choices, preview the files that will be included, then download the zip."
            />
          <div className="grid gap-[var(--spacing-38)] md:grid-cols-2">
            <div>
              <HairlineFieldset legend="Summary">
                {mergedPreview ? (
                  <ul className="space-y-2 text-[17px]">
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
                  disabled={!mergedPreview || downloading}
                  onClick={download}
                >
                  {downloading ? "Generating…" : "Download harness zip"}
                </PillButton>
              </div>
            </div>
            <div>
              <HairlineFieldset legend="Files in zip">
                <ul className="max-h-96 overflow-y-auto font-mono text-[14px] leading-relaxed text-ash-gray">
                  {fileTree.map((p) => (
                    <li key={p}>{p}</li>
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
