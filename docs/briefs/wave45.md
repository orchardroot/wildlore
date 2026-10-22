# Wildlore: These Isles 4.5, wave 45: "Learn as you go"

Adding new locations and features is welcome wherever they teach something, including places outside Britain and
Ireland (session L).

The owner's direction (2026-10-22): the game has grown from "a Pokémon clone" into a Pokémon-battle-inspired RPG of
Britain, Ireland and the Overseas Territories. Pokémon-style play draws people in; they should leave having learnt
about the diversity of the people of these isles, their history, their languages (above all **Welsh** and **Gaelic**,
plus **Scots** and **Ulster Scots**), and science, AI and technology. 39% of players are not British and that share is
growing, so explain things a British player takes for granted. The game is set in **2026**. The owner is Welsh.
Players are 16 to 55: write for adults, not children. They should also come away understanding economics, the
politics of these isles (Britain and Ireland above all) and a few life lessons, all through play.

Base: `origin/polish-4.4`. Branch: `claude/w45-<letter>-<name>`; commit there and `git push -u origin` it at the end.
Read docs/briefs/wave34.md (house rules, Screenshots, Finish) and docs/briefs/qol_common.md first.

## House rules that matter most here
- **Accuracy over volume.** Every fact, date, word and spelling must be right. If you are not certain of a word, a
  mutation or a date, leave it out, or put it in `docs/lang_review/<code>.md` (languages) or
  `docs/audit/facts_w45.md` (everything else) as a question for the owner, and keep it out of the game until then.
- Player-facing text: UK English, no em-dashes, rated 16+, warm and wry, never preachy or a lecture. Teach by doing
  (a quest, a puzzle, a person you meet), and keep each line short.
- Real people: historical figures are fine; for living people stick to well-documented public facts, never invent
  quotes. Communities are written with respect, by their own names, without stereotypes.
- Nothing past mid-2026 is "known"; don't invent 2026 events. Present-day framing ("in 2026...") only for things that
  were already true by 2025.
- Never break saves: new state lives in flags or new fields with safe defaults.
- Shared machine (4 cores, other agents): targeted tests while working (`tools/test.sh <fragment>`), the full
  `tools/test.sh` once at the end (0 SCRIPT ERROR, 0 failed, validate 0 errors). Screenshots only with
  `tools/shot.sh` (it never steals focus); never launch a windowed Godot any other way.
- Hot shared files (core/langs.gd, core/game_state_data.gd, ui/pedia_screen.gd, story/commands.gd, tools/validate.gd,
  the dev menu): small, additive edits only.

## Contract: language learning (session D owns the code; E and F author data to it)
`data/lang/<code>.json` keeps its existing keys (`places`, `greetings`, `phrases`) and gains:
```
"name": "Welsh", "endonym": "Cymraeg",
"about": ["2-4 short lines: who speaks it, where, how many, one surprising fact"],
"lessons": [{
  "id": "cy_01", "title": "Shwmae! Saying hello", "level": 1,
  "teacher": {"zone": "<zone id>", "x": 0, "y": 0, "name": "<name>", "sprite": "<existing npc sprite id>"},
  "intro": ["one to three short lines the teacher says"],
  "words": [{"id": "bore_da", "local": "Bore da", "english": "Good morning", "say": "BOR-eh dah",
             "note": "optional one-liner (grammar, culture, a mutation)"}],
  "tip": "optional single grammar or culture point for the lesson card"
}]
```
- `say` is an English-spelling pronunciation guide (no IPA), stressed syllable in capitals.
- 6 to 10 words per lesson. Levels: 1 (survival: hello, thanks, please, yes/no, numbers 1-10), 2 (places,
  weather, food and drink, nature and animals, family), 3 (a little grammar: mutations or lenition, a few verbs, "I
  like", "where is"), 4 (idioms, songs, place-name parts like aber-, llan-, bally-, kil-, inver-, strath-).
- Word ids are unique within a language. Lesson ids are `<code>_NN`.
- A teacher stands in a real town where the language is spoken (a school, library, chapel hall, pub or cafe interior
  of an existing zone), on a free floor tile; the validator checks the tile.
- New codes: `sco` (Scots) and `sco_ulster` (Ulster Scots). Session F adds them to `Langs.CODES`/`NAMES` and maps
  zones; session D's code must not hard-code the list.

Session D builds on top of 4.1's Words of the Isles: lessons from teachers, a review quiz (spaced repetition, multiple
choice, both directions), the word of the day on the pause screen, an optional "Say it" moment after a won battle in a
language's area (one quick question, small XP or money bonus, never blocks), certificates per level, and TrainerStats
counters. Session D also writes the Welsh (cy) lessons.

## Sessions
- **A. Smoother creature sprites (Opus).** Creatures are drawn by tools/spritegen/creature.gd from recipes in
  art/recipes/creatures/*.json at 96x96 and look blocky. Make every creature smoother without redrawing 246 recipes:
  e.g. render at a higher internal resolution with anti-aliased shapes and outlines and softer shading, then display
  at the same on-screen size with suitable filtering; keep each creature's silhouette, palette and charm, keep the
  icons crisp, keep coat, gene and form tinting (ui/coat_art.gd, ui/gene_art.gd, forms) working. Check memory and
  load time stay reasonable on a 2013 iMac (Kepler GPU, Compatibility renderer). Show before/after screenshots of 12+
  creatures in battle and in the Fieldbook (commit them under docs/shots/w45a/).
- **B. World graphics (Opus).** Using the existing engine and Compatibility renderer: nicer light and shadow (time of
  day, softer contact shadows, a touch of fake AO at wall bases), water, ground variation, foliage sway, sky and fog,
  interior lighting, character readability. Before/after screenshots of a city, a moor, a coast, a cave and an
  interior (docs/shots/w45b/). No big frame-rate drops; keep a "Low" graphics setting that looks like today.
- **C. More evolutions (Sonnet).** Find the evolution data (grep the creature JSON and battle/ for how a species
  evolves). Add a new evolved form to 30+ species that stop too early, with sprite recipes in the house style, stats
  in line with existing lines, move pools, evolution conditions that teach something (a level, an item, a place, a
  season, time of day, a language certificate from session D's flags `lang_cert_<code>_<level>`), and Fieldbook
  entries that each teach one true thing about the real animal or folklore. Validator and tests.
- **D. The language system and Welsh (Opus).** As the contract above. Then Welsh (cy): 12+ lessons over the four
  levels, teachers across Wales, `about` lines, the existing places, greetings and phrases kept, and signs and
  greetings drawing from lesson words as you learn them. Explain soft mutation simply ("cath" becomes "gath" after
  "ei" meaning "his"). Hooks in the Almanac (core/almanac.gd) and the Words of the Isles tab.
- **E. Scottish Gaelic and Irish (Opus).** Author `gd` and `ga` to the contract: 12+ lessons each, teachers in the
  Highlands and Islands and the Gaeltacht (Connemara, Donegal, Kerry, the Aran Islands if they exist in the game),
  lenition explained, Irish and Scottish Gaelic kept distinct (they are related, not the same), `about` lines.
  Add NPC lines and signs in the right places using the words taught. Use D's stubs if D hasn't landed (the STUB rule
  in wave34.md).
- **F. Scots, Ulster Scots and the smaller languages (Opus).** Add `sco` (Lowlands, Borders, the North East's Doric,
  Orkney and Shetland dialect as notes) and `sco_ulster` (Antrim, Down, the Ards) with 6+ lessons each, mapped to the
  right zones in core/langs.gd (the Lowlands currently get no language; Northern Ireland currently gets none by
  default). Burns, the Scots Language Act 2025 if you are sure of it, Ulster-Scots in the 1998 Belfast/Good Friday
  Agreement. Top up Manx, Cornish, Jèrriais and Guernésiais to 3 lessons each.
- **G. People of these isles (Opus).** History and diversity woven into towns: 30+ new plaques, NPCs and short side
  quests on the many peoples of these isles: Celts, Romans, Anglo-Saxons, Norse, Normans; Huguenots; Jewish
  communities; Irish emigration and the Famine; Gypsy, Roma and Traveller history; Liverpool's Chinese community
  (Europe's oldest Chinatown) and Black Liverpool; Cardiff's Tiger Bay and its Somali and Yemeni seafarers; Windrush
  (1948) and Caribbean Britain; South Asian Britain (Bradford, Leicester, Southall); Polish and other Eastern European
  communities; Ireland's new communities; and figures such as Mary Seacole, Walter Tull, Noor Inayat Khan, Olaudah
  Equiano, Lilian Bader and Dadabhai Naoroji, placed where they belong. A "These Isles" page in the Gazetteer
  tallies them. Respectful, specific, never tokenistic.
- **H. Science, invention and AI (Opus).** "Isles of Invention": a questline and plaques from Faraday, Maxwell,
  Babbage and Ada Lovelace, Darwin, Rosalind Franklin, Turing and Bletchley Park (add a small Bletchley Park zone off
  the nearest existing route if none exists), Tommy Flowers and Colossus, the Manchester Baby (1948), Jodrell Bank
  (Cheshire), Tim Berners-Lee, ARM and the Raspberry Pi (Cambridge), DeepMind and AlphaFold (Nobel Prize in Chemistry
  2024), and what AI is and isn't in plain words (how a model learns from examples, why it can be wrong, why people
  still matter). Kathleen Lonsdale, Jocelyn Bell Burnell (from Lurgan), Ernest Walton (Dungarvan; split the atom,
  1932), Robert Boyle (Lismore) for the Irish side. A science fair minigame or a puzzle that teaches one idea each
  (binary, a cipher, DNA base pairs). Accurate dates only.

- **I. Economics through play (Opus).** The game already has markets with gluts, the Building Society, Deeds,
  leases, euros and local pounds, auctions and a casino. Make them teach: supply and demand when a price drops,
  interest (simple versus compound, APR on the Building Society loan), inflation (a short story of a pint's price
  since decimalisation in 1971), opportunity cost, comparative advantage between towns, auctions and the winner's
  curse, why the house always wins (the casino's real odds shown). Economic history plaques: the Bank of England
  (1694), the South Sea Bubble (1720), the Irish punt to the euro (2002), the 2008 crash and Northern Rock, the
  Overseas Territories' own pounds and dollars. An "Economist's notebook" page in the Almanac that fills as you
  meet each idea. Small, honest numbers; no change to balance unless something is wrong (read docs/design/economy.md).
- **J. The politics of these isles (Opus).** Explain, even-handedly and accurately, how these isles fit together:
  the UK versus Great Britain versus the British Isles; England, Scotland, Wales and Northern Ireland and devolution
  (1998-99); the Republic of Ireland (independence 1922, the Republic 1949) and its relationship with the UK; the
  Troubles and the Belfast/Good Friday Agreement (1998) and the Common Travel Area; Brexit (2016 vote, left 2020) and
  the Northern Ireland Protocol and Windsor Framework (2023); the Crown Dependencies (Isle of Man, Jersey, Guernsey)
  versus the Overseas Territories; the Commonwealth; the Chagos Islands question (state facts only; do not describe
  2025-26 developments you cannot verify). No party politics, no taking sides, every community's view given fairly.
  Delivered as NPC conversations, a few plaques, a "How these isles work" Gazetteer page, and a short quest (e.g. a
  cross-border delivery from Derry to Donegal that explains the open border).
- **K. Life lessons (Sonnet).** Woven into existing systems and NPCs, never a lecture: spotting scams and phishing
  (a fake "Building Society" text, a too-good Deed offer: the owner runs a security operations centre, so get the
  details right: urgency, sender addresses, links, never share a code), budgeting a week, reading a payslip (tax,
  National Insurance, pension), renting versus buying, credit scores, gambling harms (the casino links to real help
  such as the National Gambling Helpline 0808 8020 133 in Great Britain; check every number), looking after your
  mental health (a quiet NPC who talks about a bad week; Samaritans 116 123 across the UK and Ireland), grief handled
  gently, asking for help, cooking on a budget. Each one earns a small reward and a line in a "Things worth knowing"
  Almanac page.

- **L. These isles abroad (Opus).** The owner welcomes new places, including outside Britain and Ireland, where they
  teach. Using the 3.3 Overseas travel system (flights from the RAF base, ferries; data/overseas, core/overseas.gd,
  data/timezones.json), add 4 to 6 compact destinations, each a small town plus one route or interior, with
  creatures, NPCs, plaques and a short quest, chosen for what they teach about the peoples of these isles:
  **Y Wladfa** (the Welsh in Patagonia, Argentina, since the Mimosa in 1865; Welsh still spoken in Gaiman and
  Trelew), **Cape Breton, Nova Scotia** (Scottish Gaelic in Canada, the Highland Clearances), **Boston or Ellis
  Island, New York** (Irish emigration and the Famine), **Appalachia** (the Scots-Irish/Ulster Scots in America,
  fiddle music), **Brittany** (Breton, a Celtic cousin of Welsh and Cornish), and optionally **Kingston, Jamaica**
  (the Windrush generation's home, coordinate with session G). Local time zones, local currency (the Wallet's
  currency system), and the right language hooks (Welsh in Gaiman uses session D's `cy` data). Validator, tests,
  screenshots of each.

- **M. Borders and neighbours (Opus).** Places where Britain meets its neighbours, with the same travel, currency
  and time-zone wiring as session L (coordinate by keeping to your own zones and data files):
  **La Línea de la Concepción** (Spain), across the frontier from Gibraltar (extend the existing Gibraltar zones with
  a walkable border crossing and the runway road): frontier workers, the 1969 to 1985 closure, Spanish phrases, tapas,
  the euro, the Bay of Gibraltar. **Cyprus**: the Sovereign Base Areas of Akrotiri and Dhekelia (British Overseas
  Territory, the RAF at Akrotiri), British rule until independence in 1960, and **Nicosia, both sides**: the Greek
  Cypriot south and the Turkish Cypriot north, the Green Line and the UN buffer zone, the Ledra Street crossing
  (opened 2008), 1974 told even-handedly with both communities' experience, Greek and Turkish phrases (Cypriot Greek
  and Cypriot Turkish flavour where you are sure), halloumi/hellim, the euro in the south and the Turkish lira in the
  north. No side-taking; people on both sides are warm, funny and specific. Creatures that fit the Mediterranean.
  Validator, tests, screenshots.

## Finish (each session)
Full tools/test.sh green, screenshots of every new or changed screen read back and fitting 1280x720, a short report
(under 200 words): what you built, open questions for the owner, test line, branch and commit.
