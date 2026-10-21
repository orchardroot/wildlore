extends TestCase
## The Ireland arc (3.9 Long Roads): Rás na dTonnta, the Wild Atlantic Way boat by boat. Its quest flags are each set by
## a script, its NPCs and rooms exist and validate, and the finished race changes the world.

const ZONES := ["dingle_boat_hut", "dingle_pierbar", "dingle_marina", "galway_docks", "gweedore_colaiste", "tory_island", "cork_pairc"]

func test_zones_validate() -> void:
	var all := ZoneData.load_all()
	for zid in ZONES:
		assert_eq(all[zid].validate(all), [], zid)

func test_every_quest_flag_is_set_somewhere() -> void:
	var quests = JsonUtil.read("res://data/quests/arc_ireland.json")
	assert_true(quests is Dictionary and quests.quests.size() == 1)
	var q: Dictionary = quests.quests[0]
	assert_true(q.steps.size() >= 10 and q.steps.size() <= 15, "10 to 15 steps")
	var text := ""
	for zid in ZONES:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % zid)
		text += FileAccess.get_file_as_string("res://data/zones/%s.json" % zid)
	var flags := [str(q.start_flag), str(q.done_flag)]
	for s in q.steps:
		flags.append(str(s.flag))
	for f in flags:
		assert_true(f.begins_with("q_arc_ireland_"), f + " is namespaced")
		assert_true(('"flag": "%s"' % f) in text, f + " is set by a script or an examine spot")

func test_arc_uses_the_new_verbs() -> void:
	var text := ""
	for zid in ZONES:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % zid)
		text += FileAccess.get_file_as_string("res://data/zones/%s.json" % zid)
	for verb in ['"do": "sing"', '"do": "games"', '"do": "battle"', '"examine"']:
		assert_true(verb in text, verb)
	assert_true('"do": "deed"' in FileAccess.get_file_as_string("res://data/dialogue/dingle_boat_hut.json"), "the Deed counter")
	assert_has(Shanties.cfg().pubs, "dingle_pierbar")

func test_npcs_and_scripts_exist() -> void:
	var all := ZoneData.load_all()
	for zid in ZONES:
		for n in all[zid].npcs:
			if str(n.get("id", "")).begins_with("arc_ie_"):
				assert_false(StoryData.script(zid, str(n.script)).is_empty(), str(n.id) + " has a script")
	assert_eq(JsonUtil.read("res://data/trainers/arc_ie_crew.json").scaled_floor, 97, "post-game par")
	assert_true(ItemDB.load_default().has("naomhog_oar"))

func test_finishing_changes_the_world() -> void:
	var all := ZoneData.load_all()
	var shown := 0
	for n in all.galway_docks.npcs:
		if str(n.get("show_if", "")) == "q_arc_ireland_done":
			shown += 1
	assert_eq(shown, 1, "a regatta steward appears at Galway docks")
	assert_eq(all.dingle_boat_hut.npcs.filter(func(n): return n.id == "arc_ie_nora")[0].show_if, "game_complete", "post-game")
