class_name Deeds
extends RefCounted
## STUB of session A's core/deeds.gd, with the exact signatures from docs/briefs/wave35.md, so the Regulars (D) can
## call the manager hook. The integrator drops this file in favour of the real one.

static func all() -> Array:
	return []

static func get_deed(_id: String) -> Dictionary:
	return {}

static func owned(_data: GameStateData) -> Array:
	return []

static func price(_data: GameStateData, _id: String) -> int:
	return 0

static func buy(_data: GameStateData, _id: String) -> String:
	return "Not open yet."

static func supply(_data: GameStateData, _id: String, _item_id: String, _n: int) -> int:
	return 0

static func tick(_data: GameStateData, _day: int) -> Array:
	return []

static func collect(_data: GameStateData, _id: String) -> int:
	return 0

static func upgrade(_data: GameStateData, _id: String) -> String:
	return "Not open yet."

static func set_manager(_data: GameStateData, _id: String, _npc_id: String) -> void:
	pass

static func sell_back(_data: GameStateData, _id: String) -> int:
	return 0
