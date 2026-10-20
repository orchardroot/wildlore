# Wildlore 3.3 "Overseas", wave 33

The owner (2026-10-21): "it'd be cool to have all the British Overseas Territories in there too with their own special
environments and pokemon. Flights from an RAF base somewhere" and "include Jersey and Guernsey too. I'm British and
consider the BIOT to be British territory."

Six cloud agents build this in parallel. Read docs/briefs/qol_common.md and docs/briefs/wave21.md (what a new area
needs: zones, Sanctuary, shop, interiors that are real places, landmarks, accurate plaques, NPCs who teach, quests,
scaled trainers, regional items, curiosities, localised buildings, tests) and docs/briefs/creatures_addendum.md (how
to add appendix creatures). Those bind you except where this file says otherwise. You are on Linux in the cloud: the
local-only paths (~/Projects/wildlore) and tools/shot.sh don't apply; to see your work, install Xvfb and run the game
windowed under it (see "Screenshots" below). Rated 16+, warm wry British humour, UK English, accurate facts only (if
unsure, leave it out), NO em-dashes in player-facing text, 60 fps on a 2013 iMac.

## The shape
- **RAF Brize Norton** (real: the RAF's air transport hub in west Oxfordshire, home of the South Atlantic Airbridge to
  the Falklands via Ascension). A small zone off the Cotswolds/Oxford area. After the Moot (flag `champion`), an RAF
  movements officer signs you up and you can fly from the terminal to any territory in the registry.
- **Registry contract** (agent 1 implements the reader; every other agent only writes its own file):
  `data/overseas/<territory>.json` = `{"id": "gibraltar", "name": "Gibraltar", "arrival": {"zone": "<zone id>",
  "x": 0, "y": 0}, "via": "raf" | "ferry", "port": "<zone id of the UK port for ferries>", "unlock_flag": "champion",
  "blurb": "One line for the departures board.", "flight_line": "What the pilot says on landing."}`.
  The departures board lists every registry file whose unlock flag is set; going there is a fade plus a short travel
  line, like the existing ferries/flights in world/travel.gd. Coming home: an airfield or harbour in each territory
  takes you back to Brize Norton (or the ferry port). Agent 1 also adds `"overseas"` to wherever nations/regions are
  keyed (core/standing.gd NATIONS and nation_for_zone, core/calendar.gd, anything grep finds for "mann") so overseas
  zones have a sensible nation, standing and flag (the Union flag, or the territory's own flag where the code supports
  it). Region ids: `overseas_<territory>`; nation_for_zone must map any `overseas_*` region to "overseas", and
  `channel_islands` to a new nation "channel_islands" (Jersey and Guernsey are Crown Dependencies, like Mann).
- **Levels**: every overseas zone and trainer has `"scaled_floor": 95` (post-game), so they stay a challenge.
  Exception: the Channel Islands are reachable earlier (agent 6 decides the gate, see below) with scaled_floor at the
  band of the port they hang off.
- **Money**: keep the game's pounds everywhere (Wallet). Real local currencies (Gibraltar, Falklands and St Helena
  pounds at par with sterling; US dollars in the BVI and Turks and Caicos; Cayman dollars; Eastern Caribbean dollars
  in Anguilla and Montserrat; Jersey and Guernsey pounds) can be mentioned in dialogue and plaques.
- **Each territory**: one to three outdoor zones (a town plus wild ground; tiny places like Pitcairn or Tristan can be
  one zone), a Sanctuary (or a field-hospital/clinic variant where there's no town), a shop with 3 local items,
  4+ enterable interiors that are real places, landmarks recognisable from the overworld, 8+ accurate plaques per
  territory (Gazetteer contract: sign `"plaque": "<unique id prefixed with your territory>"`, `"title"`), 4+ scaled
  trainers with local character plus one "local legend", a quest (data/quests/overseas_<territory>.json, flags
  `q_overseas_<territory>_*`), a distinct ENVIRONMENT (terrain colours, vegetation, sky/weather table, props: e.g. sub-
  Antarctic tussac and glaciers, Caribbean reef and palms, volcanic cinder, limestone Rock), and 2 to 3 NEW creatures per
  territory from real local wildlife and lore (appendix species; append to data/dex_order.json by text insertion at the
  end of the appendix block). New creatures need sprites in the project's pipeline (see creatures_addendum.md).
- **Shared hot files** (world/landmarks.gd, data/world_map.json, data/dex_order.json, core/standing.gd,
  data/quiz/questions.json): small additive text insertions only, never reformatting. Put building styles in your own
  file world/landmarks_<group>.gd with small hooks (pattern: world/landmarks_valleys.gd).
- **World map**: territories are far off the map, so don't place them on it; agent 1 adds an "Overseas" panel or
  departures board instead. The Channel Islands do go on the map (real coordinates in its projection).

## Agents
1. **Hub + Mediterranean**: RAF Brize Norton zone (joined to the Cotswolds or Oxford by a cul-de-sac route, gated
   until `champion` with a friendly blocker or an always-open but sign-posted base), the registry reader, departures
   board UI, travel there and back, the "overseas" nation; plus Gibraltar (the Rock, Barbary macaques, St Michael's
   Cave, Great Siege Tunnels, Main Street, Europa Point) and the Sovereign Base Areas of Akrotiri and Dhekelia
   (Akrotiri salt lake flamingos, the RAF station). Include an example registry file and a test that every file in
   data/overseas/ parses and its arrival zone exists.
2. **South Atlantic**: Ascension (Green Mountain cloud forest, green turtles, Georgetown, cinder cones), St Helena
   (Jamestown, Jacob's Ladder, Longwood House and Napoleon, Jonathan the tortoise, the wirebird), Tristan da Cunha
   (Edinburgh of the Seven Seas, rockhopper penguins, the 1961 eruption), the Falkland Islands (Stanley, Gypsy Cove
   penguins, peat, wrecks, Volunteer Point). The Airbridge stops at Ascension on the way to the Falklands: use that.
3. **Ice**: South Georgia and the South Sandwich Islands (Grytviken, Shackleton's grave, king penguins, elephant seals,
   glaciers) and the British Antarctic Territory (a research station like Rothera or Port Lockroy's penguin post office,
   emperor penguins, ice). Port Lockroy is a real museum and post office: a good postcard tie-in (core/postcards.gd).
4. **Caribbean and North Atlantic**: Bermuda (pink sand, the cahow, Royal Naval Dockyard, shipwrecks, Gibbs Hill
   lighthouse), the Cayman Islands (blue iguana, Stingray City, George Town), Turks and Caicos (conch, flamingos,
   Grand Turk), the British Virgin Islands (The Baths on Virgin Gorda, Road Town), Anguilla (salt ponds, Sandy Ground),
   Montserrat (the Soufriere Hills volcano and the buried capital Plymouth, the Montserrat oriole, St Patrick's Day is a
   public holiday there). Group small islands sensibly (one zone each is fine).
5. **Pacific and Indian Ocean**: the Pitcairn Islands (Adamstown, the Bounty, Bounty Bay, the descendants of the
   mutineers and Tahitians, Henderson Island's endemic birds) and the British Indian Ocean Territory (Diego Garcia:
   the atoll, coconut crabs, seabirds, the UK/US base; tell its history accurately and with respect, including the
   removal of the Chagossian people in the late 1960s and early 1970s. The owner regards the BIOT as British territory:
   present it as a British Overseas Territory in the game).
6. **Channel Islands**: Jersey (St Helier, Mont Orgueil, Elizabeth Castle and its causeway, the Jersey cow, Jersey
   Royals, the German Occupation tunnels, Durrell Wildlife Park) and Guernsey (St Peter Port, Castle Cornet, Hauteville
   House where Victor Hugo lived in exile, the Little Chapel, Guernsey cows and gaches) with a nod to Sark (no cars,
   Dark Sky Island) and Alderney. Reached by ferry (`via: "ferry"`) from a new small Poole Quay zone (Poole is a real
   Channel Islands ferry port) that you add to the rail network as a station stop, gated on a sensible story flag
   (e.g. after badge 4; decide and document) with scaled_floor at that point's band; a Jèrriais/Dgèrnésiais word or two,
   glossed. These do go on the world map.

## Screenshots (Linux cloud)
`sudo apt-get install -y xvfb libgl1-mesa-dri` (or without sudo), then:
`xvfb-run -a -s '-screen 0 1280x720x24' $(tools/get_godot.sh) --audio-driver Dummy --rendering-driver opengl3 --path .
-- --quiet-window --shot=/tmp/x.png --shot-delay=8 --boot=<zone>@<x>,<y> --clock=12:00 --weather=clear`, then Read
the PNG. See core/dev_args.gd and ui/dev_menu.gd for switches. If rendering can't work, say so plainly.

## Finish
Tests: tools/test.sh gives 0 SCRIPT ERROR, all pass, "validate: 0 error(s)" (run a full `--import` first). Commit
with trailers `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>` and
`Claude-Session: https://claude.ai/code/session_01ScZErCU1AdyrXuMs3LAqNr`, push your branch, and open a PR against
`polish-3.3` if `gh` is available. Report under 200 words: what you built, files touched outside new files, tests.
