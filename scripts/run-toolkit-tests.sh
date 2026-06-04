#!/usr/bin/env bash
# Local toolkit test runner (mirrors validate-toolkit.yml Linux job).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAILED=0
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; FAILED=1; }
run() {
  local name="$1"
  shift
  echo ""
  echo "=== $name ==="
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

# Strip CRLF on Windows checkouts
find scripts -name '*.sh' -exec sed -i 's/\r$//' {} + 2>/dev/null || true

echo "=== Template placeholders ==="
if test "$(find templates/skills -name SKILL.md | wc -l)" -gt 0 \
  && grep -q '{{LINT_CMD}}' templates/skills/frontend-verify/SKILL.md; then
  pass "Template placeholders"
else
  fail "Template placeholders"
fi

echo "=== Bootstrap skills in sync ==="
if diff -q .cursor/skills/frontend-harness-bootstrap/SKILL.md \
  agents/skills/frontend-harness-bootstrap/SKILL.md >/dev/null; then
  pass "Bootstrap skills in sync"
else
  fail "Bootstrap skills in sync"
fi

run "Fixture scripts match toolkit" bash scripts/compare-fixture-maintenance-scripts.sh
run "Validate minimal" bash scripts/validate-target-harness.sh fixtures/minimal-full-emit
run "Validate golden full (strict)" bash scripts/validate-target-harness.sh --strict fixtures/golden-full-emit
run "Validate golden portable (strict)" bash scripts/validate-target-harness.sh --strict fixtures/golden-portable-only-emit
run "Validate golden cursor (strict)" bash scripts/validate-target-harness.sh --strict fixtures/golden-cursor-only-emit
run "Manifest profile full" bash scripts/validate-fixture-manifest.sh --profile full fixtures/golden-full-emit
run "Manifest profile portable-only" bash scripts/validate-fixture-manifest.sh --profile portable-only fixtures/golden-portable-only-emit
run "Manifest profile cursor-only" bash scripts/validate-fixture-manifest.sh --profile cursor-only fixtures/golden-cursor-only-emit

echo ""
echo "=== Security templates ==="
SEC_TPL_OK=true
for f in \
  templates/rules/frontend-security.mdc.template \
  templates/skills/frontend-security/SKILL.md \
  templates/hooks/scan-secrets.sh \
  templates/hooks/scan-secrets.ps1 \
  scripts/lib/secret-patterns.sh \
  scripts/lib/secret-patterns.ps1; do
  if [[ ! -f "$f" ]]; then
    echo "Missing: $f"
    SEC_TPL_OK=false
  fi
done
if $SEC_TPL_OK \
  && grep -q '{{PUBLIC_ENV_PREFIX}}' templates/rules/frontend-security.mdc.template \
  && grep -q '{{AUTH_STACK}}' templates/skills/frontend-security/SKILL.md \
  && grep -q 'scan-secrets' templates/hooks/hooks.json.template; then
  pass "Security templates"
else
  fail "Security templates"
fi

echo ""
echo "=== Golden full security layout ==="
FULL_SEC_OK=true
for f in \
  fixtures/golden-full-emit/.cursor/rules/frontend-security.mdc \
  fixtures/golden-full-emit/.agents/skills/frontend-security/SKILL.md \
  fixtures/golden-full-emit/.cursor/hooks/scan-secrets.sh \
  fixtures/golden-full-emit/.cursor/hooks/scan-secrets.ps1 \
  fixtures/golden-full-emit/scripts/lib/secret-patterns.sh; do
  [[ -f "$f" ]] || { echo "Missing: $f"; FULL_SEC_OK=false; }
done
if $FULL_SEC_OK && grep -q 'scan-secrets.sh' fixtures/golden-full-emit/.cursor/hooks.json; then
  pass "Golden full security layout"
else
  fail "Golden full security layout"
fi

echo ""
echo "=== Golden cursor-only security layout ==="
CURSOR_SEC_OK=true
for f in \
  fixtures/golden-cursor-only-emit/.cursor/rules/frontend-security.mdc \
  fixtures/golden-cursor-only-emit/.cursor/skills/frontend-security/SKILL.md \
  fixtures/golden-cursor-only-emit/.cursor/hooks/scan-secrets.sh; do
  [[ -f "$f" ]] || { echo "Missing: $f"; CURSOR_SEC_OK=false; }
done
if $CURSOR_SEC_OK && grep -q 'scan-secrets.sh' fixtures/golden-cursor-only-emit/.cursor/hooks.json; then
  pass "Golden cursor-only security layout"
else
  fail "Golden cursor-only security layout"
fi

echo ""
echo "=== Golden portable-only security (no Cursor hooks) ==="
PORTABLE_SEC_OK=true
[[ -f fixtures/golden-portable-only-emit/.agents/skills/frontend-security/SKILL.md ]] || PORTABLE_SEC_OK=false
[[ -f fixtures/golden-portable-only-emit/scripts/lib/secret-patterns.sh ]] || PORTABLE_SEC_OK=false
[[ ! -d fixtures/golden-portable-only-emit/.cursor ]] || PORTABLE_SEC_OK=false
if $PORTABLE_SEC_OK; then
  pass "Golden portable-only security layout"
else
  fail "Golden portable-only security layout"
fi

echo ""
echo "=== secret-patterns detects literals ==="
# shellcheck source=lib/secret-patterns.sh
source "$ROOT/scripts/lib/secret-patterns.sh"
PAT_TMP="$(mktemp)"
# Use api_key assignment (not sk_live_) so GitHub push protection does not flag test literals.
printf '%s\n' 'api_key = "harness-test-fake-secret-not-real";' > "$PAT_TMP"
if secret_scan_file "$PAT_TMP" >/dev/null 2>&1; then
  fail "secret-patterns detects literals"
else
  pass "secret-patterns detects literals"
fi
rm -f "$PAT_TMP"

echo ""
echo "=== scan-secrets hook blocks changed file ==="
SCAN_REPO="$(mktemp -d)"
(
  set -euo pipefail
  cd "$SCAN_REPO"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Toolkit Test"
  mkdir -p scripts/lib .cursor/hooks src
  cp "$ROOT/scripts/lib/secret-patterns.sh" scripts/lib/
  cp "$ROOT/templates/hooks/scan-secrets.sh" .cursor/hooks/
  chmod +x .cursor/hooks/scan-secrets.sh
  printf '%s\n' '// clean' > src/app.ts
  git add .
  git commit -q -m "init"
  printf '%s\n' 'api_key = "harness-test-fake-secret-not-real";' >> src/app.ts
  code=0
  out=$(bash .cursor/hooks/scan-secrets.sh 2>&1) || code=$?
  [[ "$code" -eq 2 ]] && [[ "$out" == *Blocked* ]] || exit 1
) && pass "scan-secrets hook blocks changed file" || fail "scan-secrets hook blocks changed file"
rm -rf "$SCAN_REPO"

echo ""
echo "=== scan-secrets hook allows clean diff ==="
SCAN_CLEAN="$(mktemp -d)"
(
  set -euo pipefail
  cd "$SCAN_CLEAN"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Toolkit Test"
  mkdir -p scripts/lib .cursor/hooks src
  cp "$ROOT/scripts/lib/secret-patterns.sh" scripts/lib/
  cp "$ROOT/templates/hooks/scan-secrets.sh" .cursor/hooks/
  chmod +x .cursor/hooks/scan-secrets.sh
  printf '%s\n' 'export const ok = 1;' > src/app.ts
  git add .
  git commit -q -m "init"
  printf '%s\n' 'export const alsoOk = 2;' >> src/app.ts
  bash .cursor/hooks/scan-secrets.sh
) && pass "scan-secrets hook allows clean diff" || fail "scan-secrets hook allows clean diff"
rm -rf "$SCAN_CLEAN"

echo ""
echo "=== cursor-only no agents/ORCHESTRATION.md ==="
if [[ ! -f fixtures/golden-cursor-only-emit/agents/ORCHESTRATION.md ]]; then
  pass "cursor-only orchestration layout"
else
  fail "cursor-only orchestration layout"
fi

echo ""
echo "=== Sync smoke ==="
SMOKE="$(mktemp -d)"
cp -a fixtures/minimal-full-emit/. "$SMOKE/"
echo "# smoke" >> "$SMOKE/.agents/skills/frontend-verify/SKILL.md"
(
  cd "$SMOKE"
  bash scripts/sync-skills.sh --all-mirrors
  cmp -s .agents/skills/frontend-verify/SKILL.md .cursor/skills/frontend-verify/SKILL.md
  bash scripts/validate-target-harness.sh .
) && pass "Sync smoke" || fail "Sync smoke"
rm -rf "$SMOKE"

emit_roundtrip() {
  local name="$1" answers="$2" golden="$3" out="$4"
  rm -rf "$out"
  bash scripts/emit-from-intake.sh --answers "$answers" --target "$out" --toolkit .
  if diff -ru "$golden" "$out" \
    --exclude=intake.answers.json \
    --exclude=HARNESS_CHANGELOG.md >/dev/null; then
    pass "$name"
  else
    echo "Diff for $name:"
    diff -ru "$golden" "$out" \
      --exclude=intake.answers.json \
      --exclude=HARNESS_CHANGELOG.md | head -80 || true
    fail "$name"
  fi
  rm -rf "$out"
}

echo ""
echo "=== Emitter round-trips ==="
emit_roundtrip "Emit round-trip full" \
  fixtures/golden-full-emit/intake.answers.json \
  fixtures/golden-full-emit \
  /tmp/emit-out-full
emit_roundtrip "Emit round-trip portable-only" \
  fixtures/golden-portable-only-emit/intake.answers.json \
  fixtures/golden-portable-only-emit \
  /tmp/emit-out-portable
emit_roundtrip "Emit round-trip cursor-only" \
  fixtures/golden-cursor-only-emit/intake.answers.json \
  fixtures/golden-cursor-only-emit \
  /tmp/emit-out-cursor

if command -v shellcheck >/dev/null 2>&1; then
  run "Shellcheck" shellcheck scripts/*.sh scripts/lib/*.sh templates/hooks/*.sh
else
  echo "SKIP: shellcheck not installed"
fi

echo ""
if [[ "$FAILED" -eq 0 ]]; then
  echo "All toolkit tests passed."
  exit 0
fi
echo "Some toolkit tests failed."
exit 1
