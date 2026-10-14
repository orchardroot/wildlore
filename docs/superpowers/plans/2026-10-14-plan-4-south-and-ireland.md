# Plan 4: The South and Ireland (M3, v0.3.0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v0.3.0 carries on from Cardiff over the Severn to Bath, Glastonbury (Fae Stone), Dartmoor, Tintagel and Penzance, then by rail and Anglesey to the Holyhead ferry, across to Dublin (Kin Stone), and round Ireland by Kilkenny, Cork, Dingle, the Burren and Galway (Tide Stone) to Sligo and Newgrange, where the Morrígan wakes. 21 towns, 130 creatures, 7 Stones, two more legends (the Green Man, the Morrígan), double battles for set pieces.

**Architecture:** No new architecture. Same pipeline as plan 3: zone scripts in `tools/zones/` (`zlib.py`, the `sanctuary`/`shop` templates), creatures as JSON lines plus spritegen recipes, story as command lists, music as note lists. New engine work is small and test-first: double battles, Water and Night Snare bonuses, island-aware rail. M3 adds no field abilities (Lantern and Bog-cross belong to M4); it reuses Hedge-lay, Brook-wade and Fell-scramble.

**Tech Stack:** Godot 4.7.2 GDScript, Compatibility renderer, Python 3 zone scripts, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md` (M3 in section 9). Plan 3 (`2026-10-14-plan-3-north-and-wales.md`) and its zone brief (`2026-10-14-plan-3-zone-brief.md`) still bind: every rule in that brief applies to plan 4 zones unless this plan says otherwise.

## Global Constraints

- Everything in plans 1 to 3's Global Constraints still applies.
- Branch `plan-4-south-ireland`; agents use worktree branches `p4-<task>`. PR to `main` at the end, tag `v0.3.0`.
- Ruling: 21 towns rather than the spec's "about 25": the Midlands towns (Birmingham, Nottingham, Sheffield) sit off this route and move to M4's run down the east side.
- Ireland: Irish place names and a little Irish (Gaeilge) used respectfully and understandably (Baile Átha Cliath, Gaillimh, Sliabh, craic used sparingly). Cornwall: a little Cornish (Kernewek) on signs. Never stage-Irish or stage-Cornish caricature.
- Balance: every Keeper, rival and admin fight is tuned with `tools/dev/balance_sim.gd` so a sensible team of the right level wins 45% to 75% without items.
- The playtest bot route `m3` (continuing `m2`) must pass on seeds 2 and 3.

## Review Focus

1. **Double battles.** Targeting, fainting with reserves on one side only, catching is refused in doubles, switching, AI choosing two actions, the HUD showing four creatures. Pinned by battle engine tests (Task 2) and a scene screenshot.
2. **The Ireland crossing.** Ferry both ways, rail on each island only reaches that island's stations (no train from Dublin to Cardiff), whiteout in Ireland returns to an Irish Sanctuary. Pinned by `test_rail_stays_on_island`, `test_ferry_holyhead_dublin` (Task 3).
3. **Saves from v0.2.** v2 saves load into v3 (if the format changes) and every new flag defaults sensibly. Pinned by a migration test.
4. **Legend gating.** The Green Man and the Morrígan are only catchable after their chapters, never twice, and losing to them whites out cleanly. Pinned by story tests (Task 8).
5. **Encounter variety.** Every new route offers at least 6 species across times and weathers, and every new species is catchable somewhere in M3 (validator rule, Task 1).

---

## Task 0: v0.2 deferred minors (controller)

- [ ] Whiteout point for a new game is Macclesfield Sanctuary's door tile, not the home spawn.
- [ ] Bike refused on scree tiles (dismount, Fell-scramble on foot).
- [ ] `give_item` at the 99 cap says "Your bag's full of those." instead of "received".
- [ ] World map species view caches `ZoneData.load_all()` encounter index once.

## Task 1: Validator rules for content coverage (controller)

- Every species except legends and evolved-only forms appears in at least one zone encounter table; legends appear in a `legend` command. Test with a zone set missing a species.
- Every route has at least 6 encounter entries.

## Task 2: Double battles (controller, Opus-grade work)

**Files:** `battle/battle.gd` (2v2 mode), `battle/ai.gd`, `battle_ui/*` (four actors, target picker, HUD for two per side), `story/commands.gd` (`{"do": "battle", "trainer": id}` reads `double: true` from the trainer file), tests.

- Trainer JSON `"double": true` and an even party; player sends out the first two able creatures (one if only one is able).
- Moves keep single-target semantics; a move with `"target": "all_foes"` hits both foes at 0.75x. Add `target` to a handful of existing moves (Murmuration, Spring Tide, Thunderclap, Gale Force).
- Catching refused in doubles (only trainers use doubles anyway).
- Used by: the Glastonbury Keeper's juniors, the twins on the Burren, Kit and the Irish admin together once (a 2v2 against Kit's and the admin's lead creatures is not required; keep it to trainer doubles).

## Task 3: Ireland travel (controller)

- Ferries: `holyhead_dublin` (Anglesey port to Dublin port), and the existing Liverpool to Douglas.
- Rail destinations filtered by island: towns carry `"island": "gb" | "ireland" | "man"` in `data/world_map.json`; `Travel.rail_destinations` only lists stations on the same island as the current town.
- World map: the Irish towns and routes light up as visited; ferry routes drawn as dotted lines.

## Task 4: Creatures (subagents: Haiku data, Sonnet sprites)

Fifty-six new species (21 two-stage lines and 14 singles), to 130. Same stat rules as plan 3 (first 290 to 320, middle 400 to 430, singles 450 to 500, legends 600). Same quality bar for facts.

| Line | Types | Inspiration | Evolution |
|---|---|---|---|
| Dozelet > Hazeldoze | hedgerow/kin | hazel dormouse | 18 |
| Cranelet > Levelcrane | brook/gale | common crane, back on the Somerset Levels | 28 |
| Sulisa | brook/fae | Sulis, goddess of the Bath hot springs | single |
| Pixling > Pixiedell | fae/hedgerow | Dartmoor and Cornish piskies | 22 |
| Foalmoor > Tormane | kin/stone | Dartmoor pony | 30 |
| Bodminax | night/brawn | the Beast of Bodmin (folklore big cat) | single |
| Baskling > Baskarr | tide | basking shark | 34 |
| Tinnet > Cassiterix | iron/stone | Cornish tin mining (fantasy) | 30 |
| Thornwyn | hedgerow/fae | the Glastonbury Thorn | single |
| Barnling > Hushwing | night/gale > night/spirit | barn owl | 26 |
| Glowmite > Lanternis | fae/night | glow-worm | 20 |
| Wessexwyrm | hearth/gale | the Wessex wyvern | single |
| Green Man (`greenman`) | hedgerow/fae | the Green Man (legendary) | single, catch rate 3 |
| Leveret > Gealhare | kin/fae | Irish hare | 22 |
| Fawnlet > Stagmor | kin/brawn | Killarney red deer | 32 |
| Megalorn | spirit/stone | the Irish elk, giant deer of the bogs (extinct) | single |
| Parrlet > Bradan | brook/fae | Atlantic salmon, the Salmon of Knowledge | 30 |
| Pooka | night/fae | the púca | single |
| Bansheen | spirit/gale | the bean sí | single |
| Selklet > Selkie | tide/fae | selkies and the grey seal | 30 |
| Merrow | tide/spirit | the merrow | single |
| Cluricaun | fae/urban | the clurichaun, a trickster cousin of the leprechaun | single |
| Crexling > Corncrake | hedgerow/gale | corncrake | 20 |
| Gannetling > Plungebeak | tide/gale | northern gannet | 28 |
| Gentlet > Burrenbloom | hedgerow/stone | spring gentian on the Burren limestone | 24 |
| Connie > Connemarr | kin/tide | Connemara pony | 28 |
| Sikawhistle | kin/gale | sika deer (guest, Wicklow) | single |
| Pincray | brook/iron | signal crayfish (guest) | single |
| Horselet > Horseshoe | night/stone | lesser horseshoe bat | 22 |
| Ternlet > Polartern | frost/gale | Arctic tern | 26 |
| Kerryspot | bog/brook | Kerry slug | single |
| Stalklet > Heronarch | brook/gale | grey heron | 26 |
| Rooklet > Rookery | kin/night | rook | 24 |
| Moolet > Dextera | kin | Dexter cattle, a small Irish breed | 24 |
| The Morrígan (`morrigan`) | night/spirit | the Morrígan (legendary) | single, catch rate 3 |

## Task 5: Moves and items (subagent: Haiku)

- About 30 new moves, weighted to fae, spirit, frost and kin, plus one signature move each for the Green Man (`wild_hunt_bloom`) and the Morrígan (`battle_crow`). Some moves get `"target": "all_foes"` (Task 2).
- Items: `water_snare` and `night_snare` bonuses become real (water: 2.5x on brook/tide; night: 2.5x at dusk/night), `soda_bread` (heals 70), `barmbrack` (heals 120), `pasty` (heals 100), `cream_tea` (full heal, rare), `ferry_ticket` (key, given by Garside for Holyhead), `connemara_marble` (evolution item, reserved). Shops for every new town.

## Task 6: Zones (subagents: Sonnet, two at a time)

Same brief and quality bar as plan 3. Seams fixed in advance (open 3-tile gaps, offset 0):

- **A (the South):** Cardiff east edge rows 20-22 to `severn_crossing` (route: the Severn bridges, mudflats), then `bath` (town: Roman Baths interior `bath_baths`, Royal Crescent, the Abbey), `mendips` (route: Cheddar Gorge, caves, a deep-water underground river), `glastonbury` (town: the Tor with its tower, Chalice Well, the Abbey ruins; Keeper arena `glastonbury_tor` on the Tor), `somerset_levels` (route: rhynes, willows, cranes), `dartmoor` (landmark route: tors, ponies, clapper bridge, Hound Tor), `tintagel` (landmark: castle on the headland, Merlin's cave), `penzance` (town: harbour, St Michael's Mount across a causeway, the tin mine `geevor` dungeon).
- **B (Anglesey and Ireland east):** `anglesey` (route from Llanberis north-west across the Menai Bridge to `holyhead`, a small port town with the ferry quay); `dublin` (city: the Liffey, Ha'penny Bridge, Trinity, the port with the ferry quay; Keeper arena `dublin_hall` for Kin), `wicklow` (route: mountains, Glendalough, sika deer), `kilkenny` (town: castle, medieval mile), `comeraghs` (route), `cork` (city: the English Market, Shandon bells).
- **C (Ireland west):** `ring_of_kerry` (route: Killarney, red deer, lakes), `dingle` (town: harbour, the famous dolphin as a statue), `burren` (landmark route: limestone pavement, the Cliffs of Moher edge, wild flowers), `galway` (city: Spanish Arch, the Claddagh; Keeper arena `galway_docks` for Tide), `connemara` (route: bogs, ponies, Kylemore), `sligo` (town: Benbulben behind it), `boyne_valley` (route east to the passage tomb), `newgrange` (landmark town: the passage tomb exterior and interior `newgrange_tomb`, where the Morrígan wakes at the winter solstice light).

Wiring: Cardiff to Severn Crossing to Bath to Mendips to Glastonbury to Somerset Levels to Dartmoor to Tintagel to Penzance. Llanberis north edge (new gap columns 10-12) to Anglesey to Holyhead; Holyhead ferry to Dublin. Dublin to Wicklow to Kilkenny to Comeraghs to Cork to Ring of Kerry to Dingle; Dingle to Burren to Galway to Connemara to Sligo to Boyne Valley to Newgrange (and Boyne Valley east to Dublin, closing the loop).

## Task 7: Characters and key trainers (subagent: Sonnet)

- Sprites: Keeper Morwen (Glastonbury, Fae: festival-goer witch with a lantern), Keeper Declan (Dublin, Kin: hurling kit, warm and loud), Keeper Nuala (Galway, Tide: a currach rower in an Aran jumper), the Irish admin Director Siobhán Kerrigan (smart coat, umbrella), the English admin Sir Rupert Ashcombe (Panama hat, blazer, Enclosure lapel pin), a sean-nós singer, a tin miner, a surfer (exists), a druid re-enactor, a hurler, a fiddler, Garside in person (exists).
- Trainers: Keepers at 41/42/44 (Morwen), 47/48/50 (Declan), 52/53/54/56 (Nuala) before balancing; Kit battles 5 (Glastonbury, Kit now on your side of things but still competitive) and 6 (Galway); Ashcombe twice (Tintagel, Penzance mine); Kerrigan twice (Kilkenny, Newgrange). Then balance with the simulator.

## Task 8: Story chapters 5 to 7 (subagent: Sonnet)

- **Chapter 5 (the South):** Garside's call after Cardiff: the stones at Avebury and Stonehenge are humming too, but first Glastonbury. Bath: Sulis's spring is being bottled by the Enclosure as "Heritage Water". Glastonbury: Keeper Morwen; the Green Man wakes in the Tor's orchard when the Enclosure tries to fence it, Kit helps you this time. Dartmoor: Ashcombe's men hunting the Hound Tor legend for a brochure. Tintagel: Ashcombe battle 1. Penzance: the tin mine, Ashcombe battle 2, Garside sends a ferry ticket from Holyhead.
- **Chapter 6 (Ireland east):** Holyhead ferry. Dublin: Keeper Declan; the Irish admin Kerrigan announces "Ireland's Ancient East Experience". Kilkenny: Kerrigan battle 1. Cork and Kerry: side quests (the English Market, Killarney deer count).
- **Chapter 7 (Ireland west):** Dingle, the Burren (double battle twins), Galway: Kit battle 6, Keeper Nuala. Sligo: Yeats-ish poet NPC, Benbulben. Newgrange: Kerrigan battle 2 in the tomb, the solstice light, the Morrígan wakes and judges the Enclosure (scripted), then becomes catchable. End card: "End of Wildlore v0.3. The North is waiting."
- Green Man: catchable at `glastonbury_tor` orchard after the Fae Stone (L55). Morrígan: catchable at `newgrange_tomb` after chapter 7 (L60).
- Beats file `docs/superpowers/plans/2026-10-14-plan-4-story-beats.md` in the same format as plan 3's.

## Task 9: Audio (subagent: Sonnet)

Tracks: `town_ireland` (session reel: fiddle, whistle, bodhrán), `route_ireland` (slow air), `town_cornwall` (a Cornish fishing-song feel), `route_moor_south` (Dartmoor, misty), `battle_double` (faster trainer theme), `legend_green` (Green Man, earthy drums and pipes), `legend_crow` (Morrígan, dark and soaring), `ferry_irish_sea` (sting). SFX: `crow`, `tomb_light`, `harp_gliss`.

## Task 10: Bot route m3, balance, polish, v0.3.0 (controller)

- `tools/playtest.sh m3 <seed>`: continues from m2 to the Tide Stone and the Newgrange scene; seeds 2 and 3 pass.
- Balance every key fight with the simulator.
- README, screenshots, whole-branch review (Opus), fixes, PR, tag `v0.3.0`.

---

## Execution order and parallelism

1. Wave A, now (while v0.2 ships): Task 4 (creature data, Haiku; sprites, Sonnet), Task 5 (moves/items, Haiku), Task 9 (audio, Sonnet).
2. After v0.2.0 is merged to main and main is merged into this branch: controller does Tasks 0 to 3.
3. Wave B: Task 6 A/B/C zones (two at a time), Task 7 cast.
4. Wave C: Task 8 story. Then Task 10.
