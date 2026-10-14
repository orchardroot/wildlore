class_name BattleFlow
extends RefCounted
## The sequencing of one battle: ask for an action, let the foe pick, resolve the turn, play the events, then handle
## everything that follows (XP, level-ups, move learning, replacements, catching, rewards, evolution).
## Plain class with an injected `ui` so it runs headless in tests. The ui provides (each may await):
##   intro(flow), say(lines, hold), play_events(events, ctx), choose_action(flow) -> Dictionary,
##   choose_replacement(flow) -> int, choose_forget(creature, move_id, flow) -> int (-1 to skip),
##   evolve_anim(creature, to_species) -> bool (false if cancelled), xp_gained(creature, level_events).
## choose_action returns {"kind": "fight", "slot"} | {"kind": "switch", "index"} | {"kind": "run"}
## | {"kind": "item", "item": id, "target": party index (ignored for snares)}.
## Double battles (opts.double): choose_action and choose_replacement are asked once per field position, with
## `acting_pos` saying which; a fight choice may carry "target" (foe position, default the first foe standing).
## XP in doubles: every player creature standing on the field when a foe faints (the faint event's witnesses)
## earns that foe's full XP reward. Both fought it, and doubles are rare trainer fights, so nobody is short-changed.

signal species_caught(species_id: String)

var battle: Battle
var data: GameStateData
var dex: Dex
var move_db: MoveDB
var items: ItemDB
var ui
var trainer: Dictionary
var ai_tier := "wild"
var result := {}
var log: Array[String] = []   # every line shown, in order (handy for tests)
var bag: Bag
var _levelled: Array = []
var _xp_given := {}
var _snare: Dictionary = {}
var _catch_chance := 0.0

var _evo_ctx := {}
var _no_run := false
var acting_pos := 0  # doubles: the field position the ui is choosing for
var _switching := []  # doubles: party indices already picked to switch in this turn

func _init(p_data: GameStateData, p_dex: Dex, p_moves: MoveDB, p_chart: TypeChart, p_items: ItemDB, p_rng: Rng, foe_party: Array, opts: Dictionary, p_ui) -> void:
	data = p_data
	dex = p_dex
	move_db = p_moves
	items = p_items
	ui = p_ui
	trainer = opts.get("trainer", {})
	_no_run = bool(opts.get("no_run", false))
	_evo_ctx = {"weather": str(opts.get("weather", "clear")), "time": str(opts.get("time", "day"))}
	ai_tier = str(opts.get("ai", "wild"))
	bag = Bag.new(data.bag)
	battle = Battle.new(data.party, foe_party, {
		"chart": p_chart, "move_db": p_moves, "item_db": p_items, "rng": p_rng,
		"kind": opts.get("kind", "wild"), "weather": opts.get("weather", "clear"), "time": opts.get("time", "day"),
		"double": bool(opts.get("double", false)),
	})

func ctx() -> Dictionary:
	return EventPlayer.make_ctx(battle, trainer)

func is_wild() -> bool:
	return battle.kind == "wild"

## 1 to 3 wobbles: a likelier snare wobbles more before it either clicks or breaks. A caught creature always wobbles thrice.
static func wobbles_for(chance: float, success: bool) -> int:
	if success:
		return 3
	return clampi(int(chance * 3.0) + 1, 1, 3)

## Bag entries usable in this battle: [{"id", "name", "count", "kind", "desc"}].
func battle_items() -> Array:
	var out := []
	if items == null:
		return out
	for id in items.ids():
		var n := bag.count(id)
		var it := items.get_item(id)
		if n < 1 or not bool(it.get("battle", false)):
			continue
		var kind := str(it.get("kind", ""))
		if kind == "snare" and not is_wild():
			continue
		if kind in ["heal", "cure", "revive", "pp", "snare"]:
			out.append({"id": id, "name": it.get("name", id), "count": n, "kind": kind, "desc": it.get("desc", "")})
	return out

## Would this item do anything to that party member? Tries it on a copy, so nothing changes.
func item_check(item_id: String, target: int) -> Dictionary:
	var party: Array = battle.parties[Battle.PLAYER]
	if target < 0 or target >= party.size():
		return {"ok": false, "text": "Nothing happened."}
	var copy := Creature.from_dict(party[target].to_dict(), dex)
	return ItemEffects.apply(items.get_item(item_id), copy)

func run() -> Dictionary:
	var foe := battle.current(Battle.FOE)
	for c in battle.actives(Battle.FOE):
		data.mark_seen(c.species.id)
	await ui.intro(self)
	if foe != null and not battle.over:
		await _say(_intro_lines())
	while not battle.over:
		var pa: Variant = await _player_actions()
		var fa: Variant = BattleAI.choose(battle, Battle.FOE, ai_tier)
		var events := battle.take_turn(pa, fa)
		await _play(events)
		await _after_events(events)
	await _conclude()
	return result

func _intro_lines() -> Array[String]:
	var out: Array[String] = []
	if battle.double:
		var t := str(trainer.get("name", "A keeper"))
		out.append("%s wants to battle!" % t if not is_wild() else "Wild creatures appeared!")
		out.append("%s sends out %s!" % [t, _names(battle.actives(Battle.FOE))])
		out.append("Go! %s!" % _names(battle.actives(Battle.PLAYER)))
		return out
	var foe := battle.current(Battle.FOE)
	var me := battle.current(Battle.PLAYER)
	if is_wild():
		out.append("A wild %s appeared!" % foe.display_name())
	else:
		var t := str(trainer.get("name", "A keeper"))
		out.append("%s wants to battle!" % t)
		out.append("%s sends out %s!" % [t, foe.display_name()])
	out.append("Go! %s!" % me.display_name())
	return out

static func _names(cs: Array) -> String:
	return " and ".join(cs.map(func(c): return c.display_name()))

func _say(lines: Array, hold := 0.0) -> void:
	for l in lines:
		log.append(str(l))
	await ui.say(lines, hold)

## Singles: one action. Doubles: an Array with an action per field position ({} where nobody is standing).
func _player_actions() -> Variant:
	if not battle.double:
		return await _player_action()
	var out := []
	_switching = []
	for pos in battle.positions():
		acting_pos = pos
		var c := battle.current_at(Battle.PLAYER, pos)
		out.append({} if c == null or c.is_fainted() else await _player_action())
	acting_pos = 0
	return out

## The first foe position with someone standing in it.
func default_target() -> int:
	for p in battle.positions():
		var c := battle.current_at(Battle.FOE, p)
		if c != null and not c.is_fainted():
			return p
	return 0

func _player_action() -> Dictionary:
	while true:
		var c: Dictionary = await ui.choose_action(self)
		match str(c.get("kind", "")):
			"fight":
				if battle.double:
					return {"type": "move", "slot": int(c.slot), "target": c.get("target", default_target())}
				return {"type": "move", "slot": int(c.slot)}
			"switch":
				if battle.double:
					var i := int(c.index)
					if i in battle.active[Battle.PLAYER] or i in _switching:
						await _say(["%s is already going in!" % battle.parties[Battle.PLAYER][i].display_name()])
						continue
					_switching.append(i)
				return {"type": "switch", "index": int(c.index)}
			"run":
				if _no_run:
					await _say(["The air hums. It won't let you leave."])
					continue
				if not is_wild():
					await _say(["No! There's no running from a keeper battle!"])
					continue
				return {"type": "run"}
			"item":
				var action := await _item_action(c)
				if not action.is_empty():
					return action
	return {}

func _item_action(c: Dictionary) -> Dictionary:
	var id := str(c.item)
	var it := items.get_item(id)
	if bag.count(id) < 1 or it.is_empty():
		await _say(["You don't have any."])
		return {}
	if str(it.kind) == "snare":
		if battle.double:
			await _say(["You can't throw a snare into a double battle!"])
			return {}
		if not is_wild():
			await _say(["You can't snare another keeper's creature!"])
			return {}
		bag.remove(id)
		_snare = it
		_catch_chance = Catching.chance(battle.current(Battle.FOE), str(it.snare), battle.time)
		return {"type": "catch", "snare": str(it.snare)}
	var target := int(c.get("target", 0))
	var check := item_check(id, target)
	if not check.ok:
		await _say([str(check.text)])
		return {}
	bag.remove(id)
	return {"type": "item", "item": id, "target": target}

func _play(events: Array) -> void:
	var party: Array = battle.parties[Battle.PLAYER]
	for i in events.size():
		var e: Dictionary = events[i]
		if e.type == "catch" and str(e.get("reason", "")) == "":
			e["snare_name"] = _snare.get("name", "snare")
			e["wobbles"] = wobbles_for(_catch_chance, bool(e.success))
		elif e.type == "item":
			var t := int(e.get("target", 0))
			if t >= 0 and t < party.size():
				var at: int = battle.active[Battle.PLAYER].find(t) if battle.double else -1
				e["shown_hp"] = EventPlayer.hp_after_item(events, i, party[t], at)
	var cx := ctx()
	for e in events:
		log.append_array(EventPlayer.lines_for(e, cx))
	await ui.play_events(events, cx)

func _after_events(events: Array) -> void:
	for e in events:
		if e.type == "faint" and int(e.side) == Battle.FOE:
			await _award_xp(e)
	if battle.over:
		return
	for e in events:
		if e.type == "invalid" and str(e.get("reason", "")) == "bad_switch":
			return
	for pos in battle.positions():
		if battle.needs_switch_at(Battle.PLAYER, pos):
			acting_pos = pos
			await _replace_player(pos)
	acting_pos = 0
	for pos in battle.positions():
		if battle.needs_switch_at(Battle.FOE, pos):
			await _replace_foe(pos)

func _replace_player(pos := 0) -> void:
	var party: Array = battle.parties[Battle.PLAYER]
	for attempt in 4:
		var idx: int = await ui.choose_replacement(self)
		var ev := battle.force_switch(Battle.PLAYER, idx, pos)
		if ev[0].type != "invalid":
			await _play(ev)
			return
	for i in party.size():  # the ui kept picking nonsense: take the first creature that can stand
		if not party[i].is_fainted() and i not in battle.active[Battle.PLAYER]:
			await _play(battle.force_switch(Battle.PLAYER, i, pos))
			return

func _replace_foe(pos := 0) -> void:
	var party: Array = battle.parties[Battle.FOE]
	for i in party.size():
		if not party[i].is_fainted() and i not in battle.active[Battle.FOE]:
			var ev := battle.force_switch(Battle.FOE, i, pos)
			data.mark_seen(party[i].species.id)
			await _play(ev)
			return

## XP for a fainted foe. Singles: the creature out now. Doubles: every witness still standing (see the top).
func _award_xp(faint_ev: Dictionary = {}) -> void:
	var foe := battle.current(Battle.FOE)
	var earners := [battle.current(Battle.PLAYER)]
	if battle.double and faint_ev.has("index"):
		foe = battle.parties[Battle.FOE][int(faint_ev.index)]
		earners = []
		for i in faint_ev.get("witnesses", []):
			var c: Creature = battle.parties[Battle.PLAYER][int(i)]
			if not c.is_fainted():
				earners.append(c)
	if _xp_given.has(foe):
		return
	_xp_given[foe] = true
	var amount := Progression.xp_reward(foe, not is_wild())
	for me in earners:
		await _give_xp(me, foe, amount)

func _give_xp(me: Creature, foe: Creature, amount: int) -> void:
	Progression.add_training(me, foe.species)
	var evs := Progression.gain_xp(me, amount, move_db)
	await _say(["%s gained %d XP!" % [me.display_name(), amount]])
	await ui.xp_gained(me, evs)
	for e in evs:
		match str(e.type):
			"level_up":
				if me not in _levelled:
					_levelled.append(me)
				await _say(["%s grew to level %d!" % [me.display_name(), int(e.level)]])
			"learned":
				await _say(["%s learned %s!" % [me.display_name(), _move_name(str(e.move))]])
			"learn_pending":
				await _learn_prompt(me, str(e.move))

func _move_name(id: String) -> String:
	return str(move_db.get_move(id).get("name", id.capitalize()))

func _learn_prompt(c: Creature, move_id: String) -> void:
	var slot: int = await ui.choose_forget(c, move_id, self)
	if slot >= 0 and slot < c.moves.size():
		var old := str(c.moves[slot].id)
		Progression.replace_move(c, slot, move_id, move_db)
		await _say(["%s forgot %s and learned %s!" % [c.display_name(), _move_name(old), _move_name(move_id)]])
	else:
		await _say(["%s did not learn %s." % [c.display_name(), _move_name(move_id)]])

func _conclude() -> void:
	var who := data.player_name
	match battle.winner:
		Battle.PLAYER:
			var money := int(trainer.get("money", trainer.get("reward", 0))) if not is_wild() else 0
			var defeat := str(trainer.get("defeat", ""))
			if defeat != "":
				await _say([defeat])
			if money > 0:
				data.money += money
				await _say(["%s got £%d for winning!" % [who, money]], 0.4)
			result = {"result": "win", "caught": null, "money": money}
		Battle.FOE:
			await _say(["%s is out of creatures that can fight!" % who], 0.5)
			result = {"result": "lose", "caught": null, "money": 0}
		_:
			if battle.caught != null:
				await _after_catch(battle.caught)
				result = {"result": "caught", "caught": battle.caught, "money": 0}
			else:
				result = {"result": "ran", "caught": null, "money": 0}
	if result.result != "lose":
		await _evolutions()

func _after_catch(c: Creature) -> void:
	c.reset_stages()
	var first := not data.caught.has(c.species.id)
	var where := data.add_creature(c)
	species_caught.emit(c.species.id)
	if where == "party":
		await _say(["%s joined your party!" % c.display_name()])
	else:
		await _say(["Your party is full, so %s went to the Ark." % c.display_name()])
	if first:
		await ui.first_catch(c)

func _evolutions() -> void:
	for c in _levelled:
		if c not in data.party:
			continue
		var to: String = Progression.evolution_target(c, _evo_ctx)
		if to == "" or not dex.has(to):
			continue
		var to_sp := dex.get_species(to)
		var old_name: String = c.display_name()
		await _say(["What? %s is evolving!" % old_name])
		var go: bool = await ui.evolve_anim(c, to_sp)
		if go:
			Progression.evolve(c, to_sp)
			data.mark_caught(to_sp.id)
			await _say(["%s evolved into %s!" % [old_name, to_sp.name]], 0.5)
		else:
			await _say(["%s stopped evolving." % old_name])
