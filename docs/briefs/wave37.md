# Wildlore: These Isles 3.7 "Behind Doors", wave 37

Depth: rooms worth a second look, places to explore, mysteries, guilds, and your lead creature doing a job. The design
is docs/design/2026-10-21-deeper-wildlore.md section 3 ("Depth behind doors") and section 6 (the release called
"3.6 Behind Doors" there; it is 3.7 now because breeding took 3.6). Read both, plus docs/briefs/wave34.md (house rules,
Screenshots and Finish sections apply unchanged) and docs/briefs/qol_common.md. 3.4 (Trade, Trades, fishing, Market
Halls, Building Society), 3.5 (Deeds, Regulars, darts, crabbing, shows) and 3.6 (breeding) are merged: read their
headers before you touch anything nearby. Base: `origin/polish-3.7`. Branch: claude/w37-<letter>-<name>.

## Contracts (session A owns the code; the others author data to it)
- **Examine spots**: a zone JSON `"examine": [{"x": 0, "y": 0, "text": ["line", "line"], "find": {"item": "<id>", "n": 1}
  (optional), "money": 0 (optional), "flag": "<set once found>" (optional), "needs": "<flag or item id>" (optional),
  "evidence": "<case evidence id>" (optional)}]`. Facing the tile and pressing confirm reads it; a find is given once
  (flag `ex_<zone>_<x>_<y>` when no flag is named). Validator checks tiles are in bounds and not blocked off.
- **Locked and hidden warps**: a warp may carry `"locked": {"needs": "<flag or item id>", "line": "It's locked."}` (walking
  in says the line until you have it) and `"hidden": {"reveal": "<flag>"}` (not there at all until the flag is set). Old
  warps without these keys behave exactly as now.
- **Evidence**: data/cases/<case_id>.json `{"id", "title", "nation", "start_flag", "evidence": [{"id", "name", "text",
  "red_herring": false}], "suspects": [{"id", "name", "zone"}], "culprit": "<suspect id>", "steps": [{"flag", "text",
  "zone"}], "done_flag", "reward"}`; flags `case_<id>_*`. Session D owns core/casebook.gd and the Casebook tab.

## Sessions
- **A. The examine kit, locked and hidden warps** in data_api/zone_data.gd, world/overworld.gd, the validator and tests;
  then a first pass of examine lines for 40+ interiors in ENGLAND (flavourful, true, funny; one or two finds per town,
  small: a few coins, a material, a key that a locked warp elsewhere in the same town needs). Add three real secret or
  locked places as hidden/locked warps with small new interiors: the Williamson Tunnels (Liverpool), Mary King's Close
  is Scotland's (leave it to B), the priest hole at Speke Hall if Speke exists else another real priest hole, and the
  Chester Rows upper walkway if Chester's layout allows.
- **B. Examine lines for Wales, Scotland, Ireland, Northern Ireland and Mann**: 60+ interiors, same rules, plus Mary King's
  Close under Edinburgh's Royal Mile as a locked warp with a small interior. Author data only (you may add a temporary
  copy of A's validator check to your branch's tests if you need one); never move existing warps.
- **C. Deep Places kit + Blue John Cavern**: the four puzzle verbs from section 3 (lever and gate, weight on plate,
  light and dark using the existing lantern, water level), multi-floor interiors, built as a reusable kit; then Blue John
  Cavern at Castleton (near Buxton; check the game's zones) as the reference Deep Place with accurate plaques, wild
  creatures that fit a cave, and a reward worth the trip.
- **D. The Casebook**: core/casebook.gd, a Casebook tab in the Fieldbook (pattern: ui/rumours_tab.gd, ui/gazetteer_tab.gd),
  evidence collected from examine spots and NPCs, an accusation prompt (wrong guesses cost standing and close a line),
  and two cases: the Mersey otters (Liverpool and the Wirral) and Loch Ness (Inverness, Fort Augustus if present). Funny,
  fair, solvable; no real living people accused of anything.
- **E. Guilds**: six guilds with three ranks each earned by doing (core/guilds.gd reading TrainerStats, Trades, the
  Gazetteer, Deeds), a perk per rank wired into existing systems, and the one real choice (Ramblers versus the Heritage
  Trust), flagged in advance, reversible at a cost. A guild hall NPC for each in a fitting town. Balance: modest.
- **F. Creature jobs in the overworld**: your lead creature does a small job based on its type when you face the right
  thing (a brook type fords a stream, a gale type fetches from a ledge, a kin type nudges a boulder, a hedgerow type sniffs
  out forage, a frost type crosses ice, a spirit type shows a hidden path) with a short animation and a line; reuse
  world/field_moves.gd; place 30+ job spots across existing zones that reward a little (never block the story).
- **G. Bell ringing and drystone walling**: a change-ringing minigame in a church tower (call changes on six bells,
  readable and fair, with real method names and a plaque on English change ringing) and a drystone walling puzzle (place
  stones by size and shape to fill a gap; tied to rewilding: world/rewild.gd), both with accessibility options, small
  rewards and TrainerStats counters.

Shared hot files as before: small additive insertions only.
