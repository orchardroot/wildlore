class_name Encounters
extends RefCounted
## Wild encounters: a 1 in 10 chance per step in tall grass (1 in 20 wading), then a weighted pick among the zone's entries
## that suit the time of day and weather. A short grace period follows each battle.

const STEP_CHANCE := 10.0
const WATER_STEP_CHANCE := 5.0   # wading is a gentler way to meet things
const GRACE_STEPS := 5
const FEATURED_MULT := 3.0  # Today's Walk: the featured species is three times as likely in its zone

var _grace := 0

## `featured_species`: Today's Walk species for this zone ("" for none, see TodaysWalk.featured_in).
static func roll(zone: ZoneData, tile: String, phase: String, weather: String, rng: Rng, featured_species := "") -> Dictionary:
	var kind: String = {"tall_grass": "grass", "deep_water": "water", "bog": "grass"}.get(tile, "")
	if kind == "":
		return {}
	if not rng.chance(step_chance(tile)):
		return {}
	var list := featured(candidates(zone, kind, phase, weather), featured_species)
	if list.is_empty():
		return {}
	var e := pick_entry(list, rng.roll())
	var lo := int(e.get("min", 2))
	var hi := maxi(lo, int(e.get("max", lo)))
	return {"species": str(e.species), "level": rng.roll_int(lo, hi)}

## Percent chance per step on this tile (0 where nothing lives).
static func step_chance(tile: String) -> float:
	match tile:
		"tall_grass", "bog":
			return STEP_CHANCE
		"deep_water":
			return WATER_STEP_CHANCE
	return 0.0

## A catch is worth banking straight away (the battle is over and nothing is half-done).
static func autosave_after(result: Dictionary) -> bool:
	return str(result.get("result", "")) == "caught"

static func candidates(zone: ZoneData, kind: String, phase: String, weather: String) -> Array:
	var out := []
	for e in zone.encounters.get(kind, []):
		var times: Array = e.get("time", [])
		var weathers: Array = e.get("weather", [])
		if (times.is_empty() or phase in times) and (weathers.is_empty() or weather in weathers):
			out.append(e)
	return out

## The list with `species`' weight tripled (copies; the zone's own table is untouched). "" or absent: unchanged.
static func featured(list: Array, species: String) -> Array:
	if species == "" or not list.any(func(e): return str(e.get("species", "")) == species):
		return list
	var out := []
	for e in list:
		if str(e.get("species", "")) == species:
			var b: Dictionary = e.duplicate()
			b["weight"] = float(e.get("weight", 1)) * FEATURED_MULT
			out.append(b)
		else:
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
