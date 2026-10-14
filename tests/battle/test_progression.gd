extends TestCase

func test_xp_reward() -> void:
	var foe := Fixtures.creature("spikkin", 7)  # base_xp 62
	assert_eq(Progression.xp_reward(foe, false), 62)
	assert_eq(Progression.xp_reward(foe, true), 93)

func test_level_up_and_learn() -> void:
	var c := Fixtures.creature("kindlet", 4)  # knows scrap, glare
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 5) - c.xp, Fixtures.moves())
	assert_eq(c.level, 5)
	assert_eq(ev, [{"type": "level_up", "level": 5}, {"type": "learned", "move": "kindle"}])
	assert_true(c.has_move("kindle"))

func test_multiple_levels_in_one_go() -> void:
	var c := Fixtures.creature("kindlet", 5)
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 8) - c.xp, Fixtures.moves())
	assert_eq(c.level, 8)
	assert_eq(ev.filter(func(e): return e.type == "level_up").size(), 3)

func test_level_up_keeps_damage_taken() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.take_damage(5)
	var missing := c.max_hp() - c.hp
	Progression.gain_xp(c, Rules.xp_for_level("medium", 11) - c.xp, Fixtures.moves())
	assert_eq(c.max_hp() - c.hp, missing)

func test_full_moveset_makes_learning_pending() -> void:
	var c := Fixtures.creature("kindlet", 12)  # scrap, glare, kindle, quick_nip
	var ev := Progression.gain_xp(c, Rules.xp_for_level("medium", 13) - c.xp, Fixtures.moves())
	assert_has(ev, {"type": "learn_pending", "move": "smoulder"})
	Progression.replace_move(c, 0, "smoulder", Fixtures.moves())
	assert_eq(c.moves[0].id, "smoulder")
	assert_eq(c.moves[0].pp, 15)

func test_level_cap() -> void:
	var c := Fixtures.creature("kindlet", 100)
	assert_eq(Progression.gain_xp(c, 999999, Fixtures.moves()), [])
	assert_eq(c.level, 100)

func test_evolution() -> void:
	var c := Fixtures.creature("kindlet", 15)
	assert_eq(Progression.evolution_target(c), "")
	c.level = 16
	assert_eq(Progression.evolution_target(c), "emberdrey")
	c.take_damage(4)
	var missing := c.max_hp() - c.hp
	Progression.evolve(c, Fixtures.dex().get_species("emberdrey"))
	assert_eq(c.species.id, "emberdrey")
	assert_eq(c.max_hp() - c.hp, missing)

func test_final_stage_never_evolves() -> void:
	assert_eq(Progression.evolution_target(Fixtures.creature("pyredrey", 99)), "")

func test_training_goes_to_foes_best_stat_and_caps() -> void:
	var c := Fixtures.creature("spikkin", 10)
	var foe_sp := Fixtures.dex().get_species("kindlet")  # best base stat: spd 66
	Progression.add_training(c, foe_sp)
	assert_eq(c.training.spd, 1)
	c.training.spd = Rules.TRAINING_STAT_CAP
	Progression.add_training(c, foe_sp)
	assert_eq(c.training.spd, Rules.TRAINING_STAT_CAP)
	c.training = {"hp": 100, "atk": 100, "def": 100, "lore": 0, "ward": 0, "spd": 0}
	Progression.add_training(c, Fixtures.dex().get_species("holtling"))
	assert_eq(c.training.spd, 0)
