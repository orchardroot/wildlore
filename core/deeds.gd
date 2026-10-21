class_name Deeds
extends RefCounted
## STUB: the exact signatures session A's real core/deeds.gd will have. The integrator drops this file.

static func all() -> Array:
	return []

static func get_deed(_id: String) -> Dictionary:
	return {}

static func owned(_data: GameStateData) -> Array:
	return []

static func price(_data: GameStateData, _id: String) -> int:
	return 0

static func buy(_data: GameStateData, _id: String) -> String:
	return "Not yet."

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
