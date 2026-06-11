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
      className={`text-left font-bold tracking-[-0.02em] text-obsidian-ink ${className}`}
      style={{ fontSize: "var(--text-display)", lineHeight: 1 }}
    >
      {children}
    </Tag>
  );
}
