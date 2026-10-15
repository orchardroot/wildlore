# Plan 6: England East, the Moot and London (second half of M4, v0.5.0) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v0.5.0 completes the story. From Aberdeen down the east side along Hadrian's Wall to Newcastle, over the North York Moors to Whitby, then York (Spirit Stone, the tenth); west through the Dales to Lancaster and the Lake District fells to Keswick; south to Sheffield (which joins up with Buxton), Sherwood and Nottingham, Birmingham, then Salisbury Plain to the Moot at Stonehenge (the Four Winds and the Champion), and the London finale at the Enclosure's tower, with the Underground as the last dungeon. All 40 towns, 200 creatures, 10 Stones, all ten legends, and flight as the late-game reward.

**Architecture:** unchanged. Same pipeline and contracts as plans 3 to 5; the plan 3 zone brief still binds. New engine work: flight (fast travel to any visited town across the sea), an "elite gauntlet" for the Moot (no Sanctuary between the five fights, heal only from the bag), and a credits sequence.

**Spec:** `docs/superpowers/specs/2026-10-14-wildlore-design.md` (sections 2, 4, 5 and the M4 milestone). Plans 3 to 5 and their story beats files.

## Global Constraints

- Everything in plans 1 to 5's Global Constraints still applies.
- Branch `plan-6-finale`; agents `p6-<task>`. PR to `main`, tag `v0.5.0`.
- England's north-east, Yorkshire, Cumbria, the Midlands and London written with the same warmth as everywhere else; regional voices light and kind.
- Testing scope (user ruling 2026-10-14): unit tests (watch for SCRIPT ERROR lines), validator, CI slice bot.
- Balance every key fight with `tools/dev/balance_sim.gd`, per starter where a rival counters the starter.

## Review Focus

1. **The Moot gauntlet:** losing any of the five fights returns you to the Moot entrance with progress reset to the first Wind (no half-done state), and you can always leave to heal and shop.
2. **Flight:** only to visited towns, never during a story lock, lands on a walkable tile, works across islands; unlocked only after the Champion.
3. **The finale:** the London tower can't be entered before the Moot is won; the ending plays once, credits roll, and the player returns to the world afterwards (post-game) with a save.
4. **Legends:** Black Shuck, the Lambton Worm, Herne the Hunter and Bran's Raven offered after their chapters, never twice, hidden once caught.
5. **Sheffield joins Buxton:** the new seam must not let a v0.1-era save skip the whole game (gate it).

---

## Task 0: v0.4 deferred minors (controller)

- [ ] A validator rule: every zone (except dev zones) is reachable from Macclesfield through edges, warps, ferries or rail (catches the cave-with-no-entrance class).
- [ ] Isla's and Strachan's lines that assume order are guarded by flags (if the review left any).

## Task 1: Flight and the Moot gauntlet (controller)

- `FieldMoves.FROM_BADGE` unchanged; flight comes from the story flag `champion` (Bran's Raven carries you). `Travel.fly_destinations(data)` returns every visited town (all islands). Pause menu "Map" gets a "Fly" button when `champion` is set; choosing a town warps to its station tile or spawn.
- Moot gauntlet: a script command `{"do": "gauntlet", "trainers": [...], "flag": "moot_won", "exit": {"zone","x","y"}}` runs the fights back to back (the player can use bag items between them, no healing otherwise); a loss whites out to `exit` and nothing is saved as half-won. Tests for both.
- Credits: `{"do": "credits"}` opens a simple scrolling credits screen (team, tools, "made in Cheshire under the supervision of two cats"), then returns to the world.

## Task 2: Creatures (subagents: Haiku data, Sonnet sprites)

Twenty-nine new species (10 two-stage lines, 5 singles, 4 legends), to 200.

| Line | Types | Inspiration | Evolution |
|---|---|---|---|
| Volet > Ratty | brook/kin | water vole | 22 |
| Stagbeet > Stagmajor | hedgerow/iron | stag beetle (London's suburbs) | 30 |
| Parakit > Squawkster | gale/urban | ring-necked parakeet (guest, London) | 26 |
| Moldiwarp > Tunneller | stone/kin | mole | 26 |
| Herdlet > Herdwick | kin/stone | Herdwick sheep, Lake District | 28 |
| Peregrin > Stoopfalcon | gale/urban | peregrine falcon on city cathedrals | 34 |
| Jetling > Jetwhitby | stone/night | Whitby jet (fantasy) | 32 |
| Cutlet > Steelheart | iron/hearth | Sheffield steel (fantasy) | 34 |
| Legionette > Centurion | spirit/brawn | York's Roman legion ghosts | 30 |
| Bittling > Boomern | bog/gale | bittern | 28 |
| Barkdeer | kin/night | muntjac (guest; it barks) | single |
| Glisglis | kin/night | edible dormouse (guest, Chilterns) | single |
| Churrjar | night/gale | nightjar | single |
| Sarsenite | stone/spirit | the sarsen stones of Stonehenge (fantasy) | single |
| Tubemole | urban/stone | the London Underground (fantasy) | single |
| Black Shuck (`shuck`) | night/spirit | the black dog of East Anglia, who came ashore at Whitby in Dracula (legendary) | single, catch rate 3 |
| Lambton Worm (`lambton`) | bog/brawn | the Lambton Worm of County Durham (legendary) | single, catch rate 3 |
| Herne the Hunter (`herne`) | hedgerow/spirit | Herne of Windsor Forest (legendary) | single, catch rate 3 |
| Bran's Raven (`bran`) | gale/night | the ravens of the Tower and Brân the Blessed (legendary) | single, catch rate 3 |

## Task 3: Moves and items (subagent: Haiku)

- About 15 new moves for under-served types plus signatures `hellhound_howl` (night, Shuck), `worm_coil` (bog, Lambton), `wild_hunt` (spirit, Herne), `ravens_watch` (gale, Bran).
- Items: `whitby_jet` (evolution item; make Jetling evolve with it instead of by level if the data supports item evolution: `{"to": "jetwhitby", "item": "whitby_jet"}`), `yorkshire_pudding` (heals 130), `parkin` (heals 110), `pork_pie` (heals 140), `eccles_cake` exists; `moot_token` (key). Shops for every new town.

## Task 4: Zones (subagents: Sonnet, two at a time)

- **A (the north-east):** Ruling: Aberdeen to Northumberland is a long way, so the game compresses it: Aberdeen's south edge leads straight to `northumberland_coast` (Lindisfarne at low tide, Bamburgh castle, puffins), then `hadrians_wall` (landmark: the Wall over the crags, Housesteads fort, Sycamore Gap), then `newcastle` (the Tyne bridges, the Angel of the North as a big statue; Lambton Worm hill nearby `penshaw` small landmark), `north_york_moors` (heather, steam railway), `whitby` (the abbey ruins on the cliff, 199 steps, harbour; Black Shuck's spot on the clifftop), `york` (the Minster, the walls, the Shambles; Keeper arena `york_minster_crypt` (Spirit Keeper) as a dim interior).
- **B (the north-west and the Peak):** `yorkshire_dales` (route west: limestone, waterfalls), `lancaster` (castle, canal), `lake_district` (fells, tarns, Herdwick sheep, scree), `keswick` (town by Derwentwater), `sheffield` (city: steel heritage, the hills; its west edge joins `buxton`'s east border (open a new gap), gated in Buxton by NPCs until `badge_spirit` so early saves can't wander in), `sherwood` (landmark: the Major Oak, Herne's clearing), `nottingham` (castle on the rock, lace market).
- **C (the Midlands, the Moot and London):** `birmingham` (canals, the Bullring, the library), `salisbury_plain` (route: chalk downs, the Westbury White Horse as a white hillside figure of tiles), `stonehenge` (the Moot: the stone circle, the Four Winds stand at the four stones, the Champion in the centre; `moot_hall` if an interior is needed), `london` (city: the Thames, Tower Bridge, the Tower of London with ravens (Bran's spot), the Enclosure's glass tower `vane_tower` (interior, several floors via warps, Lord Vane at the top), an Underground entrance), `underground` (dungeon: `"dark": false`, platforms, trains as props, maze of tunnels, Wardens).

Levels: Northumberland 78-80, Hadrian's Wall 80, Newcastle 81, Moors 81-83, Whitby 83, York 84 (Keeper 86-88), Dales and Lancaster 84-86, Lake District 86-88, Keswick 87, Sheffield 86, Sherwood 87-89, Nottingham 88, Birmingham 89, Salisbury Plain 89-91, the Moot 92-96 (before balancing), London and the Underground 94-97, Vane 98.

## Task 5: Characters and key trainers (subagent: Sonnet sprites; controller trainers and balance)

- Sprites: Keeper Hester (York, Spirit: a ghost-walk guide with a lantern and a top hat), the Four Winds (Aelwen from Wales, gale and storm; Fergus from Scotland, frost and stone; Aoife from Ireland, fae and tide; Wilf from England, kin and brawn), Lord Vane's final form is just Vane in a better coat, ravenmaster, a steelworker, a Lake District fell runner, a Geordie fisherman, a Brummie canal boater.
- The Champion of the Moot is Professor Garside (a twist set up all game: she has always known too much). Her team spans the isles.
- Trainers: Hester; the Four Winds; Garside (Champion); Kit 8 (at the Moot gates, Kit's final battle and friendship moment); Vane final (two forms are not needed; one strong team); the four Enclosure Directors as a "reunion" double battle pair in London (Pryce and Ashcombe together, Kerrigan and Strachan together; they're half-hearted).

## Task 6: Story chapters 10 to 12 (subagent: Sonnet)

- **Chapter 10 (the north-east and York):** Aberdeen's call; Lindisfarne at low tide; Hadrian's Wall; the Lambton Worm stirs at Penshaw (legend after York); Whitby: Black Shuck on the abbey cliff (legend after York); York: Keeper Hester (Spirit Stone, the tenth). Garside's call: "All ten. The Moot will call you."
- **Chapter 11 (the long way round):** the Dales, the Lakes (optional), Sheffield (the Buxton seam opens), Sherwood (Herne the Hunter rides through; legend after the Moot), Nottingham, Birmingham (Kit gets a moot token too), Salisbury Plain.
- **Chapter 12 (the Moot and London):** Kit 8 at the gates; the Four Winds; Garside revealed as the Champion ("Someone had to keep the old places safe until someone better came along"); after winning, Bran's Raven arrives with news: Vane has taken the Wardstones to his tower to bind every legend at once. London: the Underground (the Directors' reunion doubles), the Tower of London (Bran's Raven's spot), Vane's tower, the final battle, the Wardstones break, the legends are free. Ending: Kit, Garside and Mum at Macclesfield; credits; post-game: flight unlocked, legends catchable, Kirkwall and Douglas secrets.
- Beats file `docs/superpowers/plans/2026-10-15-plan-6-story-beats.md`.

## Task 7: Audio (subagent: Sonnet)

`town_york` (cathedral bells and a stately tune), `route_moors` (heather and wind), `town_north` (brass band, Geordie and Yorkshire warmth), `town_london` (busy, bright), `route_lakes`, `dungeon_underground`, `battle_moot` (Four Winds), `battle_champion`, `battle_final` (Vane), `legend_hound2`, `ending` (a long, warm reprise of the title theme), `credits`.

## Task 8: Release v0.5.0 (controller)

Balance, README, Opus whole-branch review and fixes, PR, tag `v0.5.0`. Then M5 (polish, v1.0) is all that remains.

## Execution order

1. Wave A: Task 3 (moves) then Task 2 data; Task 2 sprites; Task 7 audio. Controller: Tasks 0 and 1.
2. Wave B: Task 4 A/B/C, Task 5 sprites. Controller: key trainers and balance.
3. Task 6 story. Task 8.
