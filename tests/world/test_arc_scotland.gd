extends TestCase
## 3.9 Long Roads, the Scotland arc ("The Braes Remembered", data/quests/arc_scotland.json): every quest flag is set
## somewhere in the data, the Braes Hall is locked until the arc is done, and every referenced script exists.

const ARC := "res://data/quests/arc_scotland.json"
const ZONES := ["skye", "skye_braes_hall", "portree", "portree_kirk", "edinburgh_exchange", "inverness_castle", "fort_william", "glencoe"]

func _blob() -> String:
	var out := ""
	for z in ZONES:
		var path := "res://data/zones/%s.json" % z
		out += FileAccess.get_file_as_string(path)
		var dp := "res://data/dialogue/%s.json" % z
		if FileAccess.file_exists(dp):
			out += FileAccess.get_file_as_string(dp)
	return out

func test_every_arc_flag_is_set_somewhere() -> void:
	var q: Dictionary = JsonUtil.read(ARC).quests[0]
	var blob := _blob()
	var flags: Array = [q.start_flag, q.done_flag]
	for s in q.steps:
		flags.append(s.flag)
	for f in flags:
		assert_true(blob.contains('"%s"' % f), "flag never mentioned: " + str(f))
	assert_eq(q.steps.size(), 10)

func test_arc_steps_name_real_zones() -> void:
	var q: Dictionary = JsonUtil.read(ARC).quests[0]
	for s in q.steps:
		assert_true(ZoneData.load_id(str(s.zone)) != null, "no zone " + str(s.zone))

func test_hall_door_is_locked_until_done() -> void:
	var skye := ZoneData.load_id("skye")
	var found := false
	for w in skye.warps:
		if w.to == "skye_braes_hall":
			found = true
			assert_eq(str(w.locked.needs), "q_arc_scotland_done")
	assert_true(found)
	assert_eq(ZoneData.load_id("skye_braes_hall").warps[0].to, "skye")

func test_npc_scripts_exist() -> void:
	for z in ZONES:
		for n in ZoneData.load_id(z).npcs:
			if str(n.id).begins_with("arc_scot_"):
				assert_true(StoryData.script(z, str(n.script)).size() > 0, "no script " + str(n.script))
