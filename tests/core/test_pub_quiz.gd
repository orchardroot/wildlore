extends TestCase
## The pub quiz: a sound question bank, regional weighting, the prize ladder and the once-a-day prize lock.

func test_bank_is_big_enough_and_covers_every_category() -> void:
	var bank := PubQuiz.load_bank()
	assert_true(bank.size() >= 120, "at least 120 questions, got %d" % bank.size())
	var cats := {}
	for q in bank:
		cats[q.cat] = true
	for c in ["geography", "history", "folklore", "food", "nature", "creatures"]:
		assert_true(cats.has(c), "category " + c)

func test_every_question_is_well_formed() -> void:
	var seen := {}
	for q in PubQuiz.load_bank():
		var id := str(q.get("q", ""))
		assert_true(id.length() > 8, "has a question: " + id)
		assert_false(seen.has(id), "duplicate question: " + id)
		seen[id] = true
		var opts := [str(q.a)] + (q.wrong as Array).map(func(w): return str(w))
		assert_eq(opts.size(), 4, "four options: " + id)
		var uniq := {}
		for o in opts:
			assert_true(str(o) != "", "no blank option: " + id)
			uniq[o] = true
		assert_eq(uniq.size(), 4, "options all different: " + id)
		assert_true(str(q.fact).length() > 10, "has a fact: " + id)
		assert_true(PubQuiz.REGIONS.has(str(q.region)), "known region %s: %s" % [q.region, id])
		assert_false(("—" in id) or ("—" in str(q.fact)), "no em-dashes: " + id)

func test_built_question_has_exactly_one_right_answer() -> void:
	var rng := Rng.new(3)
	for q in PubQuiz.load_bank():
		var b := PubQuiz.build(q, rng)
		assert_eq(b.options.size(), 4)
		var hits := 0
		for o in b.options:
			if o == q.a:
				hits += 1
		assert_eq(hits, 1, "one right option")
		assert_eq(b.options[b.answer], q.a, "answer index points at the right option")

func test_weight_favours_home_region() -> void:
	var home := {"region": "scotland"}
	var away := {"region": "wales"}
	var everywhere := {"region": "all"}
	assert_true(PubQuiz.weight(home, "scotland") > PubQuiz.weight(everywhere, "scotland"))
	assert_true(PubQuiz.weight(everywhere, "scotland") > PubQuiz.weight(away, "scotland"))
	assert_eq(PubQuiz.weight(away, "all"), PubQuiz.weight(home, "all"), "no region means no bias")

func test_round_is_five_distinct_questions_leaning_home() -> void:
	var bank := PubQuiz.load_bank()
	var rng := Rng.new(42)
	var home := 0
	var total := 0
	for i in 200:
		var round := PubQuiz.pick_round(bank, "scotland", rng)
		assert_eq(round.size(), PubQuiz.ROUND_SIZE)
		var ids := {}
		for q in round:
			ids[q.q] = true
			total += 1
			if q.region == "scotland":
				home += 1
		assert_eq(ids.size(), PubQuiz.ROUND_SIZE, "no repeats in a round")
	var share := float(home) / total
	var base := 0.0
	for q in bank:
		if q.region == "scotland":
			base += 1.0
	base /= bank.size()
	assert_true(share > base * 2.0, "home share %.2f beats the plain share %.2f" % [share, base])

func test_prize_ladder() -> void:
	assert_eq(PubQuiz.prize(5).item, "whitby_jet")
	assert_true(PubQuiz.prize(4).item != "" or PubQuiz.prize(4).money > 0)
	assert_true(PubQuiz.prize(3).money > PubQuiz.prize(2).money)
	assert_true(PubQuiz.prize(2).money > 0)
	assert_eq(PubQuiz.prize(1).item, "cup_of_tea")
	assert_eq(PubQuiz.prize(0).money, 0)
	assert_eq(PubQuiz.prize(0).item, "")
	for s in 6:
		var p := PubQuiz.prize(s)
		if p.item != "":
			assert_false(ItemDB.load_default().get_item(p.item).is_empty(), "prize item exists: " + p.item)

func test_prize_lock_is_once_per_day_per_pub() -> void:
	var d := GameStateData.new()
	d.day_count = 3
	d.clock_minutes = 600
	assert_false(PubQuiz.claimed_today(d, "dublin"))
	PubQuiz.claim(d, "dublin")
	assert_true(PubQuiz.claimed_today(d, "dublin"), "locked the same day")
	assert_false(PubQuiz.claimed_today(d, "galway"), "other pubs are separate")
	d.clock_minutes = 1439
	assert_true(PubQuiz.claimed_today(d, "dublin"), "still locked at closing time")
	d.day_count = 4
	d.clock_minutes = 5
	assert_false(PubQuiz.claimed_today(d, "dublin"), "unlocked the next day")

func test_award_pays_out_and_locks() -> void:
	var d := GameStateData.new()
	var items := ItemDB.load_default()
	var money := d.money
	var r := PubQuiz.award(d, items, "york", 5)
	assert_eq(r.item, "whitby_jet")
	assert_eq(int(d.bag.get("whitby_jet", 0)), 1)
	assert_true(PubQuiz.claimed_today(d, "york"))
	var again := PubQuiz.award(d, items, "york", 5)
	assert_false(again.paid, "second win the same day pays nothing")
	assert_eq(int(d.bag.get("whitby_jet", 0)), 1)
	var r3 := PubQuiz.award(d, items, "cardiff", 3)
	assert_eq(d.money, money + r3.money)

func test_quiz_command_opens_menu_and_pays() -> void:
	var h := FakeStoryHost.new()
	h.menu_results = {"quiz:dublin:ireland": {"score": 5, "total": 5}}
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland", "who": "Quizmaster"}])
	assert_has(h.log, ["menu", "quiz:dublin:ireland"])
	assert_eq(int(h.data.bag.get("whitby_jet", 0)), 1)
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland"}])
	assert_eq(int(h.data.bag.get("whitby_jet", 0)), 1, "no second prize today")

func test_quiz_command_walkout_pays_nothing() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "quiz", "pub": "dublin", "region": "ireland"}])
	assert_false(PubQuiz.claimed_today(h.data, "dublin"))

func test_every_quizmaster_is_in_a_real_place() -> void:
	var found := 0
	var dir := DirAccess.open("res://data/zones")
	for f in dir.get_files():
		if not f.ends_with(".json"):
			continue
		var id := f.get_basename()
		var z := ZoneData.load_id(id)
		for n in z.npcs:
			var script := StoryData.script(id, str(n.get("script", "")))
			if not JSON.stringify(script).contains("\"quiz\""):
				continue
			found += 1
			assert_true(z.walkable(Vector2i(int(n.x), int(n.y))), "%s: quizmaster stands on floor" % id)
	assert_true(found >= 6, "at least six quizmasters, found %d" % found)
