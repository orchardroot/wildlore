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

# --- Every year ---

func _d() -> GameStateData:
	return GameStateData.new()

func test_a_rule_window_moves_with_the_calendar() -> void:
	var rule := {"rule": {"nth": "last", "weekday": 2, "month": 1, "from": -3, "to": 1}}
	assert_eq(Festivals.window_of(rule, 2026), [1, 24, 1, 28], "last Tuesday of January 2026 is the 27th")
	assert_eq(Festivals.window_of(rule, 2027), [1, 23, 1, 27], "the 26th in 2027")
	assert_eq(Festivals.window_of(rule, 2028), [1, 22, 1, 26], "the 25th in 2028")
	assert_true(Festivals.in_window(rule, 1, 27, 2026))
	assert_false(Festivals.in_window(rule, 1, 28, 2027))

func test_run_year_follows_the_year_a_new_year_window_opened() -> void:
	var hog := Festivals.get_event("hogmanay")
	assert_eq(Festivals.run_year(hog, Vector2i(12, 31), 2026), 2026)
	assert_eq(Festivals.run_year(hog, Vector2i(1, 1), 2027), 2026, "1 January is still last year's Hogmanay")
	assert_eq(Festivals.run_year(Festivals.get_event("bonfire"), Vector2i(11, 3), 2026), 2026)

func test_a_3_1_run_still_counts_for_its_year_then_starts_afresh() -> void:
	var d := _d()
	d.set_flag("q_festivals_bonfire_started")
	d.set_flag("q_festivals_bonfire_1")
	d.set_flag("q_festivals_bonfire_2")
	d.set_flag("q_festivals_bonfire_done")
	assert_eq(Festivals.rollover(d, Vector2i(11, 3), 2026), [], "same year: nothing resets")
	assert_true(d.flag("q_festivals_bonfire_done") == true)
	assert_true(d.flag("festivals_souv_bonfire") == true, "the 3.1 souvenir is already yours")
	assert_eq(Festivals.rollover(d, Vector2i(11, 3), 2027), ["bonfire"])
	assert_true(d.flag("q_festivals_bonfire_done") == null)
	assert_true(d.flag("q_festivals_bonfire_started") == null)
	assert_true(d.flag("festivals_souv_bonfire") == true, "the souvenir flag survives the new year")
	assert_eq(int(d.flag("festivals_year_bonfire")), 2027)
	assert_eq(Festivals.years_done(d, Festivals.get_event("bonfire")), 1)
	assert_eq(Festivals.rollover(d, Vector2i(11, 4), 2027), [], "once per year")

func test_a_new_save_and_an_unfinished_run() -> void:
	var d := _d()
	assert_eq(Festivals.rollover(d, Vector2i(11, 3), 2026), [])
	assert_eq(int(d.flag("festivals_year_bonfire")), 2026)
	d.set_flag("q_festivals_bonfire_started")
	d.set_flag("q_festivals_bonfire_1")
	Festivals.rollover(d, Vector2i(11, 3), 2027)
	assert_true(d.flag("q_festivals_bonfire_1") == null, "an unfinished run does not carry over")
	assert_true(d.flag("festivals_souv_bonfire") == null, "and earned no souvenir")
	assert_eq(Festivals.years_done(d, Festivals.get_event("bonfire")), 0)

func test_only_the_festival_on_today_rolls_over() -> void:
	var d := _d()
	d.set_flag("q_festivals_burns_done")
	assert_eq(Festivals.rollover(d, Vector2i(11, 3), 2027), ["bonfire"])
	assert_true(d.flag("q_festivals_burns_done") == true, "Burns Night is not on in November")

func test_every_souvenir_is_given_once_and_the_food_every_year() -> void:
	var d: Dictionary = JsonUtil.read("res://data/dialogue/festivals.json")
	var souvenirs := 0
	var stack := [d]
	while not stack.is_empty():
		var n: Variant = stack.pop_back()
		if n is Dictionary:
			if n.get("do") == "give_item" and str(n.item).begins_with("fest_"):
				assert_true(false, "souvenir given outside its once-only guard: " + str(n.item))
			if n.get("do") == "if" and str(n.get("flag", "")).begins_with("festivals_souv_"):
				souvenirs += 1
				assert_true(n.get("else", []).size() == 2, "guarded give plus set")
				continue
			for v in n.values():
				stack.append(v)
		elif n is Array:
			stack.append_array(n)
	assert_true(souvenirs >= 24)
