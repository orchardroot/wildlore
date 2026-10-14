class_name MoveDB
extends RefCounted
## All moves, keyed by id. Loaded from every JSON array in data/moves/.

const DEFAULT_DIR := "res://data/moves"

var duplicates: Array = []
var _moves: Dictionary = {}

static func load_default() -> MoveDB:
	return load_dir(DEFAULT_DIR)

static func load_dir(dir: String) -> MoveDB:
	var all := []
	for path in JsonUtil.list_json(dir):
		var arr = JsonUtil.read(path)
		if arr is Array:
			all.append_array(arr)
	return from_array(all)

static func from_array(arr: Array) -> MoveDB:
	var db := MoveDB.new()
	for m in arr:
		db.add(normalise(m))
	return db

static func normalise(m: Dictionary) -> Dictionary:
	var out := m.duplicate(true)
	for key in ["power", "accuracy", "pp", "priority"]:
		out[key] = int(m.get(key, 0))
	var fx: Dictionary = m.get("effect", {"id": "none"}).duplicate()
	fx["chance"] = int(fx.get("chance", 100))
	if fx.get("id") == "stat":
		fx["stages"] = int(fx.get("stages", 0))
	fx["target"] = fx.get("target", "foe")
	out["effect"] = fx
	return out

func add(m: Dictionary) -> void:
	var id: String = m.get("id", "")
	if _moves.has(id):
		duplicates.append(id)
	_moves[id] = m

func get_move(id: String) -> Dictionary:
	return _moves.get(id, {})

func has(id: String) -> bool:
	return _moves.has(id)

func ids() -> Array:
	return _moves.keys()
