# Wildlore: These Isles 3.4 "Market Day", wave 34

The owner wants the economy deepened so money and choices matter. The design is
docs/design/2026-10-21-deeper-wildlore.md: read section 1 (identity), section 2 (the economy; 2d is already done in
3.3) and your part of section 6 (3.4). Also read docs/briefs/qol_common.md (conventions; local paths like
~/Projects/wildlore and tools/shot.sh don't apply in the cloud: see "Screenshots" below) and README.md.

Rated 16+, warm wry British humour, UK English (Irish English in Ireland), accurate facts only (if unsure, leave it
out), NO em-dashes in player-facing text, 60 fps on a 2013 iMac. Never break saves: new state defaults safely on old
saves (core/game_state_data.gd from_dict; flags are the usual way). Validator-loaded scripts must not name autoloads
(Game, Bus, Router, Settings, Audio) or UIKit. Small additive edits to shared files; new logic in new files. Write a
failing test first where testable. Money must never be printable: add a MarketSim-style check (see core/market_sim.gd)
that a loop of your feature can't make money from nothing.

## Contracts between the sessions (implement exactly)
- **Trade Ledger** (session A owns `core/trade.gd`, class `Trade`, pure logic):
  `static func buy_price(data: GameStateData, item_id: String, zone_id: String) -> int` and
  `static func sell_price(data: GameStateData, item_id: String, zone_id: String) -> int`, both in STERLING pence-free
  whole pounds like item "price" today (Wallet converts to the local currency); `static func price_note(data, item_id,
  zone_id) -> String` ("cheap here", "they're crying out for it", "glut") for UI. Prices derive from the item's base
  "price" times regional and seasonal factors from data/trade.json, so ANY item (including new fish) has a price
  without being listed. Sessions B and E call these; for their own testing they may add a stub core/trade.gd with these
  exact signatures returning the base price (buy) and half of it (sell), committed ALONE in a commit whose message
  starts "STUB trade.gd" so the integrator can drop it.
- **Trades** (session D owns `core/trades.gd`, class `Trades`): `static func level(data, trade_id: String) -> int` and
  `static func has_perk(data, perk_id: String) -> bool`. Other sessions don't call it; D wires its perks into existing
  systems itself, except the Trader perk on prices, which D documents as a one-line hook for the integrator to add in
  Trade.sell_price.
- **Fish items** (session E owns data/items/fish.json, kind "fish").
- Each session's new quests go in data/quests/market_<x>.json, flags `q_market_<x>_*`; plaques prefixed `market_`.

## Sessions
- **A. Trade Ledger + Money Box**: core/trade.gd, data/trade.json (regions grouped sensibly; staples cheap where made,
  dear far away; gluts after you sell a lot in one place, recovering over in-game days; perishables (dishes, fish) lose
  value over in-game days, held as flags or a small save dict that defaults empty; seasonal and festival demand using
  core/calendar.gd and core/festivals.gd), a pannier upgrade (more stock to carry; the bag may have no cap today: if so,
  make the pannier a key item that raises a NEW per-item trade cap only for trade goods, never limiting existing play),
  the Money Box on the wireless (the radio already reads the forecast: world/forecast.gd) and a Monday market report
  line. Shops use buy_price/sell_price so prices differ by place (keep existing shop prices as the base so nothing
  gets dearer than today in the home region).
- **B. Market Halls**: 25 real market halls as interiors (e.g. Leeds Kirkgate, Bolton, Bury, Cardiff Central Market,
  Swansea, Carmarthen, Newport, Glasgow Barras, Inverness Victorian Market, Aberdeen, Belfast St George's, Cork English
  Market, Dublin (Moore Street stalls), Limerick Milk Market, Galway, Birmingham Bull Ring, Leicester, Norwich, Oxford
  Covered Market, Bath Guildhall, Kendal, Carlisle, Preston, Bristol St Nicholas, Plymouth Pannier Market), only in
  towns the game already has, each with a stall-holder NPC with local character, a price board (reads Trade), a sell
  flow (sell trade goods at Trade.sell_price) and one fact plaque. Use existing interior patterns and town doors (add a
  door/warp to an existing building where there's a sensible unused one; never move existing warps). Accurate facts.
- **C. The Building Society**: a branch in a few big towns (Manchester, Cardiff, Edinburgh, Belfast, Dublin as a credit
  union with euros) where Pat lends with honest compound interest (fixed sensible rates, monthly in-game repayments
  taken automatically from the purse, letters through the post box world/post_box.gd when you're behind, a polite
  limit by progress so it can't fund silly debt), a savings account paying a little interest, and Mum's sub (a small
  interest-free loan once, with a guilt trip). Show it all on a statement screen. Teach APR lightly in plain words.
- **D. Trades**: the player's own progression without a skill tree: Rambler (steps walked), Trader (money from sales),
  Cook (dishes cooked), Angler (fish caught, reading a counter session E adds; use TrainerStats.get_count so it's 0
  until fishing lands), Naturalist (Fieldbook entries), Local (standing) read off core/trainer_stats.gd and existing
  state; levels with friendly titles; a Trades page on the Stats screen; 2 small perks per trade wired into existing
  systems (e.g. Rambler: repel lasts longer; Cook: a chance of a second portion; Naturalist: rarer weather spawns
  a touch more often). Balance: modest.
- **E. Fishing**: a rod (key item, from a tackle shop or an angler NPC early; better rods later), cast at water tiles
  you face (world/field_moves.gd has field interactions; reuse its pattern), a short timing minigame that is fun, fair
  and readable (no twitch skill wall; an accessibility option to make it easier in core/settings.gd), fish as items
  (data/items/fish.json, 15+ real UK, Irish and overseas fish appropriate to fresh/salt water and region; accurate),
  a few creatures only found "on a line" from the existing dex by habitat (water types), a TrainerStats counter
  "fish_caught", and fish sold via Trade.sell_price. Overseas waters get their own fish.
- **F. Builds and feedback**: make the Release workflow (.github/workflows/release.yml, export_presets.cfg) also build
  and attach working Windows and Linux (x86_64) builds, verified by a CI step that at least launches the Linux build
  headless and quits; add an in-game "Report a bug" option (pause or settings menu) that opens a pre-filled GitHub issue
  URL (repo orchardroot/wildlore-these-isles) with version, zone, platform and a short free-text box, via
  OS.shell_open; add .github/ISSUE_TEMPLATE bug and idea templates and a short CONTRIBUTING.md (how to run tests and
  the playtest bot including `tools/playtest.sh from <beat>`, the house rules from README Status, briefs as starter
  tasks). Close GitHub issue "Windows and Linux builds, and a report-a-bug button" in your PR description.

## Screenshots (Linux cloud)
`sudo apt-get install -y xvfb libgl1-mesa-dri` (or without sudo), then
`xvfb-run -a -s '-screen 0 1280x720x24' $(tools/get_godot.sh) --audio-driver Dummy --rendering-driver opengl3 --path .
-- --quiet-window --shot=/tmp/x.png --shot-delay=8 --boot=<zone>@<x>,<y> --clock=12:00 --weather=clear` and Read the
PNG (see core/dev_args.gd and ui/dev_menu.gd for switches such as --menu=<name>). Check every new screen you add.

## Finish
Run `$(tools/get_godot.sh) --headless --path . --import` once, then
`tools/test.sh > /tmp/t.log 2>&1; grep -c "SCRIPT ERROR" /tmp/t.log; grep -E "passed|validate:" /tmp/t.log`: 0 SCRIPT
ERROR, 0 failed, "validate: 0 error(s)"; and `tools/playtest.sh slice 2` passes. Do NOT run the full-story playtest.
Commit with trailers `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` and
`Claude-Session: https://claude.ai/code/session_01ScZErCU1AdyrXuMs3LAqNr`, push your branch claude/w34-<letter>-<name>,
and report in under 150 words: what you built, files touched outside new files, test counts. Be token-efficient:
targeted reads (grep, sed -n), long output to files.
