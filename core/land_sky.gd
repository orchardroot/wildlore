class_name LandSky
extends RefCounted
## Land and Sky (4.5): the geology, weather and climate ideas the game teaches, one row each on an Almanac page
## that fills as you meet them. Nothing is stored for the page itself: an idea counts as met once any of the flags
## listed for it in data/land_sky.json is set (a plaque read, a line an NPC set, a rewilding stage reached), so old
## saves simply show what they have already done. Pure logic, no autoload names.

const PATH := "res://data/land_sky.json"

static var _db: Dictionary = {}

static func _all() -> Dictionary:
	if _db.is_empty():
		var d = JsonUtil.read(PATH)
		_db = d if d is Dictionary else {"ideas": []}
	return _db

static func ideas() -> Array:
	return _all().get("ideas", [])

static func idea(id: String) -> Dictionary:
	for i in ideas():
		if str(i.get("id", "")) == id:
			return i
	return {}

## A flag counts when it is true, a non-zero number or a non-empty string (rewilding stages are ints).
static func _on(d: GameStateData, key: String) -> bool:
	var v: Variant = d.flag(key)
	match typeof(v):
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return false

static func met(d: GameStateData, i: Dictionary) -> bool:
	for f in i.get("flags", []):
		if _on(d, str(f)):
			return true
	return false

static func met_count(d: GameStateData) -> int:
	return ideas().filter(func(i): return met(d, i)).size()

## The Almanac rows [title, note]: the ideas met, in the data's order, or one line saying nothing is noted yet.
static func rows(d: GameStateData) -> Array:
	var out := []
	for i in ideas():
		if met(d, i):
			out.append([str(i.get("title", "")), str(i.get("note", ""))])
	if out.is_empty():
		out.append(["Nothing noted yet", "Read the plaques by the rocks, and ask the people who watch the sky"])
	return out

static func blurb(d: GameStateData) -> String:
	return "%d of %d ideas met" % [met_count(d), ideas().size()]

## Problems with data/land_sky.json: ids unique, a title, a note and at least one flag each, no em-dashes.
## `settable` (Quests.all_settable, plus anything the caller knows) says which flags the game can set at all.
static func check(settable: Dictionary = {}) -> Array:
	var e := []
	var ids := {}
	for i in ideas():
		var id := str(i.get("id", ""))
		var tag := "land_sky: idea '%s'" % id
		if id == "":
			e.append("land_sky: an idea has no id")
		elif ids.has(id):
			e.append(tag + " twice")
		ids[id] = true
		for k in ["title", "note"]:
			if str(i.get(k, "")).strip_edges() == "":
				e.append(tag + " has no %s" % k)
			if "—" in str(i.get(k, "")):
				e.append(tag + " has an em-dash in %s" % k)
		var flags: Array = i.get("flags", [])
		if flags.is_empty():
			e.append(tag + " has no flags")
		if not settable.is_empty():
			for f in flags:
				if not settable.has(str(f)):
					e.append(tag + ": nothing sets '%s'" % f)
	return e
