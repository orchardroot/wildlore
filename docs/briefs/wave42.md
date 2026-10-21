# Wildlore: These Isles 4.2 "Far and Wide", wave 42

Two asks from the owner: (1) the Overseas Territories should have their real time differences, and (2) some creatures
should have regional forms with slight, unique differences depending on which nation or territory they're caught in.
Read docs/design/2026-10-21-deeper-wildlore.md section 1, docs/design/2026-10-21-breeding.md (genetics: forms must
inherit sensibly), docs/briefs/wave33.md (the overseas registry and regions), docs/briefs/wave34.md (house rules,
Screenshots and Finish) and docs/briefs/qol_common.md. Base: `origin/polish-4.1`. Branch: claude/w42-<letter>-<name>.
Other waves (3.9 story arcs, 4.1 languages and music) are being built in parallel on other branches: keep edits to
shared files small and additive.

## Timezones (session A)
- core/timezones.gd (pure logic): each overseas region (and the Channel Islands, which share UK time) has a UTC offset
  and DST rule; the game clock is UK time; `Timezones.local_minutes(data, zone_id)` gives local time there. Use the real
  rules and CHECK each one (if unsure, say so in your report rather than guess): Gibraltar and the Sovereign Base Areas
  follow EU summer time (CET/CEST and EET/EEST); Ascension, St Helena and Tristan da Cunha are UTC+0 with no DST; the
  Falklands UTC-3 all year; South Georgia UTC-2; the British Antarctic Territory: pick the research station's practice
  (Rothera uses UTC-3); Bermuda AST with US-style DST; Turks and Caicos US Eastern with DST; Cayman UTC-5 no DST; BVI,
  Anguilla and Montserrat UTC-4 no DST; Pitcairn UTC-8; the BIOT UTC+6.
- Everything time-of-day in an overseas zone uses local time: the sky and light, day/night encounter phases, shop and NPC
  routine hours (3.8), festivals keyed to local dates where relevant. The departures board shows "Arrive 03:40 local
  time" and the flight time (rough real flight durations); landing gives a jet-lag line and, if you like, a tiny jet-lag
  effect (a nap at the Sanctuary clears it; nothing punishing).
- Save-safe; tests for each offset and DST switch date; the clock in the pause menu shows local time abroad with UK time
  beside it.

## Regional forms (sessions B, C, D)
**Contract (session B owns code):** `data/forms.json` = `{"<species id>": {"<form id>": {"name": "Falklands Gentoo-ish
suffix shown as e.g. 'Spikkin (Shetland)'", "regions": ["scotland", "overseas_falklands", ...], "zones": [optional
zone ids], "types": [optional replacement types, max one change from the base], "stat_lean": {"atk": 4, "spd": -4}
(small, net zero, max +/-6 per stat), "knack": "<optional knack id>", "move": "<optional signature move id>",
"look": {"palette": {...}, "features": [...] } (deltas on the sprite recipe: colours, a crest, longer ears, darker coat:
cheap and readable), "fact": "One true sentence about the real regional variation."}}}`.
- Creature gains `form := ""` (save-safe). A wild creature caught in a form's region gets that form (each form spawns
  only where it belongs; the base form elsewhere). Breeding: a form is inherited from the dam (document it as maternal for
  game clarity; add a Stud Book line explaining it's a simplification), and hybrids never carry forms.
- Fieldbook: forms listed under their species with where they're found; catching forms counts toward a "Forms" tally
  but never toward the core 200 (the core total must not change).
- Session B builds the system, sprite deltas (tools/spritegen recipes are generated, so apply the look delta at runtime
  like coats), validator checks, tests, and 6 reference forms.
- **C. UK and Ireland forms** (15 to 20): grounded in real regional variation where it exists (Shetland and Orkney
  island races, Irish stoats and hares, Scottish crossbills, Welsh mountain ponies, Highland cattle hairiness,
  Hebridean sheep, Manx loaghtan and the Manx cat's taillessness, Lundy's ponies, Skomer voles, St Kilda wrens and mice),
  and folklore forms where the legend is regional. Accurate facts only.
- **D. Overseas forms** (15 to 20): real island variation (Falklands and South Georgia pipits and teal, St Helena's
  wirebird, Ascension's land crabs, Bermuda's skinks, Cayman's blue iguanas vs rock iguanas, Caribbean anoles, Pitcairn's
  Henderson Island birds, Gibraltar's macaques, Cyprus's mouflon in Akrotiri's hinterland), mapped onto existing or 3.3
  overseas species. Accurate facts only.
- C and D author data to B's contract; use the STUB rule (commit a stub of core/forms.gd alone as "STUB forms.gd") if
  you need it to test before B lands.
