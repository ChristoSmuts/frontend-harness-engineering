"use client";

import {
  useCallback,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type KeyboardEvent,
} from "react";

type BaseProps = {
  label: string;
  options: readonly string[];
  placeholder?: string;
  allowCustom?: boolean;
  inferred?: boolean;
};

type SingleProps = BaseProps & {
  mode?: "single";
  value: string;
  onChange: (value: string) => void;
};

type MultiProps = BaseProps & {
  mode: "multi";
  value: string[];
  onChange: (value: string[]) => void;
  minItems?: number;
};

export type AutocompleteFieldProps = SingleProps | MultiProps;

function normalize(value: string) {
  return value.trim().toLowerCase();
}

function Chip({ label, onRemove }: { label: string; onRemove: () => void }) {
  return (
    <span className="inline-flex max-w-full items-center gap-1.5 rounded-full border border-ash-gray/30 bg-obsidian-ink/[0.03] py-1 pl-3 pr-1.5 text-[14px] leading-tight text-obsidian-ink">
      <span className="truncate">{label}</span>
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          onRemove();
        }}
        aria-label={`Remove ${label}`}
        className="flex size-5 shrink-0 items-center justify-center rounded-full text-ash-gray transition-colors hover:bg-ash-gray/15 hover:text-obsidian-ink cursor-pointer"
      >
        <svg width="10" height="10" viewBox="0 0 10 10" aria-hidden>
          <path
            d="M2 2 8 8M8 2 2 8"
            stroke="currentColor"
            strokeWidth="1.5"
            strokeLinecap="round"
          />
        </svg>
      </button>
    </span>
  );
}

export function AutocompleteField(props: AutocompleteFieldProps) {
  const {
    label,
    options,
    placeholder = "Search or type to add…",
    allowCustom = true,
    inferred = false,
  } = props;

  const isMulti = props.mode === "multi";
  const inputId = useId();
  const listboxId = `${inputId}-listbox`;
  const containerRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const selected = useMemo(
    () => (isMulti ? props.value : props.value ? [props.value] : []),
    [isMulti, props.value],
  );

  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [highlight, setHighlight] = useState(0);

  const selectedSet = useMemo(() => new Set(selected.map(normalize)), [selected]);

  const suggestions = useMemo(() => {
    const q = normalize(query);
    const pool = options.filter((opt) => !selectedSet.has(normalize(opt)));
    const filtered = q ? pool.filter((opt) => normalize(opt).includes(q)) : pool;
    const trimmed = query.trim();
    const canAddCustom =
      allowCustom &&
      trimmed.length > 0 &&
      !selectedSet.has(normalize(trimmed)) &&
      !options.some((opt) => normalize(opt) === normalize(trimmed));

    if (canAddCustom) {
      return [...filtered, `__custom__:${trimmed}`];
    }
    return filtered;
  }, [allowCustom, options, query, selectedSet]);

  const displaySuggestions = useMemo(
    () =>
      suggestions.map((item) =>
        item.startsWith("__custom__:") ? item.slice("__custom__:".length) : item,
      ),
    [suggestions],
  );

  const close = useCallback(() => {
    setOpen(false);
    setHighlight(0);
  }, []);

  useEffect(() => {
    const onPointerDown = (event: MouseEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) close();
    };
    document.addEventListener("mousedown", onPointerDown);
    return () => document.removeEventListener("mousedown", onPointerDown);
  }, [close]);

  const addValue = (raw: string) => {
    const value = raw.trim();
    if (!value) return;

    if (isMulti) {
      const next = props as MultiProps;
      if (selectedSet.has(normalize(value))) return;
      next.onChange([...next.value, value]);
    } else {
      const next = props as SingleProps;
      next.onChange(value);
      close();
    }
    setQuery("");
    setHighlight(0);
  };

  const removeValue = (value: string) => {
    if (isMulti) {
      const next = props as MultiProps;
      const filtered = next.value.filter((v) => v !== value);
      if (next.minItems && filtered.length < next.minItems) return;
      next.onChange(filtered);
    } else {
      (props as SingleProps).onChange("");
    }
    inputRef.current?.focus();
  };

  const pickHighlighted = () => {
    const item = suggestions[highlight];
    if (!item) return;
    if (item.startsWith("__custom__:")) {
      addValue(item.slice("__custom__:".length));
    } else {
      addValue(item);
    }
  };

  const onKeyDown = (event: KeyboardEvent<HTMLInputElement>) => {
    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (!open) setOpen(true);
      setHighlight((h) => Math.min(h + 1, Math.max(suggestions.length - 1, 0)));
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      setHighlight((h) => Math.max(h - 1, 0));
      return;
    }
    if (event.key === "Escape") {
      close();
      return;
    }
    if (event.key === "Enter") {
      event.preventDefault();
      if (open && suggestions.length > 0) {
        pickHighlighted();
      } else if (allowCustom && query.trim()) {
        addValue(query);
      }
      return;
    }
    if (event.key === "Backspace" && !query && isMulti && selected.length > 0) {
      const next = props as MultiProps;
      if (next.minItems && selected.length <= next.minItems) return;
      removeValue(selected[selected.length - 1]);
    }
  };

  const showInput = isMulti || !selected.length;

  return (
    <div ref={containerRef} className="relative">
      <label htmlFor={inputId}>
        {label}
        {inferred ? (
          <span className="ml-2 text-[14px] font-normal text-copper-clay">inferred — confirm</span>
        ) : null}
      </label>

      <div
        className={[
          "mt-0 flex min-h-[calc(var(--spacing-15)*2+1.61*var(--text-caption))] flex-wrap items-center gap-2 border border-ash-gray bg-marble-white px-[var(--spacing-15)] py-[var(--spacing-13)] cursor-text transition-all duration-200",
          open ? "border-obsidian-ink" : "",
        ].join(" ")}
        onClick={() => inputRef.current?.focus()}
      >
        {isMulti
          ? selected.map((item) => <Chip key={item} label={item} onRemove={() => removeValue(item)} />)
          : selected[0]
            ? <Chip label={selected[0]} onRemove={() => removeValue(selected[0])} />
            : null}

        {showInput ? (
          <input
            ref={inputRef}
            id={inputId}
            type="text"
            role="combobox"
            aria-expanded={open}
            aria-controls={listboxId}
            aria-autocomplete="list"
            value={query}
            placeholder={selected.length ? undefined : placeholder}
            className="min-w-[8rem] flex-1 border-0 bg-transparent p-0 text-[var(--text-caption)] outline-none"
            onChange={(e) => {
              setQuery(e.target.value);
              setOpen(true);
              setHighlight(0);
            }}
            onFocus={() => setOpen(true)}
            onKeyDown={onKeyDown}
          />
        ) : (
          <button
            type="button"
            className="flex-1 text-left text-[14px] text-ash-gray cursor-pointer"
            onClick={() => {
              removeValue(selected[0]);
              requestAnimationFrame(() => inputRef.current?.focus());
            }}
          >
            Change selection
          </button>
        )}
      </div>

      {open && (displaySuggestions.length > 0 || query.trim()) ? (
        <ul
          id={listboxId}
          role="listbox"
          className="absolute z-20 mt-1 max-h-56 w-full overflow-y-auto border border-obsidian-ink bg-marble-white py-1 shadow-[0_8px_24px_rgba(0,13,16,0.12)]"
        >
          {suggestions.length === 0 ? (
            <li className="px-[var(--spacing-22)] py-2 text-[14px] text-ash-gray">No matches</li>
          ) : (
            suggestions.map((item, index) => {
              const isCustom = item.startsWith("__custom__:");
              const display = isCustom ? item.slice("__custom__:".length) : item;
              const isActive = index === highlight;

              return (
                <li key={`${display}-${index}`} role="option" aria-selected={isActive}>
                  <button
                    type="button"
                    className={[
                      "flex w-full items-center gap-2 px-[var(--spacing-22)] py-2 text-left text-[15px] cursor-pointer transition-colors",
                      isActive ? "bg-obsidian-ink text-marble-white" : "text-obsidian-ink/90 hover:bg-obsidian-ink/5",
                    ].join(" ")}
                    onMouseEnter={() => setHighlight(index)}
                    onMouseDown={(e) => e.preventDefault()}
                    onClick={() => addValue(display)}
                  >
                    {isCustom ? (
                      <>
                        <span className={isActive ? "text-marble-white/70" : "text-ash-gray"}>Add</span>
                        <span className="font-bold">&ldquo;{display}&rdquo;</span>
                      </>
                    ) : (
                      display
                    )}
                  </button>
                </li>
              );
            })
          )}
        </ul>
      ) : null}
    </div>
  );
}
