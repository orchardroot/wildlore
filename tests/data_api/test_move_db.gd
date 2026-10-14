extends TestCase

var db := MoveDB.load_default()

func test_loads_starter_moves() -> void:
	for id in ["scrap", "glare", "bramble_lash", "rill_shot", "kindle", "drench"]:
		assert_true(db.has(id), id)

func test_move_fields() -> void:
	var m := db.get_move("kindle")
	assert_eq(m.type, "hearth")
	assert_eq(m.category, "special")
	assert_eq(m.power, 40)

func test_move_numbers_are_ints() -> void:
	var m := db.get_move("quick_nip")
	for key in ["power", "accuracy", "pp", "priority"]:
		assert_eq(typeof(m[key]), TYPE_INT, key)
	assert_eq(m.priority, 1)

func test_effect_defaults() -> void:
	var m := MoveDB.normalise({"id": "x", "effect": {"id": "status", "status": "soaked"}})
	assert_eq(m.effect.chance, 100)
	assert_eq(m.effect.target, "foe")
	assert_eq(MoveDB.normalise({"id": "y"}).effect.id, "none")

func test_unknown_move_is_empty() -> void:
	assert_eq(db.get_move("nope"), {})

func test_duplicates_are_recorded() -> void:
	var d := MoveDB.from_array([{"id": "a"}, {"id": "a"}])
	assert_eq(d.duplicates, ["a"])
