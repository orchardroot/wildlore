class_name BattleAI
extends RefCounted
## Chooses actions. "wild": random usable move. "trainer": best expected damage. "keeper": also switches out of bad match-ups.
## In a double battle `choose` returns an Array with one action per field position (see choose_double).

## A steady roll for damage estimates: the middle of the damage spread, never a crit.
class Steady extends Rng:
	func roll() -> float:
		return 0.5
	func roll_int(a: int, _b: int) -> int:
		return a
	func roll_range(a: float, b: float) -> float:
		return (a + b) * 0.5
	func chance(_percent: float) -> bool:
		return false
	func pick(arr: Array):
		return arr[0]

static var _steady := Steady.new()

## Singles: one action Dictionary. Doubles: an Array of actions, one per position.
static func choose(b: Battle, side: int, tier: String) -> Variant:
	if b.double:
		return choose_double(b, side, tier)
	var me := b.current(side)
	var foe := b.current(1 - side)
	var usable := _usable(b, me)
	if usable.is_empty():
		return {"type": "move", "slot": 0}  # Battle falls back to Flail
	if tier == "wild":
		var slot: int = b.rng.pick(usable)
		return {"type": "move", "slot": slot}
	if tier == "keeper":
		var sw := _better_switch(b, side)
		if sw >= 0:
			return {"type": "switch", "index": sw}
	var best: int = usable[0]
	var best_score := -1.0
	for i in usable:
		var s := score(b, me, foe, b.move_db.get_move(me.moves[i].id))
		if s > best_score:
			best_score = s
			best = i
	return {"type": "move", "slot": best}

static func score(b: Battle, me: Creature, foe: Creature, move: Dictionary) -> float:
	var fx: Dictionary = move.get("effect", {})
	var fx_id := str(fx.get("id", "none"))
	if move.category == "status":
		match fx_id:
			"heal_self":
				return _heal_score(me)
			"protect":
				return _protect_score(b, me, foe)
			"set_weather":
				return _weather_score(b, me, foe, str(fx.get("weather", "")))
			"cure_team":
				var ill := 0
				for c in b.parties[_side_of(b, me)]:
					if c.status != "" and not c.is_fainted():
						ill += 1
				return 45.0 * ill if ill > 0 else 1.0
		if fx_id == "status" and (Charms.blocks_status(foe) or (b.knacks_on and Knacks.blocks_status(foe, str(fx.get("status", ""))))):
			return 5.0  # a Brigid's Cross or a knack: no point
		return 30.0 if fx_id == "status" and foe.status == "" else 20.0
	var s := attack_score(b, me, foe, move)
	match fx_id:
		"drain":
			s *= 1.0 + (1.0 - float(me.hp) / me.max_hp()) * float(fx.get("frac", 50)) / 100.0
		"recoil":
			s *= 1.0 - float(fx.get("frac", 25)) / 200.0 * (2.0 if me.hp * 3 <= me.max_hp() else 1.0)
		"flinch":
			if b._speed_of(me) > b._speed_of(foe):
				s *= 1.0 + float(fx.get("chance", 0)) / 200.0
		"set_weather":
			s += maxf(0.0, _weather_score(b, me, foe, str(fx.get("weather", ""))) - 1.0) * 0.5
	if _expect_protect(b, foe):
		s *= 0.6  # the foe looks ready to brace: don't waste the big hit on it every time
	return s

## Expected value of a damaging move: power in this weather x effectiveness x accuracy x STAB, with charms, knacks
## and the number of hits.
static func attack_score(b: Battle, me: Creature, foe: Creature, move: Dictionary, weather := "") -> float:
	var w := b.weather if weather == "" else weather
	if b.knacks_on and Knacks.immune(foe, move):
		return 0.0
	var eff := b.chart.effectiveness(move.type, foe.types())
	var acc := 100.0 if MoveFX.sure_in(move, w) else float(move.accuracy) * Weather.accuracy_mod(w)
	var s := float(MoveFX.power_in(move, w)) * eff * acc / 100.0
	s *= MoveFX.average_hits(move.get("effect", {}))
	s *= Weather.damage_mod(w, move.type)
	s *= Charms.incoming_mult(foe, move.type) * Charms.outgoing_mult(me, move.type)
	if b.knacks_on:
		s *= Knacks.defend_mult(foe, move, eff) * Knacks.weather_power(me, move, w)
	if move.type in me.types():
		s *= 1.5
	return s

static func _side_of(b: Battle, c: Creature) -> int:
	return Battle.PLAYER if c in b.parties[Battle.PLAYER] else Battle.FOE

static func _heal_score(me: Creature) -> float:
	var left := float(me.hp) / me.max_hp()
	if left <= 0.35:
		return 250.0
	if left <= 0.55:
		return 80.0
	return 1.0

## Protect: never twice running; worth it when low and about to be hit first (stalling out a weather or a status
## tick, or waiting for a heal), otherwise a rare change of pace.
static func _protect_score(b: Battle, me: Creature, foe: Creature) -> float:
	if b.guarded_last_turn(me):
		return 0.0
	var left := float(me.hp) / me.max_hp()
	if left <= 0.35 and b._speed_of(foe) > b._speed_of(me):
		return 120.0
	if foe.status in ["hexed", "stung"]:
		return 40.0
	return 4.0

## The foe has a protect move it could use this turn and is in a spot where it might.
static func _expect_protect(b: Battle, foe: Creature) -> bool:
	if b.guarded_last_turn(foe) or foe.hp * 3 > foe.max_hp():
		return false
	for m in foe.moves:
		if str(b.move_db.get_move(m.id).get("effect", {}).get("id", "")) == "protect" and int(m.pp) > 0:
			return true
	return false

## Calling a weather: how much it helps this side's best attacks (and knacks) over the other side's, times the
## damage those attacks do, for about two turns' worth. 0 when the weather is already that.
static func _weather_score(b: Battle, me: Creature, foe: Creature, w: String) -> float:
	if w == "" or b.weather == w:
		return 0.0
	var side := _side_of(b, me)
	var mine := _weather_gain(b, b.parties[side], b.actives(1 - side), w)
	var theirs := _weather_gain(b, b.parties[1 - side], b.actives(side), w)  # their bench may like it too
	var net := mine - theirs
	if net <= 0.05:
		return 1.0
	var best := 1.0
	for i in _usable(b, me):
		var mv := b.move_db.get_move(me.moves[i].id)
		if mv.category != "status":
			best = maxf(best, attack_score(b, me, foe, mv))
	return net * best * 2.0

## Average change in a team's best attack multiplier (against `targets`) from the current weather to `w`, plus a
## little for each knack that likes `w` (speed, healing, hiding).
static func _weather_gain(b: Battle, team: Array, targets: Array, w: String) -> float:
	var total := 0.0
	var bonus := 0.0
	var n := 0
	for c in team:
		if c.is_fainted():
			continue
		n += 1
		var now := 0.0
		var then := 0.0
		for slot in c.moves:
			var mv := b.move_db.get_move(str(slot.id))
			if mv.is_empty() or mv.category == "status":
				continue
			for t in targets:
				now = maxf(now, attack_score(b, c, t, mv, b.weather))
				then = maxf(then, attack_score(b, c, t, mv, w))
		if now > 0.0:
			total += then / now - 1.0
		if b.knacks_on:
			if Knacks.speed_mult(c, w) > Knacks.speed_mult(c, b.weather):
				bonus += 0.25
			if Knacks.turn_heal(c, w) > Knacks.turn_heal(c, b.weather):
				bonus += 0.2
			if Knacks.evade_mult(c, w) < Knacks.evade_mult(c, b.weather):
				bonus += 0.2
	return total / maxf(1.0, n) + bonus

## Slots with PP left whose move still exists in the database.
static func _usable(b: Battle, c: Creature) -> Array:
	var out := []
	for i in c.moves.size():
		if int(c.moves[i].pp) > 0 and b.move_db.has(c.moves[i].id):
			out.append(i)
	return out

static func _best_score(b: Battle, c: Creature, foe: Creature) -> float:
	var best := 0.0
	for i in _usable(b, c):
		best = maxf(best, score(b, c, foe, b.move_db.get_move(c.moves[i].id)))
	return best

static func _better_switch(b: Battle, side: int) -> int:
	var foe := b.current(1 - side)
	var mine := _best_score(b, b.current(side), foe)
	var party: Array = b.parties[side]
	for i in party.size():
		var c: Creature = party[i]
		if i in b.active[side] or c.is_fainted() or c.hp * 2 <= c.max_hp():
			continue
		if _best_score(b, c, foe) > mine * 2.0:
			return i
	return -1

## Doubles: an action per field position, each move with a "target" foe position. Positions with nobody standing
## get {} (the battle skips them). Trainers weigh every move against every foe, favour a knockout, and do not
## pile both attacks onto a foe the first one is already expected to finish. Keepers do not switch in doubles.
static func choose_double(b: Battle, side: int, tier: String) -> Array:
	var out := []
	var planned := {}  # foe position -> damage already aimed at it this turn
	for pos in b.positions():
		var me := b.current_at(side, pos)
		if me == null or me.is_fainted():
			out.append({})
			continue
		out.append(_double_action(b, side, me, tier, planned))
	return out

static func _double_action(b: Battle, side: int, me: Creature, tier: String, planned: Dictionary) -> Dictionary:
	var foes := []
	for p in b.positions():
		var c := b.current_at(1 - side, p)
		if c != null and not c.is_fainted():
			foes.append(p)
	if foes.is_empty():
		foes = [0]
	var usable := _usable(b, me)
	if usable.is_empty():
		return {"type": "move", "slot": 0, "target": foes[0]}
	if tier == "wild":
		return {"type": "move", "slot": b.rng.pick(usable), "target": b.rng.pick(foes)}
	var best := {"type": "move", "slot": usable[0], "target": foes[0]}
	var best_score := -1.0
	for i in usable:
		var move := b.move_db.get_move(me.moves[i].id)
		if str(move.get("target", "")) == "all_foes" and foes.size() > 1:
			var total := 0.0
			for p in foes:
				total += _target_score(b, me, b.current_at(1 - side, p), move, float(planned.get(p, 0.0)), Battle.SPREAD_MULT)
			if total > best_score:
				best_score = total
				best = {"type": "move", "slot": i, "target": foes[0]}
			continue
		for p in foes:
			var s := _target_score(b, me, b.current_at(1 - side, p), move, float(planned.get(p, 0.0)), 1.0)
			if s > best_score:
				best_score = s
				best = {"type": "move", "slot": i, "target": p}
	var chosen := b.move_db.get_move(me.moves[best.slot].id)
	if chosen.category != "status":
		var spread := str(chosen.get("target", "")) == "all_foes" and foes.size() > 1
		for p in (foes if spread else [best.target]):
			planned[p] = float(planned.get(p, 0.0)) + estimate(b, me, b.current_at(1 - side, p), chosen, Battle.SPREAD_MULT if spread else 1.0)
	return best

static func _target_score(b: Battle, me: Creature, foe: Creature, move: Dictionary, already: float, mult: float) -> float:
	var s := score(b, me, foe, move) * mult
	if move.category == "status":
		return s
	var left := float(foe.hp) - already
	if left <= 0.0:
		return s * 0.1  # a partner is already finishing it off
	if estimate(b, me, foe, move, mult) >= left:
		return s * 2.0 + 100.0
	return s

## Expected damage of a move, middle roll and no crit.
static func estimate(b: Battle, me: Creature, foe: Creature, move: Dictionary, mult := 1.0) -> float:
	return float(DamageCalc.compute(me, foe, move, b.chart, b.weather, _steady, 0.0, mult).damage)
