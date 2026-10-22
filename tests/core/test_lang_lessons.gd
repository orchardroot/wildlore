extends TestCase
## LangLessons (4.5): lessons from teachers, the extra lesson files, certificates by level, the Leitner review
## timetable, questions both ways, the word of the day, learnt greetings and sign glosses, "Say it" after a battle,
## the teacher's command and the validator.

func _w(id: String, local: String, english: String) -> Dictionary:
	return {"id": id, "local": local, "english": english, "say": "TEST"}

func _fixture() -> void:
	Langs.reset()
	var t := {"zone": "cardiff_wmc", "x": 3, "y": 2, "name": "Tess", "sprite": "poet"}
	Langs._cache["zz"] = {"name": "Testish", "lessons": [
		{"id": "zz_01", "title": "Hello", "level": 1, "teacher": t, "intro": ["Hi."],
			"words": [_w("morn", "Mornio", "Good morning"), _w("eve", "Evio", "Good evening"), _w("cat", "Catto", "Cat"),
				_w("castle", "Castello", "Castle"), _w("dog", "Doggo", "Dog"), _w("yes", "Yeppo", "Yes")]},
		{"id": "zz_03", "title": "Grammar", "level": 2, "teacher": t, "intro": ["More."],
			"words": [_w("a", "Aa", "A"), _w("b", "Bb", "B"), _w("c", "Cc", "C"), _w("d", "Dd", "D"), _w("e", "Ee", "E"), _w("f", "Ff", "F")]}]}
	LangLessons._extra["zz"] = [{"id": "zz_02", "title": "More hello", "level": 1, "teacher": {"zone": "swansea_dtc", "x": 2, "y": 2, "name": "Rae", "sprite": "poet"},
		"intro": ["Hi again."], "words": [_w("g", "Gg", "G"), _w("h", "Hh", "H"), _w("i", "Ii", "I"), _w("j", "Jj", "J"), _w("k", "Kk", "K"), _w("l", "Ll", "L")]}]

func test_extra_file_lessons_are_appended_and_sorted() -> void:
	_fixture()
	assert_eq(LangLessons.lessons("zz").map(func(l): return l.id), ["zz_01", "zz_02", "zz_03"])
	assert_eq(LangLessons.code_of("sco_ulster_02"), "sco_ulster")
	assert_eq(str(LangLessons.word("zz", "g").lesson), "zz_02")

func test_levels_unlock_with_certificates() -> void:
	_fixture()
	var d := GameStateData.new()
	assert_true(LangLessons.unlocked(d, "zz", 1))
	assert_false(LangLessons.unlocked(d, "zz", 2), "level 2 needs the level 1 certificate")
	assert_eq(LangLessons.next_lesson(d, "zz_01").id, "zz_01")
	assert_eq(LangLessons.learn(d, "zz_01"), [], "one of two level 1 lessons: no certificate yet")
	assert_true(LangLessons.next_lesson(d, "zz_01").is_empty(), "the next from Tess is level 2, still shut")
	assert_eq(LangLessons.learn(d, "zz_02"), [1])
	assert_true(d.flag("lang_cert_zz_1") == true)
	assert_eq(LangLessons.next_lesson(d, "zz_01").id, "zz_03")
	assert_eq(TrainerStats.get_count(d, "lessons_taken"), 2)
	assert_eq(TrainerStats.get_count(d, "lang_certs"), 1)
	assert_true(Almanac.words_met(d) >= 12, "learnt words count as words met")

func test_leitner_boxes() -> void:
	_fixture()
	var d := GameStateData.new()
	LangLessons.learn(d, "zz_01")
	assert_eq(LangLessons.card(d, "zz", "cat"), [1, 1])
	assert_eq(LangLessons.due_count(d, "zz"), 0, "nothing due the day you learn it")
	LangLessons.review(d, "zz", "cat", true)
	assert_eq(LangLessons.card(d, "zz", "cat"), [1, 1], "practice before it's due changes nothing")
	d.day_count = 1
	assert_eq(LangLessons.due_count(d, "zz"), 6)
	LangLessons.review(d, "zz", "cat", true)
	assert_eq(LangLessons.card(d, "zz", "cat"), [2, 3])
	LangLessons.review(d, "zz", "dog", false)
	assert_eq(LangLessons.card(d, "zz", "dog"), [1, 1], "a miss goes back to box 1, due now")
	assert_eq(LangLessons.due_text(d, "zz", "cat"), "in 2 days")
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(LangLessons.card(back, "zz", "cat"), [2, 3], "survives a save")

func test_questions_both_ways() -> void:
	_fixture()
	var rng := Rng.new(3)
	var qs := LangLessons.check_round("zz_01", rng)
	assert_eq(qs.size(), 6)
	for q in qs:
		assert_eq(q.options.size(), 4)
		assert_true(int(q.answer) >= 0)
		var w := LangLessons.word("zz", str(q.word))
		assert_eq(q.options[q.answer], w.english if q.dir == "meaning" else w.local)
	assert_true(qs.any(func(q): return q.dir == "say") and qs.any(func(q): return q.dir == "meaning"))
	var d := GameStateData.new()
	assert_eq(LangLessons.review_round(d, "zz", rng), [])
	LangLessons.learn(d, "zz_01")
	assert_eq(LangLessons.review_round(d, "zz", rng).size(), 6, "practice when nothing is due")

func test_word_of_day_greeting_and_sign() -> void:
	_fixture()
	var d := GameStateData.new()
	assert_true(LangLessons.word_of_day(d, "", 4).is_empty())
	assert_eq(str(LangLessons.word_of_day(d, "zz", 0).code), "zz", "a taster from the local first lesson")
	LangLessons.learn(d, "zz_01")
	assert_eq(LangLessons.time_greeting(d, "zz", 9 * 60), "Mornio!")
	assert_eq(LangLessons.time_greeting(d, "zz", 19 * 60), "Evio!")
	assert_eq(LangLessons.time_greeting(d, "zz", 14 * 60), "", "no afternoon word learnt")
	assert_eq(LangLessons.sign_gloss(d, "zz", "Castello Caerdydd"), "You know: Castello: Castle.")
	assert_eq(LangLessons.sign_gloss(d, "zz", "Castellomania"), "", "whole words only")

func test_say_it_offer_is_rare_and_capped() -> void:
	_fixture()
	var d := GameStateData.new()
	assert_false(LangLessons.say_it_offer(d, "zz", true, 0.0), "nothing learnt")
	LangLessons.learn(d, "zz_01")
	assert_true(LangLessons.say_it_offer(d, "zz", true, 0.0))
	assert_false(LangLessons.say_it_offer(d, "zz", true, 0.9))
	assert_false(LangLessons.say_it_offer(d, "zz", false, 0.0), "languages switched off")
	assert_false(LangLessons.say_it_offer(d, "", true, 0.0), "not in a language's own country")
	for i in LangLessons.SAY_IT_PER_DAY:
		LangLessons.say_it_used(d)
	assert_false(LangLessons.say_it_offer(d, "zz", true, 0.0), "a few a day at most")
	d.day_count += 1
	assert_true(LangLessons.say_it_offer(d, "zz", true, 0.0))

func test_teacher_npcs_one_per_spot() -> void:
	Langs.reset()
	var n := LangLessons.npcs_for("cardiff_wmc").filter(func(x): return str(x.id).begins_with("lang_teacher_cy"))
	assert_eq(n.size(), 1, "one teacher per spot, however many lessons")
	assert_eq(n[0].id, "lang_teacher_cy_01")
	assert_eq(n[0].script_file, "lang_lessons")

func test_teacher_command_passes_and_certifies() -> void:
	var h := FakeStoryHost.new()
	h.zone = "cardiff_wmc"
	h.choices = [0]
	h.menu_results = {"lang:lesson:cy_01": {"score": 7, "total": 7}}
	await Commands.new(h, "lang_teacher_cy_01").run([{"do": "lesson"}])
	assert_true(LangLessons.done(h.data, "cy_01"))
	assert_true(LangLessons.learnt(h.data, "cy", "bore_da"))
	var h2 := FakeStoryHost.new()
	h2.choices = [0]
	h2.menu_results = {"lang:lesson:cy_01": {"score": 2, "total": 7}}
	await Commands.new(h2, "lang_teacher_cy_01").run([{"do": "lesson"}])
	assert_false(LangLessons.done(h2.data, "cy_01"), "a fail teaches nothing yet")
	var h3 := FakeStoryHost.new()
	await Commands.new(h3, "lang_teacher_cy_01").run([{"do": "lesson"}])
	assert_false(LangLessons.done(h3.data, "cy_01"), "saying not now is fine")

func test_say_it_command_pays_a_little_or_passes() -> void:
	var h := FakeStoryHost.new()
	h.zone = "cardiff"
	LangLessons.learn(h.data, "cy_01")
	var money := h.data.money
	await Commands.new(h).run([{"do": "say_it"}])
	assert_eq(h.data.money, money, "the default answer is Pass: no harm, no prize")
	assert_eq(LangLessons.say_it_today(h.data), 1)
	var q := LangLessons.say_it_question(h.data, "cy", Rng.new(1))
	assert_eq(q.options.size(), 4)

func test_real_lessons_validate() -> void:
	var zones := ZoneData.load_all()
	assert_eq(LangLessons.check(func(z): return zones.get(z), ZoneIndex.get_index()), [])
	assert_true(LangLessons.lessons("cy").size() >= 2)
	assert_eq(LangLessons.lang_name("cy"), "Welsh")
	for l in LangLessons.lessons("cy"):
		assert_eq(Langs.code_for(str(l.teacher.zone), ZoneIndex.get_index()), "cy", "Welsh teachers stand in Wales")

func test_validator_catches_bad_lessons() -> void:
	var zones := ZoneData.load_all()
	var idx := ZoneIndex.get_index()
	var bad := [{"id": "cy_1", "title": "", "level": 5, "intro": [], "words": [{"id": "x", "local": "X", "english": "", "say": "ˈeks"}],
		"teacher": {"zone": "leeds", "x": 0, "y": 0, "name": "Bob", "sprite": "nobody"}}]
	var errs := LangLessons.check_list("cy", bad, func(z): return zones.get(z), idx)
	for bit in ["id should be", "no title", "level should", "intro should", "6 to 10", "no 'english'", "not IPA", "no art", "free floor tile", "not a Welsh-speaking"]:
		assert_true(errs.any(func(e): return bit in e), bit + " in " + str(errs))
