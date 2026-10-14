# Plan 3 zone brief (for zone-building agents)

Read this with plan 3 Task 9 (`docs/superpowers/plans/2026-10-14-plan-3-north-and-wales.md`). It is the binding contract between the zone agents, the cast agent and the story agent.

## Tools

- Author zones with Python scripts in `tools/zones/` using `zlib.py` (`Z` class: `rect`, `height`, `set`, `border`, `scatter`, `building`, `warp`, `prop`, `sign`, `npc`, `save`; plus `sanctuary(...)` and `shop(...)` interior templates). Study `tools/zones/routes.py` and `tools/zones/macclesfield.py` first, and `data/zones/macclesfield.json`, `buxton.json`, `macc_forest.json`, `cat_and_fiddle.json` for density and style. One script per group, e.g. `tools/zones/england_north.py`, run as `python3 tools/zones/<script>.py tools/zones data/zones`.
- Tile chars (`data_api/zone_data.gd` LEGEND): `.` grass, `,` tall grass (encounters), `#` path, `=` road, `:` cobbles, `s` sand, `f` flowers, `~` water, `w` shallow (walkable), `T` oak, `P` pine, `H` hedge, `W` drystone wall, `F` fence, `R` rock, `^` cliff, `B` building (must be under a building prop), `D` door, `x` void, `|` wood floor, `+` tile floor, `C` counter, `L` ledge (hop south only), `%` bramble (Hedge-lay), `o` deep water (Brook-wade; uses the `"water"` encounter table), `/` scree (Fell-scramble), `_` platform (walkable), `!` rail track, `$` open sea. Per-zone custom chars via `legend_extra` (see cat_and_fiddle: `{"tile": "tall_grass", "colour": "#6e5a5c", "prop": "heather"}`).
- Heights: `z.height(x, y, w, h, level)` levels 0..6; neighbours more than 1 level apart block movement, so use paths or ramps of single steps.
- Building styles: `red_brick`, `stone`, `white_render`, `gritstone`, `cream_render`, `sanctuary`, `shop`, and the M2 specials `mill`, `terrace`, `tudor`, `slate_cottage`, `chapel`, `castle`, `cathedral`, `liver_building`, `station`, `aqueduct`. `building(x, y, w, h, style, label, door=<column>)` returns the door tile. The station's canopy overhangs one tile south, so put a row of `_` platform under it and `!` rail south of that.
- Point props (`prop(type, x, y, variant=, rot=)`, they block the tile): `lamp_post`, `bench`, `bush`, `birch`, `oak`, `pine`, `rock`, `market_stall`, `planter`, `phone_box`, `post_box`, `bookshelf`, `potted_plant`, `table`, `bed`, `standing_stone`, `slate_heap`, `boat` (variant 0 ferry, 1 fishing boat; on water), `canal_boat` (on water), `bollard`, `buoy` (on water), `lighthouse`, `statue`, `harp`.
- See every mesh in the dev zone: `godot --path . -- --boot=mesh_gallery@20,15 --clock=12:00 --shot=/tmp/x.png --shot-delay=4` (find godot with `tools/get_godot.sh`, which prints its path). Screenshot any zone the same way with `--boot=<zone>@<x>,<y>`, then Read the PNG. The camera shows roughly 30 x 17 tiles around the player.

## Zone keys

- `id`, `name`, `region` (`peak`, `manchester`, `merseyside`, `cheshire`, `man`, `north_wales`, `mid_wales`, `south_wales`), `kind` (`town`, `route`, `interior`), `music`, `weather` (weights over `clear`, `drizzle`, `downpour`, `fog`, `gale`, `frost`, `sunshine`), `spawn`.
- `stage`: battle diorama: `town`, `city`, `docks`, `coast`, `bog`, `mountain`, `quarry`, `cave`, `castle`, `valley`, `forest`, `moor`, `grass`, `spa_interior`. Set it on every new zone.
- Towns: `town_id` (= the zone id), a `station` building, `"station": {"x": .., "y": ..}` = a walkable platform tile, and a rail guard NPC beside it: `{"id": "rail_guard", "sprite": "rail_guard", "script": "rail_guard", ...}` whose script is a line of dialogue then `{"do": "rail"}`.
- Liverpool and Douglas: `"ferry": {"x": .., "y": .., "route": "liverpool_douglas"}` = a walkable quay tile, plus a sailor NPC (`sprite` `sailor`, script ends with `{"do": "ferry", "route": "liverpool_douglas"}`).
- Music ids: `town_cheshire`, `town_city`, `town_wales`, `route_forest`, `route_moor`, `route_coast`, `route_mountain`, `sanctuary`, `battle_keeper`, `legend`.
- Encounters: `{"grass": [...], "water": [...]}`; entry `{"species", "min", "max", "weight", "time": [dawn|day|dusk|night], "weather": [...]}` (time and weather optional). Only species that exist in `data/creatures/`. Wild levels follow plan 3 Task 8's curve.
- Gates: a warp or edge only reachable through bramble, deep water or scree gets `"gate": "hedge_lay" | "brook_wade" | "fell_scramble"`. The validator checks every warp and edge is reachable from the spawn (with only its gate's ability) and that every reachable border tile lands on a walkable tile in the next zone.

## Interiors and NPCs

- Every town gets a Sanctuary and a Corner Shop building in town (styles `sanctuary`, `shop`, labelled) whose door tiles warp to `<town>_sanctuary` (arrive 5,6 facing up) and `<town>_shop` (arrive 4,5 facing up); build the interiors with `sanctuary(OUT, town, name, ret)` and `shop(OUT, town, name, ret)`, where `ret` is the town tile just south of that door. Write `data/dialogue/<town>_sanctuary.json` (script `nurse`, copy the structure of `data/dialogue/macc_sanctuary.json` including the Ark choice, new witty lines) and `data/dialogue/<town>_shop.json` (script `shopkeeper`, with `{"do": "shop", "id": "<town>_corner_shop"}`; the shops exist in `data/shops/`).
- NPC: `{"id", "sprite", "x", "y", "facing", "move": "still"|"wander"|"pace", "script"}` or with `"trainer": "<id>"` instead of a script. Optional `"name"`, `"hide_if": flag`, `"show_if": flag`. Scripts live in `data/dialogue/<zone>.json` keyed by script id. Every town and route has at least 4 chatty NPCs with local colour and one real fact each about the place (written for age 11+, witty, never grim).
- Ordinary trainers: write them yourself in `data/trainers/<id>.json` (schema: `data/trainers/gwen.json`), 3 to 5 per route, 2 juniors in each Keeper arena; trainer NPCs face along a corridor the player must pass. Classes: Hiker, Birdwatcher, Angler, Jogger, Student, Fell Runner, Choir Singer, Surfer, Dog Walker, Rugby Player, Busker, Warden (Enclosure grunt: class "Warden", sprite `warden_grunt`, smug comedy lines about "curating" the countryside).
- Sprites you may use now: `player_a`, `player_b`, `prof_garside`, `kit`, `keeper_maud`, `mum`, `villager_1` to `villager_6`, `sanctuary_nurse`, `shopkeeper`, `hiker`, `birdwatcher`, `angler`, `jogger`, `warden_grunt`. Sprites the cast agent is making (use these ids where they fit; until made they show a placeholder): `rail_guard`, `sailor`, `bev`, `vane`, `pryce`, `keeper_ray`, `keeper_eluned`, `keeper_rhys`, `dr_hughes`, `harpist`, `tour_guide`, `student`, `farmer`, `choir_singer`, `surfer`, `rugby_player`.
- Story NPCs: place them with the script id given and write a one-line placeholder script; the story agent rewrites those scripts and may add flags. Do not write Keeper, Kit, Pryce or Vane trainer files; the cast agent does.

## Cross-agent seams (must match exactly)

- Buxton (existing, `data/zones/buxton.json`): edit the JSON directly. Open a 3-tile gap in its north border at columns 26, 27, 28 (path tiles down to the town's paths) and add `"north": {"to": "goyt_valley", "offset": 0}`. Do not regenerate buxton from `routes.py` (it would lose NPCs).
- Goyt Valley's south border gap must be at columns 26-28 too (offset 0 means same x).
- Chester west edge to Dee Valley east edge: open rows 18, 19, 20 on both borders (both zones at least 26 tall), offset 0.
- Llanberis south edge to Cambrian Coast north edge: open columns 24, 25, 26 on both (both at least 34 wide), offset 0.
- All other connections are inside one agent's group: pick freely, keep the gaps 3 wide and aligned.
