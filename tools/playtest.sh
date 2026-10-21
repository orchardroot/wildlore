#!/usr/bin/env bash
# Runs the headless playtest bot and fails on a bot failure or any script error.
# Usage: tools/playtest.sh slice [seed]     tools/playtest.sh m2 [seed]     tools/playtest.sh fuzz [seed] [seconds]
#        tools/playtest.sh full [seed] [seconds]   (the whole story to the credits; prints BOT: fight and BOT: summary lines;
#        tools/playtest.sh from <zone>/<npc>[+N] [seed]   (start at that story beat with a par-level team, play N beats, default 1)
#        default limit 150000 bot seconds, about an hour on a 4-core iMac: start it in the background)
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")" || exit 1
MODE="${1:-slice}"
SEED="${2:-2}"
SECS="${3:-0}"
if [ "$MODE" = "from" ]; then MODE="from:${2:?usage: playtest.sh from <zone>/<npc>[+N] [seed]}"; SEED="${3:-2}"; SECS=0; fi
cd "$ROOT"
"$GODOT" --headless --path . --import >/dev/null 2>&1
LOG="$(mktemp)"
"$GODOT" --headless --fixed-fps 30 --path . -- --playtest="$MODE" --seed="$SEED" --seconds="$SECS" > "$LOG" 2>&1
STATUS=$?
grep -E "^BOT|^PLAYTEST" "$LOG"
if grep -q "SCRIPT ERROR" "$LOG"; then
  grep -A3 "SCRIPT ERROR" "$LOG" | head -40
  echo "playtest.sh: script errors during the run" >&2
  STATUS=1
fi
rm -f "$LOG"
exit "$STATUS"
