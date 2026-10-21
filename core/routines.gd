class_name Routines
extends RefCounted
## Weekly routines for townsfolk who opt in with a `"routine"` list on their NPC def (pure data, no pathfinding):
## [{"days": [0..6, 0 = Sunday], "from": "HH:MM", "to": "HH:MM", "seasons": ["summer"], "x": 5, "y": 7, "facing": "up"}]
## The first slot that fits the weekday, hour and season says where they are; none fits and they stand at their
## usual spot. Slots only move someone within their own zone. `days` and `seasons` are optional. `to` is exclusive and
## may be earlier than `from` (a slot that runs past midnight). Pure; nothing in here names an autoload.

const DAYS := [0, 1, 2, 3, 4, 5, 6]

## The slot in force, or {} (stay put).
static func slot(d: Dictionary, weekday: int, season: String, minutes: int) -> Dictionary:
	for s in d.get("routine", []):
		if s is Dictionary and _fits(s, weekday, season, GameClock.wrap(minutes)):
			return s
	return {}

static func _fits(s: Dictionary, weekday: int, season: String, m: int) -> bool:
	if s.has("days") and weekday not in s.days:
		return false
	if s.has("seasons") and season not in s.seasons:
		return false
	var a := GameClock.parse(str(s.get("from", "00:00")))
	var b := GameClock.parse(str(s.get("to", "00:00")))
	if a == b:
		return true  # the whole day
	return (m >= a and m < b) if a < b else (m >= a or m < b)

## Where and which way they stand: the def itself, or a copy moved to the slot in force.
static func placed(d: Dictionary, weekday: int, season: String, minutes: int) -> Dictionary:
	if not d.has("routine"):
		return d
	var s := slot(d, weekday, season, minutes)
	if s.is_empty():
		return d
	var out := d.duplicate()
	out["x"] = int(s.x)
	out["y"] = int(s.y)
	if s.has("facing"):
		out["facing"] = s.facing
	return out

## Changes whenever anyone's routine could have moved them (cheap to compare: the overworld asks once a second).
static func stamp(weekday: int, season: String, minutes: int) -> String:
	return "%d%s%d" % [weekday, season, GameClock.wrap(minutes) / 30]

## Problems with a routine, for the validator. `blocked` holds tiles routine people may not stand on (doors and the
## tile in front of each, other people's spots).
static func errors(d: Dictionary, z: ZoneData, blocked: Dictionary) -> Array:
	var out := []
	var r = d.get("routine")
	if not r is Array or r.is_empty():
		return ["routine must be a list of slots"]
	for i in r.size():
		var s = r[i]
		if not s is Dictionary or not s.has("x") or not s.has("y"):
			out.append("routine slot %d needs x and y" % i)
			continue
		var p := Vector2i(int(s.x), int(s.y))
		if not z.walkable(p) or z.is_gap(p):
			out.append("routine slot %d: %s is not a plain walkable tile" % [i, p])
		elif blocked.has(p):
			out.append("routine slot %d: %s blocks a door or someone's spot" % [i, p])
		for key in ["from", "to"]:
			if s.has(key) and GameClock.parse(str(s[key])) < 0:
				out.append("routine slot %d: bad %s" % [i, key])
		for day in s.get("days", []):
			if int(day) not in DAYS:
				out.append("routine slot %d: bad day %s" % [i, day])
		for se in s.get("seasons", []):
			if str(se) not in ["spring", "summer", "autumn", "winter"]:
				out.append("routine slot %d: bad season %s" % [i, se])
	return out

## Tiles a routine may not use in a zone: every warp, its four neighbours, and every NPC's own spot.
static func blocked_tiles(z: ZoneData) -> Dictionary:
	var out := {}
	for w in z.warps:
		var p := Vector2i(int(w.x), int(w.y))
		out[p] = true
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			out[p + dir] = true
	for n in z.npcs:
		out[Vector2i(int(n.get("x", 0)), int(n.get("y", 0)))] = true
	return out

## The same, without the NPC's own usual spot (their slots may share it).
static func blocked_tiles_except(z: ZoneData, d: Dictionary) -> Dictionary:
	var out := blocked_tiles(z)
	var own := Vector2i(int(d.get("x", 0)), int(d.get("y", 0)))
	var w_near := false
	for w in z.warps:
		if absi(int(w.x) - own.x) + absi(int(w.y) - own.y) <= 1:
			w_near = true
	if not w_near:
		out.erase(own)
	return out
