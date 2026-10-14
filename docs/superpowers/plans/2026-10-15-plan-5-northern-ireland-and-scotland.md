# Plan 5: Northern Ireland and Scotland (first half of M4, v0.4.0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v0.4.0 carries on from Newgrange north over the Mournes to Belfast (Iron Stone), the Giant's Causeway, Bushmills and Derry, then the ferry to Cairnryan and up through Glasgow and Edinburgh into the Highlands: Glencoe, Fort William, the Great Glen and Loch Ness, Inverness (Frost Stone), Skye and Portree, the Cairngorms and Aberdeen, with Kirkwall on Orkney as a ferry trip. 31 towns, about 171 creatures, 9 Stones, three more legends (Manannán's Horse, the Cù-Sìth, Nessie), two new field abilities (Lantern, Bog-cross).

**Ruling (scope):** the spec's M4 is "all 40 towns, 200 creatures, 10 badges, the Moot, London". That is too big to build, review and ship safely as one step, so M4 is split: plan 5 (this, v0.4.0) does Northern Ireland and Scotland; plan 6 (v0.5.0) does the east side of England (Newcastle, Whitby, York and the Spirit Stone, the Lake District, Lancaster, Sheffield, Nottingham and Sherwood, Birmingham), the Moot at Stonehenge and the London finale. M5 polish remains v1.0.

**Architecture:** unchanged. Same pipeline and contracts as plans 3 and 4; the plan 3 zone brief still binds.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md`. Plans 3 and 4 and their story beats files.

## Global Constraints

- Everything in plans 1 to 4's Global Constraints still applies.
- Branch `plan-5-north`; agents `p5-<task>`. PR to `main`, tag `v0.4.0`.
- Scotland: Scots and Gaelic used respectfully and understandably (a "wee" here and there, Gaelic place names on signs: Inbhir Nis, Dùn Èideann); Northern Ireland: written with care for both communities, no politics, no flags beyond civic ones; never caricature (no tartan-and-haggis jokes as the whole joke).
- Testing scope (user ruling 2026-10-14): unit tests, validator, CI slice bot; no full route bot run during the build.
- Balance with `tools/dev/balance_sim.gd`: every Keeper, rival and Director fight 45% to 75% for a sensible team.

## Review Focus

1. **Lantern and dark zones:** dark caves without the Lantern must still be walkable to the exit (no soft-lock), and the light radius must not hide warps or NPCs you need.
2. **Bog-cross gates:** same reachability rules as the other abilities (validator `ability_gates`).
3. **Ferries:** Belfast to Cairnryan both ways, Aberdeen to Kirkwall both ways; rail stays on its island (Northern Ireland is on the "ireland" island; Scotland on "gb").
4. **Legends:** offered after their chapter, never twice, hidden once caught.
5. **v0.3 saves:** load, and the player is pointed north from Newgrange.

---

## Task 0: v0.3 deferred minors (controller)

- [ ] Spread-move effectiveness lines name the target ("It's super effective on Spikkin!") in doubles.
- [ ] A v2 save fixture test (a hand-written v0.3-era save loads and plays from Newgrange).

## Task 1: Lantern and Bog-cross (controller)

- New tile `"*"` = `bog` (deep peat: impassable without Bog-cross; walkable with it; encounters use the `"grass"` table). `ZoneData.ABILITY_TILES["bog"] = "bog_cross"`; validator gates accept `bog_cross`.
- `FieldMoves.FROM_BADGE`: `iron` gives `lantern`, `frost` gives `bog_cross`.
- Zone key `"dark": true`: the overworld draws a darkness overlay with a small light circle around the player (radius 2 tiles) unless the player has `lantern` (radius 6, warm). NPCs and warps inside the circle are visible; the exit warp of every dark zone gets a faint glow so the way out is always findable. Test the shader-free logic (`FieldMoves.light_radius(data)`), screenshot both states.

## Task 2: Northern and Scottish travel (controller)

- Ferries: `belfast_cairnryan` (Belfast port to Cairnryan, a small port zone), `aberdeen_kirkwall`.
- Rail islands: Belfast, Bushmills and Derry are `"island": "ireland"`; Cairnryan, Glasgow and the rest `"gb"`; Kirkwall `"orkney"` (no trains).

## Task 3: Creatures (subagents: Haiku data, Sonnet sprites)

Forty-one new species (16 two-stage lines and 9 singles), to about 171. Same stat and fact rules.

| Line | Types | Inspiration | Evolution |
|---|---|---|---|
| Basaltling > Causewarden | stone/tide | the Giant's Causeway basalt columns (fantasy) | 28 |
| Rivetling > Samsonian | iron/brawn | Belfast shipyard, Samson and Goliath cranes (fantasy) | 32 |
| Flaxling > Linenwisp | hedgerow/fae | flax and Ulster linen (fantasy) | 22 |
| Fionnling > Finnmacool | brawn/stone | Fionn mac Cumhaill and the Causeway legend | 34 |
| Pollanet | brook | the pollan, a fish found in Ireland in Lough Neagh and a few other loughs | single |
| Manannán's Horse (`enbarr`) | tide/fae | Enbarr, the sea god's horse (legendary) | single, catch rate 3 |
| Stoatlet > Ermine | kin/frost | stoat, white in a Highland winter | 24 |
| Wildkit > Highlynx | night/brawn | Scottish wildcat | 30 |
| Caperling > Capercaillie | hedgerow/gale | capercaillie | 30 |
| Ptarmlet > Ptarmigan | frost/gale | ptarmigan | 26 |
| Coolet > Heilan | kin/frost | Highland cattle | 32 |
| Eaglet > Goldeneyrie | gale/stone | golden eagle | 36 |
| Ospret > Lochosprey | gale/brook | osprey (Loch Garten) | 28 |
| Midgie > Midgeswarm | bog/gale | the Highland midge | 18 |
| Orcalet > Orcaird | tide/frost | orcas off the west coast | 36 |
| Buntling > Snowbunting | frost/kin | snow bunting | 22 |
| Calfrein > Reindeer | frost/brawn | the Cairngorm reindeer herd | 30 |
| Thistlet > Thistlord | hedgerow/brawn | the thistle | 26 |
| Kelpie | brook/spirit | the kelpie water horse | single |
| Brownie | fae/kin | the brownie, a helpful house spirit | single |
| Minchman | tide/storm | the Blue Men of the Minch | single |
| Haarling | frost/tide | the haar, the east coast sea fog | single |
| Railspark | iron/storm | the Forth Bridge (fantasy) | single |
| Cù-Sìth (`cusith`) | fae/night | the great green fairy dog of the Highlands (legendary) | single, catch rate 3 |
| Nessie (`nessie`) | brook/spirit | the Loch Ness Monster (legendary) | single, catch rate 3 |

## Task 4: Moves and items (subagent: Haiku)

- About 20 new moves, weighted to frost, iron, storm and bog, plus signatures `wave_sweeper` (tide special 110, Enbarr's), `fairy_hound_howl` (fae special 110, the Cù-Sìth's), `loch_deep` (brook special 110, Nessie's).
- Items: `lantern` (key, from the Iron Stone story beat), `waders` (key, flavour for Bog-cross), `tablet` (heals 90, Scottish sweet), `cranachan` (heals 150), `soda_farl` (heals 75), `ulster_fry` (full heal, rare), `irn_tonic` (cures status; do not use a real brand name). Shops for every new town.

## Task 5: Zones (subagents: Sonnet, two at a time)

- **A (Northern Ireland):** `mournes` (route north from Boyne Valley: the Mourne Wall, granite, a bog patch gated `bog_cross` for a side area), `belfast` (city: City Hall, the Titanic Quarter, the Samson and Goliath cranes as tall yellow `liver_building`-style or custom blocks, the Lagan, the ferry quay; Keeper arena `belfast_yard` (shipyard, Iron Keeper)), `antrim_coast` (route: glens, cliffs, Carrick-a-Rede rope bridge), `causeway` (landmark: hexagonal basalt columns as stepped stone heights over `$` sea; Manannán's Horse legend spot on a sea stack), `bushmills` (small town), `derry` (city: the walls, the Peace Bridge; a station). Seam: Boyne Valley north edge (open new columns, agent edits JSON) to `mournes`.
- **B (Scotland west):** `cairnryan` (port town), `galloway` (route: forest park, dark sky park as a `"dark": true` night side area), `glasgow` (city: the Clyde, the Finnieston Crane, Kelvingrove; station), `central_belt` (route east), `edinburgh` (city: the Castle on its rock, the Royal Mile, Arthur's Seat; station), `glencoe` (landmark route: the Three Sisters, big heights, scree), `fort_william` (town, Ben Nevis behind; station), `great_glen` (route along the loch).
- **C (Scotland north):** `loch_ness` (landmark: the loch, Urquhart Castle ruins, Nessie's spot), `inverness` (town: the river Ness, the castle; Keeper arena `inverness_rink` (an ice rink, Frost Keeper); station), `skye` (route over the Skye bridge: the Old Man of Storr, Fairy Pools; Cù-Sìth legend glen), `portree` (harbour town), `cairngorms` (landmark: reindeer, snow, bog gated `bog_cross`, a dark cave `"dark": true` needing the Lantern for the inner chamber), `aberdeen` (granite city, harbour, ferry to Kirkwall; station), `kirkwall` (Orkney: St Magnus Cathedral; post-game flavour now: the Ring of Brodgar nearby as standing stones).

Levels: Mournes 61-63, Belfast 63 (Keeper 66-68 before balancing), Antrim 64-66, Causeway 66, Derry 67, Galloway 67-69, Glasgow and Edinburgh 69-70, Glencoe 70-72, Fort William 72, Great Glen and Loch Ness 72-74, Inverness 74 (Keeper 76-78), Skye 74-76, Cairngorms 76-78, Aberdeen 78, Kirkwall 80.

## Task 6: Characters and key trainers (subagent: Sonnet for sprites; controller for trainers and balance)

- Sprites: Keeper Ruairí (Belfast, Iron: shipyard welder with a visor), Keeper Isla (Inverness, Frost: curling stone and broom, a woolly hat), the Scottish admin Director Morag Strachan (waxed jacket, clipboard, wellies), Lord Ambrose Vane in person again (exists), a piper (respectful), a ceilidh caller, a shinty player, a ghillie, a ferry crew (exists).
- Trainers: Ruairí, Isla, Kit 7 (Edinburgh), Strachan twice (Glencoe, Loch Ness), Vane once (a cameo battle at the Causeway he expects to lose and complains about), double-battle pairs (the Glasgow ceilidh couple).

## Task 7: Story chapters 8 and 9 (subagent: Sonnet)

- **Chapter 8 (Northern Ireland):** Garside's call after Newgrange: the Morrígan has been seen flying north. Belfast: Keeper Ruairí (Iron Stone, gives the Lantern); Vane in person at the Causeway, trying to "lease" the columns; Manannán's Horse rises from the sea and the waves wash out his marquee. Derry: the walls, a gentle side quest.
- **Chapter 9 (Scotland):** ferry to Cairnryan. Glasgow and Edinburgh (Kit 7 on the Castle esplanade). Glencoe: Strachan battle 1 in the mist. Loch Ness: Strachan battle 2 on a survey boat, Nessie surfaces (scripted). Inverness: Keeper Isla (Frost Stone, Bog-cross). Skye: the Cù-Sìth's glen (legend after the Frost Stone). Cairngorms: the reindeer herd, the Lantern cave. Aberdeen: Garside's call: "York. The Spirit Stone. And then the Moot." End card: "End of Wildlore v0.4. The Moot is gathering."
- Legends: Enbarr catchable after chapter 8 (L66); Nessie after the Frost Stone (L74); Cù-Sìth after the Frost Stone (L76).
- Beats file `docs/superpowers/plans/2026-10-15-plan-5-story-beats.md`.

## Task 8: Audio (subagent: Sonnet)

`town_scotland` (a strathspey: fiddle and a pipe-like drone, respectful), `route_highlands` (wide, slow, mountain air), `town_belfast` (bright, maritime), `route_north_coast` (wind and waves), `legend_sea` (Enbarr and Nessie), `legend_hound` (the Cù-Sìth), `ferry_north_channel` (sting). SFX: `lantern_on`, `bog_squelch`, `bagpipe_drone` (short, for a piper NPC).

## Task 9: Release v0.4.0 (controller)

Balance, README, Opus whole-branch review and fixes, PR, tag `v0.4.0`.

## Execution order

1. Wave A: Task 3 data (after Task 4 moves) and sprites, Task 4, Task 8. Controller: Tasks 0, 1, 2.
2. Wave B: Task 5 A/B/C (two at a time), Task 6 sprites.
3. Task 7 story. Task 9.
