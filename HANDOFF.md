# Handoff: wave 45 session K (life lessons)

Done (commit e79858a4 and later, pushed to claude/w45-k-life):
- 12 lesson NPCs + 1 Palace pit boss, scripts `life_<id>` in each zone's dialogue (generated, now plain data).
- data/life_lessons.json, core/life_lessons.gd, Almanac page "Things worth knowing" (core/almanac.gd, additive).
- tests/core/test_life_lessons.gd (6 pass locally), docs/audit/facts_w45.md, screenshot docs/shots/w45k/payslip.png.

Left: confirm GitHub CI green (full suite + slice playtest); fix anything it reports.

Gotchas: `gh run watch` can hit API rate limits, so poll with `gh run view <id>`. Run `--import` fully before local tests or the class cache is missing. Two stray .uid files (world/occluder_fade.gd.uid, viaduct.gd.uid) got committed from the import; harmless.
