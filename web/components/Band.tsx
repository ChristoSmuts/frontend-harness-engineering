import type { ReactNode } from "react";

type BandTone = "light" | "dark";

export function Band({
  tone = "light",
  children,
  className = "",
}: {
  tone?: BandTone;
  children: ReactNode;
  className?: string;
}) {
  const bg = tone === "dark" ? "bg-dusk-blue-black text-marble-white" : "bg-marble-white text-obsidian-ink";
  return (
    <section className={`w-full py-[var(--spacing-68)] ${bg} ${className}`}>
      <div className="mx-auto max-w-[1200px] px-[var(--spacing-23)]">{children}</div>
    </section>
  );
}
