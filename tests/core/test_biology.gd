extends TestCase
## Biology you can practise (core/biology.gd, core/biology_check.gd): the Biology page and Dr Keir's challenges.

func _mk(sex: String, over := {}, uid := 0, species := "moolet") -> Creature:
	var c := Fixtures.creature(species, 10)
	c.sex = sex
	c.uid = uid
	c.friendship = 200
	var g := {"coat": ["+", "+"], "tint": ["W", "W"], "mark": ["b", "b"], "knack": ["K", "K"], "ginger": ["o", "o"],
		"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"]}
	g.merge(over, true)
	var one_copy := Genetics.is_one_copy(sex, Genetics.sex_mode(Genetics.kindred_of(c)))
	if one_copy:
		g["ginger"] = [g["ginger"][0], "Y" if sex == "m" else "W"]
	c.genome = g
	return c

func _lab(d: GameStateData) -> void:
	d.set_flag("bio_lab_on", true)

func test_the_data_is_valid_and_ideas_exist() -> void:
	assert_eq(BiologyCheck.check(), [], "biology.json validates")
	for p in Biology.pages():
		for cond in str(p.when).split("|"):
			if cond.begins_with("idea:"):
				assert_false(StudBook.idea(cond.substr(5)).is_empty(), "%s names a real Stud Book idea" % p.id)
	assert_true(Biology.pages().size() >= 10, "ten or more pages")
	assert_eq(Biology.challenges().size(), 5)

func test_page_appears_after_meeting_keir_and_pages_open_as_you_go() -> void:
	var d := GameStateData.new()
	assert_false(Biology.visible(d), "nothing on a fresh save")
	d.set_flag("breed_met_keir", true)
	assert_true(Biology.visible(d))
	assert_true(Biology.page_open(d, Biology.page("dna")))
	assert_false(Biology.page_open(d, Biology.page("dolly")))
	d.set_flag("bio_dolly", true)
	assert_true(Biology.page_open(d, Biology.page("dolly")))
	assert_false(Biology.page_open(d, Biology.page("hybrids")))
	StudBook.unlock(d, "vigour")
	assert_true(Biology.page_open(d, Biology.page("hybrids")), "the Stud Book's vigour page opens it")
	assert_true(Biology.page_open(d, Biology.page("inbreeding")))

func test_no_challenge_until_keir_sets_them_then_in_order() -> void:
	var d := GameStateData.new()
	assert_eq(Biology.current(d), {})
	_lab(d)
	assert_eq(str(Biology.current(d).id), "marks")
	d.set_flag("bio_ch_marks", true)
	assert_eq(str(Biology.current(d).id), "daughter")

func test_truths_are_the_squares() -> void:
	var d := GameStateData.new()
	var bb := _mk("m", {"mark": ["B", "b"]})
	var bb2 := _mk("f", {"mark": ["B", "b"]})
	var bold := _mk("m", {"mark": ["B", "B"]})
	var faint := _mk("f", {"mark": ["b", "b"]})
	assert_eq(Biology.truth(d, Biology.challenge("marks"), bb, bb2), {"min": 0.5, "max": 0.5})
	assert_eq(Biology.truth(d, Biology.challenge("marks"), bold, faint), {"min": 1.0, "max": 1.0})
	assert_eq(Biology.truth(d, Biology.challenge("daughter"), bb, bb2), {"min": 0.5, "max": 0.5})
	# coat: two untested plain parents could be carriers, so none to 1 in 4
	assert_eq(Biology.truth(d, Biology.challenge("coat"), _mk("m", {"coat": ["+", "c"]}), _mk("f")), {"min": 0.0, "max": 0.25})
	assert_eq(Biology.truth(d, Biology.challenge("coat"), _mk("m", {"coat": ["c", "c"]}), _mk("f", {"coat": ["c", "c"]})), {"min": 1.0, "max": 1.0})
	var s := _mk("m", {"coat": ["+", "c"]}, 11)
	var m := _mk("f", {"coat": ["+", "c"]}, 12)
	d.set_flag("stud_tested_11", true)
	d.set_flag("stud_tested_12", true)
	assert_eq(Biology.truth(d, Biology.challenge("coat"), s, m), {"min": 0.25, "max": 0.25}, "tested parents: exact")
	# frame: the mid-parent average
	var big := _mk("m", {"frame1": ["+", "+"], "frame2": ["+", "+"], "frame3": ["+", "+"], "frame4": ["+", "-"]})
	assert_eq(Biology.truth(d, Biology.challenge("frame"), big, _mk("f")), {"min": 5.5, "max": 5.5})

func test_tortie_odds_follow_the_sex_chromosome() -> void:
	# beasts: a ginger sire's daughters all get his O; with an oo dam every daughter is Oo, so 1 in 2 overall
	assert_eq(Biology.tortie_odds(_mk("m", {"ginger": ["O", "Y"]}), _mk("f", {"ginger": ["o", "o"]})), 0.5)
	# a tortie dam and a plain sire: half the daughters, so 1 in 4
	assert_eq(Biology.tortie_odds(_mk("m"), _mk("f", {"ginger": ["O", "o"]})), 0.25)
	assert_eq(Biology.tortie_odds(_mk("m", {"ginger": ["O", "Y"]}), _mk("f", {"ginger": ["O", "O"]})), 0.0)
	# fowl are the other way round: the hen has one copy, so a cock can be tortie
	var hen := _mk("f", {"ginger": ["O", "W"]}, 0, "chipgull")
	var cock := _mk("m", {"ginger": ["o", "o"]}, 0, "chipgull")
	assert_eq(Biology.tortie_odds(cock, hen), 0.5)

func test_options_always_hold_the_truth() -> void:
	var t := {"min": 0.0, "max": 0.5}
	var opts := Biology.options(Biology.challenge("coat"), t)
	assert_true(opts.any(func(o): return o.min == 0.0 and o.max == 0.5), "the range is offered")
	var f := Biology.options(Biology.challenge("frame"), {"min": 5.5, "max": 5.5})
	assert_true(f.any(func(o): return o.min == 5.5))
	assert_true(f.size() >= 3 and f.size() <= 4)
	assert_eq(Biology.frame_words(5.5), "5 and a half pluses")
	assert_eq(Biology.frame_words(1.0), "1 plus")

func test_right_odds_are_scored_not_luck_and_pay_once() -> void:
	var d := GameStateData.new()
	_lab(d)
	var sire := _mk("m", {"mark": ["B", "b"]})
	var dam := _mk("f", {"mark": ["B", "b"]})
	var p := Biology.prompt(d, sire, dam)
	assert_eq(str(p.challenge.id), "marks")
	var pick := -1
	for i in p.options.size():
		if p.options[i].text == "1 in 2":
			pick = i
	Biology.predict(d, 501, p, pick)
	assert_true(Biology.waiting(d, 501))
	var kid := _mk("f", {"mark": ["b", "b"]}, 501)
	var money := Wallet.balance(d, Wallet.GBP)
	var r := Biology.score(d, kid)
	assert_true(r.right, "1 in 2 is right even though it hatched faint")
	assert_false(r.hit)
	assert_eq(r.money, 50)
	assert_eq(Wallet.balance(d, Wallet.GBP), money + 50)
	assert_true(Biology.done(d, "marks"))
	assert_false(Biology.waiting(d, 501))
	assert_eq(Biology.score(d, kid), {}, "scored once")
	# practice after it is met: no second grant
	d.set_flag("bio_ch_daughter", true)
	d.set_flag("bio_ch_coat", true)
	d.set_flag("bio_ch_tortie", true)
	d.set_flag("bio_ch_frame", true)
	var total := 0
	for i in 20:
		var q := Biology.prompt(d, sire, dam)
		Biology.predict(d, 600 + i, q, 0)
		total += int(Biology.score(d, _mk("f", {}, 600 + i)).money)
	assert_eq(total, 0, "practice never pays: no money from nothing")

func test_wrong_odds_say_the_square_and_the_record_counts() -> void:
	var d := GameStateData.new()
	_lab(d)
	var p := Biology.prompt(d, _mk("m", {"mark": ["B", "b"]}), _mk("f", {"mark": ["B", "b"]}))
	Biology.predict(d, 7, p, 0)  # "None"
	var r := Biology.score(d, _mk("f", {"mark": ["B", "b"]}, 7))
	assert_false(r.right)
	assert_true(r.hit)
	assert_true(str(r.lines[0]).contains("1 in 2"), r.lines[0])
	assert_eq(r.money, 0)
	assert_eq(Biology.record(d), {"None": [1, 1]})
	assert_eq(Biology.record_lines(d), ["Said \"none\" once; it came true once.", "Right odds 0 times out of 1."])

func test_old_saves_have_no_predictions() -> void:
	var d := GameStateData.from_dict({}, Fixtures.dex())
	assert_eq(Biology.record(d), {})
	assert_false(Biology.lab_on(d))
	assert_eq(Biology.score(d, _mk("f", {}, 3)), {})
