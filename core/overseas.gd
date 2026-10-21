class_name Overseas
extends RefCounted
## The registry of British Overseas Territories (and Crown Dependencies reached by sea): one file per place in
## data/overseas/<id>.json, written by whoever builds the territory:
##   {"id", "name", "arrival": {"zone", "x", "y"}, "via": "raf" | "ferry", "port": <UK port zone for ferries>,
##    "unlock_flag": "champion", "blurb": "One line for the departures board.", "flight_line": "What the pilot says."}
## RAF Brize Norton's departures board lists every file whose unlock flag is set; a territory's airfield or harbour
## brings you home to Brize Norton (or the ferry port). Pure data (no autoloads), so tests and the validator use it.

const DIR := "res://data/overseas"
const HUB := "brize_norton"
const REQUIRED := ["id", "name", "arrival", "via", "unlock_flag", "blurb", "flight_line"]

static var _cache: Array = []

## Every registry entry, sorted by name. Unreadable files are skipped (validate() reports them).
static func all() -> Array:
	if _cache.is_empty():
		var out := []
		for f in DirAccess.get_files_at(DIR):
			if f.ends_with(".json"):
				var d = JsonUtil.read(DIR + "/" + f)
				if d is Dictionary and str(d.get("id", "")) != "":
					out.append(d)
		out.sort_custom(func(a, b): return str(a.name) < str(b.name))
		_cache = out
	return _cache

static func reset() -> void:
	_cache = []

static func get_entry(id: String) -> Dictionary:
	for e in all():
		if str(e.id) == id:
			return e
	return {}

static func name_of(id: String) -> String:
	var e := get_entry(id)
	return str(e.get("name", "")) if not e.is_empty() else ""

static func is_ferry(e: Dictionary) -> bool:
	return str(e.get("via", "raf")) == "ferry"

## Entries whose unlock flag is set, for the departures board.
static func available(data: GameStateData) -> Array:
	var out := []
	for e in all():
		if data.flag(str(e.get("unlock_flag", "champion"))) == true:
			out.append(e)
	return out

## {zone, pos}: where a trip to this territory lands.
static func arrival(e: Dictionary) -> Dictionary:
	var a: Dictionary = e.get("arrival", {})
	return {"zone": str(a.get("zone", "")), "pos": Vector2i(int(a.get("x", 0)), int(a.get("y", 0)))}

## {zone, pos}: where "coming home" lands: Brize Norton's apron for flights, the UK port's quay for ferries.
static func home(e: Dictionary) -> Dictionary:
	if is_ferry(e):
		var port := str(e.get("port", ""))
		var z := ZoneData.load_id(port)
		var fp := Vector2i(int(z.ferry.get("x", -1)), int(z.ferry.get("y", -1)))
		return {"zone": port, "pos": fp if fp.x >= 0 else z.spawn}
	var h := ZoneData.load_id(HUB)
	return {"zone": HUB, "pos": Vector2i(int(h.spawn.x), int(h.spawn.y))}

## Problems with the registry, for the validator and tests.
static func validate(zone_exists: Callable) -> Array:
	var errors := []
	var seen := {}
	for e in all():
		var id := str(e.id)
		for k in REQUIRED:
			if not e.has(k):
				errors.append("overseas %s: missing '%s'" % [id, k])
		if seen.has(id):
			errors.append("overseas %s: duplicate id" % id)
		seen[id] = true
		if str(e.get("via", "")) not in ["raf", "ferry"]:
			errors.append("overseas %s: via must be raf or ferry" % id)
		var a: Dictionary = e.get("arrival", {})
		if not a.has("zone") or not zone_exists.call(str(a.get("zone", ""))):
			errors.append("overseas %s: arrival zone '%s' does not exist" % [id, a.get("zone", "")])
		if is_ferry(e) and not zone_exists.call(str(e.get("port", ""))):
			errors.append("overseas %s: ferry port '%s' does not exist" % [id, e.get("port", "")])
	return errors
