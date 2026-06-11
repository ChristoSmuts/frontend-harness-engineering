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
    "inline-flex items-center justify-center rounded-full px-[var(--spacing-22)] py-[var(--spacing-15)] text-[17px] font-bold transition-opacity disabled:opacity-40";
  const styles = {
    filled: "bg-obsidian-ink text-marble-white",
    ghost: "border border-obsidian-ink bg-transparent text-obsidian-ink",
    accent: "bg-copper-clay text-marble-white",
  };
  return (
    <button type="button" className={`${base} ${styles[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
}
