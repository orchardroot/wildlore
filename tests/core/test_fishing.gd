extends TestCase
## Fishing: pools by water and region, the bite bar, the daily cap, the catch ledger, and that a loop of casting
## can't print money (see Fishing). Pure rules; the overworld and the bar overlay just play them.

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.bag["fishing_rod"] = 1
	return d

func _fish_ids(pool: Array) -> Array:
	return pool.filter(func(e): return e.has("id")).map(func(e): return str(e.id))

func test_fish_items_are_real_items_with_prices() -> void:
	var db := ItemDB.load_default()
	var n := 0
	for it in JSON.parse_string(FileAccess.get_file_as_string("res://data/items/fish.json")):
		if str(it.kind) == "fish":
			n += 1
			assert_true(int(it.price) > 0, "%s is worth something" % it.id)
			assert_true(db.has(str(it.id)))
	assert_true(n >= 15, "at least 15 fish: %d" % n)

func test_every_pool_entry_exists() -> void:
	var db := ItemDB.load_default()
	for g in Fishing.groups():
		for kind in Fishing.groups()[g]:
			for e in Fishing.groups()[g][kind]:
				if e.has("id"):
					assert_true(db.has(str(e.id)), "%s/%s: %s" % [g, kind, e.id])

func test_no_rod_no_cast() -> void:
	assert_true(Fishing.refusal(GameStateData.new(), "water", "") != "", "needs a rod")
	assert_eq(Fishing.refusal(_data(), "water", ""), "")
	assert_true(Fishing.refusal(_data(), "grass", "") != "", "only water")

func test_salt_and_fresh() -> void:
	assert_eq(Fishing.water_kind("", "sea"), "salt")
	assert_eq(Fishing.water_kind("", "water"), "fresh")
	assert_eq(Fishing.water_kind("overseas_bermuda", "deep_water"), "salt", "an island's water is the sea")

func test_pools_suit_the_place() -> void:
	var river := _fish_ids(Fishing.pool("yorkshire", "water", "summer", 0, 1))
	assert_has(river, "brown_trout")
	assert_false("mackerel" in river)
	var sea := _fish_ids(Fishing.pool("yorkshire", "sea", "summer", 0, 1))
	assert_has(sea, "mackerel")
	assert_false("brown_trout" in sea)
	assert_has(_fish_ids(Fishing.pool("overseas_cayman", "sea", "summer", 0, 1)), "great_barracuda")
	assert_has(_fish_ids(Fishing.pool("overseas_falklands", "sea", "winter", 0, 1)), "patagonian_toothfish")
	assert_has(_fish_ids(Fishing.pool("ireland_west", "water", "autumn", 0, 1)), "atlantic_salmon")

func test_seasons_gate_fish() -> void:
	assert_false("mackerel" in _fish_ids(Fishing.pool("", "sea", "winter", 0, 1)))
	assert_false("atlantic_salmon" in _fish_ids(Fishing.pool("", "water", "spring", 0, 1)))
	assert_has(_fish_ids(Fishing.pool("", "water", "autumn", 0, 1)), "atlantic_salmon")

func test_line_creatures_wait_for_badges_and_are_never_wild() -> void:
	var early := Fishing.pool("", "water", "summer", 0, 1).filter(func(e): return e.has("species"))
	assert_eq(early.map(func(e): return e.species), ["holtling"])
	var late := Fishing.pool("", "water", "summer", 4, 1).filter(func(e): return e.has("species"))
	assert_eq(late.size(), 2)
	for z in ZoneData.load_all().values():
		for kind in z.encounters:
			for e in z.encounters[kind]:
				assert_false(str(e.species) in ["holtling", "aqueduck", "swelkie"], "%s is on a line only (%s)" % [e.species, z.id])

func test_a_better_rod_favours_the_rare() -> void:
	var p1 := Fishing.pool("", "water", "autumn", 0, 1)
	var p2 := Fishing.pool("", "water", "autumn", 0, 2)
	var w := func(p: Array, id: String) -> float:
		for e in p:
			if str(e.get("id", "")) == id:
				return float(e.weight)
		return 0.0
	assert_true(w.call(p2, "atlantic_salmon") > w.call(p1, "atlantic_salmon"))
	assert_eq(w.call(p2, "roach"), w.call(p1, "roach"), "common fish unchanged")

func test_cast_picks_along_the_weights() -> void:
	var pool := [{"id": "roach", "weight": 1.0}, {"id": "perch", "weight": 3.0}]
	assert_eq(Fishing.pick(pool, 0.1).id, "roach")
	assert_eq(Fishing.pick(pool, 0.9).id, "perch")

func test_bar_marker_sweeps_there_and_back() -> void:
	assert_near(Fishing.marker(0.0, 2.0), 0.0)
	assert_near(Fishing.marker(1.0, 2.0), 1.0)
	assert_near(Fishing.marker(2.0, 2.0), 0.0)
	assert_near(Fishing.marker(0.5, 2.0), 0.5)

func test_easy_mode_is_wider_and_slower() -> void:
	var n := Fishing.bar(1, false)
	var e := Fishing.bar(1, true)
	assert_true(e.half > n.half, "wider sweet spot")
	assert_true(e.period > n.period, "slower marker")
	assert_true(Fishing.bar(2, false).half > n.half, "a match rod is kinder")
	assert_true(e.tries > n.tries)

func test_hit_window() -> void:
	assert_true(Fishing.hit(0.5, 0.55, 0.1))
	assert_false(Fishing.hit(0.2, 0.55, 0.1))

func test_the_sweet_spot_stays_on_the_bar() -> void:
	var r := FixedRng.new()
	for f in [0.0, 1.0]:
		r.f = f
		var c := Fishing.centre(r, 0.2)
		assert_true(c >= 0.2 and c <= 0.8, "centre %s" % c)

func test_daily_cap_resets_each_day() -> void:
	var d := _data()
	d.day_count = 3
	for i in Fishing.daily_casts():
		assert_true(Fishing.casts_left(d) > 0)
		Fishing.spend_cast(d)
	assert_eq(Fishing.casts_left(d), 0)
	assert_true(Fishing.refusal(d, "water", "") != "", "they've stopped biting")
	d.day_count = 4
	assert_eq(Fishing.casts_left(d), Fishing.daily_casts())

func test_catch_goes_in_the_bag_and_the_counter() -> void:
	var d := _data()
	Fishing.land(d, "roach")
	Fishing.land(d, "roach")
	assert_eq(int(d.bag.roach), 2)
	assert_eq(TrainerStats.get_count(d, "fish_caught"), 2)

func test_old_save_has_no_fish_and_a_default_setting() -> void:
	var back := GameStateData.from_dict({"money": 5}, Fixtures.dex())
	assert_eq(TrainerStats.get_count(back, "fish_caught"), 0)
	assert_eq(Fishing.casts_left(back), Fishing.daily_casts())
	assert_false(Settings.easy_fishing)

## Fish sell through the Ledger at no more than their base price, so a day's fishing, played perfectly with the best
## rod in the best water, pays a modest sum and can never mint money out of nothing.
func test_a_day_of_fishing_cannot_print_money() -> void:
	var d := _data()
	var db := ItemDB.load_default()
	for group in Fishing.groups():
		for kind in Fishing.groups()[group]:
			var pool: Array = Fishing.groups()[group][kind].filter(func(e): return e.has("id"))
			var total := 0.0
			var worth := 0.0
			for e in pool:
				total += float(e.weight)
				var v := Trade.sell_price(d, str(e.id), "")
				assert_true(v <= int(db.get_item(str(e.id)).price), "%s never sells above its base" % e.id)
				worth += float(e.weight) * v
			var per_cast := worth / total
			assert_true(per_cast * Fishing.daily_casts() < 3000.0, "%s/%s: a day's fishing is %d" % [group, kind, per_cast * Fishing.daily_casts()])
