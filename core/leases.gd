class_name Leases
extends RefCounted
## STUB: session A owns the real thing (auction, upkeep, edge-opening). Just enough for lease zones and their tests.
## A lease is owned when the flag lease_<id> is set (data/leases/<id>.json); absent = not owned.

const DIR := "res://data/leases"

static func flag_key(lease_id: String) -> String:
	return "lease_" + lease_id

static func owned(data: GameStateData, lease_id: String) -> bool:
	return data.flag(flag_key(lease_id)) == true
