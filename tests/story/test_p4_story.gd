extends TestCase
## Plan 4 story beats against the fake host: the Fae, Kin and Tide Keepers, the ferry ticket, the Green Man and the
## Morrigan legends, the Kit counter-starter fights, Ashcombe and Kerrigan.

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func test_keeper_morwen_awards_fae_stone() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "glastonbury_tor", "keeper_morwen", "keeper_morwen")
	assert_true("fae" in h.data.badges)
	assert_eq(h.data.flag("badge_fae"), true)
	assert_eq(h.data.flag("ch5_fae"), true)
	assert_eq(h.last_battle.opts.ai, "keeper")
	h.said.clear()
	await _run(h, "glastonbury_tor", "keeper_morwen", "keeper_morwen")
	assert_eq(h.said.size(), 1, "afterwards only a goodbye")
	assert_eq(h.data.badges.count("fae"), 1, "no second Stone")

func test_losing_to_morwen_gives_nothing() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "glastonbury_tor", "keeper_morwen", "keeper_morwen")
	assert_false("fae" in h.data.badges)
	assert_false(h.data.flag("badge_fae") == true)

func test_declan_and_nuala_award_kin_and_tide() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "dublin_hall", "keeper_declan", "keeper_declan")
	assert_true("kin" in h.data.badges)
	assert_eq(h.data.flag("badge_kin"), true)
	await _run(h, "galway_docks", "keeper_nuala", "keeper_nuala")
	assert_true("tide" in h.data.badges)
	assert_eq(h.data.flag("badge_tide"), true)

func test_holyhead_sailor_refuses_without_ticket() -> void:
	var h := FakeStoryHost.new()
	h.zone = "holyhead"
	h.choices = [0]
	await _run(h, "holyhead", "sailor", "hh_sailor")
	assert_true(h.warps.is_empty(), "no ticket, no crossing")

func test_holyhead_sailor_sails_with_ticket() -> void:
	var h := FakeStoryHost.new()
	h.zone = "holyhead"
	h.data.set_flag("ferry_ticket", true)
	h.choices = [0]
	await _run(h, "holyhead", "sailor", "hh_sailor")
	assert_eq(h.warps.size(), 1)
	assert_eq(h.warps[0][0], "dublin")

func test_dublin_sailor_always_sails_back() -> void:
	var h := FakeStoryHost.new()
	h.zone = "dublin"
	h.choices = [0]
	await _run(h, "dublin", "sailor", "dub_sailor")
	assert_eq(h.warps[0][0], "holyhead")

func test_ashcombe_mine_gives_the_ferry_ticket_once() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "geevor", "ashcombe_mine", "ashcombe_mine")
	assert_eq(h.data.flag("ashcombe2_done"), true)
	assert_eq(h.data.flag("ferry_ticket"), true)
	assert_eq(Bag.new(h.data.bag).count("ferry_ticket"), 1)
	await _run(h, "geevor", "ashcombe_mine", "ashcombe_mine")
	assert_eq(Bag.new(h.data.bag).count("ferry_ticket"), 1, "only once")

func test_green_man_wakes_then_is_offered_only_after_fae_stone() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_true(h.last_battle.is_empty(), "no battle before the Fae Stone")
	assert_eq(h.data.flag("ch5_greenman_woke"), true, "the orchard scene plays first")
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_true(h.last_battle.is_empty(), "the second visit before the Stone is only a hint")
	h.data.set_flag("badge_fae", true)
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_eq(h.last_battle.foes[0].species.id, "greenman")
	assert_eq(h.last_battle.foes[0].level, 55)
	assert_true(h.last_battle.opts.no_run)

func test_green_man_never_offered_after_caught() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_fae", true)
	h.data.set_flag("caught_greenman", true)
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_true(h.last_battle.is_empty())

func test_green_man_catch_sets_flag_and_ends_the_offer() -> void:
	var h := FakeStoryHost.new()
	h.data.set_flag("badge_fae", true)
	h.battle_results = [{"result": "caught"}]
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_eq(h.data.flag("caught_greenman"), true)
	h.last_battle = {}
	await _run(h, "glastonbury_tor", "greenman", "greenman_spot")
	assert_true(h.last_battle.is_empty())

func test_kit_5_and_6_counter_the_starter() -> void:
	for pair in [["spikkin", "kindlet"], ["holtling", "spikkin"], ["kindlet", "holtling"]]:
		for n in [[5, "glastonbury", "kit_glaston", "kit5_done"], [6, "galway", "kit_galway", "kit6_done"]]:
			var h := FakeStoryHost.new()
			h.data.set_flag("starter", pair[0])
			await _run(h, n[1], n[2], "kit")
			assert_eq(h.data.flag("trainer_kit_%d_vs_%s" % [n[0], pair[0]]), true)
			assert_eq(h.data.flag(n[3]), true)

func test_kit_5_picks_the_right_trainer_file() -> void:
	for st in ["spikkin", "holtling", "kindlet"]:
		var h := FakeStoryHost.new()
		h.data.set_flag("starter", st)
		await _run(h, "glastonbury", "kit_glaston", "kit")
		assert_eq(h.last_battle.opts.trainer.id, "kit_5_vs_" + st)

func test_ashcombe_1_sets_the_tintagel_flag() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "tintagel", "ashcombe_tintagel", "ashcombe")
	assert_eq(h.data.flag("ashcombe1_done"), true)
	assert_eq(h.data.flag("trainer_ashcombe_1"), true)

func test_kerrigan_launch_has_no_battle() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "dublin", "kerrigan_launch", "kerrigan_launch")
	assert_true(h.last_battle.is_empty())
	assert_eq(h.data.flag("ch6_launch"), true)

func test_newgrange_scene_then_morrigan_offered_once() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "newgrange_tomb", "morrigan", "morrigan_spot")
	assert_true(h.last_battle.is_empty(), "not before the judgement")
	await _run(h, "newgrange_tomb", "kerrigan_tomb", "kerrigan_tomb")
	assert_eq(h.last_battle.opts.trainer.id, "kerrigan_2")
	assert_eq(h.data.flag("ch7_judged"), true)
	assert_eq(h.data.flag("v03_complete"), true)
	assert_true(["music", "legend_crow"] in h.log)
	assert_true(["sfx", "tomb_light"] in h.log)
	assert_eq(h.data.flag("ch8_started"), true, "Garside's call north replaces the v0.3 end card")
	for line in h.said:
		assert_false(String(line[1]).begins_with("End of Wildlore"), "the v0.3 end card is gone")
	h.last_battle = {}
	h.battle_results = [{"result": "caught"}]
	await _run(h, "newgrange_tomb", "morrigan", "morrigan_spot")
	assert_eq(h.last_battle.foes[0].species.id, "morrigan")
	assert_eq(h.last_battle.foes[0].level, 60)
	assert_eq(h.data.flag("caught_morrigan"), true)
	h.last_battle = {}
	await _run(h, "newgrange_tomb", "morrigan", "morrigan_spot")
	assert_true(h.last_battle.is_empty(), "never offered twice")

func test_losing_to_kerrigan_2_skips_the_judgement() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "newgrange_tomb", "kerrigan_tomb", "kerrigan_tomb")
	assert_false(h.data.flag("ch7_judged") == true)
	assert_false(h.data.flag("v03_complete") == true)

func test_cardiff_has_no_v02_end_card_now() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "cardiff_arena", "keeper_rhys", "keeper_rhys")
	assert_eq(h.data.flag("v02_complete"), true)
	assert_eq(h.data.flag("ch5_started"), true)
	for line in h.said:
		assert_false(String(line[1]).begins_with("End of Wildlore"), "the end card moved to Newgrange")

func test_side_quests_pay_out_existing_items() -> void:
	var h := FakeStoryHost.new()
	h.choices = [0]
	await _run(h, "bath", "heritage_stall", "heritage_stall")
	await _run(h, "bath_baths", "spring_keeper", "spring_keeper")
	assert_eq(Bag.new(h.data.bag).count("cream_tea"), 1)
	await _run(h, "bath_baths", "spring_keeper", "spring_keeper")
	assert_eq(Bag.new(h.data.bag).count("cream_tea"), 1, "only once")
	await _run(h, "ring_of_kerry", "deer_ranger", "deer_ranger")
	h.choices = [2]
	await _run(h, "ring_of_kerry", "deer_ranger", "deer_ranger")
	assert_eq(Bag.new(h.data.bag).count("barmbrack"), 2)
	await _run(h, "cork", "market_fishmonger", "market_fishmonger")
	await _run(h, "cork", "market_baker", "market_baker")
	await _run(h, "cork", "market_spice", "market_spice")
	await _run(h, "cork", "market_fishmonger", "market_fishmonger")
	assert_eq(Bag.new(h.data.bag).count("soda_bread"), 3)
	h.choices = [0]
	await _run(h, "sligo", "sligo_poet", "sligo_poet")
	assert_eq(Bag.new(h.data.bag).count("kendal_mint_cake"), 2)
