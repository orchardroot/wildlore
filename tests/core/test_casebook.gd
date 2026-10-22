extends TestCase
## The Casebook (core/casebook.gd, story/casebook_talk.gd, ui/casebook_tab.gd): two cases, evidence and red herrings,
## the accusation (wrong costs standing and crosses a suspect off, right pays once), the story commands, and the data.

func _data() -> GameStateData:
	return GameStateData.new()

func _open(d: GameStateData, id: String) -> Dictionary:
	var c := Casebook.get_case(id)
	d.set_flag(str(c.start_flag), true)
	return c

func _finish_steps(d: GameStateData, c: Dictionary) -> void:
	for s in c.steps:
		d.set_flag(str(s.flag), true)

func test_the_cases_validate() -> void:
	assert_true(Casebook.all().size() >= 3)

func test_two_cases_that_validate() -> void:
	assert_true(Casebook.all().size() >= 3)

	assert_true(Casebook.all().size() >= 2)

	assert_true(Casebook.get_case("causeway_stone").size() > 0)
	assert_true(Casebook.get_case("mersey_otters").size() > 0)
	assert_true(Casebook.get_case("loch_ness").size() > 0)
	assert_true(Casebook.get_case("eisteddfod_chair").size() > 0)
	var zones := func(z): return FileAccess.file_exists("res://data/zones/%s.json" % z)
	assert_eq(Casebook.validate(zones), [])

func test_each_case_is_solvable_by_its_real_evidence() -> void:
	for c in Casebook.all():
		var real: Array = c.evidence.filter(func(e): return not e.red_herring)
		var herrings: Array = c.evidence.filter(func(e): return e.red_herring)
		assert_true(real.size() >= 3, str(c.id) + " has real clues")
		assert_true(herrings.size() >= 2, str(c.id) + " has red herrings")

func test_old_saves_have_no_cases() -> void:
	var d := _data()
	assert_false(Casebook.visible(d))
	assert_eq(Casebook.open_cases(d), [])

func test_evidence_is_collected_once() -> void:
	var d := _data()
	var c := _open(d, "mersey_otters")
	assert_eq(Casebook.collect(d, "sheen").size(), 1)
	assert_true(Casebook.has_evidence(d, c, "sheen"))
	assert_eq(Casebook.collect(d, "sheen").size(), 0)
	assert_eq(Casebook.collect(d, "nonsense"), [])
	assert_eq(Casebook.held(d, c).size(), 1)

func test_not_ready_until_every_step_is_done() -> void:
	var d := _data()
	var c := _open(d, "mersey_otters")
	assert_false(Casebook.ready(d, c))
	assert_false(Casebook.accuse(d, "mersey_otters", "dennis").ok)
	_finish_steps(d, c)
	assert_true(Casebook.ready(d, c))

func test_wrong_accusation_costs_standing_and_closes_a_line() -> void:
	var d := _data()
	var c := _open(d, "mersey_otters")
	_finish_steps(d, c)
	d.set_flag("standing_england", 20)
	var r := Casebook.accuse(d, "mersey_otters", "rooke")
	assert_true(r.ok)
	assert_false(r.correct)
	assert_eq(Standing.points(d, "england"), 17)
	assert_eq(Casebook.open_suspects(d, c).size(), 2)
	assert_false(Casebook.accuse(d, "mersey_otters", "rooke").ok, "can't name them twice")
	assert_false(Casebook.solved(d, c))

func test_standing_never_goes_below_zero() -> void:
	var d := _data()
	var c := _open(d, "mersey_otters")
	_finish_steps(d, c)
	Casebook.accuse(d, "mersey_otters", "rooke")
	assert_eq(Standing.points(d, "england"), 0)

func test_right_accusation_pays_once_and_less_after_wrong_guesses() -> void:
	var d := _data()
	var c := _open(d, "mersey_otters")
	_finish_steps(d, c)
	var before := d.money
	var r := Casebook.accuse(d, "mersey_otters", "dennis")
	assert_true(r.correct)
	assert_eq(d.money - before, 1200)
	assert_true(Casebook.solved(d, c))
	assert_eq(Standing.points(d, "england"), 6)
	assert_false(Casebook.accuse(d, "mersey_otters", "dennis").ok, "paid once")
	assert_eq(d.money - before, 1200)
	var d2 := _data()
	_open(d2, "mersey_otters")
	_finish_steps(d2, c)
	Casebook.accuse(d2, "mersey_otters", "rooke")
	Casebook.accuse(d2, "mersey_otters", "mavis")
	var m := d2.money
	Casebook.accuse(d2, "mersey_otters", "dennis")
	assert_eq(d2.money - m, 600, "half the reward after two wrong guesses")

func test_loch_ness_culprit_is_the_stall_not_the_obvious_pair() -> void:
	var c := Casebook.get_case("loch_ness")
	assert_eq(str(c.culprit), "gillian")
	var d := _data()
	_open(d, "loch_ness")
	_finish_steps(d, c)
	assert_true(Casebook.accuse(d, "loch_ness", "gillian").correct)
	assert_true(d.bag.get("tablet", 0) >= 1 or Bag.new(d.bag).count("tablet") >= 1)

func test_zone_evidence_and_scripts_exist() -> void:
	for p in JsonUtil.list_json("res://data/zones"):
		var z = JsonUtil.read(p)
		for e in z.get("examine", []):
			if e is Dictionary and e.has("evidence"):
				assert_true(Casebook.is_evidence(str(e.evidence)), "%s examine evidence %s" % [z.id, e.evidence])
	for c in Casebook.all():
		for s in c.steps:
			assert_true(str(s.flag).begins_with("case_" + str(c.id) + "_"))

func test_validator_knows_the_commands() -> void:
	var dex := Fixtures.dex()
	var items := ItemDB.load_default()
	assert_eq(StoryValidator.validate_commands([{"do": "evidence", "id": "sheen"}, {"do": "casebook", "id": "loch_ness"}], "t", dex, items, {}), [])
	assert_eq(StoryValidator.validate_commands([{"do": "evidence", "id": "zzz"}], "t", dex, items, {}).size(), 1)
	assert_eq(StoryValidator.validate_commands([{"do": "casebook", "id": "zzz"}], "t", dex, items, {}).size(), 1)

func test_evidence_command_gives_a_line_once() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "evidence", "id": "docket"}])
	assert_true(str(h.said).contains("Delivery Docket"))
	h.said.clear()
	await Commands.new(h).run([{"do": "evidence", "id": "docket"}])
	assert_eq(h.said.size(), 0)

func test_accusation_prompt_end_to_end() -> void:
	var h := FakeStoryHost.new()
	var c := _open(h.data, "mersey_otters")
	await Commands.new(h).run([{"do": "casebook", "id": "mersey_otters"}])
	assert_true(str(h.said).contains("name anyone"), "not ready")
	_finish_steps(h.data, c)
	h.said.clear()
	h.choices = [0, 0]   # Director Rooke, yes: wrong
	await Commands.new(h).run([{"do": "casebook", "id": "mersey_otters"}])
	assert_true(str(h.said).contains("bowling green"))
	assert_false(Casebook.solved(h.data, c))
	h.said.clear()
	h.choices = [1, 0]   # now the list is Mavis, Dennis: Dennis, yes
	await Commands.new(h).run([{"do": "casebook", "id": "mersey_otters"}])
	assert_true(Casebook.solved(h.data, c))
	assert_true(str(h.said).contains("Case solved"))

func test_tab_filter_only_appears_with_a_case() -> void:
	assert_eq(MenuLogic.next_filter("rumours"), "all")
	assert_eq(MenuLogic.next_filter("rumours", false, true), "casebook")
	assert_eq(MenuLogic.next_filter("casebook", true, true), "studbook")
	assert_eq(MenuLogic.next_filter("casebook", false, true), "all")

func test_fair_isle_case_is_solvable_by_its_chain() -> void:
	var c := Casebook.get_case("fair_isle")
	assert_eq(str(c.culprit), "marjory")
	var d := _data()
	_open(d, "fair_isle")
	assert_false(Casebook.ready(d, c))
	_finish_steps(d, c)
	assert_false(Casebook.accuse(d, "fair_isle", "dyer").correct)
	assert_true(Casebook.accuse(d, "fair_isle", "marjory").correct)
	assert_true(Casebook.solved(d, c))

func test_kilkenny_hex_is_fair_and_solvable() -> void:
	var c := Casebook.get_case("kilkenny_hex")
	assert_eq(str(c.nation), "ireland")
	assert_true(c.steps.size() >= 8 and c.steps.size() <= 12)
	var d := _data()
	_open(d, "kilkenny_hex")
	Examine.read(d, "kilkenny_kyteler", {"x": 1, "y": 3, "text": ["x"], "evidence": "trolley"}, null)
	assert_true(Casebook.has_evidence(d, c, "trolley"))
	_finish_steps(d, c)
	assert_false(Casebook.accuse(d, "kilkenny_hex", "declan").correct)
	var r := Casebook.accuse(d, "kilkenny_hex", "maeve")
	assert_true(r.correct)
	assert_eq(r.money, 1125)
