#!/usr/bin/env bash
# Normalize harness text files under a directory to LF line endings.
# Usage: ./scripts/normalize-harness-text-lf.sh [ROOT]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/normalize-text-lf.sh
source "$SCRIPT_DIR/lib/normalize-text-lf.sh"

ROOT="${1:-.}"
normalize_text_lf_tree "$ROOT"
echo "Normalized text line endings under $ROOT"
