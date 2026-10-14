extends TestCase

func _creature(evolves) -> Creature:
	var sp := Fixtures.species("a", ["kin"], 50, {"evolves": evolves})
	return Creature.create(sp, 10, FixedRng.new(), Fixtures.moves())

func test_item_evolution_target() -> void:
	var c := _creature({"to": "b", "item": "whitby_jet"})
	assert_eq(Progression.evolution_target_with_item(c, "whitby_jet"), "b")
	assert_eq(Progression.evolution_target_with_item(c, "cup_of_tea"), "")

func test_level_evolution_ignores_items() -> void:
	var c := _creature({"to": "b", "level": 5})
	assert_eq(Progression.evolution_target_with_item(c, "whitby_jet"), "")
	assert_eq(Progression.evolution_target(c), "b")

func test_item_evolution_not_triggered_by_level() -> void:
	var c := _creature({"to": "b", "item": "whitby_jet"})
	assert_eq(Progression.evolution_target(c), "")

func test_no_evolution() -> void:
	assert_eq(Progression.evolution_target_with_item(_creature(null), "whitby_jet"), "")
