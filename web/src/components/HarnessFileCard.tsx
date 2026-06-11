"use client";

import React, { useState, useEffect, useRef } from "react";
import { gsap } from "gsap";
import { Check, ChevronRight, Download, ExternalLink } from "lucide-react";
import { HarnessFile } from "@/lib/claude";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface HarnessFileCardProps {
  file: HarnessFile;
  isSelected: boolean;
  onToggle: () => void;
  index: number;
}

export function HarnessFileCard({ file, isSelected, onToggle, index }: HarnessFileCardProps) {
  const [isExpanded, setIsExpanded] = useState(false);
  const cardRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    gsap.fromTo(
      cardRef.current,
      { opacity: 0, x: -20, filter: "blur(10px)" },
      {
        opacity: 1,
        x: 0,
        filter: "blur(0px)",
        duration: 0.6,
        delay: index * 0.1,
        ease: "power2.out",
      }
    );
  }, [index]);

  return (
    <div
      ref={cardRef}
      className={cn(
        "group relative border rounded-xl transition-all duration-300 overflow-hidden",
        isSelected ? "bg-zinc-900/50 border-accent/50 ring-1 ring-accent/20" : "bg-zinc-900/20 border-zinc-800 hover:border-zinc-700"
      )}
    >
      <div className="p-4 flex items-start space-x-4">
        <div
          onClick={onToggle}
          className={cn(
            "mt-1 w-5 h-5 rounded border flex items-center justify-center cursor-pointer transition-colors",
            isSelected ? "bg-accent border-accent text-white" : "border-zinc-700 bg-zinc-950 group-hover:border-zinc-500"
          )}
        >
          {isSelected && <Check className="w-3.5 h-3.5" strokeWidth={3} />}
        </div>

        <div className="flex-grow min-w-0">
          <div className="flex items-center justify-between">
            <h4 className="text-sm font-mono font-medium text-zinc-200 truncate">{file.name}</h4>
            <div className="flex items-center space-x-2">
              <span className={cn(
                "text-[10px] px-1.5 py-0.5 rounded font-bold tracking-tight uppercase",
                file.type === "From skills.sh" ? "bg-emerald-500/10 text-emerald-500" :
                file.type === "AI-generated" ? "bg-accent/10 text-accent" :
                "bg-zinc-800 text-zinc-400"
              )}>
                {file.type}
              </span>
            </div>
          </div>

          <p className="text-xs text-zinc-500 mt-1 line-clamp-2">{file.description}</p>

          <div className="mt-3 flex items-center justify-between">
            <div className="flex items-center space-x-2">
              {file.supportBadges.map((badge, i) => (
                <span key={i} className="text-[10px] text-zinc-600 bg-zinc-950 border border-zinc-900 px-1.5 py-0.5 rounded">
                  {badge}
                </span>
              ))}
              {file.installs && (
                <span className="flex items-center text-[10px] text-emerald-600 font-medium">
                  <Download className="w-2.5 h-2.5 mr-1" />
                  {file.installs.toLocaleString()}
                </span>
              )}
            </div>

            <div className="flex items-center space-x-3">
              {file.url && (
                <a
                  href={file.url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-zinc-500 hover:text-zinc-300 transition-colors"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                </a>
              )}
              <button
                onClick={() => setIsExpanded(!isExpanded)}
                className="text-xs font-medium text-zinc-400 hover:text-zinc-200 flex items-center"
              >
                {isExpanded ? "Hide Preview" : "Preview"}
                <ChevronRight className={cn("w-3.5 h-3.5 ml-1 transition-transform", isExpanded && "rotate-90")} />
              </button>
            </div>
          </div>
        </div>
      </div>

      {isExpanded && (
        <div className="border-t border-zinc-800 bg-zinc-950 p-4 animate-in slide-in-from-top-2 duration-300">
          <pre className="text-[10px] font-mono text-zinc-400 overflow-x-auto p-4 bg-black/50 rounded-lg">
            {file.content}
          </pre>
        </div>
      )}
    </div>
  );
}
