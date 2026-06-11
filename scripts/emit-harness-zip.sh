#!/usr/bin/env bash
# Emit harness to a temp dir and zip the result.
# Usage: ./scripts/emit-harness-zip.sh --answers FILE [--toolkit DIR] [--output FILE.zip]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

ANSWERS=""
TOOLKIT="$TOOLKIT_ROOT"
OUTPUT=""

usage() {
  echo "Usage: $0 --answers FILE [--toolkit DIR] [--output FILE.zip]"
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --answers) shift; ANSWERS="${1:?}" ;;
    --toolkit) shift; TOOLKIT="${1:?}" ;;
    --output) shift; OUTPUT="${1:?}" ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1" >&2; usage ;;
  esac
  shift
done

[[ -n "$ANSWERS" ]] || usage
command -v jq >/dev/null 2>&1 || { echo "jq is required" >&2; exit 1; }

project_name=$(jq -r '.project_name // "harness"' "$ANSWERS" | tr ' ' '-')
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${project_name}-harness.zip"
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

bash "$SCRIPT_DIR/emit-from-intake.sh" --answers "$ANSWERS" --target "$tmpdir" --toolkit "$TOOLKIT" --no-strict

rm -f "$OUTPUT"
if command -v zip >/dev/null 2>&1; then
  (cd "$tmpdir" && zip -rq "$OLDPWD/$OUTPUT" .)
elif command -v powershell.exe >/dev/null 2>&1; then
  pwsh -NoProfile -Command "Compress-Archive -Path '$tmpdir/*' -DestinationPath '$OUTPUT' -Force"
else
  echo "zip or pwsh required to create archive" >&2
  exit 1
fi

echo "Wrote $OUTPUT"
