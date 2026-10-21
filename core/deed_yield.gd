class_name DeedYield
extends RefCounted
## What a boat or an allotment Deed brings in, as items: data/deeds/<id>.json "yield" is {season: [{item, n}]}. The day's
## haul is a seeded pick of two or three of that season's lines, so it is the same for everyone on a given day and there
## is nothing to save. A storm or a gale (an event with mult 0) loses the haul; the boat is never lost. Pure logic.

const DEEDS_DIR := "res://data/deeds/"

## {item_id: n} for `day` (a DailyKey day number) in `season`; empty when the day is lost.
static func haul(deed: Dictionary, season: String, day: int, lost := false) -> Dictionary:
	var out := {}
	var lines: Array = deed.get("yield", {}).get(season, [])
	if lost or lines.is_empty():
		return out
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("%s|%s|%d" % [deed.get("id", ""), season, day])
	var picks := mini(lines.size(), 2 + rng.randi_range(0, 1))
	var pool := lines.duplicate()
	for _i in picks:
		var line: Dictionary = pool.pop_at(rng.randi_range(0, pool.size() - 1))
		out[str(line.item)] = out.get(str(line.item), 0) + int(line.n)
	return out

## The haul's worth at the Ledger's selling price in `zone_id` (sterling).
static func worth(data: GameStateData, items: Dictionary, zone_id: String) -> int:
	var total := 0
	for id in items:
		total += Trade.sell_total(data, str(id), zone_id, int(items[id]))
	return total

## The most a full-stock day can take at tier 0: base plus every input's per_input (one allowance per distinct input
## active in a season is the caller's job, so this is the safe upper bound over all inputs).
static func ceiling(deed: Dictionary) -> int:
	var o: Dictionary = deed.get("output", {})
	return int(o.get("base", 0)) + int(o.get("per_input", 0)) * (deed.get("inputs", []) as Array).size()
