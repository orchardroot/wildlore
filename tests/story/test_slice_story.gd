extends TestCase
## The slice's real scripts, run against the fake host: once-only beats, the Kit fight (win and lose), the Keeper.

class StarterHost extends FakeStoryHost:
	var pick := "spikkin"
	func open_menu(menu: String) -> Variant:
		log.append(["menu", menu])
		return pick if menu == "starter" else null

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

func test_mum_gives_tea_once() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "macc_home", "mum")
	assert_eq(Bag.new(h.data.bag).count("cup_of_tea"), 3)
	await _run(h, "macc_home", "mum")
	assert_eq(Bag.new(h.data.bag).count("cup_of_tea"), 3, "no second helping")

func test_garside_counter_picks_and_kit_battle() -> void:
	for pair in [["spikkin", "kindlet"], ["holtling", "spikkin"], ["kindlet", "holtling"]]:
		var h := StarterHost.new()
		h.pick = pair[0]
		await _run(h, "macc_fieldstation", "garside", "garside")
		assert_eq(h.last_battle.foes[0].species.id, pair[1], "Kit counters %s" % pair[0])
		assert_eq(h.data.flag("trainer_kit_1_vs_" + pair[0]), true)
		assert_eq(Bag.new(h.data.bag).count("wicker_snare"), 5)
		assert_eq(Bag.new(h.data.bag).count("fieldbook"), 1)

func test_losing_to_kit_whites_out_but_keeps_snares() -> void:
	var h := StarterHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_eq(h.warps.size(), 1, "whiteout warp")
	assert_eq(Bag.new(h.data.bag).count("wicker_snare"), 5)
	assert_false(h.data.flag("trainer_kit_1_vs_spikkin") == true)
	# Talking to Garside again just points the way east; no second fight.
	h.last_battle = {}
	await _run(h, "macc_fieldstation", "garside", "garside")
	assert_true(h.last_battle.is_empty())

func test_maud_awards_brook_stone_and_ends_slice() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "buxton_spa", "maud", "maud")
	assert_true("brook" in h.data.badges)
	assert_eq(h.said.back()[1], "Thanks for playing the Wildlore slice.")
	assert_eq(h.last_battle.opts.ai, "keeper")
	h.said.clear()
	await _run(h, "buxton_spa", "maud", "maud")
	assert_eq(h.said.size(), 1, "afterwards only a goodbye")

func test_losing_to_maud_gives_no_badge() -> void:
	var h := FakeStoryHost.new()
	h.battle_results = [{"result": "lose"}]
	await _run(h, "buxton_spa", "maud", "maud")
	assert_false("brook" in h.data.badges)
