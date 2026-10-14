class_name FakeStoryHost
extends RefCounted
## A host for Commands that records what was asked of it and never suspends, so tests run synchronously.

var data := GameStateData.new()
var dex := Fixtures.dex()
var moves := Fixtures.moves()
var items := ItemDB.load_default()
var rng := Rng.new(1)
var zone := "testbed"
var anchor := Vector2i(7, 8)
var log: Array = []
var said: Array = []
var choices: Array = []          # queued answers for choice()
var battle_results: Array = []   # queued results for battle(); default is a win
var last_battle: Dictionary = {}
var warps: Array = []

func zone_id() -> String:
	return zone

func heal_anchor(_npc: String) -> Vector2i:
	return anchor

func say(who: String, text: String) -> void:
	said.append([who, text])

func choice(_text: String, options: Array) -> int:
	return int(choices.pop_front()) if not choices.is_empty() else options.size() - 1

func battle(foe_party: Array, opts: Dictionary) -> Dictionary:
	last_battle = {"foes": foe_party, "opts": opts}
	return battle_results.pop_front() if not battle_results.is_empty() else {"result": "win", "caught": null}

func move_npc(npc: String, path: Array) -> void:
	log.append(["move", npc, path])

func face_npc(npc: String, dir: String) -> void:
	log.append(["face", npc, dir])

func face_player(npc: String) -> void:
	log.append(["face_player", npc])

func warp(to: String, x: int, y: int, facing: String) -> void:
	warps.append([to, x, y, facing])

var menu_results: Dictionary = {}

func open_menu(menu: String) -> Variant:
	log.append(["menu", menu])
	return menu_results.get(menu)

func fade(out: bool) -> void:
	log.append(["fade", out])

func music(id: String) -> void:
	log.append(["music", id])

func sfx(id: String) -> void:
	log.append(["sfx", id])

func wait(seconds: float) -> void:
	log.append(["wait", seconds])

func texts() -> Array:
	return said.map(func(s): return s[1])
