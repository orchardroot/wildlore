class_name MapLogic
extends RefCounted
## What the interactive world map knows: which way the cursor jumps, what the info panel says about a
## town, and whether you can fly there. Pure functions over GameStateData and the data files.

## Town -> [Keeper, Stone id]. The Stones are won in order, one Keeper per town.
const KEEPERS := {
	"buxton": ["Maud", "brook"], "liverpool": ["Ray", "urban"], "llanberis": ["Eluned", "stone"],
	"cardiff": ["Rhys", "storm"], "glastonbury": ["Morwen", "fae"], "dublin": ["Declan", "kin"],
	"galway": ["Nuala", "tide"], "belfast": ["Ruairi", "iron"], "inverness": ["Isla", "frost"],
	"york": ["Hester", "spirit"],
}
## Towns whose corner shop file uses a short name.
const SHOP_ALIAS := {"macclesfield": "macc"}

const DIRS := {"left": Vector2(-1, 0), "right": Vector2(1, 0), "up": Vector2(0, -1), "down": Vector2(0, 1)}

## The town the cursor jumps to from `from` going `dir` (a unit vector in map space, y down), or "".
## `cands` is town id -> map position. Prefers a town roughly straight ahead (within 60 degrees), nearer
## and more on-line the better; failing that, anything at all on that side.
static func nearest(from: Vector2, cands: Dictionary, dir: Vector2, exclude := "") -> String:
	var best := ""
	var best_score := INF
	for pass_no in 2:
		for id in cands:
			if id == exclude:
				continue
			var d: Vector2 = cands[id] - from
			var dist := d.length()
			var along := d.dot(dir)
			if dist < 0.001 or along <= 0.0:
				continue
			if pass_no == 0 and along / dist < 0.5:
				continue
			var score := dist + absf(d.cross(dir)) * 1.5
			if score < best_score:
				best_score = score
				best = id
		if best != "":
			break
	return best

## Towns that exist in the game (they have a zone file).
static func real_towns() -> Array:
	var out := []
	for t in Travel.world_map().get("towns", {}):
		if FileAccess.file_exists("res://data/zones/%s.json" % t):
			out.append(t)
	return out

static func visited(data: GameStateData, town: String) -> bool:
	return data.flag("visited_" + town) == true

## Map position of every visited town: the cursor's stepping stones.
static func visited_positions(data: GameStateData) -> Dictionary:
	var out := {}
	var towns: Dictionary = Travel.world_map().get("towns", {})
	for t in real_towns():
		if visited(data, t):
			out[t] = Vector2(float(towns[t].x), float(towns[t].y))
	return out

## Where the cursor starts: your current town if you have been there, else any visited town, else "".
static func start_town(data: GameStateData) -> String:
	var here = data.flag("last_town")
	var pos := visited_positions(data)
	if here and pos.has(str(here)):
		return str(here)
	for t in pos:
		return t
	return ""

## Unvisited towns that still get a name on the map: the one "Where next?" is pointing at.
static func named_unvisited(data: GameStateData, objective_town: String) -> Array:
	return [objective_town] if objective_town != "" and not visited(data, objective_town) else []

## Species that live on the wild routes next to a town, in first-seen order.
static func nearby_species(town: String) -> Array:
	var out := []
	var z := ZoneData.load_id(town)
	for dir in z.edges:
		var r := ZoneData.load_id(str(z.edges[dir].get("to", "")))
		if r.kind == "town" or r.kind == "interior":
			continue
		for kind in r.encounters:
			for e in r.encounters[kind]:
				var sp := str(e.get("species", ""))
				if sp != "" and sp not in out:
					out.append(sp)
	return out

static func has_shop(town: String) -> bool:
	return FileAccess.file_exists("res://data/shops/%s_corner_shop.json" % SHOP_ALIAS.get(town, town))

## Everything the info panel shows about a visited town.
static func info(data: GameStateData, town: String) -> Dictionary:
	var out := {"town": town, "name": Travel.town_name(town), "keeper": {}, "sanctuary": false, "shop": false,
		"station": false, "ferries": [], "found": 0, "nearby": 0, "rooms": 0, "rooms_seen": 0}
	if KEEPERS.has(town):
		var k: Array = KEEPERS[town]
		out.keeper = {"name": k[0], "stone": str(k[1]).capitalize() + " Stone",
			"won": data.flag("badge_" + str(k[1])) == true or str(k[1]) in data.badges}
	out.sanctuary = FileAccess.file_exists("res://data/zones/%s_sanctuary.json" % SHOP_ALIAS.get(town, town))
	out.shop = has_shop(town)
	out.station = data.flag(Travel.station_flag(town)) == true
	var fer: Dictionary = Travel.ferries()
	for route in fer:
		var r: Dictionary = fer[route]
		if str(r.a) == town or str(r.b) == town:
			out.ferries.append(Travel.town_name(str(r.b) if str(r.a) == town else str(r.a)))
	var near := nearby_species(town)
	out.nearby = near.size()
	for sp in near:
		if data.caught.has(sp):
			out.found += 1
	var rooms := VisitorsBook.count(data, town, ZoneIndex.get_index())
	out.rooms_seen = rooms.x
	out.rooms = rooms.y
	var nation := Standing.nation_for_zone(town)
	out["standing"] = "%s in %s" % [Standing.tier_name(data, nation), Standing.name_of(nation)]
	return out

## The panel's lines, top to bottom.
static func info_lines(i: Dictionary) -> Array:
	var out := []
	if not i.keeper.is_empty():
		out.append("Keeper %s: %s %s" % [i.keeper.name, i.keeper.stone, "won" if i.keeper.won else "not yet won"])
	out.append("Sanctuary: " + ("yes" if i.sanctuary else "none"))
	out.append("Corner Shop: " + ("yes" if i.shop else "none"))
	out.append("Station: " + ("yes" if i.station else "not found yet"))
	out.append("Ferry: " + (", ".join(i.ferries) if not i.ferries.is_empty() else "none"))
	if i.nearby > 0:
		out.append("Fieldbook nearby: %d of %d found" % [i.found, i.nearby])
	else:
		out.append("Fieldbook nearby: no wild routes")
	if i.get("rooms", 0) > 0:
		out.append("Rooms visited: %d of %d%s" % [i.rooms_seen, i.rooms, "  (the full tour!)" if i.rooms_seen >= i.rooms else ""])
	if i.has("standing"):
		out.append("Standing: " + str(i.standing))
	return out

## After the Champion, a visited town other than the one you are standing in is a flight away.
static func can_fly_to(data: GameStateData, here: String, town: String) -> bool:
	return data.flag("champion") == true and town in Travel.fly_destinations(data, here)
