extends TestCase

func test_stats_follow_formula() -> void:
	# kindlet lore base 56, level 10, iv 0: (112 * 10) / 100 = 11, + 5 = 16
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.calc_stat("lore"), 16)
	# hp base 40: (80 * 10) / 100 = 8, + 10 + 10 = 28
	assert_eq(c.max_hp(), 28)
	assert_eq(c.hp, 28)

func test_nature_raises_and_lowers() -> void:
	var c := Fixtures.creature("kindlet", 50)
	var neutral := c.calc_stat("spd")
	c.nature = "cheeky"
	assert_eq(c.calc_stat("spd"), int(neutral * 1.1))
	assert_eq(c.nature_mod("def"), 0.9)

func test_default_moves_are_last_four_learned() -> void:
	var c := Fixtures.creature("kindlet", 13)
	var ids := c.moves.map(func(m): return m.id)
	assert_eq(ids, ["glare", "kindle", "quick_nip", "smoulder"])
	assert_eq(c.moves[1].pp, 25)

func test_stage_multipliers() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.change_stage("atk", 2), 2)
	assert_eq(c.stage_mult("atk"), 2.0)
	c.change_stage("atk", -4)
	assert_eq(c.stage_mult("atk"), 0.5)
	assert_eq(c.change_stage("def", -9), -6)
	assert_eq(c.change_stage("def", -1), 0)
	c.change_stage("acc", 3)
	assert_eq(c.stage_mult("acc"), 2.0)

func test_damage_and_heal_clamp() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_eq(c.take_damage(500), 28)
	assert_true(c.is_fainted())
	assert_eq(c.heal(500), 28)

func test_round_trip_through_json() -> void:
	var c := Creature.create(Fixtures.dex().get_species("holtling"), 12, Rng.new(42), Fixtures.moves())
	c.nickname = "Bolly"
	c.take_damage(3)
	var text := JSON.stringify(c.to_dict())
	var back := Creature.from_dict(JSON.parse_string(text), Fixtures.dex())
	assert_eq(back.to_dict(), c.to_dict())
	assert_eq(typeof(back.ivs.hp), TYPE_INT)
	assert_eq(back.display_name(), "Bolly")

func test_seeded_creation_is_repeatable() -> void:
	var sp := Fixtures.dex().get_species("spikkin")
	var a := Creature.create(sp, 5, Rng.new(7), Fixtures.moves())
	var b := Creature.create(sp, 5, Rng.new(7), Fixtures.moves())
	assert_eq(a.to_dict(), b.to_dict())

func test_rng_chance_edges() -> void:
	var r := Rng.new(1)
	assert_true(r.chance(100))
	assert_false(r.chance(0))
