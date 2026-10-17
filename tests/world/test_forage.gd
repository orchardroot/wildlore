extends TestCase
## Foraging: season and weather weighting, the once-a-day refill, picking into the bag, and the placed props.

func _zone_with(variant: String) -> ZoneData:
	return ZoneData.from_dict({"id": "fz", "kind": "route", "rows": ["....", "....", "####"],
		"props": [{"type": "forage", "variant": variant, "x": 1, "y": 1}],
		"encounters": {"grass": [{"species": "spikkin", "min": 3, "max": 4, "weight": 1}]}})

func _share(w: Dictionary, id: String) -> float:
	var total := 0.0
	for k in w:
		total += float(w[k])
	return float(w.get(id, 0.0)) / total

func test_blackberries_and_sloes_peak_in_autumn() -> void:
	for pair in [["bramble", "blackberries"], ["blackthorn", "sloes"], ["hazel", "hazelnuts"]]:
		var autumn := float(Forage.weights(pair[0], "autumn", "clear")[pair[1]])
		var spring := float(Forage.weights(pair[0], "spring", "clear")[pair[1]])
		assert_true(autumn > spring * 4.0, "%s: %s far likelier in autumn (%f vs %f)" % [pair[0], pair[1], autumn, spring])
		assert_true(_share(Forage.weights(pair[0], "autumn", "clear"), pair[1]) > 0.7, "%s: mostly %s in autumn" % pair)
		assert_false(Forage.lean(pair[0], "autumn", "clear"), "%s: a good haul in autumn" % pair[0])
	assert_true(Forage.lean("blackthorn", "spring", "clear"), "nothing on a blackthorn in spring but a few haws")
	assert_false(Forage.lean("bramble", "spring", "clear"), "a bramble patch still has young nettles round it")

func test_slim_pickings_out_of_season() -> void:
	var rng := FixedRng.new()
	rng.f = 0.5
	rng.hi = true  # would be three picks
	var r := Forage.roll("blackthorn", "spring", "clear", rng)
	assert_eq(r.items.values().reduce(func(a, b): return a + b, 0), 1, "one pick out of season")
	r = Forage.roll("blackthorn", "autumn", "clear", rng)
	assert_eq(r.items.values().reduce(func(a, b): return a + b, 0), 3, "three in season")

func test_elderflower_and_wild_garlic_peak_in_spring() -> void:
	for pair in [["elder", "elderflower"], ["wild_garlic", "wild_garlic"]]:
		var spring := _share(Forage.weights(pair[0], "spring", "clear"), pair[1])
		var autumn := _share(Forage.weights(pair[0], "autumn", "clear"), pair[1])
		assert_true(spring > autumn, "%s: %s likelier in spring" % pair)

func test_out_of_season_still_gives_something() -> void:
	for v in Forage.VARIANTS:
		for s in Calendar.SEASONS:
			var w := Forage.weights(v, s, "clear")
			assert_false(w.is_empty(), "%s in %s gives something" % [v, s])
			assert_true(Forage.choose(w, 0.5) != "", "%s in %s picks something" % [v, s])

func test_mushrooms_after_rain() -> void:
	var dry := Forage.weights("hazel", "summer", "clear")
	var wet := Forage.weights("hazel", "summer", "drizzle")
	assert_near(float(wet.field_mushrooms), float(dry.field_mushrooms) * Forage.RAIN_MUSHROOMS)
	assert_near(float(wet.hazelnuts), float(dry.hazelnuts), 0.0001, "rain only helps the mushrooms")
	assert_true(_share(Forage.weights("mushroom_ring", "spring", "downpour"), "field_mushrooms") > _share(Forage.weights("mushroom_ring", "spring", "clear"), "field_mushrooms"))

func test_seeded_rolls_follow_the_season() -> void:
	var rng := Rng.new(7)
	var autumn := 0
	var spring := 0
	for i in 300:
		autumn += int(Forage.roll("bramble", "autumn", "clear", rng).items.get("blackberries", 0))
		spring += int(Forage.roll("bramble", "spring", "clear", rng).items.get("blackberries", 0))
	assert_true(autumn > spring * 2, "more blackberries in autumn: %d vs %d" % [autumn, spring])

func test_roll_gives_one_to_three() -> void:
	var rng := Rng.new(3)
	for i in 200:
		var r := Forage.roll("nettle_patch", "summer", "clear", rng)
		var n := 0
		for k in r.items:
			n += int(r.items[k])
		assert_true(n >= 1 and n <= 3, "1 to 3 picked, got %d" % n)

func test_bonus_and_startle_thresholds() -> void:
	var rng := FixedRng.new()
	rng.f = 0.0  # every roll lowest: a charm, and a startled creature
	var r := Forage.roll("seaweed", "summer", "clear", rng)
	assert_eq(r.bonus_kind, "charm")
	assert_eq(r.bonus, "hag_stone")
	assert_true(r.startled)
	rng.f = 0.03
	r = Forage.roll("slate_heap", "summer", "clear", rng)
	assert_eq(r.bonus_kind, "rare")
	assert_eq(r.bonus, "ammonite")
	assert_true(r.startled, "3% is under the 5% startle chance")
	rng.f = 0.5
	r = Forage.roll("bramble", "autumn", "clear", rng)
	assert_eq(r.bonus, "")
	assert_false(r.startled)

func test_refills_once_per_in_game_day() -> void:
	var d := GameStateData.new()
	var z := _zone_with("bramble")
	var p := Vector2i(1, 1)
	assert_true(Forage.is_ready(d, z.id, p), "never picked: ready")
	var items := ItemDB.load_default()
	var rng := FixedRng.new()
	rng.f = 0.5
	var first := Forage.pick(d, z, Forage.prop_at(z, p), "autumn", "clear", rng, items)
	assert_true(first.ok)
	assert_eq(d.flag("forage_fz_1_1"), 0, "remembers the in-game day")
	assert_false(Forage.is_ready(d, z.id, p), "picked clean today")
	var again := Forage.pick(d, z, Forage.prop_at(z, p), "autumn", "clear", rng, items)
	assert_false(again.ok)
	assert_eq(again.lines[0], Forage.BARE.bramble)
	d.clock_minutes = 1439
	assert_false(Forage.is_ready(d, z.id, p), "still today at 23:59")
	d.day_count += 1
	assert_true(Forage.is_ready(d, z.id, p), "after midnight it has refilled")

func test_pick_puts_materials_in_the_bag() -> void:
	var d := GameStateData.new()
	var z := _zone_with("bramble")
	var rng := FixedRng.new()
	rng.f = 0.5
	rng.hi = true  # three picks
	var r := Forage.pick(d, z, Forage.prop_at(z, Vector2i(1, 1)), "autumn", "clear", rng, ItemDB.load_default())
	assert_eq(int(d.bag.get("blackberries", 0)), 3)
	assert_eq(r.lines[0], "You picked 3 Blackberries. Your fingers are purple now.")

func test_haul_line_wording() -> void:
	var items := ItemDB.load_default()
	assert_eq(Forage.haul_line({"blackberries": 2}, items), "You picked 2 Blackberries. Your fingers are purple now.")
	assert_eq(Forage.haul_line({"sloes": 1}, items), "You picked a Sloe. You try one. Your whole face folds in half.")
	assert_eq(Forage.haul_line({"sloes": 2, "hawthorn_berry": 1}, items), "You picked 2 Sloes and a Hawthorn Berry. You try one. Your whole face folds in half.")

func test_startled_encounter_comes_from_the_zone() -> void:
	var e := Forage.startled_encounter(_zone_with("bramble"), "day", "clear", FixedRng.new())
	assert_eq(e.species, "spikkin")
	assert_eq(e.level, 3)
	var bare := ZoneData.from_dict({"id": "x", "rows": ["..."]})
	assert_true(Forage.startled_encounter(bare, "day", "clear", FixedRng.new()).is_empty())

func test_every_material_yielded_exists() -> void:
	var items := ItemDB.load_default()
	for v in Forage.VARIANTS:
		for m in Forage.VARIANTS[v].yield:
			assert_true(items.has(m), "%s yields unknown '%s'" % [v, m])
			assert_eq(str(items.get_item(m).kind), "material")
			assert_true(Forage.QUIPS.has(m), "%s has a quip" % m)
		assert_true(items.has(Forage.VARIANTS[v].rare), "%s rare find exists" % v)
		assert_true(Forage.BARE.has(v) and Forage.NAMES.has(v))
		assert_true(Forage.part_mesh(v, "Base") != null and Forage.part_mesh(v, "Ready") != null, "%s has meshes" % v)

func test_placed_forage_props_are_sound() -> void:
	var count := 0
	var zones := 0
	for path in JsonUtil.list_json(ZoneData.DIR):
		var z := ZoneData.load_id(path.get_file().get_basename())
		var fs := Forage.props_in(z)
		if fs.is_empty():
			continue
		zones += 1
		assert_true(z.kind != "interior", "%s: no foraging indoors" % z.id)
		for pr in fs:
			count += 1
			var p := Vector2i(int(pr.x), int(pr.y))
			assert_true(Forage.VARIANTS.has(str(pr.get("variant", ""))), "%s: known variant at %s" % [z.id, p])
			assert_true(z.tile_at(p) in ["grass", "flowers", "sand", "tall_grass"], "%s: forage at %s stands on soft ground, not %s" % [z.id, p, z.tile_at(p)])
			assert_true(z.warp_at(p).is_empty() and z.sign_at(p).is_empty(), "%s: forage at %s clear of warps and signs" % [z.id, p])
	assert_true(zones >= 40, "most routes have foraging (%d)" % zones)
	assert_true(count >= zones * 3, "3 or more per zone")
