class_name Invention
extends RefCounted
## Isles of Invention (4.5): the Timeline of Invention, filled by reading plaques, meeting people and finding real
## objects round the isles. data/invention.json lists eras (each with what it cost and a small gadget it unlocks)
## and entries (a year, a line, where to look, and the flags that count as having found it: any one will do).
## Nothing new is saved: an entry is found once any of its flags is set, so old saves that already read the Iron
## Bridge plaque have it from the start. A gadget opens once `need` entries of its era are found; a few gadgets keep
## a once-a-day flag (see Gadgets). Pure logic, no autoload names: the validator loads it.

const PATH := "res://data/invention.json"
const NOW_YEAR := 0   # an entry "year" of 0 reads as "Now"

static var _data: Dictionary = {}

static func _load() -> Dictionary:
	if _data.is_empty():
		var d = JsonUtil.read(PATH)
		_data = d if d is Dictionary else {"eras": [], "entries": []}
	return _data

## Swap in fixture data (tests); reset() goes back to the file.
static func use(d: Dictionary) -> void:
	_data = d

static func reset() -> void:
	_data = {}

static func eras() -> Array:
	return _load().get("eras", [])

static func era(id: String) -> Dictionary:
	for e in eras():
		if str(e.id) == id:
			return e
	return {}

## Every entry, in year order (Now last), then file order.
static func entries() -> Array:
	var out: Array = _load().get("entries", []).duplicate()
	out.sort_custom(func(a, b): return _sort_year(a) < _sort_year(b))
	return out

static func _sort_year(e: Dictionary) -> int:
	var y := int(e.get("year", 0))
	return 99999 if y == NOW_YEAR else y

static func entry(id: String) -> Dictionary:
	for e in _load().get("entries", []):
		if str(e.id) == id:
			return e
	return {}

## The entries of one era, in year order.
static func era_entries(era_id: String) -> Array:
	return entries().filter(func(e): return str(e.era) == era_id)

static func year_text(e: Dictionary) -> String:
	var y := int(e.get("year", 0))
	return "Now" if y == NOW_YEAR else str(y)

static func found(d: GameStateData, e: Dictionary) -> bool:
	for f in e.get("flags", []):
		if ZoneData.flag_on(d.flag(str(f))):
			return true
	return false

static func found_count(d: GameStateData) -> int:
	return entries().filter(func(e): return found(d, e)).size()

static func era_found(d: GameStateData, era_id: String) -> int:
	return era_entries(era_id).filter(func(e): return found(d, e)).size()

## A gadget is yours once enough of its era is found.
static func gadget_open(d: GameStateData, era_id: String) -> bool:
	var e := era(era_id)
	return not e.is_empty() and era_found(d, era_id) >= int(e.get("need", 1))

static func open_gadgets(d: GameStateData) -> Array:
	return eras().filter(func(e): return gadget_open(d, str(e.id))).map(func(e): return str(e.gadget.id))

static func era_of_gadget(gadget_id: String) -> String:
	for e in eras():
		if str(e.get("gadget", {}).get("id", "")) == gadget_id:
			return str(e.id)
	return ""

## The flag `key` was just set: what that adds to the Timeline, for a toast. {} when it adds nothing (the entry
## was already found through another of its flags, or the flag isn't one of ours). Else {entry, gadget} where
## gadget is the era's gadget dictionary when this find is the one that opened it, or {}.
static func news_for_flag(d: GameStateData, key: String) -> Dictionary:
	for e in _load().get("entries", []):
		var fl: Array = e.get("flags", [])
		if key not in fl:
			continue
		for f in fl:
			if str(f) != key and ZoneData.flag_on(d.flag(str(f))):
				return {}
		var er := era(str(e.era))
		var gadget: Dictionary = er.get("gadget", {}) if era_found(d, str(e.era)) == int(er.get("need", 1)) else {}
		return {"entry": e, "gadget": gadget}
	return {}

## Data problems: eras and entries well formed, years sane, no em-dashes, each era's need reachable, and every
## entry's flags set by something in the game (`settable`, see Quests.settable_flags).
static func check(settable: Dictionary) -> Array:
	var errors := []
	var era_ids := {}
	var gadget_ids := {}
	for e in eras():
		var id := str(e.get("id", ""))
		if id == "" or era_ids.has(id):
			errors.append("invention: era '%s' has no id or a duplicate one" % id)
		era_ids[id] = 0
		var g: Dictionary = e.get("gadget", {})
		if str(g.get("id", "")) == "" or gadget_ids.has(str(g.get("id", ""))):
			errors.append("invention: era '%s' needs a gadget with its own id" % id)
		gadget_ids[str(g.get("id", ""))] = true
		for k in ["name", "years", "cost"]:
			if str(e.get(k, "")) == "":
				errors.append("invention: era '%s' has no %s" % [id, k])
		errors.append_array(_dash_check("era " + id, [str(e.get("name", "")), str(e.get("cost", "")), str(g.get("name", "")), str(g.get("text", ""))]))
	var ids := {}
	for e in _load().get("entries", []):
		var id := str(e.get("id", ""))
		var tag := "invention: entry '%s'" % id
		if id == "" or ids.has(id):
			errors.append(tag + " has no id or a duplicate one")
		ids[id] = true
		if not era_ids.has(str(e.get("era", ""))):
			errors.append(tag + " is in unknown era '%s'" % str(e.get("era", "")))
		else:
			era_ids[str(e.era)] += 1
		var y := int(e.get("year", -1))
		if y != NOW_YEAR and (y < 1500 or y > 2025):
			errors.append(tag + " has year %d (1500 to 2025, or 0 for now)" % y)
		for k in ["title", "text", "where"]:
			if str(e.get(k, "")) == "":
				errors.append(tag + " has no %s" % k)
		var fl: Array = e.get("flags", [])
		if fl.is_empty():
			errors.append(tag + " has no flags to find it by")
		for f in fl:
			if not settable.has(str(f)):
				errors.append(tag + ": flag '%s' is never set by any plaque, script or examine spot" % str(f))
		errors.append_array(_dash_check("entry " + id, [str(e.get("title", "")), str(e.get("text", "")), str(e.get("where", "")), str(e.get("cost", ""))]))
	for e in eras():
		if int(era_ids.get(str(e.id), 0)) < int(e.get("need", 1)):
			errors.append("invention: era '%s' needs %d found but has only %d entries" % [str(e.id), int(e.get("need", 1)), int(era_ids.get(str(e.id), 0))])
	return errors

static func _dash_check(tag: String, texts: Array) -> Array:
	for t in texts:
		if "—" in str(t):
			return ["invention: %s has an em-dash" % tag]
	return []
