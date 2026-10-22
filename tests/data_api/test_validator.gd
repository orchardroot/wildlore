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

func test_effect_chance_out_of_range() -> void:
	var bad := MoveDB.from_array([{"id": "m", "name": "M", "type": "kin", "category": "status", "power": 0, "accuracy": 100, "pp": 10, "effect": {"id": "status", "status": "stung", "chance": 150}}])
	assert_true(_has_error_containing(DataValidator.validate(chart, Dex.from_array([]), bad), "chance"))

func test_priority_out_of_range() -> void:
	var bad := MoveDB.from_array([{"id": "m", "name": "M", "type": "kin", "category": "physical", "power": 40, "accuracy": 100, "pp": 10, "priority": 9}])
	assert_true(_has_error_containing(DataValidator.validate(chart, Dex.from_array([]), bad), "priority"))

func test_evolution_level_out_of_range() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"evolves": {"to": "b", "level": 0}}), _sp("b")]), "evolution level"))

# --- Fieldbook teaching: `real` and `names` (docs/design/fieldbook_teaching.md)

func test_teaching_keys_are_optional_and_checked_when_present() -> void:
	assert_eq(_errors_for([_sp("a", {"real": "A true thing.", "names": {"cy": "ci", "ga": "madra", "gd": "cù"}})]), [])
	assert_eq(_errors_for([_sp("a", {"names": {}})]), [], "a place or a machine has no local names")
	assert_true(_has_error_containing(_errors_for([_sp("a", {"real": ""})]), "non-empty sentence"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"real": 3})]), "non-empty sentence"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"real": "Hedgehogs " + char(0x2014) + " spiny."})]), "em-dash in real"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"real": "f"})]), "repeats the fact"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"names": ["ci"]})]), "names must be a dictionary"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"names": {"en": "dog"}})]), "unknown language 'en'"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"names": {"cy": ""}})]), "names.cy must be a non-empty string"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"names": {"ga": 7}})]), "names.ga must be a non-empty string"))
	assert_true(_has_error_containing(_errors_for([_sp("a", {"names": {"gd": "c" + char(0x2014)}})]), "em-dash in names.gd"))

func test_malformed_learnset_is_reported_not_crashed() -> void:
	assert_true(_has_error_containing(_errors_for([_sp("a", {"learnset": [[5], "x", [1, "scrap"]]})]), "malformed learnset"))
