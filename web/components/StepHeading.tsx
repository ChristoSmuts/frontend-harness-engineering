export function StepHeading({
  title,
  description,
}: {
  title: string;
  description?: string;
}) {
  return (
    <header className="mb-[var(--spacing-38)]">
      <h2 className="text-[var(--text-heading-sm)] font-bold leading-[1.1] tracking-[-0.01em] text-obsidian-ink">
        {title}
      </h2>
      {description ? (
        <p className="mt-[var(--spacing-15)] max-w-xl text-[var(--text-body)] leading-[1.61] text-obsidian-ink/80">
          {description}
        </p>
      ) : null}
    </header>
  );
}
