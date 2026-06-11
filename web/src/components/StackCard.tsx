"use client";

import React, { useEffect, useRef } from "react";
import { gsap } from "gsap";
import { Boxes, Cpu, Layout, Shield, Database, Lock, TestTube } from "lucide-react";
import { AnalysisResult } from "@/lib/claude";

interface StackCardProps {
  stack: AnalysisResult["stack"];
}

export function StackCard({ stack }: StackCardProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (containerRef.current) {
      gsap.fromTo(
        containerRef.current.querySelectorAll(".stack-item"),
        { opacity: 0, y: 20, scale: 0.95 },
        {
          opacity: 1,
          y: 0,
          scale: 1,
          duration: 0.5,
          stagger: 0.1,
          ease: "back.out(1.7)",
        }
      );
    }
  }, [stack]);

  const items = [
    { label: "Framework", value: stack.framework, icon: Cpu },
    { label: "UI Library", value: stack.uiLibrary, icon: Layout },
    { label: "Styling", value: stack.styling, icon: Boxes },
    { label: "Backend", value: stack.backend, icon: Database },
    { label: "Auth", value: stack.auth, icon: Lock },
    { label: "Database", value: stack.db, icon: Shield },
    { label: "Testing", value: stack.testing, icon: TestTube },
  ].filter((item) => item.value);

  if (items.length === 0) return null;

  return (
    <div ref={containerRef} className="w-full max-w-4xl mx-auto">
      <div className="bg-zinc-900/80 border border-zinc-800 rounded-2xl p-6 backdrop-blur-sm">
        <div className="flex items-center space-x-3 mb-6">
          <div className="p-2 rounded-lg bg-accent/10 border border-accent/20">
            <Cpu className="w-5 h-5 text-accent" />
          </div>
          <div>
            <h3 className="text-sm font-semibold text-zinc-100">Project Stack Analysis</h3>
            <p className="text-xs text-zinc-500">Automatically identified components</p>
          </div>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
          {items.map((item, i) => (
            <div
              key={i}
              className="stack-item p-4 rounded-xl bg-zinc-950 border border-zinc-900 flex flex-col space-y-2 group hover:border-zinc-700 transition-colors"
            >
              <item.icon className="w-4 h-4 text-zinc-500 group-hover:text-accent transition-colors" />
              <div>
                <p className="text-[10px] uppercase tracking-wider font-bold text-zinc-600">{item.label}</p>
                <p className="text-sm font-medium text-zinc-200 truncate">{item.value}</p>
              </div>
            </div>
          ))}
          {stack.projectType && (
            <div className="stack-item p-4 rounded-xl bg-accent/5 border border-accent/10 flex flex-col space-y-2 col-span-2 sm:col-span-1">
              <Layout className="w-4 h-4 text-accent" />
              <div>
                <p className="text-[10px] uppercase tracking-wider font-bold text-accent/60">Project Type</p>
                <p className="text-sm font-medium text-accent">{stack.projectType}</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
