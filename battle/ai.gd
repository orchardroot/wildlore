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
	if move.category == "status":
		var fx: Dictionary = move.get("effect", {})
		if fx.get("id") == "status" and Charms.blocks_status(foe):
			return 5.0  # a Brigid's Cross: no point
		return 30.0 if fx.get("id") == "status" and foe.status == "" else 20.0
	var s := float(move.power) * b.chart.effectiveness(move.type, foe.types()) * float(move.accuracy) / 100.0
	s *= Charms.incoming_mult(foe, move.type) * Charms.outgoing_mult(me, move.type)
	if move.type in me.types():
		s *= 1.5
	return s

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
