# Wildlore: These Isles 3.8 "The Long Game", wave 38

The post-game and the land. The design is docs/design/2026-10-21-deeper-wildlore.md: section 2e ("Sinks worth being
rich for": the Enclosure's leases), section 3 (Guilds: the Ramblers versus the Heritage Trust choice already exists
from 3.7), section 4 (minigames table) and section 6 (the release called "3.7 The Long Game" there; it is 3.8 now).
Read those, plus docs/briefs/wave34.md (house rules, Screenshots and Finish sections apply unchanged) and
docs/briefs/qol_common.md. Everything from 3.4 to 3.7 is merged (Trade, Trades, Deeds, Regulars, breeding, examine
spots, Deep Places, Casebook, Guilds, creature jobs): read headers before touching anything nearby.
Base: `origin/polish-3.8`. Branch: claude/w38-<letter>-<name>.

## The lease contract (session A owns core/leases.gd and the auction; B and C author lease zones to it)
- `data/leases/<lease_id>.json` = `{"id", "name", "nation", "kind": "grouse_moor" | "forestry" | "estate" | "foreshore" |
  "quarry" | ..., "anchor": "<existing outdoor zone>", "side": "north" | "south" | "east" | "west" (an edge that zone has
  free today), "zone": "<new zone id>", "reserve": 40000 (sterling; euros by Wallet in Ireland), "upkeep": 300 (weekly),
  "unlock_flag": "game_complete", "trust_wants": true (the Heritage Trust bids against you), "blurb"}`.
- A lease is won at auction (the Exchange: core/markets.gd has the stock exchange towns) against rival bidders whose
  behaviour depends on your guild side; owning it opens the edge from the anchor into the lease zone (closed and
  sign-posted "Private land, Enclosure Ltd" until then), and the land changes over in-game seasons as you rewild it
  (world/rewild.gd stages, drystone walls from 3.7). State in flags `lease_<id>`; absent = not owned.
- Never a shortcut between two existing zones: a lease zone is a cul-de-sac off its anchor.

## Sessions
- **A. Leases core + auction + two reference leases**: core/leases.gd, the auction screen (bids, rivals, reserve, the
  Trust), upkeep through the post, the edge-opening, and two reference lease zones (a Pennine grouse moor off a Peak or
  Yorkshire route, and a Welsh conifer plantation) with rewilding stages, creatures that return as it heals, and plaques
  on real land-use history (the Kinder trespass 1932, accurate).
- **B. Lease zones, England and Wales** (four): e.g. a Norfolk estate, a Dartmoor clay works, a Lake District forestry
  block, a Welsh hill farm; data and zones to the contract, with rewilding stages and accurate plaques. STUB rule for
  core/leases.gd (commit alone as "STUB leases.gd").
- **C. Lease zones, Scotland, Ireland and Northern Ireland** (four): e.g. a Highland deer forest, a Flow Country peat bog
  (the real restoration story), an Irish cutaway bog, an Antrim glen; same rules.
- **D. Pub quiz league and the crossword**: turn the existing pub quiz (core/pub_quiz.gd) into a league with a table per
  nation and a final; and a daily crossword in the newspaper (a small cryptic-lite grid with UK and Irish clues drawn from
  the Gazetteer plaques), with small prizes.
- **E. Highland games, hurling and shinty**: caber (hold-and-release timing) and tug of war (your creature's attack with a
  rhythm tap) at Braemar or Oban if present; hurling (Ireland) and shinty (Scotland) as short, fair minigames; accurate
  plaques on each sport.
- **F. Sea shanties and conkers**: a rhythm minigame singing shanties in harbour pubs (real traditional shanties, public
  domain lyrics only, short excerpts), and conkers in autumn (a horse chestnut you season and play; real history of the
  World Conker Championships).
- **G. NPC routines**: townsfolk follow a simple weekly schedule from core/calendar.gd and the clock (the market on
  market day, the pub in the evening, church on Sunday morning, the beach in summer), done cheaply (data per NPC, no
  pathfinding cost per frame), never blocking doors or the story, opt-in per NPC so existing ones stay put.

Shared hot files: small additive insertions only.
