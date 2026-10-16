class_name Ambience
extends RefCounted
## What the world sounds like where you stand: the ambience bed and weather layer for a zone, whether the
## music should sound muffled (heard from indoors), town accents, footstep surfaces and interaction sounds.
## Pure functions: Audio plays what these pick. Loops live in res://audio/ambience/ (tools/audio/ambgen.gd).

const BEDS := ["amb_coast", "amb_country", "amb_city", "amb_moor", "amb_cave", "amb_interior", "amb_night"]
const LAYERS := ["amb_rain_light", "amb_rain_heavy", "amb_gale", "amb_rain_roof"]

const STAGE_BEDS := {
	"coast": "amb_coast", "docks": "amb_coast", "city": "amb_city",
	"moor": "amb_moor", "bog": "amb_moor", "mountain": "amb_moor", "quarry": "amb_moor",
}
const WEATHER_LAYERS := {"drizzle": "amb_rain_light", "downpour": "amb_rain_heavy", "gale": "amb_gale"}
const RAIN := ["drizzle", "downpour"]

## Tile -> footstep sound. Tiles not listed (tall grass, scree, bog, water) keep their own sounds or none.
const FOOTSTEPS := {
	"path": "step_path", "road": "step_stone", "cobbles": "step_stone", "platform": "step_stone",
	"level_crossing": "step_stone", "floor_tile": "step_stone", "door": "step_stone",
	"floor_wood": "step_wood", "sand": "step_sand", "grass": "step_soft", "flowers": "step_soft", "shallow": "step_wet",
}
## Surfaces that go splashy in the rain (sand soaks it up, floors are indoors).
const WETTABLE := ["step_path", "step_stone", "step_soft"]

## {"bed", "layer", "muffle"} for zone `z`. `weather` is the zone's own (always "clear" indoors);
## `outside` is the weather last seen outdoors, which is what drums on the roof.
static func pick(z: ZoneData, weather: String, phase: String, outside: String) -> Dictionary:
	var indoors := z.kind == "interior"
	var cave := is_cave(z)
	var layer := ""
	if not indoors:
		layer = WEATHER_LAYERS.get(weather, "")
	elif not cave and outside in RAIN:
		layer = "amb_rain_roof"
	return {"bed": bed_for(z, phase), "layer": layer, "muffle": indoors and z.music == ""}

static func is_cave(z: ZoneData) -> bool:
	return z.dark or z.stage == "cave"

static func bed_for(z: ZoneData, phase: String) -> String:
	if z.ambience != "":
		return "" if z.ambience == "none" else z.ambience
	if z.kind == "interior":
		return "amb_cave" if is_cave(z) else "amb_interior"
	var bed: String = STAGE_BEDS.get(z.stage, "amb_country")
	if bed == "amb_country" and phase == "night":
		return "amb_night"
	return bed

## Occasional town sounds: "bell" (a cathedral or abbey strikes the hour), "horn" (ships in the docks).
static func accents(z: ZoneData) -> Array:
	var out: Array = []
	if z.kind != "town":
		return out
	for p in z.props:
		if str(p.get("type", "")) == "building" and str(p.get("style", "")) == "cathedral":
			out.append("bell")
			break
	if z.stage == "docks":
		out.append("horn")
	return out

## Did the game clock pass an hour mark going from `before` to `now`? Big jumps (a night's sleep, a load) don't count.
static func hour_struck(before: int, now: int) -> bool:
	var gone := posmod(now - before, GameClock.DAY)
	if gone == 0 or gone > 5:
		return false
	return posmod(now, 60) < gone

## The sound for stepping onto `tile`, or "" for none.
static func footstep(tile: String, weather: String, indoors: bool, on_bike: bool) -> String:
	var id: String = FOOTSTEPS.get(tile, "")
	if id == "":
		return ""
	if on_bike:
		return "bike_tyre"
	if not indoors and weather in RAIN and id in WETTABLE:
		return "step_wet"
	return id

## The sound for pressing confirm at a sign (`sign` non-empty) or at an NPC (its def), or "".
static func interact_kind(sign: Dictionary, npc_def: Dictionary) -> String:
	if not sign.is_empty():
		return "sign_creak"
	if npc_def.is_empty():
		return ""
	match str(npc_def.get("script", "")):
		"shopkeeper":
			return "shop_bell"
		"nurse":
			return "sanctuary_chime"
	return "talk_blip"
