#!/usr/bin/env bash
# Refresh a golden fixture tree from emit-from-intake (maintainer/CI helper).
# Preserves intake.answers.json and HARNESS_CHANGELOG.md in the fixture.
#
# Usage: ./scripts/refresh-golden-fixture-from-emit.sh fixtures/golden-full-emit
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE="${1:?fixture path under fixtures/ e.g. fixtures/golden-full-emit}"

if [[ "$FIXTURE" != /* ]]; then
  FIXTURE="$TOOLKIT/$FIXTURE"
fi

ANSWERS="$FIXTURE/intake.answers.json"
[[ -f "$ANSWERS" ]] || { echo "Missing intake answers: $ANSWERS" >&2; exit 1; }

REFRESH_ROOT="$(mktemp -d)"
cleanup() { rm -rf "$REFRESH_ROOT"; }
trap cleanup EXIT

bash "$TOOLKIT/scripts/emit-from-intake.sh" \
  --answers "$ANSWERS" \
  --target "$REFRESH_ROOT" \
  --toolkit "$TOOLKIT" \
  --no-strict

bash "$TOOLKIT/scripts/normalize-harness-text-lf.sh" "$REFRESH_ROOT"

rsync -a \
  --exclude=intake.answers.json \
  --exclude=HARNESS_CHANGELOG.md \
  "$REFRESH_ROOT/" "$FIXTURE/"

bash "$TOOLKIT/scripts/normalize-harness-text-lf.sh" "$FIXTURE"

echo "Refreshed $FIXTURE from emit (kept intake.answers.json and HARNESS_CHANGELOG.md)"
