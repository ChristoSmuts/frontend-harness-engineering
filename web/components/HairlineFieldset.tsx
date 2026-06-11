import type { ReactNode } from "react";

export function HairlineFieldset({
  legend,
  children,
}: {
  legend: string;
  children: ReactNode;
}) {
  return (
    <fieldset className="border-0 p-0 pt-[var(--spacing-38)]">
      <div className="mb-[var(--spacing-38)] h-px w-full bg-ash-gray/30" />
      <legend className="mb-[var(--spacing-23)] text-[var(--text-subheading)] font-bold text-obsidian-ink tracking-tight">
        {legend}
      </legend>
      <div className="flex flex-col gap-[var(--spacing-23)]">{children}</div>
    </fieldset>
  );
}
