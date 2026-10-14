#!/usr/bin/env bash
# Idempotent: creates labels, milestones and the plan 1 issues on orchardroot/wildlore.
set -euo pipefail
REPO="orchardroot/wildlore"

label() { gh label create "$1" --repo "$REPO" --color "$2" --description "$3" --force >/dev/null; }
label battle "d73a4a" "Battle engine and battle UI"
label world  "0e8a16" "Zones, movement, camera"
label data   "1d76db" "Creatures, moves, items, dialogue data"
label art    "fbca04" "Sprites, tiles, shaders"
label story  "5319e7" "Plot, quests, scripted events"
label audio  "c5def5" "Music and SFX"
label bug    "b60205" "Something is broken"
label infra  "555555" "CI, tooling, releases"

EXISTING_MS="$(gh api "repos/$REPO/milestones?state=all" --jq '.[].title')"
milestone() {
  if ! grep -qxF "$1" <<<"$EXISTING_MS"; then
    gh api "repos/$REPO/milestones" -f title="$1" -f description="$2" >/dev/null
  fi
}
milestone "M0 Foundations" "Repo, CI, schemas, validator, type chart, saves, release pipeline"
milestone "M1 Vertical slice" "Macclesfield to Buxton, 20 creatures, battle system, HD-2D look (v0.1)"
milestone "M2 England North and Wales" "About 12 towns, 70 creatures, 4 badges (v0.2)"
milestone "M3 South and Ireland" "About 25 towns, 130 creatures, 7 badges (v0.3)"
milestone "M4 Scotland, NI and finale" "All 40 towns, 200 creatures, 10 badges, the Moot, London (v0.4)"
milestone "M5 Polish" "Post-game, balance, audio, accessibility, performance (v1.0)"

EXISTING_ISSUES="$(gh issue list --repo "$REPO" --state all --limit 200 --json title --jq '.[].title')"
issue() {
  if ! grep -qxF "$1" <<<"$EXISTING_ISSUES"; then
    gh issue create --repo "$REPO" --title "$1" --label "$2" --milestone "$3" \
      --body "Plan 1 task. See docs/superpowers/plans/2026-10-14-plan-1-foundations-and-battle-core.md" >/dev/null
  fi
}
issue "Type chart and JSON loading"            data   "M0 Foundations"
issue "Move database and starter moves"        data   "M0 Foundations"
issue "Dex and the three starter lines"         data   "M0 Foundations"
issue "Data validator in CI"                    infra  "M0 Foundations"
issue "Creature instances, stats and natures"   battle "M1 Vertical slice"
issue "Weather and status conditions"           battle "M1 Vertical slice"
issue "Damage calculation"                      battle "M1 Vertical slice"
issue "Battle turn engine"                      battle "M1 Vertical slice"
issue "Catching"                                battle "M1 Vertical slice"
issue "XP, level-up, evolution, training"       battle "M1 Vertical slice"
issue "Battle AI tiers"                         battle "M1 Vertical slice"
issue "Crash-safe versioned saves"              infra  "M0 Foundations"
issue "Mac and Windows export, v0.0.1 release"  infra  "M0 Foundations"
echo "gh_setup: done"
