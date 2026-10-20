#!/usr/bin/env bash
# Takes a game screenshot quietly: no sound, launched in the background and off-screen, quits when done.
# Usage: tools/shot.sh <out.png> [delay_seconds] [game args...]
#   tools/shot.sh docs/screens/x.png 6 --boot=york@20,20 --clock=12:00 --weather=clear
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")" || exit 1
OUT="$1"; shift
DELAY="${1:-6}"; [ $# -gt 0 ] && shift
cd "$ROOT"
case "$OUT" in /*) ;; *) OUT="$ROOT/$OUT" ;; esac
ARGS=(--audio-driver Dummy --position 0,-4000 --path "$ROOT" -- --quiet-window --shot="$OUT" --shot-delay="$DELAY" "$@")
APP="${GODOT%/Contents/MacOS/*}"
if [ "$(uname)" = Darwin ] && [ -d "$APP" ] && [ "${APP##*.}" = app ]; then
  # `open -g` launches in the background, so a screenshot run never steals focus from whatever you're doing
  # (e.g. playing the installed game); -n gives each run its own instance, -W waits for it to quit.
  open -g -n -W -a "$APP" --stdout /dev/null --stderr /dev/null --args "${ARGS[@]}"
else
  "$GODOT" "${ARGS[@]}" >/dev/null 2>&1
fi
