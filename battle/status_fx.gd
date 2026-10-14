class_name StatusFX
extends RefCounted
## What each status condition does. Pure functions over a Creature; Battle turns the results into events.

static func inflict(c: Creature, status: String, rng: Rng) -> bool:
	if c.status != "" or c.is_fainted():
		return false
	c.status = status
	match status:
		"asleep":
			c.status_turns = rng.roll_int(1, 3)
		"muddled":
			c.status_turns = rng.roll_int(2, 5)
		_:
			c.status_turns = 0
	return true

static func before_move(c: Creature, rng: Rng) -> Dictionary:
	var r := {"can_act": true, "reason": "", "self_hit": false, "cured_status": ""}
	match c.status:
		"asleep":
			if c.status_turns > 0:
				c.status_turns -= 1
				r.can_act = false
				r.reason = "asleep"
			else:
				r.cured_status = _cure(c)
		"chilled":
			if rng.chance(25):
				r.can_act = false
				r.reason = "chilled"
		"muddled":
			c.status_turns -= 1
			if c.status_turns < 0:
				r.cured_status = _cure(c)
			elif rng.chance(33):
				r.can_act = false
				r.self_hit = true
				r.reason = "muddled"
	return r

static func end_of_turn_damage(c: Creature) -> int:
	match c.status:
		"hexed":
			return maxi(1, c.max_hp() / 16)
		"stung":
			return maxi(1, c.max_hp() / 8)
	return 0

static func speed_mult(c: Creature) -> float:
	return 0.75 if c.status == "soaked" else 1.0

static func incoming_mult(c: Creature, move_type: String) -> float:
	return 1.5 if c.status == "soaked" and move_type == "storm" else 1.0

static func _cure(c: Creature) -> String:
	var old := c.status
	c.status = ""
	c.status_turns = 0
	return old
