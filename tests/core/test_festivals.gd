extends TestCase
## Festivals (data/festivals.json): date windows (including ones that wrap the new year), the people and creatures
## they bring, the "What's on" lines, and that every event's data hangs together.

func test_windows_and_the_new_year_wrap() -> void:
	var bonfire := Festivals.get_event("bonfire")
	assert_true(Festivals.in_window(bonfire, 11, 1))
	assert_true(Festivals.in_window(bonfire, 11, 7))
	assert_false(Festivals.in_window(bonfire, 11, 8))
	assert_false(Festivals.in_window(bonfire, 10, 31))
	var hog := Festivals.get_event("hogmanay")
	assert_true(Festivals.in_window(hog, 12, 31))
	assert_true(Festivals.in_window(hog, 1, 2))
	assert_false(Festivals.in_window(hog, 1, 3))
	assert_false(Festivals.in_window(hog, 12, 27))

func test_days_until() -> void:
	var bonfire := Festivals.get_event("bonfire")
	assert_eq(Festivals.days_until(bonfire, Vector2i(11, 3)), 0)
	assert_eq(Festivals.days_until(bonfire, Vector2i(10, 30)), 2)
	assert_eq(Festivals.days_until(bonfire, Vector2i(11, 8)), 358)

func test_at_least_eight_occasions_over_the_four_nations() -> void:
	assert_true(Festivals.events().size() >= 8)
	var nations := {}
	for e in Festivals.events():
		nations[Calendar.nation_for_region(ZoneData.load_id(str(e.town)).region)] = true
	for n in ["england", "wales", "scotland", "ireland"]:
		assert_true(nations.has(n), n)

func test_the_person_is_only_there_in_the_window() -> void:
	assert_eq(Festivals.npcs_for("york", Vector2i(7, 1)).size(), 0)
	var defs := Festivals.npcs_for("york", Vector2i(11, 5))
	assert_eq(defs.size(), 1)
	assert_eq(str(defs[0].script_file), Festivals.SCRIPT_FILE)
	assert_eq(Festivals.npcs_for("dublin", Vector2i(11, 5)).size(), 0, "wrong town")

func test_the_creature_joins_the_wild_table_only_in_the_window() -> void:
	var table := [{"species": "pepperling", "min": 84, "max": 85, "weight": 20}]
	assert_eq(Festivals.extra_encounters("york", "grass", table, Vector2i(7, 1)), [])
	var got := Festivals.extra_encounters("york", "grass", table, Vector2i(11, 2))
	assert_eq(got.size(), 1)
	assert_eq(str(got[0].species), "fizzlet")
	assert_eq(int(got[0].min), 84)
	assert_eq(Festivals.extra_encounters("york", "water", table, Vector2i(11, 2)), [])
	assert_eq(Festivals.extra_encounters("york", "grass", [], Vector2i(11, 2)), [], "no table, no festival creature")

func test_whats_on_lists_now_then_soon() -> void:
	var lines := Festivals.whats_on(Vector2i(11, 3))
	assert_true(lines[0].begins_with("On now:"), lines[0])
	assert_true("York" in lines[0])
	var soon := Festivals.whats_on(Vector2i(10, 30))
	assert_true(soon.any(func(l): return l.begins_with("Coming up:") and "York" in l and "in 2 days" in l))
	assert_eq(Festivals.whats_on(Vector2i(6, 1)), [], "nothing near in early June")
	assert_true(Festivals.whats_on(Vector2i(11, 3), 2).size() <= 2)

func test_when_condition() -> void:
	Calendar.set_override("11-03")
	assert_true(Festivals.cond("fest_bonfire"))
	assert_false(Festivals.cond("fest_fringe"))
	assert_false(Festivals.cond("fest_nonsense"))
	assert_true(Festivals.is_cond("fest_fringe"))
	assert_false(Festivals.is_cond("fest_nonsense"))
	Calendar.set_override("")

func test_data_validates_and_every_quest_flag_is_set() -> void:
	var zones := {}
	for e in Festivals.events():
		zones[str(e.town)] = true
	var errs := Festivals.validate(zones, Dex.load_default(), Quests.all())
	assert_eq(errs, [], str(errs))
	var set_flags := Quests.all_settable()
	var n := 0
	for q in Quests.all():
		if str(q.get("_file", "")) != "festivals":
			continue
		n += 1
		for f in Quests.flags_of(q):
			assert_true(f.begins_with("q_festivals_"), f)
			assert_true(set_flags.has(f), "nobody sets " + f)
	assert_eq(n, Festivals.events().size())

func test_the_scripts_walk_the_quest_to_the_end() -> void:
	for e in Festivals.events():
		var cmds := StoryData.script(Festivals.SCRIPT_FILE, str(e.script))
		var text := JSON.stringify(cmds)
		assert_true(text.contains("q_festivals_%s_done" % e.id), str(e.id))
		assert_true(text.contains("has_" + str(e.spawn.species)), str(e.id))
		assert_false(text.contains("—"), "no em-dashes")
		assert_true(FileAccess.file_exists("res://art/sprites/chars/%s.png" % e.sprite), str(e.id))
		var z := ZoneData.load_id(str(e.town))
		assert_true(SideStories.free_tile(z, Vector2i(int(e.x), int(e.y))), "%s: stands somewhere free" % e.id)
