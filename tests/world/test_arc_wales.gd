extends TestCase
## Long arcs, Wales: "Whose Pit Is It?" (data/quests/arc_wales.json). Flags, the Deep Place, the hidden door, the
## guild and Regular conditions, the quiz step, and the ending that opens the Miners' Hall.

const ZONES := ["blaenavon_bigpit_east", "blaenavon_miners_hall"]

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func test_every_arc_flag_is_set_by_some_script_or_spot() -> void:
	var text := ""
	for f in DirAccess.get_files_at("res://data/dialogue"):
		text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
	for z in ["blaenavon_bigpit", "rhondda_heritage", "blaenavon_bigpit_east"]:
		text += FileAccess.get_file_as_string("res://data/zones/%s.json" % z)
	var q: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/quests/arc_wales.json")) as Dictionary).quests[0]
	var flags: Array = [q.start_flag, q.done_flag]
	for s in q.steps:
		flags.append(s.flag)
	assert_true(q.steps.size() >= 10)
	for fl in flags:
		assert_true(str(fl).begins_with("q_arc_wales_"), fl)
		assert_true(text.contains("\"%s\"" % fl), "%s is set somewhere" % fl)

func test_the_old_workings_are_a_deep_place_behind_a_hidden_door() -> void:
	var below := ZoneData.load_id("blaenavon_bigpit_below")
	var found := false
	for w in below.warps:
		if str(w.to) == "blaenavon_bigpit_east":
			found = true
			assert_eq(str(ZoneData.warp_state(w, GameStateData.new())), "hidden")
	assert_true(found)
	var east := ZoneData.load_id("blaenavon_bigpit_east")
	assert_false(east.deep.is_empty(), "plates, a tram and a gate")

func test_the_hall_door_is_locked_until_the_key() -> void:
	var town := ZoneData.load_id("blaenavon")
	var hall: Dictionary = {}
	for w in town.warps:
		if str(w.to) == "blaenavon_miners_hall":
			hall = w
	assert_eq(str(hall.locked.needs), "miners_hall_key")
	assert_eq(str(ZoneData.load_id("blaenavon_miners_hall").warps[0].to), "blaenavon")

func test_conditions_read_guild_rank_and_regular_favour() -> void:
	var h := FakeStoryHost.new()
	var c := Commands.new(h, "")
	assert_false(c._when("guild_ramblers_1"))
	assert_false(c._when("regular_gwenllian_2"))
	h.data.set_flag("reg_gwenllian", {"favour": 2})
	assert_true(c._when("regular_gwenllian_2"))
	assert_false(c._when("regular_gwenllian_3"))

func test_cerys_starts_the_arc_and_the_vote_pays_once() -> void:
	var h := FakeStoryHost.new()
	h.choices = [0]
	await _run(h, "blaenavon", "arc_cerys", "arc_cerys")
	assert_eq(h.data.flag("q_arc_wales_1"), true)
	assert_eq(h.data.flag("q_arc_wales_started"), true)
	h.data.set_flag("q_arc_wales_9", true)
	await _run(h, "blaenavon", "arc_cerys", "arc_cerys")
	assert_eq(h.data.flag("q_arc_wales_10"), true)
	assert_eq(Bag.new(h.data.bag).count("miners_hall_key"), 1)
	await _run(h, "blaenavon", "arc_cerys", "arc_cerys")
	assert_eq(Bag.new(h.data.bag).count("miners_hall_key"), 1, "the key is given once")

func test_elwyn_waits_for_gwenllian_to_like_you() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("q_arc_wales_6", true)
	await _run(h, "rhondda_chapel", "rhn_conductor", "rhn_conductor")
	assert_false(h.data.flag("q_arc_wales_7") == true)
	h.data.set_flag("reg_gwenllian", {"favour": 2})
	await _run(h, "rhondda_chapel", "rhn_conductor", "rhn_conductor")
	assert_eq(h.data.flag("q_arc_wales_7"), true)

func test_prys_wants_a_guild_rank() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("q_arc_wales_7", true)
	await _run(h, "merthyr_pub", "arc_prys", "arc_prys")
	assert_false(h.data.flag("q_arc_wales_8") == true, "no guild, no motion")

func test_mair_opens_the_hall_and_pays_once() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("q_arc_wales_10", true)
	await _run(h, "blaenavon_miners_hall", "arc_mair", "arc_mair")
	assert_eq(h.data.flag("q_arc_wales_done"), true)
	assert_eq(Bag.new(h.data.bag).count("lodge_banner"), 1)
	await _run(h, "blaenavon_miners_hall", "arc_mair", "arc_mair")
	assert_eq(Bag.new(h.data.bag).count("lodge_banner"), 1)
