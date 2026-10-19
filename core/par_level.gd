class_name ParLevel
extends RefCounted
## "Par": the level the main story expects of you right now, read off the furthest story step you have done
## (the same steps as the pause card's "Where next?", data/objectives.json). The wider-Isles areas off the
## main line (zones with "scaled_floor", trainers with "scaled_floor") are authored at their floor par and
## lift with you as the story moves on, so they are worth a visit whenever you wander in.
## Pure: no autoloads, so the validator and tests can load it.

## [done flag, par once it is set], in story order. The par is the band of where the story sends you next.
const STEPS := [
	["starter", 7],
	["badge_brook", 14],
	["bev_bike_given", 17],
	["badge_urban", 22],
	["badge_stone", 28],
	["ch3_ddraig_woke", 33],
	["badge_storm", 40],
	["badge_fae", 44],
	["ashcombe1_done", 46],
	["ashcombe2_done", 48],
	["visited_dublin", 50],
	["badge_kin", 52],
	["kerrigan1_done", 56],
	["badge_tide", 60],
	["ch7_judged", 63],
	["badge_iron", 65],
	["ch8_vane", 67],
	["ch9_started", 69],
	["strachan1_done", 71],
	["strachan2_done", 73],
	["badge_frost", 76],
	["ch10_started", 82],
	["badge_spirit", 88],
	["kit8_done", 92],
	["moot_won", 95],
	["game_complete", 97],
]
const START := 5

## The par for these save flags: the furthest step done wins (steps can be done slightly out of order).
static func par(flags: Dictionary) -> int:
	for i in range(STEPS.size() - 1, -1, -1):
		var v: Variant = flags.get(STEPS[i][0])
		if _truthy(v):
			return int(STEPS[i][1])
	return START

static func _truthy(v: Variant) -> bool:
	match typeof(v):
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_NIL:
			return false
	return true

## How many levels to add to something authored at `floor_par`: never negative, so an area is never
## easier than it was written.
static func offset(flags: Dictionary, floor_par: int) -> int:
	return maxi(0, par(flags) - floor_par)

## `level` lifted by the offset, within the level cap.
static func lift(level: int, flags: Dictionary, floor_par: int) -> int:
	return clampi(level + offset(flags, floor_par), 1, Rules.MAX_LEVEL)

## The evolution `species_id` would have reached by `level`, following level evolutions only (an item or
## friendship evolution stops the walk). Unknown ids come back unchanged.
static func stage(dex: Dex, species_id: String, level: int) -> String:
	var id := species_id
	for _guard in 4:
		if not dex.has(id):
			return id
		var evo: Variant = dex.get_species(id).get("evolves")
		if not (evo is Dictionary) or not evo.has("level") or level < int(evo.level) or not dex.has(str(evo.get("to", ""))):
			return id
		id = str(evo.to)
	return id
