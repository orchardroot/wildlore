class_name WeatherWild
extends RefCounted
## Weather that matters on foot (3.1): what the sky brings out of the grass. Only species already on the zone's
## table are favoured (their weight is multiplied), so nothing turns up out of region and a zone with no fitting
## type is simply unchanged. Interiors and caves run on "clear" (their weather table is empty), so they never shift.

const BOOST := 2.5
## Weather -> the types it brings out.
const AFFINITY := {
	"drizzle": ["brook", "tide", "bog"],
	"downpour": ["brook", "tide", "bog", "storm"],
	"fog": ["spirit", "fae", "night"],
	"frost": ["frost"],
	"sunshine": ["hedgerow", "gale"],
	"gale": ["gale", "storm"],
}
## What the radio says about it.
const HINTS := {
	"drizzle": "Damp weather: water and bog creatures are out.",
	"downpour": "Wet weather: water, bog and storm creatures are out in force.",
	"fog": "Foggy weather: ghostly and fae things are drifting about.",
	"frost": "Frosty weather: frost creatures are about.",
	"sunshine": "Sunny weather: bugs, birds and blossom folk are out.",
	"gale": "Blustery weather: birds and storm creatures are on the wing.",
}

## True if the weather favours a species with these types.
static func favours(weather: String, types: Array) -> bool:
	var want: Array = AFFINITY.get(weather, [])
	for t in types:
		if str(t) in want:
			return true
	return false

## The list with favoured species' weight multiplied (copies; the zone's own table is untouched).
## `types_of`: Callable(species id) -> Array of type ids.
static func shift(list: Array, weather: String, types_of: Callable) -> Array:
	if not AFFINITY.has(weather) or list.is_empty():
		return list
	var out := []
	var changed := false
	for e in list:
		if favours(weather, types_of.call(str(e.get("species", "")))):
			var b: Dictionary = e.duplicate()
			b["weight"] = float(e.get("weight", 1)) * BOOST
			out.append(b)
			changed = true
		else:
			out.append(e)
	return out if changed else list

## Species id -> types, from the live dex (empty before it exists, e.g. in bare unit tests).
static func dex_types(id: String) -> Array:
	var d: Variant = Game.get("dex")
	if d == null:
		if _fallback == null:
			_fallback = Dex.load_default()
		d = _fallback
	return d.get_species(id).get("types", [])

static var _fallback: Dex

static func hint(weather: String) -> String:
	return str(HINTS.get(weather, ""))
