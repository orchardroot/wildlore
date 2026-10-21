extends TestCase
## Langs: which language a zone uses, bilingual banners, signs and plaque titles, local-first order, the setting
## switching it all off, the words-met glossary and the Welsh data's shape.

func _index() -> Dictionary:
	return {"zones": {"cardiff": {"region": "south_wales"}, "cardiff_castle_hall": {"region": ""}, "leeds": {"region": "yorkshire"},
		"dingle": {"region": "ireland_west"}, "st_helier": {"region": "channel_islands"}, "douglas": {"region": "man"}},
		"room_town": {"cardiff_castle_hall": "cardiff"}}

func test_language_by_region_and_room() -> void:
	var i := _index()
	assert_eq(Langs.code_for("cardiff", i), "cy")
	assert_eq(Langs.code_for("cardiff_castle_hall", i), "cy", "a room borrows its town")
	assert_eq(Langs.code_for("leeds", i), "")
	assert_eq(Langs.code_for("dingle", i), "ga")
	assert_eq(Langs.code_for("st_helier", i), "jer")
	assert_eq(Langs.code_for("douglas", i), "gv")

func test_banner_shows_both_names_and_respects_setting() -> void:
	var i := _index()
	assert_eq(Langs.banner("cardiff", "Cardiff", true, i), ["Cardiff", "Caerdydd"])
	assert_eq(Langs.banner("cardiff", "Cardiff", false, i), ["Cardiff", ""])
	assert_eq(Langs.banner("leeds", "Leeds", true, i), ["Leeds", ""])

func test_welsh_goes_first_on_signs_and_titles() -> void:
	var i := _index()
	var sign := {"text": "Old.", "local": {"cy": "Castell Caerdydd"}}
	assert_eq(Langs.sign_lines(sign, "cardiff", true, i)[0], ["Castell Caerdydd", "Old."])
	assert_eq(Langs.sign_lines(sign, "cardiff", false, i)[0], ["Old."])
	var plaque := {"text": "Old.", "title": "Cardiff Castle", "plaque": "cc", "local": {"cy": "Castell Caerdydd"}}
	assert_eq(Langs.sign_title(plaque, "cardiff", true, i), "Castell Caerdydd / Cardiff Castle")
	assert_eq(Langs.sign_lines(plaque, "cardiff", true, i)[0], ["Old."], "a plaque keeps its text; the title carries the local name")
	assert_eq(Langs.sign_title(plaque, "cardiff", false, i), "Cardiff Castle")
	assert_eq(Langs.sign_title(plaque, "leeds", true, i), "Cardiff Castle", "no local language, no change")

func test_words_met_make_the_glossary() -> void:
	var d := GameStateData.new()
	var i := _index()
	assert_true(Langs.glossary(d, {}).is_empty())
	Langs.note_place(d, "cardiff", "Cardiff", i)
	Langs.note_text(d, "cy", "Diolch!")
	Langs.note_text(d, "cy", "Shwmae!")
	var g := Langs.glossary(d, {"cardiff": "Cardiff"})
	assert_eq(g.size(), 1)
	assert_eq(g[0].language, "Welsh")
	var words: Array = g[0].rows.map(func(r): return r.word)
	assert_true("Caerdydd" in words and "Diolch" in words and "Shwmae!" in words)
	var thanks: Dictionary = g[0].rows.filter(func(r): return r.word == "Diolch")[0]
	assert_eq(thanks.meaning, "thanks")

func test_greeting_is_local_or_empty() -> void:
	var i := _index()
	assert_true(Langs.greeting("cardiff", 3, true, i) in Langs.data("cy").greetings)
	assert_eq(Langs.greeting("cardiff", 3, false, i), "")
	assert_eq(Langs.greeting("leeds", 3, true, i), "")

func test_welsh_data_is_sound() -> void:
	var d := Langs.data("cy")
	assert_true(d.places.size() >= 14 and d.greetings.size() >= 6 and d.greetings.size() <= 10)
	var zones := ZoneData.load_all()
	assert_eq(Langs.check(func(z): return zones.has(z)), [])
	for p in d.places:
		assert_true(zones.has(p), p)

func test_welsh_zone_signs_carry_welsh() -> void:
	var z := ZoneData.load_id("cardiff")
	var n := 0
	for s in z.signs:
		if s.has("local"):
			n += 1
			assert_true(s.local.has("cy"))
	assert_true(n >= 4)
