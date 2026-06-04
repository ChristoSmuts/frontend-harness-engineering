# shellcheck shell=bash
# Strip YAML frontmatter from .mdc template body → Claude .md rule file.

mdc_template_to_claude_md() {
  local src="$1"
  local dst="$2"
  local map_file="${3:-}"
  local tmp
  tmp=$(mktemp)
  awk 'BEGIN { fm=0; done=0 }
    /^---$/ && done==0 { fm++; if (fm==2) { done=1 }; next }
    done==1 { print }
  ' "$src" > "$tmp"
  mkdir -p "$(dirname "$dst")"
  if [[ -n "$map_file" && -f "$map_file" ]]; then
    substitute_from_map_file "$tmp" "$dst" "$map_file"
    rm -f "$tmp"
  else
    mv "$tmp" "$dst"
  fi
}
