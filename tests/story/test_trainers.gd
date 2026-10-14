extends TestCase

func _open(_p: Vector2i) -> bool:
	return false

func test_sight_straight_line_within_range() -> void:
	var open := func(_p): return false
	assert_true(Sight.sees(Vector2i(10, 5), "left", Vector2i(5, 5), open), "5 tiles away is seen")
	assert_true(Sight.sees(Vector2i(10, 5), "left", Vector2i(9, 5), open), "adjacent is seen")
	assert_false(Sight.sees(Vector2i(10, 5), "left", Vector2i(4, 5), open), "6 tiles is out of range")
	assert_true(Sight.sees(Vector2i(2, 2), "down", Vector2i(2, 7), open))
	assert_true(Sight.sees(Vector2i(2, 7), "up", Vector2i(2, 2), open))
	assert_true(Sight.sees(Vector2i(2, 2), "right", Vector2i(7, 2), open))

func test_sight_only_in_facing_direction() -> void:
	var open := func(_p): return false
	assert_false(Sight.sees(Vector2i(10, 5), "right", Vector2i(8, 5), open), "behind")
	assert_false(Sight.sees(Vector2i(10, 5), "left", Vector2i(8, 6), open), "diagonal and off-axis")
	assert_false(Sight.sees(Vector2i(10, 5), "up", Vector2i(10, 6), open), "wrong way")
	assert_false(Sight.sees(Vector2i(10, 5), "left", Vector2i(10, 5), open), "same tile")

func test_blocked_tile_stops_sight() -> void:
	var wall := func(p: Vector2i): return p == Vector2i(8, 5)
	assert_false(Sight.sees(Vector2i(10, 5), "left", Vector2i(6, 5), wall), "wall in between")
	assert_true(Sight.sees(Vector2i(10, 5), "left", Vector2i(9, 5), wall), "in front of the wall is fine")
	assert_false(Sight.sees(Vector2i(10, 5), "left", Vector2i(8, 5), wall), "cannot see into a blocked tile")

func test_defeated_trainers_do_not_retrigger() -> void:
	var data := GameStateData.new()
	var open := func(_p): return false
	var npc := {"id": "dougie", "trainer": "testbed_tester"}
	assert_true(Sight.triggers(npc, data, Vector2i(10, 5), "left", Vector2i(7, 5), open))
	data.set_flag("trainer_testbed_tester")
	assert_false(Sight.triggers(npc, data, Vector2i(10, 5), "left", Vector2i(7, 5), open))
	assert_false(Sight.triggers({"id": "x"}, GameStateData.new(), Vector2i(10, 5), "left", Vector2i(7, 5), open), "not a trainer")

func test_lost_trainer_triggers_again() -> void:
	var data := GameStateData.new()
	var open := func(_p): return false
	var npc := {"id": "dougie", "trainer": "testbed_tester"}
	assert_false(data.flags.has("trainer_testbed_tester"))
	assert_true(Sight.triggers(npc, data, Vector2i(10, 5), "left", Vector2i(7, 5), open), "undefeated trainers stay armed")

func test_walk_path_to_player() -> void:
	assert_eq(Sight.approach_path(Vector2i(10, 5), "left", Vector2i(6, 5)), ["left", "left", "left"])
	assert_eq(Sight.approach_path(Vector2i(2, 2), "down", Vector2i(2, 3)), [])
	assert_eq(Sight.approach_path(Vector2i(2, 7), "up", Vector2i(2, 2)), ["up", "up", "up", "up"])

func test_story_data_loads() -> void:
	var t := StoryData.trainer("testbed_tester")
	assert_eq(t.name, "Dev Dougie")
	assert_eq(t.party.size(), 2)
	assert_eq(t.money, 120)
	assert_true(StoryData.script("testbed", "tester_hello").size() > 0)
	assert_true(StoryData.script("testbed", "nothing_to_say").size() > 0, "common scripts are visible from any zone")
	assert_eq(StoryData.script("testbed", "no_such_script"), [])
	var tscript := StoryData.trainer_script("testbed_tester")
	assert_eq(tscript[tscript.size() - 1], {"do": "battle", "trainer": "testbed_tester"})

func test_validator_catches_bad_scripts() -> void:
	var dex := Fixtures.dex()
	var moves := Fixtures.moves()
	var items := ItemDB.load_default()
	var errs := StoryValidator.validate_commands([
		{"do": "give_item", "item": "nope"},
		{"do": "give_creature", "species": "nope", "level": 3},
		{"do": "battle", "trainer": "nope"},
		{"do": "dance"},
		{"do": "if", "flag": "x", "then": [{"do": "shop", "id": "nope"}]},
		{"do": "say", "text": "ok"},
	], "t", dex, items, {"testbed": true})
	assert_eq(errs.size(), 5, str(errs))
	assert_eq(StoryValidator.validate_commands([{"do": "say", "text": "fine"}], "t", dex, items, {}).size(), 0)
	assert_eq(StoryValidator.validate(dex, moves, items, ZoneData.load_all()), [], "shipped story data is valid")
