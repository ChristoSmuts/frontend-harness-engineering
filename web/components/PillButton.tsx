import type { ButtonHTMLAttributes, ReactNode } from "react";

type Variant = "filled" | "ghost" | "accent";

export function PillButton({
  variant = "filled",
  children,
  className = "",
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: Variant;
  children: ReactNode;
}) {
  const base =
    "inline-flex items-center justify-center rounded-full px-[var(--spacing-22)] py-[var(--spacing-15)] text-[17px] font-bold transition-all duration-200 disabled:opacity-40 cursor-pointer active:scale-[0.98]";
  const styles = {
    filled: "bg-obsidian-ink text-marble-white hover:bg-obsidian-ink/90",
    ghost: "border border-obsidian-ink bg-transparent text-obsidian-ink hover:bg-obsidian-ink hover:text-marble-white",
    accent: "bg-copper-clay text-marble-white hover:bg-copper-clay/90",
  };
  return (
    <button type="button" className={`${base} ${styles[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
}
