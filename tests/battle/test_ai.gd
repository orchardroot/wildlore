extends TestCase

func test_wild_picks_a_usable_move() -> void:
	var foe := Fixtures.creature("kindlet", 10)
	foe.moves[0].pp = 0
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [foe])
	assert_eq(BattleAI.choose(b, 1, "wild"), {"type": "move", "slot": 1})

func test_trainer_prefers_super_effective() -> void:
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [Fixtures.creature("kindlet", 10)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "trainer"), {"type": "move", "slot": 2})  # kindle

func test_keeper_switches_out_of_bad_matchup() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 20)],
		[Fixtures.creature("spikkin", 20), Fixtures.creature("holtling", 20)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "keeper"), {"type": "switch", "index": 1})

func test_keeper_stays_when_matchup_is_fine() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 20)],
		[Fixtures.creature("holtling", 20), Fixtures.creature("spikkin", 20)], {"kind": "trainer"})
	assert_eq(BattleAI.choose(b, 1, "keeper").type, "move")

func test_no_pp_left_still_returns_an_action() -> void:
	var foe := Fixtures.creature("kindlet", 10)
	for m in foe.moves:
		m.pp = 0
	var b := Fixtures.battle([Fixtures.creature("spikkin", 10)], [foe])
	assert_eq(BattleAI.choose(b, 1, "trainer"), {"type": "move", "slot": 0})
