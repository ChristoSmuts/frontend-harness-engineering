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
