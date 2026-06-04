#!/usr/bin/env bash
# Resolve target_path to an absolute directory (macOS, Linux, Git Bash on Windows).
# Source this file; do not execute directly.
# Usage: normalize_target_path "/path/to/repo"
#        is_toolkit_meta_repo "/path"

normalize_target_path() {
  local input="${1:?}"
  local expanded="$input"

  if [[ "$expanded" == "~" ]]; then
    expanded="${HOME:?}"
  elif [[ "$expanded" == ~/* ]]; then
    expanded="${HOME}${expanded:1}"
  fi

  if [[ ! -e "$expanded" ]]; then
    echo "ERROR: target path does not exist: $input" >&2
    return 1
  fi
  if [[ ! -d "$expanded" ]]; then
    echo "ERROR: target path is not a directory: $input" >&2
    return 1
  fi

  (cd "$expanded" && pwd -P)
}

is_toolkit_meta_repo() {
  local dir="${1:?}"
  [[ -f "$dir/manifest/ARTIFACT_MANIFEST.md" && -f "$dir/prompts/MASTER_BOOTSTRAP.md" ]]
}
