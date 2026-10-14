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
		party.append(e)
	out["party"] = party
	return out

## What a trainer says and does when they challenge you: their intro, then the battle itself.
static func trainer_script(id: String) -> Array:
	var t := trainer(id)
	var cmds: Array = t.get("intro", []).duplicate()
	cmds.append({"do": "battle", "trainer": id})
	return cmds

static func _file(name: String) -> Dictionary:
	if not _dialogue_cache.has(name):
		var path := DIALOGUE_DIR.path_join(name + ".json")
		var d: Variant = JsonUtil.read(path) if FileAccess.file_exists(path) else null
		_dialogue_cache[name] = d if d is Dictionary else {}
	return _dialogue_cache[name]
