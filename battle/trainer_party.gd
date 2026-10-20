class_name TrainerParty
extends RefCounted
## Builds a trainer's party from its data (data/trainers/*.json), for the story and the balance simulator alike.
## Each party entry: {"species", "level", "moves"?: [ids] (an authored moveset, else the last four learned),
## "held"?: a charm id, "tea"?: a healing item id the keeper AI may pour for it once, below 40% HP (see BattleAI)}.
## The tea rides on the creature as metadata (TEA): foe creatures are never saved, and Battle clears it once drunk.

const TEA := &"keeper_tea"

## `flags`: the save's flags, for a trainer off the main line ("scaled_floor": its party is authored at that par
## and lifted to the story's, each creature evolved to suit; see ParLevel). Absent: fixed levels.
static func build(def: Dictionary, dex: Dex, rng: Rng, moves: MoveDB, level_offset := 0, flags := {}) -> Array:
	var foes := []
	var scaled := def.has("scaled_floor")
	if scaled:
		level_offset += ParLevel.offset(flags, int(def.scaled_floor))
	for m in def.get("party", []):
		var lv := int(m.level) if level_offset == 0 else clampi(int(m.level) + level_offset, 2, Rules.MAX_LEVEL)  # offset: sim tuning, or scaling
		var sp := ParLevel.stage(dex, str(m.species), lv) if scaled else str(m.species)
		var cr := Creature.create(dex.get_species(sp), lv, rng, moves)
		if m.has("moves"):
			cr.moves = []
			for mid in m.moves:
				cr.moves.append(cr.make_move_slot(str(mid), moves))
		if str(m.get("held", "")) != "":
			cr.held = str(m.held)
		if str(m.get("tea", "")) != "":
			cr.set_meta(TEA, str(m.tea))
		foes.append(cr)
	return foes
