extends TestCase

var chart := TypeChart.load_default()
var moves := MoveDB.load_default()

func _sp(id: String, extra := {}) -> Dictionary:
	var sp := {"id": id, "name": id.capitalize(), "types": ["kin"],
		"base": {"hp": 50, "atk": 50, "def": 50, "lore": 50, "ward": 50, "spd": 50},
		"growth": "medium", "catch_rate": 45, "base_xp": 60, "learnset": [[1, "scrap"]],
		"evolves": null, "habitat": [], "dex": {"text": "t", "fact": "f"}, "sprite": id}
	sp.merge(extra, true)
	return sp

func _errors_for(species: Array) -> Array:
	return DataValidator.validate(chart, Dex.from_array(species), moves)

func _has_error_containing(errors: Array, needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false

func test_real_data_is_valid() -> void:
	assert_eq(DataValidator.validate(chart, Dex.load_default(), moves), [])

func test_minimal_species_is_valid() -> void:
	assert_eq(_errors_for([_sp("a")]), [])

func test_unknown_learnset_move() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"learnset": [[1, "nope"]]})]), "'nope' does not exist"))

func test_unknown_type() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"types": ["lava"]})]), "unknown type 'lava'"))

func test_too_many_types() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"types": ["kin", "bog", "fae"]})]), "1 or 2 types"))

func test_missing_evolution_target() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"evolves": {"to": "b", "level": 10}})]), "unknown species 'b'"))

func test_missing_fact() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"dex": {"text": "t", "fact": ""}})]), "real-world fact"))

func test_bad_base_stat() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"base": {"hp": 50}})]), "base atk"))

func test_duplicate_species() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a"), _sp("a")]), "'a' defined more than once"))

func test_bad_move() -> void:
	var bad := MoveDB.from_array([{"id": "m", "name": "M", "type": "kin", "category": "physical", "power": 0, "accuracy": 100, "pp": 10}])
	var errors := DataValidator.validate(chart, Dex.from_array([]), bad)
	assert_true(_has_error_containing(errors, "needs power"))
