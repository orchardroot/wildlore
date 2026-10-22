extends TestCase
## Biology you can practise, in play: Dr Keir sets the challenges and talks about the bigger picture, the moor model
## opens from her bench, and a hatch at the farm is scored against the prediction and noted in the Stud Book.

func _run(script_file: String, sid: String, h: FakeStoryHost, owner := "") -> void:
	await Commands.new(h, owner).run(StoryData.script(script_file, sid))

func _menus(h: FakeStoryHost) -> Array:
	return h.log.filter(func(e): return e[0] == "menu").map(func(e): return e[1])

func test_keir_sets_the_challenges() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("breed_met_keir", true)
	h.choices = [6]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_true(Biology.lab_on(h.data))
	assert_true(h.texts().any(func(t): return str(t).contains("not your luck")), str(h.texts()))
	assert_true(h.texts().any(func(t): return str(t).contains("Medium marks")))

func test_the_bigger_picture_opens_pages_and_the_moor_model() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("breed_met_keir", true)
	h.choices = [7, 1]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_eq(h.data.flag("bio_since_dolly"), true)
	assert_true(Biology.page_open(h.data, Biology.page("crispr")))
	h.choices = [7, 2]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_eq(h.data.flag("bio_seedbank"), true)
	h.choices = [7, 3]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_has(_menus(h), "selection")
	h.choices = [3]
	await _run("roslin_lab", "breed_keir", h, "breed_keir")
	assert_eq(h.data.flag("bio_dolly"), true, "the Dolly answer opens the Dolly page")

func test_a_hatch_is_scored_and_noted_in_the_stud_book() -> void:
	var h := FakeStoryHost.new()
	h.zone = "guiting_farm"
	h.data.set_flag("bio_lab_on", true)
	var sire := Fixtures.creature("moolet", 10)
	var dam := Fixtures.creature("moolet", 10)
	sire.sex = "m"
	dam.sex = "f"
	sire.friendship = 200
	dam.friendship = 200
	sire.genome = Genetics.derive(sire).genome
	dam.genome = Genetics.derive(dam).genome
	sire.genome.ginger = [sire.genome.ginger[0], "Y"]
	dam.genome.ginger = ["o", "o"]
	h.data.party = [sire, dam]
	var r := Breeding.start(h.data, sire, dam, "guiting_farm", h.dex, h.moves, Rng.new(3), "spring")
	assert_true(r.ok)
	var uid := int(h.data.flag("breed_basket_%d" % int(r.slot)).uid)
	var p := Biology.prompt(h.data, sire, dam)
	var right := -1
	for i in p.options.size():
		if is_equal_approx(float(p.options[i].min), float(p.truth.min)) and is_equal_approx(float(p.options[i].max), float(p.truth.max)):
			right = i
	Biology.predict(h.data, uid, p, right)
	h.data.stats["steps"] = int(h.data.stats.get("steps", 0)) + int(r.steps)
	h.data.set_flag("breed_met_dot", true)
	var money := Wallet.balance(h.data, Wallet.GBP)
	h.choices = [1]
	await _run("guiting_farm", "breed_dot", h, "breed_dot")
	assert_eq(h.data.party.size(), 3, "the hatchling joined")
	assert_true(h.texts().any(func(t): return str(t).contains("Dr Keir's challenge")), str(h.texts()))
	assert_true(Biology.done(h.data, "marks"))
	assert_eq(Wallet.balance(h.data, Wallet.GBP), money + 50)
	assert_true(StudBook.unlocked(h.data, "breed"), "the hatch reached the Stud Book")
	assert_false(StudBook.tally_lines(h.data).is_empty())

func test_observe_hatch_stands_in_for_parents_no_longer_held() -> void:
	var d := GameStateData.new()
	var c := Fixtures.creature("moolet", 1)
	c.uid = 9
	c.sex = "f"
	c.genome = {"coat": ["c", "c"], "tint": ["W", "W"], "mark": ["B", "b"], "knack": ["K", "K"], "ginger": ["o", "o"],
		"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"]}
	var hands := {"coat": "+c", "tint": "WW", "mark": "Bb", "knack": "KK", "ginger": "oY", "frame1": "+-", "frame2": "+-", "frame3": "+-", "frame4": "+-"}
	var dam_hands := hands.duplicate()
	dam_hands.ginger = "oo"
	var basket := {"sire_uid": 1, "dam_uid": 2, "sire_species": "moolet", "dam_species": "moolet", "species": "moolet",
		"kind": "same_line", "parents": {"sire": hands, "dam": dam_hands}}
	var fresh := StudBook.observe_hatch(d, basket, c, Fixtures.dex())
	assert_has(fresh, "carriers", "two plain carriers, read from the basket's record")
	assert_has(fresh, "incomplete")
