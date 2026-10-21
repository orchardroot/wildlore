class_name Dex
extends RefCounted
## All species, keyed by id. Loaded from every evolution-line JSON file in data/creatures/.

const DEFAULT_DIR := "res://data/creatures"

var duplicates: Array = []
var _species: Dictionary = {}
var _order: Array = []

const ORDER_PATH := "res://data/dex_order.json"

## Species marked "appendix": true (the 2.2 autumn fungi) are a bonus section after the original 200: they're in
## the Fieldbook and catchable, but the milestones, the diploma and the region stamps only count the rest.
## Kept static (ids are global) so code holding only the save, like FieldbookGoals, can ask.
static var _appendix := {}
## Hybrids (data/hybrids.json, Good Stock) are real species a cross can hatch, kept out of the dex order, the
## original-200 counts and the appendix: the Fieldbook lists them as a third section, H01 onwards.
static var _hybrid := {}
var _hybrid_order: Array = []

static func load_default() -> Dex:
	var dex := load_dir(DEFAULT_DIR)
	if FileAccess.file_exists(ORDER_PATH):
		var order = JsonUtil.read(ORDER_PATH)
		if order is Array:
			dex.apply_order(order)
	dex._load_hybrids()
	return dex

func _load_hybrids() -> void:
	for id in Genetics.hybrids():
		_species[id] = normalise(Genetics.hybrid_species(Genetics.hybrids()[id]))
		_hybrid[id] = true
		if id not in _hybrid_order:
			_hybrid_order.append(id)

## Creaturepedia numbering: listed ids first in this order, anything unlisted after, in load order.
func apply_order(order: Array) -> void:
	var out := []
	for id in order:
		if _species.has(id) and id not in out:
			out.append(id)
	for id in _order:
		if id not in out:
			out.append(id)
	_order = out

static func load_dir(dir: String) -> Dex:
	var all := []
	for path in JsonUtil.list_json(dir):
		var line = JsonUtil.read(path)
		if line is Dictionary:
			for sp in line.get("species", []):
				if sp is Dictionary and line.has("line"):
					sp["line"] = str(line.line)  # the evolution line, for Genetics (evolving never changes it)
				all.append(sp)
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
	if sp.get("appendix", false) == true:
		_appendix[id] = true

func get_species(id: String) -> Dictionary:
	return _species.get(id, {})

func has(id: String) -> bool:
	return _species.has(id)

func ids() -> Array:
	return _order.duplicate()

## The Fieldbook proper (the original 200), in dex order.
func core_ids() -> Array:
	return _order.filter(func(id): return not _appendix.has(id))

## The appendix species, in dex order.
func appendix_ids() -> Array:
	return _order.filter(func(id): return _appendix.has(id))

static func in_appendix(id: String) -> bool:
	return _appendix.has(id)

## The hybrid species, in the order data/hybrids.json lists them (H01 onwards in the Fieldbook).
func hybrid_ids() -> Array:
	return _hybrid_order.duplicate()

static func is_hybrid(id: String) -> bool:
	return _hybrid.has(id)

## How many of a caught (or seen) set are in the Fieldbook proper.
static func core_count(ids: Dictionary) -> int:
	var n := 0
	for id in ids:
		if not _appendix.has(id) and not _hybrid.has(id):
			n += 1
	return n
