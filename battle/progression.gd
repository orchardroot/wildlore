class_name Progression
extends RefCounted
## XP, levelling, move learning, evolution and training.

static func xp_reward(foe: Creature, trainer: bool) -> int:
	var x: int = foe.species.base_xp * foe.level / 7
	return int(x * 1.5) if trainer else x

static func gain_xp(c: Creature, amount: int, move_db: MoveDB) -> Array:
	var ev := []
	if c.level >= Rules.MAX_LEVEL:
		return ev
	c.xp += amount
	while c.level < Rules.MAX_LEVEL and c.xp >= Rules.xp_for_level(c.species.growth, c.level + 1):
		var old_max := c.max_hp()
		c.level += 1
		if not c.is_fainted():
			c.hp += c.max_hp() - old_max
		ev.append({"type": "level_up", "level": c.level})
		for id in moves_learned_at(c.species, c.level):
			if c.has_move(id):
				continue
			if c.moves.size() < Rules.MAX_MOVES:
				c.moves.append(c.make_move_slot(id, move_db))
				ev.append({"type": "learned", "move": id})
			else:
				ev.append({"type": "learn_pending", "move": id})
	return ev

static func moves_learned_at(sp: Dictionary, level: int) -> Array:
	var out := []
	for entry in sp.learnset:
		if entry[0] == level:
			out.append(entry[1])
	return out

static func replace_move(c: Creature, slot: int, id: String, move_db: MoveDB) -> void:
	c.moves[slot] = c.make_move_slot(id, move_db)

static func evolution_target(c: Creature) -> String:
	var evo = c.species.get("evolves")
	if not (evo is Dictionary):
		return ""
	if evo.has("level") and c.level >= int(evo.level):
		return evo.to
	return ""

## Item evolutions ({"to", "item"}): the target if this item triggers one for this creature, else "".
static func evolution_target_with_item(c: Creature, item_id: String) -> String:
	var evo = c.species.get("evolves")
	if evo is Dictionary and evo.has("item") and str(evo.item) == item_id:
		return str(evo.to)
	return ""

static func evolve(c: Creature, new_sp: Dictionary) -> void:
	var missing := c.max_hp() - c.hp
	c.species = new_sp
	c.hp = maxi(1, c.max_hp() - missing)

static func add_training(c: Creature, foe_species: Dictionary) -> void:
	var total := 0
	for s in Rules.STATS:
		total += int(c.training[s])
	if total >= Rules.TRAINING_TOTAL_CAP:
		return
	var best: String = Rules.STATS[0]
	for s in Rules.STATS:
		if foe_species.base[s] > foe_species.base[best]:
			best = s
	c.training[best] = mini(int(c.training[best]) + 1, Rules.TRAINING_STAT_CAP)
