extends TestCase
## These Isles: the Gazetteer's page on the many peoples of these isles. Plaques carry "people": <theme>, people you
## meet set a flag, quests carry "people" too; the page tallies each theme. Everything reads existing flags.

func _themes() -> Array:
	return [
		{"id": "norse", "name": "Norse and Vikings", "about": "They came, they saw, they named the becks."},
		{"id": "windrush", "name": "Windrush", "about": "1948, Tilbury."},
	]

func _plaques() -> Array:
	return [
		{"id": "dales_words", "title": "Dales Words", "zone": "yorkshire_dales", "town": "yorkshire_dales", "town_name": "Yorkshire Dales", "people": "norse"},
		{"id": "york_minster", "title": "York Minster", "zone": "york", "town": "york", "town_name": "York", "people": ""},
		{"id": "london_windrush", "title": "Empire Windrush", "zone": "london", "town": "london", "town_name": "London", "people": "windrush"},
	]

func _people() -> Array:
	return [{"id": "marcia", "name": "Marcia", "theme": "windrush", "zone": "london", "flag": "isles_met_marcia", "line": "Brixton"}]

func _quests() -> Array:
	return [{"id": "isles_windrush", "title": "Windrush Day", "people": "windrush", "town": "london",
		"start_flag": "q_isles_windrush_started", "done_flag": "q_isles_windrush_done", "steps": [{"flag": "q_isles_windrush_done", "zone": "london"}]},
		{"id": "other", "title": "Other", "town": "york", "start_flag": "q_x", "done_flag": "q_y", "steps": []}]

func _entries() -> Array:
	return TheseIsles.build(_themes(), _plaques(), _people(), _quests())

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_build_gathers_tagged_plaques_people_and_quests_by_theme() -> void:
	var e := _entries()
	assert_eq(e.map(func(t): return t.id), ["norse", "windrush"], "themes in file order")
	assert_eq(e[0].items.map(func(i): return i.id), ["dales_words"], "an untagged plaque stays out")
	assert_eq(e[1].items.map(func(i): return [i.kind, i.id]), [["plaque", "london_windrush"], ["person", "marcia"], ["quest", "isles_windrush"]])
	assert_eq(str(e[1].items[1].where), "London")

func test_tally_reads_the_flags_already_in_the_save() -> void:
	var e := _entries()
	var d := _data({"plaque_london_windrush": true, "isles_met_marcia": true})
	var t := TheseIsles.tally(d, e)
	assert_eq([t[0].found, t[0].total], [0, 1])
	assert_eq([t[1].found, t[1].total], [2, 3], "the quest isn't done yet")
	d.set_flag("q_isles_windrush_done", true)
	t = TheseIsles.tally(d, e)
	assert_eq([t[1].found, t[1].total], [3, 3])
	assert_true(t[1].items[2].found)
	assert_eq(TheseIsles.totals(d, e), {"found": 3, "total": 4})

func test_an_old_save_has_found_nothing_and_breaks_nothing() -> void:
	var t := TheseIsles.tally(_data(), _entries())
	assert_eq(t.map(func(x): return x.found), [0, 0])
	assert_eq(TheseIsles.stats_line(_data(), _entries()), "None yet")

func test_validate_catches_unknown_themes_and_unset_flags() -> void:
	var pl := _plaques()
	pl.append({"id": "bad", "title": "Bad", "zone": "york", "town": "york", "town_name": "York", "people": "martians"})
	var pe := _people()
	pe.append({"id": "ghost", "name": "Ghost", "theme": "norse", "zone": "nowhere", "flag": "isles_met_ghost", "line": "Boo — boo"})
	var errs := "\n".join(TheseIsles.validate(_themes(), pl, pe, _quests(), {"isles_met_marcia": true}, func(z): return z in ["london", "york"]))
	assert_has(errs, "martians")
	assert_has(errs, "isles_met_ghost")
	assert_has(errs, "nowhere")
	assert_has(errs, "em-dash")
	assert_eq(TheseIsles.validate(_themes(), _plaques(), _people(), _quests(), {"isles_met_marcia": true}, func(z): return z in ["london", "york"]), [])

func test_real_page_is_rich_and_sound() -> void:
	var e := TheseIsles.all()
	assert_true(e.size() >= 15, "a theme for each of the peoples in the brief (%d)" % e.size())
	var n := 0
	for t in e:
		assert_true(t.items.size() >= 2, "%s has at least two things to find" % t.id)
		n += t.items.size()
	assert_true(n >= 60, "plenty to find (%d)" % n)
