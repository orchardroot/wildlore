# Wildlore: These Isles 3.9 "Long Roads", wave 39

The long arcs, one per nation, woven through everything built since 3.4, plus a polish pass. Read
docs/design/2026-10-21-deeper-wildlore.md section 3 ("Long arcs") and section 1 (identity), docs/briefs/wave34.md (house
rules, Screenshots and Finish sections apply unchanged), docs/briefs/wave21.md (how a region quest is authored) and
docs/briefs/qol_common.md. Everything from 3.4 to 3.8 is merged: Trade and Market Halls, Trades, fishing, the Building
Society, Deeds, Regulars, darts, crabbing, shows, breeding, examine spots, locked and hidden warps, Deep Places, the
Casebook, Guilds, creature jobs, bells, walling, leases and the auction, quiz league, crossword, Highland games, hurling,
shinty, shanties, conkers and NPC routines. Read the headers of the ones your arc uses.
Base: `origin/polish-3.9`. Branch: claude/w39-<letter>-<name>.

## The arcs (sessions A to F): one nation each, 10 to 15 steps, post-game or late game (decide the gate from the
nation's story chapter), in data/quests/arc_<nation>.json (flags `q_arc_<nation>_*`), using at least four of the newer
verbs (a Deed, a Regular, an examine clue or Casebook evidence, a Deep Place, a guild rank, a lease, a minigame), with a
proper ending that changes something visible in the world (a reopened building, a restored landscape, a festival
revived) and a reward worth the road. Accurate history; real places; no real living people.
- **A. England**: e.g. the Kinder trespass spirit and a moor reopened to walkers, ending at a new right of way.
- **B. Wales**: the Big Pit, the Valleys' choirs, and whether the Heritage Trust reopens the mine as a theme park.
- **C. Scotland**: a Highland estate, the clearances remembered honestly, and a community buyout (real Scottish land
  reform history, accurate).
- **D. Ireland**: the Wild Atlantic Way boat by boat, a Gaeltacht story, a curragh race.
- **E. Northern Ireland**: the shipyards, the linen mills, the Mourne Wall builders (built 1904 to 1922), told with care.
- **F. Mann and the islands**: the Isle of Man's Tynwald and the TT, Shetland's Up Helly Aa and the Channel Islands'
  Occupation history, one arc that hops between them by ferry.

## G. Polish and audit
1. Deep Places look like ordinary rooms (beige walls): give cave interiors a rock style (stone walls, uneven floor,
   stalactites; cheap vertex-coloured meshes) in world/zone_builder.gd or a cave style in landmarks, and apply it to the
   Blue John zones and any other cave interiors (grep "cave" in data/zones).
2. First-hour audit for new players: play the opening from a new game headless (tools/playtest.sh slice and the
   `from` mode) and read the opening dialogue and tutorials; list anything confusing or unexplained in
   docs/audit/first-hour.md and fix the small, clear ones.
3. A scan for anything too close to Pokémon in player-facing text, names and UI (terms like Pokédex, Poké Ball, gym,
   trainer card, HM, IV, EV, nature, egg group, Day Care, evolution stones by those names): list findings in
   docs/audit/ip-scan.md and fix the clear ones with our own vocabulary (keep "Fieldbook", "snare", "Keeper", "Stone").
