# Wildlore: These Isles 4.1 "Voices of the Isles", wave 41

Languages, music, accessibility and sharing. Read docs/design/2026-10-21-deeper-wildlore.md section 1 (identity),
docs/briefs/wave34.md (house rules, Screenshots and Finish sections apply unchanged) and docs/briefs/qol_common.md.
Base: `origin/polish-4.1`. Branch: claude/w41-<letter>-<name>. Other waves (3.9 story arcs) are being built in parallel
on other branches: keep your edits to shared files small and additive.

## The language contract (session A owns core/langs.gd and the rendering; B and C author data to it)
- A setting `local_languages` (core/settings.gd; default ON, showing the local language alongside English where the
  place really uses it): "off" | "on".
- Zone signs may carry `"local": {"cy": "Croeso", "ga": "...", "gd": "...", "gv": "...", "kw": "...", "jer": "...",
  "nrf_gg": "..."}` (Welsh, Irish, Scottish Gaelic, Manx, Cornish, Jèrriais, Guernésiais); NPC greetings and town
  names come from data/lang/<code>.json = `{"places": {"<zone id>": "Caerdydd"}, "greetings": ["Shwmae!"], "phrases":
  {"thanks": "Diolch", ...}}`. Langs picks the language(s) for a zone from its region (Wales: cy; Ireland and the
  Gaeltacht areas: ga; Highlands and Islands: gd; Mann: gv; Cornwall: kw; Jersey: jer; Guernsey: nrf_gg).
- Rendering: bilingual signs show both, the local language first where that's local practice (Welsh road signs vary by
  council; Irish signs show Irish first), in a slightly different colour; the town banner on arrival shows both names.
- ACCURACY IS EVERYTHING. Use only official or long-established place names (Welsh names from the Welsh Language
  Commissioner's standardised list style; Irish names from logainm.ie style; Gaelic from Ainmean-Àite na h-Alba style)
  and short, standard phrases. If you are not sure of a form, LEAVE IT OUT. No machine-translated sentences.

## Sessions
- **A. Language core + Welsh**: core/langs.gd, the setting, sign and banner rendering, a short glossary page in the
  Fieldbook ("Words of the Isles": each phrase met, with its meaning), and Welsh data for every Welsh zone (place names,
  6 to 10 greetings and phrases, bilingual signs on key buildings and plaques' titles where natural).
- **B. Irish and Scottish Gaelic data** to the contract: Irish for Republic of Ireland zones (Gaeltacht towns like
  Dingle/An Daingean and Gweedore/Gaoth Dobhair first), Gaelic for Highlands and Islands zones (Stornoway/Steòrnabhagh,
  Portree/Port Rìgh, Fort William/An Gearasdan, Inverness/Inbhir Nis). Northern Ireland: Irish and Ulster-Scots only
  where genuinely used on signage, sparingly and respectfully.
- **C. Manx, Cornish, Jèrriais and Guernésiais data** to the contract, smaller sets, same accuracy rule, plus a plaque
  in each place on the language's revival (accurate dates: e.g. Ned Maddrell, the last native Manx speaker, died 1974).
- **D. Music by region**: the soundtrack is composed as note lists (tools/music/). Add regional themes and
  instrumentation: harp and male voice choir feel for Wales, fiddle, whistle and bodhrán for Ireland, pipes and fiddle for
  Scotland, brass band for the north of England, a Manx and a Cornish air, a steel pan touch for the Caribbean
  territories; traditional public-domain tunes or originals only (no copyrighted melodies). Keep CPU and file size modest.
- **E. Accessibility pass**: screen-reader-friendly labels where Godot allows, every action remappable (check
  core/input_setup.gd), a dyslexia-friendly font option and larger text modes that don't break layouts (check every
  screen with screenshots at the largest size), colour-blind safe type colours, hold-to-confirm alternatives for
  timing minigames (fishing, darts, bells, shanties, caber: each must have an easier mode), and a short accessibility
  page in Settings.
- **F. Sharing and challenges**: export postcards and photo-mode pictures as PNGs to a folder with a caption, and a
  weekly seeded challenge (a fixed seed, rules like "Wales only, level cap 30, one creature per type") with a result code
  players can post and compare (deterministic, so the same code means the same run). No network features.
