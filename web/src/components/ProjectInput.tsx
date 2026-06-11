"use client";

import React, { useState, useCallback } from "react";
import { Upload, FileCode, MessageSquare, X } from "lucide-react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ProjectInputProps {
  onAnalyze: (data: {
    files: Array<{ name: string; content: string }>;
    description: string;
    rawText: string;
  }) => void;
  isLoading: boolean;
}

export function ProjectInput({ onAnalyze, isLoading }: ProjectInputProps) {
  const [files, setFiles] = useState<Array<{ name: string; content: string }>>([]);
  const [description, setDescription] = useState("");
  const [rawText, setRawText] = useState("");
  const [isDragging, setIsDragging] = useState(false);

  const handleFileUpload = useCallback(async (e: React.ChangeEvent<HTMLInputElement> | React.DragEvent) => {
    let uploadedFiles: File[] = [];
    if ("files" in e.target && e.target.files) {
      uploadedFiles = Array.from(e.target.files);
    } else if ("dataTransfer" in e) {
      uploadedFiles = Array.from(e.dataTransfer.files);
    }

    const newFiles = await Promise.all(
      uploadedFiles.map(async (file) => ({
        name: file.name,
        content: await file.text(),
      }))
    );

    setFiles((prev) => [...prev, ...newFiles]);
  }, []);

  const removeFile = (index: number) => {
    setFiles((prev) => prev.filter((_, i) => i !== index));
  };

  const isFormEmpty = files.length === 0 && !description.trim() && !rawText.trim();

  return (
    <div className="w-full max-w-4xl mx-auto space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Left Column: Manifest Files & Description */}
        <div className="space-y-6">
          <div
            className={cn(
              "relative group border-2 border-dashed rounded-xl p-8 transition-all duration-300 flex flex-col items-center justify-center text-center space-y-4",
              isDragging ? "border-accent bg-accent/5" : "border-zinc-800 hover:border-zinc-700 bg-zinc-900/50",
              isLoading && "opacity-50 pointer-events-none"
            )}
            onDragOver={(e) => {
              e.preventDefault();
              setIsDragging(true);
            }}
            onDragLeave={() => setIsDragging(false)}
            onDrop={(e) => {
              e.preventDefault();
              setIsDragging(false);
              handleFileUpload(e);
            }}
          >
            <input
              type="file"
              multiple
              className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
              onChange={handleFileUpload}
              disabled={isLoading}
            />
            <div className="p-3 rounded-full bg-zinc-800 group-hover:bg-zinc-700 transition-colors">
              <Upload className="w-6 h-6 text-zinc-400" />
            </div>
            <div>
              <p className="text-sm font-medium text-zinc-200">Drop project manifest files</p>
              <p className="text-xs text-zinc-500 mt-1">package.json, requirements.txt, Cargo.toml, etc.</p>
            </div>
          </div>

          {files.length > 0 && (
            <div className="grid grid-cols-1 gap-2">
              {files.map((file, i) => (
                <div key={i} className="flex items-center justify-between p-3 rounded-lg bg-zinc-900 border border-zinc-800 group">
                  <div className="flex items-center space-x-3 overflow-hidden">
                    <FileCode className="w-4 h-4 text-accent shrink-0" />
                    <span className="text-xs font-mono text-zinc-300 truncate">{file.name}</span>
                  </div>
                  <button
                    onClick={() => removeFile(i)}
                    className="p-1 hover:bg-zinc-800 rounded text-zinc-500 hover:text-zinc-300 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
              ))}
            </div>
          )}

          <div className="space-y-2">
            <label className="flex items-center space-x-2 text-xs font-medium text-zinc-500 uppercase tracking-wider">
              <MessageSquare className="w-3.5 h-3.5" />
              <span>Project Description</span>
            </label>
            <textarea
              className="w-full min-h-[120px] bg-zinc-900/50 border border-zinc-800 rounded-xl p-4 text-sm text-zinc-300 placeholder:text-zinc-600 focus:outline-none focus:ring-1 focus:ring-accent transition-all resize-none"
              placeholder="Describe your project, tech stack, design system, and any specific constraints..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              disabled={isLoading}
            />
          </div>
        </div>

        {/* Right Column: Raw Text Paste */}
        <div className="space-y-2 flex flex-col">
          <label className="flex items-center space-x-2 text-xs font-medium text-zinc-500 uppercase tracking-wider">
            <FileCode className="w-3.5 h-3.5" />
            <span>Raw Context / Code Snippets</span>
          </label>
          <textarea
            className="w-full flex-grow min-h-[300px] bg-zinc-900/50 border border-zinc-800 rounded-xl p-4 text-xs font-mono text-zinc-300 placeholder:text-zinc-600 focus:outline-none focus:ring-1 focus:ring-accent transition-all resize-none"
            placeholder="// Paste README.md, additional config, or core component snippets for better analysis..."
            value={rawText}
            onChange={(e) => setRawText(e.target.value)}
            disabled={isLoading}
          />
        </div>
      </div>

      <div className="flex justify-center pt-4">
        <button
          onClick={() => onAnalyze({ files, description, rawText })}
          disabled={isLoading || isFormEmpty}
          className={cn(
            "relative px-8 py-4 bg-accent text-white rounded-xl font-medium transition-all duration-300 hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 disabled:pointer-events-none overflow-hidden",
            isLoading && "after:absolute after:inset-0 after:bg-white/10 after:animate-pulse"
          )}
        >
          {isLoading ? (
            <span className="flex items-center space-x-2">
              <svg className="animate-spin h-4 w-4 text-white" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              <span>Analyzing Stack...</span>
            </span>
          ) : (
            "Analyze & Generate Harness"
          )}
        </button>
      </div>
    </div>
  );
}
