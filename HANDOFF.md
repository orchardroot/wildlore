# Handoff: wave 45 session G, People of these isles

Done (commits 4910bd41 and the screenshots after it, pushed):
- core/these_isles.gd + data/these_isles.json: 17 themes, tallies plaques (sign "people" tag), people met
  (isles_met_<id> flags) and quests (data/quests/isles.json). Page in the Gazetteer tab (ui/gazetteer_tab.gd),
  Stats line, validator hook, tests/core/test_these_isles.gd (5 pass, validate 0 errors locally).
- tools/zones/w45_people.py placed 37 plaques, 16 NPCs (new isles_* sprites; headscarf/turban hats in
  character.gd), 4 quests, tagged 23 old plaques. It runs once on clean data only (refuses re-runs).
- docs/audit/facts_w45.md: open fact questions. Shots in docs/shots/w45g/.

Left: CI result for claude/w45-g-people was still running (gh hit API rate limit); check it, fix if red.
Gotcha: dev --menu ignores --flag, so "met" people show unmet in menu screenshots.
