class_name IslesWork
extends RefCounted
## "How these isles work": the Gazetteer's page on how Britain, Ireland and the islands round them fit together
## (the UK versus Great Britain, devolution, Ireland's independence, the Agreement, the open border, Brexit, the
## Crown Dependencies, the Overseas Territories, the Commonwealth, Chagos). Each topic in data/isles_work.json is
## learnt by talking to someone who knows (their dialogue sets the flag isles_<id>) or by reading one of the plaques
## it lists in `also`. Nothing else is saved, so old saves are fine. The page itself is in ui/isles_work_view.gd.
## Pure logic, no autoload names: the validator loads it.

const FILE := "res://data/isles_work.json"
const PREFIX := "isles_"
const MAX_LINE := 220  # a line on the page; longer ones don't fit the Gazetteer's panel

static var _cache: Array = []
static var _loaded := false

## Every topic, in page order: [{id, title, where, lines: [String], also: [flag]}].
static func all() -> Array:
	if not _loaded:
		var d = JsonUtil.read(FILE)
		use(parse(d))
	return _cache

## Swap in a topic list (tests); reset() goes back to the file.
static func use(list: Array) -> void:
	_cache = list
	_loaded = true

static func reset() -> void:
	_cache = []
	_loaded = false

static func parse(d: Variant) -> Array:
	if not (d is Dictionary) or not (d.get("topics") is Array):
		return []
	var out := []
	for t in d.topics:
		if t is Dictionary:
			var c: Dictionary = t.duplicate(true)
			if not (c.get("lines") is Array):
				c["lines"] = []
			if not (c.get("also") is Array):
				c["also"] = []
			out.append(c)
	return out

static func flag_key(id: String) -> String:
	return PREFIX + id

static func _on(v: Variant) -> bool:
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

## Learnt: its own flag, or any flag in `also` (a plaque read, say).
static func is_learnt(d: GameStateData, t: Dictionary) -> bool:
	if _on(d.flag(flag_key(str(t.get("id", ""))))):
		return true
	for f in t.get("also", []):
		if _on(d.flag(str(f))):
			return true
	return false

static func count(d: GameStateData, list: Array = []) -> int:
	return (list if not list.is_empty() else all()).filter(func(t): return is_learnt(d, t)).size()

## "4 of 15 understood", or "Nothing yet".
static func progress_line(d: GameStateData, list: Array = []) -> String:
	var l := list if not list.is_empty() else all()
	var n := count(d, l)
	return "Nothing yet" if n == 0 else "%d of %d understood" % [n, l.size()]

## Problems: unique ids, a title, a where and some lines, short lines, no em-dashes, and every topic learnable
## (something in the game sets its flag, or one of its `also` flags). `settable` is Quests.all_settable().
static func validate(list: Array, settable: Dictionary) -> Array:
	var errors := []
	var seen := {}
	for t in list:
		var id := str(t.get("id", ""))
		var tag := "isles_work topic '%s'" % id
		if id == "":
			errors.append("isles_work: a topic has no id")
			continue
		if seen.has(id):
			errors.append(tag + " is listed twice")
		seen[id] = true
		if str(t.get("title", "")).strip_edges() == "" or str(t.get("where", "")).strip_edges() == "":
			errors.append(tag + " needs a title and a where")
		if t.get("lines", []).is_empty():
			errors.append(tag + " has no lines")
		var text := str(t.get("title", "")) + str(t.get("where", ""))
		for l in t.get("lines", []):
			text += str(l)
			if str(l).length() > MAX_LINE:
				errors.append(tag + " has a line over %d characters: '%s...'" % [MAX_LINE, str(l).left(40)])
		if "—" in text:
			errors.append(tag + " has an em-dash")
		var ways: Array = [flag_key(id)] + Array(t.get("also", []))
		if not ways.any(func(f): return settable.has(str(f))):
			errors.append(tag + " can't be learnt: nothing sets %s or any of its `also` flags" % flag_key(id))
	return errors
