import type { ReactNode } from "react";

export function EditorialHeadline({
  children,
  as: Tag = "h1",
  className = "",
}: {
  children: ReactNode;
  as?: "h1" | "h2" | "h3";
  className?: string;
}) {
  return (
    <Tag
      className={`text-left font-bold text-obsidian-ink ${className}`}
      style={{
        fontSize: "var(--text-display)",
        lineHeight: "var(--text-display--line-height)",
        letterSpacing: "var(--text-display--letter-spacing)",
      }}
    >
      {children}
    </Tag>
  );
}
