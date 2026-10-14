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
