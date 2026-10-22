class_name TheseIsles
extends RefCounted
## These Isles: a Gazetteer page on the many peoples who made these isles, from the Celts and Romans to Windrush and
## Ireland's new communities. data/these_isles.json lists the themes and the people you can meet. A theme gathers:
##   plaques   any Gazetteer plaque whose sign carries "people": <theme id> (read = plaque_<id>, see Gazetteer)
##   people    NPCs whose talk sets their `flag` (isles_met_<id>) the first time you chat
##   quests    any quest in data/quests with "people": <theme id> (found = done)
## Nothing new is saved: the page only reads flags old saves already have or lack. Pure logic, no autoload names.

const FILE := "res://data/these_isles.json"

static var _cache: Array = []
static var _file: Dictionary = {}

static func _data() -> Dictionary:
	if _file.is_empty():
		var d = JsonUtil.read(FILE)
		_file = d if d is Dictionary else {"themes": [], "people": []}
	return _file

static func themes() -> Array:
	return _data().get("themes", [])

static func people() -> Array:
	return _data().get("people", [])

## Every theme with its plaques, people and quests, from the real data.
static func all() -> Array:
	if _cache.is_empty():
		_cache = build(themes(), Gazetteer.all(), people(), Quests.all())
	return _cache

static func reset() -> void:
	_cache = []
	_file = {}

## [{id, name, about, items: [{kind, id, title, where, flag}]}]: themes in file order; within one, plaques (in
## Gazetteer order), then people, then quests.
static func build(theme_list: Array, plaques: Array, people_list: Array, quests: Array) -> Array:
	var out := []
	var by := {}
	for t in theme_list:
		var e := {"id": str(t.get("id", "")), "name": str(t.get("name", "")), "about": str(t.get("about", "")), "items": []}
		by[e.id] = e
		out.append(e)
	for p in plaques:
		var th := str(p.get("people", ""))
		if by.has(th):
			by[th].items.append({"kind": "plaque", "id": str(p.id), "title": str(p.title), "where": str(p.get("town_name", "")),
				"flag": Gazetteer.flag_key(str(p.id))})
	for p in people_list:
		var th := str(p.get("theme", ""))
		if by.has(th):
			by[th].items.append({"kind": "person", "id": str(p.get("id", "")), "title": str(p.get("name", "")),
				"where": _place_name(str(p.get("zone", ""))), "flag": str(p.get("flag", "")), "line": str(p.get("line", ""))})
	for q in quests:
		var th := str(q.get("people", ""))
		if by.has(th):
			by[th].items.append({"kind": "quest", "id": str(q.get("id", "")), "title": str(q.get("title", "")),
				"where": _place_name(str(q.get("town", ""))), "flag": str(q.get("done_flag", ""))})
	return out

static func _place_name(zone: String) -> String:
	var zi: Dictionary = ZoneIndex.get_index().get("zones", {})
	var town := str(ZoneIndex.get_index().get("room_town", {}).get(zone, zone))
	return str(zi.get(town, {}).get("name", town.capitalize()))

## Found: a plaque read, a person met, a quest done. All three are a flag being set.
static func is_found(d: GameStateData, item: Dictionary) -> bool:
	var v: Variant = d.flag(str(item.get("flag", "")))
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return true

## The entries with counts: each theme gains found and total, and each item found.
static func tally(d: GameStateData, entries: Array = []) -> Array:
	var out := []
	for t in (entries if not entries.is_empty() else all()):
		var e: Dictionary = t.duplicate()
		var items := []
		var n := 0
		for it in t.items:
			var c: Dictionary = it.duplicate()
			c["found"] = is_found(d, it)
			if c.found:
				n += 1
			items.append(c)
		e["items"] = items
		e["found"] = n
		e["total"] = items.size()
		out.append(e)
	return out

static func totals(d: GameStateData, entries: Array = []) -> Dictionary:
	var f := 0
	var n := 0
	for t in tally(d, entries):
		f += int(t.found)
		n += int(t.total)
	return {"found": f, "total": n}

## The Stats page line: "12 of 80", or "None yet".
static func stats_line(d: GameStateData, entries: Array = []) -> String:
	var t := totals(d, entries)
	return "None yet" if int(t.found) == 0 else "%d of %d" % [int(t.found), int(t.total)]

## Problems: unique theme ids with a name and an about line, every tag a known theme, every person in a real zone with
## a flag something sets, no em-dashes. `settable` is Quests.all_settable(); `zone_ok` says if a zone id exists.
static func validate(theme_list: Array, plaques: Array, people_list: Array, quests: Array, settable: Dictionary, zone_ok: Callable) -> Array:
	var errors := []
	var ids := {}
	for t in theme_list:
		var id := str(t.get("id", ""))
		if id == "" or ids.has(id):
			errors.append("these_isles: theme '%s' is blank or repeated" % id)
		ids[id] = true
		if str(t.get("name", "")) == "" or str(t.get("about", "")) == "":
			errors.append("these_isles: theme '%s' needs a name and an about line" % id)
		if "—" in str(t.get("name", "")) + str(t.get("about", "")):
			errors.append("these_isles: theme '%s' has an em-dash" % id)
	for p in plaques:
		var th := str(p.get("people", ""))
		if th != "" and not ids.has(th):
			errors.append("these_isles: plaque '%s' names unknown theme '%s'" % [str(p.id), th])
	var seen := {}
	for p in people_list:
		var id := str(p.get("id", ""))
		var tag := "these_isles: person '%s'" % id
		if id == "" or seen.has(id):
			errors.append(tag + " is blank or repeated")
		seen[id] = true
		if not ids.has(str(p.get("theme", ""))):
			errors.append(tag + " names unknown theme '%s'" % str(p.get("theme", "")))
		if not zone_ok.call(str(p.get("zone", ""))):
			errors.append(tag + " stands in unknown zone '%s'" % str(p.get("zone", "")))
		var f := str(p.get("flag", ""))
		if not f.begins_with("isles_met_") or not settable.has(f):
			errors.append(tag + ": flag '%s' should be isles_met_<id> and set by their talk" % f)
		if "—" in str(p.get("name", "")) + str(p.get("line", "")):
			errors.append(tag + " has an em-dash")
	for q in quests:
		var th := str(q.get("people", ""))
		if th != "" and not ids.has(th):
			errors.append("these_isles: quest '%s' names unknown theme '%s'" % [str(q.get("id", "")), th])
	return errors
