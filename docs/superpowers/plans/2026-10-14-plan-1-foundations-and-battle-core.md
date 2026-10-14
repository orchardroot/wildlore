# Plan 1: Foundations and Battle Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A Godot 4 project with CI, GitHub project management, validated game data, a fully unit-tested headless battle engine (damage, types, weather, status, catching, XP, evolution, AI), crash-safe saves, and a tagged v0.0.1 release that exports Mac and Windows builds.

**Architecture:** Everything in this plan is pure GDScript logic with no scene dependencies, tested by a tiny headless test runner. Game content is JSON under `data/`, loaded through typed accessors in `data_api/` and cross-checked by a validator that CI runs on every push. The battle engine takes an injected `Rng` so every battle is deterministic and replayable; it returns event dictionaries that the plan 2 battle UI will render.

**Tech Stack:** Godot 4.7.2-stable (Compatibility renderer), GDScript, bash, GitHub Actions (ubuntu-latest), `gh` CLI.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md`

**Scope note:** The spec spans milestones M0 to M5. This plan covers M0 plus the headless battle core from M1. Plan 2 (world, HD-2D rendering, battle UI, Macclesfield to Buxton slice) is written after this plan lands. Evolution by item, weather, time and friendship arrives with the item system in plan 2; this plan does level evolution only.

## Global Constraints

- Godot version pinned to `4.7.2-stable` in exactly one place: `tools/get_godot.sh`.
- Renderer: `gl_compatibility` (OpenGL 3.3) for the GTX 775M Kepler iMac.
- GDScript files are indented with **tabs**. One `class_name` per file. Files stay small and single-purpose.
- `JSON.parse_string` returns every number as a float. Every loader casts numeric fields with `int()` at load time; nothing downstream casts.
- Never name a method `randf`, `randi`, `get` or `set` on our classes (they shadow globals or Object methods).
- Type ids, stat ids, status ids and weather ids are lowercase strings, exactly as listed in `core/rules.gd`.
- Stats: `hp, atk, def, lore, ward, spd`. Stage stats add `acc`.
- Statuses: `soaked, chilled, muddled, hexed, stung, asleep`.
- Weathers: `clear, drizzle, downpour, fog, gale, frost, sunshine`.
- Prose (README, dialogue, dex text, commit messages): British spelling, no em-dashes.
- Every commit message ends with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>` (or the model that actually did the work).
- Commit after every task and push immediately. Tasks 1 to 3 go straight to `main` (bootstrapping). Tasks 4 to 16 go on branch `plan-1-battle-core`, pushed after every commit, merged by PR once CI is green.
- Test command for everything: `tools/test.sh` (optionally `tools/test.sh <filter>` to run tests whose `file::method` contains the filter). The test runner exits non-zero on any failed assertion and `tools/test.sh` also fails if the log contains `SCRIPT ERROR` or `Parse Error`.

## Review Focus

1. **JSON numbers arriving as floats.** Base stats, levels, PP, power read from JSON must be `int` everywhere, or stat maths and `==` comparisons drift. Pinned by `test_species_numbers_are_ints` and `test_move_numbers_are_ints` (Tasks 5 and 6).
2. **Exported builds missing the JSON data.** Godot only packs resources it knows about, so `data/*.json` silently vanishes from release builds unless `include_filter` covers it. Pinned by the PCK content check in `tools/export.sh` and the boot-screen data self-check (Task 16).
3. **A battle starting with a side that has no conscious creature.** Expect the battle to be over immediately with the other side winning, not a crash on index -1. Pinned by `test_side_with_no_able_creature_ends_at_once` (Task 11).
4. **A save written by a newer game version.** Expect the loader to refuse it with a `_too_new` marker rather than return empty (which would let autosave overwrite it). Pinned by `test_newer_save_is_flagged_not_dropped` (Task 15).
5. **A creature whose chosen move has 0 PP, or both sides fainting on the same turn.** Expect Flail as the fallback move, and the player to lose a mutual wipe. Pinned by `test_zero_pp_falls_back_to_flail` and `test_mutual_wipe_counts_as_player_loss` (Task 11).

---

## File Structure

```
wildlore/
  .gitignore
  project.godot
  main.tscn, main.gd                  boot screen placeholder + data self-check
  export_presets.cfg                  macOS + Windows presets
  README.md
  .github/workflows/ci.yml            tests + validator on every push
  .github/workflows/release.yml       export + GitHub Release on v* tags
  core/rules.gd                       Rules: shared constants, XP curves
  core/save_system.gd                 SaveSystem: atomic versioned JSON saves
  data/types.json                     16 types + effectiveness chart
  data/moves/*.json                   moves, one file per type
  data/creatures/*.json               species, one file per evolution line
  data_api/json_util.gd               JsonUtil: read + list JSON files
  data_api/type_chart.gd              TypeChart
  data_api/move_db.gd                 MoveDB
  data_api/dex.gd                     Dex
  data_api/validator.gd               DataValidator
  battle/rng.gd                       Rng: seeded wrapper
  battle/creature.gd                  Creature: one individual creature
  battle/weather.gd                   Weather
  battle/status_fx.gd                 StatusFX
  battle/damage_calc.gd               DamageCalc
  battle/catching.gd                  Catching
  battle/progression.gd               Progression: XP, level-up, evolution, training
  battle/battle.gd                    Battle: turn engine, events
  battle/ai.gd                        BattleAI
  tools/get_godot.sh                  download pinned Godot, print path
  tools/test.sh                       import + unit tests + validator
  tools/validate.gd                   headless validator entry point
  tools/export.sh                     export Mac + Windows into build/
  tools/gh_setup.sh                   labels, milestones, issues
  tests/run_tests.gd                  headless runner
  tests/support/case.gd               TestCase base class
  tests/support/fixed_rng.gd          FixedRng test double
  tests/support/fixtures.gd           Fixtures: shared builders
  tests/test_smoke.gd
  tests/data_api/test_*.gd
  tests/battle/test_*.gd
  tests/core/test_*.gd
```

---

### Task 1: Project skeleton and headless test runner

**Files:**
- Create: `.gitignore`, `project.godot`, `main.tscn`, `main.gd`, `tools/get_godot.sh`, `tools/test.sh`, `tests/run_tests.gd`, `tests/support/case.gd`, `tests/test_smoke.gd`

**Interfaces:**
- Produces: `tools/get_godot.sh` prints the Godot binary path (or the version tag with `--version`). `tools/test.sh [filter]`. `TestCase` with `runner`, `fail(msg)`, `assert_eq(actual, expected, msg="")`, `assert_true(cond, msg="")`, `assert_false(cond, msg="")`, `assert_near(actual, expected, eps=0.0001, msg="")`, `assert_has(container, item, msg="")`. Every test file `extends TestCase`, lives under `tests/`, is named `test_*.gd`, and each test is a `func test_*() -> void`. A fresh instance is made per test.

- [ ] **Step 1: Create `.gitignore`**

```
.godot/
.godot-bin/
build/
*.tmp
.DS_Store
```

- [ ] **Step 2: Create `project.godot`**

```
config_version=5

[application]

config/name="Wildlore"
config/version="0.0.1"
run/main_scene="res://main.tscn"
config/features=PackedStringArray("4.7", "GL Compatibility")

[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"

[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0
```

- [ ] **Step 3: Create `main.tscn` and `main.gd`**

`main.tscn`:
```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://main.gd" id="1_main"]

[node name="Main" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1_main")
```

`main.gd`:
```gdscript
extends Control
## Boot screen placeholder until the title screen lands in plan 2.

func _ready() -> void:
	var label := Label.new()
	label.text = "Wildlore  v%s" % ProjectSettings.get_setting("application/config/version")
	label.add_theme_font_size_override("font_size", 64)
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
```

- [ ] **Step 4: Create `tools/get_godot.sh`** (then `chmod +x tools/get_godot.sh`)

```bash
#!/usr/bin/env bash
# Downloads the pinned Godot into .godot-bin/ (once) and prints the binary path.
# With --version, prints the pinned version tag instead.
set -euo pipefail
VERSION="4.7.2-stable"
if [ "${1:-}" = "--version" ]; then echo "$VERSION"; exit 0; fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN_DIR="$ROOT/.godot-bin"
BASE="https://github.com/godotengine/godot/releases/download/$VERSION"
case "$(uname -s)" in
  Darwin) ZIP="Godot_v${VERSION}_macos.universal.zip"; EXE="$BIN_DIR/Godot.app/Contents/MacOS/Godot" ;;
  Linux)  ZIP="Godot_v${VERSION}_linux.x86_64.zip";    EXE="$BIN_DIR/Godot_v${VERSION}_linux.x86_64" ;;
  *) echo "get_godot.sh: unsupported OS $(uname -s)" >&2; exit 1 ;;
esac
if [ ! -x "$EXE" ]; then
  mkdir -p "$BIN_DIR"
  curl -sSL -o "$BIN_DIR/$ZIP" "$BASE/$ZIP"
  unzip -q -o "$BIN_DIR/$ZIP" -d "$BIN_DIR"
  rm "$BIN_DIR/$ZIP"
  chmod +x "$EXE"
fi
echo "$EXE"
```

- [ ] **Step 5: Create `tools/test.sh`** (then `chmod +x tools/test.sh`)

```bash
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
```

- [ ] **Step 6: Create `tests/support/case.gd`**

```gdscript
class_name TestCase
extends RefCounted
## Base class for tests. Assertions report to the runner and never abort the test.

var runner

func fail(msg: String) -> void:
	runner.fail(msg)

func assert_eq(actual, expected, msg := "") -> void:
	if not _comparable(actual, expected):
		fail("%s expected <%s> (%s) got <%s> (%s)" % [msg, str(expected), type_string(typeof(expected)), str(actual), type_string(typeof(actual))])
	elif actual != expected:
		fail("%s expected <%s> got <%s>" % [msg, str(expected), str(actual)])

func assert_true(cond: bool, msg := "") -> void:
	if not cond:
		fail("%s expected true" % msg)

func assert_false(cond: bool, msg := "") -> void:
	if cond:
		fail("%s expected false" % msg)

func assert_near(actual: float, expected: float, eps := 0.0001, msg := "") -> void:
	if absf(actual - expected) > eps:
		fail("%s expected ~%s got %s" % [msg, str(expected), str(actual)])

func assert_has(container, item, msg := "") -> void:
	if not (item in container):
		fail("%s expected %s to contain %s" % [msg, str(container), str(item)])

func _comparable(a, b) -> bool:
	var ta := typeof(a)
	var tb := typeof(b)
	if ta == tb:
		return true
	var nums := [TYPE_INT, TYPE_FLOAT]
	var strs := [TYPE_STRING, TYPE_STRING_NAME]
	return (ta in nums and tb in nums) or (ta in strs and tb in strs)
```

- [ ] **Step 7: Create `tests/run_tests.gd`**

```gdscript
extends SceneTree
## Headless test runner. Runs every res://tests/**/test_*.gd; each test_* method is one test.
## Usage: godot --headless --path . -s res://tests/run_tests.gd -- [filter]

var failures := 0
var passed := 0
var current := ""

func fail(msg: String) -> void:
	failures += 1
	printerr("FAIL %s: %s" % [current, msg])

func _initialize() -> void:
	var filter := ""
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		filter = args[0]
	for path in _find_tests("res://tests"):
		var script: GDScript = load(path)
		for m in script.get_script_method_list():
			var method: String = m.name
			if not method.begins_with("test_"):
				continue
			current = "%s::%s" % [path.get_file().get_basename(), method]
			if filter != "" and not current.contains(filter):
				continue
			var inst = script.new()
			inst.runner = self
			var before := failures
			inst.call(method)
			if failures == before:
				passed += 1
	print("\n%d passed, %d failed" % [passed, failures])
	quit(1 if failures > 0 else 0)

func _find_tests(dir_path: String) -> Array:
	var out := []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			out.append(dir_path.path_join(f))
	for d in dir.get_directories():
		out.append_array(_find_tests(dir_path.path_join(d)))
	out.sort()
	return out
```

- [ ] **Step 8: Write the smoke test `tests/test_smoke.gd`**

```gdscript
extends TestCase

func test_project_is_named_wildlore() -> void:
	assert_eq(ProjectSettings.get_setting("application/config/name"), "Wildlore")

func test_renderer_is_compatibility() -> void:
	assert_eq(ProjectSettings.get_setting("rendering/renderer/rendering_method"), "gl_compatibility")
```

- [ ] **Step 9: Run the tests**

Run: `tools/test.sh`
Expected: first run downloads Godot (about 70 MB), then prints `2 passed, 0 failed`, exit 0.

- [ ] **Step 10: Prove the runner catches failures**

Temporarily change the expected name in `test_project_is_named_wildlore` to `"Nope"`, run `tools/test.sh`, expect `FAIL test_smoke::test_project_is_named_wildlore` and exit code 1 (`echo $?`). Revert the change and rerun to green.

- [ ] **Step 11: Commit and push**

```bash
git add -A
git commit -m "chore: Godot 4.7.2 project skeleton and headless test runner"
git push
```

---

### Task 2: CI workflow and README

**Files:**
- Create: `.github/workflows/ci.yml`, `README.md`

**Interfaces:**
- Consumes: `tools/test.sh` (Task 1).
- Produces: a CI check named `CI / test` on every push and PR.

- [ ] **Step 1: Create `.github/workflows/ci.yml`**

```yaml
name: CI
on:
  push:
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/cache@v4
        with:
          path: .godot-bin
          key: godot-${{ hashFiles('tools/get_godot.sh') }}
      - name: Tests and data validation
        run: tools/test.sh
```

- [ ] **Step 2: Create `README.md`**

~~~markdown
# Wildlore

[![CI](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml/badge.svg)](https://github.com/orchardroot/wildlore/actions/workflows/ci.yml)

A monster-catching RPG across the UK and Ireland. You start in Macclesfield, because somebody has to, and work your way round forty towns, ten Keepers and two hundred creatures. Most of them you could see on a decent walk if you got up early enough. The rest are legends, and the legends are waking up.

Built in Godot 4 for Mac and Windows. It is early days: right now it is foundations and a battle engine with no pictures. The design lives in `docs/superpowers/specs/` and the plans in `docs/superpowers/plans/`.

## Running the tests

```
tools/test.sh            # all tests (downloads the pinned Godot on first run)
tools/test.sh damage     # only tests whose file::method contains "damage"
```

## Status

Milestone M0. Progress is on the project board and in Issues.

*orchardroot, made in Cheshire, under the supervision of two cats. Neither of them is in this one. Yet.*
~~~

- [ ] **Step 3: Commit, push, and watch CI**

```bash
git add -A
git commit -m "ci: run tests on every push; add README"
git push
gh run watch --exit-status "$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')"
```
Expected: the run finishes green.

---

### Task 3: GitHub project management

**Files:**
- Create: `tools/gh_setup.sh`

**Interfaces:**
- Produces: labels `battle, world, data, art, story, audio, bug, infra`; milestones `M0 Foundations` .. `M5 Polish`; one issue per Task 4 to 16 of this plan; a GitHub Project board named `Wildlore` linked to the repo.

- [ ] **Step 1: Create `tools/gh_setup.sh`** (then `chmod +x`)

```bash
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
```

- [ ] **Step 2: Run it**

Run: `tools/gh_setup.sh`
Expected: `gh_setup: done`; `gh issue list --repo orchardroot/wildlore` shows 13 issues. Running it a second time creates nothing new.

- [ ] **Step 3: Create the Project board**

The `gh` token lacks the `project` scope. Ask the user to run `! gh auth refresh -s project` (interactive browser login). Then:

```bash
NUM=$(gh project create --owner orchardroot --title "Wildlore" --format json --jq .number)
gh project link "$NUM" --owner orchardroot --repo orchardroot/wildlore
for url in $(gh issue list --repo orchardroot/wildlore --state open --limit 200 --json url --jq '.[].url'); do
  gh project item-add "$NUM" --owner orchardroot --url "$url" >/dev/null
done
```
Expected: `gh project item-list "$NUM" --owner orchardroot` lists 13 items. If the user declines the scope refresh, skip this step and note it; Issues and Milestones still work.

- [ ] **Step 4: Commit, push, then branch for the rest of the plan**

```bash
git add -A
git commit -m "chore: GitHub labels, milestones and plan 1 issues"
git push
git checkout -b plan-1-battle-core
git push -u origin plan-1-battle-core
```

From here, mention the issue number in each task's commit message, for example `(#3)`, and close issues from the final PR body with `Closes #N` lines.

---

### Task 4: JSON loading, Rules constants, and the type chart

**Files:**
- Create: `data_api/json_util.gd`, `core/rules.gd`, `data/types.json`, `data_api/type_chart.gd`
- Test: `tests/data_api/test_type_chart.gd`

**Interfaces:**
- Produces:
  - `JsonUtil.read(path: String) -> Variant` (Dictionary/Array, or `null` if missing or invalid), `JsonUtil.list_json(dir_path: String) -> Array` (sorted `res://` paths).
  - `Rules` constants: `STATS, STAGE_STATS, STATUSES, GROWTH_RATES, CATEGORIES, EFFECTS, WEATHERS, NATURES, MAX_LEVEL, MAX_MOVES, IV_MAX, TRAINING_STAT_CAP, TRAINING_TOTAL_CAP`; `Rules.xp_for_level(growth: String, level: int) -> int`.
  - `TypeChart.load_default() -> TypeChart`, `TypeChart.from_dict(d: Dictionary) -> TypeChart`, `.types: Array`, `.multiplier(attacker: String, defender: String) -> float`, `.effectiveness(attacker: String, defender_types: Array) -> float`, `.validate() -> Array` (error strings).

- [ ] **Step 1: Write the failing tests `tests/data_api/test_type_chart.gd`**

```gdscript
extends TestCase

var chart := TypeChart.load_default()

func test_sixteen_types() -> void:
	assert_eq(chart.types.size(), 16)

func test_super_effective() -> void:
	assert_eq(chart.multiplier("hearth", "hedgerow"), 2.0)
	assert_eq(chart.multiplier("brook", "hearth"), 2.0)

func test_not_very_effective() -> void:
	assert_eq(chart.multiplier("hearth", "brook"), 0.5)

func test_no_effect() -> void:
	assert_eq(chart.multiplier("kin", "spirit"), 0.0)
	assert_eq(chart.multiplier("storm", "stone"), 0.0)

func test_unlisted_pair_is_neutral() -> void:
	assert_eq(chart.multiplier("kin", "kin"), 1.0)

func test_fae_fears_iron() -> void:
	assert_eq(chart.multiplier("iron", "fae"), 2.0)

func test_dual_types_multiply() -> void:
	assert_eq(chart.effectiveness("iron", ["fae", "frost"]), 4.0)
	assert_eq(chart.effectiveness("storm", ["brook", "stone"]), 0.0)
	assert_eq(chart.effectiveness("hearth", ["hedgerow", "brook"]), 1.0)

func test_typeless_move_is_neutral() -> void:
	assert_eq(chart.effectiveness("", ["hedgerow"]), 1.0)

func test_real_chart_is_valid() -> void:
	assert_eq(chart.validate(), [])

func test_validate_catches_unknown_type() -> void:
	var bad := TypeChart.from_dict({"types": ["a", "b"], "chart": {"a": {"se": ["zz"]}, "b": {"se": ["a"]}}})
	assert_true(bad.validate().size() > 0)

func test_validate_catches_type_with_no_weakness() -> void:
	var bad := TypeChart.from_dict({"types": ["a", "b"], "chart": {"a": {"se": ["a"]}, "b": {"se": ["a"]}}})
	assert_has(bad.validate(), "type 'b' has no weakness")

func test_xp_curves() -> void:
	assert_eq(Rules.xp_for_level("medium", 1), 0)
	assert_eq(Rules.xp_for_level("medium", 10), 1000)
	assert_eq(Rules.xp_for_level("fast", 10), 800)
	assert_eq(Rules.xp_for_level("slow", 10), 1250)
```

- [ ] **Step 2: Run to verify it fails**

Run: `tools/test.sh type_chart`
Expected: FAIL / script errors (TypeChart not defined).

- [ ] **Step 3: Create `data_api/json_util.gd`**

```gdscript
class_name JsonUtil
extends RefCounted
## Reads JSON files from res:// (or user://). Numbers come back as floats: callers cast.

static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JsonUtil: missing %s" % path)
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		push_error("JsonUtil: invalid JSON in %s" % path)
	return parsed

static func list_json(dir_path: String) -> Array:
	var out := []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.ends_with(".json"):
			out.append(dir_path.path_join(f))
	out.sort()
	return out
```

- [ ] **Step 4: Create `core/rules.gd`**

```gdscript
class_name Rules
extends RefCounted
## Shared game constants. Data files and the battle engine both validate against these.

const STATS := ["hp", "atk", "def", "lore", "ward", "spd"]
const STAGE_STATS := ["atk", "def", "lore", "ward", "spd", "acc"]
const STATUSES := ["soaked", "chilled", "muddled", "hexed", "stung", "asleep"]
const GROWTH_RATES := ["fast", "medium", "slow"]
const CATEGORIES := ["physical", "special", "status"]
const EFFECTS := ["none", "stat", "status"]
const WEATHERS := ["clear", "drizzle", "downpour", "fog", "gale", "frost", "sunshine"]
const MAX_LEVEL := 100
const MAX_MOVES := 4
const IV_MAX := 15
const TRAINING_STAT_CAP := 100
const TRAINING_TOTAL_CAP := 300

## nature -> [raised stat, lowered stat]; empty means neutral. "steady" must stay first (tests rely on it).
const NATURES := {
	"steady": [], "chipper": [],
	"brash": ["atk", "def"], "stubborn": ["atk", "lore"],
	"hardy": ["def", "lore"], "wary": ["def", "spd"],
	"canny": ["lore", "atk"], "dreamy": ["lore", "spd"],
	"gentle": ["ward", "atk"], "stoic": ["ward", "spd"],
	"cheeky": ["spd", "def"], "plucky": ["spd", "ward"],
}

## Total XP needed to be at `level`.
static func xp_for_level(growth: String, level: int) -> int:
	if level <= 1:
		return 0
	var cube := level * level * level
	match growth:
		"fast":
			return int(cube * 0.8)
		"slow":
			return int(cube * 1.25)
		_:
			return cube
```

- [ ] **Step 5: Create `data/types.json`** (the chart from spec section 3)

```json
{
  "types": ["kin", "hedgerow", "brook", "tide", "hearth", "gale", "storm", "frost",
            "stone", "bog", "iron", "urban", "fae", "spirit", "brawn", "night"],
  "chart": {
    "kin":      {"se": [], "nve": ["stone", "iron"], "none": ["spirit"]},
    "hedgerow": {"se": ["brook", "tide", "stone"], "nve": ["hearth", "gale", "bog", "iron", "urban", "hedgerow"], "none": []},
    "brook":    {"se": ["hearth", "stone"], "nve": ["brook", "hedgerow", "frost"], "none": []},
    "tide":     {"se": ["hearth", "stone", "iron"], "nve": ["tide", "hedgerow", "storm"], "none": []},
    "hearth":   {"se": ["hedgerow", "frost", "iron"], "nve": ["brook", "tide", "stone", "hearth"], "none": []},
    "gale":     {"se": ["hedgerow", "brawn"], "nve": ["stone", "iron", "storm"], "none": []},
    "storm":    {"se": ["brook", "tide", "gale"], "nve": ["hedgerow", "storm"], "none": ["stone"]},
    "frost":    {"se": ["hedgerow", "gale", "bog"], "nve": ["hearth", "iron", "tide", "frost"], "none": []},
    "stone":    {"se": ["hearth", "gale", "frost", "storm"], "nve": ["brawn", "brook"], "none": []},
    "bog":      {"se": ["hedgerow", "brook", "fae"], "nve": ["bog", "stone", "spirit"], "none": ["iron"]},
    "iron":     {"se": ["fae", "frost", "stone"], "nve": ["hearth", "brook", "tide", "iron"], "none": []},
    "urban":    {"se": ["hedgerow", "kin"], "nve": ["brawn", "iron", "night"], "none": []},
    "fae":      {"se": ["brawn", "night"], "nve": ["iron", "urban", "fae"], "none": []},
    "spirit":   {"se": ["spirit", "urban"], "nve": ["night"], "none": ["kin"]},
    "brawn":    {"se": ["kin", "stone", "iron", "urban", "frost"], "nve": ["gale", "fae", "bog"], "none": ["spirit"]},
    "night":    {"se": ["spirit", "fae"], "nve": ["brawn", "night"], "none": []}
  }
}
```

- [ ] **Step 6: Create `data_api/type_chart.gd`**

```gdscript
class_name TypeChart
extends RefCounted
## Type effectiveness lookup built from data/types.json.

const DEFAULT_PATH := "res://data/types.json"

var types: Array = []
var _chart: Dictionary = {}  # attacker -> {"se": [...], "nve": [...], "none": [...]}

static func load_default() -> TypeChart:
	var d = JsonUtil.read(DEFAULT_PATH)
	return from_dict(d if d is Dictionary else {})

static func from_dict(d: Dictionary) -> TypeChart:
	var tc := TypeChart.new()
	tc.types = d.get("types", [])
	tc._chart = d.get("chart", {})
	return tc

func multiplier(attacker: String, defender: String) -> float:
	var row: Dictionary = _chart.get(attacker, {})
	if defender in row.get("none", []):
		return 0.0
	if defender in row.get("se", []):
		return 2.0
	if defender in row.get("nve", []):
		return 0.5
	return 1.0

func effectiveness(attacker: String, defender_types: Array) -> float:
	var m := 1.0
	for t in defender_types:
		m *= multiplier(attacker, t)
	return m

func validate() -> Array:
	var errors := []
	var weak := {}
	for atk in _chart:
		if atk not in types:
			errors.append("chart row for unknown type '%s'" % atk)
		var row: Dictionary = _chart[atk]
		for key in ["se", "nve", "none"]:
			for t in row.get(key, []):
				if t not in types:
					errors.append("%s.%s lists unknown type '%s'" % [atk, key, t])
		for t in row.get("se", []):
			weak[t] = true
		if row.get("se", []).is_empty() and atk != "kin":
			errors.append("type '%s' has no super-effective target" % atk)
	for t in types:
		if not weak.has(t):
			errors.append("type '%s' has no weakness" % t)
	return errors
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `tools/test.sh`
Expected: all pass (`14 passed, 0 failed`).

- [ ] **Step 8: Commit and push**

```bash
git add -A
git commit -m "feat(data): JSON loading, rules constants, 16-type chart"
git push
```

---

### Task 5: Move database and starter moves

**Files:**
- Create: `data_api/move_db.gd`, `data/moves/kin.json`, `data/moves/hedgerow.json`, `data/moves/brook.json`, `data/moves/hearth.json`
- Test: `tests/data_api/test_move_db.gd`

**Interfaces:**
- Consumes: `JsonUtil` (Task 4).
- Produces: `MoveDB.load_default() -> MoveDB`, `MoveDB.load_dir(dir: String) -> MoveDB`, `MoveDB.from_array(arr: Array) -> MoveDB`, `MoveDB.normalise(m: Dictionary) -> Dictionary` (static), `.add(m: Dictionary)`, `.get_move(id: String) -> Dictionary` (`{}` if unknown), `.has(id: String) -> bool`, `.ids() -> Array`, `.duplicates: Array`.
- Move shape: `{"id", "name", "type", "category", "power": int, "accuracy": int (1..100), "pp": int, "priority": int, "effect": {"id": "none"} | {"id": "stat", "target": "self"|"foe", "stat", "stages": int, "chance": int} | {"id": "status", "status", "chance": int}}`. `effect.target` defaults to `"foe"`, `effect.chance` to 100.

- [ ] **Step 1: Write the failing tests `tests/data_api/test_move_db.gd`**

```gdscript
extends TestCase

var db := MoveDB.load_default()

func test_loads_starter_moves() -> void:
	for id in ["scrap", "glare", "bramble_lash", "rill_shot", "kindle", "drench"]:
		assert_true(db.has(id), id)

func test_move_fields() -> void:
	var m := db.get_move("kindle")
	assert_eq(m.type, "hearth")
	assert_eq(m.category, "special")
	assert_eq(m.power, 40)

func test_move_numbers_are_ints() -> void:
	var m := db.get_move("quick_nip")
	for key in ["power", "accuracy", "pp", "priority"]:
		assert_eq(typeof(m[key]), TYPE_INT, key)
	assert_eq(m.priority, 1)

func test_effect_defaults() -> void:
	var m := MoveDB.normalise({"id": "x", "effect": {"id": "status", "status": "soaked"}})
	assert_eq(m.effect.chance, 100)
	assert_eq(m.effect.target, "foe")
	assert_eq(MoveDB.normalise({"id": "y"}).effect.id, "none")

func test_unknown_move_is_empty() -> void:
	assert_eq(db.get_move("nope"), {})

func test_duplicates_are_recorded() -> void:
	var d := MoveDB.from_array([{"id": "a"}, {"id": "a"}])
	assert_eq(d.duplicates, ["a"])
```

- [ ] **Step 2: Run to verify it fails**

Run: `tools/test.sh move_db` — Expected: FAIL (MoveDB not defined).

- [ ] **Step 3: Create `data_api/move_db.gd`**

```gdscript
class_name MoveDB
extends RefCounted
## All moves, keyed by id. Loaded from every JSON array in data/moves/.

const DEFAULT_DIR := "res://data/moves"

var duplicates: Array = []
var _moves: Dictionary = {}

static func load_default() -> MoveDB:
	return load_dir(DEFAULT_DIR)

static func load_dir(dir: String) -> MoveDB:
	var all := []
	for path in JsonUtil.list_json(dir):
		var arr = JsonUtil.read(path)
		if arr is Array:
			all.append_array(arr)
	return from_array(all)

static func from_array(arr: Array) -> MoveDB:
	var db := MoveDB.new()
	for m in arr:
		db.add(normalise(m))
	return db

static func normalise(m: Dictionary) -> Dictionary:
	var out := m.duplicate(true)
	for key in ["power", "accuracy", "pp", "priority"]:
		out[key] = int(m.get(key, 0))
	var fx: Dictionary = m.get("effect", {"id": "none"}).duplicate()
	fx["chance"] = int(fx.get("chance", 100))
	if fx.get("id") == "stat":
		fx["stages"] = int(fx.get("stages", 0))
	fx["target"] = fx.get("target", "foe")
	out["effect"] = fx
	return out

func add(m: Dictionary) -> void:
	var id: String = m.get("id", "")
	if _moves.has(id):
		duplicates.append(id)
	_moves[id] = m

func get_move(id: String) -> Dictionary:
	return _moves.get(id, {})

func has(id: String) -> bool:
	return _moves.has(id)

func ids() -> Array:
	return _moves.keys()
```

- [ ] **Step 4: Create the move files**

`data/moves/kin.json`:
```json
[
  {"id": "scrap", "name": "Scrap", "type": "kin", "category": "physical", "power": 40, "accuracy": 100, "pp": 35, "priority": 0, "effect": {"id": "none"}},
  {"id": "glare", "name": "Glare", "type": "kin", "category": "status", "power": 0, "accuracy": 100, "pp": 30, "priority": 0, "effect": {"id": "stat", "target": "foe", "stat": "atk", "stages": -1}},
  {"id": "quick_nip", "name": "Quick Nip", "type": "kin", "category": "physical", "power": 40, "accuracy": 100, "pp": 30, "priority": 1, "effect": {"id": "none"}},
  {"id": "hunker", "name": "Hunker Down", "type": "kin", "category": "status", "power": 0, "accuracy": 100, "pp": 30, "priority": 0, "effect": {"id": "stat", "target": "self", "stat": "def", "stages": 1}},
  {"id": "barge", "name": "Barge", "type": "kin", "category": "physical", "power": 70, "accuracy": 100, "pp": 20, "priority": 0, "effect": {"id": "none"}}
]
```

`data/moves/hedgerow.json`:
```json
[
  {"id": "bramble_lash", "name": "Bramble Lash", "type": "hedgerow", "category": "physical", "power": 45, "accuracy": 100, "pp": 25, "priority": 0, "effect": {"id": "none"}},
  {"id": "spore_puff", "name": "Spore Puff", "type": "hedgerow", "category": "status", "power": 0, "accuracy": 75, "pp": 15, "priority": 0, "effect": {"id": "status", "status": "asleep"}},
  {"id": "thorn_volley", "name": "Thorn Volley", "type": "hedgerow", "category": "physical", "power": 75, "accuracy": 95, "pp": 15, "priority": 0, "effect": {"id": "status", "status": "stung", "chance": 20}}
]
```

`data/moves/brook.json`:
```json
[
  {"id": "rill_shot", "name": "Rill Shot", "type": "brook", "category": "special", "power": 40, "accuracy": 100, "pp": 25, "priority": 0, "effect": {"id": "none"}},
  {"id": "drench", "name": "Drench", "type": "brook", "category": "status", "power": 0, "accuracy": 100, "pp": 20, "priority": 0, "effect": {"id": "status", "status": "soaked"}},
  {"id": "spate_surge", "name": "Spate Surge", "type": "brook", "category": "special", "power": 80, "accuracy": 100, "pp": 10, "priority": 0, "effect": {"id": "none"}}
]
```

`data/moves/hearth.json`:
```json
[
  {"id": "kindle", "name": "Kindle", "type": "hearth", "category": "special", "power": 40, "accuracy": 100, "pp": 25, "priority": 0, "effect": {"id": "none"}},
  {"id": "smoulder", "name": "Smoulder", "type": "hearth", "category": "special", "power": 60, "accuracy": 100, "pp": 15, "priority": 0, "effect": {"id": "status", "status": "hexed", "chance": 10}},
  {"id": "blaze_dash", "name": "Blaze Dash", "type": "hearth", "category": "physical", "power": 80, "accuracy": 95, "pp": 10, "priority": 0, "effect": {"id": "none"}}
]
```

- [ ] **Step 5: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "feat(data): move database and starter moves"
git push
```

---

### Task 6: Dex and the three starter lines

**Files:**
- Create: `data_api/dex.gd`, `data/creatures/spikkin.json`, `data/creatures/holtling.json`, `data/creatures/kindlet.json`
- Test: `tests/data_api/test_dex.gd`

**Interfaces:**
- Consumes: `JsonUtil`, `Rules.STATS` (Task 4).
- Produces: `Dex.load_default() -> Dex`, `Dex.load_dir(dir) -> Dex`, `Dex.from_array(arr: Array) -> Dex`, `Dex.normalise(sp) -> Dictionary` (static), `.get_species(id) -> Dictionary` (`{}` if unknown), `.has(id) -> bool`, `.ids() -> Array` (load order), `.duplicates: Array`.
- Species shape: `{"id", "name", "types": [1-2], "base": {stat: int}, "growth", "catch_rate": int, "base_xp": int, "learnset": [[int level, String move_id], ...], "evolves": null | {"to": id, "level": int}, "habitat": [], "dex": {"text", "fact"}, "sprite"}`. Creature files are `{"line": "<first stage id>", "species": [...]}`.

- [ ] **Step 1: Write the failing tests `tests/data_api/test_dex.gd`**

```gdscript
extends TestCase

var dex := Dex.load_default()

func test_nine_starter_species() -> void:
	for id in ["spikkin", "bramblehog", "thornsow", "holtling", "rillotter", "spatelord", "kindlet", "emberdrey", "pyredrey"]:
		assert_true(dex.has(id), id)

func test_species_numbers_are_ints() -> void:
	var sp := dex.get_species("kindlet")
	for s in Rules.STATS:
		assert_eq(typeof(sp.base[s]), TYPE_INT, s)
	assert_eq(typeof(sp.catch_rate), TYPE_INT)
	assert_eq(typeof(sp.learnset[0][0]), TYPE_INT)
	assert_eq(typeof(sp.evolves.level), TYPE_INT)

func test_evolution_chain() -> void:
	assert_eq(dex.get_species("spikkin").evolves.to, "bramblehog")
	assert_eq(dex.get_species("bramblehog").evolves.to, "thornsow")
	assert_eq(dex.get_species("thornsow").evolves, null)

func test_dual_type_final_stage() -> void:
	assert_eq(dex.get_species("pyredrey").types, ["hearth", "gale"])

func test_unknown_species_is_empty() -> void:
	assert_eq(dex.get_species("nope"), {})

func test_missing_stat_becomes_zero_for_the_validator_to_catch() -> void:
	var sp := Dex.normalise({"id": "x", "base": {"hp": 10}})
	assert_eq(sp.base.atk, 0)
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh dex` — Expected: FAIL.

- [ ] **Step 3: Create `data_api/dex.gd`**

```gdscript
class_name Dex
extends RefCounted
## All species, keyed by id. Loaded from every evolution-line JSON file in data/creatures/.

const DEFAULT_DIR := "res://data/creatures"

var duplicates: Array = []
var _species: Dictionary = {}
var _order: Array = []

static func load_default() -> Dex:
	return load_dir(DEFAULT_DIR)

static func load_dir(dir: String) -> Dex:
	var all := []
	for path in JsonUtil.list_json(dir):
		var line = JsonUtil.read(path)
		if line is Dictionary:
			all.append_array(line.get("species", []))
	return from_array(all)

static func from_array(arr: Array) -> Dex:
	var dex := Dex.new()
	for sp in arr:
		dex._add(normalise(sp))
	return dex

static func normalise(sp: Dictionary) -> Dictionary:
	var out := sp.duplicate(true)
	var base := {}
	var raw_base: Dictionary = sp.get("base", {})
	for s in Rules.STATS:
		base[s] = int(raw_base.get(s, 0))
	out["base"] = base
	out["catch_rate"] = int(sp.get("catch_rate", 0))
	out["base_xp"] = int(sp.get("base_xp", 0))
	var learnset := []
	for entry in sp.get("learnset", []):
		learnset.append([int(entry[0]), str(entry[1])])
	out["learnset"] = learnset
	var evo = sp.get("evolves")
	if evo is Dictionary:
		var e: Dictionary = evo.duplicate()
		if e.has("level"):
			e["level"] = int(e["level"])
		out["evolves"] = e
	else:
		out["evolves"] = null
	return out

func _add(sp: Dictionary) -> void:
	var id: String = sp.get("id", "")
	if _species.has(id):
		duplicates.append(id)
	else:
		_order.append(id)
	_species[id] = sp

func get_species(id: String) -> Dictionary:
	return _species.get(id, {})

func has(id: String) -> bool:
	return _species.has(id)

func ids() -> Array:
	return _order.duplicate()
```

- [ ] **Step 4: Create the starter lines**

`data/creatures/spikkin.json`:
```json
{
  "line": "spikkin",
  "species": [
    {"id": "spikkin", "name": "Spikkin", "types": ["hedgerow"],
     "base": {"hp": 45, "atk": 55, "def": 62, "lore": 45, "ward": 55, "spd": 48},
     "growth": "medium", "catch_rate": 45, "base_xp": 62,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "bramble_lash"], [9, "hunker"], [13, "spore_puff"], [18, "thorn_volley"], [24, "barge"]],
     "evolves": {"to": "bramblehog", "level": 16}, "habitat": [],
     "dex": {"text": "Snuffles along hedge bottoms at dusk, grumbling to itself. Rolls into a prickly ball and waits for trouble to get bored.",
             "fact": "A hedgehog has around 5,000 to 7,000 spines. Each one is a hollow hair made stiff with keratin, the same stuff as your fingernails."},
     "sprite": "spikkin"},
    {"id": "bramblehog", "name": "Bramblehog", "types": ["hedgerow"],
     "base": {"hp": 60, "atk": 72, "def": 82, "lore": 58, "ward": 70, "spd": 63},
     "growth": "medium", "catch_rate": 45, "base_xp": 142,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "bramble_lash"], [9, "hunker"], [13, "spore_puff"], [18, "thorn_volley"], [24, "barge"]],
     "evolves": {"to": "thornsow", "level": 32}, "habitat": [],
     "dex": {"text": "Its spines have grown into living bramble. Gardeners leave a gap under the fence for it, which it considers the least they could do.",
             "fact": "Hedgehogs can travel a mile or more a night looking for food, which is why holes in garden fences, called hedgehog highways, help them so much."},
     "sprite": "bramblehog"},
    {"id": "thornsow", "name": "Thornsow", "types": ["hedgerow", "brawn"],
     "base": {"hp": 80, "atk": 98, "def": 105, "lore": 72, "ward": 90, "spd": 85},
     "growth": "medium", "catch_rate": 45, "base_xp": 236,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "bramble_lash"], [9, "hunker"], [13, "spore_puff"], [18, "thorn_volley"], [24, "barge"]],
     "evolves": null, "habitat": [],
     "dex": {"text": "A walking hedgerow the size of a pony. Old farmers say a field with a Thornsow in it never needs a gate.",
             "fact": "Hedgehogs are one of the few mammals with some resistance to adder venom, though they are not immune."},
     "sprite": "thornsow"}
  ]
}
```

`data/creatures/holtling.json`:
```json
{
  "line": "holtling",
  "species": [
    {"id": "holtling", "name": "Holtling", "types": ["brook"],
     "base": {"hp": 44, "atk": 50, "def": 48, "lore": 58, "ward": 50, "spd": 60},
     "growth": "medium", "catch_rate": 45, "base_xp": 62,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "rill_shot"], [9, "drench"], [13, "quick_nip"], [18, "spate_surge"], [24, "barge"]],
     "evolves": {"to": "rillotter", "level": 16}, "habitat": [],
     "dex": {"text": "Plays in the shallows of the River Bollin, juggling pebbles. Gets very cross if you take one.",
             "fact": "An otter's den is called a holt. Otters nearly vanished from England in the 1970s and have since returned to every county."},
     "sprite": "holtling"},
    {"id": "rillotter", "name": "Rillotter", "types": ["brook"],
     "base": {"hp": 58, "atk": 64, "def": 62, "lore": 78, "ward": 64, "spd": 79},
     "growth": "medium", "catch_rate": 45, "base_xp": 142,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "rill_shot"], [9, "drench"], [13, "quick_nip"], [18, "spate_surge"], [24, "barge"]],
     "evolves": {"to": "spatelord", "level": 32}, "habitat": [],
     "dex": {"text": "Steers small streams with a flick of its tail. Anglers suspect it, and they are right.",
             "fact": "Otter droppings are called spraint. Naturalists swear they smell of jasmine tea, and they use them to survey where otters live."},
     "sprite": "rillotter"},
    {"id": "spatelord", "name": "Spatelord", "types": ["brook", "night"],
     "base": {"hp": 75, "atk": 84, "def": 80, "lore": 102, "ward": 85, "spd": 104},
     "growth": "medium", "catch_rate": 45, "base_xp": 236,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "rill_shot"], [9, "drench"], [13, "quick_nip"], [18, "spate_surge"], [24, "barge"]],
     "evolves": null, "habitat": [],
     "dex": {"text": "Hunts by moonlight when the rivers are in spate. Its wake can turn a mill wheel.",
             "fact": "Otters are mostly active at night. Their whiskers can sense the movement of fish in murky water."},
     "sprite": "spatelord"}
  ]
}
```

`data/creatures/kindlet.json`:
```json
{
  "line": "kindlet",
  "species": [
    {"id": "kindlet", "name": "Kindlet", "types": ["hearth"],
     "base": {"hp": 40, "atk": 58, "def": 44, "lore": 56, "ward": 46, "spd": 66},
     "growth": "medium", "catch_rate": 45, "base_xp": 62,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "kindle"], [9, "quick_nip"], [13, "smoulder"], [18, "blaze_dash"], [24, "barge"]],
     "evolves": {"to": "emberdrey", "level": 16}, "habitat": [],
     "dex": {"text": "Its tail glows like a coal when it is pleased. Buries hazelnuts and forgets most of them, which is how half of Macclesfield Forest got planted.",
             "fact": "Red squirrels are now rare in England. Most of Britain's live in Scotland, with smaller groups on Anglesey, the Isle of Wight and at Formby near Liverpool."},
     "sprite": "kindlet"},
    {"id": "emberdrey", "name": "Emberdrey", "types": ["hearth"],
     "base": {"hp": 55, "atk": 76, "def": 58, "lore": 74, "ward": 60, "spd": 82},
     "growth": "medium", "catch_rate": 45, "base_xp": 142,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "kindle"], [9, "quick_nip"], [13, "smoulder"], [18, "blaze_dash"], [24, "barge"]],
     "evolves": {"to": "pyredrey", "level": 32}, "habitat": [],
     "dex": {"text": "Builds warm nests of twigs high in the pines and keeps them toasty all winter. Other creatures queue to visit.",
             "fact": "A squirrel's nest is called a drey. Red squirrels often build several and move between them."},
     "sprite": "emberdrey"},
    {"id": "pyredrey", "name": "Pyredrey", "types": ["hearth", "gale"],
     "base": {"hp": 70, "atk": 100, "def": 74, "lore": 96, "ward": 80, "spd": 110},
     "growth": "medium", "catch_rate": 45, "base_xp": 236,
     "learnset": [[1, "scrap"], [1, "glare"], [5, "kindle"], [9, "quick_nip"], [13, "smoulder"], [18, "blaze_dash"], [24, "barge"]],
     "evolves": null, "habitat": [],
     "dex": {"text": "Leaps between treetops trailing sparks like a firework. Strictly forbidden in thatched villages.",
             "fact": "A red squirrel's bushy tail helps it balance on thin branches, and it wraps it round itself like a blanket when it sleeps."},
     "sprite": "pyredrey"}
  ]
}
```

- [ ] **Step 5: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "feat(data): dex loader and the three Cheshire starter lines"
git push
```

---

### Task 7: Data validator in CI

**Files:**
- Create: `data_api/validator.gd`, `tools/validate.gd`
- Modify: `tools/test.sh` (append a validator run)
- Test: `tests/data_api/test_validator.gd`

**Interfaces:**
- Consumes: `TypeChart`, `MoveDB`, `Dex`, `Rules`.
- Produces: `DataValidator.validate(chart: TypeChart, dex: Dex, moves: MoveDB) -> Array` (error strings, empty when valid). `tools/validate.gd` exits 1 and prints `DATA: <error>` lines on failure.

- [ ] **Step 1: Write the failing tests `tests/data_api/test_validator.gd`**

```gdscript
extends TestCase

var chart := TypeChart.load_default()
var moves := MoveDB.load_default()

func _sp(id: String, extra := {}) -> Dictionary:
	var sp := {"id": id, "name": id.capitalize(), "types": ["kin"],
		"base": {"hp": 50, "atk": 50, "def": 50, "lore": 50, "ward": 50, "spd": 50},
		"growth": "medium", "catch_rate": 45, "base_xp": 60, "learnset": [[1, "scrap"]],
		"evolves": null, "habitat": [], "dex": {"text": "t", "fact": "f"}, "sprite": id}
	sp.merge(extra, true)
	return sp

func _errors_for(species: Array) -> Array:
	return DataValidator.validate(chart, Dex.from_array(species), moves)

func _has_error_containing(errors: Array, needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false

func test_real_data_is_valid() -> void:
	assert_eq(DataValidator.validate(chart, Dex.load_default(), moves), [])

func test_minimal_species_is_valid() -> void:
	assert_eq(_errors_for([_sp("a")]), [])

func test_unknown_learnset_move() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"learnset": [[1, "nope"]]})]), "'nope' does not exist"))

func test_unknown_type() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"types": ["lava"]})]), "unknown type 'lava'"))

func test_too_many_types() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"types": ["kin", "bog", "fae"]})]), "1 or 2 types"))

func test_missing_evolution_target() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"evolves": {"to": "b", "level": 10}})]), "unknown species 'b'"))

func test_missing_fact() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"dex": {"text": "t", "fact": ""}})]), "real-world fact"))

func test_bad_base_stat() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"base": {"hp": 50}})]), "base atk"))

func test_duplicate_species() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a"), _sp("a")]), "'a' defined more than once"))

func test_bad_move() -> void:
	var bad := MoveDB.from_array([{"id": "m", "name": "M", "type": "kin", "category": "physical", "power": 0, "accuracy": 100, "pp": 10}])
	var errors := DataValidator.validate(chart, Dex.from_array([]), bad)
	assert_true(_has_error_containing(errors, "needs power"))
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh validator` — Expected: FAIL.

- [ ] **Step 3: Create `data_api/validator.gd`**

```gdscript
class_name DataValidator
extends RefCounted
## Cross-checks all game data. Returns human-readable errors; an empty array means valid.

static func validate(chart: TypeChart, dex: Dex, moves: MoveDB) -> Array:
	var errors := chart.validate()
	for id in moves.duplicates:
		errors.append("move id '%s' defined more than once" % id)
	for id in dex.duplicates:
		errors.append("species id '%s' defined more than once" % id)
	for id in moves.ids():
		errors.append_array(_check_move(moves.get_move(id), chart))
	for id in dex.ids():
		errors.append_array(_check_species(dex.get_species(id), chart, dex, moves))
	return errors

static func _check_move(m: Dictionary, chart: TypeChart) -> Array:
	var e := []
	var id: String = m.get("id", "?")
	if str(m.get("name", "")) == "":
		e.append("move %s: missing name" % id)
	if m.get("type") not in chart.types:
		e.append("move %s: unknown type '%s'" % [id, m.get("type")])
	if m.get("category") not in Rules.CATEGORIES:
		e.append("move %s: unknown category '%s'" % [id, m.get("category")])
	if m.get("category") != "status" and int(m.power) <= 0:
		e.append("move %s: damaging move needs power > 0" % id)
	if int(m.accuracy) < 1 or int(m.accuracy) > 100:
		e.append("move %s: accuracy must be 1..100" % id)
	if int(m.pp) < 1 or int(m.pp) > 64:
		e.append("move %s: pp must be 1..64" % id)
	var fx: Dictionary = m.get("effect", {})
	if fx.get("id") not in Rules.EFFECTS:
		e.append("move %s: unknown effect '%s'" % [id, fx.get("id")])
	elif fx.id == "stat":
		if fx.get("stat") not in Rules.STAGE_STATS:
			e.append("move %s: unknown stat '%s'" % [id, fx.get("stat")])
		if int(fx.get("stages", 0)) == 0:
			e.append("move %s: stat effect needs non-zero stages" % id)
	elif fx.id == "status" and fx.get("status") not in Rules.STATUSES:
		e.append("move %s: unknown status '%s'" % [id, fx.get("status")])
	if fx.get("target", "foe") not in ["self", "foe"]:
		e.append("move %s: effect target must be self or foe" % id)
	return e

static func _check_species(sp: Dictionary, chart: TypeChart, dex: Dex, moves: MoveDB) -> Array:
	var e := []
	var id: String = sp.get("id", "?")
	if str(sp.get("name", "")) == "":
		e.append("species %s: missing name" % id)
	var types: Array = sp.get("types", [])
	if types.size() < 1 or types.size() > 2:
		e.append("species %s: needs 1 or 2 types" % id)
	for t in types:
		if t not in chart.types:
			e.append("species %s: unknown type '%s'" % [id, t])
	if types.size() == 2 and types[0] == types[1]:
		e.append("species %s: repeats a type" % id)
	for s in Rules.STATS:
		var v: int = sp.base[s]
		if v < 1 or v > 255:
			e.append("species %s: base %s must be 1..255" % [id, s])
	if sp.get("growth") not in Rules.GROWTH_RATES:
		e.append("species %s: unknown growth '%s'" % [id, sp.get("growth")])
	if sp.catch_rate < 1 or sp.catch_rate > 255:
		e.append("species %s: catch_rate must be 1..255" % id)
	if sp.base_xp < 1:
		e.append("species %s: base_xp must be positive" % id)
	if sp.learnset.is_empty():
		e.append("species %s: empty learnset" % id)
	for entry in sp.learnset:
		if entry[0] < 1 or entry[0] > Rules.MAX_LEVEL:
			e.append("species %s: learnset level %d out of range" % [id, entry[0]])
		if not moves.has(entry[1]):
			e.append("species %s: learnset move '%s' does not exist" % [id, entry[1]])
	var evo = sp.evolves
	if evo != null:
		var target: String = evo.get("to", "")
		if not dex.has(target):
			e.append("species %s: evolves into unknown species '%s'" % [id, target])
		elif target == id:
			e.append("species %s: evolves into itself" % id)
		if not evo.has("level"):
			e.append("species %s: evolution needs a level (item and weather rules arrive in plan 2)" % id)
	var d: Dictionary = sp.get("dex", {})
	if str(d.get("text", "")) == "" or str(d.get("fact", "")) == "":
		e.append("species %s: needs Creaturepedia text and a real-world fact" % id)
	return e
```

- [ ] **Step 4: Create `tools/validate.gd`**

```gdscript
extends SceneTree
## Headless data validation. Usage: godot --headless --path . -s res://tools/validate.gd

func _initialize() -> void:
	var errors := DataValidator.validate(TypeChart.load_default(), Dex.load_default(), MoveDB.load_default())
	for e in errors:
		printerr("DATA: " + e)
	print("validate: %d error(s)" % errors.size())
	quit(1 if errors.size() > 0 else 0)
```

- [ ] **Step 5: Append the validator run to `tools/test.sh`**, replacing the final `rm -f "$LOG"` and `exit "$STATUS"` lines with:

```bash
rm -f "$LOG"
"$GODOT" --headless --path . -s res://tools/validate.gd || STATUS=1
exit "$STATUS"
```

- [ ] **Step 6: Run** — `tools/test.sh` — Expected: all tests pass, then `validate: 0 error(s)`, exit 0. Then break `data/creatures/kindlet.json` temporarily (change `"kindle"` in one learnset to `"kindel"`), rerun, expect `DATA: species kindlet: learnset move 'kindel' does not exist` and exit 1; revert.

- [ ] **Step 7: Commit and push**

```bash
git add -A
git commit -m "feat(data): data validator, run by tools/test.sh and CI"
git push
```

---

### Task 8: Rng, test doubles, and Creature instances

**Files:**
- Create: `battle/rng.gd`, `battle/creature.gd`, `tests/support/fixed_rng.gd`, `tests/support/fixtures.gd`
- Test: `tests/battle/test_creature.gd`

**Interfaces:**
- Consumes: `Rules`, `Dex`, `MoveDB`.
- Produces:
  - `Rng.new(seed_value: int = 0)`, `.roll() -> float` (0..1), `.roll_int(a: int, b: int) -> int` (inclusive), `.roll_range(a: float, b: float) -> float`, `.chance(percent: float) -> bool` (true without rolling at >= 100, false at <= 0), `.pick(arr: Array)`.
  - `FixedRng` (extends Rng, tests only): `.f := 1.0` returned by `roll()`; `roll_int` returns `a` (or `b` when `.hi = true`); `roll_range(a, b) = a + (b - a) * f`; `chance(p) = f * 100 < p` (same >=100 / <=0 shortcuts); `pick(arr) = arr[0]`. Default `f = 1.0` means: no crits, max damage roll, no random status procs.
  - `Creature.create(sp: Dictionary, lvl: int, rng: Rng, move_db: MoveDB) -> Creature`, `Creature.from_dict(d: Dictionary, dex: Dex) -> Creature`, `Creature.default_moves(sp, lvl) -> Array`.
  - Creature fields: `species, nickname, level, xp, nature, ivs, training, hp, moves ([{"id","pp","max_pp"}]), status, status_turns, stages`.
  - Creature methods: `display_name() -> String`, `types() -> Array`, `max_hp() -> int`, `calc_stat(s) -> int`, `nature_mod(s) -> float`, `reset_stages()`, `stage_mult(s) -> float`, `battle_stat(s) -> int`, `change_stage(s, delta) -> int` (applied delta), `is_fainted() -> bool`, `take_damage(n) -> int`, `heal(n) -> int`, `make_move_slot(id, move_db) -> Dictionary`, `has_move(id) -> bool`, `to_dict() -> Dictionary`.
  - `Fixtures.chart()`, `Fixtures.dex()`, `Fixtures.moves()`, `Fixtures.creature(species_id, level) -> Creature` (zero IVs, steady nature), `Fixtures.species(id, types, base := 50, extra := {}) -> Dictionary`. `Fixtures.battle(...)` is added in Task 11.

- [ ] **Step 1: Write the failing tests `tests/battle/test_creature.gd`**

```gdscript
extends TestCase

func test_stats_follow_formula() -> void:
	# kindlet lore base 56, level 10, iv 0: (112 * 10) / 100 = 11, + 5 = 16
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.calc_stat("lore"), 16)
	# hp base 40: (80 * 10) / 100 = 8, + 10 + 10 = 28
	assert_eq(c.max_hp(), 28)
	assert_eq(c.hp, 28)

func test_nature_raises_and_lowers() -> void:
	var c := Fixtures.creature("kindlet", 50)
	var neutral := c.calc_stat("spd")
	c.nature = "cheeky"
	assert_eq(c.calc_stat("spd"), int(neutral * 1.1))
	assert_eq(c.nature_mod("def"), 0.9)

func test_default_moves_are_last_four_learned() -> void:
	var c := Fixtures.creature("kindlet", 13)
	var ids := c.moves.map(func(m): return m.id)
	assert_eq(ids, ["glare", "kindle", "quick_nip", "smoulder"])
	assert_eq(c.moves[1].pp, 25)

func test_stage_multipliers() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.change_stage("atk", 2), 2)
	assert_eq(c.stage_mult("atk"), 2.0)
	c.change_stage("atk", -4)
	assert_eq(c.stage_mult("atk"), 0.5)
	assert_eq(c.change_stage("def", -9), -6)
	assert_eq(c.change_stage("def", -1), 0)
	c.change_stage("acc", 3)
	assert_eq(c.stage_mult("acc"), 2.0)

func test_damage_and_heal_clamp() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.take_damage(500), 28)
	assert_true(c.is_fainted())
	assert_eq(c.heal(500), 28)

func test_round_trip_through_json() -> void:
	var c := Creature.create(Fixtures.dex().get_species("holtling"), 12, Rng.new(42), Fixtures.moves())
	c.nickname = "Bolly"
	c.take_damage(3)
	var text := JSON.stringify(c.to_dict())
	var back := Creature.from_dict(JSON.parse_string(text), Fixtures.dex())
	assert_eq(back.to_dict(), c.to_dict())
	assert_eq(typeof(back.ivs.hp), TYPE_INT)
	assert_eq(back.display_name(), "Bolly")

func test_seeded_creation_is_repeatable() -> void:
	var sp := Fixtures.dex().get_species("spikkin")
	var a := Creature.create(sp, 5, Rng.new(7), Fixtures.moves())
	var b := Creature.create(sp, 5, Rng.new(7), Fixtures.moves())
	assert_eq(a.to_dict(), b.to_dict())

func test_rng_chance_edges() -> void:
	var r := Rng.new(1)
	assert_true(r.chance(100))
	assert_false(r.chance(0))
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh creature` — Expected: FAIL.

- [ ] **Step 3: Create `battle/rng.gd`**

```gdscript
class_name Rng
extends RefCounted
## Seeded RNG wrapper so battles replay identically from a seed.

var _r := RandomNumberGenerator.new()

func _init(seed_value: int = 0) -> void:
	_r.seed = seed_value

func roll() -> float:
	return _r.randf()

func roll_int(a: int, b: int) -> int:
	return _r.randi_range(a, b)

func roll_range(a: float, b: float) -> float:
	return _r.randf_range(a, b)

func chance(percent: float) -> bool:
	if percent >= 100.0:
		return true
	if percent <= 0.0:
		return false
	return _r.randf() * 100.0 < percent

func pick(arr: Array):
	return arr[_r.randi_range(0, arr.size() - 1)]
```

- [ ] **Step 4: Create `tests/support/fixed_rng.gd`**

```gdscript
class_name FixedRng
extends Rng
## Test double. Every roll returns `f`; integer rolls return the low bound (or high with hi = true).
## Default f = 1.0: no crits, maximum damage roll, no random status procs.

var f := 1.0
var hi := false

func roll() -> float:
	return f

func roll_int(a: int, b: int) -> int:
	return b if hi else a

func roll_range(a: float, b: float) -> float:
	return a + (b - a) * f

func chance(percent: float) -> bool:
	if percent >= 100.0:
		return true
	if percent <= 0.0:
		return false
	return f * 100.0 < percent

func pick(arr: Array):
	return arr[0]
```

- [ ] **Step 5: Create `battle/creature.gd`**

```gdscript
class_name Creature
extends RefCounted
## One individual creature: species data plus everything personal to it.

var species: Dictionary
var nickname := ""
var level := 1
var xp := 0
var nature := "steady"
var ivs := {}          # stat -> 0..Rules.IV_MAX
var training := {}     # stat -> 0..Rules.TRAINING_STAT_CAP
var hp := 1
var moves: Array = []  # [{"id": String, "pp": int, "max_pp": int}]
var status := ""
var status_turns := 0
var stages := {}       # Rules.STAGE_STATS -> -6..6, reset on switch-out

static func create(sp: Dictionary, lvl: int, rng: Rng, move_db: MoveDB) -> Creature:
	var c := Creature.new()
	c.species = sp
	c.level = clampi(lvl, 1, Rules.MAX_LEVEL)
	c.xp = Rules.xp_for_level(sp.growth, c.level)
	for s in Rules.STATS:
		c.ivs[s] = rng.roll_int(0, Rules.IV_MAX)
		c.training[s] = 0
	c.nature = rng.pick(Rules.NATURES.keys())
	for id in default_moves(sp, c.level):
		c.moves.append(c.make_move_slot(id, move_db))
	c.reset_stages()
	c.hp = c.max_hp()
	return c

## The last four distinct moves learnable at or below `lvl`, in learn order.
static func default_moves(sp: Dictionary, lvl: int) -> Array:
	var ids := []
	for entry in sp.learnset:
		if entry[0] <= lvl and entry[1] not in ids:
			ids.append(entry[1])
	return ids.slice(maxi(0, ids.size() - Rules.MAX_MOVES))

static func from_dict(d: Dictionary, dex: Dex) -> Creature:
	var c := Creature.new()
	c.species = dex.get_species(d.species)
	c.nickname = d.get("nickname", "")
	c.level = int(d.level)
	c.xp = int(d.xp)
	c.nature = d.nature
	for s in Rules.STATS:
		c.ivs[s] = int(d.ivs[s])
		c.training[s] = int(d.training[s])
	c.hp = int(d.hp)
	for m in d.moves:
		c.moves.append({"id": m.id, "pp": int(m.pp), "max_pp": int(m.max_pp)})
	c.status = d.get("status", "")
	c.status_turns = int(d.get("status_turns", 0))
	c.reset_stages()
	return c

func to_dict() -> Dictionary:
	return {"species": species.id, "nickname": nickname, "level": level, "xp": xp, "nature": nature,
		"ivs": ivs.duplicate(), "training": training.duplicate(), "hp": hp,
		"moves": moves.duplicate(true), "status": status, "status_turns": status_turns}

func make_move_slot(id: String, move_db: MoveDB) -> Dictionary:
	var pp := int(move_db.get_move(id).get("pp", 10))
	return {"id": id, "pp": pp, "max_pp": pp}

func has_move(id: String) -> bool:
	for m in moves:
		if m.id == id:
			return true
	return false

func display_name() -> String:
	return nickname if nickname != "" else species.name

func types() -> Array:
	return species.types

func max_hp() -> int:
	return calc_stat("hp")

func calc_stat(s: String) -> int:
	var core: int = (2 * species.base[s] + 2 * ivs.get(s, 0) + training.get(s, 0) / 4) * level / 100
	if s == "hp":
		return core + level + 10
	return int((core + 5) * nature_mod(s))

func nature_mod(s: String) -> float:
	var n: Array = Rules.NATURES.get(nature, [])
	if n.is_empty():
		return 1.0
	if n[0] == s:
		return 1.1
	if n[1] == s:
		return 0.9
	return 1.0

func reset_stages() -> void:
	for s in Rules.STAGE_STATS:
		stages[s] = 0

func stage_mult(s: String) -> float:
	var st: int = stages.get(s, 0)
	if s == "acc":
		return (3.0 + st) / 3.0 if st >= 0 else 3.0 / (3.0 - st)
	return (2.0 + st) / 2.0 if st >= 0 else 2.0 / (2.0 - st)

func battle_stat(s: String) -> int:
	return maxi(1, int(calc_stat(s) * stage_mult(s)))

func change_stage(s: String, delta: int) -> int:
	var old: int = stages[s]
	stages[s] = clampi(old + delta, -6, 6)
	return stages[s] - old

func is_fainted() -> bool:
	return hp <= 0

func take_damage(n: int) -> int:
	var dealt := mini(n, hp)
	hp -= dealt
	return dealt

func heal(n: int) -> int:
	var healed := mini(n, max_hp() - hp)
	hp += healed
	return healed
```

- [ ] **Step 6: Create `tests/support/fixtures.gd`**

```gdscript
class_name Fixtures
extends RefCounted
## Shared builders for tests: real data where it exists, tiny hand-made species where a test needs something odd.

static var _chart: TypeChart
static var _dex: Dex
static var _moves: MoveDB

static func chart() -> TypeChart:
	if _chart == null:
		_chart = TypeChart.load_default()
	return _chart

static func dex() -> Dex:
	if _dex == null:
		_dex = Dex.load_default()
	return _dex

static func moves() -> MoveDB:
	if _moves == null:
		_moves = MoveDB.load_default()
	return _moves

## Zero IVs, no training, "steady" nature: stats are exactly predictable.
static func creature(species_id: String, level: int) -> Creature:
	return Creature.create(dex().get_species(species_id), level, FixedRng.new(), moves())

## A normalised hand-made species, for tests that need types or stats no real creature has.
static func species(id: String, types: Array, base := 50, extra := {}) -> Dictionary:
	var sp := {"id": id, "name": id.capitalize(), "types": types, "base": {},
		"growth": "medium", "catch_rate": 45, "base_xp": 60, "learnset": [[1, "scrap"]],
		"evolves": null, "habitat": [], "dex": {"text": "t", "fact": "f"}, "sprite": id}
	for s in Rules.STATS:
		sp.base[s] = base
	sp.merge(extra, true)
	return Dex.normalise(sp)
```

- [ ] **Step 7: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 8: Commit and push**

```bash
git add -A
git commit -m "feat(battle): seeded Rng and Creature instances with stats, natures, stages"
git push
```

---

### Task 9: Weather and status conditions

**Files:**
- Create: `battle/weather.gd`, `battle/status_fx.gd`
- Test: `tests/battle/test_weather.gd`, `tests/battle/test_status_fx.gd`

**Interfaces:**
- Consumes: `Creature`, `Rng`, `Rules`.
- Produces:
  - `Weather.damage_mod(weather: String, move_type: String) -> float`, `Weather.accuracy_mod(weather) -> float`, `Weather.crit_mult(weather, side: int) -> float` (sunshine doubles crit chance for side 0, the player: the "morale" bonus), `Weather.pick(table: Dictionary, rng: Rng) -> String` (weighted; empty table gives `"clear"`).
  - `StatusFX.inflict(c, status, rng) -> bool`, `StatusFX.before_move(c, rng) -> Dictionary` with keys `can_act: bool, reason: String, self_hit: bool, cured_status: String`, `StatusFX.end_of_turn_damage(c) -> int`, `StatusFX.speed_mult(c) -> float`, `StatusFX.incoming_mult(c, move_type) -> float`.
- Status rules: soaked = speed x0.75 and Storm damage taken x1.5, permanent until cured; chilled = 25% chance to lose the turn; muddled = lasts 2 to 5 turns, 33% chance per turn to hit itself instead; hexed = lose 1/16 max HP at end of turn; stung = lose 1/8 max HP at end of turn; asleep = cannot act for 1 to 3 turns, then wakes and acts.

- [ ] **Step 1: Write the failing tests**

`tests/battle/test_weather.gd`:
```gdscript
extends TestCase

func test_downpour_boosts_water_and_damps_fire() -> void:
	assert_eq(Weather.damage_mod("downpour", "brook"), 1.5)
	assert_eq(Weather.damage_mod("downpour", "hearth"), 0.5)

func test_sunshine_boosts_fire_and_plants() -> void:
	assert_eq(Weather.damage_mod("sunshine", "hearth"), 1.5)
	assert_eq(Weather.damage_mod("sunshine", "hedgerow"), 1.5)

func test_clear_is_neutral() -> void:
	assert_eq(Weather.damage_mod("clear", "hearth"), 1.0)

func test_fog_hurts_accuracy() -> void:
	assert_eq(Weather.accuracy_mod("fog"), 0.85)
	assert_eq(Weather.accuracy_mod("drizzle"), 1.0)

func test_sunshine_morale_is_player_only() -> void:
	assert_eq(Weather.crit_mult("sunshine", 0), 2.0)
	assert_eq(Weather.crit_mult("sunshine", 1), 1.0)

func test_pick_is_weighted_and_has_a_default() -> void:
	assert_eq(Weather.pick({}, Rng.new(1)), "clear")
	assert_eq(Weather.pick({"drizzle": 0, "fog": 5}, Rng.new(1)), "fog")
	var r := FixedRng.new()
	r.f = 0.0
	assert_eq(Weather.pick({"drizzle": 50, "sunshine": 1}, r), "drizzle")
	r.f = 0.999
	assert_eq(Weather.pick({"drizzle": 50, "sunshine": 1}, r), "sunshine")
```

`tests/battle/test_status_fx.gd`:
```gdscript
extends TestCase

func test_inflict_only_when_healthy_and_clear() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_true(StatusFX.inflict(c, "stung", FixedRng.new()))
	assert_false(StatusFX.inflict(c, "hexed", FixedRng.new()))
	assert_eq(c.status, "stung")

func test_asleep_skips_turns_then_wakes() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "asleep", FixedRng.new())  # low bound: 1 turn
	var r := StatusFX.before_move(c, FixedRng.new())
	assert_false(r.can_act)
	assert_eq(r.reason, "asleep")
	r = StatusFX.before_move(c, FixedRng.new())
	assert_true(r.can_act)
	assert_eq(r.cured_status, "asleep")
	assert_eq(c.status, "")

func test_chilled_sometimes_loses_turn() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "chilled", FixedRng.new())
	var r := FixedRng.new()
	r.f = 0.1
	assert_false(StatusFX.before_move(c, r).can_act)
	r.f = 0.9
	assert_true(StatusFX.before_move(c, r).can_act)

func test_muddled_can_self_hit_and_wears_off() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "muddled", FixedRng.new())  # 2 turns
	var r := FixedRng.new()
	r.f = 0.0
	assert_true(StatusFX.before_move(c, r).self_hit)
	assert_true(StatusFX.before_move(c, r).self_hit)
	var last := StatusFX.before_move(c, r)
	assert_true(last.can_act)
	assert_eq(last.cured_status, "muddled")

func test_end_of_turn_damage() -> void:
	var c := Fixtures.creature("kindlet", 50)
	c.status = "stung"
	assert_eq(StatusFX.end_of_turn_damage(c), c.max_hp() / 8)
	c.status = "hexed"
	assert_eq(StatusFX.end_of_turn_damage(c), c.max_hp() / 16)
	c.status = ""
	assert_eq(StatusFX.end_of_turn_damage(c), 0)

func test_soaked_slows_and_conducts() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.status = "soaked"
	assert_eq(StatusFX.speed_mult(c), 0.75)
	assert_eq(StatusFX.incoming_mult(c, "storm"), 1.5)
	assert_eq(StatusFX.incoming_mult(c, "hearth"), 1.0)
```

- [ ] **Step 2: Run to verify they fail** — `tools/test.sh weather` and `tools/test.sh status_fx` — Expected: FAIL.

- [ ] **Step 3: Create `battle/weather.gd`**

```gdscript
class_name Weather
extends RefCounted
## Battle effects of British weather.

const DAMAGE := {
	"drizzle": {"brook": 1.1, "tide": 1.1},
	"downpour": {"brook": 1.5, "tide": 1.5, "hearth": 0.5},
	"gale": {"gale": 1.3},
	"frost": {"frost": 1.3, "hearth": 0.8},
	"sunshine": {"hearth": 1.5, "hedgerow": 1.5, "brook": 0.8},
}

static func damage_mod(weather: String, move_type: String) -> float:
	return float(DAMAGE.get(weather, {}).get(move_type, 1.0))

static func accuracy_mod(weather: String) -> float:
	return 0.85 if weather == "fog" else 1.0

## Sunshine is rare enough that the player's side gets giddy: double crit chance.
static func crit_mult(weather: String, side: int) -> float:
	return 2.0 if weather == "sunshine" and side == 0 else 1.0

## Weighted pick from {weather: weight}. Empty or all-zero tables give "clear".
static func pick(table: Dictionary, rng: Rng) -> String:
	var total := 0.0
	for w in table:
		total += float(table[w])
	if total <= 0.0:
		return "clear"
	var r := rng.roll() * total
	for w in table:
		r -= float(table[w])
		if r < 0.0:
			return w
	for w in table:
		if float(table[w]) > 0.0:
			return w
	return "clear"
```

Note: the last loop only runs if `roll()` returned exactly 1.0 (FixedRng default); it returns the first non-zero entry, keeping the result deterministic. The `pick` test uses `f = 0.999` to reach the final bucket.

- [ ] **Step 4: Create `battle/status_fx.gd`**

```gdscript
class_name StatusFX
extends RefCounted
## What each status condition does. Pure functions over a Creature; Battle turns the results into events.

static func inflict(c: Creature, status: String, rng: Rng) -> bool:
	if c.status != "" or c.is_fainted():
		return false
	c.status = status
	match status:
		"asleep":
			c.status_turns = rng.roll_int(1, 3)
		"muddled":
			c.status_turns = rng.roll_int(2, 5)
		_:
			c.status_turns = 0
	return true

static func before_move(c: Creature, rng: Rng) -> Dictionary:
	var r := {"can_act": true, "reason": "", "self_hit": false, "cured_status": ""}
	match c.status:
		"asleep":
			if c.status_turns > 0:
				c.status_turns -= 1
				r.can_act = false
				r.reason = "asleep"
			else:
				r.cured_status = _cure(c)
		"chilled":
			if rng.chance(25):
				r.can_act = false
				r.reason = "chilled"
		"muddled":
			c.status_turns -= 1
			if c.status_turns < 0:
				r.cured_status = _cure(c)
			elif rng.chance(33):
				r.can_act = false
				r.self_hit = true
				r.reason = "muddled"
	return r

static func end_of_turn_damage(c: Creature) -> int:
	match c.status:
		"hexed":
			return maxi(1, c.max_hp() / 16)
		"stung":
			return maxi(1, c.max_hp() / 8)
	return 0

static func speed_mult(c: Creature) -> float:
	return 0.75 if c.status == "soaked" else 1.0

static func incoming_mult(c: Creature, move_type: String) -> float:
	return 1.5 if c.status == "soaked" and move_type == "storm" else 1.0

static func _cure(c: Creature) -> String:
	var old := c.status
	c.status = ""
	c.status_turns = 0
	return old
```

- [ ] **Step 5: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "feat(battle): British weather and status conditions"
git push
```

---

### Task 10: Damage calculation

**Files:**
- Create: `battle/damage_calc.gd`
- Test: `tests/battle/test_damage_calc.gd`

**Interfaces:**
- Consumes: `Creature`, `TypeChart`, `Weather`, `StatusFX`, `Rng`.
- Produces: `DamageCalc.compute(attacker: Creature, defender: Creature, move: Dictionary, chart: TypeChart, weather: String, rng: Rng, crit_chance: float = DamageCalc.CRIT_CHANCE) -> Dictionary` returning `{"damage": int, "effectiveness": float, "crit": bool}`. Constants `CRIT_CHANCE := 100.0 / 24.0`, `STAB := 1.5`, `CRIT_MULT := 1.5`. RNG call order: one `chance()` for the crit, then one `roll_range(0.85, 1.0)`. A move with power 0 or effectiveness 0 returns damage 0 and consumes no rolls.

- [ ] **Step 1: Write the failing tests `tests/battle/test_damage_calc.gd`**

```gdscript
extends TestCase

func _move(id: String) -> Dictionary:
	return Fixtures.moves().get_move(id)

func test_worked_example_super_effective_with_stab() -> void:
	# Kindlet L10 lore 16 vs Spikkin L10 ward 16, Kindle power 40:
	# floor(floor(6 * 40 * 16 / 16) / 50) + 2 = 6; x2 (SE) x1.5 (STAB) x1.0 (max roll) = 18
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("kindle"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 18)
	assert_eq(r.effectiveness, 2.0)
	assert_false(r.crit)

func test_downpour_multiplies_water() -> void:
	# Holtling L10 lore 16 vs Kindlet L10 ward 14, Rill Shot 40: base 7. Clear: 7 x 3 = 21. Downpour: 7 x 4.5 = 31.
	var a := Fixtures.creature("holtling", 10)
	var d := Fixtures.creature("kindlet", 10)
	assert_eq(DamageCalc.compute(a, d, _move("rill_shot"), Fixtures.chart(), "clear", FixedRng.new()).damage, 21)
	assert_eq(DamageCalc.compute(a, d, _move("rill_shot"), Fixtures.chart(), "downpour", FixedRng.new()).damage, 31)

func test_immunity_deals_nothing() -> void:
	var ghost := Creature.create(Fixtures.species("ghost", ["spirit"]), 10, FixedRng.new(), Fixtures.moves())
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), ghost, _move("scrap"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 0)
	assert_eq(r.effectiveness, 0.0)

func test_status_move_deals_nothing() -> void:
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("glare"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 0)

func test_minimum_one_damage() -> void:
	var tank := Creature.create(Fixtures.species("tank", ["stone"], 255), 100, FixedRng.new(), Fixtures.moves())
	var r := DamageCalc.compute(Fixtures.creature("kindlet", 1), tank, _move("scrap"), Fixtures.chart(), "clear", FixedRng.new())
	assert_eq(r.damage, 1)

func test_crit_and_low_roll() -> void:
	var r := FixedRng.new()
	r.f = 0.0  # crit, and the lowest 0.85 roll
	var res := DamageCalc.compute(Fixtures.creature("kindlet", 10), Fixtures.creature("spikkin", 10), _move("kindle"), Fixtures.chart(), "clear", r)
	assert_true(res.crit)
	assert_eq(res.damage, 22)  # 6 x 2 x 1.5 x 1.5 x 0.85 = 22.95

func test_soaked_defender_takes_more_storm() -> void:
	var zap := {"id": "zap", "type": "storm", "category": "special", "power": 40, "accuracy": 100}
	var a := Fixtures.creature("kindlet", 10)
	var d := Fixtures.creature("spikkin", 10)
	var dry := DamageCalc.compute(a, d, zap, Fixtures.chart(), "clear", FixedRng.new()).damage
	d.status = "soaked"
	var wet := DamageCalc.compute(a, d, zap, Fixtures.chart(), "clear", FixedRng.new()).damage
	assert_true(wet > dry)
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh damage` — Expected: FAIL.

- [ ] **Step 3: Create `battle/damage_calc.gd`**

```gdscript
class_name DamageCalc
extends RefCounted
## The damage formula. Pure: same inputs and rolls, same answer.

const CRIT_CHANCE := 100.0 / 24.0
const STAB := 1.5
const CRIT_MULT := 1.5

static func compute(attacker: Creature, defender: Creature, move: Dictionary, chart: TypeChart, weather: String, rng: Rng, crit_chance: float = CRIT_CHANCE) -> Dictionary:
	var move_type: String = move.get("type", "")
	var power: int = move.get("power", 0)
	var eff := chart.effectiveness(move_type, defender.types())
	if eff == 0.0 or power <= 0:
		return {"damage": 0, "effectiveness": eff, "crit": false}
	var physical: bool = move.get("category") == "physical"
	var atk_stat := "atk" if physical else "lore"
	var def_stat := "def" if physical else "ward"
	var a := attacker.battle_stat(atk_stat)
	var d := defender.battle_stat(def_stat)
	var crit := rng.chance(crit_chance)
	if crit:
		# Crits ignore the attacker's drops and the defender's boosts.
		a = maxi(a, attacker.calc_stat(atk_stat))
		d = mini(d, defender.calc_stat(def_stat))
	var level_factor := floori(2.0 * attacker.level / 5.0 + 2.0)
	var base := floori(floori(level_factor * power * a / float(d)) / 50.0) + 2
	var mult := eff * Weather.damage_mod(weather, move_type) * StatusFX.incoming_mult(defender, move_type)
	if move_type in attacker.types():
		mult *= STAB
	if crit:
		mult *= CRIT_MULT
	mult *= rng.roll_range(0.85, 1.0)
	return {"damage": maxi(1, floori(base * mult)), "effectiveness": eff, "crit": crit}
```

- [ ] **Step 4: Run tests** — `tools/test.sh` — Expected: all pass. If a worked-example number differs, recheck the hand calculation in the test comment against `Creature.calc_stat` before touching the formula.

- [ ] **Step 5: Commit and push**

```bash
git add -A
git commit -m "feat(battle): damage formula with STAB, weather, crits, soaked"
git push
```

---

### Task 11: Battle turn engine

**Files:**
- Create: `battle/battle.gd`
- Modify: `tests/support/fixtures.gd` (add `battle()`)
- Test: `tests/battle/test_battle.gd`

**Interfaces:**
- Consumes: `Creature`, `TypeChart`, `MoveDB`, `Rng`, `DamageCalc`, `StatusFX`, `Weather`.
- Produces:
  - `Battle.new(player_party: Array, foe_party: Array, opts: Dictionary)` where opts has `chart` (required), `move_db` (required), and optionally `kind` (`"wild"` default or `"trainer"`), `weather` (`"clear"`), `time` (`"day"`), `rng` (else `Rng.new(opts.seed or 0)`).
  - Fields: `parties`, `active: Array[int]`, `kind`, `weather`, `time`, `chart`, `move_db`, `rng`, `over: bool`, `winner: int` (0 player, 1 foe, -1 nobody), `caught: Creature` (null until Task 12).
  - Methods: `current(side) -> Creature`, `needs_switch(side) -> bool`, `take_turn(player_action: Dictionary, foe_action: Dictionary) -> Array`, `force_switch(side, index) -> Array`.
  - Actions: `{"type": "move", "slot": int}`, `{"type": "switch", "index": int}`, `{"type": "run"}`, `{"type": "catch", "snare": String}` (Task 12).
  - Events (Dictionaries, `type` key): `move {side, user, move}`, `miss {side}`, `no_effect {side}`, `damage {side, amount, hp, effectiveness, crit}` (side = who was hit), `stat {side, stat, delta}`, `status {side, status}`, `status_cured {side, status}`, `cant_act {side, reason}`, `self_hit {side, amount, hp}`, `status_damage {side, status, amount, hp}`, `faint {side, user}`, `switch {side, index, user}`, `run {side, success}`, `end {winner}`.
  - Constants `PLAYER := 0`, `FOE := 1`, `FLAIL` (typeless 40-power fallback), `SELF_HIT` (typeless 40-power confusion hit).
  - `Fixtures.battle(player: Array, foe: Array, opts := {}) -> Battle` with real chart, real moves and a default `FixedRng`.
- Ordering: switches, runs and catches act before moves (player first). Moves go by priority, then speed (`battle_stat("spd") * StatusFX.speed_mult`), then a coin flip. A side whose active creature has fainted skips its action. A side losing all creatures ends the battle; if both lose everything on the same turn, the foe wins.

- [ ] **Step 1: Add `battle()` to `tests/support/fixtures.gd`**

```gdscript
static func battle(player: Array, foe: Array, opts := {}) -> Battle:
	var o := {"chart": chart(), "move_db": moves(), "rng": FixedRng.new()}
	o.merge(opts, true)
	return Battle.new(player, foe, o)
```

- [ ] **Step 2: Write the failing tests `tests/battle/test_battle.gd`**

Slot reference at level 10: Spikkin `[scrap, glare, bramble_lash, hunker]`, Holtling `[scrap, glare, rill_shot, drench]`, Kindlet `[scrap, glare, kindle, quick_nip]`. At 13, Holtling is `[glare, rill_shot, drench, quick_nip]`. At 30, Kindlet is `[quick_nip, smoulder, blaze_dash, barge]`.

```gdscript
extends TestCase

const SCRAP := {"type": "move", "slot": 0}

func _types(events: Array) -> Array:
	return events.map(func(e): return e.type)

func _first(events: Array, type: String) -> Dictionary:
	for e in events:
		if e.type == type:
			return e
	return {}

func test_faster_side_moves_first() -> void:
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [Fixtures.creature("kindlet", 10)])
	var ev := b.take_turn(SCRAP, SCRAP)
	assert_eq(_first(ev, "move").side, 1)

func test_priority_beats_speed() -> void:
	var b := Fixtures.battle([Fixtures.creature("holtling", 13)], [Fixtures.creature("kindlet", 13)])
	var ev := b.take_turn({"type": "move", "slot": 3}, {"type": "move", "slot": 0})
	assert_eq(_first(ev, "move").side, 0)
	assert_eq(_first(ev, "move").move, "quick_nip")

func test_damage_faint_and_wild_win() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 30)], [Fixtures.creature("spikkin", 2)])
	var ev := b.take_turn({"type": "move", "slot": 1}, SCRAP)
	assert_has(_types(ev), "faint")
	assert_eq(_first(ev, "faint").side, 1)
	assert_true(b.over)
	assert_eq(b.winner, 0)
	assert_eq(ev.back(), {"type": "end", "winner": 0})
	assert_false("move" in _types(ev.slice(ev.find(_first(ev, "faint")))))

func test_pp_is_spent() -> void:
	var p := Fixtures.creature("kindlet", 10)
	var b := Fixtures.battle([p], [Fixtures.creature("spikkin", 10)])
	b.take_turn(SCRAP, SCRAP)
	assert_eq(p.moves[0].pp, 34)

func test_status_move_inflicts() -> void:
	var b := Fixtures.battle([Fixtures.creature("holtling", 10)], [Fixtures.creature("kindlet", 10)])
	var ev := b.take_turn({"type": "move", "slot": 3}, {"type": "move", "slot": 1})
	assert_eq(_first(ev, "status"), {"type": "status", "side": 1, "status": "soaked"})
	assert_eq(b.current(1).status, "soaked")

func test_stat_move_lowers_foe() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)])
	b.take_turn({"type": "move", "slot": 1}, {"type": "move", "slot": 3})
	assert_eq(b.current(1).stages.atk, -1)
	assert_eq(b.current(1).stages.def, 1)

func test_switch_goes_first_and_resets_stages() -> void:
	var lead := Fixtures.creature("spikkin", 10)
	var b := Fixtures.battle([lead, Fixtures.creature("holtling", 10)], [Fixtures.creature("kindlet", 10)], {"kind": "trainer"})
	lead.change_stage("atk", 2)  # after construction, which resets stages
	var ev := b.take_turn({"type": "switch", "index": 1}, SCRAP)
	assert_eq(ev[0].type, "switch")
	assert_eq(lead.stages.atk, 0)
	assert_eq(b.current(0).species.id, "holtling")
	assert_eq(_first(ev, "damage").side, 0)

func test_run_from_wild_when_faster() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)])
	var ev := b.take_turn({"type": "run"}, SCRAP)
	assert_eq(_first(ev, "run").success, true)
	assert_true(b.over)
	assert_eq(b.winner, -1)
	assert_false("damage" in _types(ev))

func test_cannot_run_from_trainer() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)], {"kind": "trainer"})
	var ev := b.take_turn({"type": "run"}, SCRAP)
	assert_eq(_first(ev, "run").success, false)
	assert_false(b.over)

func test_trainer_brings_out_next_after_faint() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 30)], [Fixtures.creature("spikkin", 2), Fixtures.creature("holtling", 5)], {"kind": "trainer"})
	b.take_turn({"type": "move", "slot": 1}, SCRAP)
	assert_false(b.over)
	assert_true(b.needs_switch(1))
	var ev := b.force_switch(1, 1)
	assert_eq(ev[0].type, "switch")
	assert_false(b.needs_switch(1))
	assert_eq(b.current(1).species.id, "holtling")

func test_player_wipe_means_foe_wins() -> void:
	var b := Fixtures.battle([Fixtures.creature("spikkin", 2)], [Fixtures.creature("kindlet", 30)], {"kind": "trainer"})
	b.take_turn(SCRAP, {"type": "move", "slot": 1})
	assert_true(b.over)
	assert_eq(b.winner, 1)

func test_end_of_turn_status_damage() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)])
	b.current(1).status = "stung"
	var ev := b.take_turn({"type": "move", "slot": 1}, {"type": "move", "slot": 3})
	assert_eq(_first(ev, "status_damage").amount, b.current(1).max_hp() / 8)

func test_asleep_creature_cannot_act() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)])
	StatusFX.inflict(b.current(1), "asleep", FixedRng.new())
	var ev := b.take_turn({"type": "move", "slot": 1}, SCRAP)
	assert_eq(_first(ev, "cant_act"), {"type": "cant_act", "side": 1, "reason": "asleep"})

func test_side_with_no_able_creature_ends_at_once() -> void:
	var down := Fixtures.creature("kindlet", 10)
	down.hp = 0
	var b := Fixtures.battle([down], [Fixtures.creature("spikkin", 10)])
	assert_true(b.over)
	assert_eq(b.winner, 1)
	assert_eq(b.take_turn(SCRAP, SCRAP), [])

func test_zero_pp_falls_back_to_flail() -> void:
	var p := Fixtures.creature("kindlet", 10)
	p.moves[0].pp = 0
	var b := Fixtures.battle([p], [Fixtures.creature("spikkin", 10)])
	var ev := b.take_turn(SCRAP, {"type": "move", "slot": 1})
	assert_eq(_first(ev, "move").move, "flail")
	assert_eq(_first(ev, "damage").side, 1)

func test_mutual_wipe_counts_as_player_loss() -> void:
	var p := Fixtures.creature("kindlet", 10)
	var f := Fixtures.creature("spikkin", 10)
	p.hp = 1
	f.hp = 1
	p.status = "stung"
	f.status = "stung"
	var b := Fixtures.battle([p], [f])
	b.take_turn({"type": "move", "slot": 1}, {"type": "move", "slot": 1})
	assert_true(b.over)
	assert_eq(b.winner, 1)

func test_fog_can_cause_a_miss() -> void:
	var r := FixedRng.new()
	r.f = 0.9  # 90 is not under 85
	var b := Fixtures.battle([Fixtures.creature("kindlet", 10)], [Fixtures.creature("spikkin", 10)], {"weather": "fog", "rng": r})
	var ev := b.take_turn({"type": "move", "slot": 2}, {"type": "move", "slot": 1})
	assert_has(_types(ev), "miss")

func test_same_seed_same_battle() -> void:
	var run := func(seed_value: int) -> Array:
		var b := Battle.new([Fixtures.creature("kindlet", 12)], [Fixtures.creature("holtling", 12)],
			{"chart": Fixtures.chart(), "move_db": Fixtures.moves(), "rng": Rng.new(seed_value)})
		var all := []
		while not b.over and all.size() < 200:
			all.append_array(b.take_turn({"type": "move", "slot": 2}, {"type": "move", "slot": 2}))
		return all
	assert_eq(run.call(99), run.call(99))
```

- [ ] **Step 3: Run to verify it fails** — `tools/test.sh test_battle` — Expected: FAIL (Battle not defined).

- [ ] **Step 4: Create `battle/battle.gd`**

```gdscript
class_name Battle
extends RefCounted
## One battle, resolved a turn at a time. Pure logic: callers submit actions and render the returned events.
## Event and action shapes are documented in docs/superpowers/plans/2026-10-14-plan-1-foundations-and-battle-core.md (Task 11).

const PLAYER := 0
const FOE := 1
const FLAIL := {"id": "flail", "name": "Flail", "type": "", "category": "physical", "power": 40, "accuracy": 100, "pp": 1, "priority": 0, "effect": {"id": "none"}}
const SELF_HIT := {"id": "self_hit", "name": "Muddled", "type": "", "category": "physical", "power": 40, "accuracy": 100, "pp": 1, "priority": 0, "effect": {"id": "none"}}

var parties := [[], []]
var active := [0, 0]
var kind := "wild"
var weather := "clear"
var time := "day"
var chart: TypeChart
var move_db: MoveDB
var rng: Rng
var over := false
var winner := -1
var caught: Creature = null
var run_attempts := 0

func _init(player_party: Array, foe_party: Array, opts: Dictionary) -> void:
	parties = [player_party, foe_party]
	chart = opts.chart
	move_db = opts.move_db
	kind = opts.get("kind", "wild")
	weather = opts.get("weather", "clear")
	time = opts.get("time", "day")
	rng = opts.get("rng", Rng.new(opts.get("seed", 0)))
	for side in [PLAYER, FOE]:
		for c in parties[side]:
			c.reset_stages()
		active[side] = maxi(0, _first_able(side))
	_check_end([])

func current(side: int) -> Creature:
	return parties[side][active[side]]

func needs_switch(side: int) -> bool:
	return not over and current(side).is_fainted()

func take_turn(player_action: Dictionary, foe_action: Dictionary) -> Array:
	var ev := []
	if over:
		return ev
	var actions := [player_action, foe_action]
	for side in _order(actions):
		if over:
			break
		if current(side).is_fainted():
			continue
		var a: Dictionary = actions[side]
		match a.type:
			"switch":
				_do_switch(side, int(a.index), ev)
			"run":
				_do_run(side, ev)
			"catch":
				_do_catch(str(a.get("snare", "wicker")), ev)
			"move":
				_do_move(side, int(a.slot), ev)
		_check_end(ev)
	if not over:
		_end_of_turn(ev)
	return ev

## Bring in a replacement after a faint, between turns.
func force_switch(side: int, index: int) -> Array:
	var ev := []
	_do_switch(side, index, ev)
	return ev

func _order(actions: Array) -> Array:
	var keys := []
	for side in [PLAYER, FOE]:
		var a: Dictionary = actions[side]
		var prio := 10 if a.type != "move" else _priority(side, int(a.slot))
		keys.append([prio, _speed(side)])
	var first := 0
	if keys[0][0] != keys[1][0]:
		first = PLAYER if keys[0][0] > keys[1][0] else FOE
	elif actions[0].type != "move":
		first = PLAYER
	elif keys[0][1] != keys[1][1]:
		first = PLAYER if keys[0][1] > keys[1][1] else FOE
	else:
		first = rng.roll_int(0, 1)
	return [first, 1 - first]

func _priority(side: int, slot: int) -> int:
	return int(_peek_move(current(side), slot).get("priority", 0))

func _speed(side: int) -> float:
	var c := current(side)
	return c.battle_stat("spd") * StatusFX.speed_mult(c)

func _peek_move(c: Creature, slot: int) -> Dictionary:
	if slot < 0 or slot >= c.moves.size() or int(c.moves[slot].pp) <= 0:
		return FLAIL
	return move_db.get_move(c.moves[slot].id)

func _do_move(side: int, slot: int, ev: Array) -> void:
	var user := current(side)
	var target_side := 1 - side
	var target := current(target_side)
	if target.is_fainted():
		return
	var check := StatusFX.before_move(user, rng)
	if check.cured_status != "":
		ev.append({"type": "status_cured", "side": side, "status": check.cured_status})
	if not check.can_act:
		if check.self_hit:
			var hurt: int = DamageCalc.compute(user, user, SELF_HIT, chart, "clear", rng, 0.0).damage
			user.take_damage(hurt)
			ev.append({"type": "self_hit", "side": side, "amount": hurt, "hp": user.hp})
			if user.is_fainted():
				_faint(side, ev)
		else:
			ev.append({"type": "cant_act", "side": side, "reason": check.reason})
		return
	var move := _peek_move(user, slot)
	if move != FLAIL:
		user.moves[slot].pp -= 1
	ev.append({"type": "move", "side": side, "user": user.display_name(), "move": move.id})
	if not _hits(user, move):
		ev.append({"type": "miss", "side": side})
		return
	if move.category != "status":
		var res := DamageCalc.compute(user, target, move, chart, weather, rng, DamageCalc.CRIT_CHANCE * Weather.crit_mult(weather, side))
		if res.effectiveness == 0.0:
			ev.append({"type": "no_effect", "side": target_side})
			return
		var dealt := target.take_damage(res.damage)
		ev.append({"type": "damage", "side": target_side, "amount": dealt, "hp": target.hp, "effectiveness": res.effectiveness, "crit": res.crit})
		if target.is_fainted():
			_faint(target_side, ev)
	_apply_effect(side, move, ev)

func _hits(user: Creature, move: Dictionary) -> bool:
	var fx: Dictionary = move.get("effect", {})
	if move.category == "status" and fx.get("target") == "self":
		return true
	var acc := float(move.accuracy) * user.stage_mult("acc") * Weather.accuracy_mod(weather)
	return rng.chance(acc)

func _apply_effect(side: int, move: Dictionary, ev: Array) -> void:
	var fx: Dictionary = move.get("effect", {"id": "none"})
	if fx.id == "none":
		return
	var to_side := side if fx.get("target", "foe") == "self" else 1 - side
	var who := current(to_side)
	if who.is_fainted() or not rng.chance(float(fx.get("chance", 100))):
		return
	match fx.id:
		"stat":
			var applied := who.change_stage(fx.stat, int(fx.stages))
			ev.append({"type": "stat", "side": to_side, "stat": fx.stat, "delta": applied})
		"status":
			if StatusFX.inflict(who, fx.status, rng):
				ev.append({"type": "status", "side": to_side, "status": fx.status})

func _do_switch(side: int, index: int, ev: Array) -> void:
	var party: Array = parties[side]
	if index < 0 or index >= party.size() or index == active[side] or party[index].is_fainted():
		return
	current(side).reset_stages()
	active[side] = index
	ev.append({"type": "switch", "side": side, "index": index, "user": current(side).display_name()})

func _do_run(side: int, ev: Array) -> void:
	if kind != "wild" or side != PLAYER:
		ev.append({"type": "run", "side": side, "success": false})
		return
	run_attempts += 1
	var ok := _speed(PLAYER) >= _speed(FOE) or rng.chance(40.0 + 10.0 * run_attempts)
	ev.append({"type": "run", "side": side, "success": ok})
	if ok:
		_finish(-1, ev)

## Replaced in Task 12; until then a catch attempt is ignored.
func _do_catch(_snare: String, _ev: Array) -> void:
	pass

func _faint(side: int, ev: Array) -> void:
	ev.append({"type": "faint", "side": side, "user": current(side).display_name()})

func _end_of_turn(ev: Array) -> void:
	for side in [PLAYER, FOE]:
		var c := current(side)
		if c.is_fainted():
			continue
		var dmg := StatusFX.end_of_turn_damage(c)
		if dmg > 0:
			c.take_damage(dmg)
			ev.append({"type": "status_damage", "side": side, "status": c.status, "amount": dmg, "hp": c.hp})
			if c.is_fainted():
				_faint(side, ev)
	_check_end(ev)

func _check_end(ev: Array) -> void:
	if over:
		return
	if _first_able(PLAYER) < 0:
		_finish(FOE, ev)
	elif _first_able(FOE) < 0:
		_finish(PLAYER, ev)

func _finish(who: int, ev: Array) -> void:
	over = true
	winner = who
	ev.append({"type": "end", "winner": who})

func _first_able(side: int) -> int:
	var party: Array = parties[side]
	for i in party.size():
		if not party[i].is_fainted():
			return i
	return -1
```

Note on `test_damage_faint_and_wild_win`: the foe faints during the player's move, so `_check_end` ends the battle before the foe acts; the assertion that no `move` event follows the faint pins that.

- [ ] **Step 5: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "feat(battle): turn engine with ordering, effects, switching, running, end conditions"
git push
```

---

### Task 12: Catching

**Files:**
- Create: `battle/catching.gd`
- Modify: `battle/battle.gd` (replace `_do_catch`)
- Test: `tests/battle/test_catching.gd`

**Interfaces:**
- Consumes: `Creature`, `Rng`, `Battle`.
- Produces: `Catching.SNARES` (`wicker 1.0, iron 1.5, silver 2.0`; `night`, `water`, `fae` are situational x3, else x1), `Catching.snare_bonus(snare, c, time) -> float`, `Catching.status_bonus(c) -> float` (asleep 2.0, any other status 1.5), `Catching.chance(c, snare, time) -> float` (0..1), `Catching.attempt(c, snare, time, rng) -> bool` (one `roll()`). Battle event `catch {success: bool}` (plus `reason: "trainer"` when refused); on success `battle.caught` is the creature, the battle ends with winner -1. Snare consumption is the bag's job (plan 2).

- [ ] **Step 1: Write the failing tests `tests/battle/test_catching.gd`**

```gdscript
extends TestCase

func test_full_hp_wicker_chance() -> void:
	# (3m - 2m) * 45 * 1 / 3m = 15; 15 / 255
	assert_near(Catching.chance(Fixtures.creature("spikkin", 5), "wicker", "day"), 15.0 / 255.0)

func test_low_hp_and_sleep_help() -> void:
	var c := Fixtures.creature("spikkin", 5)
	var full := Catching.chance(c, "wicker", "day")
	c.hp = 1
	var low := Catching.chance(c, "wicker", "day")
	c.status = "asleep"
	assert_true(low > full * 2.5)
	assert_near(Catching.chance(c, "wicker", "day"), low * 2.0)

func test_situational_snares() -> void:
	var otter := Fixtures.creature("holtling", 5)
	assert_eq(Catching.snare_bonus("water", otter, "day"), 3.0)
	assert_eq(Catching.snare_bonus("water", Fixtures.creature("kindlet", 5), "day"), 1.0)
	assert_eq(Catching.snare_bonus("night", otter, "night"), 3.0)
	assert_eq(Catching.snare_bonus("night", otter, "day"), 1.0)
	assert_eq(Catching.snare_bonus("silver", otter, "day"), 2.0)

func test_chance_is_capped() -> void:
	var easy := Creature.create(Fixtures.species("easy", ["kin"], 50, {"catch_rate": 255}), 5, FixedRng.new(), Fixtures.moves())
	easy.hp = 1
	easy.status = "asleep"
	assert_eq(Catching.chance(easy, "silver", "day"), 1.0)

func test_catch_in_wild_battle() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	var foe := Fixtures.creature("spikkin", 5)
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [foe], {"rng": r})
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": true})
	assert_true(b.over)
	assert_eq(b.winner, -1)
	assert_eq(b.caught, foe)

func test_failed_catch_lets_foe_act() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [Fixtures.creature("spikkin", 5)])
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": false})
	assert_false(b.over)
	assert_eq(ev[1].type, "move")

func test_cannot_catch_trainer_creature() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [Fixtures.creature("spikkin", 5)], {"kind": "trainer", "rng": r})
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": false, "reason": "trainer"})
	assert_eq(b.caught, null)
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh catching` — Expected: FAIL.

- [ ] **Step 3: Create `battle/catching.gd`**

```gdscript
class_name Catching
extends RefCounted
## Snare maths. Weaken it, send it to sleep, use the right snare.

const SNARES := {"wicker": 1.0, "iron": 1.5, "silver": 2.0}

static func snare_bonus(snare: String, c: Creature, time: String) -> float:
	match snare:
		"night":
			return 3.0 if time in ["dusk", "night"] else 1.0
		"water":
			return 3.0 if ("brook" in c.types() or "tide" in c.types()) else 1.0
		"fae":
			return 3.0 if "fae" in c.types() else 1.0
	return float(SNARES.get(snare, 1.0))

static func status_bonus(c: Creature) -> float:
	if c.status == "asleep":
		return 2.0
	return 1.5 if c.status != "" else 1.0

static func chance(c: Creature, snare: String, time: String) -> float:
	var m := float(c.max_hp())
	var a := (3.0 * m - 2.0 * c.hp) * c.species.catch_rate * snare_bonus(snare, c, time) / (3.0 * m) * status_bonus(c)
	return clampf(a / 255.0, 0.0, 1.0)

static func attempt(c: Creature, snare: String, time: String, rng: Rng) -> bool:
	return rng.roll() < chance(c, snare, time)
```

Note: with FixedRng's default `f = 1.0`, `attempt` always fails, and `chance` of exactly 1.0 also fails (1.0 < 1.0 is false). Tests that want a catch set `f = 0.0`.

- [ ] **Step 4: Replace `_do_catch` in `battle/battle.gd`**

```gdscript
func _do_catch(snare: String, ev: Array) -> void:
	if kind != "wild":
		ev.append({"type": "catch", "success": false, "reason": "trainer"})
		return
	var foe := current(FOE)
	var ok := Catching.attempt(foe, snare, time, rng)
	ev.append({"type": "catch", "success": ok})
	if ok:
		caught = foe
		_finish(-1, ev)
```

- [ ] **Step 5: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "feat(battle): snares and catching"
git push
```

---

### Task 13: XP, level-up, evolution, training

**Files:**
- Create: `battle/progression.gd`
- Test: `tests/battle/test_progression.gd`

**Interfaces:**
- Consumes: `Creature`, `Rules`, `MoveDB`.
- Produces: `Progression.xp_reward(foe: Creature, trainer: bool) -> int`, `Progression.gain_xp(c, amount, move_db) -> Array` (events `level_up {level}`, `learned {move}`, `learn_pending {move}`), `Progression.moves_learned_at(sp, level) -> Array`, `Progression.replace_move(c, slot, id, move_db)`, `Progression.evolution_target(c) -> String` (`""` if none), `Progression.evolve(c, new_sp)` (keeps damage taken), `Progression.add_training(c, foe_species)` (+1 in the foe's highest base stat, ties go to the first in `Rules.STATS`, capped per stat and in total).

- [ ] **Step 1: Write the failing tests `tests/battle/test_progression.gd`**

```gdscript
extends TestCase

func test_xp_reward() -> void:
	var foe := Fixtures.creature("spikkin", 7)  # base_xp 62
	assert_eq(Progression.xp_reward(foe, false), 62)
	assert_eq(Progression.xp_reward(foe, true), 93)

func test_level_up_and_learn() -> void:
	var c := Fixtures.creature("kindlet", 4)  # knows scrap, glare
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 5) - c.xp, Fixtures.moves())
	assert_eq(c.level, 5)
	assert_eq(ev, [{"type": "level_up", "level": 5}, {"type": "learned", "move": "kindle"}])
	assert_true(c.has_move("kindle"))

func test_multiple_levels_in_one_go() -> void:
	var c := Fixtures.creature("kindlet", 5)
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 8) - c.xp, Fixtures.moves())
	assert_eq(c.level, 8)
	assert_eq(ev.filter(func(e): return e.type == "level_up").size(), 3)

func test_level_up_keeps_damage_taken() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.take_damage(5)
	var missing := c.max_hp() - c.hp
	Progression.gain_xp(c, Rules.xp_for_level("medium", 11) - c.xp, Fixtures.moves())
	assert_eq(c.max_hp() - c.hp, missing)

func test_full_moveset_makes_learning_pending() -> void:
	var c := Fixtures.creature("kindlet", 12)  # scrap, glare, kindle, quick_nip
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 13) - c.xp, Fixtures.moves())
	assert_has(ev, {"type": "learn_pending", "move": "smoulder"})
	Progression.replace_move(c, 0, "smoulder", Fixtures.moves())
	assert_eq(c.moves[0].id, "smoulder")
	assert_eq(c.moves[0].pp, 15)

func test_level_cap() -> void:
	var c := Fixtures.creature("kindlet", 100)
	assert_eq(Progression.gain_xp(c, 999999, Fixtures.moves()), [])
	assert_eq(c.level, 100)

func test_evolution() -> void:
	var c := Fixtures.creature("kindlet", 15)
	assert_eq(Progression.evolution_target(c), "")
	c.level = 16
	assert_eq(Progression.evolution_target(c), "emberdrey")
	c.take_damage(4)
	Progression.evolve(c, Fixtures.dex().get_species("emberdrey"))
	assert_eq(c.species.id, "emberdrey")
	assert_eq(c.max_hp() - c.hp, 4)

func test_final_stage_never_evolves() -> void:
	assert_eq(Progression.evolution_target(Fixtures.creature("pyredrey", 99)), "")

func test_training_goes_to_foes_best_stat_and_caps() -> void:
	var c := Fixtures.creature("spikkin", 10)
	var foe_sp := Fixtures.dex().get_species("kindlet")  # best base stat: spd 66
	Progression.add_training(c, foe_sp)
	assert_eq(c.training.spd, 1)
	c.training.spd = Rules.TRAINING_STAT_CAP
	Progression.add_training(c, foe_sp)
	assert_eq(c.training.spd, Rules.TRAINING_STAT_CAP)
	c.training = {"hp": 100, "atk": 100, "def": 100, "lore": 0, "ward": 0, "spd": 0}
	Progression.add_training(c, Fixtures.dex().get_species("holtling"))
	assert_eq(c.training.spd, 0)
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh progression` — Expected: FAIL.

- [ ] **Step 3: Create `battle/progression.gd`**

```gdscript
class_name Progression
extends RefCounted
## XP, levelling, move learning, evolution and training.

static func xp_reward(foe: Creature, trainer: bool) -> int:
	var x: int = foe.species.base_xp * foe.level / 7
	return int(x * 1.5) if trainer else x

static func gain_xp(c: Creature, amount: int, move_db: MoveDB) -> Array:
	var ev := []
	if c.level >= Rules.MAX_LEVEL:
		return ev
	c.xp += amount
	while c.level < Rules.MAX_LEVEL and c.xp >= Rules.xp_for_level(c.species.growth, c.level + 1):
		var old_max := c.max_hp()
		c.level += 1
		c.hp += c.max_hp() - old_max
		ev.append({"type": "level_up", "level": c.level})
		for id in moves_learned_at(c.species, c.level):
			if c.has_move(id):
				continue
			if c.moves.size() < Rules.MAX_MOVES:
				c.moves.append(c.make_move_slot(id, move_db))
				ev.append({"type": "learned", "move": id})
			else:
				ev.append({"type": "learn_pending", "move": id})
	return ev

static func moves_learned_at(sp: Dictionary, level: int) -> Array:
	var out := []
	for entry in sp.learnset:
		if entry[0] == level:
			out.append(entry[1])
	return out

static func replace_move(c: Creature, slot: int, id: String, move_db: MoveDB) -> void:
	c.moves[slot] = c.make_move_slot(id, move_db)

static func evolution_target(c: Creature) -> String:
	var evo = c.species.get("evolves")
	if not (evo is Dictionary):
		return ""
	if evo.has("level") and c.level >= int(evo.level):
		return evo.to
	return ""

static func evolve(c: Creature, new_sp: Dictionary) -> void:
	var missing := c.max_hp() - c.hp
	c.species = new_sp
	c.hp = maxi(1, c.max_hp() - missing)

static func add_training(c: Creature, foe_species: Dictionary) -> void:
	var total := 0
	for s in Rules.STATS:
		total += int(c.training[s])
	if total >= Rules.TRAINING_TOTAL_CAP:
		return
	var best: String = Rules.STATS[0]
	for s in Rules.STATS:
		if foe_species.base[s] > foe_species.base[best]:
			best = s
	c.training[best] = mini(int(c.training[best]) + 1, Rules.TRAINING_STAT_CAP)
```

- [ ] **Step 4: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 5: Commit and push**

```bash
git add -A
git commit -m "feat(battle): XP, level-up, move learning, evolution, training"
git push
```

---

### Task 14: Battle AI tiers

**Files:**
- Create: `battle/ai.gd`
- Test: `tests/battle/test_ai.gd`

**Interfaces:**
- Consumes: `Battle` (`current`, `parties`, `active`, `rng`, `chart`, `move_db`), `Creature`.
- Produces: `BattleAI.choose(b: Battle, side: int, tier: String) -> Dictionary` (an action), `BattleAI.score(b, me, foe, move) -> float`. Tiers: `"wild"` random usable move (via `b.rng.pick`), `"trainer"` best score, `"keeper"` also switches when a healthy (over half HP) benched creature's best score is more than double the active one's.
- Score: damaging = power x effectiveness x accuracy/100 x 1.5 if STAB; status move that inflicts a status on a foe with none = 30; any other status move = 20.

- [ ] **Step 1: Write the failing tests `tests/battle/test_ai.gd`**

```gdscript
extends TestCase

func test_wild_picks_a_usable_move() -> void:
	var foe := Fixtures.creature("kindlet", 10)
	foe.moves[0].pp = 0
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [foe])
	assert_eq(BattleAI.choose(b, 1, "wild"), {"type": "move", "slot": 1})

func test_trainer_prefers_super_effective() -> void:
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [Fixtures.creature("kindlet", 10)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "trainer"), {"type": "move", "slot": 2})  # kindle

func test_keeper_switches_out_of_bad_matchup() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 20)],
		[Fixtures.creature("spikkin", 20), Fixtures.creature("holtling", 20)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "keeper"), {"type": "switch", "index": 1})

func test_keeper_stays_when_matchup_is_fine() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 20)],
		[Fixtures.creature("holtling", 20), Fixtures.creature("spikkin", 20)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "keeper").type, "move")

func test_no_pp_left_still_returns_an_action() -> void:
	var foe := Fixtures.creature("kindlet", 10)
	for m in foe.moves:
		m.pp = 0
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [foe])
	assert_eq(BattleAI.choose(b, 1, "trainer"), {"type": "move", "slot": 0})
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh test_ai` — Expected: FAIL.

- [ ] **Step 3: Create `battle/ai.gd`**

```gdscript
class_name BattleAI
extends RefCounted
## Chooses actions. "wild": random usable move. "trainer": best expected damage. "keeper": also switches out of bad match-ups.

static func choose(b: Battle, side: int, tier: String) -> Dictionary:
	var me := b.current(side)
	var foe := b.current(1 - side)
	var usable := _usable(me)
	if usable.is_empty():
		return {"type": "move", "slot": 0}  # Battle falls back to Flail
	if tier == "wild":
		var slot: int = b.rng.pick(usable)
		return {"type": "move", "slot": slot}
	if tier == "keeper":
		var sw := _better_switch(b, side)
		if sw >= 0:
			return {"type": "switch", "index": sw}
	var best: int = usable[0]
	var best_score := -1.0
	for i in usable:
		var s := score(b, me, foe, b.move_db.get_move(me.moves[i].id))
		if s > best_score:
			best_score = s
			best = i
	return {"type": "move", "slot": best}

static func score(b: Battle, me: Creature, foe: Creature, move: Dictionary) -> float:
	if move.category == "status":
		var fx: Dictionary = move.get("effect", {})
		return 30.0 if fx.get("id") == "status" and foe.status == "" else 20.0
	var s := float(move.power) * b.chart.effectiveness(move.type, foe.types()) * float(move.accuracy) / 100.0
	if move.type in me.types():
		s *= 1.5
	return s

static func _usable(c: Creature) -> Array:
	var out := []
	for i in c.moves.size():
		if int(c.moves[i].pp) > 0:
			out.append(i)
	return out

static func _best_score(b: Battle, c: Creature, foe: Creature) -> float:
	var best := 0.0
	for i in _usable(c):
		best = maxf(best, score(b, c, foe, b.move_db.get_move(c.moves[i].id)))
	return best

static func _better_switch(b: Battle, side: int) -> int:
	var foe := b.current(1 - side)
	var mine := _best_score(b, b.current(side), foe)
	var party: Array = b.parties[side]
	for i in party.size():
		var c: Creature = party[i]
		if i == b.active[side] or c.is_fainted() or c.hp * 2 <= c.max_hp():
			continue
		if _best_score(b, c, foe) > mine * 2.0:
			return i
	return -1
```

Check of `test_keeper_switches_out_of_bad_matchup`: Spikkin at 20 knows bramble_lash, hunker, spore_puff, thorn_volley; its best against Kindlet is thorn_volley at 75 x 0.5 x 0.95 x 1.5 = 53.4. Benched Holtling's spate_surge scores 80 x 2 x 1.5 = 240, more than double, so it switches. In `test_keeper_stays_when_matchup_is_fine` Holtling is already active at 240 and nobody on the bench beats 480.

- [ ] **Step 4: Run tests** — `tools/test.sh` — Expected: all pass.

- [ ] **Step 5: Commit and push**

```bash
git add -A
git commit -m "feat(battle): wild, trainer and keeper AI"
git push
```

---

### Task 15: Crash-safe versioned saves

**Files:**
- Create: `core/save_system.gd`
- Test: `tests/core/test_save_system.gd`

**Interfaces:**
- Produces: `SaveSystem.VERSION := 1`, `SaveSystem.save(slot: String, data: Dictionary, dir := "user://saves") -> Error`, `SaveSystem.load_slot(slot: String, dir := "user://saves") -> Dictionary` (`{}` when none; `_recovered: true` when the `.bak` was used; `{"_too_new": true, "version": n}` when written by a newer game), `SaveSystem.migrate(data) -> Dictionary`, `SaveSystem.list_slots(dir) -> Array` (sorted slot names). Slots are `"auto"`, `"slot1"`, `"slot2"`, `"slot3"`.

- [ ] **Step 1: Write the failing tests `tests/core/test_save_system.gd`**

```gdscript
extends TestCase

var dir := "user://test_saves_%d" % Time.get_ticks_usec()

func _wipe() -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(dir)

func _write_raw(name: String, text: String) -> void:
	var f := FileAccess.open(dir.path_join(name), FileAccess.WRITE)
	f.store_string(text)
	f.close()

func test_round_trip() -> void:
	assert_eq(SaveSystem.save("slot1", {"town": "macclesfield", "badges": 0}, dir), OK)
	var back := SaveSystem.load_slot("slot1", dir)
	assert_eq(back.town, "macclesfield")
	assert_eq(int(back.version), SaveSystem.VERSION)
	_wipe()

func test_second_save_keeps_a_backup() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	SaveSystem.save("slot1", {"n": 2}, dir)
	assert_true(FileAccess.file_exists(dir.path_join("slot1.json.bak")))
	assert_eq(int(SaveSystem.load_slot("slot1", dir).n), 2)
	_wipe()

func test_corrupt_save_falls_back_to_backup() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	SaveSystem.save("slot1", {"n": 2}, dir)
	_write_raw("slot1.json", "{not json")
	var back := SaveSystem.load_slot("slot1", dir)
	assert_eq(int(back.n), 1)
	assert_true(back._recovered)
	_wipe()

func test_missing_save_is_empty() -> void:
	assert_eq(SaveSystem.load_slot("slot3", dir), {})

func test_unversioned_save_migrates() -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	_write_raw("auto.json", '{"town": "buxton"}')
	var back := SaveSystem.load_slot("auto", dir)
	assert_eq(int(back.version), 1)
	assert_eq(back.town, "buxton")
	_wipe()

func test_newer_save_is_flagged_not_dropped() -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	_write_raw("auto.json", '{"version": 99}')
	var back := SaveSystem.load_slot("auto", dir)
	assert_true(back.get("_too_new", false))
	_wipe()

func test_list_slots() -> void:
	SaveSystem.save("slot2", {}, dir)
	SaveSystem.save("auto", {}, dir)
	assert_eq(SaveSystem.list_slots(dir), ["auto", "slot2"])
	_wipe()

func test_no_temp_file_left_behind() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	assert_false(FileAccess.file_exists(dir.path_join("slot1.json.tmp")))
	_wipe()
```

- [ ] **Step 2: Run to verify it fails** — `tools/test.sh save_system` — Expected: FAIL.

- [ ] **Step 3: Create `core/save_system.gd`**

```gdscript
class_name SaveSystem
extends RefCounted
## Versioned JSON saves. Writes go to a temp file then get renamed into place; the previous save is kept as .bak.

const VERSION := 1
const DEFAULT_DIR := "user://saves"

static func slot_path(slot: String, dir := DEFAULT_DIR) -> String:
	return dir.path_join(slot + ".json")

static func save(slot: String, data: Dictionary, dir := DEFAULT_DIR) -> Error:
	DirAccess.make_dir_recursive_absolute(dir)
	var path := slot_path(slot, dir)
	var payload := data.duplicate(true)
	payload["version"] = VERSION
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(path + ".bak")
		DirAccess.rename_absolute(path, path + ".bak")
	return DirAccess.rename_absolute(tmp, path)

static func load_slot(slot: String, dir := DEFAULT_DIR) -> Dictionary:
	var path := slot_path(slot, dir)
	var data = _read(path)
	if data == null:
		data = _read(path + ".bak")
		if data == null:
			return {}
		data["_recovered"] = true
	var v := int(data.get("version", 0))
	if v > VERSION:
		return {"_too_new": true, "version": v}
	return migrate(data)

static func migrate(data: Dictionary) -> Dictionary:
	var v := int(data.get("version", 0))
	while v < VERSION:
		match v:
			0:
				data = _v0_to_v1(data)
		v += 1
		data["version"] = v
	return data

static func list_slots(dir := DEFAULT_DIR) -> Array:
	var out := []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out

## Pre-release saves had no version field and nothing else changed.
static func _v0_to_v1(data: Dictionary) -> Dictionary:
	return data

static func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else null
```

- [ ] **Step 4: Run tests** — `tools/test.sh` — Expected: all pass. (A corrupt-JSON test may print an engine `ERROR: ... Parse JSON` line; that is expected and `tools/test.sh` only fails on `SCRIPT ERROR` or `Parse Error`. If Godot prints the literal text `Parse Error` for invalid JSON, change the corrupt fixture to `{"n": ` and confirm; if it still matches, narrow the grep in `tools/test.sh` to `SCRIPT ERROR|Parse Error: ` with a path prefix check `res://`.)

- [ ] **Step 5: Commit and push**

```bash
git add -A
git commit -m "feat(core): atomic, versioned saves with backup recovery"
git push
```

---

### Task 16: Mac and Windows export, v0.0.1 release

**Files:**
- Create: `export_presets.cfg`, `tools/export.sh`, `.github/workflows/release.yml`
- Modify: `main.gd` (data self-check)

**Interfaces:**
- Consumes: `tools/get_godot.sh` (`--version`), `TypeChart`, `Dex`.
- Produces: `tools/export.sh` writes `build/Wildlore-mac.zip` and `build/Wildlore-windows.zip`; pushing a `v*` tag publishes both to a GitHub Release.

- [ ] **Step 1: Add the data self-check to `main.gd`** (replace the file)

```gdscript
extends Control
## Boot screen placeholder until the title screen lands in plan 2.
## Also proves the JSON data made it into this build.

func _ready() -> void:
	var label := Label.new()
	var chart := TypeChart.load_default()
	var dex := Dex.load_default()
	if chart.types.is_empty() or dex.ids().is_empty():
		label.text = "Wildlore: game data missing from this build"
	else:
		label.text = "Wildlore  v%s\n%d types, %d creatures" % [ProjectSettings.get_setting("application/config/version"), chart.types.size(), dex.ids().size()]
	label.add_theme_font_size_override("font_size", 64)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(label)
```

- [ ] **Step 2: Create `export_presets.cfg`**

```
[preset.0]

name="macOS"
platform="macOS"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter="*.json"
exclude_filter="tests/*, tools/*, docs/*"
export_path="build/mac/Wildlore.zip"

[preset.0.options]

application/bundle_identifier="uk.orchardroot.wildlore"
application/short_version="0.0.1"
application/version="0.0.1"
codesign/codesign=1
notarization/notarization=0

[preset.1]

name="Windows"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter="*.json"
exclude_filter="tests/*, tools/*, docs/*"
export_path="build/windows/Wildlore.exe"

[preset.1.options]

binary_format/embed_pck=true
application/product_name="Wildlore"
application/file_version="0.0.1.0"
application/product_version="0.0.1.0"
```

If Godot reports unknown or missing preset options on first export, open the project once in the Godot editor (`$(tools/get_godot.sh) --path . -e`), open Project > Export, let it rewrite `export_presets.cfg` with full defaults, keep the values above, and commit the rewritten file.

- [ ] **Step 3: Create `tools/export.sh`** (then `chmod +x`)

```bash
#!/usr/bin/env bash
# Exports Mac and Windows builds into build/. Downloads export templates (about 1 GB) on first run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="$("$ROOT/tools/get_godot.sh")"
TAG="$("$ROOT/tools/get_godot.sh" --version)"   # e.g. 4.7.2-stable
TPL_NAME="${TAG/-/.}"                            # e.g. 4.7.2.stable
case "$(uname -s)" in
  Darwin) TPL="$HOME/Library/Application Support/Godot/export_templates/$TPL_NAME" ;;
  *)      TPL="$HOME/.local/share/godot/export_templates/$TPL_NAME" ;;
esac
if [ ! -f "$TPL/version.txt" ]; then
  mkdir -p "$TPL"
  TMP="$(mktemp -d)"
  curl -sSL -o "$TMP/t.tpz" "https://github.com/godotengine/godot/releases/download/$TAG/Godot_v${TAG}_export_templates.tpz"
  unzip -q "$TMP/t.tpz" -d "$TMP"
  mv "$TMP"/templates/* "$TPL"/
  rm -rf "$TMP"
fi

cd "$ROOT"
rm -rf build
mkdir -p build/mac build/windows
"$GODOT" --headless --path . --import >/dev/null 2>&1
"$GODOT" --headless --path . --export-release "macOS" build/mac/Wildlore.zip
"$GODOT" --headless --path . --export-release "Windows" build/windows/Wildlore.exe

# The JSON data must be inside the packs, or the game boots empty.
unzip -p build/mac/Wildlore.zip '*.pck' | grep -aq "data/types.json" || { echo "export.sh: data missing from mac pck" >&2; exit 1; }
grep -aq "data/types.json" build/windows/Wildlore.exe || { echo "export.sh: data missing from windows exe" >&2; exit 1; }

cp build/mac/Wildlore.zip build/Wildlore-mac.zip
(cd build/windows && zip -q -r ../Wildlore-windows.zip .)
ls -la build/*.zip
```

- [ ] **Step 4: Export locally and launch the Mac build**

```bash
tools/export.sh
cd build && unzip -q -o Wildlore-mac.zip -d mac-test && open mac-test/Wildlore.app && cd ..
```
Expected: both zips listed; the app opens a window reading `Wildlore v0.0.1` and `16 types, 9 creatures`. (Unsigned: if macOS blocks it, right-click the app > Open.) Take a screenshot with `screencapture -x build/v0.0.1-mac.png` for the user.

- [ ] **Step 5: Create `.github/workflows/release.yml`**

```yaml
name: Release
on:
  push:
    tags: ["v*"]
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/cache@v4
        with:
          path: |
            .godot-bin
            ~/.local/share/godot/export_templates
          key: godot-export-${{ hashFiles('tools/get_godot.sh') }}
      - name: Tests
        run: tools/test.sh
      - name: Export
        run: tools/export.sh
      - name: Publish release
        env:
          GH_TOKEN: ${{ github.token }}
        run: >
          gh release create "$GITHUB_REF_NAME"
          build/Wildlore-mac.zip build/Wildlore-windows.zip
          --title "Wildlore $GITHUB_REF_NAME"
          --notes "Unsigned builds. Mac: right-click Wildlore.app, Open. Windows: More info, Run anyway."
          --prerelease
```

- [ ] **Step 6: Commit, push, open the PR, merge on green, tag**

```bash
git add -A
git commit -m "feat: Mac and Windows export with data check, release workflow"
git push
gh pr create --base main --head plan-1-battle-core --title "Plan 1: foundations and battle core" --body "Implements docs/superpowers/plans/2026-10-14-plan-1-foundations-and-battle-core.md

Closes #<each plan 1 issue number, one per line>"
gh pr checks --watch
gh pr merge --merge --delete-branch
git checkout main && git pull
git tag v0.0.1 && git push origin v0.0.1
gh run watch --exit-status "$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')"
gh release view v0.0.1
```
Expected: the release lists `Wildlore-mac.zip` and `Wildlore-windows.zip`. Fill the `Closes #N` lines from `gh issue list --repo orchardroot/wildlore --milestone "M0 Foundations"` and the M1 battle issues.

---

## After this plan

Write plan 2 (world and the playable slice): zone kit and GridMap tiles, player controller and HD-2D camera rig, Macclesfield, Macclesfield Forest, the route to Buxton and the Buxton Keeper, battle UI rendering these events, items and the bag (snare consumption, tea and tonics, item evolution), party and Creaturepedia screens, encounters with weather and time of day, the sprite generator, and the remaining 11 creatures of the first 20.
