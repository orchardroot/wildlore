extends TestCase
## BattleAI in double battles: an action per foe on the field, each with a sensible target.

func _mon(id: String, spd: int, move_ids := ["scrap"], hp := 200, types := ["kin"]) -> Creature:
	var base := {"hp": hp, "atk": 50, "def": 50, "lore": 50, "ward": 50, "spd": spd}
	var c := Creature.create(Fixtures.species(id, types, 50, {"base": base}), 20, FixedRng.new(), Fixtures.moves())
	c.moves = []
	for m in move_ids:
		c.moves.append(c.make_move_slot(m, Fixtures.moves()))
	return c

func _double(player: Array, foe: Array, opts := {}) -> Battle:
	var o := {"kind": "trainer", "double": true}
	o.merge(opts, true)
	return Fixtures.battle(player, foe, o)

func test_ai_returns_an_action_per_active_foe_with_valid_targets() -> void:
	var b := _double([Fixtures.creature("holtling", 10), Fixtures.creature("spikkin", 10)],
		[Fixtures.creature("kindlet", 10), Fixtures.creature("kindlet", 10)])
	var acts = BattleAI.choose(b, Battle.FOE, "trainer")
	assert_true(acts is Array)
	assert_eq(acts.size(), 2)
	for a in acts:
		assert_eq(a.type, "move")
		assert_true(int(a.target) in [0, 1])
	assert_eq(acts[0].target, 1, "kindle is super effective on Spikkin, who stands at position 1")
	assert_eq(acts[0].slot, 2)

func test_ai_goes_for_the_knockout() -> void:
	var low := _mon("pb", 50)
	low.hp = 1
	var b := _double([_mon("pa", 50), low], [_mon("fa", 50), _mon("fb", 50)])
	var acts: Array = BattleAI.choose(b, Battle.FOE, "trainer")
	assert_eq(acts[0].target, 1)
	assert_eq(acts[1].target, 0, "no need for both to pile on the one already finished")

func test_ai_wild_doubles_still_target_a_living_foe() -> void:
	var gone := _mon("pa", 50)
	var b := _double([gone, _mon("pb", 50)], [_mon("fa", 50), _mon("fb", 50)])
	gone.hp = 0
	for a in BattleAI.choose(b, Battle.FOE, "wild"):
		assert_eq(a.target, 1)

func test_ai_singles_unchanged_shape() -> void:
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [Fixtures.creature("kindlet", 10)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "trainer"), {"type": "move", "slot": 2})
