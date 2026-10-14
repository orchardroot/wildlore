# Plan 3: England North and Wales (M2, v0.2.0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v0.2.0 carries on from the Buxton slice through Manchester, Liverpool (Urban Stone), Chester, Llangollen, Llanberis (Stone Stone), Snowdon, Aberystwyth, St Davids and Cardiff (Storm Stone), with a ferry side trip to Douglas. About 11 towns, 74 creatures, 4 Stones, the Welsh legend moment (Y Ddraig Goch), the bike, three field abilities, rail fast travel, a world map, three save slots and an Ark viewer.

**Architecture:** No new architecture. Everything plugs into plan 2's contracts: zones are JSON made by `tools/zones/*.py` scripts and built by `ZoneBuilder`; story is command lists run by `ScriptRunner`; creatures are JSON lines plus spritegen recipes; music is note lists in `tools/music/`. New systems are small focused files (bike, field moves, rail, ferry, world map, save slots, Ark) with logic in testable `RefCounted` classes and thin scene glue.

**Tech Stack:** Godot 4.7.2 GDScript, Compatibility renderer, Python 3 zone scripts, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md` (M2 in section 9; towns, travel and field abilities in sections 2 and 4; Keepers in section 5). Plan 2: `docs/superpowers/plans/2026-10-14-plan-2-vertical-slice.md`.

**Plan style note:** as plan 2. Contracts (paths, names, signatures, data formats, flags) are exact; scene layout, art and prose are left to the implementer with screenshot acceptance checks.

## Global Constraints

- Everything in plans 1 and 2's Global Constraints still applies (tabs, int casting from JSON, British spelling, no em-dashes, Co-Authored-By trailer, `tools/test.sh` green, push after every commit, generated art and audio only, every scene task reads its own screenshot, Medium holds 60 fps on the iMac, text for age 11+).
- Branch `plan-3-north-wales`; agents use worktree branches `p3-<task>` under `.claude/worktrees`; the controller merges. PR to `main` at the end, tag `v0.2.0`.
- Before merging any agent branch: `git diff --stat` must not contain `.godot-bin`, `.godot/`, or deletions of files the task did not own.
- No new autoloads. Input map changes only in Task 3 (adds `bike`).
- Save format bumps to VERSION 2 with a `_v1_to_v2` migration; old v1 saves must load.
- Flags naming: `badge_<type>` stays as plan 2 (badges array); story flags `ch2_*`, `ch3_*`, `ch4_*`; stations `station_<town_id>`; trainers `trainer_<id>` (as plan 2).
- Wales: Welsh place names spelled correctly (Yr Wyddfa / Snowdon, Llanberis, Pen y Fan, Tyddewi / St Davids); a little Welsh in dialogue is welcome, always understandable from context.

## Review Focus

1. **Field-ability soft-locks.** A player who reaches a bramble, deep water or scree before owning the ability must always have another way back; no story-critical path may need an ability the player cannot yet own. Pinned by the extended zone validator rule `ability_gates` (Task 2) and the bot's M2 route (Task 12).
2. **Fast travel and ferries into bad states.** Rail or ferry to a zone must land on a walkable tile, never during a story lock (`Router.busy`), never to a station not yet visited. Pinned by `test_rail_destinations_only_visited` and `test_travel_arrival_walkable` (Task 4).
3. **Saves across versions and slots.** v1 saves from v0.1.0 load into v2; three manual slots plus autosave never overwrite each other; a corrupt slot shows as "Damaged" and does not crash the title. Pinned by `test_v1_save_migrates`, `test_slots_independent`, `test_corrupt_slot_listed` (Task 1).
4. **Ark edge cases.** Depositing the last able creature is refused; withdrawing into a full party is refused; catching with a full party goes to the Ark with a message. Pinned by `test_ark_rules` (Task 1).
5. **Biking where you shouldn't.** Bike is refused indoors, in tall grass it still triggers encounters, and getting off happens automatically on warps into interiors. Pinned by `test_bike_rules` (Task 3).

---

## Task 0: Plan 2 deferred minors (controller)

- [ ] Gate dev args (`--playtest`, `--boot`, `--battle`, `--menu`, `--talk`, `--battle-catch`, `--shot`, `--stage`) behind `OS.is_debug_build()` in `core/dev_args.gd` (one guard, returns empty dict in release). Test: `test_dev_args_ignored_in_release` using an injectable `is_debug` param.
- [ ] One whiteout: `Commands.whiteout` delegates to `Overworld.whiteout`; delete the duplicate. Test that trainer loss and wild loss both land at `last_sanctuary` healed with half money.
- [ ] Wild loss: no fade into the overworld and straight back out (whiteout fades once).
- [ ] `last_sanctuary` default is Macclesfield's Sanctuary door tile (read from zone data), not `[0,0]`; a save in a removed zone falls back to `last_sanctuary`, not `testbed`.
- [ ] `Bag.add` respects `MAX_STACK` (returns the number actually added). Test.
- [ ] Quality setting applies live (shadows, tilt-shift, MSAA, render scale). Test that `Settings.quality = "low"` emits and the overworld hides tilt-shift.
- [ ] Ledge hop bob: reset y at the end of the tween (no accumulation). Test position after 5 hops.

## Task 1: Save slots, autosave, Ark (controller)

**Files:** `core/save_system.gd`, `core/game_state_data.gd`, `ui/save_screen.gd/.tscn` (new), `ui/ark_screen.gd/.tscn` (new), `ui/title.gd`, `ui/pause_menu.gd`, tests in `tests/core/`, `tests/ui/`.

**Contract:**
- Slots: `"auto"`, `"1"`, `"2"`, `"3"`. `SaveSystem.list_slots()` returns `[{slot, ok, zone_name, play_seconds, badges, saved_at}]` with `ok=false` for unreadable files.
- Autosave on every zone change and after every Keeper win (`Game.autosave()`); never during battle.
- Pause menu "Save" opens `save_screen` (pick a slot, confirm overwrite). Title: "Continue" loads the newest ok slot; "Load" opens `save_screen` in load mode.
- `VERSION := 2`; `_v1_to_v2` adds `"version": 2`, `"rail": []` (unused, kept for future), fills `last_sanctuary` default.
- Ark: `GameStateData.deposit(i: int) -> String` ("" or a refusal reason), `withdraw(j: int) -> String`. `ark_screen` shows party left, Ark grid right (30 per box, boxes paged), opened from a Sanctuary `Ark terminal` prop (new script command `{"do": "ark"}`).

**Tests:** `test_v1_save_migrates`, `test_slots_independent`, `test_corrupt_slot_listed`, `test_ark_rules`, `test_autosave_on_zone_change`. Screenshot: `docs/screens/p3-save.png`, `docs/screens/p3-ark.png`.

## Task 2: Zone format additions and mesh library (controller)

**Files:** `data_api/zone_data.gd`, `world/zone_builder.gd`, `world/meshes.gd`, `tools/zones/zlib.py`, `tools/zone_check.gd`/validator, tests.

**Contract:**
- New tiles: `"%"` bramble (blocks; cleared by Hedge-lay, flag `cut_<zone>_<x>_<y>`), `"o"` deep_water (blocks; walkable with Brook-wade), `"/"` scree (blocks; walkable with Fell-scramble), `"_"` platform (walkable, station/pier boards), `"r"` rail track (blocks), `"$"` sea (blocks, deep blue, waves). Add to `LEGEND`; `ZoneData.walkable(p, dir, abilities := [])`.
- Optional zone keys: `"stage"` (battle diorama id; replaces the name heuristics in `Overworld._stage`), `"station": {"x","y"}` (rail stop tile), `"ferry": {"x","y","to","tx","ty"}`, `"town_id"` (for world map and rail).
- Validator rule `ability_gates`: BFS from spawn with the abilities the zone declares as `"requires": [..]` (default none) must reach every edge and warp listed in `"must_reach"` (default all edges and warps); bramble/deep/scree tiles are only passable in the BFS when listed.
- Mesh library additions (low-poly, vertex-coloured, same look): `terrace` (red-brick row, chimneys), `mill` (big brick block, many windows, chimney stack), `tudor` (Chester black-and-white), `castle_wall` (crenellated, with towers), `slate_cottage`, `chapel`, `cathedral` (one big nave + tower), `lighthouse`, `liver_building` (two clock towers and birds), `station` (canopy + platform), `boat` (ferry), `aqueduct` segment, `standing_stone`, `slate_heap`, `bramble` tile mesh, deep/sea water using `water.gdshader` with a darker tint, `scree` tile (grey rubble), mountain height levels up to 6 with rock-faced sides.
- Each new building style accepts `label`, door index and window glow at night like plan 2's.

**Tests:** zone parse tests for each new tile; `test_ability_gates_rule` (passes with ability listed, fails when the only exit is behind bramble). Screenshot: `tools/dev/` gallery zone `mesh_gallery` with every new mesh, `docs/screens/p3-meshes.png`, read and tuned.

## Task 3: Bike and field abilities (controller)

**Files:** `world/player.gd`, `world/field_moves.gd` (new, `class_name FieldMoves`), `world/overworld.gd`, `core/input_setup.gd`, `data/items/key.json`, tests.

**Contract:**
- Key item `bike`, given free by the Manchester bike shop after showing the Brook Stone. Action `bike` (keyboard B, pad Y) toggles. `BIKE_SPEED := 9.0`. `Player.on_bike: bool`. Refused indoors ("No cycling indoors. The carpets have suffered enough.") and while surfing. Warping into an interior dismounts.
- `FieldMoves.abilities(data: GameStateData) -> Array`: `hedge_lay` from badge `brook`, `brook_wade` from badge `urban`, `fell_scramble` from badge `stone`. Facing a bramble/deep/scree tile and pressing confirm asks "Use Hedge-lay?" etc. with the lead creature's name; yes cuts (sets flag, rebuilds that tile) or mounts the wade/scramble state.
- Wading: player moves on deep water at walk speed with a coracle under the sprite; stepping onto land ends it. Scree: walkable while ability owned (a "scramble" sfx).
- Wild encounters on deep water use the zone's `"water"` encounter table.

**Tests:** `test_bike_rules`, `test_field_ability_from_badges`, `test_bramble_cut_persists` (flag survives save/load and zone rebuild), `test_wade_needs_ability`. Screenshot: biking and wading.

## Task 4: Rail, ferries, world map (controller)

**Files:** `world/travel.gd` (new, `class_name Travel`), `ui/world_map.gd/.tscn` (new), `ui/travel_menu.gd/.tscn` (new), `data/world_map.json` (new), story command `{"do": "rail"}`, `{"do": "ferry", "route": "liverpool_douglas"}`, tests.

**Contract:**
- `data/world_map.json`: `{"outlines": {"gb": [[x,y],...], "ireland": [...], "man": [...]}, "towns": {"macclesfield": {"name","x","y","nation"}, ...}}` in a 0..1000 x 0..1300 space. Outlines are hand-placed coarse coastlines (at least 60 points for GB, 30 for Ireland) good enough to recognise. All 40 spec towns are listed with `x, y`; only towns whose zone exists are drawn as live.
- Visiting a zone with `"station"` sets `station_<town_id>`. `Travel.rail_destinations(data) -> Array[String]` returns visited station towns except the current one. Arrival: the station tile of the target zone, facing down.
- Ferries: `data/ferries.json` `{"liverpool_douglas": {"from": "liverpool", "to": "douglas", "price": 0, "arrive": [x,y]}}` both directions. A short fade with a sea crossing card ("The Manannan ploughs across the Irish Sea...").
- World map: pause menu item "Map". Shows outlines, town dots (visited bright, unvisited dim, unknown hidden), player marker, nation labels; Creaturepedia habitat view reuses it (highlights towns whose zones list the species).

**Tests:** `test_rail_destinations_only_visited`, `test_travel_arrival_walkable` (every station and ferry arrival is walkable in its zone), `test_world_map_has_all_spec_towns`. Screenshot of the map.

## Task 5: Engine additions for new content (controller)

**Files:** `battle/progression.gd`, `battle/status_fx.gd`, `battle/item_effects.gd`, `battle_ui/diorama.gd`, `world/overworld.gd`, tests.

- Evolution rules: `{"to", "level", "weather"}` (evolves on level up only if the overworld weather matches), `{"to", "level", "time"}` (phase), `{"to", "friendship"}` (friendship 220, gained per level up and walking steps). `Progression.evolution_target(c, ctx := {})` with `ctx = {weather, time}`.
- Battle stages added to the diorama: `city`, `docks`, `coast`, `bog`, `mountain`, `quarry`, `cave`, `castle`, `valley`. Zones choose via `"stage"`.
- Trainer `double: true` is out of scope (M3); doubles are not used in M2.
- Legendary encounter: script command `{"do": "legend", "species": "ddraig", "level": 45, "flag": "caught_ddraig"}` runs a wild battle that cannot be fled, uses `legend` music, sets the flag on catch or on win (a won battle lets it return later: flag not set).

**Tests:** one per evolution rule; diorama builds every stage without errors; `test_legend_command`.

## Task 6: Creatures (subagent: Haiku for data, Sonnet for sprite recipes; worktree `p3-creatures`)

Fifty-three new species bring the roster to 74. Base-stat totals: first stages 290 to 320, middle 400 to 430, final or single-stage oddities 450 to 500, Ddraig 600. Every species: real-world fact (checked, written for 11+), witty dex text, learnset to level 50 using moves from Task 7, habitats listing zone ids from Task 9, recipe in `art/recipes/creatures/` rendered with `tools/spritegen.gd` and every sheet looked at (contact sheet `docs/screens/p3-creatures-<n>.png`).

| Line | Types | Inspiration | Evolution |
|---|---|---|---|
| Cooplet > Strutcoo | urban/gale | feral pigeon | 18 |
| Grizzlet > Raidtail | kin/urban | grey squirrel (guest) | 20 |
| Chipgull > Pierlord | urban/tide | bin-raiding herring gull (guest) | 24 |
| Pepperling > Sootwing | hedgerow/night > night/iron | peppered moth, industrial melanism | 20, time night |
| Bobbin > Shuttlecog | iron | cotton-mill spirit (fantasy) | 22 |
| Starlet > Murmurant | gale/kin | starling murmuration | 20 |
| Minkshade | brook/night | American mink (guest) | single |
| Sphagnet > Peatmonarch | bog/hedgerow | sphagnum moss, Chat Moss | 24 |
| Croakle > Bufomire | bog > bog/brawn | common toad | 22, weather downpour |
| Natterjack | bog/storm | natterjack toad, Formby dunes | single |
| Duneskink | stone/hearth | sand lizard, Merseyside dunes | single |
| Pupplash > Greyhaul | tide | grey seal, Hilbre Island | 26 |
| Puffling > Clownbill | tide/gale | Atlantic puffin, Skomer | 24 |
| Dolphlet > Bayrunner | tide | Cardigan Bay bottlenose dolphin | 28 |
| Pinchkin > Clawcastle | tide/stone | shore crab | 22 |
| Cragchough | gale/stone | red-billed chough, Pembrokeshire | single |
| Kitelet > Forkwing | gale/hearth | red kite, mid-Wales comeback | 26 |
| Kidgruff > Billgruff | stone/brawn | Snowdonia feral goat | 24 |
| Prismite | fae/hedgerow | Snowdon rainbow leaf beetle | single |
| Martling > Pinewraith | hedgerow/night | pine marten | 26 |
| Slatelet > Quarrion | stone > stone/iron | Llanberis slate (fantasy) | 26 |
| Tapknock > Coblynn | spirit/stone | coblynau, Welsh mine knockers | 28 |
| Tylwyth | fae | Tylwyth Teg | single |
| Afanc | brook/brawn | Welsh lake monster (and the beaver, its likely root) | single |
| Gwyllgi | night/spirit | the Dog of Darkness | single |
| Brockling > Brockmoor | kin/brawn > stone/brawn | badger | 24 |
| Flittermouse | night/gale | common pipistrelle | single |
| Zigzlet > Adderking | hedgerow/night | adder | 25 |
| Elverlet > Severnshock | brook/storm > storm/brook | European eel (Sargasso migration) | 26 |
| Swiftlet > Stormswift | storm/gale | common swift (sleeps on the wing) | 24 |
| Petrelash | storm/tide | storm petrel | single |
| Loaghtan | kin/stone | Manx Loaghtan four-horned sheep, Isle of Man | single |
| Y Ddraig Goch (`ddraig`) | hearth/gale | the red dragon of Wales (legendary) | single, catch rate 3 |

That is 53 species: 20 two-stage lines (40), Bufomire, and 12 singles. Append all to `data/dex_order.json` in table order after the 21 existing (Bufomire straight after Croakle's slot is not required; append order is fine).

**Acceptance:** validator green (types, moves exist, learnsets sorted, evolution targets exist), 74 species, every sprite read in a contact sheet and the weakest redone once; also redo plan 2's weakest four (Pyredrey membrane, Rillotter vs Holtling distinctness, Thornsow head, Wispet).

## Task 7: Moves and items (subagent: Haiku; worktree `p3-moves`)

- About 90 new moves to reach ~130, every type to at least 7 (tide, storm, iron get a full set: weak, mid, strong physical and special, two status). Effects use only effect ids the engine already supports (`grep -o '"[a-z_]*"' battle/status_fx.gd battle/damage_calc.gd` and plan 1's effect list); new effect ids need an engine change and are out of scope.
- Items: `cycle_voucher` (key, unused after bike), `bike` (key), `rail_pass` (key, given by Garside's call after Liverpool), `leek` (held, boosts crit, a Welsh joke), `bara_brith` (heals 60, Wales shops), `scouse` (heals 80, Liverpool shop), `eccles_cake` (cures status), `slate_shard` (evolution item, unused in M2 lines; reserve), `iron_snare` priced, `silver_snare` in Cardiff shop. Shops: one per new town under `data/shops/`.
- Validator green.

## Task 8: Characters and trainers (subagent: Sonnet; worktree `p3-cast`; after 6, 7)

- Char recipes in `art/recipes/chars/` (rendered with spritegen): Keeper Ray (Liverpool, Urban, a Merseybeat drummer in a mod suit), Keeper Eluned (Llanberis, Stone, quarry engineer with a hard hat), Keeper Rhys (Cardiff, Storm, rugby kit and a cagoule), Regional Director Gareth Pryce (Enclosure admin for Wales, tweed and a lanyard), Lord Ambrose Vane (cameo, Manchester), Warden variants, sailor, rail guard, bike-shop owner Bev, Dr Anwen Hughes (Garside's colleague at Aberystwyth), hikers, students, anglers, a choir, a harpist.
- Trainers JSON (~40): route trainers levelled to the curve below, 3 Keepers, 2 Kit battles (Liverpool Pier Head, Cardiff Bay; picks counter-starter as plan 2), Pryce twice (Llanberis quarry gates, Cardiff), Wardens.
- **Level curve** (bot-checked in Task 12): Goyt 12-15, Manchester 15, Chat Moss 15-18, Liverpool juniors 18-20, Keeper Ray 20/21/23 (Binfox, Strutcoo, Pierlord), Wirral 20-22, Chester 22, Dee Valley 22-25, Llangollen 25, Ogwen 25-28, Keeper Eluned 28/29/31 (Gritling, Billgruff, Quarrion), Snowdon 28-31, Cambrian Coast 30-32, Pembroke 32-34, Beacons 33-36, Keeper Rhys 35/36/37/38 (Natterjack, Severnshock, Petrelash, Stormswift). Douglas side trip 20-24.

## Task 9: Zones (subagents: Sonnet, two at a time; worktrees `p3-zones-a`, `p3-zones-b`)

One Python script per area group in `tools/zones/` using `zlib.py`. Each exterior dense with props, never a flat field, 40 to 80 tiles across, real landmarks as named props or buildings, a station in each town, signs with dry humour. Encounter tables use Task 6 species by habitat, time and weather. Validator and `ability_gates` green; screenshot every exterior and read it.

- **A (England):** `goyt_valley` (route Buxton north to Manchester: reservoirs, woods; note Buxton gains a north edge), `manchester` (terraces, mills, Town Hall, canal, the bike shop interior `manc_bikes`, Enclosure "Heritage Experience" pop-up with Vane cameo), `chat_moss` (bog route, Stephenson's railway on a raft of heather, bramble patch with a side path), `liverpool` (Pier Head, Liver Building, Albert Dock, Cavern-ish club `liverpool_club` = Keeper Ray's arena, ferry terminal), `wirral_way` (coast route, Hilbre seals at low tide, deep water side area for Brook-wade), `chester` (walls, the Rows in Tudor style, cathedral, river Dee, racecourse), `douglas` (prom, horse trams, Laxey wheel as a prop, Loaghtan field), interiors: Sanctuary and Corner Shop per town (`<town>_sanctuary`, `<town>_shop`, generated by one `interiors.py` template).
- **B (Wales):** `dee_valley` (route: Pontcysyllte aqueduct, canal boats, bramble gate to an optional grove), `llangollen` (chain bridge, Eisteddfod field, harpist), `ogwen` (mountain route: Nant Ffrancon, Tryfan, Llyn Ogwen; scree side path), `llanberis` (slate cottages, Llyn Padarn, Dinorwic quarry arena `llanberis_quarry` for Keeper Eluned, mountain railway station), `yr_wyddfa` (landmark: the summit zone reached by scree after the Stone Stone, the Ddraig legend moment at Dinas Emrys cave `dinas_emrys`), `cambrian_coast` (route: Cardigan Bay, dolphins, deep water cove), `aberystwyth` (prom, cliff railway, Constitution Hill camera obscura, Dr Hughes's lab interior `aber_lab`), `pembroke_coast` (route: Skomer view, puffins, choughs, deep water to a seal cove), `st_davids` (smallest city, cathedral, Enclosure gift shop), `beacons` (route: Pen y Fan, storm-heavy weather table), `cardiff` (castle, Bay, Keeper Rhys's arena `cardiff_arena` under a stormy roof, Kit at the Bay), interiors as group A.
- **Journey wiring:** Buxton north edge to Goyt; Goyt to Manchester; Manchester west to Chat Moss to Liverpool; Liverpool south via Wirral to Chester; Chester west to Dee Valley to Llangollen; Llangollen west via Ogwen to Llanberis; Llanberis south via Cambrian Coast to Aberystwyth; Aberystwyth south via Pembroke Coast to St Davids; St Davids east via Beacons to Cardiff. Rail stations in every town. Gates: Chat Moss needs nothing; Wirral's seal cove needs Brook-wade (optional); Ogwen's scree shortcut needs Fell-scramble (optional); Yr Wyddfa summit needs Fell-scramble (story requires the Stone Stone first, which you have by then); Dee Valley's grove needs Hedge-lay (optional, and you have it from Buxton).

## Task 10: Story chapters 2 to 4 (subagent: Sonnet; worktree `p3-story`; after 8, 9)

Dialogue in `data/dialogue/<zone>.json`; everything validated by the story validator.

- **Chapter 2 (England):** Garside's call sends you north to Manchester (the Arbor Low hum is "spreading north"). Goyt: first wild Pepperlings. Manchester: Bev's bike shop gives the bike for showing the Brook Stone; Vane's "Heritage Experience" (a smug launch speech: the Enclosure will "curate" the old places; Kit is impressed by the free merch); Wardens fencing the canal. Chat Moss: Wardens draining the moss, a battle, Garside explains peat bogs store carbon. Liverpool: Kit streams at Pier Head (battle 3), Keeper Ray in the club (Urban Stone, grants Brook-wade), ferry to Douglas optional (Manx side quest: find three Loaghtan lambs for a farmer, reward: a Silver Snare). Garside sends the rail pass.
- **Chapter 3 (North Wales):** Wirral seals. Chester: Roman walls tour guide, Pryce's first appearance (polite, terrifying in a spreadsheet way) planning to "license" Dinas Emrys. Dee Valley aqueduct. Llangollen: the harpist tells the tale of the two dragons under Dinas Emrys. Ogwen: Wardens on Tryfan. Llanberis: Keeper Eluned (Stone Stone, grants Fell-scramble), Pryce battle at the quarry gates. Yr Wyddfa summit: the stones hum, Pryce attempts the binding, Y Ddraig Goch wakes and scatters the Wardens (scripted, no battle), Kit sees it and wavers ("maybe they're not the good guys"). Dinas Emrys flag `ch3_ddraig_woke`.
- **Chapter 4 (Mid and South Wales):** Aberystwyth: Dr Anwen Hughes explains the Wardstones (the Enclosure's binding devices) and that ten legends answer to ten Stones. Pembroke Coast: puffins and an oil-drum-free cove clean-up side quest. St Davids: Enclosure gift shop selling "Authentic Dragon Scales" (they're crisps), a Warden battle. Beacons: storm walk. Cardiff: Pryce's final battle, Kit battle 4 at the Bay (Kit announces they're quitting the Enclosure sponsorship), Keeper Rhys (Storm Stone). Garside's call: the legend at Dinas Emrys can now be met; end card "End of Wildlore v0.2. Ireland awaits." Post-chapter: `dinas_emrys` lets you face the Ddraig (`legend` command, L45).

## Task 11: Audio (subagent: Sonnet; worktree `p3-audio`)

New tracks in `tools/music/`, same composer: `town_city` (Manchester/Liverpool, bouncy bass, a bit of Merseybeat), `town_wales` (harp arpeggios, hymn-like), `route_coast` (sea-shanty lilt), `route_mountain` (big open fifths, slow), `battle_enclosure` (pompous brass-ish), `legend` (drums and a soaring lead), `ferry` (short sting). SFX: `cut`, `splash`, `scramble`, `bike_bell`, `train`, `ship_horn`. Register in `AudioIds`. Same acceptance as plan 2 (lengths, peaks 0.2 to 0.95, clean loops).

## Task 12: Playtest bot M2 route and balance (controller; after 1 to 10)

- `tools/playtest.sh m2 <seed>` continues the slice route to the Storm Stone: bike after Manchester, rail not required, abilities used at gates, Douglas skipped, Kit/Pryce/Keepers fought, legend not attempted. Same invariants as plan 2.
- Measure cheat heals. Target: slice under 15 and M2 under 30 per seed by tuning trainer levels, wild levels, XP and the AI (not by weakening Keepers below the curve). Record numbers in the ledger.
- CI: push runs `slice 2`; nightly runs `m2` for seeds 101/202/303 plus fuzz.

## Task 13: Polish, README, v0.2.0 (controller)

- [ ] Performance check on the iMac in Manchester, Liverpool and Cardiff (Medium 60 fps; MultiMesh any repeated props that push draw calls).
- [ ] Title backdrop rotates between Macclesfield, Liverpool and Llanberis.
- [ ] README: what's new in v0.2, screenshots, honest status. Wry voice, orchardroot footer.
- [ ] Whole-branch review (Opus), fix Critical/Important with tests, PR, merge, tag `v0.2.0`, check release assets, update Project board and memory.

---

## Execution order and parallelism

1. Controller: Task 0, 1, 2 (contracts for tiles, zone keys, meshes).
2. Wave A (max 3 agents): Task 6 (creatures), Task 7 (moves/items), Task 11 (audio). Controller does Tasks 3, 4, 5 meanwhile.
3. Merge wave A. Wave B: Task 9A and 9B zones (two Sonnet agents), Task 8 (cast).
4. Merge wave B. Task 10 story (one Sonnet agent, it touches every zone). Controller reviews screenshots and fixes looks.
5. Controller: Task 12, then Task 13.
