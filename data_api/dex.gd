class_name Dex
extends RefCounted
## All species, keyed by id. Loaded from every evolution-line JSON file in data/creatures/.

const DEFAULT_DIR := "res://data/creatures"

var duplicates: Array = []
var _species: Dictionary = {}
var _order: Array = []

static func load_default() -> Dex:
	return load_dir(DEFAULT_DIR)

static func load_dir(dir: String) -> Dex:
	var all := []
	for path in JsonUtil.list_json(dir):
		var line = JsonUtil.read(path)
		if line is Dictionary:
			all.append_array(line.get("species", []))
	return from_array(all)

static func from_array(arr: Array) -> Dex:
	var dex := Dex.new()
	for sp in arr:
		dex._add(normalise(sp))
	return dex

static func normalise(sp: Dictionary) -> Dictionary:
	var out := sp.duplicate(true)
	var base := {}
	var raw_base: Dictionary = sp.get("base", {})
	for s in Rules.STATS:
		base[s] = int(raw_base.get(s, 0))
	out["base"] = base
	out["catch_rate"] = int(sp.get("catch_rate", 0))
	out["base_xp"] = int(sp.get("base_xp", 0))
	var learnset := []
	var malformed := 0
	for entry in sp.get("learnset", []):
		if entry is Array and entry.size() == 2:
			learnset.append([int(entry[0]), str(entry[1])])
		else:
			malformed += 1
	out["learnset"] = learnset
	out["malformed_learnset"] = malformed
	var evo = sp.get("evolves")
	if evo is Dictionary:
		var e: Dictionary = evo.duplicate()
		if e.has("level"):
			e["level"] = int(e["level"])
		out["evolves"] = e
	else:
		out["evolves"] = null
	return out

func _add(sp: Dictionary) -> void:
	var id: String = sp.get("id", "")
	if _species.has(id):
		duplicates.append(id)
	else:
		_order.append(id)
	_species[id] = sp

func get_species(id: String) -> Dictionary:
	return _species.get(id, {})

func has(id: String) -> bool:
	return _species.has(id)

func ids() -> Array:
	return _order.duplicate()
