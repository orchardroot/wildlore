class_name Commands
extends RefCounted
## The story command interpreter. Pure logic: everything that touches the screen goes through an injected host.
##
## Host interface (duck typed; coroutines may suspend):
##   data: GameStateData, dex: Dex, moves: MoveDB, items: ItemDB, rng: Rng
##   zone_id() -> String                      heal_anchor(npc_id) -> Vector2i
##   say(who, text)      choice(text, options) -> int      battle(foe_party, opts) -> Dictionary
##   move_npc(npc, path) face_npc(npc, dir)    face_player(npc)
##   warp(zone, x, y, facing)   open_menu(name) -> Variant   fade(out: bool)
##   music(id)  sfx(id)  wait(seconds)
##   optional: on_flag(key, value)

const WHITEOUT_LINE := "You hurry back to the Sanctuary, a little dazed."
const WHITEOUT_LINE_2 := "Your team is patched up and ready to go again."

var host
var npc_id: String
var _ended := false

## npc_id is the NPC that owns the script (the default target of move, face and heal).
func _init(h, owner_npc := "") -> void:
	host = h
	npc_id = owner_npc

func run(commands: Array) -> void:
	_ended = false
	await _run_list(commands)

func _run_list(commands: Array) -> void:
	for c in commands:
		if _ended:
			return
		if c is Dictionary:
			await _exec(c)

func _exec(c: Dictionary) -> void:
	var data: GameStateData = host.data
	match str(c.get("do", "")):
		"say":
			await host.say(_sub(str(c.get("who", ""))), _sub(str(c.get("text", ""))))
		"choice":
			var idx: int = await host.choice(_sub(str(c.get("text", ""))), c.get("options", []).map(func(o): return _sub(str(o))))
			if c.has("set"):
				_set_flag(str(c.set), idx)
		"if":
			var branch: Array = c.get("then", []) if _test(c) else c.get("else", [])
			await _run_list(branch)
		"set":
			_set_flag(str(c.get("flag", "")), c.get("value", true))
		"give_item":
			var id := str(c.get("item", ""))
			var n := int(c.get("n", 1))
			Bag.new(data.bag).add(id, n)
			var nm: String = host.items.get_item(id).get("name", id)
			await host.sfx("item")
			await host.say("", "%s received %s%s." % [data.player_name, nm, " x%d" % n if n > 1 else ""])
		"give_creature":
			var sp: Dictionary = host.dex.get_species(str(c.get("species", "")))
			var cr := Creature.create(sp, int(c.get("level", 5)), host.rng, host.moves)
			var where := data.add_creature(cr)
			await host.sfx("catch")
			if where == "party":
				await host.say("", "%s joined your team!" % cr.display_name())
			else:
				await host.say("", "%s was sent to the Ark, as your team is full." % cr.display_name())
		"heal":
			data.heal_party()
			var t: Vector2i = host.heal_anchor(str(c.get("npc", npc_id)))
			data.last_sanctuary = {"zone": host.zone_id(), "pos": [t.x, t.y]}
			await host.sfx("heal")
		"battle":
			await _battle(str(c.get("trainer", "")))
		"move":
			await host.move_npc(str(c.get("npc", npc_id)), c.get("path", []))
		"face":
			await host.face_npc(str(c.get("npc", npc_id)), str(c.get("dir", "down")))
		"face_player":
			await host.face_player(str(c.get("npc", npc_id)))
		"wait":
			await host.wait(float(c.get("seconds", 0.5)))
		"warp":
			await host.warp(str(c.get("zone", "")), int(c.get("x", 0)), int(c.get("y", 0)), str(c.get("facing", "down")))
		"shop":
			await host.open_menu("shop:" + str(c.get("id", "")))
		"starter":
			var picked = await host.open_menu("starter")
			if picked is String and picked != "":
				_set_flag("starter", picked)
		"fade_out":
			await host.fade(true)
		"fade_in":
			await host.fade(false)
		"music":
			await host.music(str(c.get("id", "")))
		"sfx":
			await host.sfx(str(c.get("id", "")))
		"badge":
			var b := str(c.get("id", ""))
			if b != "" and b not in data.badges:
				data.badges.append(b)
			await host.sfx("badge")
		"end":
			_ended = true
		_:
			push_warning("Commands: unknown command '%s'" % c.get("do", ""))

func _battle(trainer_id: String) -> void:
	var data: GameStateData = host.data
	var def := StoryData.trainer(trainer_id)
	if def.is_empty():
		push_error("Commands: no trainer '%s'" % trainer_id)
		return
	var foes := []
	for m in def.party:
		var cr := Creature.create(host.dex.get_species(m.species), m.level, host.rng, host.moves)
		if m.has("moves"):
			cr.moves = []
			for mid in m.moves:
				cr.moves.append(cr.make_move_slot(mid, host.moves))
		foes.append(cr)
	var result: Dictionary = await host.battle(foes, {"kind": "trainer", "ai": def.ai, "trainer": def})
	match str(result.get("result", "")):
		"win":
			data.money += int(def.money)
			_set_flag("trainer_" + trainer_id, true)
			if def.win != "":
				await host.say(def.name, _sub(def.win))
		"lose":
			await whiteout()
			_ended = true

## Lost a battle: lose half the money, heal up, back to the last Sanctuary.
func whiteout() -> void:
	var data: GameStateData = host.data
	data.money = data.money / 2
	data.heal_party()
	var ls: Dictionary = data.last_sanctuary
	await host.warp(str(ls.zone), int(ls.pos[0]), int(ls.pos[1]), "down")
	await host.say("", WHITEOUT_LINE)
	await host.say("", WHITEOUT_LINE_2)

func _test(c: Dictionary) -> bool:
	var v: Variant = host.data.flag(str(c.get("flag", "")))
	if c.has("eq"):
		return _loose_eq(v, c.eq)
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return true

static func _loose_eq(a: Variant, b: Variant) -> bool:
	if typeof(a) in [TYPE_INT, TYPE_FLOAT] and typeof(b) in [TYPE_INT, TYPE_FLOAT]:
		return is_equal_approx(float(a), float(b))
	return a == b

func _set_flag(key: String, value: Variant) -> void:
	if typeof(value) == TYPE_FLOAT and value == floorf(value):
		value = int(value)
	host.data.set_flag(key, value)
	if host.has_method("on_flag"):
		host.on_flag(key, value)

func _sub(s: String) -> String:
	return s.replace("{player}", host.data.player_name).replace("{rival}", host.data.rival_name)
