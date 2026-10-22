extends TestCase
## Arts and letters (4.5): the five short quests in data/quests/arts.json, one per nation, played through their
## scripts with a FakeStoryHost. Plaque steps are ticked the way the overworld does it, with Gazetteer.record.

func _talk(h: FakeStoryHost, zone: String, script: String) -> void:
	h.said.clear()
	await Commands.new(h, script).run(StoryData.script(zone, script))

func _q(id: String) -> Dictionary:
	return Quests.get_quest(id)

func test_poets_corner_errand_in_england() -> void:
	var h := FakeStoryHost.new()
	var q := _q("arts_england")
	assert_false(q.is_empty())
	await _talk(h, "london_westminster", "arts_pc_guide")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	assert_eq(Quests.step_index(h.data, q), 0)
	await _talk(h, "london_westminster", "arts_pc_guide")
	assert_true(str(h.said).contains("Lakes first"), "a nudge towards the first plaque")
	Gazetteer.record(h.data, "arts_wordsworth_daffodils")
	Gazetteer.record(h.data, "arts_shakespeare")
	assert_eq(Quests.step_index(h.data, q), 2, "two plaques read: Austen next")
	await _talk(h, "london_westminster", "arts_pc_guide")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE, "not done until Bath")
	Gazetteer.record(h.data, "bath_austen")
	await _talk(h, "london_westminster", "arts_pc_guide")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("pocket_anthology", 0)), 1)
	assert_true(Standing.points(h.data, "england") >= 5)

func test_branwens_starling_in_wales() -> void:
	var h := FakeStoryHost.new()
	var q := _q("arts_wales")
	await _talk(h, "aberystwyth_nlw", "arts_mabinogi_scholar")
	assert_eq(Quests.status(h.data, q), Quests.NOT_STARTED, "the scholar just chats before Harlech sends you")
	await _talk(h, "cambrian_harlech", "arts_cyfarwydd")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	await _talk(h, "aberystwyth_nlw", "arts_mabinogi_scholar")
	assert_eq(int(h.data.bag.get("white_book_page", 0)), 0, "no page until Branwen's board is read")
	Gazetteer.record(h.data, "arts_branwen")
	await _talk(h, "aberystwyth_nlw", "arts_mabinogi_scholar")
	assert_eq(int(h.data.bag.get("white_book_page", 0)), 1)
	assert_eq(Quests.step_index(h.data, q), 2)
	await _talk(h, "cambrian_harlech", "arts_cyfarwydd")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("mabinogion_copy", 0)), 1)

func test_the_immortal_memory_in_scotland() -> void:
	var h := FakeStoryHost.new()
	var q := _q("arts_scotland")
	await _talk(h, "galloway", "arts_burns_club")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	Gazetteer.record(h.data, "arts_burns_dumfries")
	await _talk(h, "galloway", "arts_burns_club")
	assert_true(str(h.said).contains("Edinburgh"), "sent on to the second board")
	Gazetteer.record(h.data, "arts_burns_edinburgh")
	h.choices = [1]  # Stevenson: wrong
	await _talk(h, "galloway", "arts_burns_club")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE, "a wrong answer is not the end")
	h.choices = [0]  # the red, red rose
	await _talk(h, "galloway", "arts_burns_club")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("kilmarnock_edition", 0)), 1)
	assert_true(Standing.points(h.data, "scotland") >= 5)

func test_field_day_in_northern_ireland() -> void:
	var h := FakeStoryHost.new()
	var q := _q("arts_ni")
	await _talk(h, "derry_craftvillage", "arts_field_day_actor")
	assert_eq(h.data.flag("q_arts_ni_actor"), null, "the actor stays put until the stage manager asks")
	await _talk(h, "derry_guildhall", "arts_stage_manager")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	await _talk(h, "derry_craftvillage", "arts_field_day_actor")
	assert_eq(h.data.flag("q_arts_ni_actor"), true)
	assert_eq(Quests.step_index(h.data, q), 0, "Heaney's board is still the first step")
	await _talk(h, "derry_guildhall", "arts_stage_manager")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	Gazetteer.record(h.data, "arts_heaney_bellaghy")
	assert_eq(Quests.step_index(h.data, q), 2, "both done: hand in")
	await _talk(h, "derry_guildhall", "arts_stage_manager")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("field_day_programme", 0)), 1)

func test_bloomsday_in_ireland() -> void:
	var h := FakeStoryHost.new()
	var q := _q("arts_ireland")
	await _talk(h, "dublin", "arts_chemist")
	assert_eq(int(h.data.bag.get("lemon_soap", 0)), 0, "no soap without the errand")
	await _talk(h, "dublin", "arts_joycean")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	await _talk(h, "dublin", "arts_davy_byrnes")
	assert_eq(int(h.data.bag.get("gorgonzola_sandwich", 0)), 1)
	await _talk(h, "dublin", "arts_joycean")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE, "the soap is still owed")
	await _talk(h, "dublin", "arts_chemist")
	assert_eq(int(h.data.bag.get("lemon_soap", 0)), 1)
	await _talk(h, "dublin", "arts_chemist")
	assert_eq(int(h.data.bag.get("lemon_soap", 0)), 1, "one cake is plenty")
	await _talk(h, "dublin", "arts_joycean")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("straw_boater", 0)), 1)
	assert_true(Standing.points(h.data, "ireland") >= 5)

func test_arts_plaques_and_quest_steps_line_up() -> void:
	var ids := {}
	for p in PoetsCorner.all():
		ids[str(p.id)] = true
	for q in Quests.all():
		if str(q.get("_file", "")) != "arts":
			continue
		for s in q.steps:
			var f := str(s.flag)
			if f.begins_with(Gazetteer.PREFIX):
				assert_true(ids.has(f.substr(Gazetteer.PREFIX.length())), "%s: %s is a plaque on the arts" % [q.id, f])
