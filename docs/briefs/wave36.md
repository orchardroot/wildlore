# Wildlore: These Isles 3.6 "Good Stock" (breeding), wave 36

The owner asked for breeding that goes well beyond Pokémon: real inheritance that teaches genetics, hybrids where
they're plausible (or mythic), merged types and skills, deep enough to be engaging. The design is
docs/design/2026-10-21-breeding.md: read ALL of it (sections 7 and 8 are your contracts). Also read docs/briefs/wave34.md
(house rules, Screenshots and Finish sections apply unchanged) and docs/briefs/qol_common.md.

Session A (the genetics kit) is DONE and merged: core/genetics.gd (class Genetics: genes(), hybrids(), kindred_of,
genome_of, derive, cross, showing, kinship, punnett, can_pair, check), data/genes.json and the Creature fields in
battle/creature.gd. Read its header and tests (tests/core/test_genetics.gd) before you start; use its API, don't
change its signatures (additive helpers are fine). 3.5 Open for Business is merged too: core/deeds.gd (Deeds),
core/regulars.gd (Regulars), the show ring events.

Base: `origin/polish-3.6`. Branch: claude/w36-<letter>-<name>. Sessions B to F from section 8 of the design, all in
parallel:
- **B. Hybrids and the Fieldbook**: data/hybrids.json (each entry tagged real / folklore / invented, accurate), Dex
  hybrid loading, the Hybrids Fieldbook section, sterility, merged types and move pools, validator checks.
  Contract: the hybrid entry shape in section 7 and `Dex.hybrid_ids()`.
- **C. Sprites**: blend two creature recipes by genome (tools/spritegen recipes are generated, so this is runtime
  blending: ui/gene_art.gd per section 7), roan and tortie coats, caching per genome hash, cheap enough for a 2013 iMac.
  Contract: `GeneArt.texture(c: Creature, kind: String) -> Texture2D`. Screenshot several crosses and hybrids.
- **D. The farm and Roslin**: the rare-breeds farm zone (Cotswolds; invent the farm's name, no real business) with Dot,
  and the Roslin Institute lab near Edinburgh with Dr Keir (real place: describe its real work accurately and
  respectfully, Dolly the sheep 1996), core/breeding.gd (baskets, pairing, eggs hatching by steps walked and season,
  the `breed_*` flags), three Watchlist conservation quests (Soay sheep, Kerry cattle, Scottish wildcat or similar,
  accurate), plaques (Mendel, Bateson, Punnett, Franklin, Crick and Watson, Dolly, rare breeds; check every date).
- **E. UI and the Stud Book**: pairing screen with the Punnett preview, the genome page, the basket line, and the
  Stud Book tab (observed versus expected tallies) in core/stud_book.gd. Uses D's flag names (agree them from section
  7; use the STUB rule for core/breeding.gd if you need it before D lands: commit alone as "STUB breeding.gd").
- **F. Shows, stud fees and the paddock**: a Breed Class at the County Shows, stud fees, the genotype test, a paddock
  Deed (data/deeds/ to the 3.5 contract), and a MarketSim strategy proving breeding can't print money.

Nothing bred may overpower the story: keep inherited strength within the existing IV-style ranges (see section 9).
Old saves must load unchanged and existing creatures get genomes by Genetics.derive. No Pokémon vocabulary (no Day
Care, Ditto, egg groups, IVs, natures in player-facing text).
