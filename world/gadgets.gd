class_name Gadgets
extends RefCounted
## The small useful things the Timeline of Invention hands you, one an era (see Invention): a Steam Whistle (a free
## sachet's worth of peace, once a day), the Telegraph Office (the bureau de change from anywhere), a Pocket Wireless
## (the nearest sea areas and how long this weather has left), the Reckoner (unread plaques here, and the nearest),
## the Web (where the creatures you've seen but not caught live) and a Field Guide Model (a guess at what you'll meet
## here, learnt only from what you've seen). None of them makes or takes money. Logic only: the Timeline screen
## passes in what it needs, so tests can call these directly.

const WHISTLE_DAY_FLAG := "invent_whistle_day"   # the day_count the whistle last blew (absent: never)
const WHISTLE_STEPS := 100
const WEB_MAX := 6
const GUIDE_TOP := 3

## The Steam Whistle: {ok, text}. Works like a Lavender Sachet (Repel), once per in-game day.
static func whistle(d: GameStateData) -> Dictionary:
	if Repel.active(d):
		return {"ok": false, "text": "No need: something's already keeping them off (%d steps left)." % Repel.steps_left(d)}
	var last: Variant = d.flag(WHISTLE_DAY_FLAG)
	if typeof(last) in [TYPE_INT, TYPE_FLOAT] and int(last) == d.day_count:
		return {"ok": false, "text": "The boiler's cold. It'll have a head of steam again tomorrow."}
	d.set_flag(WHISTLE_DAY_FLAG, d.day_count)
	d.set_flag(Repel.FLAG, WHISTLE_STEPS)
	return {"ok": true, "text": "PEEEEP! Every weaker wild creature for a mile decides it has somewhere else to be. Good for %d steps." % WHISTLE_STEPS}

## Where a zone sits on the world map: its own spot, or its town's for a room. (-1, -1) if nowhere (abroad).
static func map_pos(zone_id: String, idx: Dictionary) -> Vector2:
	var zones: Dictionary = idx.get("zones", {})
	var id: String = idx.get("room_town", {}).get(zone_id, zone_id)
	if zones.has(id):
		return zones[id].pos
	return Vector2(-1, -1)

## The sea areas nearest a map position, nearest first (`areas`: area -> stand-in zone; `idx` as ZoneIndex).
static func nearest_areas(pos: Vector2, areas: Dictionary, idx: Dictionary, n := 3) -> Array:
	var scored := []
	for a in areas:
		var p := map_pos(str(areas[a]), idx)
		if p.x >= 0:
			scored.append([pos.distance_squared_to(p), str(a)])
	scored.sort_custom(func(x, y): return x[0] < y[0] or (x[0] == y[0] and x[1] < y[1]))
	return scored.slice(0, n).map(func(s): return s[1])

## The Pocket Wireless: the nearest sea area gets the real weather, the next two what's coming their way today, then
## the outlook. `tables`: {area: weather table} for the other areas; `outlook`: Forecast.outlook's lines.
static func wireless_lines(pos: Vector2, actual: String, day: int, idx: Dictionary, tables_of: Callable, outlook: Array) -> Array:
	if pos.x < 0:
		return ["Nothing but hiss: the longwave doesn't reach this far."] + outlook
	var areas := nearest_areas(pos, Forecast.AREAS, idx)
	if areas.is_empty():
		return ["Static."] + outlook
	var out := [Forecast.area_line(str(areas[0]), actual, day)]
	for i in range(1, areas.size()):
		var a := str(areas[i])
		var u := float(absi(hash("%s#%d" % [a, day])) % 10000) / 10000.0
		out.append(Forecast.area_line(a, Forecast.pick(tables_of.call(a), u), day))
	return out + outlook

## Compass word for a step from `a` to `b` on the map grid (y grows southward).
static func compass(a: Vector2i, b: Vector2i) -> String:
	var dx := b.x - a.x
	var dy := b.y - a.y
	if dx == 0 and dy == 0:
		return "right here"
	var ns := "north" if dy < 0 else "south"
	var ew := "west" if dx < 0 else "east"
	if absi(dy) > 2 * absi(dx):
		return ns
	if absi(dx) > 2 * absi(dy):
		return ew
	return ns + "-" + ew

## The Reckoner: lines about the plaques of the place you're in (a town with its rooms, or a route) that you haven't
## read. `plaques`: Gazetteer rows ({id, zone, x, y, town}); `read`: id -> bool.
static func reckoner_lines(zone_id: String, pos: Vector2i, plaques: Array, read: Callable, room_town: Dictionary) -> Array:
	var place: String = room_town.get(zone_id, zone_id)
	var here := plaques.filter(func(p): return str(p.town) == place)
	if here.is_empty():
		return ["The Reckoner clicks and whirs. No plaques round here at all. Restful."]
	var unread := here.filter(func(p): return not read.call(str(p.id)))
	if unread.is_empty():
		return ["All %d plaque%s round here read. The Reckoner prints a tiny gold star." % [here.size(), "" if here.size() == 1 else "s"]]
	var out := ["%d of %d plaque%s round here still unread." % [unread.size(), here.size(), "" if here.size() == 1 else "s"]]
	var same := unread.filter(func(p): return str(p.zone) == zone_id)
	if not same.is_empty():
		same.sort_custom(func(a, b): return pos.distance_squared_to(Vector2i(int(a.x), int(a.y))) < pos.distance_squared_to(Vector2i(int(b.x), int(b.y))))
		var p: Dictionary = same[0]
		var t := Vector2i(int(p.x), int(p.y))
		out.append("Nearest: %d steps %s of you." % [absi(t.x - pos.x) + absi(t.y - pos.y), compass(pos, t)])
	else:
		out.append("None in this spot: try %s." % ("the streets outside" if zone_id != place else "the rooms indoors"))
	return out

## The Web: for species seen but not caught (in `order`), where they're said to live. `idx` as ZoneIndex;
## `name_of` gives a species' name. At most WEB_MAX lines, then a count of the rest.
static func web_lines(d: GameStateData, order: Array, idx: Dictionary, name_of: Callable) -> Array:
	var wanted := order.filter(func(s): return d.seen.has(s) and not d.caught.has(s))
	if wanted.is_empty():
		return ["Search results: 0. Everything you've seen, you've caught. The web has nothing to add, for once."]
	var homes := {}
	for zid in idx.get("zones", {}):
		var z: Dictionary = idx.zones[zid]
		for e in z.get("enc", []):
			var s := str(e.species)
			if s in wanted:
				if not homes.has(s):
					homes[s] = []
				if str(z.name) not in homes[s]:
					homes[s].append(str(z.name))
	var out := []
	for s in wanted:
		if out.size() >= WEB_MAX:
			break
		var places: Array = homes.get(s, [])
		places.sort()
		var where := ", ".join(PackedStringArray(places.slice(0, 3))) if not places.is_empty() else "nobody online seems to know"
		out.append("%s: %s%s" % [name_of.call(s), where, "" if places.size() <= 3 else ", and more"])
	if wanted.size() > WEB_MAX:
		out.append("And %d more. Page 2 of the results, which nobody ever reads." % (wanted.size() - WEB_MAX))
	return out

## The Field Guide Model: from this zone's wild candidates right now ({species, weight} entries), the shares of each,
## naming only species you've seen. It cannot name what it has never been shown. {lines, top: [[species, pct]]}.
static func guide(d: GameStateData, candidates: Array, name_of: Callable) -> Dictionary:
	if candidates.is_empty():
		return {"lines": ["Nothing wild lives here at this hour, it reckons. It may be right.", "(It has learnt only from what you've seen. That's all it knows.)"], "top": []}
	var total := 0.0
	var by := {}
	for e in candidates:
		var w := maxf(0.0, float(e.get("weight", 1)))
		total += w
		var s := str(e.species)
		by[s] = float(by.get(s, 0.0)) + w
	var known := []
	var unknown := 0.0
	for s in by:
		if d.seen.has(s):
			known.append([s, by[s] / total * 100.0])
		else:
			unknown += by[s] / total * 100.0
	known.sort_custom(func(a, b): return a[1] > b[1] or (a[1] == b[1] and a[0] < b[0]))
	var top := known.slice(0, GUIDE_TOP)
	var lines := []
	for t in top:
		lines.append("%s: %d per cent" % [name_of.call(t[0]), roundi(t[1])])
	if unknown >= 1.0:
		lines.append("Something it has never seen: %d per cent. It can't name what it was never shown." % roundi(unknown))
	if top.is_empty():
		lines.append("It has no idea. You haven't shown it anything from round here yet.")
	lines.append("A guess from patterns, not a promise. The weather, the hour and luck all get a vote.")
	return {"lines": lines, "top": top}
