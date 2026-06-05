# shellcheck shell=bash
# Shared shell-guard logic for deny-dangerous hooks.
# Source from hook scripts; do not execute directly.

shell_guard_root() {
  printf '%s\n' "${AGENT_PROJECT_ROOT:-${CURSOR_PROJECT_DIR:-${CODEX_PROJECT_DIR:-.}}}"
}

shell_guard_allowed_domains_file() {
  local root="$1"
  local f
  for f in \
    "$root/.agents/harness/allowed-domains.txt" \
    "$root/.cursor/harness/allowed-domains.txt"; do
    if [[ -f "$f" ]]; then
      printf '%s\n' "$f"
      return 0
    fi
  done
  return 1
}

# Default domains when no allowlist file exists (package managers, git hosts).
shell_guard_default_domains=(
  github.com
  api.github.com
  raw.githubusercontent.com
  registry.npmjs.org
  registry.yarnpkg.com
  npmjs.org
  pnpm.io
  bun.sh
  nodejs.org
  localhost
  127.0.0.1
)

shell_guard_load_domains() {
  local root="$1"
  local -n _out=$2
  _out=()
  local f domain
  if f=$(shell_guard_allowed_domains_file "$root"); then
    while IFS= read -r domain || [[ -n "$domain" ]]; do
      domain="${domain%%#*}"
      domain="${domain// /}"
      [[ -n "$domain" ]] && _out+=("$domain")
    done < "$f"
  fi
  if [[ "${#_out[@]}" -eq 0 ]]; then
    _out=("${shell_guard_default_domains[@]}")
  fi
}

shell_guard_host_allowed() {
  local host="$1"
  shift
  local allowed=("$@")
  local a lower_host lower_a
  lower_host=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')
  for a in "${allowed[@]}"; do
    lower_a=$(printf '%s' "$a" | tr '[:upper:]' '[:lower:]')
    [[ "$lower_host" == "$lower_a" ]] && return 0
    [[ "$lower_host" == *".$lower_a" ]] && return 0
  done
  return 1
}

# Extract hostnames from a shell command string (best-effort).
shell_guard_extract_hosts() {
  local cmd="$1"
  local -a hosts=()
  local token host

  while IFS= read -r token; do
    [[ -n "$token" ]] || continue
    host="${token#*://}"
    host="${host%%/*}"
    host="${host%%:*}"
    host="${host%%\?*}"
    host="${host%%#*}"
    [[ -n "$host" && "$host" != "$token" ]] && hosts+=("$host")
  done < <(printf '%s\n' "$cmd" | grep -oE 'https?://[^[:space:]"'\''<>]+' 2>/dev/null || true)

  if [[ "${#hosts[@]}" -gt 0 ]]; then
    printf '%s\n' "${hosts[@]}"
  fi
}

shell_guard_is_outbound_command() {
  local cmd="$1"
  echo "$cmd" | grep -qiE '(^|[;&|[:space:]])(curl|wget|Invoke-WebRequest|Invoke-RestMethod|nc|netcat)([[:space:]]|$)' \
    && return 0
  return 1
}

shell_guard_is_env_read_command() {
  local cmd="$1"
  echo "$cmd" | grep -qiE '(^|[;&|[:space:]])(cat|type|Get-Content|more|less|head|tail)([[:space:]]|$).*(\\.env|id_rsa|\\.pem)' \
    && return 0
  echo "$cmd" | grep -qiE '(\\.env(\\.local|\\.production|\\.development)?|id_rsa|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY)' \
    && echo "$cmd" | grep -qiE '(cat|type|Get-Content|more|less|head|tail)' \
    && return 0
  return 1
}

shell_guard_is_git_remote_change() {
  local cmd="$1"
  echo "$cmd" | grep -qiE 'git[[:space:]]+remote[[:space:]]+(add|set-url|remove)' && return 0
  return 1
}

shell_guard_check_outbound() {
  local cmd="$1"
  local root
  root=$(shell_guard_root)
  cd "$root" 2>/dev/null || true

  if ! shell_guard_is_outbound_command "$cmd"; then
    return 0
  fi

  local -a allowed=()
  shell_guard_load_domains "$root" allowed

  local host
  local blocked=0
  while IFS= read -r host; do
    [[ -n "$host" ]] || continue
    if ! shell_guard_host_allowed "$host" "${allowed[@]}"; then
      echo "Blocked: outbound request to unapproved host '$host' — add to .agents/harness/allowed-domains.txt or ask the user." >&2
      blocked=1
    fi
  done < <(shell_guard_extract_hosts "$cmd")

  # curl/wget with no URL visible — block conservatively.
  if [[ "$blocked" -eq 0 ]] && ! shell_guard_extract_hosts "$cmd" | grep -q .; then
    if echo "$cmd" | grep -qiE '(curl|wget|Invoke-WebRequest|Invoke-RestMethod)'; then
      echo "Blocked: outbound network command without a clear allowlisted URL — ask the user to run manually." >&2
      return 2
    fi
  fi

  [[ "$blocked" -eq 1 ]] && return 2
  return 0
}
