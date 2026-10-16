extends TestCase
## Legends are marked in the data (`"legend": true`), not guessed from the catch rate.

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

func _has(errors: Array, needle: String) -> bool:
	for e in errors:
		if needle in e:
			return true
	return false

func test_legend_flag_is_accepted_and_must_be_a_bool() -> void:
	assert_eq(_errors_for([_sp("a", {"legend": true})]), [])
	assert_true(_has(_errors_for([_sp("a", {"legend": "yes"})]), "legend must be true or false"))

func test_rock_bottom_catch_rate_must_be_marked_legend() -> void:
	assert_true(_has(_errors_for([_sp("a", {"catch_rate": 3})]), "mark it"))
	assert_eq(_errors_for([_sp("a", {"catch_rate": 3, "legend": true})]), [])

func test_every_story_legend_is_marked_in_the_data() -> void:
	var dex := Dex.load_default()
	for id in ["ddraig", "greenman", "morrigan", "enbarr", "cusith", "nessie", "shuck", "lambton", "herne", "bran", "megalorn", "tylwyth"]:
		assert_true(bool(dex.get_species(id).get("legend", false)), id + " is a legend")
	assert_false(bool(dex.get_species("kindlet").get("legend", false)))
