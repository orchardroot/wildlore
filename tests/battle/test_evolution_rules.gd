extends TestCase

func _c(evolves: Dictionary, level := 30) -> Creature:
	var c := Creature.new()
	c.species = {"id": "a", "evolves": evolves}
	c.level = level
	return c

func test_weather_evolution() -> void:
	var c := _c({"to": "b", "level": 22, "weather": "downpour"})
	assert_eq(Progression.evolution_target(c, {"weather": "drizzle"}), "")
	assert_eq(Progression.evolution_target(c, {"weather": "downpour"}), "b")
	assert_eq(Progression.evolution_target(c), "", "no context, no weather evolution")

func test_time_evolution() -> void:
	var c := _c({"to": "b", "level": 20, "time": "night"})
	assert_eq(Progression.evolution_target(c, {"time": "day"}), "")
	assert_eq(Progression.evolution_target(c, {"time": "night"}), "b")
	c.level = 19
	assert_eq(Progression.evolution_target(c, {"time": "night"}), "", "still needs the level")

func test_friendship_evolution() -> void:
	var c := _c({"to": "b", "friendship": 220}, 5)
	c.friendship = 200
	assert_eq(Progression.evolution_target(c), "")
	c.friendship = 220
	assert_eq(Progression.evolution_target(c), "b")

func test_bond_brings_a_level_evolution_on_early() -> void:
	var c := _c({"to": "b", "level": 16, "bond": 220}, 10)
	c.friendship = 100
	assert_eq(Progression.evolution_target(c), "", "neither the level nor the bond yet")
	c.friendship = 220
	assert_eq(Progression.evolution_target(c), "b", "a close bond evolves it before Lv 16")
	c.friendship = 0
	c.level = 16
	assert_eq(Progression.evolution_target(c), "b", "and it still evolves at Lv 16 regardless")

func test_friendship_saved_and_grows() -> void:
	var dex := Dex.load_default()
	var c := Creature.create(dex.get_species("scuttlet"), 5, Rng.new(1), MoveDB.load_default())
	var f0 := c.friendship
	Progression.gain_xp(c, 10000, MoveDB.load_default())
	assert_true(c.friendship > f0, "levelling up makes friends")
	var back := Creature.from_dict(c.to_dict(), dex)
	assert_eq(back.friendship, c.friendship)

func test_real_lines_use_rules() -> void:
	var dex := Dex.load_default()
	assert_eq(str(dex.get_species("croakle").evolves.get("weather", "")), "downpour")
	assert_eq(str(dex.get_species("pepperling").evolves.get("time", "")), "night")

func test_season_evolution() -> void:
	var c := _c({"to": "b", "level": 30, "season": "autumn"})
	assert_eq(Progression.evolution_target(c, {"season": "summer"}), "")
	assert_eq(Progression.evolution_target(c, {"season": "autumn"}), "b")
	assert_eq(Progression.evolution_target(c), "", "no context, no season evolution")

func test_zone_evolution() -> void:
	var c := _c({"to": "b", "level": 30, "zone": ["bath", "somerset_levels"]})
	assert_eq(Progression.evolution_target(c, {"zone": "york"}), "")
	assert_eq(Progression.evolution_target(c, {"zone": "bath"}), "b")
	assert_eq(Progression.evolution_target(c, {"zone": "somerset_levels"}), "b", "any listed zone will do")
	var one := _c({"to": "b", "level": 30, "zone": "cayman"})
	assert_eq(Progression.evolution_target(one, {"zone": "cayman"}), "b", "a single zone id works too")

func test_flag_evolution() -> void:
	var c := _c({"to": "b", "level": 30, "flag": "lang_cert_cy_1"})
	assert_eq(Progression.evolution_target(c, {"flags": {}}), "")
	assert_eq(Progression.evolution_target(c, {"flags": {"lang_cert_cy_1": true}}), "b")
	assert_eq(Progression.evolution_target(c), "", "no flags, no flag evolution")
	c.level = 29
	assert_eq(Progression.evolution_target(c, {"flags": {"lang_cert_cy_1": true}}), "", "still needs the level")

func test_conditions_combine() -> void:
	var c := _c({"to": "b", "level": 30, "season": "winter", "zone": ["bermuda"]})
	assert_eq(Progression.evolution_target(c, {"season": "winter", "zone": "york"}), "")
	assert_eq(Progression.evolution_target(c, {"season": "summer", "zone": "bermuda"}), "")
	assert_eq(Progression.evolution_target(c, {"season": "winter", "zone": "bermuda"}), "b")
