#!/usr/bin/env bash
# Takes a game screenshot quietly: no sound, window opened off-screen and unfocused, quits when done.
# Usage: tools/shot.sh <out.png> [delay_seconds] [game args...]
#   tools/shot.sh docs/screens/x.png 6 --boot=york@20,20 --clock=12:00 --weather=clear
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")" || exit 1
OUT="$1"; shift
DELAY="${1:-6}"; [ $# -gt 0 ] && shift
cd "$ROOT"
"$GODOT" --audio-driver Dummy --position 0,-4000 --path . -- --quiet-window --shot="$OUT" --shot-delay="$DELAY" "$@" >/dev/null 2>&1
