extends TestCase
## Mum's house as a home base: the trophy shelf built from game state, the garden plots, legends visiting
## and what Mum has to say about it all.

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.clock_minutes = 600
	d.day_count = 3
	return d

# --- the trophy shelf ---------------------------------------------------------

func test_shelf_is_empty_on_a_new_game() -> void:
	assert_eq(HomeBase.trophies(_data(), Fixtures.dex()), [])

func test_shelf_fills_in_as_you_play() -> void:
	var d := _data()
	d.badges = ["brook"]
	d.set_flag("badge_urban")  # flags count too (old saves)
	d.set_flag("fieldbook_25")
	d.set_flag("fieldbook_diploma_given")
	d.mark_caught("herne")
	d.mark_caught("kindlet")
	var t := HomeBase.trophies(d, Fixtures.dex())
	var kinds := t.map(func(x): return str(x.kind) + ":" + str(x.id))
	assert_eq(kinds, ["stone:brook", "stone:urban", "diploma:diploma", "award:25", "legend:herne"])
	for x in t:
		assert_true(str(x.name) != "" and str(x.line) != "", "%s has a name and a line" % x.id)
		assert_false(str(x.line).contains("—"), "no em-dashes")

# --- the garden ---------------------------------------------------------------

func test_planting_takes_one_from_the_bag() -> void:
	var d := _data()
	d.bag["sloes"] = 2
	assert_eq(HomeBase.plot_state(d, 1).stage, "empty")
	assert_true(HomeBase.plant(d, 1, "sloes"))
	assert_eq(int(d.bag.get("sloes", 0)), 1)
	assert_eq(HomeBase.plot_state(d, 1).material, "sloes")
	assert_eq(HomeBase.plot_state(d, 1).stage, "seed")
	assert_false(HomeBase.plant(d, 1, "sloes"), "already planted")
	assert_false(HomeBase.plant(d, 2, "hazelnuts"), "none in the bag")
	assert_false(HomeBase.plant(d, 2, "seaweed"), "seaweed won't grow in a garden")

func test_growth_stages_and_ready_next_day() -> void:
	var d := _data()
	d.bag["elderflower"] = 1
	HomeBase.plant(d, 3, "elderflower")
	d.clock_minutes += HomeBase.SPROUT_MINUTES
	assert_eq(HomeBase.plot_state(d, 3).stage, "sprout")
	d.clock_minutes += HomeBase.GROW_MINUTES
	assert_eq(HomeBase.plot_state(d, 3).stage, "growing")
	assert_false(HomeBase.plot_state(d, 3).ready)
	d.day_count += 1
	d.clock_minutes = 10
	assert_eq(HomeBase.plot_state(d, 3).stage, "ready", "ready the next in-game day")
	assert_true(HomeBase.plot_state(d, 3).ready)

func test_harvest_gives_two_to_four_and_a_bit_more_in_season() -> void:
	var d := _data()
	var lo := FixedRng.new()
	lo.f = 0.5
	var hi := FixedRng.new()
	hi.f = 0.5
	hi.hi = true
	d.bag["sloes"] = 2
	HomeBase.plant(d, 1, "sloes")
	d.day_count += 1
	var r := HomeBase.harvest(d, 1, "spring", lo)
	assert_eq(r.items, {"sloes": 2}, "two out of season at least")
	assert_eq(HomeBase.plot_state(d, 1).stage, "empty", "the plot is cleared")
	HomeBase.plant(d, 1, "sloes")
	d.day_count += 1
	r = HomeBase.harvest(d, 1, "spring", hi)
	assert_eq(r.items, {"sloes": 4})
	HomeBase.plant(d, 1, "sloes")
	d.day_count += 1
	r = HomeBase.harvest(d, 1, "autumn", hi)
	assert_eq(r.items, {"sloes": 5}, "sloes in autumn: one extra")
	assert_eq(int(d.bag.get("sloes", 0)), 2 - 1 + 2 - 1 + 4 - 1 + 5, "seeds come out of the bag, the crop goes in")

func test_harvest_not_ready_does_nothing() -> void:
	var d := _data()
	d.bag["hazelnuts"] = 1
	HomeBase.plant(d, 2, "hazelnuts")
	var r := HomeBase.harvest(d, 2, "autumn", FixedRng.new())
	assert_eq(r.items, {})
	assert_eq(HomeBase.plot_state(d, 2).material, "hazelnuts")

func test_harvest_bonus() -> void:
	var d := _data()
	var r := FixedRng.new()
	r.f = 0.001
	d.bag["rowan_berry"] = 1
	HomeBase.plant(d, 4, "rowan_berry")
	d.day_count += 1
	var res := HomeBase.harvest(d, 4, "summer", r)
	assert_eq(res.bonus_kind, "charm")
	assert_true(int(d.bag.get(str(res.bonus), 0)) >= 1, "the charm is bagged")

func test_seeds_are_real_materials() -> void:
	var items := ItemDB.load_default()
	for m in HomeBase.SEEDS:
		assert_true(items.has(m), m + " is an item")
	for m in HomeBase.CHARMS + HomeBase.RARES:
		assert_true(items.has(m), m + " is an item")

# --- visitors and Mum -----------------------------------------------------------

func test_caught_legends_visit_the_garden() -> void:
	var d := _data()
	assert_eq(HomeBase.legend_visitors(d, Fixtures.dex()), [])
	d.mark_caught("herne")
	d.mark_caught("nessie")
	d.mark_caught("kindlet")
	var v := HomeBase.legend_visitors(d, Fixtures.dex())
	assert_true("herne" in v and "nessie" in v and not "kindlet" in v)

func test_mum_notices_things() -> void:
	var d := _data()
	assert_eq(HomeBase.mum_note(d, Fixtures.dex()), "")
	d.bag["sloes"] = 1
	HomeBase.plant(d, 1, "sloes")
	d.day_count += 1
	assert_eq(HomeBase.mum_note(d, Fixtures.dex()), "garden_ready")
	d.mark_caught("herne")
	d.badges = ["brook"]
	var seen := {}
	for day in 12:
		d.day_count = 10 + day
		seen[HomeBase.mum_note(d, Fixtures.dex())] = true
	assert_true(seen.has("legends") and seen.has("stones") and seen.has("garden_ready"), "she gets round to everything: %s" % str(seen.keys()))

func test_zone_props_are_placed() -> void:
	var town := ZoneData.load_id("macclesfield")
	var plots := town.props.filter(func(p): return str(p.get("type", "")) == HomeBase.PLOT)
	assert_eq(plots.size(), 6, "six garden plots")
	for p in plots:
		var at := Vector2i(int(p.x), int(p.y))
		assert_true(town.blocked.has(at), "a plot is something you stand beside")
	var home := ZoneData.load_id("macc_home")
	assert_eq(home.props.filter(func(p): return str(p.get("type", "")) == HomeBase.SHELF and not p.has("part")).size(), 1, "one trophy shelf")

func test_mum_has_a_line_for_every_note() -> void:
	var script: Array = JsonUtil.read("res://data/dialogue/macc_home.json").mum
	var keys := []
	for c in script:
		if str(c.get("flag", "")) == HomeBase.NOTE_FLAG:
			keys.append(str(c.eq))
			assert_true(c.then.size() > 0, c.eq + " has something to say")
	keys.sort()
	assert_eq(keys, ["all_stones", "diploma", "garden_ready", "legends", "stones"])
