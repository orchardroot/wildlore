# Wildlore: These Isles 4.0 "Settling In", wave 40

No new systems: make everything since 3.0 work together, run well, and make sense to a new player. Read
docs/design/2026-10-21-deeper-wildlore.md section 1 (identity) and section 7 (risks), docs/briefs/wave34.md (house rules,
Screenshots and Finish sections apply unchanged), docs/briefs/qol_common.md and README.md "What's new" from 3.1 to 3.9.
Base: `origin/polish-4.0`. Branch: claude/w40-<letter>-<name>. Write a failing test first wherever you fix a bug.

## Sessions
- **A. The whole story, end to end**: run `tools/playtest.sh full 2` (over an hour; the only session allowed to) and
  `tools/playtest.sh from <beat>` for any beat it trips on; fix every soft-lock, crash and dead end it finds (real
  ones, not bot quirks: check each against the map and NPC data). Report the bot's last lines.
- **B. Performance on a 2013 iMac**: profile the busiest places (Liverpool, London, Edinburgh, Dublin, a Market Hall,
  a lease zone, a Deep Place, a town during a festival with NPC routines running) with the --fps dev switch and Godot's
  profiler headless where possible; cut per-frame allocations, node counts and draw calls; target 60 fps on Intel HD /
  Kepler-class GPUs with the Compatibility renderer. Report before/after numbers.
- **C. Saves across versions**: build save fixtures for 2.0, 2.2, 3.0, 3.3, 3.5 and 3.8 shapes (generate them by
  checking out those tags' core/game_state_data.gd to_dict, or by hand from the code history), and a test that each
  loads, plays a scripted hour (the bot's from mode), saves and reloads with nothing lost. Fix what breaks.
- **D. The Almanac and "Where next?"**: one hub screen gathering the pages that have sprouted (Fieldbook, Gazetteer,
  Casebook, Stud Book, Trades, Guilds, Deeds, the Society statement, the quest log, Rumours, Words of the Isles if it
  exists) with a consistent layout and tab order, and a "Where next?" card on the pause menu suggesting three
  worthwhile things based on where you are and what you've unlocked (story first, then nearby quests, festivals today,
  a Deed's till, a basket about to hatch).
- **E. Gentle introductions**: each system explains itself the first time you meet it and not before (a short line or
  card, never a wall of text), with a "Hints" setting to turn them off. Audit the opening hour again after 3.9's audit
  (docs/audit/first-hour.md if present) and fix what's left.
- **F. The whole economy**: a MarketSim-style simulation that plays the money systems together over a long run (Deeds,
  Trade arbitrage between regions, stocks and crypto, the casino and racing, breeding and stud fees, leases, jobs,
  tips, the Building Society) and proves no combination prints money or makes the story trivial; tune numbers that do.
  Document the economy's shape in docs/design/economy.md.
