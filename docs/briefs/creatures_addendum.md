# Addendum (owner, 2026-10-20): new regional creatures

The owner wants new monsters tied to specific regions, inspired by local lore, local wildlife and local events. Early on,
most creatures are birds (gale) and kin; playing Macclesfield to Liverpool the owner's frost Snowhare did all the heavy
lifting and it felt short of variety. So new creatures should favour UNDER-REPRESENTED types: storm (8 species), hearth (11),
urban (13), bog (13), iron (14), spirit (16), frost (16); avoid adding more pure gale/kin.

How (follow the 2.2 autumn-fungi appendix exactly: see `git show 73c368c --stat` and data/creatures/flyling.json):
- New species are in the APPENDIX: `"appendix": true` on every species of the line (they don't change the 200 count, the
  diploma or milestones). Append their ids to the END of data/dex_order.json (text edit; other agents append too, the
  controller merges).
- One file per line, data/creatures/<line>.json, 1 to 3 stages, existing move ids only (data/moves), sensible learnsets
  that give real coverage, base stat totals in line with comparable existing lines (basics ~280-330, middles ~400-430,
  finals 470-500; a one-stage lore creature ~450-500 and rarer). They should be GOOD, viable picks, not filler.
- Sprites: front and back via the generator (art/recipes/creatures + tools/spritegen.gd; `godot --headless --path . -s
  res://tools/spritegen.gd -- <ids>`, the fungi used recipes too, back sprites via back_* recipe keys). Look at the result
  and iterate until it reads well at battle size and is distinctive; the owner hates "naff" amateur art.
- Knacks (data/knacks.json): give the line a knack if the pattern makes that easy. Cries: check how cries are made (audio)
  and add one if needed.
- Dex text: in-voice text plus a true "fact" about the real creature, legend or event.
- Place them: habitat list and encounter entries in YOUR zones (and, for genuinely local ones, up to 2 existing nearby
  zones, by additive text edit). A legend-type one-off can be a quest reward or a special encounter instead.
- Unique ids: check `ls data/creatures` and grep dex_order so you don't clash with existing species (e.g. shuck, lambton,
  herne, afanc, bansheen exist). Prefix nothing, but pick distinctive names.
- Region agents: add 2 to 3 new lines each for your region. Tests: species load, appendix flag, sprites exist, placed in a
  zone or quest.
