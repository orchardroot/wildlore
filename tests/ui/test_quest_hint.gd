extends TestCase
## "Where next?" mentions one quest under way nearby: on the pause card before the ending, and after it in the
## catch-all's place once side stories and rewilding have had their turn (before the next Fieldbook milestone).

const FIXTURE := "res://tests/support/quest_fixture.json"

func _quests() -> Array:
	return Quests.parse(JsonUtil.read(FIXTURE), "fixture")

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_pause_card_line_for_a_quest_nearby() -> void:
	var d := _data({"q_testshire_hens_started": true})
	assert_eq(MenuLogic.quest_nearby(d, "buxton", _quests()), "Quest, Hen Night: Find the hens on the old road over the moor.")
	assert_eq(MenuLogic.quest_nearby(d, "york", _quests()), "", "not near York")
	d.set_flag("game_complete", true)
	assert_eq(MenuLogic.quest_nearby(d, "buxton", _quests()), "", "after the ending, Still to do covers it")

func test_postgame_catch_all_gives_way_to_a_quest() -> void:
	var o := {"story": [], "postgame": [{"text": "Catch them all.", "town": "macclesfield"}], "rematches": []}
	var sides := [{"id": "none", "zone": "nowhere", "flag_done": "x", "hint": "h"}]
	var d := _data({"game_complete": true, "q_testshire_kettle_started": true, "last_town": "macclesfield"})
	assert_eq(MenuLogic.quest_entry(d, _quests()).get("town", ""), "macclesfield", "ringed at the town of its next step")
	var e := MenuLogic.next_objective(d, 10, o, sides, _quests())
	if Rewild.hint_entry(d).is_empty() and SideStories.next_hint(d, sides).is_empty():
		assert_has(str(e.get("text", "")), "Put the Kettle On")
	var none := _data({"game_complete": true, "last_town": "macclesfield"})
	assert_eq(MenuLogic.quest_entry(none, _quests()), {}, "no quest, no entry")
	assert_false(str(MenuLogic.next_objective(none, 10, o, sides, _quests()).get("text", "")).contains("Quest,"), "and no line")
