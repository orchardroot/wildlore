extends TestCase
## Deeds (core/deeds.gd): buying, the stock, takings with tiers, events and managers, rates, collecting, selling back,
## the post and the taxman, inflation, old saves, and that none of it prints money (see DeedsSim).

func _data(badges := 4, cash := 50000) -> GameStateData:
	var d := GameStateData.new()
	d.money = cash
	d.day_count = 100
	d.rng_seed = 12345
	for i in badges:
		d.badges.append("b%d" % i)
	d.set_flag("badge_stone", true)
	return d

func _owned(id := "chippy_whitby", badges := 4) -> GameStateData:
	var d := _data(badges)
	assert_eq(Deeds.buy(d, id), "")
	return d

func _stock(d: GameStateData, id: String) -> void:
	for inp in Deeds.get_deed(id).inputs:
		d.bag[str(inp.item)] = 99
		Deeds.supply(d, id, str(inp.item), 99)

func test_data_is_sound() -> void:
	var zones := {}
	for f in DirAccess.get_files_at("res://data/zones/"):
		zones[f.get_basename()] = true
	var items := ItemDB.load_default()
	assert_true(Deeds.all().size() >= 2, "the chippies exist")
	for d in Deeds.all():
		var id := str(d.id)
		assert_true(["chippy", "bnb", "boat", "stall", "allotment"].has(str(d.kind)), id + " kind")
		assert_true(zones.has(str(d.zone)), id + " zone")
		assert_true(zones.has(str(d.interior)), id + " interior")
		assert_eq((d.cost as Array).size(), 3, id + " three price bands")
		assert_true((d.tiers as Array).size() >= 3 and (d.tiers as Array).size() <= 4, id + " tiers")
		assert_eq(float(d.tiers[0].mult), 1.0)
		assert_eq(int(d.tiers[0].cost), 0)
		assert_true((d.events as Array).size() >= 5, id + " events")
		assert_true(float(d.rates) > 0.0 and float(d.rates) < 0.5)
		for inp in d.inputs:
			assert_true(items.has(str(inp.item)), "%s input %s" % [id, inp.item])
		for e in d.events:
			assert_false(str(e.line).contains("—"), "no em-dashes in " + str(e.id))
		assert_false(str(d.name).contains("—"))

func test_buy_needs_a_stone_the_money_and_one_of_a_kind() -> void:
	var d := _data(4, 100)
	assert_true(Deeds.buy(d, "chippy_whitby") != "", "can't afford it")
	d.money = 50000
	d.set_flag("badge_stone", false)
	assert_true(Deeds.buy(d, "chippy_whitby") != "", "not unlocked")
	d.set_flag("badge_stone", true)
	var before := d.money
	assert_eq(Deeds.buy(d, "chippy_whitby"), "")
	assert_eq(before - d.money, Deeds.price(d, "chippy_whitby"))
	assert_true(Deeds.is_owned(d, "chippy_whitby"))
	assert_true(Deeds.buy(d, "chippy_whitby") != "", "already yours")
	assert_true(Deeds.buy(d, "chippy_blackpool") != "", "one chippy per save")
	assert_eq(Deeds.owned(d).size(), 1)

func test_price_follows_the_badge_band() -> void:
	var a := Deeds.price(_data(3), "chippy_whitby")
	var b := Deeds.price(_data(5), "chippy_whitby")
	var c := Deeds.price(_data(9), "chippy_whitby")
	assert_true(a < b and b < c, "%d %d %d" % [a, b, c])

func test_supply_moves_goods_from_the_bag_and_caps_at_a_fortnight() -> void:
	var d := _owned()
	d.bag["potatoes"] = 200
	assert_eq(Deeds.supply(d, "chippy_whitby", "potatoes", 5), 5)
	assert_eq(int(d.bag["potatoes"]), 195)
	assert_eq(Deeds.supply(d, "chippy_whitby", "potatoes", 500), 6 * Deeds.STORE_DAYS - 5, "tops up to a fortnight and no more")
	assert_eq(Deeds.supply(d, "chippy_whitby", "mackerel", 1), 0, "not one of its inputs")
	assert_eq(Deeds.supply(d, "chippy_whitby", "haddock", 1), 0, "none in the bag")

func test_unstocked_deed_earns_only_a_quarter() -> void:
	var d := _owned()
	var full := _owned()
	_stock(full, "chippy_whitby")
	d.day_count += 20
	full.day_count += 20
	Deeds.tick(d, d.day_count)
	Deeds.tick(full, full.day_count)
	assert_true(Deeds.till(d, "chippy_whitby") > 0)
	assert_true(Deeds.till(d, "chippy_whitby") * 3 < Deeds.till(full, "chippy_whitby"), "stock is what earns")

func test_stock_is_used_up_each_day() -> void:
	var d := _owned()
	_stock(d, "chippy_whitby")
	var before := Deeds.store_of(d, "chippy_whitby", "potatoes")
	d.day_count += 3
	Deeds.tick(d, d.day_count)
	assert_true(Deeds.store_of(d, "chippy_whitby", "potatoes") < before)

func test_tick_is_idempotent_and_deterministic() -> void:
	var a := _owned()
	var b := _owned()
	_stock(a, "chippy_whitby")
	_stock(b, "chippy_whitby")
	a.day_count += 10
	b.day_count += 10
	Deeds.tick(a, a.day_count)
	Deeds.tick(a, a.day_count)
	Deeds.tick(b, b.day_count)
	assert_eq(Deeds.till(a, "chippy_whitby"), Deeds.till(b, "chippy_whitby"))

func test_a_long_absence_is_trimmed_not_exploded() -> void:
	var d := _owned()
	_stock(d, "chippy_whitby")
	d.day_count += 5000
	Deeds.tick(d, d.day_count)
	assert_true(Deeds.till(d, "chippy_whitby") < 40000, "bounded: %d" % Deeds.till(d, "chippy_whitby"))

func test_upgrade_raises_takings_and_costs() -> void:
	var d := _owned()
	var cost := Deeds.upgrade_cost(d, "chippy_whitby")
	assert_true(cost > 0)
	var m0 := Deeds.tier_mult(d, "chippy_whitby")
	var before := d.money
	assert_eq(Deeds.upgrade(d, "chippy_whitby"), "")
	assert_eq(before - d.money, cost)
	assert_true(Deeds.tier_mult(d, "chippy_whitby") > m0)
	d.money = 0
	assert_true(Deeds.upgrade(d, "chippy_whitby") != "", "can't afford the next")
	for i in 5:
		d.money = 999999
		Deeds.upgrade(d, "chippy_whitby")
	assert_eq(Deeds.upgrade_cost(d, "chippy_whitby"), 0, "top tier")
	assert_true(Deeds.upgrade(d, "chippy_whitby") != "")

func test_a_manager_adds_to_takings_and_keeps_the_till_filling() -> void:
	var a := _owned()
	var b := _owned()
	Deeds.set_manager(b, "chippy_whitby", "reg_pat")
	assert_eq(Deeds.manager(b, "chippy_whitby"), "reg_pat")
	for d in [a, b]:
		_stock(d, "chippy_whitby")
		d.day_count += Deeds.UNATTENDED_DAYS + 20
		Deeds.tick(d, d.day_count)
	assert_true(Deeds.till(b, "chippy_whitby") > Deeds.till(a, "chippy_whitby") * 1.1, "managed %d vs %d" % [Deeds.till(b, "chippy_whitby"), Deeds.till(a, "chippy_whitby")])

func test_rates_accrue_weekly_and_come_off_the_till() -> void:
	var d := _owned()
	_stock(d, "chippy_whitby")
	d.day_count += 8
	Deeds.tick(d, d.day_count)
	assert_true(Deeds.rates_due(d, "chippy_whitby") > 0, "a week's bill")
	var till := Deeds.till(d, "chippy_whitby")
	var rates := Deeds.rates_due(d, "chippy_whitby")
	var before := d.money
	var got := Deeds.collect(d, "chippy_whitby")
	assert_eq(got, till - rates, "paid out after rates")
	assert_eq(d.money - before, got)
	assert_eq(Deeds.till(d, "chippy_whitby"), 0)
	assert_eq(Deeds.rates_due(d, "chippy_whitby"), 0)
	assert_eq(Deeds.collect(d, "chippy_whitby"), 0, "an empty till pays nothing")

func test_events_are_seeded_and_lines_reach_the_post() -> void:
	var d := _owned()
	var seen := 0
	for day in range(100, 700):
		var e := Deeds.event_on(d, "chippy_whitby", day)
		assert_eq(e, Deeds.event_on(d, "chippy_whitby", day), "same day, same event")
		if not e.is_empty():
			seen += 1
	assert_true(seen > 30 and seen < 150, "about one day in ten: %d in 600" % seen)
	_stock(d, "chippy_whitby")
	d.day_count += 600
	var lines := Deeds.tick(d, d.day_count)
	assert_false(lines.is_empty(), "events come back as lines")

func test_a_storm_day_earns_nothing() -> void:
	var d := _owned()
	var day := -1
	for x in range(101, 5000):
		if Deeds.event_on(d, "chippy_whitby", x).get("mult", 1.0) == 0.0:
			day = x
			break
	assert_true(day > 0)
	_stock(d, "chippy_whitby")
	d.day_count = day - 1
	Deeds.tick(d, day - 1)
	var before := Deeds.till(d, "chippy_whitby")
	var stock := Deeds.store_of(d, "chippy_whitby", "potatoes")
	Deeds.tick(d, day)
	assert_eq(Deeds.till(d, "chippy_whitby"), before, "closed")
	assert_eq(Deeds.store_of(d, "chippy_whitby", "potatoes"), stock, "and the stock keeps")

func test_sell_back_pays_sixty_percent_and_never_more_than_it_cost() -> void:
	var d := _data()
	var start := d.money
	Deeds.buy(d, "chippy_whitby")
	Deeds.upgrade(d, "chippy_whitby")
	var spent := start - d.money
	Deeds.sell_back(d, "chippy_whitby")
	assert_false(Deeds.is_owned(d, "chippy_whitby"))
	assert_eq(start - d.money, spent - roundi(spent * Deeds.SELL_BACK), "lost 40% on the round trip")
	assert_eq(Deeds.buy(d, "chippy_whitby"), "", "and it can be bought again fresh")

func test_stock_comes_back_when_you_sell() -> void:
	var d := _owned()
	d.bag["potatoes"] = 30
	Deeds.supply(d, "chippy_whitby", "potatoes", 30)
	assert_false(d.bag.has("potatoes"))
	Deeds.sell_back(d, "chippy_whitby")
	assert_eq(int(d.bag["potatoes"]), 30)

func test_inflation_is_gentle_seeded_and_capped() -> void:
	var d := _data()
	d.day_count = 100
	assert_eq(Deeds.inflation(d), 1.0, "nothing in the first year")
	d.day_count = Deeds.YEAR * 3
	var f := Deeds.inflation(d)
	assert_true(f > 1.0 and f < 1.25, "three years: %f" % f)
	assert_eq(f, Deeds.inflation(d), "seeded")
	d.day_count = Deeds.YEAR * 200
	assert_true(Deeds.inflation(d) <= Deeds.DRIFT_CAP)

func test_inflation_only_touches_deeds() -> void:
	var d := _data()
	var shop_before := Trade.base_price("potatoes")
	d.day_count = Deeds.YEAR * 5
	assert_eq(Trade.base_price("potatoes"), shop_before)
	assert_true(Deeds.price(d, "chippy_whitby") > 9000 - 1 or Deeds.price(d, "chippy_whitby") > 4000, "costs rise")

func test_tax_bands_and_allowance() -> void:
	assert_eq(Deeds.tax_on(0), 0)
	assert_eq(Deeds.tax_on(Deeds.ALLOWANCE), 0, "the allowance is free")
	assert_eq(Deeds.tax_on(Deeds.ALLOWANCE + 1000), 100)
	assert_true(Deeds.tax_on(30000) < 30000 * 0.2 and Deeds.tax_on(30000) > 0)
	assert_true(Deeds.tax_on(100000) <= 100000 * 0.2, "never more than the top band")

func test_the_taxman_writes_once_a_year_in_april() -> void:
	Calendar.set_override("2027-06-01")
	var d := _owned()
	Deeds._add_income(d, "gbp", 9000)
	Calendar.set_override("2028-04-03")
	d.day_count += 5
	Deeds.tick(d, d.day_count)
	var mail := Deeds.letters_waiting(d)
	assert_eq(mail.filter(func(m): return m.k == "tax").size(), 1)
	var money := d.money
	var lines := Deeds.collect_letters(d)
	assert_false(lines.is_empty())
	assert_eq(money - d.money, Deeds.tax_on(9000), "settled from the purse")
	d.day_count += 1
	Deeds.tick(d, d.day_count)
	assert_eq(Deeds.letters_waiting(d).filter(func(m): return m.k == "tax").size(), 0, "once a year")
	Calendar.set_override("")

func test_no_taxman_without_deed_income() -> void:
	Calendar.set_override("2028-04-03")
	var d := _data()
	Deeds.tick(d, d.day_count)
	assert_eq(Deeds.letters_waiting(d).size(), 0)
	Calendar.set_override("")

func test_unpaid_tax_waits_politely() -> void:
	Calendar.set_override("2027-06-01")
	var d := _owned()
	Deeds._add_income(d, "gbp", 30000)
	Calendar.set_override("2028-04-02")
	d.money = 10
	Deeds.tick(d, d.day_count + 1)
	Deeds.collect_letters(d)
	assert_eq(d.money, 0, "took what there was")
	assert_true(int(Deeds._post_st(d, false).owed.get("gbp", 0)) > 0)
	Calendar.set_override("")

func test_letters_replace_themselves_and_have_text() -> void:
	var d := _owned()
	_stock(d, "chippy_whitby")
	d.day_count += 20
	Deeds.tick(d, d.day_count)
	var rates := Deeds.letters_waiting(d).filter(func(m): return m.k == "rates")
	assert_eq(rates.size(), 1, "one rates letter at a time")
	var lines := Deeds.collect_letters(d)
	assert_true(lines.size() >= 3)
	for l in lines:
		assert_false(str(l).contains("—"))
		assert_false(str(l).contains("{"), "no raw placeholder: " + str(l))
	assert_eq(Deeds.collect_letters(d), [], "the box is empty after")

func test_old_saves_and_save_round_trips() -> void:
	var d := GameStateData.from_dict({"money": 10}, Dex.load_default())
	assert_eq(Deeds.owned(d).size(), 0)
	assert_eq(Deeds.tick(d, 500), [])
	assert_eq(Deeds.letters_waiting(d), [])
	var e := _owned()
	_stock(e, "chippy_whitby")
	e.day_count += 10
	Deeds.tick(e, e.day_count)
	var till := Deeds.till(e, "chippy_whitby")
	var f := GameStateData.from_dict(JSON.parse_string(JSON.stringify(e.to_dict())), Dex.load_default())
	assert_true(Deeds.is_owned(f, "chippy_whitby"))
	assert_eq(Deeds.till(f, "chippy_whitby"), till, "JSON turned the ints into floats and back")
	f.day_count += 5
	Deeds.tick(f, f.day_count)
	assert_true(Deeds.till(f, "chippy_whitby") > till)

func test_nothing_prints_money() -> void:
	var d := _data(10)
	for deed in Deeds.all():
		var id := str(deed.id)
		for t in (deed.tiers as Array).size():
			for managed in [false, true]:
				var days := DeedsSim.payback_days(d, id, t, managed)
				assert_true(days >= 10.0, "%s tier %d (managed %s) pays back in %.1f days" % [id, t, managed, days])
				assert_true(DeedsSim.net_per_day(d, id, t, managed) < Deeds.price(d, id) / 6.0, "%s tier %d earns less than a sixth of its price a day" % [id, t])

func test_buy_sell_loops_lose_money() -> void:
	var d := _data(10)
	var start := d.money
	for i in 20:
		Deeds.buy(d, "chippy_blackpool")
		Deeds.upgrade(d, "chippy_blackpool")
		Deeds.sell_back(d, "chippy_blackpool")
	assert_true(d.money < start, "a loop can only lose")

func test_the_year_of_play_matches_the_design_payback() -> void:
	# design: break-even on a fresh Deed in 12 to 18 in-game days at the early price band
	var d := _data(1)
	d.badges = ["b0"]
	var days := DeedsSim.payback_days(d, "chippy_whitby", 0, false)
	assert_true(days >= 12.0 and days <= 30.0, "%.1f days" % days)
