class_name Encounters
extends RefCounted
## Wild encounters: a 1 in 10 chance per step in tall grass, then a weighted pick among the zone's entries
## that suit the time of day and weather. A short grace period follows each battle.

const STEP_CHANCE := 10.0
const GRACE_STEPS := 3

var _grace := 0

static func roll(zone: ZoneData, tile: String, phase: String, weather: String, rng: Rng) -> Dictionary:
	var kind: String = {"tall_grass": "grass", "deep_water": "water", "bog": "grass"}.get(tile, "")
	if kind == "":
		return {}
	if not rng.chance(STEP_CHANCE):
		return {}
	var list := candidates(zone, kind, phase, weather)
	if list.is_empty():
		return {}
	var e := pick_entry(list, rng.roll())
	var lo := int(e.get("min", 2))
	var hi := maxi(lo, int(e.get("max", lo)))
	return {"species": str(e.species), "level": rng.roll_int(lo, hi)}

static func candidates(zone: ZoneData, kind: String, phase: String, weather: String) -> Array:
	var out := []
	for e in zone.encounters.get(kind, []):
		var times: Array = e.get("time", [])
		var weathers: Array = e.get("weather", [])
		if (times.is_empty() or phase in times) and (weathers.is_empty() or weather in weathers):
			out.append(e)
	return out

## `u` in 0..1 chooses along the cumulative weights.
static func pick_entry(list: Array, u: float) -> Dictionary:
	var total := 0.0
	for e in list:
		total += float(e.get("weight", 1))
	var r := clampf(u, 0.0, 0.9999) * total
	for e in list:
		r -= float(e.get("weight", 1))
		if r < 0.0:
			return e
	return list.back()

func after_battle() -> void:
	_grace = GRACE_STEPS

func stepped() -> void:
	_grace = maxi(0, _grace - 1)

func in_grace() -> bool:
	return _grace > 0
