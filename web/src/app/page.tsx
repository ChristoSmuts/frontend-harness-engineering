"use client";

import React, { useState, useEffect, useRef } from "react";
import { gsap } from "gsap";
import { ProjectInput } from "@/components/ProjectInput";
import { StackCard } from "@/components/StackCard";
import { HarnessSelection } from "@/components/HarnessSelection";
import { analyzeProject, AnalysisResult, ProjectData } from "@/lib/claude";
import { getSkillsForDependencies } from "@/lib/skills";
import { generateHarnessZip, downloadBlob } from "@/lib/zip";
import { Hammer, Settings, ShieldCheck, Sparkles } from "lucide-react";

export default function Home() {
  const [apiKey, setApiKey] = useState("");
  const [showApiKeyInput, setShowApiKeyInput] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<AnalysisResult | null>(null);

  const headerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    // Initial animations
    gsap.fromTo(
      ".hero-content > *",
      { opacity: 0, y: 30 },
      { opacity: 1, y: 0, duration: 0.8, stagger: 0.2, ease: "power3.out" }
    );
  }, []);

  const handleAnalyze = async (data: ProjectData) => {
    if (!apiKey) {
      alert("Please enter an Anthropic API Key first.");
      return;
    }

    setIsLoading(true);
    setResult(null);

    try {
      // 1. Analyze with Claude
      const analysis = await analyzeProject(data, apiKey);

      // 2. Fetch skills.sh integration
      const deps = [
        analysis.stack.framework,
        analysis.stack.uiLibrary,
        analysis.stack.styling,
        analysis.stack.backend,
        analysis.stack.auth,
        analysis.stack.db,
      ].filter(Boolean) as string[];

      const skills = await getSkillsForDependencies(deps);

      // 3. Combine results
      const finalResult: AnalysisResult = {
        ...analysis,
        harnessFiles: [...analysis.harnessFiles, ...skills]
      };

      setResult(finalResult);

      // Scroll to result
      setTimeout(() => {
        window.scrollTo({ top: document.getElementById("results")?.offsetTop ?? 0, behavior: "smooth" });
      }, 100);

    } catch (error) {
      console.error(error);
      alert("Analysis failed. Check your API key and try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleDownload = async (files: any[]) => {
    const blob = await generateHarnessZip(files);
    downloadBlob(blob, "harness-forge-export.zip");
  };

  return (
    <div className="min-h-screen">
      {/* Background Decor */}
      <div className="absolute inset-0 -z-10 overflow-hidden">
        <div className="absolute -top-[10%] -left-[10%] w-[40%] h-[40%] bg-accent/5 blur-[120px] rounded-full" />
        <div className="absolute top-[20%] -right-[10%] w-[30%] h-[30%] bg-accent/10 blur-[100px] rounded-full" />
        <div className="absolute inset-0 bg-[url('/grid.svg')] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))]" />
      </div>

      <nav className="sticky top-0 z-50 w-full border-b border-zinc-800 bg-background/80 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-accent rounded flex items-center justify-center">
              <Hammer className="w-5 h-5 text-white" />
            </div>
            <span className="text-lg font-bold tracking-tight text-zinc-100">HarnessForge</span>
          </div>

          <div className="flex items-center space-x-4">
            {showApiKeyInput ? (
              <div className="flex items-center space-x-2 bg-zinc-900 border border-zinc-800 rounded-lg px-3 py-1.5">
                <Settings className="w-3.5 h-3.5 text-zinc-500" />
                <input
                  type="password"
                  placeholder="Anthropic API Key"
                  className="bg-transparent border-none text-xs text-zinc-300 focus:outline-none w-48"
                  value={apiKey}
                  onChange={(e) => setApiKey(e.target.value)}
                />
                <button
                  onClick={() => setShowApiKeyInput(false)}
                  className="text-[10px] font-bold text-accent uppercase tracking-wider ml-2"
                >
                  Save
                </button>
              </div>
            ) : (
              <button
                onClick={() => setShowApiKeyInput(true)}
                className="text-xs text-zinc-500 hover:text-zinc-300 flex items-center space-x-1"
              >
                <Settings className="w-3.5 h-3.5" />
                <span>API Key Configured</span>
              </button>
            )}
          </div>
        </div>
      </nav>

      <div className="max-w-7xl mx-auto px-4 py-16 sm:py-24">
        <div className="hero-content text-center mb-16 space-y-6">
          <div className="inline-flex items-center space-x-2 px-3 py-1 rounded-full bg-accent/10 border border-accent/20 text-accent text-xs font-medium">
            <Sparkles className="w-3 h-3" />
            <span>Architect Your AI Coding Partner</span>
          </div>
          <h1 className="text-4xl sm:text-6xl font-bold tracking-tight text-zinc-100 max-w-3xl mx-auto">
            Generate the <span className="text-accent">Perfect Harness</span> for your project
          </h1>
          <p className="text-lg text-zinc-500 max-w-2xl mx-auto">
            HarnessForge analyzes your tech stack and constructs a precise environment of rules, skills, and memory files that guide AI agents to produce correct, safe, and idiomatic output.
          </p>
        </div>

        <ProjectInput onAnalyze={handleAnalyze} isLoading={isLoading} />

        {result && (
          <div id="results" className="mt-24 space-y-16 animate-in fade-in duration-1000">
            <StackCard stack={result.stack} />
            <HarnessSelection files={result.harnessFiles} onDownload={handleDownload} />

            <div className="text-center py-20">
              <div className="inline-flex items-center space-x-2 text-zinc-600">
                <ShieldCheck className="w-5 h-5" />
                <span className="text-sm font-medium">Your harness is ready for deployment.</span>
              </div>
            </div>
          </div>
        )}
      </div>

      <footer className="border-t border-zinc-900 py-12">
        <div className="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between space-y-4 sm:space-y-0">
          <p className="text-xs text-zinc-600">© 2024 HarnessForge. Built for the era of AI-orchestrated development.</p>
          <div className="flex items-center space-x-6">
            <a href="#" className="text-xs text-zinc-500 hover:text-zinc-300">GitHub</a>
            <a href="#" className="text-xs text-zinc-500 hover:text-zinc-300">Documentation</a>
            <a href="#" className="text-xs text-zinc-500 hover:text-zinc-300">Privacy</a>
          </div>
        </div>
      </footer>
    </div>
  );
}
