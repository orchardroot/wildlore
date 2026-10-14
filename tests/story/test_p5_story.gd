extends TestCase
## Plan 5 story beats against the fake host: the Iron and Frost Keepers, the Belfast to Cairnryan ferry gate, Vane and
## Manannan's Horse, Kit 7, Strachan twice, Nessie, the Cu-Sith, Garside's calls, the gates and the side quests.

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func _said_has(h: FakeStoryHost, needle: String) -> bool:
	for line in h.said:
		if String(line[1]).contains(needle):
			return true
	return false

func _npc(zone_id: String, npc_id: String) -> Dictionary:
	for n in ZoneData.load_id(zone_id).npcs:
		if n.get("id", "") == npc_id:
			return n
	return {}

# ---------------------------------------------------------------- chapter 8

func test_newgrange_end_card_became_garsides_call_north() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "newgrange_tomb", "kerrigan_tomb", "kerrigan_tomb")
	assert_eq(h.data.flag("v03_complete"), true)
	assert_eq(h.data.flag("ch8_started"), true)
	assert_true(_said_has(h, "flew north"), "the call points north")
	assert_true(_said_has(h, "Belfast"))
	assert_false(_said_has(h, "End of Wildlore"), "the v0.3 end card is gone")

func test_v03_saves_get_the_call_once_from_garside_at_newgrange() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("ch7_judged", true)
	h.data.set_flag("v03_complete", true)
	h.data.set_flag("garside_met", true)  # a save that already saw the old end card and spoke to her
	await _run(h, "newgrange", "garside_ng", "garside_ng")
	assert_eq(h.data.flag("ch8_started"), true)
	assert_true(_said_has(h, "flew north"))
	h.said.clear()
	await _run(h, "newgrange", "garside_ng", "garside_ng")
	assert_false(_said_has(h, "flew north"), "the call comes once")
	assert_eq(h.said.size(), 1)

func test_garside_at_newgrange_does_not_repeat_a_call_already_made_in_the_tomb() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "newgrange_tomb", "kerrigan_tomb", "kerrigan_tomb")
	h.said.clear()
	await _run(h, "newgrange", "garside_ng", "garside_ng")
	assert_false(_said_has(h, "flew north"))

func test_ruairi_gives_the_iron_stone_and_the_lantern() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "belfast_yard", "keeper_ruairi", "keeper_ruairi")
	assert_true("iron" in h.data.badges)
	assert_eq(h.data.flag("badge_iron"), true)
	assert_eq(h.data.flag("ch8_iron"), true)
	assert_eq(h.last_battle.opts.ai, "keeper")
	assert_eq(h.last_battle.opts.trainer.id, "keeper_ruairi")
	assert_eq(Bag.new(h.data.bag).count("lantern"), 1)
	assert_true(_said_has(h, "dark cave"), "the Iron Stone's sight in the dark is mentioned")
	h.said.clear()
	await _run(h, "belfast_yard", "keeper_ruairi", "keeper_ruairi")
	assert_eq(h.said.size(), 2, "afterwards only goodbyes")
	assert_eq(h.data.badges.count("iron"), 1)
	assert_eq(Bag.new(h.data.bag).count("lantern"), 1, "one lantern")

func test_losing_to_ruairi_gives_nothing() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "belfast_yard", "keeper_ruairi", "keeper_ruairi")
	assert_false("iron" in h.data.badges)
	assert_eq(Bag.new(h.data.bag).count("lantern"), 0)

func test_belfast_sailor_refuses_before_the_iron_stone() -> void:
	var h := FakeStoryHost.new()
	h.zone = "belfast"
	h.choices = [0]
	await _run(h, "belfast", "sailor", "belfast_sailor")
	assert_true(h.warps.is_empty(), "no Iron Stone, no crossing")

func test_belfast_sailor_sails_after_the_iron_stone() -> void:
	var h := FakeStoryHost.new()
	h.zone = "belfast"
	h.data.set_flag("badge_iron", true)
	h.choices = [0]
	await _run(h, "belfast", "sailor", "belfast_sailor")
	assert_eq(h.warps.size(), 1)
	assert_eq(h.warps[0][0], "cairnryan")

func test_cairnryan_and_kirkwall_sailors_always_sail() -> void:
	var h := FakeStoryHost.new()
	h.zone = "cairnryan"
	h.choices = [0]
	await _run(h, "cairnryan", "sailor", "cai_sailor")
	assert_eq(h.warps[0][0], "belfast")
	var a := FakeStoryHost.new()
	a.zone = "aberdeen"
	a.choices = [0]
	await _run(a, "aberdeen", "sailor", "abdn_sailor")
	assert_eq(a.warps[0][0], "kirkwall")
	var k := FakeStoryHost.new()
	k.zone = "kirkwall"
	k.choices = [0]
	await _run(k, "kirkwall", "sailor", "kwl_sailor")
	assert_eq(k.warps[0][0], "aberdeen")

func test_vane_battle_then_the_sea_takes_his_marquee() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "causeway", "vane_causeway", "vane_causeway")
	assert_eq(h.last_battle.opts.trainer.id, "vane_1")
	assert_eq(h.data.flag("ch8_vane"), true)
	assert_true(["music", "legend_sea"] in h.log)
	assert_true(_said_has(h, "We'll meet at the Moot"))
	assert_eq(h.warps.back(), ["causeway", 38, 34, "up"], "the zone reloads so Vane is gone")

func test_losing_to_vane_leaves_the_scene_unplayed() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "causeway", "vane_causeway", "vane_causeway")
	assert_false(h.data.flag("ch8_vane") == true)

func test_enbarr_only_after_the_causeway_scene() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "causeway", "enbarr", "enbarr_spot")
	assert_true(h.last_battle.is_empty(), "not before Vane's scene")
	h.data.set_flag("ch8_vane", true)
	await _run(h, "causeway", "enbarr", "enbarr_spot")
	assert_eq(h.last_battle.foes[0].species.id, "enbarr")
	assert_eq(h.last_battle.foes[0].level, 66)
	assert_true(h.last_battle.opts.no_run)
	assert_eq(h.last_battle.opts.music, "legend_sea")
	assert_false(h.data.flag("caught_enbarr") == true, "knocked out is not caught")

func test_enbarr_never_offered_twice() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("ch8_vane", true)
	h.battle_results = [{"result": "caught"}]
	await _run(h, "causeway", "enbarr", "enbarr_spot")
	assert_eq(h.data.flag("caught_enbarr"), true)
	h.last_battle = {}
	await _run(h, "causeway", "enbarr", "enbarr_spot")
	assert_true(h.last_battle.is_empty())

# ---------------------------------------------------------------- chapter 9

func test_kit_7_picks_the_right_variant() -> void:
	for st in ["spikkin", "holtling", "kindlet"]:
		var h := FakeStoryHost.new()
		h.data.set_flag("starter", st)
		await _run(h, "edinburgh", "kit_edinburgh", "kit")
		assert_eq(h.last_battle.opts.trainer.id, "kit_7_vs_" + st)
		assert_eq(h.data.flag("trainer_kit_7_vs_" + st), true)
		assert_eq(h.data.flag("kit7_done"), true)
		h.last_battle = {}
		await _run(h, "edinburgh", "kit_edinburgh", "kit")
		assert_true(h.last_battle.is_empty(), "Kit fights once")

func test_strachan_1_in_the_glen() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "glencoe", "strachan_glencoe", "strachan")
	assert_eq(h.last_battle.opts.trainer.id, "strachan_1")
	assert_eq(h.data.flag("trainer_strachan_1"), true)
	assert_eq(h.data.flag("strachan1_done"), true)
	assert_eq(h.warps.back()[0], "glencoe", "reload so she is gone")

func test_strachan_2_nessie_surfaces_and_the_enclosure_leaves() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "loch_ness", "strachan_loch_ness", "strachan_boat")
	assert_eq(h.last_battle.opts.trainer.id, "strachan_2")
	assert_eq(h.data.flag("strachan2_done"), true)
	assert_eq(h.data.flag("ch9_nessie_seen"), true)
	assert_true(["music", "legend_sea"] in h.log)
	assert_true(_said_has(h, "pulling out of Scotland"))
	assert_true(h.last_battle.foes.size() > 0)
	assert_true(h.last_battle.opts.get("kind", "") == "trainer", "Nessie's surfacing is not a battle")

func test_losing_to_strachan_2_skips_nessie() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "loch_ness", "strachan_loch_ness", "strachan_boat")
	assert_false(h.data.flag("ch9_nessie_seen") == true)

func test_isla_gives_the_frost_stone_and_waders() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "inverness_rink", "keeper_isla", "keeper_isla")
	assert_true("frost" in h.data.badges)
	assert_eq(h.data.flag("badge_frost"), true)
	assert_eq(h.last_battle.opts.trainer.id, "keeper_isla")
	assert_eq(Bag.new(h.data.bag).count("waders"), 1)
	assert_true(_said_has(h, "Bog-cross"))
	h.said.clear()
	await _run(h, "inverness_rink", "keeper_isla", "keeper_isla")
	assert_eq(h.said.size(), 1)
	assert_eq(h.data.badges.count("frost"), 1)

func test_nessie_only_after_the_frost_stone_and_never_twice() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "loch_ness", "nessie", "nessie_spot")
	assert_true(h.last_battle.is_empty(), "not before the Frost Stone")
	h.data.set_flag("badge_frost", true)
	await _run(h, "loch_ness", "nessie", "nessie_spot")
	assert_eq(h.last_battle.foes[0].species.id, "nessie")
	assert_eq(h.last_battle.foes[0].level, 74)
	assert_true(h.last_battle.opts.no_run)
	assert_eq(h.last_battle.opts.music, "legend_sea")
	h.last_battle = {}
	h.battle_results = [{"result": "caught"}]
	await _run(h, "loch_ness", "nessie", "nessie_spot")
	assert_eq(h.data.flag("caught_nessie"), true)
	h.last_battle = {}
	await _run(h, "loch_ness", "nessie", "nessie_spot")
	assert_true(h.last_battle.is_empty(), "never offered twice")

func test_cusith_barks_three_times_before_the_frost_stone() -> void:
	var h := FakeStoryHost.new()
	h.choices = [2]
	await _run(h, "faerie_glen", "cusith", "cusith_spot")
	assert_true(h.last_battle.is_empty(), "no battle before the Frost Stone")
	var barks := 0
	for line in h.said:
		if String(line[1]).begins_with("Woof."):
			barks += 1
	assert_eq(barks, 3, "three barks to count")
	assert_eq(h.data.flag("ch9_cusith_heard"), true, "the right count is noticed")

func test_cusith_only_after_the_frost_stone_and_never_twice() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_frost", true)
	await _run(h, "faerie_glen", "cusith", "cusith_spot")
	assert_eq(h.last_battle.foes[0].species.id, "cusith")
	assert_eq(h.last_battle.foes[0].level, 76)
	assert_true(h.last_battle.opts.no_run)
	assert_eq(h.last_battle.opts.music, "legend_hound")
	h.last_battle = {}
	h.battle_results = [{"result": "caught"}]
	await _run(h, "faerie_glen", "cusith", "cusith_spot")
	assert_eq(h.data.flag("caught_cusith"), true)
	h.last_battle = {}
	await _run(h, "faerie_glen", "cusith", "cusith_spot")
	assert_true(h.last_battle.is_empty())

func test_aberdeen_call_and_the_v04_end_card() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "aberdeen", "abdn_postie", "abdn_postie")
	assert_eq(h.data.flag("v04_complete"), true)
	assert_true(_said_has(h, "York. The Spirit Stone. And then the Moot."))
	assert_true(["", "End of Wildlore v0.4. The Moot is gathering."] in h.said)
	h.said.clear()
	await _run(h, "aberdeen", "abdn_postie", "abdn_postie")
	assert_false(_said_has(h, "End of Wildlore"), "the end card shows once")

# ---------------------------------------------------------------- gates

func test_gates_hide_on_the_right_flags_and_keep_off_the_edge_rows() -> void:
	# [zone, npc id, x, y, hide_if]
	var gates := [
		["belfast", "belfast_north_a", 30, 1, "badge_iron"], ["belfast", "belfast_north_b", 31, 1, "badge_iron"],
		["belfast", "belfast_north_c", 32, 1, "badge_iron"],
		["great_glen", "great_glen_east_a", 54, 20, "trainer_strachan_1"],
		["great_glen", "great_glen_east_b", 54, 21, "trainer_strachan_1"],
		["great_glen", "great_glen_east_c", 54, 22, "trainer_strachan_1"],
		["inverness", "inverness_west_a", 1, 20, "badge_frost"], ["inverness", "inverness_west_b", 1, 21, "badge_frost"],
		["inverness", "inverness_west_c", 1, 22, "badge_frost"], ["inverness", "inverness_east_a", 62, 24, "badge_frost"],
		["inverness", "inverness_east_b", 62, 25, "badge_frost"], ["inverness", "inverness_east_c", 62, 26, "badge_frost"],
	]
	for g in gates:
		var n := _npc(g[0], g[1])
		assert_false(n.is_empty(), "%s exists" % g[1])
		assert_eq(int(n.x), g[2])
		assert_eq(int(n.y), g[3])
		assert_eq(str(n.hide_if), g[4])
		var z := ZoneData.load_id(g[0])
		assert_true(int(n.x) > 0 and int(n.x) < z.width - 1 and int(n.y) > 0 and int(n.y) < z.height - 1, "%s is inside the edge strip" % g[1])
		assert_false(StoryData.script(g[0], str(n.script)).is_empty(), "%s has a script" % g[1])

func test_causeway_npcs_follow_vanes_scene() -> void:
	assert_eq(str(_npc("causeway", "vane_causeway").hide_if), "ch8_vane")
	assert_eq(str(_npc("causeway", "enbarr_spot").show_if), "ch8_vane")
	assert_eq(str(_npc("causeway", "enbarr_spot").hide_if), "caught_enbarr")

# ---------------------------------------------------------------- side quests

func test_side_quests_pay_out_existing_items() -> void:
	var h := FakeStoryHost.new()
	# Derry walls walk
	await _run(h, "derry", "walls_gunner", "walls_gunner")
	assert_eq(Bag.new(h.data.bag).count("soda_farl"), 0, "not before the guide asks")
	await _run(h, "derry", "wall_guide", "wall_guide")
	await _run(h, "derry", "walls_gunner", "walls_gunner")
	assert_eq(Bag.new(h.data.bag).count("soda_farl"), 2)
	await _run(h, "derry", "walls_gunner", "walls_gunner")
	assert_eq(Bag.new(h.data.bag).count("soda_farl"), 2, "only once")
	# Glasgow ceilidh
	await _run(h, "glasgow", "glw_ceilidh_host", "glw_ceilidh_host")
	assert_eq(Bag.new(h.data.bag).count("tablet"), 0, "not before the double battle")
	h.data.set_flag("trainer_glasgow_ceilidh", true)
	await _run(h, "glasgow", "glw_ceilidh_host", "glw_ceilidh_host")
	assert_eq(Bag.new(h.data.bag).count("tablet"), 3)
	await _run(h, "glasgow", "glw_ceilidh_host", "glw_ceilidh_host")
	assert_eq(Bag.new(h.data.bag).count("tablet"), 3, "only once")
	# Cairngorms reindeer count: 7 on the map
	await _run(h, "cairngorms", "reindeer_herder", "reindeer_herder")
	h.choices = [2]
	await _run(h, "cairngorms", "reindeer_herder", "reindeer_herder")
	assert_eq(Bag.new(h.data.bag).count("cranachan"), 2)
	await _run(h, "cairngorms", "reindeer_herder", "reindeer_herder")
	assert_eq(Bag.new(h.data.bag).count("cranachan"), 2, "only once")
	# Ring of Brodgar riddle
	h.choices = [1]
	await _run(h, "kirkwall", "brodgar_ranger", "brodgar_ranger")
	assert_eq(Bag.new(h.data.bag).count("irn_tonic"), 0, "wrong answer")
	h.choices = [0]
	await _run(h, "kirkwall", "brodgar_ranger", "brodgar_ranger")
	assert_eq(Bag.new(h.data.bag).count("irn_tonic"), 2)
	await _run(h, "kirkwall", "brodgar_ranger", "brodgar_ranger")
	assert_eq(Bag.new(h.data.bag).count("irn_tonic"), 2, "only once")

func test_reindeer_count_matches_the_map() -> void:
	var n := 0
	for npc in ZoneData.load_id("cairngorms").npcs:
		if str(npc.get("sprite", "")) == "creature:reindeer":
			n += 1
	assert_eq(n, 7, "the herder's right answer is Seven")
