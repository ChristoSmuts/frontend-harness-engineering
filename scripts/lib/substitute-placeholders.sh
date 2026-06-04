# shellcheck shell=bash
# Substitute {{TOKEN}} placeholders from a key=value file (one per line: KEY=value).

substitute_from_map_file() {
  local src="$1"
  local dst="$2"
  local map_file="$3"
  local multiline_file="${4:-}"
  local content
  content=$(<"$src")
  content="${content//$'\r'/}"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    local key="${line%%=*}"
    local val="${line#*=}"
    if [[ "$val" == "__MULTILINE_FILE__" && -n "$multiline_file" && -f "$multiline_file" ]]; then
      val=$(<"$multiline_file")
    fi
    val="${val//\\n/$'\n'}"
    content="${content//\{\{${key}\}\}/${val}}"
  done < "$map_file"
  mkdir -p "$(dirname "$dst")"
  if [[ -n "$content" && "$content" != *$'\n' ]]; then
    content+=$'\n'
  fi
  printf '%s' "$content" > "$dst"
}

substitute_inplace_file() {
  local file="$1"
  local map_file="$2"
  local multiline_file="${3:-}"
  local tmp
  tmp=$(mktemp)
  substitute_from_map_file "$file" "$tmp" "$map_file" "$multiline_file"
  mv "$tmp" "$file"
}

remove_monorepo_block() {
  local file="$1"
  if [[ ! -f "$file" ]]; then return 0; fi
  local tmp
  tmp=$(mktemp)
  awk '
    /{{MONOREPO_CD_BLOCK_START}}/ { skip=1; next }
    /{{MONOREPO_CD_BLOCK_END}}/ { skip=0; next }
    skip==0 { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

inject_monorepo_cd() {
  local file="$1"
  local app_path="$2"
  local is_ps=false
  [[ "$file" == *.ps1 ]] && is_ps=true
  local tmp
  tmp=$(mktemp)
  if $is_ps; then
    awk -v p="$app_path" '
      /{{MONOREPO_CD_BLOCK_START}}/ { print "Set-Location \"" p "\""; skip=1; next }
      /{{MONOREPO_CD_BLOCK_END}}/ { skip=0; next }
      skip==0 { print }
    ' "$file" > "$tmp"
  else
    awk -v p="$app_path" '
      /{{MONOREPO_CD_BLOCK_START}}/ { print "cd \"" p "\""; skip=1; next }
      /{{MONOREPO_CD_BLOCK_END}}/ { skip=0; next }
      skip==0 { print }
    ' "$file" > "$tmp"
  fi
  mv "$tmp" "$file"
}
