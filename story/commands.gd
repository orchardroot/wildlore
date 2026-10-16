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
var _badge_won := false
var _legend_caught := false

## npc_id is the NPC that owns the script (the default target of move, face and heal).
func _init(h, owner_npc := "") -> void:
	host = h
	npc_id = owner_npc

func run(commands: Array) -> void:
	_ended = false
	_badge_won = false
	_legend_caught = false
	await _run_list(commands)
	# autosave once the whole scene has played, so the save has everything the Keeper's script did after the badge
	# (or after a legend was caught, never mid-script)
	if (_badge_won or _legend_caught) and host.has_method("autosave"):
		host.autosave()

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
			var got := Bag.new(data.bag).add(id, n)
			var nm: String = host.items.get_item(id).get("name", id)
			if got <= 0:
				await host.say("", "Your bag's full of %s already. You leave them for someone else." % nm)
			else:
				await host.sfx("item")
				await host.say("", "%s received %s%s." % [data.player_name, nm, " x%d" % got if got > 1 else ""])
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
			if bool(c.get("intro", false)):
				for line in StoryData.trainer(str(c.get("trainer", ""))).get("intro", []):
					await _exec(line)
			await _battle(str(c.get("trainer", "")))
		"daily":
			# once per in-game day: `key` remembers the day number it last ran on
			var today := int(data.day_count)
			var last: Variant = data.flag(str(c.get("key", "")))
			if last == null or int(last) != today:
				_set_flag(str(c.get("key", "")), today)
				await _run_list(c.get("then", []))
			else:
				await _run_list(c.get("else", []))
		"when":
			await _run_list(c.get("then", []) if _when(str(c.get("cond", ""))) else c.get("else", []))
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
			if picked is String and picked != "" and host.dex.has(picked):
				_set_flag("starter", picked)
				host.data.add_creature(Creature.create(host.dex.get_species(picked), STARTER_LEVEL, host.rng, host.moves))
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
			if b != "":
				_set_flag("badge_" + b, true)
				_badge_won = true
			await host.sfx("badge")
		"end":
			_ended = true
		"ark":
			await host.open_menu("ark")
		"relearn":
			# the move relearner; `set` (optional) gets 1 if a move was learned, 0 if they backed out
			var learned = await host.open_menu("relearn")
			if c.has("set"):
				_set_flag(str(c.set), 1 if learned is Dictionary else 0)
		"sachet_worn":
			await _sachet_worn()
		"legend":
			await _legend(c)
		"rail":
			await _rail()
		"gauntlet":
			await _gauntlet(c)
		"credits":
			await host.open_menu("credits")
			# the credits swapped the music and the ending set game_complete: put the zone's tune back and save
			if host.has_method("zone_music"):
				host.zone_music()
			if host.has_method("autosave"):
				host.autosave()
		"ferry":
			await _ferry(str(c.get("route", "")))
		"whiteout":
			await whiteout()
			_ended = true
		_:
			push_warning("Commands: unknown command '%s'" % c.get("do", ""))

const STARTER_LEVEL := 5

func _battle(trainer_id: String) -> void:
	var def := StoryData.trainer(trainer_id)
	if def.is_empty():
		push_error("Commands: no trainer '%s'" % trainer_id)
		return
	var result := await _fight(def)
	match str(result.get("result", "")):
		"win":
			# prize money is paid by the battle scene, which also announces it
			_set_flag("trainer_" + trainer_id, true)
			if def.win != "":
				await host.say(def.name, _sub(def.win))
		"lose":
			await whiteout()
			_ended = true

## Builds a trainer's party and runs the battle; returns the battle result.
func _fight(def: Dictionary) -> Dictionary:
	var foes := []
	for m in def.party:
		var cr := Creature.create(host.dex.get_species(m.species), m.level, host.rng, host.moves)
		if m.has("moves"):
			cr.moves = []
			for mid in m.moves:
				cr.moves.append(cr.make_move_slot(mid, host.moves))
		foes.append(cr)
	var opts := {"kind": "trainer", "ai": def.ai, "trainer": def}
	if str(def.get("music", "")) != "":
		opts["music"] = str(def.music)
	if bool(def.get("double", false)) and foes.size() >= 2:
		opts["double"] = true  # a 2v2: the trainer sends out two at once
	return await host.battle(foes, opts)

## The Moot: several trainers back to back with no Sanctuary in between. Winning them all sets `flag`.
## Losing any one sends you back to the entrance (`exit`), healed and poorer, with nothing half-won.
func _gauntlet(c: Dictionary) -> void:
	var ids: Array = c.get("trainers", [])
	var prize := 0  # paid only once the whole gauntlet is won, so retries can't farm it
	for i in ids.size():
		var def := StoryData.trainer(str(ids[i]))
		if def.is_empty():
			push_error("Commands: no trainer '%s'" % ids[i])
			return
		for line in def.get("intro", []):
			await _exec(line)
		prize += int(def.get("money", def.get("reward", 0)))
		var fight_def := def.duplicate()
		fight_def["money"] = 0
		fight_def.erase("reward")
		var result := await _fight(fight_def)
		if str(result.get("result", "")) != "win":
			var ex: Dictionary = c.get("exit", {})
			host.data.money = host.data.money / 2
			host.data.heal_party()
			await host.warp(str(ex.get("zone", host.zone_id())), int(ex.get("x", -1)), int(ex.get("y", -1)), "down")
			await host.say("", "You come round at the edge of the stones, patched up and a little humbled. The Moot will wait.")
			_ended = true
			return
		if def.win != "":
			await host.say(def.name, _sub(def.win))
		if i < ids.size() - 1:
			await host.say("", "No rest at the Moot. The next challenger steps forward.")
			while await host.choice("Anything to sort out before the next challenger?", ["Open your bag", "Carry on"]) == 0:
				await host.open_menu("bag")
	if prize > 0:
		host.data.money += prize
		await host.say("", "%s collects £%d in prize money from the Moot." % [host.data.player_name, prize])
	_set_flag(str(c.get("flag", "gauntlet_won")), true)

## A legendary encounter: a wild battle you can't run from, with its own music. Catching it sets `flag`;
## knocking it out doesn't, so it can be met again. Losing whites out as usual.
func _legend(c: Dictionary) -> void:
	var sp: Dictionary = host.dex.get_species(str(c.get("species", "")))
	if sp.is_empty():
		push_error("Commands: no legend species '%s'" % c.get("species", ""))
		return
	host.data.mark_seen(str(sp.id))
	var foe := Creature.create(sp, int(c.get("level", 40)), host.rng, host.moves)
	var result: Dictionary = await host.battle([foe], {"kind": "wild", "no_run": true, "music": str(c.get("music", "legend"))})
	match str(result.get("result", "")):
		"caught":
			_set_flag(str(c.get("flag", "caught_" + str(sp.id))), true)
			_legend_caught = true
		"lose":
			await whiteout()
			_ended = true

## A Lavender Sachet ran out on the overworld: say so, and offer another if there's one in the bag.
func _sachet_worn() -> void:
	await host.say("", Repel.WORN_LINE)
	if Bag.new(host.data.bag).count(Repel.ITEM) < 1:
		return
	if await host.choice("Use another Lavender Sachet?", ["Yes", "No"]) == 0:
		var r := Repel.use(host.data, Repel.ITEM, host.items)
		await host.sfx("confirm" if r.ok else "bump")
		await host.say("", str(r.text))

func _rail() -> void:
	if int(host.data.bag.get("rail_pass", 0)) <= 0:
		await host.say("", "The ticket barrier beeps sadly. You'll need a Rail Pass.")
		return
	var dest = await host.open_menu("travel:rail")
	if dest == null or str(dest) == "":
		return
	var a := Travel.rail_arrival(str(dest))
	await host.sfx("train")
	await host.warp(str(a.zone), a.pos.x, a.pos.y, "down")
	_ended = true

func _ferry(route: String) -> void:
	var a := Travel.ferry_arrival(route, host.zone_id())
	if a.is_empty():
		push_error("Commands: no ferry route '%s'" % route)
		return
	var pick: int = await host.choice("Sail to %s?" % Travel.town_name(str(a.zone)), ["All aboard", "Not today"])
	if pick != 0:
		return
	await host.music(str(Travel.ferries()[route].get("music", "ferry")))
	await host.say("", str(Travel.ferries()[route].get("card", "The ferry crosses the sea.")))
	await host.warp(str(a.zone), a.pos.x, a.pos.y, "down")
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

## Conditions that aren't flags: "night" (the in-game clock) and "caught_all" (every species in the Fieldbook caught).
func _when(cond: String) -> bool:
	match cond:
		"night":
			return GameClock.phase(host.data.clock_minutes) == "night"
		"caught_all":
			return host.data.caught.size() >= host.dex.ids().size()
	push_warning("Commands: unknown condition '%s'" % cond)
	return false

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
	var total: int = host.dex.ids().size()
	var got: int = host.data.caught.size()
	return s.replace("{player}", host.data.player_name).replace("{rival}", host.data.rival_name) \
		.replace("{caught}", str(got)).replace("{left}", str(maxi(0, total - got))).replace("{total}", str(total))
