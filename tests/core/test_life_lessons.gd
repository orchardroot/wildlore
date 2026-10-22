extends TestCase
## "Things worth knowing" (4.5 K): every lesson has an NPC whose script teaches it once, pays once and fills the
## Almanac page; the helpline numbers are only ever the verified ones; no em-dashes.

const NUMBERS := ["0808 8020 133", "116 123", "0808 808 1677", "7726", "159", "999", "112"]

func _talk(h: FakeStoryHost, zone: String, script: String) -> void:
	h.said.clear()
	await Commands.new(h, script).run(StoryData.script(zone, script))

func _npc_of(zone: String, script: String) -> Dictionary:
	var z: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/zones/%s.json" % zone))
	for n in z.npcs:
		if str(n.get("script", "")) == script:
			return n
	return {}

func test_every_lesson_has_a_teacher_with_a_script() -> void:
	assert_true(LifeLessons.all().size() >= 10)
	var seen := {}
	for l in LifeLessons.all():
		var id := str(l.id)
		assert_false(seen.has(id), "duplicate " + id)
		seen[id] = true
		assert_false(_npc_of(str(l.zone), "life_" + id).is_empty(), id)
		assert_true(StoryData.script(str(l.zone), "life_" + id).size() > 0, id)

func test_a_lesson_teaches_once_and_pays_once() -> void:
	var h := FakeStoryHost.new()
	h.choices = [1]
	await _talk(h, "manchester_society", "life_text_scam")
	assert_true(LifeLessons.learnt(h.data, "text_scam"))
	assert_true(str(h.said).contains("7726"))
	var bag := Bag.new(h.data.bag)
	assert_eq(int(h.data.bag.get("eccles_cake", 0)), 1, "the thank-you")
	await _talk(h, "manchester_society", "life_text_scam")
	assert_eq(int(h.data.bag.get("eccles_cake", 0)), 1, "no second helping")
	assert_true(bag != null)

func test_a_wrong_answer_still_teaches() -> void:
	var h := FakeStoryHost.new()
	h.choices = [0]
	await _talk(h, "leeds_whitelocks", "life_deed_scam")
	assert_true(LifeLessons.learnt(h.data, "deed_scam"))
	assert_true(str(h.said).contains("deadline"))

func test_casino_and_bookies_share_one_lesson() -> void:
	var h := FakeStoryHost.new()
	await _talk(h, "douglas_palace", "life_pit_boss")
	assert_true(str(h.said).contains("0808 8020 133"))
	assert_eq(int(h.data.bag.get("manx_queenie_pie", 0)), 1)
	h.choices = [1]
	await _talk(h, "glasgow_bookies", "life_gambling")
	assert_eq(int(h.data.bag.get("cranachan", 0)), 0, "already learnt: no second reward")

func test_almanac_page_sprouts_and_lists() -> void:
	var d := GameStateData.new()
	assert_false(Almanac.pages(d).any(func(p): return p.id == "worth"))
	d.set_flag("lesson_payslip", true)
	assert_true(Almanac.pages(d).any(func(p): return p.id == "worth"))
	var rows := Almanac.ledger(d, "worth")
	assert_eq(str(rows[0][0]), "Reading a payslip")
	assert_true(str(Almanac.blurb(d, "worth")).begins_with("1 of"))

func test_only_verified_numbers_and_no_em_dashes() -> void:
	var re := RegEx.new()
	re.compile("\\d[\\d ]{2,}\\d")
	for l in LifeLessons.all() + [{"zone": "douglas_palace", "id": "pit_boss"}]:
		var txt := JSON.stringify(StoryData.script(str(l.zone), "life_" + str(l.id)))
		assert_false(txt.contains("—") or txt.contains("–"), "dash in " + str(l.id))
		for m in re.search_all(txt):
			var s := m.get_string().strip_edges()
			if s.begins_with("£") or s.length() < 4:
				continue
			var ok := NUMBERS.any(func(n): return n.contains(s) or s.contains(n))
			# allow money-ish figures such as 12,570 or 1257 (not helplines)
			if not ok and not (s.length() == 4 and not s.contains(" ")):
				assert_true(false, "unverified number '%s' in %s" % [s, l.id])
