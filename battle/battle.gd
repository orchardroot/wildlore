class_name Battle
extends RefCounted
## One battle, resolved a turn at a time. Pure logic: callers submit actions and render the returned events.
## Event and action shapes are documented in docs/superpowers/plans/2026-10-14-plan-1-foundations-and-battle-core.md (Task 11).

const PLAYER := 0
const FOE := 1
const FLAIL := {"id": "flail", "name": "Flail", "type": "", "category": "physical", "power": 40, "accuracy": 100, "pp": 1, "priority": 0, "effect": {"id": "none"}}
const SELF_HIT := {"id": "self_hit", "name": "Muddled", "type": "", "category": "physical", "power": 40, "accuracy": 100, "pp": 1, "priority": 0, "effect": {"id": "none"}}

var parties := [[], []]
var active := [0, 0]
var kind := "wild"
var weather := "clear"
var time := "day"
var chart: TypeChart
var move_db: MoveDB
var rng: Rng
var over := false
var winner := -1
var caught: Creature = null
var run_attempts := 0
var _pending: Array = []  # events raised before the first turn (a battle that starts already decided)

func _init(player_party: Array, foe_party: Array, opts: Dictionary) -> void:
	parties = [player_party, foe_party]
	chart = opts.chart
	move_db = opts.move_db
	kind = opts.get("kind", "wild")
	weather = opts.get("weather", "clear")
	time = opts.get("time", "day")
	rng = opts.get("rng", Rng.new(opts.get("seed", 0)))
	for side in [PLAYER, FOE]:
		for c in parties[side]:
			c.reset_stages()
		active[side] = maxi(0, _first_able(side))
	_check_end(_pending)

func current(side: int) -> Creature:
	var party: Array = parties[side]
	return party[active[side]] if not party.is_empty() else null

func needs_switch(side: int) -> bool:
	return not over and current(side).is_fainted()

func take_turn(player_action: Dictionary, foe_action: Dictionary) -> Array:
	var ev := _pending
	_pending = []
	if over:
		return ev
	for side in [PLAYER, FOE]:
		if needs_switch(side):
			return [{"type": "invalid", "side": side, "reason": "needs_switch"}]
	var actions := [player_action, foe_action]
	for side in _order(actions):
		if over:
			break
		if current(side).is_fainted():
			continue
		var a: Dictionary = actions[side]
		match a.type:
			"switch":
				_do_switch(side, int(a.index), ev)
			"run":
				if side == PLAYER:
					_do_run(side, ev)
			"catch":
				if side != PLAYER:
					continue
				_do_catch(str(a.get("snare", "wicker")), ev)
			"move":
				_do_move(side, int(a.slot), ev)
		_check_end(ev)
	if not over:
		_end_of_turn(ev)
	return ev

## Bring in a replacement after a faint, between turns.
## Returns [{"type": "invalid", ...}] when the index cannot be sent out.
func force_switch(side: int, index: int) -> Array:
	var ev := []
	_do_switch(side, index, ev)
	if ev.is_empty():
		ev.append({"type": "invalid", "side": side, "reason": "bad_switch"})
	return ev

func _order(actions: Array) -> Array:
	var keys := []
	for side in [PLAYER, FOE]:
		var a: Dictionary = actions[side]
		var prio := 10 if a.type != "move" else _priority(side, int(a.slot))
		keys.append([prio, _speed(side)])
	var first := 0
	if keys[0][0] != keys[1][0]:
		first = PLAYER if keys[0][0] > keys[1][0] else FOE
	elif actions[0].type != "move":
		first = PLAYER
	elif keys[0][1] != keys[1][1]:
		first = PLAYER if keys[0][1] > keys[1][1] else FOE
	else:
		first = rng.roll_int(0, 1)
	return [first, 1 - first]

func _priority(side: int, slot: int) -> int:
	return int(_peek_move(current(side), slot).get("priority", 0))

func _speed(side: int) -> float:
	var c := current(side)
	return c.battle_stat("spd") * StatusFX.speed_mult(c)

func _peek_move(c: Creature, slot: int) -> Dictionary:
	if slot < 0 or slot >= c.moves.size() or int(c.moves[slot].pp) <= 0:
		return FLAIL
	var move := move_db.get_move(c.moves[slot].id)
	return move if not move.is_empty() else FLAIL  # a save can outlive a renamed move

func _do_move(side: int, slot: int, ev: Array) -> void:
	var user := current(side)
	var target_side := 1 - side
	var target := current(target_side)
	if target.is_fainted():
		return
	var check := StatusFX.before_move(user, rng)
	if check.cured_status != "":
		ev.append({"type": "status_cured", "side": side, "status": check.cured_status})
	if not check.can_act:
		if check.self_hit:
			var hurt: int = DamageCalc.compute(user, user, SELF_HIT, chart, "clear", rng, 0.0).damage
			user.take_damage(hurt)
			ev.append({"type": "self_hit", "side": side, "amount": hurt, "hp": user.hp})
			if user.is_fainted():
				_faint(side, ev)
		else:
			ev.append({"type": "cant_act", "side": side, "reason": check.reason})
		return
	var move := _peek_move(user, slot)
	if move != FLAIL:
		user.moves[slot].pp -= 1
	ev.append({"type": "move", "side": side, "user": user.display_name(), "move": move.id})
	if not _hits(user, move):
		ev.append({"type": "miss", "side": side})
		return
	if move.category != "status":
		var res := DamageCalc.compute(user, target, move, chart, weather, rng, DamageCalc.CRIT_CHANCE * Weather.crit_mult(weather, side))
		if res.effectiveness == 0.0:
			ev.append({"type": "no_effect", "side": target_side})
			return
		var dealt := target.take_damage(res.damage)
		ev.append({"type": "damage", "side": target_side, "amount": dealt, "hp": target.hp, "effectiveness": res.effectiveness, "crit": res.crit})
		if target.is_fainted():
			_faint(target_side, ev)
	_apply_effect(side, move, ev)

func _hits(user: Creature, move: Dictionary) -> bool:
	var fx: Dictionary = move.get("effect", {})
	if move.category == "status" and fx.get("target") == "self":
		return true
	var acc := float(move.accuracy) * user.stage_mult("acc") * Weather.accuracy_mod(weather)
	return rng.chance(acc)

func _apply_effect(side: int, move: Dictionary, ev: Array) -> void:
	var fx: Dictionary = move.get("effect", {"id": "none"})
	if fx.id == "none":
		return
	var to_side := side if fx.get("target", "foe") == "self" else 1 - side
	var who := current(to_side)
	if who.is_fainted() or not rng.chance(float(fx.get("chance", 100))):
		return
	match fx.id:
		"stat":
			var applied := who.change_stage(fx.stat, int(fx.stages))
			ev.append({"type": "stat", "side": to_side, "stat": fx.stat, "delta": applied})
		"status":
			if StatusFX.inflict(who, fx.status, rng):
				ev.append({"type": "status", "side": to_side, "status": fx.status})

func _do_switch(side: int, index: int, ev: Array) -> void:
	var party: Array = parties[side]
	if index < 0 or index >= party.size() or index == active[side] or party[index].is_fainted():
		return
	current(side).reset_stages()
	active[side] = index
	ev.append({"type": "switch", "side": side, "index": index, "user": current(side).display_name()})

func _do_run(side: int, ev: Array) -> void:
	if kind != "wild" or side != PLAYER:
		ev.append({"type": "run", "side": side, "success": false})
		return
	run_attempts += 1
	var ok := _speed(PLAYER) >= _speed(FOE) or rng.chance(40.0 + 10.0 * run_attempts)
	ev.append({"type": "run", "side": side, "success": ok})
	if ok:
		_finish(-1, ev)

func _do_catch(snare: String, ev: Array) -> void:
	if kind != "wild":
		ev.append({"type": "catch", "success": false, "reason": "trainer"})
		return
	var foe := current(FOE)
	var ok := Catching.attempt(foe, snare, time, rng)
	ev.append({"type": "catch", "success": ok})
	if ok:
		caught = foe
		_finish(-1, ev)

func _faint(side: int, ev: Array) -> void:
	ev.append({"type": "faint", "side": side, "user": current(side).display_name()})

func _end_of_turn(ev: Array) -> void:
	for side in [PLAYER, FOE]:
		var c := current(side)
		if c.is_fainted():
			continue
		var dmg := StatusFX.end_of_turn_damage(c)
		if dmg > 0:
			c.take_damage(dmg)
			ev.append({"type": "status_damage", "side": side, "status": c.status, "amount": dmg, "hp": c.hp})
			if c.is_fainted():
				_faint(side, ev)
	_check_end(ev)

func _check_end(ev: Array) -> void:
	if over:
		return
	if _first_able(PLAYER) < 0:
		_finish(FOE, ev)
	elif _first_able(FOE) < 0:
		_finish(PLAYER, ev)

func _finish(who: int, ev: Array) -> void:
	over = true
	winner = who
	ev.append({"type": "end", "winner": who})

func _first_able(side: int) -> int:
	var party: Array = parties[side]
	for i in party.size():
		if not party[i].is_fainted():
			return i
	return -1
