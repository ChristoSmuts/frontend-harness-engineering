# shellcheck shell=bash
# Strip CR characters from harness text artifacts (LF-only repos / CI diffs).

normalize_text_lf_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  perl -0777 -pi -e '
    s/\r\n?/\n/g;
    $_ .= "\n" if length && !/\n\z/;
  ' "$file"
}

normalize_text_lf_tree() {
  local root="${1:-.}"
  [[ -d "$root" ]] || return 0
  local file
  while IFS= read -r -d '' file; do
    normalize_text_lf_file "$file"
  done < <(
    find "$root" -type f \( \
      -name '*.sh' -o -name '*.ps1' -o -name '*.md' -o -name '*.mdc' \
      -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' -o -name '*.toml' \
      -o -name '*.example' \
    \) ! -path '*/.git/*' -print0 2>/dev/null
  )
}
