extends TestCase
## Quests (data/quests/*.json): state from save flags, what the Quest Log shows, the toasts when a flag moves a quest
## on, the "Where next?" line for a quest nearby, and the validator. Uses the fixture in tests/support, never a real
## region's file.

const FIXTURE := "res://tests/support/quest_fixture.json"

func _list() -> Array:
	return Quests.parse(JsonUtil.read(FIXTURE), "fixture")

func _kettle() -> Dictionary:
	return _list()[0]

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_parse_reads_the_contract_and_notes_the_file() -> void:
	var l := _list()
	assert_eq(l.size(), 2)
	assert_eq(str(l[0].id), "testshire_kettle")
	assert_eq(l[0].steps.size(), 3)
	assert_eq(str(l[0]._file), "fixture", "each quest remembers its file (for validator messages)")
	assert_eq(Quests.parse(null, "x"), [], "a broken file is no quests, not a crash")
	assert_eq(Quests.parse({"quests": "nope"}, "x"), [])

func test_not_started_until_the_start_flag() -> void:
	var q := _kettle()
	assert_eq(Quests.status(_data(), q), Quests.NOT_STARTED)
	assert_eq(Quests.status(_data({"q_testshire_kettle_1": true}), q), Quests.NOT_STARTED, "a step flag alone doesn't start it")

func test_current_step_is_the_first_whose_flag_is_unset() -> void:
	var q := _kettle()
	var d := _data({"q_testshire_kettle_started": true})
	assert_eq(Quests.status(d, q), Quests.ACTIVE)
	assert_eq(Quests.step_index(d, q), 0)
	d.set_flag("q_testshire_kettle_1", true)
	assert_eq(Quests.step_index(d, q), 1)
	assert_eq(str(Quests.current_step(d, q).zone), "buxton")
	d.set_flag("q_testshire_kettle_3", true)  # out of order: still the first unset
	assert_eq(Quests.step_index(d, q), 1)

func test_falsy_flags_do_not_count() -> void:
	var q := _kettle()
	var d := _data({"q_testshire_kettle_started": 1, "q_testshire_kettle_1": 0, "q_testshire_kettle_done": ""})
	assert_eq(Quests.status(d, q), Quests.ACTIVE)
	assert_eq(Quests.step_index(d, q), 0)

func test_done_flag_finishes_it_whatever_the_steps() -> void:
	var q := _kettle()
	var d := _data({"q_testshire_kettle_started": true, "q_testshire_kettle_done": true})
	assert_eq(Quests.status(d, q), Quests.DONE)
	assert_eq(Quests.current_step(d, q), {}, "a finished quest has no current step")
	assert_eq(Quests.status(_data({"q_testshire_kettle_done": true}), q), Quests.DONE, "even if the start flag was never set")

func test_all_steps_done_but_not_handed_in_stays_active_on_the_last() -> void:
	var q := _kettle()
	var d := _data({"q_testshire_kettle_started": true, "q_testshire_kettle_1": true, "q_testshire_kettle_2": true, "q_testshire_kettle_3": true})
	assert_eq(Quests.status(d, q), Quests.ACTIVE)
	assert_eq(Quests.step_index(d, q), 2, "the last step stays current until the done flag")

func test_log_steps_show_done_and_current_and_hide_the_future() -> void:
	var q := _kettle()
	var d := _data({"q_testshire_kettle_started": true, "q_testshire_kettle_1": true})
	var s := Quests.log_steps(d, q)
	assert_eq(s.size(), 2, "the third step stays hidden")
	assert_true(s[0].done and not s[0].current)
	assert_true(s[1].current and not s[1].done)
	d.set_flag("q_testshire_kettle_done", true)
	s = Quests.log_steps(d, q)
	assert_eq(s.size(), 3, "a finished quest shows every step")
	assert_true(s.all(func(e): return e.done and not e.current))
	assert_eq(Quests.log_steps(_data(), q), [], "nothing for a quest not started")

func test_active_and_done_lists() -> void:
	var l := _list()
	var d := _data({"q_testshire_kettle_started": true, "q_testshire_hens_started": true, "q_testshire_hens_done": true})
	assert_eq(Quests.active(d, l).map(func(q): return q.id), ["testshire_kettle"])
	assert_eq(Quests.done(d, l).map(func(q): return q.id), ["testshire_hens"])
	assert_eq(Quests.active(_data(), l), [])

func test_news_for_a_start_an_advance_and_a_finish() -> void:
	var q := _kettle()
	var d := _data()
	var before := Quests.snapshot(d, q)
	d.set_flag("q_testshire_kettle_started", true)
	var n := Quests.change_news(q, before, Quests.snapshot(d, q))
	assert_eq(n, ["New quest", "Put the Kettle On"], "short: the Journal has the rest")
	before = Quests.snapshot(d, q)
	d.set_flag("q_testshire_kettle_1", true)
	n = Quests.change_news(q, before, Quests.snapshot(d, q))
	assert_eq(n, ["Quest updated", "Put the Kettle On"])
	before = Quests.snapshot(d, q)
	d.set_flag("q_testshire_kettle_2", true)
	d.set_flag("q_testshire_kettle_3", true)
	d.set_flag("q_testshire_kettle_done", true)
	n = Quests.change_news(q, before, Quests.snapshot(d, q))
	assert_eq(n, ["Quest complete", "Put the Kettle On"], "one toast for a hand-in that sets several flags")
	assert_eq(Quests.change_news(q, before, before), [], "nothing changed, nothing to say")

func test_starting_and_finishing_in_one_go_is_just_complete() -> void:
	var q: Dictionary = _list()[1]
	var d := _data()
	var before := Quests.snapshot(d, q)
	d.set_flag("q_testshire_hens_started", true)
	d.set_flag("q_testshire_hens_1", true)
	d.set_flag("q_testshire_hens_done", true)
	assert_eq(Quests.change_news(q, before, Quests.snapshot(d, q))[0], "Quest complete")

func test_flag_index_finds_the_quests_a_flag_touches() -> void:
	var l := _list()
	assert_eq(Quests.touched_by("q_testshire_kettle_2", l).map(func(q): return q.id), ["testshire_kettle"])
	assert_eq(Quests.touched_by("q_testshire_hens_done", l).map(func(q): return q.id), ["testshire_hens"])
	assert_eq(Quests.touched_by("badge_brook", l), [])

func test_nearby_prefers_this_town_then_its_region() -> void:
	var l := _list()
	var idx := ZoneIndex.get_index()
	var d := _data({"q_testshire_kettle_started": true, "q_testshire_hens_started": true})
	assert_eq(str(Quests.nearby(d, "macclesfield", idx, l).get("id", "")), "testshire_kettle", "its next step is in a Macclesfield room")
	assert_eq(str(Quests.nearby(d, "buxton", idx, l).get("id", "")), "testshire_hens", "the Cat and Fiddle is Buxton's patch (same region)")
	assert_eq(Quests.nearby(d, "penzance", idx, l), {}, "nothing near Penzance")
	assert_eq(Quests.nearby(_data(), "macclesfield", idx, l), {}, "nothing active")

func test_hint_line_names_the_quest_and_the_step() -> void:
	var l := _list()
	var d := _data({"q_testshire_kettle_started": true})
	var s := Quests.hint_line(d, "macclesfield", ZoneIndex.get_index(), l)
	assert_eq(s, "Quest, Put the Kettle On: Ask the ironmonger at the Silk Museum for a fuse.")
	assert_eq(Quests.hint_line(_data(), "macclesfield", ZoneIndex.get_index(), l), "")

func test_map_zone_is_the_town_for_a_room() -> void:
	var idx := ZoneIndex.get_index()
	assert_eq(Quests.map_zone("macc_silkmuseum", idx), "macclesfield")
	assert_eq(Quests.map_zone("cat_and_fiddle", idx), "cat_and_fiddle")

# --- the validator -----------------------------------------------------------------

func _zones() -> Dictionary:
	return {"macclesfield": true, "macc_silkmuseum": true, "buxton": true, "cat_and_fiddle": true}

func _settable() -> Dictionary:
	var out := {}
	for q in _list():
		for f in Quests.flags_of(q):
			out[f] = true
	return out

func test_validator_passes_the_fixture() -> void:
	assert_eq(Quests.validate(_list(), _zones(), _settable()), [])

func test_validator_catches_the_usual_mistakes() -> void:
	var l := _list()
	l[1] = l[1].duplicate(true)
	l[1].id = "testshire_kettle"  # duplicate id
	l[0] = l[0].duplicate(true)
	l[0].steps[1].zone = "atlantis"
	l[0].steps[2].flag = ""
	l[0].erase("reward")
	var errs := Quests.validate(l, _zones(), _settable())
	var all := "\n".join(errs)
	assert_has(all, "duplicate quest id 'testshire_kettle'")
	assert_has(all, "unknown zone 'atlantis'")
	assert_has(all, "step 3 has no flag")
	assert_has(all, "no reward")

func test_validator_wants_every_flag_set_somewhere() -> void:
	var s := _settable()
	s.erase("q_testshire_kettle_2")
	var errs := Quests.validate(_list(), _zones(), s)
	assert_eq(errs.size(), 1)
	assert_has(str(errs[0]), "q_testshire_kettle_2")

func test_validator_wants_the_region_namespace() -> void:
	var l := _list()
	l[0] = l[0].duplicate(true)
	l[0].start_flag = "kettle_started"
	var s := _settable()
	s["kettle_started"] = true
	assert_has("\n".join(Quests.validate(l, _zones(), s)), "q_testshire_")

func test_settable_flags_come_from_scripts_trainers_and_plaques() -> void:
	var dialogue := {"f": {"a": [{"do": "set", "flag": "one"}, {"do": "if", "flag": "x", "then": [{"do": "choice", "text": "?", "options": ["a", "b"], "set": "two"}],
		"else": [{"do": "battle", "trainer": "bob"}, {"do": "legend", "species": "s", "flag": "three"}, {"do": "daily", "key": "four", "then": []}]}]}}
	var zones := {"z": {"npcs": [{"id": "n", "trainer": "sue"}], "signs": [{"x": 1, "y": 1, "plaque": "z_well", "title": "Well", "text": "t"}]}}
	var got := Quests.settable_flags(dialogue, zones, [])
	for f in ["one", "two", "three", "four", "trainer_bob", "trainer_sue", "plaque_z_well"]:
		assert_true(got.has(f), "%s is settable" % f)
	assert_false(got.has("x"), "a flag only tested is not set")

# --- the real data -------------------------------------------------------------------

func test_real_quests_validate() -> void:
	var errs := Quests.validate(Quests.all(), ZoneData.load_all(), Quests.all_settable())
	assert_eq(errs, [], "\n".join(errs))

func test_the_macclesfield_silk_quest_is_there() -> void:
	var q := Quests.get_quest("macclesfield_silk")
	assert_false(q.is_empty(), "the example quest exists")
	assert_eq(str(q.town), "macclesfield")
	assert_true(q.steps.size() >= 2 and q.steps.size() <= 3)
	for s in q.steps:
		assert_false("—" in str(s.text), "no em-dashes")
