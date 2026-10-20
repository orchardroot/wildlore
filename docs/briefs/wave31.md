# Wildlore 3.1 "Seasons & Streets", wave 31

The owner (2026-10-20) asked for five features. Six agents build them in parallel, one feature (or half of one) each.
Read docs/briefs/qol_common.md first (in the main checkout ~/Projects/wildlore if your worktree lacks it); it binds
you, with these overrides: BASE is `origin/main` (3.0.0). The game is rated 16+ (mild adult jokes fine). Warm, wry
British humour; UK English (Irish English in Ireland, a little Welsh/Gaelic/Scots where natural, always glossed);
NO em-dashes in player-facing text. Accurate facts only: if unsure, leave it out. 60 fps on a 2013 iMac.

Much of the groundwork exists. READ before building, and EXTEND rather than replace:
- core/calendar.gd (real-date seasons and festivals, `--date=MM-DD` dev switch), world/seasonal.gd (festival dressing)
- core/crafting.gd + data/recipes.json (bench recipes, regional food), data/items/*.json, core/rules.gd
- world/home_base.gd, world/home_garden.gd, world/home_meshes.gd, data/zones/macc_home.json (trophy shelf, garden, visitors)
- per-zone weather tables (grep "weather" in data/zones and world/), world/sky_and_light.gd, world/forecast.gd
- world/landmarks.gd (building styles; pattern for a split-out file: world/landmarks_valleys.gd + 4 small hooks)
- story/commands.gd + data_api/story_validator.gd (story commands and `when` conditions), core/game_state_data.gd (save)

Shared hot files (landmarks.gd, commands.gd, story_validator.gd, game_state_data.gd, calendar.gd, rules.gd, battle
code): edit them SMALL and ADDITIVE, put new logic in NEW files. Six branches will be merged, so never reformat or
reorder existing code. Save compatibility is sacred: the owner's save (1 badge, in Liverpool) must load and play.

Time box about 2.5 hours. Ship finished, tested, good-looking pieces. Screenshot with tools/shot.sh and look at
them; the owner called amateur visuals "naff". Run tools/test.sh at the end: 0 SCRIPT ERROR, all pass,
"validate: 0 error(s)". Commit on your branch (don't push). Report briefly (under 200 words): what you built,
files touched outside new files, test counts, branch and commit.

## A. Streets (two agents: A1 England + Wales + Isle of Man, A2 Scotland + Ireland + Northern Ireland)
The 3.0 towns have local architecture; the ORIGINAL towns don't (they share generic buildings). Original towns:
A1: bath birmingham buxton chester glastonbury keswick lancaster liverpool london macclesfield manchester newcastle
nottingham penzance sheffield whitby york aberystwyth cardiff holyhead llanberis llangollen st_davids douglas
A2: aberdeen cairnryan edinburgh fort_william glasgow inverness kirkwall portree belfast bushmills derry cork dingle
dublin galway kilkenny newgrange sligo
Give each a local look: materials and colours (Bath stone, Manchester red brick and mills, York timber frames,
Welsh slate, Cornish granite, Aberdeen granite, Edinburgh sandstone tenements, Glasgow red sandstone, Dublin
Georgian doors, colourful Irish shopfronts, Orkney flagstone, Portree's painted harbour), roofs, chimneys, gables,
shopfronts, street furniture. Prefer palette/variant parameters on existing house styles plus a few new styles in a
NEW file (world/landmarks_<yours>.gd, hooks like the valleys pattern) over editing each zone's props by hand; where
you do edit zone props, change `style` values only, never move buildings, doors or warps. Screenshot every town
before and after. A1 file: world/landmarks_streets_ew.gd; A2: world/landmarks_streets_si.gd.

## B. Festivals and events
Turn the calendar's festivals into things to DO, not just decorations: a short quest or event for each of at least
8 real occasions across the four nations (e.g. Bonfire Night, Hogmanay, Burns Night, St David's Day, St Patrick's
Day, Up Helly Aa in Kirkwall/Lerwick if reachable, Notting Hill Carnival in London, the Edinburgh Fringe, Cooper's
Hill cheese-rolling, Lá Bealtaine/Beltane, Halloween/Samhain, Christmas, a well dressing in the Peak). Each:
an NPC/event in a fitting town active only in its date window (Calendar), a quest entry in data/quests/festivals.json
(same contract as other quest files; flags `q_festivals_*`, keyed per year where repeatable), a reward (item, coat,
costume or money) and something seasonal to catch where it fits (a limited-time spawn via existing encounter data).
Also a "What's on" line somewhere visible (noticeboard or the radio) listing upcoming events. Test with --date.

## C. Regional cooking
Extend Crafting into cooking: 20+ regional dishes (Lancashire hotpot, scouse, cawl, Welsh cakes, bara brith,
Cullen skink, haggis neeps and tatties, cranachan, Irish stew, soda bread, boxty, Ulster fry, champ, Cornish pasty,
Yorkshire pudding, Eccles cake, Bakewell pudding, Arbroath smokie, Stottie cake, Glamorgan sausage...) cooked from
ingredients (existing materials, regional items, shop-bought basics). Dishes give a meaningful effect: heal plus a
short buff for the next battle or a timed overworld effect (more encounters of a type, better catch, extra money),
documented on the item. Recipes are learned from locals in the right region (dialogue sets recipe_<id>). A cooking
spot: Mum's kitchen at home plus a hob in some pubs/cafes. Keep it balanced (buffs modest, not stackable).

## D. Home and garden
Extend Mum's house (HomeBase): a souvenir system (buy or earn one souvenir per region: a stick of Blackpool rock,
a Welsh lovespoon, a Toby jug from Stoke, a Claddagh ring, a Viking helmet from York...) that you can place on
shelves/spots in the house; framed plaques (the Gazetteer: show how many plaques read per nation as framed boards
on the wall); a bigger garden with a bird table/bug hotel/pond that attracts specific visiting creatures you can
catch or befriend there (rotating by season). Save-safe new fields. Make the house feel like YOUR place.

## E. Weather that matters
Make weather mechanical, using the existing per-zone weather: (1) encounter tables shift with weather (rain brings
water/amphibian types, fog brings ghostly/fae, snow ice, sun bugs and birds; reuse species already in each zone's
region, e.g. a weather-only bonus list per region or per zone kind), (2) battles: weather started from the overworld
boosts matching move types modestly (e.g. +20% water in rain, ice in snow, fire in sun; fog lowers accuracy a little)
shown with a clear battle message and icon, (3) the forecast/radio tells you what's coming. Visuals already exist?
check sky_and_light and add tasteful rain/fog/snow particles if missing (cheap CPUParticles). Keep it fair: no
weather in interiors or underground; trainers' key fights unaffected unless they're outdoors (decide and document).
