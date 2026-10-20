# Wildlore 3.0 "Wider Isles", wave 21+

The owner (2026-10-19, overnight free hand): "Any bits which are walled off, such as Manchester to Oldham, you may as well just
expand the map. Add more cities and more things to do while retaining the general progression line. Perhaps make them quest
areas. Let's cover more of the UK." and "add interesting things in the new cities and towns. Add as many as makes it
interesting. I want people to learn about the UK and Ireland in this game."

Read docs/briefs/qol_common.md first; it binds you, with these overrides: BASE is `origin/polish-2.3` (not origin/main):
`git fetch -q origin && git checkout -b <your branch> origin/polish-2.3`. The game is now rated 16+ (mild adult jokes fine).
Warm, wry British humour; UK English (Irish English in Ireland, a little Welsh/Gaelic/Scots where natural, always glossed);
NO em-dashes in player-facing text. 60 fps on a 2013 iMac.

## What already exists (read before building)
- The world is a graph of outdoor zones (data/zones/<id>.json, `kind` "town" or "route") joined by `edges`
  ({"north": {"to": id, "offset": 0}}), one edge per side, which must be mirrored by the neighbour and land on walkable tiles
  (validator checks). Buildings are `props` of type "building" with `style`/`label`/`kind`; doors are `warps` into interior
  zones (kind "interior", region ""). Dialogue scripts live in data/dialogue/<zone>.json; trainers in data/trainers/<id>.json;
  signs in a zone's `signs`. Study a recent, rich town end to end before you start: data/zones/whitby.json (+ its interiors,
  data/dialogue/whitby*.json, trainers named whitby_*) and data/zones/buxton.json. Also: world/zone_builder.gd,
  world/landmarks.gd (building styles), world/dressing.gd, world/signage.gd, data/world_map.json (towns/places shown on the
  map screen, rail lines, ferries), world/travel.gd + zone `station` (the rail network), core/standing.gd (region -> nation),
  core/calendar.gd, data/objectives.json, story/commands.gd (all story commands) and data_api/story_validator.gd.
- Progression: the main story walks a fixed line (objectives.json "story"). Every outdoor zone has a level band.
  NEW: core/par_level.gd. A zone with `"scaled_floor": N` has its encounter levels authored for par N and lifted to the
  player's current par (furthest story step); species evolve to suit. A trainer with `"scaled_floor": N` likewise. ALL new
  zones and trainers in this wave MUST be scaled, with floor = the band of the existing zone you join onto. That is what lets
  new areas hang off early towns without breaking the progression line, and stay worth visiting later.
- Rule for joining: a new area joins the existing graph at ONE existing outdoor zone (your anchor), on a side that has no
  edge today, so it is a cul-de-sac (or a loop entirely inside your new zones). Never create a shortcut between two existing
  zones. Open the anchor's wall on that side cleanly (edit its rows with a careful text/Python edit; keep the town looking
  designed, e.g. a lane or gate leading out, a fingerpost sign naming your destination). If the anchor zone is reachable
  before the floor makes sense, gate the way out with the established pattern: blocker NPCs with `hide_if` (see the
  sheffield_warden NPCs in data/zones/buxton.json) and a friendly line explaining why (roadworks, a closed footpath, a
  farmer's bull), keyed on a story flag.
- Wild species: use the existing 200 + appendix (data/creatures). Pick ones whose habitat/lore fits the place; you may append
  your zone ids to a species' `habitat` list (text edit, additive). Check data/dex_order.json is untouched.

## What every region agent builds
1. Geography: 1 to 3 new outdoor zones (towns and routes), sized like existing ones (towns ~56-80 wide), real places in the
   right compass direction. Each town: Sanctuary (copy an existing sanctuary interior pattern), a shop (data/shops), a
   station if it's on the rail network, and at least 6 enterable interiors that are places people know: museums, castles,
   pubs, markets, chippies, galleries, cathedrals, football grounds, famous shops. Interiors need furniture/NPCs that make
   them feel like that place, not empty boxes.
2. Landmarks: the 1 to 3 things the town is famous for must be recognisable from the overworld (Blackpool Tower, Clifton
   Suspension Bridge, bottle kilns...). Add new building styles in world/landmarks.gd (append to SPECIAL and the `match`,
   new static funcs at the end of the file, matching the existing low-poly vertex-colour style). The owner called amateur
   visuals "naff": screenshot with tools/shot.sh from a couple of angles and iterate until it looks good. Keep vertex
   counts modest.
3. Learning about the place (the owner's main ask). Several of:
   - Heritage plaques: signs with `"plaque": "<unique id>", "title": "<short name>"` plus `text` (2-3 sentences of real,
     accurate, interesting history/nature/culture, told in the game's voice). At least 8 per town, 3 per route. Another agent
     is building the Gazetteer that collects them (contract below); you only author them.
   - NPCs who teach: locals with real dialect, stories, food, sport, industry, famous people, myths and folklore,
     wildlife facts, place-name meanings.
   - Pub quiz questions about your area appended to data/quiz/questions.json (check its format; append only).
   - Facts in creature dex text stay as they are; don't rewrite existing species.
   Be ACCURATE. If unsure of a fact, leave it out. No real living private individuals; famous historical figures are fine;
   avoid trademarks as logos (naming a real place/team/shop in passing is fine).
4. Quests: 2 to 4 quests per region, in data/quests/<your_region>.json (contract below). At least one multi-step chain that
   sends the player around your town(s) and route(s) learning things (e.g. Blackpool: help switch on the Illuminations;
   Stoke: fire a bottle kiln; Bristol: a balloon for the Fiesta). Quests use ordinary dialogue scripts and flags (namespace
   `q_<region>_*`), conditions via the existing story commands, and pay out real rewards: items, charms, money, standing
   (`{"do": "standing", ...}`), maybe a gift creature (`give_creature`, check commands.gd) or a key item of your own in
   data/items/<region>.json. At least one quest should include a trainer fight and one a catch or show-a-creature check.
5. Trainers: 6+ per region, scaled, varied, with local character and short funny intros; one tougher "local legend" with a
   full party.
6. World map: add your towns to data/world_map.json `towns` (real coordinates in the same projection: interpolate from
   nearby existing towns' x/y and real lat/long) and routes to `places`; extend rail lines if you add stations. Insert by text
   so other agents' additions merge cleanly. Check the map screen with tools/shot.sh (--menu=map or see dev_args).
7. Regions: give zones a `region` id; prefer an existing region id that fits (england regions: e.g. "yorkshire", "midlands",
   "south_england", "merseyside", "manchester", "cheshire", "cumbria", "north_east", "cornwall"...); if you need a new one,
   add it where core/standing.gd, core/calendar.gd and anything else keyed on regions (grep for an existing region id like
   "merseyside") need it.
8. Tests: a test file tests/world/test_<region>.gd that loads your zones and checks the edges, scaling, quest flags reachable
   and so on. Run tools/test.sh at the end: 0 SCRIPT ERROR, all pass, "validate: 0 error(s)". Also boot each new zone with
   tools/shot.sh and look at it. If tools/playtest.sh has a zone smoke/walk check, keep it passing.

## Shared contracts
**Quests** (agent Q builds the loader, Quest Log screen, toasts; region agents only author data):
`data/quests/<region>.json` = `{"quests": [ {"id": "blackpool_lights", "title": "Switch-On Night", "region": "blackpool",
"town": "<zone id where it's given>", "giver": "Name", "summary": "One line.", "start_flag": "q_blackpool_lights_started",
"steps": [ {"flag": "q_blackpool_lights_1", "text": "Find the electrician at the Tower Ballroom.", "zone": "<zone id>"} ...],
"done_flag": "q_blackpool_lights_done", "reward": "Short text of what you get."} ] }`.
A quest shows in the log once start_flag is set; the current step is the first step whose flag is not set; it is done when
done_flag is set. Your dialogue scripts set these flags with the existing set_flag story command. Region agents: write a
test that every flag in your quest file is set somewhere in your dialogue/trainer data.
**Plaques** (agent Q builds the Gazetteer): a zone `signs` entry with `"plaque": "<id>"` (unique across the game,
prefix it with your region, e.g. "leeds_corn_exchange") and `"title"`. Reading it the first time records it.
**Flags namespaces:** `q_<region>_*` for your quests, `<region>_*` for anything else you need.
**Shared hot files:** world/landmarks.gd, data/world_map.json, data/quiz/questions.json, core/standing.gd, creature habitat
lists, your anchor zone. Edit those SMALL and additive, by text insertion, never reformatting. Everything else: NEW files.

## Rules
- Save compatibility: an old save must load and play; existing zones keep their ids and spawn; you only open a wall.
- No changes to the main story, existing trainers or balance.
- Time box: about 2.5 hours. Ship finished, tested, beautiful pieces rather than half of everything. Commit on your branch,
  don't push. Report: what you built (zones, interiors, quests, plaques, trainers), map/landmark screenshots you checked,
  contract deviations, test counts, branch and commit.

## Also (owner, 2026-10-20; see docs/ROADMAP.md "Medium term")
- Regional items: 3+ items you can only find or buy in your region (local food and drink as healing items, a local charm,
  a craft material), in data/items/<region>.json and your shop's stock, with real-world descriptions.
- Local curiosities: 2+ odd, true local things to discover (a folly, a strange custom, a holy well, an odd museum), as
  interactable spots, NPCs or plaques.
- Localised buildings: your towns must not look like every other town. Use or add building styles and colours that fit
  the real local architecture (materials, roofs, chimneys, gables, shopfronts, street furniture).
- Regional creatures: read docs/briefs/creatures_addendum.md and add 2 to 3 new lines for your region.
