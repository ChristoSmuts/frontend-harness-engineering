export function StepHeading({
  title,
  description,
}: {
  title: string;
  description?: string;
}) {
  return (
    <header className="mb-[var(--spacing-38)]">
      <h2 className="text-[var(--text-heading)] font-bold leading-[1.1] tracking-tight text-obsidian-ink">
        {title}
      </h2>
      {description ? (
        <p className="mt-[var(--spacing-15)] max-w-xl text-[var(--text-body)] leading-[1.61] text-obsidian-ink/70">
          {description}
        </p>
      ) : null}
    </header>
  );
}
