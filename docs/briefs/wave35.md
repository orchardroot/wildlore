# Wildlore: These Isles 3.5 "Open for Business", wave 35

Read docs/design/2026-10-21-deeper-wildlore.md sections 1, 2 (especially 2b Deeds, 2c credit and rates) and 6 (3.5),
docs/briefs/wave34.md (the house rules, the Screenshots and Finish sections apply here unchanged; 3.4 Market Day
is merged, so core/trade.gd Trade, core/trades.gd Trades, core/building_society.gd, fishing and the Market Halls
exist: read their headers) and docs/briefs/qol_common.md. Base: `origin/polish-3.5`. Branch: claude/w35-<letter>-<name>.

## The Deeds contract (session A owns core/deeds.gd, class Deeds, pure logic; everyone else writes data to it)
- A Deed is a business the player can buy in one real place: `data/deeds/<deed_id>.json` =
  `{"id": "chippy_whitby", "kind": "chippy" | "bnb" | "boat" | "stall" | "allotment", "name": "The Magpie... (invent a
  name; never a real business's name)", "zone": "<town zone id>", "door": {"x": 0, "y": 0} (the existing building
  whose door leads to it, or omit if the Deed adds its own interior zone), "interior": "<interior zone id>",
  "cost": [3000, 9000, 20000] (sterling by badge band: under 4 badges, 4 to 7, 8+; euros are converted by Wallet in
  Ireland), "unlock_flag": "badge_storm", "inputs": [{"item": "<item id>", "per_day": 3}] (what it consumes from its
  store each in-game day; Trade prices them), "output": {"base": 120, "per_input": 30} (takings per in-game day in
  sterling before multipliers), "rates": 0.08 (share of takings owed as business rates, billed weekly),
  "tiers": [{"name": "...", "cost": 0, "mult": 1.0}, {"name": "New fryer", "cost": 4000, "mult": 1.25}, ...] (3 to 4),
  "events": [{"id": "coach_party", "chance": 0.05, "mult": 2.0, "line": "A coach party from Barnsley..."},
  {"id": "storm", "chance": 0.03, "mult": 0.0, "line": "..."}] (5 or more, seasonal where it fits: "season": "summer"),
  "manager_slot": true}.
- State in flags `deed_<id>` = `{"owned": true, "tier": 0, "store": {item: n}, "till": 0, "rates_due": 0,
  "manager": "", "last_day": <DailyKey day>}`; absent means not owned, so old saves are fine.
- API: `Deeds.all() -> Array`, `Deeds.get_deed(id) -> Dictionary`, `Deeds.owned(data) -> Array`,
  `Deeds.price(data, id) -> int`, `Deeds.buy(data, id) -> String` ("" or a friendly reason), `Deeds.supply(data, id,
  item_id, n) -> int`, `Deeds.tick(data, day) -> Array` (advance owned Deeds to `day`: consume inputs, add takings
  times tier and event multipliers and the manager's bonus, accrue rates; returns lines for the post), `Deeds.collect(data,
  id) -> int` (empties the till into the purse in the local currency), `Deeds.upgrade(data, id) -> String`,
  `Deeds.set_manager(data, id, npc_id)`, `Deeds.sell_back(data, id) -> int` (60% of what you paid). A Deed with no
  stock earns only `base` x 0.25. Nothing may print money: MarketSim-style test that buying, supplying from the
  cheapest region and collecting can't beat a sensible ceiling per in-game day.
- UI: a Deed screen reached by talking to the counter in the interior (`{"do": "deed", "id": ...}` story command)
  showing till, store, tier, events log, rates due, manager, with Collect / Supply / Upgrade / Sell back.
- Post: weekly rates bill and monthly statements through world/post_box.gd; a once-a-year HMRC envelope (self
  assessment, done with humour; real UK tax facts in plain words, accurate and light).

## Sessions
- **A. Deeds core + the chippy**: core/deeds.gd, the story command and validator entry, the Deed screen, post,
  rates and HMRC, MarketSim check, inflation drift (a slow, seeded, gentle rise in Deed costs and takings over in-game
  years; never raising existing shop prices), and the reference Deed: a chippy in two places (pick from Whitby,
  Blackpool, Fleetwood, Morecambe or Grimsby if the game has them; else Whitby and Blackpool), with fryers, fish from
  the fishing items, potatoes, and events.
- **B. B&B and market stall**: data for B&Bs (e.g. Bath, Keswick or Edinburgh: whatever towns exist, two places) and
  a market stall in two Market Halls from 3.4; their interiors, NPCs and events. Write the JSON to the contract; test
  that each file parses and names real zones and items; you may add a temporary core/deeds.gd stub with the exact
  signatures committed ALONE as "STUB deeds.gd".
- **C. The boat and the allotment**: a fishing boat Deed in two harbours (catch is fish items; a storm loses a day's
  catch) and an allotment Deed (grows produce items from seeds by season: add data/items/allotment.json produce and
  seeds, real British veg), with interiors (a harbour hut, a shed), NPCs, events. Same contract and STUB rule.
- **D. The Regulars**: twelve recurring characters across the Isles (core/regulars.gd), each with a home town, a
  favour meter in flags `reg_<id>`, three or four small story beats unlocked as favour rises (letters by post,
  meeting them in other towns), a gift they like, and the manager hook: at high favour they offer to manage one of
  your Deeds (call `Deeds.set_manager`; STUB rule applies). Warm, funny, varied (a retired trawlerman, a Welsh choir
  mistress, a Belfast shipyard pensioner, a Dublin bookie...). No real living people.
- **E. Darts and crabbing**: a darts minigame in pubs (a fair, readable aiming mechanic; 501 against locals, a pub
  league ladder per nation with small prizes) and crabbing off harbour walls (bait, a line, a bucket, counting and
  releasing; a crabbing competition in summer). Both with accessibility options (core/settings.gd), TrainerStats
  counters and modest money/standing rewards.
- **F. Show ring: allotment show and sheepdog trials**: extend the County Shows (world/show_ring.gd, data/shows.json)
  with a produce class (judge any items of kind "produce": size and condition, with rosettes and prize money) and
  sheepdog trials (herd sheep through gates with your lead creature: a short, fair steering minigame), each with a
  real-facts plaque.
- **G. Good Stock genetics kit (3.6 groundwork)**: read docs/design/2026-10-21-breeding.md and build ONLY the first
  session from its section 8: the pure-logic genetics kit (core/genetics.gd and data/genes.json per section 7) with its
  tests (inheritance ratios over many seeded crosses within tolerance, sex linkage, linkage, deterministic derive for
  existing creatures, old saves load unchanged). No UI, no Creature changes beyond what section 7 says are safe
  defaults; don't wire it into gameplay yet.

Shared hot files: story/commands.gd, data_api/story_validator.gd (COMMANDS list), core/scene_router.gd (menus),
core/trainer_stats.gd (COUNTERS), data/quiz/questions.json, world/landmarks.gd: SMALL additive insertions only.
