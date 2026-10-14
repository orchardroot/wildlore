extends TestCase

func test_downpour_boosts_water_and_damps_fire() -> void:
	assert_eq(Weather.damage_mod("downpour", "brook"), 1.5)
	assert_eq(Weather.damage_mod("downpour", "hearth"), 0.5)

func test_sunshine_boosts_fire_and_plants() -> void:
	assert_eq(Weather.damage_mod("sunshine", "hearth"), 1.5)
	assert_eq(Weather.damage_mod("sunshine", "hedgerow"), 1.5)

func test_clear_is_neutral() -> void:
	assert_eq(Weather.damage_mod("clear", "hearth"), 1.0)

func test_fog_hurts_accuracy() -> void:
	assert_eq(Weather.accuracy_mod("fog"), 0.85)
	assert_eq(Weather.accuracy_mod("drizzle"), 1.0)

func test_sunshine_morale_is_player_only() -> void:
	assert_eq(Weather.crit_mult("sunshine", 0), 2.0)
	assert_eq(Weather.crit_mult("sunshine", 1), 1.0)

func test_pick_is_weighted_and_has_a_default() -> void:
	assert_eq(Weather.pick({}, Rng.new(1)), "clear")
	assert_eq(Weather.pick({"drizzle": 0, "fog": 5}, Rng.new(1)), "fog")
	var r := FixedRng.new()
	r.f = 0.0
	assert_eq(Weather.pick({"drizzle": 50, "sunshine": 1}, r), "drizzle")
	r.f = 0.999
	assert_eq(Weather.pick({"drizzle": 50, "sunshine": 1}, r), "sunshine")
