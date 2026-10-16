extends TestCase
## Battle entry: the transition suits where the fight starts (grass, water, cave, trainer, legend), stays short and
## follows battle speed; the VS splash is for the big fights only, lasts about 1.5 s and never strobes.

func _wild(tile: String, extra := {}) -> String:
	var ctx := {"tile": tile, "dark": false, "stage": "grass", "interior": false}
	ctx.merge(extra, true)
	return BattleIntro.choose({"kind": "wild"}, ctx)

func test_transition_suits_where_the_fight_starts() -> void:
	assert_eq(_wild("tall_grass"), "grass", "wild in tall grass")
	assert_eq(_wild("deep_water"), "ripple", "wild in the water")
	assert_eq(_wild("water"), "ripple", "fishing from the bank")
	assert_eq(_wild("cave_floor", {"stage": "cave"}), "iris", "a cave")
	assert_eq(_wild("tall_grass", {"dark": true}), "iris", "a dark place, even in its grass")
	assert_eq(_wild("floor_wood", {"interior": true}), "iris", "indoors")
	assert_eq(_wild("path"), "grass", "anywhere else outdoors")
	assert_eq(BattleIntro.choose({"kind": "trainer", "trainer": {"class": "Hiker"}}, {"tile": "tall_grass"}), "bars", "a trainer")
	assert_eq(BattleIntro.choose({"kind": "wild", "legend": true}, {"tile": "tall_grass"}), "pulse", "a legend")
	assert_eq(BattleIntro.choose({"kind": "wild"}, {}), "grass", "no overworld (dev battles)")

func test_transitions_are_short_and_follow_battle_speed() -> void:
	for style in BattleIntro.STYLES:
		var d := BattleIntro.seconds_for(style, 1.0)
		assert_true(d >= 0.4 and d <= 1.2, "%s takes %.2f s" % [style, d])
		assert_near(BattleIntro.seconds_for(style, 2.0), d / 2.0, 0.001, style + " at Fastest")
	assert_true(BattleIntro.seconds_for("pulse", 1.0) > BattleIntro.seconds_for("grass", 1.0), "the legend's pulse is the slow one")

func test_every_transition_ends_fully_covered() -> void:
	for style in BattleIntro.STYLES:
		for reduce in [false, true]:
			assert_near(BattleIntro.cover(style, 0.0, reduce), 0.0, 0.001, "%s starts clear" % style)
			assert_near(BattleIntro.cover(style, 1.0, reduce), 1.0, 0.001, "%s ends covered" % style)

func test_legend_pulse_never_strobes_with_reduce_flashing() -> void:
	var last := 0.0
	var dips := 0
	for i in 101:
		var a := BattleIntro.cover("pulse", i / 100.0, true)
		assert_true(a >= last - 0.0001, "only ever darkens at %d%%" % i)
		last = a
	last = 0.0
	var falling := false
	for i in 101:
		var a := BattleIntro.cover("pulse", i / 100.0, false)
		if a < last - 0.001 and not falling:
			dips += 1  # a new dip starts
		falling = a < last - 0.001
		last = a
	assert_true(dips > 0 and dips <= 3, "a slow pulse (a dip or two) when flashing is allowed: %d" % dips)

func _tr(cls: String) -> Dictionary:
	return {"kind": "trainer", "trainer": {"class": cls, "name": "Someone", "sprite": "kit"}}

func test_vs_splash_is_for_the_big_fights() -> void:
	for cls in ["Keeper", "Rival", "Director", "Wind", "Champion", "Lord"]:
		assert_true(BattleIntro.wants_vs(_tr(cls)), cls)
	for cls in ["Hiker", "Warden", "Angler", ""]:
		assert_false(BattleIntro.wants_vs(_tr(cls)), cls)
	assert_false(BattleIntro.wants_vs({"kind": "wild"}), "wild")
	assert_false(BattleIntro.wants_vs({"kind": "wild", "legend": true}), "legend")
	# every real big-fight trainer qualifies
	for id in ["keeper_declan", "kit_1_vs_holtling", "wind_aelwen", "champion_garside", "vane_1", "vane_final"]:
		assert_true(BattleIntro.wants_vs({"kind": "trainer", "trainer": StoryData.trainer(id)}), id)
	assert_near(BattleIntro.VS_SECONDS, 1.5, 0.01)

func test_regions_have_their_own_stripe() -> void:
	var seen := {}
	for r in ZoneCard.REGIONS:
		var c := BattleIntro.region_colour(r)
		assert_true(c.a > 0.9, r)
		seen[c.to_html()] = true
	assert_true(seen.size() >= 10, "regions mostly differ: %d colours" % seen.size())
	assert_eq(BattleIntro.region_colour("nowhere"), BattleIntro.region_colour(""), "unknown regions share the default")

func test_vs_splash_builds_and_skips() -> void:
	InputSetup.apply(InputSetup.defaults())
	var s := BattleIntro.new()
	s.setup_vs(_tr("Keeper").trainer, "player_a", "Robin", "cheshire")
	s.build_view(Vector2(1280, 720))
	assert_true(s.has_node("Root/Stripe"), "regional stripe")
	assert_true(s.has_node("Root/Them") and s.has_node("Root/You"), "both sprites")
	assert_true(s.has_node("Root/VS"), "the VS")
	s.advance(0.2)
	assert_false(s.done)
	var ev := InputEventAction.new()
	ev.action = "confirm"
	ev.pressed = true
	assert_true(s.wants_skip(ev), "confirm skips")
	s.skip()
	assert_true(s.done, "skipped")
	s.free()
	var t := BattleIntro.new()
	t.setup_vs(_tr("Keeper").trainer, "player_a", "Robin", "cheshire")
	t.build_view(Vector2(1280, 720))
	var secs := 0.0
	while not t.done and secs < 5.0:
		t.advance(1.0 / 60.0)
		secs += 1.0 / 60.0
	assert_near(secs, BattleIntro.VS_SECONDS, 0.05, "plays its 1.5 s and ends")
	t.free()
