extends TestCase
## The England long arc (3.9 Long Roads): "The Right to Roam", Kinder trespass to a moor opened to walkers.

const FILES := ["goyt_valley", "manchester_townhall", "pennine_grouse_moor"]

func _text() -> String:
	var t := ""
	for f in FILES:
		t += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % f)
	t += FileAccess.get_file_as_string("res://data/zones/blue_john_stream.json")
	return t

func test_every_arc_flag_is_set_somewhere() -> void:
	var quests = JsonUtil.read("res://data/quests/arc_england.json")
	assert_true(quests is Dictionary and quests.quests.size() == 1)
	var q: Dictionary = quests.quests[0]
	assert_true(q.steps.size() >= 10, "ten or more steps")
	var text := _text()
	var flags := [str(q.start_flag), str(q.done_flag)]
	for s in q.steps:
		flags.append(str(s.flag))
	for f in flags:
		assert_true(f.begins_with("q_arc_england_"), f + " is namespaced")
		assert_true(('"flag": "%s"' % f) in text, f + " is set by a script or an examine spot")

func test_npc_scripts_exist() -> void:
	var all := ZoneData.load_all()
	for zid in FILES:
		var scripts := StoryData.scripts_for(zid)
		for n in all[zid].npcs:
			if str(n.get("id", "")).begins_with("arc_"):
				assert_true(scripts.has(str(n.script)), "%s has script %s" % [zid, n.script])
				assert_true(n.has("show_if"), n.id + " is gated")

func test_zones_validate_and_trainer_is_scaled() -> void:
	var all := ZoneData.load_all()
	for zid in FILES + ["blue_john_stream"]:
		assert_eq(all[zid].validate(all), [], zid)
	var t := StoryData.trainer("arc_england_agent")
	assert_false(t.is_empty())
	assert_true(int(t.get("scaled_floor", 0)) > 0)

func test_reward_charm_exists() -> void:
	var items := ItemDB.load_default()
	assert_true(items.has("right_of_way_boots"))
