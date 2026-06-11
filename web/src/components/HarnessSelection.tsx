"use client";

import React, { useState } from "react";
import { Download } from "lucide-react";
import { HarnessFile } from "@/lib/claude";
import { HarnessFileCard } from "./HarnessFileCard";

interface HarnessSelectionProps {
  files: HarnessFile[];
  onDownload: (selectedFiles: HarnessFile[]) => void;
}

export function HarnessSelection({ files, onDownload }: HarnessSelectionProps) {
  const [selectedNames, setSelectedNames] = useState<Set<string>>(new Set(files.map(f => f.name)));

  const toggleFile = (name: string) => {
    const next = new Set(selectedNames);
    if (next.has(name)) next.delete(name);
    else next.add(name);
    setSelectedNames(next);
  };

  const selectedFiles = files.filter(f => selectedNames.has(f.name));

  return (
    <div className="w-full max-w-4xl mx-auto space-y-8 pb-20">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold text-zinc-100">Select Harness Components</h2>
          <p className="text-sm text-zinc-500 mt-1">
            {selectedFiles.length} of {files.length} components selected
          </p>
        </div>

        <button
          onClick={() => onDownload(selectedFiles)}
          disabled={selectedFiles.length === 0}
          className="flex items-center space-x-2 px-6 py-3 bg-accent text-white rounded-xl font-medium hover:scale-[1.02] active:scale-[0.98] transition-all disabled:opacity-50"
        >
          <Download className="w-4 h-4" />
          <span>Download Harness (.zip)</span>
        </button>
      </div>

      <div className="grid grid-cols-1 gap-4">
        {files.map((file, i) => (
          <HarnessFileCard
            key={file.name}
            file={file}
            index={i}
            isSelected={selectedNames.has(file.name)}
            onToggle={() => toggleFile(file.name)}
          />
        ))}
      </div>
    </div>
  );
}
