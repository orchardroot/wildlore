#!/usr/bin/env bash
# Screenshots one menu with the sample party: tools/shot_menu.sh <menu[:arg]> <name>  ->  docs/screens/t9-<name>.png
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")" || exit 1
cd "$ROOT"
"$GODOT" --path . -- "--menu=$1" "--shot=docs/screens/t9-$2.png" --shot-delay=2 2>&1 | grep -E "ERROR|SCRIPT|Parse" | grep -vE "leaked|still in use" || true
