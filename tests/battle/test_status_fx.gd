extends TestCase

func test_inflict_only_when_healthy_and_clear() -> void:
	var c := Fixtures.creature("kindlet", 10)
	assert_true(StatusFX.inflict(c, "stung", FixedRng.new()))
	assert_false(StatusFX.inflict(c, "hexed", FixedRng.new()))
	assert_eq(c.status, "stung")

func test_asleep_skips_turns_then_wakes() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "asleep", FixedRng.new())  # low bound: 1 turn
	var r := StatusFX.before_move(c, FixedRng.new())
	assert_false(r.can_act)
	assert_eq(r.reason, "asleep")
	r = StatusFX.before_move(c, FixedRng.new())
	assert_true(r.can_act)
	assert_eq(r.cured_status, "asleep")
	assert_eq(c.status, "")

func test_chilled_sometimes_loses_turn() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "chilled", FixedRng.new())
	var r := FixedRng.new()
	r.f = 0.1
	assert_false(StatusFX.before_move(c, r).can_act)
	r.f = 0.9
	assert_true(StatusFX.before_move(c, r).can_act)

func test_muddled_can_self_hit_and_wears_off() -> void:
	var c := Fixtures.creature("kindlet", 10)
	StatusFX.inflict(c, "muddled", FixedRng.new())  # 2 turns
	var r := FixedRng.new()
	r.f = 0.0
	assert_true(StatusFX.before_move(c, r).self_hit)
	assert_true(StatusFX.before_move(c, r).self_hit)
	var last := StatusFX.before_move(c, r)
	assert_true(last.can_act)
	assert_eq(last.cured_status, "muddled")

func test_end_of_turn_damage() -> void:
	var c := Fixtures.creature("kindlet", 50)
	c.status = "stung"
	assert_eq(StatusFX.end_of_turn_damage(c), c.max_hp() / 8)
	c.status = "hexed"
	assert_eq(StatusFX.end_of_turn_damage(c), c.max_hp() / 16)
	c.status = ""
	assert_eq(StatusFX.end_of_turn_damage(c), 0)

func test_soaked_slows_and_conducts() -> void:
	var c := Fixtures.creature("kindlet", 10)
	c.status = "soaked"
	assert_eq(StatusFX.speed_mult(c), 0.75)
	assert_eq(StatusFX.incoming_mult(c, "storm"), 1.5)
	assert_eq(StatusFX.incoming_mult(c, "hearth"), 1.0)
