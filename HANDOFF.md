# Handoff: w45-o crossbreeds

Done: core/crossbreeds.gd (closeness from new data/taxa.json real taxonomy, ids `x_<sire>_<dam>` resolved lazily in Dex.get_species/has, names, stats, learnset, fertility, validator check), ui/crossbreed_art.gd (blend.gd + creature.gd render, hooked in CreatureArt and AnimSprite), small hooks in genetics.gd, breeding.gd (crossbreed kind, odds roll consumes the day), pairing_logic.gd, pedia_screen.gd (Crossbreeds section C01+), dev_menu (`--menu=pedia:x_...`), validate.gd. Design section 10, docs/audit/facts_w45.md.

tests/core/test_crossbreeds.gd: 17 pass, 4 fail:
- deny-list test: "Xkrtpl" hits "no vowel" before "shape" (fix the test, use e.g. "Brrkstan").
- sterile/fertile test: a crossbred calf (x_moolet_coolet) x coolet is refused; Genetics._lines_of probably not picking up Crossbreeds.parent_lines (check line_of uses species.line = id), plus a SCRIPT ERROR (Breeding.offspring_species returned {} then `.id`).

Left: fix those, screenshots of 8+ crossbreeds to docs/shots/w45o/ via tools/shot.sh `--menu=pedia:<id>`, read them back, restrict mushy pairs, push, CI.
