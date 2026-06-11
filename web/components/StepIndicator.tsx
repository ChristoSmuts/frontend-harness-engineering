export const WIZARD_STEPS = [
  { label: "Start", title: "Mission brief", description: "Portable harness setup" },
  { label: "Project", title: "Project identity", description: "Name and package manager" },
  { label: "Stack", title: "Framework & UI", description: "Stack and component library" },
  { label: "Commands", title: "Control & paths", description: "Scripts and folder layout" },
  { label: "Agents", title: "Agent setup", description: "Tools and skills" },
  { label: "Review", title: "Quality check", description: "Preview files and export" },
  { label: "Done", title: "Harness ready", description: "Add to your project" },
] as const;

function StepCircle({
  index,
  isActive,
  isComplete,
}: {
  index: number;
  isActive: boolean;
  isComplete: boolean;
}) {
  if (isComplete) {
    return (
      <span
        aria-hidden
        className="relative z-10 flex size-8 shrink-0 items-center justify-center rounded-full bg-obsidian-ink text-marble-white"
      >
        <svg width="14" height="14" viewBox="0 0 14 14" fill="none" aria-hidden>
          <path
            d="M2.5 7.2 5.8 10.5 11.5 3.8"
            stroke="currentColor"
            strokeWidth="1.75"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </span>
    );
  }

  return (
    <span
      aria-hidden
      className={[
        "relative z-10 flex size-8 shrink-0 items-center justify-center rounded-full border-2 text-[13px] font-bold tabular-nums transition-colors",
        isActive
          ? "border-obsidian-ink bg-marble-white text-obsidian-ink"
          : "border-ash-gray/30 bg-marble-white text-ash-gray",
      ].join(" ")}
    >
      {String(index + 1).padStart(2, "0")}
    </span>
  );
}

function VerticalTracker({
  current,
  onStepClick,
}: {
  current: number;
  onStepClick?: (step: number) => void;
}) {
  return (
    <ol className="flex flex-col">
      {WIZARD_STEPS.map((step, i) => {
        const isActive = i === current;
        const isComplete = i < current;
        const isLast = i === WIZARD_STEPS.length - 1;
        const canNavigate = isComplete && onStepClick;

        return (
          <li key={step.label} className="flex gap-[var(--spacing-15)]">
            <div className="flex w-8 shrink-0 flex-col items-center self-stretch">
              <StepCircle index={i} isActive={isActive} isComplete={isComplete} />
              {!isLast ? (
                <span
                  aria-hidden
                  className={[
                    "my-1 w-px min-h-[var(--spacing-23)] flex-1",
                    isComplete ? "bg-obsidian-ink" : "bg-ash-gray/20",
                  ].join(" ")}
                />
              ) : null}
            </div>

            <div className="min-w-0 flex-1 pb-[var(--spacing-23)] pt-0.5 last:pb-0">
              {canNavigate ? (
                <button
                  type="button"
                  onClick={() => onStepClick(i)}
                  className="group w-full text-left cursor-pointer"
                >
                  <StepLabel step={step} isActive={isActive} isComplete={isComplete} interactive />
                </button>
              ) : (
                <StepLabel step={step} isActive={isActive} isComplete={isComplete} />
              )}
            </div>
          </li>
        );
      })}
    </ol>
  );
}

function StepLabel({
  step,
  isActive,
  isComplete,
  interactive = false,
}: {
  step: (typeof WIZARD_STEPS)[number];
  isActive: boolean;
  isComplete: boolean;
  interactive?: boolean;
}) {
  return (
    <>
      <span
        className={[
          "block text-[15px] leading-tight tracking-[0.01em]",
          isActive ? "font-bold text-obsidian-ink" : isComplete ? "font-bold text-obsidian-ink/80" : "text-ash-gray",
          interactive ? "group-hover:text-copper-clay" : "",
        ].join(" ")}
      >
        {step.label}
      </span>
      <span
        className={[
          "mt-1 block text-[13px] leading-snug",
          isActive ? "text-obsidian-ink/70" : "text-ash-gray/60",
        ].join(" ")}
      >
        {step.description}
      </span>
    </>
  );
}

function MobileProgress({ current }: { current: number }) {
  const step = WIZARD_STEPS[current];
  const progress = ((current + 1) / WIZARD_STEPS.length) * 100;

  return (
    <div className="lg:hidden">
      <div className="mb-[var(--spacing-13)] flex items-baseline justify-between gap-4">
        <p className="text-[13px] font-bold uppercase tracking-[0.08em] text-ash-gray">
          Step {current + 1} of {WIZARD_STEPS.length}
        </p>
        <p className="text-[15px] font-bold text-obsidian-ink">{step.label}</p>
      </div>
      <div
        className="h-px w-full bg-ash-gray/20"
        role="progressbar"
        aria-valuenow={current + 1}
        aria-valuemin={1}
        aria-valuemax={WIZARD_STEPS.length}
        aria-label={`Step ${current + 1}: ${step.title}`}
      >
        <div
          className="h-px bg-copper-clay transition-all duration-300 ease-out"
          style={{ width: `${progress}%` }}
        />
      </div>
      <p className="mt-[var(--spacing-13)] text-[15px] text-ash-gray/70">{step.description}</p>
    </div>
  );
}

export function StepIndicator({
  current,
  onStepClick,
}: {
  current: number;
  onStepClick?: (step: number) => void;
}) {
  return (
    <nav aria-label="Progress">
      <MobileProgress current={current} />

      <div className="hidden lg:block">
        <p className="mb-[var(--spacing-23)] text-[13px] font-bold uppercase tracking-[0.08em] text-ash-gray">
          Your progress
        </p>
        <VerticalTracker current={current} onStepClick={onStepClick} />
      </div>
    </nav>
  );
}
