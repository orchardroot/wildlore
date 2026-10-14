extends TestCase
## Plan 3 story beats against the fake host: Keeper Ray, Bev's bike, the Kit counter-starter fights and the gates.

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func test_keeper_ray_awards_urban_stone_and_rail_pass() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "liverpool_club", "keeper_ray", "keeper_ray")
	assert_true("urban" in h.data.badges)
	assert_eq(h.data.flag("badge_urban"), true)
	assert_eq(h.data.flag("ch2_urban"), true)
	assert_eq(Bag.new(h.data.bag).count("rail_pass"), 1)
	assert_eq(h.last_battle.opts.ai, "keeper")
	h.said.clear()
	await _run(h, "liverpool_club", "keeper_ray", "keeper_ray")
	assert_eq(h.said.size(), 1, "afterwards only a goodbye")
	assert_eq(Bag.new(h.data.bag).count("rail_pass"), 1, "no second pass")

func test_losing_to_keeper_ray_gives_nothing() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "liverpool_club", "keeper_ray", "keeper_ray")
	assert_false("urban" in h.data.badges)
	assert_false(h.data.flag("badge_urban") == true)
	assert_eq(Bag.new(h.data.bag).count("rail_pass"), 0)

func test_bev_gives_bike_only_with_brook_badge() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "manc_bikes", "bev", "bev")
	assert_eq(Bag.new(h.data.bag).count("bike"), 0, "no Stone, no bike")
	await _run(h, "buxton_spa", "maud", "maud")
	assert_true("brook" in h.data.badges)
	assert_eq(h.data.flag("badge_brook"), true)
	await _run(h, "manc_bikes", "bev", "bev")
	assert_eq(Bag.new(h.data.bag).count("bike"), 1)
	await _run(h, "manc_bikes", "bev", "bev")
	assert_eq(Bag.new(h.data.bag).count("bike"), 1, "only once")

func test_kit_battle_3_and_4_counter_the_starter() -> void:
	for pair in [["spikkin", "kindlet"], ["holtling", "spikkin"], ["kindlet", "holtling"]]:
		for n in [[3, "liverpool", "kit_pier", "kit3_done"], [4, "cardiff", "kit_bay", "kit4_done"]]:
			var h := FakeStoryHost.new()
			h.data.set_flag("starter", pair[0])
			await _run(h, n[1], n[2], "kit")
			assert_eq(h.data.flag("trainer_kit_%d_vs_%s" % [n[0], pair[0]]), true)
			assert_eq(h.data.flag(n[3]), true)

func test_summit_sets_woke_flag_and_takes_no_battle() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "yr_wyddfa", "summit", "pryce_summit")
	assert_eq(h.data.flag("ch3_ddraig_woke"), true)
	assert_true(h.last_battle.is_empty())
	assert_true(["music", "legend"] in h.log)

func test_dinas_emrys_offers_dragon_only_after_storm_stone() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "dinas_emrys", "ddraig", "ddraig_spot")
	assert_true(h.last_battle.is_empty(), "quiet pool before the Storm Stone")
	h.data.set_flag("badge_storm", true)
	await _run(h, "dinas_emrys", "ddraig", "ddraig_spot")
	assert_eq(h.last_battle.foes[0].species.id, "ddraig")
	assert_eq(h.last_battle.foes[0].level, 45)
	h.last_battle = {}
	h.data.set_flag("caught_ddraig", true)
	await _run(h, "dinas_emrys", "ddraig", "ddraig_spot")
	assert_true(h.last_battle.is_empty(), "not offered again once caught")

func test_douglas_lambs_reward_silver_snare() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "douglas", "farmer", "farmer")
	assert_eq(Bag.new(h.data.bag).count("silver_snare"), 0)
	for i in [1, 2, 3]:
		await _run(h, "douglas", "lamb_%d" % i, "lamb_%d" % i)
	await _run(h, "douglas", "farmer", "farmer")
	assert_eq(Bag.new(h.data.bag).count("silver_snare"), 1)
	await _run(h, "douglas", "farmer", "farmer")
	assert_eq(Bag.new(h.data.bag).count("silver_snare"), 1, "only once")
