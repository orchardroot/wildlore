class_name StoryData
extends RefCounted
## Loads dialogue scripts (data/dialogue/<zone>.json plus the global common.json) and trainers (data/trainers/<id>.json).

const DIALOGUE_DIR := "res://data/dialogue"
const TRAINER_DIR := "res://data/trainers"

static var _dialogue_cache: Dictionary = {}
static var _trainer_cache: Dictionary = {}

static func clear_cache() -> void:
	_dialogue_cache.clear()
	_trainer_cache.clear()

## Every script visible from a zone: the zone's own, over the common ones.
static func scripts_for(zone_id: String) -> Dictionary:
	var out := _file("common").duplicate()
	out.merge(_file(zone_id), true)
	return out

## A script's commands, or [] if there is no such script.
static func script(zone_id: String, script_id: String) -> Array:
	var s: Variant = scripts_for(zone_id).get(script_id, [])
	return s if s is Array else []

## dialogue file basename -> {script id -> commands}
static func all_dialogue() -> Dictionary:
	var out := {}
	for path in JsonUtil.list_json(DIALOGUE_DIR):
		out[path.get_file().get_basename()] = _file(path.get_file().get_basename())
	return out

static func trainer(id: String) -> Dictionary:
	if not _trainer_cache.has(id):
		var path := TRAINER_DIR.path_join(id + ".json")
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		_trainer_cache[id] = normalise_trainer(d, id) if d is Dictionary else {}
	return _trainer_cache[id]

static func trainer_exists(id: String) -> bool:
	return FileAccess.file_exists(TRAINER_DIR.path_join(id + ".json"))

static func trainer_ids() -> Array:
	return JsonUtil.list_json(TRAINER_DIR).map(func(p): return p.get_file().get_basename())

static func normalise_trainer(d: Dictionary, id: String) -> Dictionary:
	var out := d.duplicate(true)
	out["id"] = str(d.get("id", id))
	out["name"] = str(d.get("name", id))
	out["class"] = str(d.get("class", ""))
	out["sprite"] = str(d.get("sprite", ""))
	out["ai"] = str(d.get("ai", "trainer"))
	out["money"] = int(d.get("money", 0))
	out["win"] = str(d.get("win", ""))
	out["after"] = str(d.get("after", ""))
	out["intro"] = d.get("intro", [])
	var party := []
	for m in d.get("party", []):
		var e := {"species": str(m.get("species", "")), "level": int(m.get("level", 1))}
		if m.has("moves"):
			e["moves"] = m.moves.map(func(x): return str(x))
		for k in ["held", "tea"]:  # a charm, and a keeper's one tea (see TrainerParty)
			if str(m.get(k, "")) != "":
				e[k] = str(m[k])
		party.append(e)
	out["party"] = party
	return out

## What a trainer says and does when they challenge you: their intro, then the battle itself.
static func trainer_script(id: String) -> Array:
	var t := trainer(id)
	var cmds: Array = t.get("intro", []).duplicate()
	cmds.append({"do": "battle", "trainer": id})
	return cmds

## {greeting}: how folk say hello round here (dialogue writes "{greeting} Lovely day."). Zone ids beat regions,
## interiors use the town they're in, and Man's depends on the hour.
const GREETINGS := {
	"cheshire": "Alright!", "manchester": "Alright, our kid!", "merseyside": "Alright, la!", "yorkshire": "Ey up!",
	"north_east": "Alreet, pet!", "midlands": "Alright, mate!", "peak": "Ay up, me duck!", "cumbria": "Now then!", "lancashire": "Hiya, love!",
	"south_england": "Alright, my lover!", "cornwall": "Dydh da!", "north_wales": "Shwmae!", "mid_wales": "Shwmae!",
	"south_wales": "Shwmae!", "scotland": "Hiya!", "ireland": "How's the form?", "ireland_east": "How's the form?",
	"ireland_west": "Dia dhuit!",
}
const ZONE_GREETINGS := {
	"birmingham": "Alright, bab!", "nottingham": "Ay up, me duck!", "stoke": "Ow at, duck?", "aberdeen": "Fit like?",
	# Northern Ireland
	"belfast": "Bout ye?", "bushmills": "Bout ye?", "derry": "Bout ye?", "antrim_coast": "Bout ye?",
	"causeway": "Bout ye?", "mournes": "Bout ye?",
	# the Highlands and Skye, where you'll still hear Gaelic
	"inverness": "Halò!", "fort_william": "Halò!", "portree": "Halò!", "skye": "Halò!", "faerie_glen": "Halò!",
	"great_glen": "Halò!", "loch_ness": "Halò!", "glencoe": "Halò!", "cairngorms": "Halò!",
}
const MANX_MORNING := "Moghrey mie!"     # good morning
const MANX_AFTERNOON := "Fastyr mie!"    # good afternoon (and evening)
static var _greeting_key_cache: Dictionary = {}

static func greeting(zone_id: String, minutes: int) -> String:
	var key := _greeting_key(zone_id)
	if key == "man":
		var m := GameClock.wrap(minutes)
		return MANX_MORNING if m >= 5 * 60 and m < 12 * 60 else MANX_AFTERNOON
	if ZONE_GREETINGS.has(key):
		return ZONE_GREETINGS[key]
	return GREETINGS.get(key, "Hello!")

## The zone id (if it has its own greeting) or region a zone greets as; an interior walks back to its town
## ("fort_william_sanctuary" -> "fort_william").
static func _greeting_key(zone_id: String) -> String:
	if _greeting_key_cache.has(zone_id):
		return _greeting_key_cache[zone_id]
	var key := ""
	var parts := zone_id.split("_")
	for n in range(parts.size(), 0, -1):
		var id := "_".join(parts.slice(0, n))
		if ZONE_GREETINGS.has(id):
			key = id
			break
		var path := ZoneData.DIR.path_join(id + ".json")
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		if d is Dictionary and str(d.get("region", "")) != "":
			key = str(d.region)
			break
	_greeting_key_cache[zone_id] = key
	return key

static func _file(name: String) -> Dictionary:
	if not _dialogue_cache.has(name):
		var path := DIALOGUE_DIR.path_join(name + ".json")
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		_dialogue_cache[name] = d if d is Dictionary else {}
	return _dialogue_cache[name]
