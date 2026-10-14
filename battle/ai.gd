class_name BattleAI
extends RefCounted
## Chooses actions. "wild": random usable move. "trainer": best expected damage. "keeper": also switches out of bad match-ups.

static func choose(b: Battle, side: int, tier: String) -> Dictionary:
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
		return 30.0 if fx.get("id") == "status" and foe.status == "" else 20.0
	var s := float(move.power) * b.chart.effectiveness(move.type, foe.types()) * float(move.accuracy) / 100.0
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
		if i == b.active[side] or c.is_fainted() or c.hp * 2 <= c.max_hp():
			continue
		if _best_score(b, c, foe) > mine * 2.0:
			return i
	return -1
