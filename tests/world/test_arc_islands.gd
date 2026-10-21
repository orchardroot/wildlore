extends TestCase
## 3.9 Long Roads, session F: the Mann and islands arc (data/quests/arc_islands.json, data/cases/island_roll.json).
## Twelve steps hopping Douglas, Lerwick, Guernsey and Jersey by ferry, with an examine trail into the Casebook,
## a shanty, a peal and a Gathering on the Douglas prom at the end.

const ZONES := ["douglas_gaiety", "douglas_tramdepot", "lerwick_pub", "lerwick_galley_shed", "guernsey_occupation", "jersey_tunnels", "st_helier_church", "douglas", "lerwick", "st_helier"]

func _flags_set(c: Variant, out: Dictionary) -> void:
	if c is Array:
		for x in c:
			_flags_set(x, out)
	elif c is Dictionary:
		if str(c.get("do", "")) == "set":
			out[str(c.get("flag", ""))] = true
		for k in ["then", "else"]:
			_flags_set(c.get(k), out)

func _quest() -> Dictionary:
	return (JsonUtil.read("res://data/quests/arc_islands.json") as Dictionary).quests[0]

func test_every_quest_flag_is_set_somewhere() -> void:
	var set_flags := {}
	var dlg := StoryData.all_dialogue()
	for file in dlg:
		for sid in dlg[file]:
			_flags_set(dlg[file][sid], set_flags)
	for zid in ZONES:
		for ex in ZoneData.load_id(zid).examine:
			if str(ex.get("flag", "")) != "":
				set_flags[str(ex.flag)] = true
	var q := _quest()
	var flags: Array = [q.start_flag, q.done_flag]
	for st in q.steps:
		flags.append(st.flag)
		assert_true(ZoneData.load_id(str(st.zone)) != null, str(st.zone))
	assert_true(q.steps.size() >= 10 and q.steps.size() <= 15)
	for f in flags:
		assert_true(str(f).begins_with("q_arc_islands_"), f)
		assert_true(set_flags.has(f), "nobody sets " + str(f))

func test_every_case_flag_is_set_or_examined() -> void:
	var set_flags := {}
	var dlg := StoryData.all_dialogue()
	for file in dlg:
		for sid in dlg[file]:
			_flags_set(dlg[file][sid], set_flags)
	var c := Casebook.get_case("island_roll")
	assert_false(c.is_empty())
	for s in c.steps:
		assert_true(set_flags.has(str(s.flag)), "nobody sets " + str(s.flag))
	var examined := {}
	for zid in ZONES:
		for ex in ZoneData.load_id(zid).examine:
			if str(ex.get("evidence", "")) != "":
				examined[str(ex.evidence)] = true
	for e in c.evidence:
		assert_true(examined.has(str(e.id)), "unreachable evidence " + str(e.id))

func test_the_arc_npcs_have_scripts_and_gates() -> void:
	for zid in ZONES:
		var z := ZoneData.load_id(zid)
		for n in z.npcs:
			if str(n.id).begins_with("arc_"):
				assert_false(StoryData.script(zid, str(n.script)).is_empty(), str(n.id))
				assert_true(n.has("show_if"), str(n.id))

func test_the_gathering_appears_only_after_the_case() -> void:
	var d := GameStateData.new()
	var reader := {}
	for n in ZoneData.load_id("douglas").npcs:
		if str(n.id) == "arc_reader":
			reader = n
	assert_false(reader.is_empty())
	assert_false(ZoneData.flag_on(d.flag(str(reader.show_if))))
	d.set_flag("q_arc_islands_11", true)
	assert_true(ZoneData.flag_on(d.flag(str(reader.show_if))))

func test_the_ribbon_is_a_real_charm() -> void:
	var items := ItemDB.load_default()
	assert_true(items.has("roll_ribbon"))
	assert_eq(str(items.get_item("roll_ribbon").kind), "charm")
