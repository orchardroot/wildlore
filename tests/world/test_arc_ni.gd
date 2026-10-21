extends TestCase
## The Northern Ireland arc (3.9 Long Roads): "Three Kinds of Hands", a quest through the Linen Hall, Titanic Belfast, the
## yard, Lisburn Road Linens and the Mournes that ends with the Hands Mill opening in Belfast.

const Q := "q_arc_ni_"

func _talk(h: FakeStoryHost, zone: String, script: String) -> void:
	h.said.clear()
	h.zone = zone
	await Commands.new(h, script).run(StoryData.script(zone, script))

func _quest() -> Dictionary:
	return Quests.get_quest("arc_ni_hands")

func _examine(h: FakeStoryHost, zone: String, x: int, y: int) -> void:
	var z: ZoneData = ZoneData.load_all()[zone]
	Examine.read(h.data, zone, z.examine_at(Vector2i(x, y)), null)

func test_quest_is_well_formed() -> void:
	var q := _quest()
	assert_false(q.is_empty())
	assert_true(q.steps.size() >= 10 and q.steps.size() <= 15, "10 to 15 steps")
	for s in q.steps:
		assert_true(ZoneData.load_all().has(str(s.zone)), "step zone %s exists" % s.zone)

func test_the_whole_arc() -> void:
	var h := FakeStoryHost.new()
	var q := _quest()
	h.choices = [0]
	await _talk(h, "belfast_linenhall", "arcni_nuala")
	assert_eq(Quests.status(h.data, q), Quests.ACTIVE)
	assert_eq(Quests.step_index(h.data, q), 1, "Nuala sets you on the yard")
	_examine(h, "belfast_titanic", 12, 3)
	assert_true(h.data.flag(Q + "2"))
	await _talk(h, "belfast_yard", "arcni_mervyn")
	assert_false(ZoneData.flag_on(h.data.flag(Q + "3")), "Mervyn won't tell it to a stranger")
	h.data.set_flag("reg_mervyn", {"favour": 1})
	await _talk(h, "belfast_yard", "arcni_mervyn")
	assert_true(h.data.flag(Q + "3"))
	await _talk(h, "belfast_yard", "arcni_yardsong")
	assert_true(h.data.flag(Q + "4"), "the sing-song")
	Gazetteer.record(h.data, "arc_ni_1907")
	_examine(h, "belfast_lisburnroad", 11, 5)
	await _talk(h, "belfast_lisburnroad", "arcni_weaver")
	assert_true(h.data.flag(Q + "7"))
	await _talk(h, "mournes", "arcni_waller")
	assert_true(h.data.flag(Q + "8"))
	await _talk(h, "mournes", "arcni_waller")
	assert_false(ZoneData.flag_on(h.data.flag(Q + "9")), "the gap isn't mended until the wall is built")
	h.data.set_flag("wall_done_mournes", 1)
	await _talk(h, "mournes", "arcni_waller")
	assert_true(h.data.flag(Q + "9"))
	await _talk(h, "belfast_linenhall", "arcni_nuala")
	assert_false(ZoneData.flag_on(h.data.flag(Q + "hands_open")), "the Wall plaque comes first")
	Gazetteer.record(h.data, "arc_ni_wall_builders")
	await _talk(h, "belfast_linenhall", "arcni_nuala")
	assert_true(h.data.flag(Q + "hands_open"))
	var belfast: ZoneData = ZoneData.load_all().belfast
	var mill := {}
	for w in belfast.warps:
		if str(w.to) == "belfast_handsmill":
			mill = w
	assert_eq(ZoneData.warp_state(mill, h.data), "open", "the Hands Mill's door opens")
	await _talk(h, "belfast_handsmill", "arcni_mill_nuala")
	assert_eq(Quests.status(h.data, q), Quests.DONE)
	assert_eq(int(h.data.bag.get("ulster_hands_token", 0)), 1)
	assert_true(Standing.points(h.data, "northern_ireland") >= 8)

func test_mill_is_locked_until_the_stories_are_in() -> void:
	var h := FakeStoryHost.new()
	for w in ZoneData.load_all().belfast.warps:
		if str(w.to) == "belfast_handsmill":
			assert_eq(ZoneData.warp_state(w, h.data), "locked")

func test_arc_people_wait_for_the_post_game_and_the_quest() -> void:
	for zid in ["belfast_linenhall", "belfast_yard", "belfast_lisburnroad", "mournes"]:
		for n in ZoneData.load_all()[zid].npcs:
			if str(n.id).begins_with("arcni_"):
				assert_true(n.has("show_if"), str(n.id) + " is gated")

func test_every_quest_flag_is_set_somewhere() -> void:
	var text := ""
	for zid in ["belfast_linenhall", "belfast_titanic", "belfast_yard", "belfast_lisburnroad", "mournes", "belfast_handsmill"]:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % zid) + FileAccess.get_file_as_string("res://data/zones/%s.json" % zid)
	for s in _quest().steps:
		var f := str(s.flag).replace("plaque_", "")
		assert_true(text.contains('"%s"' % f), "%s is set somewhere" % f)
