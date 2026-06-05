#!/usr/bin/env bash
# Resolve target_path to an absolute directory (macOS, Linux, Git Bash on Windows).
# Source this file; do not execute directly.
# Usage: normalize_target_path "/path/to/repo"
#        is_toolkit_meta_repo "/path"
#        reject_emit_target_under_toolkit TARGET TOOLKIT_ROOT

# Convert Windows paths for Git Bash (C:\foo or C:/foo -> /c/foo).
convert_windows_path_for_bash() {
  local p="$1"
  if command -v cygpath >/dev/null 2>&1; then
    local converted
    if converted=$(cygpath -u "$p" 2>/dev/null); then
      printf '%s' "$converted"
      return 0
    fi
  fi
  if [[ "$p" =~ ^[A-Za-z]:[/\\] ]]; then
    local drive="${p:0:1}"
    local rest="${p:2}"
    rest="${rest//\\//}"
    printf '/%s%s' "$(printf '%s' "$drive" | tr '[:upper:]' '[:lower:]')" "$rest"
    return 0
  fi
  printf '%s' "$p"
}

normalize_target_path() {
  local input="${1:?}"
  local expanded="$input"

  if [[ "$expanded" == "~" ]]; then
    expanded="${HOME:?}"
  elif [[ "$expanded" == ~/* ]]; then
    expanded="${HOME}${expanded:1}"
  fi

  expanded=$(convert_windows_path_for_bash "$expanded")

  if [[ ! -e "$expanded" ]]; then
    echo "ERROR: target path does not exist: $input" >&2
    echo "  (resolved as: $expanded)" >&2
    echo "  On Windows with Git Bash, use C:/path, /c/path, or an absolute path that exists." >&2
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

# Block emit into mistaken relative trees under the toolkit (e.g. C:/... created by mkdir).
reject_emit_target_under_toolkit() {
  local target="${1:?}"
  local toolkit="${2:?}"

  if [[ "$target" == "$toolkit" ]]; then
    return 1
  fi
  case "$target" in
    "$toolkit"/*)
      if is_toolkit_meta_repo "$target"; then
        return 1
      fi
      if [[ ! -f "$target/package.json" ]]; then
        echo "ERROR: target_path resolves inside the toolkit checkout but is not a frontend app: $target" >&2
        echo "  This often means a Windows path was not normalized (check C:/ vs /c/ and spaces)." >&2
        echo "  Remove any stray directories under the toolkit root and fix target_path in answers JSON." >&2
        return 1
      fi
      ;;
  esac
  return 0
}
