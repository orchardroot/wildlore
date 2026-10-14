#!/usr/bin/env bash
# Imports the project, then runs the unit tests. Fails on any failed test or script error.
# Usage: tools/test.sh [filter]
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")" || exit 1
cd "$ROOT"
"$GODOT" --headless --path . --import >/dev/null 2>&1

LOG="$(mktemp)"
"$GODOT" --headless --path . -s res://tests/run_tests.gd -- "${1:-}" 2>&1 | tee "$LOG"
STATUS=${PIPESTATUS[0]}
if grep -qE "SCRIPT ERROR|Parse Error" "$LOG"; then
  echo "test.sh: script errors in the log, failing" >&2
  STATUS=1
fi
rm -f "$LOG"
exit "$STATUS"
