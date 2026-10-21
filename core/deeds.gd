class_name Deeds
extends RefCounted
## STUB of session A's Deeds (the exact contract signatures, no behaviour). The integrator drops this for the real one.

static func all() -> Array:
	return []

static func get_deed(id: String) -> Dictionary:
	var d = JsonUtil.read("res://data/deeds/%s.json" % id)
	return d if d is Dictionary else {}

static func owned(_data: GameStateData) -> Array:
	return []

static func price(_data: GameStateData, _id: String) -> int:
	return 0

static func buy(_data: GameStateData, _id: String) -> String:
	return "Not for sale yet."

static func supply(_data: GameStateData, _id: String, _item_id: String, _n: int) -> int:
	return 0

static func tick(_data: GameStateData, _day: int) -> Array:
	return []

static func collect(_data: GameStateData, _id: String) -> int:
	return 0

static func upgrade(_data: GameStateData, _id: String) -> String:
	return "Not yet."

static func set_manager(_data: GameStateData, _id: String, _npc_id: String) -> void:
	pass

static func sell_back(_data: GameStateData, _id: String) -> int:
	return 0
