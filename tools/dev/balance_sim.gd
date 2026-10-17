extends SceneTree
## Simulates a party against a trainer many times with the trainer-tier AI on both sides.
## godot --headless --path . -s res://tools/dev/balance_sim.gd -- <trainer_id> <species:level,...> [runs]
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var dex := Dex.load_default()
	var moves := MoveDB.load_default()
	var chart := TypeChart.load_default()
	var def := StoryData.trainer(a[0])
	var runs := int(a[2]) if a.size() > 2 else 200
	var offset := int(a[3]) if a.size() > 3 else 0  # added to every foe level (tuning)
	var wins := 0
	for r in runs:
		if OS.get_environment("SIMDBG") != "":
			print("run ", r)
		var rng := Rng.new(r + 1)
		var mine := []
		for e in a[1].split(","):
			var kv := e.split(":")
			mine.append(Creature.create(dex.get_species(kv[0]), int(kv[1]), rng, moves))
		var foes := []
		for m in def.party:
			foes.append(Creature.create(dex.get_species(m.species), maxi(2, int(m.level) + offset), rng, moves))
		# NOKNACKS=1 in the environment: knacks off (the 1.x rules, for before/after comparisons)
		var b := Battle.new(mine, foes, {"chart": chart, "move_db": moves, "rng": rng, "kind": "trainer", "knacks": OS.get_environment("NOKNACKS") == ""})
		var guard := 0
		while not b.over and guard < 300:
			guard += 1
			for side in [Battle.PLAYER, Battle.FOE]:
				if b.needs_switch(side):
					var party: Array = b.parties[side]
					for i in party.size():
						if not party[i].is_fainted():
							b.force_switch(side, i)
							break
			if b.over:
				break
			b.take_turn(_best(b, moves), BattleAI.choose(b, Battle.FOE, str(def.ai)))
		if b.winner == Battle.PLAYER:
			wins += 1
		if r == 0:
			print("first battle: turns %d, over %s, winner %d, mine %s, foes %s" % [guard, b.over, b.winner, mine.map(func(c): return "%s %d/%d" % [c.species.id, c.hp, c.max_hp()]), foes.map(func(c): return "%s %d/%d" % [c.species.id, c.hp, c.max_hp()])])
	print("SIM %s vs [%s] offset %d: player wins %d/%d" % [a[0], a[1], offset, wins, runs])
	quit()

## The player picks the highest-scoring move, like the playtest bot (and a sensible human).
func _best(b: Battle, moves: MoveDB) -> Dictionary:
	var me := b.current(Battle.PLAYER)
	var foe := b.current(Battle.FOE)
	var best := 0
	var best_score := -1.0
	for i in me.moves.size():
		if int(me.moves[i].pp) <= 0:
			continue
		var s := BattleAI.score(b, me, foe, moves.get_move(me.moves[i].id))
		if s > best_score:
			best_score = s
			best = i
	return {"type": "move", "slot": best}
