extends TestCase

func test_full_hp_wicker_chance() -> void:
	# (3m - 2m) * 45 * 1 / 3m = 15; 15 / 255
	assert_near(Catching.chance(Fixtures.creature("spikkin", 5), "wicker", "day"), 15.0 / 255.0)

func test_low_hp_and_sleep_help() -> void:
	var c := Fixtures.creature("spikkin", 5)
	var full := Catching.chance(c, "wicker", "day")
	c.hp = 1
	var low := Catching.chance(c, "wicker", "day")
	c.status = "asleep"
	assert_true(low > full * 2.5)
	assert_near(Catching.chance(c, "wicker", "day"), low * 2.0)

func test_situational_snares() -> void:
	var otter := Fixtures.creature("holtling", 5)
	assert_eq(Catching.snare_bonus("water", otter, "day"), 3.0)
	assert_eq(Catching.snare_bonus("water", Fixtures.creature("kindlet", 5), "day"), 1.0)
	assert_eq(Catching.snare_bonus("night", otter, "night"), 3.0)
	assert_eq(Catching.snare_bonus("night", otter, "day"), 1.0)
	assert_eq(Catching.snare_bonus("silver", otter, "day"), 2.0)

func test_chance_is_capped() -> void:
	var easy := Creature.create(Fixtures.species("easy", ["kin"], 50, {"catch_rate": 255}), 5, FixedRng.new(), Fixtures.moves())
	easy.hp = 1
	easy.status = "asleep"
	assert_eq(Catching.chance(easy, "silver", "day"), 1.0)

func test_catch_in_wild_battle() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	var foe := Fixtures.creature("spikkin", 5)
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [foe], {"rng": r})
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": true})
	assert_true(b.over)
	assert_eq(b.winner, -1)
	assert_eq(b.caught, foe)

func test_failed_catch_lets_foe_act() -> void:
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [Fixtures.creature("spikkin", 5)])
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": false})
	assert_false(b.over)
	assert_eq(ev[1].type, "move")

func test_cannot_catch_trainer_creature() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	var b := Fixtures.battle([Fixtures.creature("kindlet", 5)], [Fixtures.creature("spikkin", 5)], {"kind": "trainer", "rng": r})
	var ev := b.take_turn({"type": "catch", "snare": "wicker"}, {"type": "move", "slot": 0})
	assert_eq(ev[0], {"type": "catch", "success": false, "reason": "trainer"})
	assert_eq(b.caught, null)
