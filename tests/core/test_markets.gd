extends TestCase
## The Stock Exchange and Doggerel: data, deterministic prices, story shocks, dealing, caps, dividends, the rug.

func _data(seed_value := 11, day := 10) -> GameStateData:
	var d := GameStateData.new()
	d.rng_seed = seed_value
	d.day_count = day
	d.money = 5000
	d.zone_id = "manchester"
	return d

func test_data_is_sound() -> void:
	var cs := Markets.companies()
	assert_true(cs.size() >= 8 and cs.size() <= 12, "8 to 12 companies, got %d" % cs.size())
	var ids := {}
	var eur := 0
	for c in cs:
		assert_false(ids.has(c.id), "unique id " + str(c.id))
		ids[c.id] = true
		for k in ["name", "sector", "about", "start", "vol", "drift", "currency"]:
			assert_true(c.has(k), "%s has %s" % [c.id, k])
		assert_true(float(c.vol) > 0.0 and float(c.vol) < 0.05, "sane volatility " + str(c.id))
		assert_true(float(c.start) > 0.0)
		assert_eq((c.get("season", [0, 0, 0, 0]) as Array).size(), 4)
		if str(c.currency) == "eur":
			eur += 1
		assert_false(str(c.about).contains("—"), "no em-dashes")
	assert_true(eur >= 1, "an Irish listing in euros")
	for want in ["Pennine Mills", "Mersey Ferries", "Cornish Tin", "Glasgow Shipyards", "Welsh Slate", "Sanctuary Holdings", "Vane Industries"]:
		assert_true(cs.any(func(c): return c.name == want), want)
	for b in ["manchester", "london", "edinburgh", "dublin"]:
		assert_false(Markets.board(b).is_empty(), "board " + b)
	assert_true(Markets.listings("dublin").all(func(id): return Markets.currency_of(id) == "eur"), "Dublin lists euro shares")
	assert_true(Markets.listings("london").all(func(id): return Markets.currency_of(id) == "gbp"))
	assert_eq(Markets.currency_of(Markets.listings("manchester")[0]), "gbp")
	assert_eq(str(Markets.company(Markets.listings("manchester")[0]).home), "manchester", "home shares first")

func test_news_has_no_em_dashes() -> void:
	var t := Markets.news_templates()
	for k in t:
		var v = t[k]
		var lines: Array = v.values() if v is Dictionary else v
		for l in lines:
			assert_false(str(l).contains("—"), str(l))

func test_prices_are_deterministic_from_seed_and_day() -> void:
	var a := Markets.price(5, "PNM", 40)
	Markets.price(6, "PNM", 80)
	assert_eq(Markets.price(5, "PNM", 40), a)
	assert_true(Markets.price(5, "PNM", 41) != a)
	assert_true(Markets.price(5, "MRF", 40) != Markets.price(5, "PNM", 40))
	assert_true(Markets.price(5, "PNM", 40) > 0.0)

func test_vane_crashes_at_the_end() -> void:
	var ev := {"ch8_vane": 30, "game_complete": 60}
	var before := Markets.price(2, "VNI", 59, ev)
	var after := Markets.price(2, "VNI", 60, ev)
	assert_true(after < before * 0.2, "Vane Industries collapses: %s -> %s" % [before, after])
	assert_true(Markets.price(2, "VNI", 30, ev) > Markets.price(2, "VNI", 30) * 1.05, "the plot pumps it first")
	assert_true(Markets.price(2, "SNH", 60, ev) > Markets.price(2, "SNH", 60), "Sanctuary Holdings up at the end")

func test_sync_stamps_flags_badges_and_rewilding_once() -> void:
	var d := _data(3, 12)
	d.set_flag("badge_stone", true)
	d.badges = ["brook", "urban", "stone"]
	var got := Markets.sync(d)
	assert_has(got, "badge_stone")
	assert_has(got, "badge:3")
	assert_eq(int(d.markets.ev.badge_stone), 12)
	d.day_count = 20
	assert_eq(Markets.sync(d).size(), 0, "nothing new")
	assert_eq(int(d.markets.ev.badge_stone), 12, "the first day sticks")
	var site := str(Rewild.sites()[0].id)
	d.set_flag(Rewild.flag_key(site), 2)
	assert_has(Markets.sync(d), "rewild:2")
	assert_true(Markets.price(3, "SNH", 20, d.markets.ev) > Markets.price(3, "SNH", 20, {}), "rewilding lifts Sanctuary Holdings")

func test_wet_weather_and_seasons_are_shared_and_bounded() -> void:
	for day in 200:
		var w := Markets.wet(4, day)
		assert_true(w >= -1.5 and w <= 1.5)
	assert_eq(Markets.season_of(0), 0)
	assert_eq(Markets.season_of(Markets.SEASON_DAYS), 1)
	assert_eq(Markets.season_of(Markets.SEASON_DAYS * 4), 0)

func test_buy_and_sell_with_commission() -> void:
	var d := _data()
	var p := Markets.price_for(d, "PNM")
	var r := Markets.buy(d, "PNM", 100)
	assert_true(r.ok, str(r.why))
	assert_eq(r.cost, ceili(100 * p - 0.000001) + Markets.commission(ceili(100 * p - 0.000001), "gbp"))
	assert_eq(d.money, 5000 - r.cost)
	assert_eq(int(Markets.holding(d, "PNM").n), 100)
	var s := Markets.sell(d, "PNM", 100)
	assert_true(s.ok)
	assert_true(d.money < 5000, "a same-day round trip costs the commission twice")
	assert_eq(int(Markets.holding(d, "PNM").n), 0)
	assert_eq(int(s.profit), int(s.got) - int(r.cost))

func test_cannot_sell_what_you_do_not_hold_or_overspend() -> void:
	var d := _data()
	assert_false(Markets.sell(d, "PNM", 1).ok)
	d.money = 10
	assert_false(Markets.buy(d, "SNH", 5).ok)
	assert_eq(d.money, 10)
	assert_false(Markets.buy(d, "NOPE", 1).ok)

func test_position_cap_grows_with_badges() -> void:
	var d := _data()
	d.money = 1000000
	var n0 := Markets.max_buy(d, "KTL")
	var p := Markets.price_for(d, "KTL")
	assert_true(n0 * p <= Markets.cap(0, "gbp"), "within the cap")
	assert_true((n0 + 1) * p > Markets.cap(0, "gbp") - 0.01, "and right up to it")
	d.badges = ["a", "b", "c", "d"]
	assert_true(Markets.max_buy(d, "KTL") > n0 * 3, "more Stones, more room")
	assert_true(Markets.buy(d, "KTL", Markets.max_buy(d, "KTL")).ok)
	assert_eq(Markets.max_buy(d, "KTL"), 0, "full")
	assert_false(Markets.buy(d, "KTL", 1).ok)

func test_euro_shares_trade_in_euros() -> void:
	var d := _data()
	d.euros = 2000
	var r := Markets.buy(d, "GVC", 50)
	assert_true(r.ok, str(r.why))
	assert_eq(r.cur, "eur")
	assert_eq(d.money, 5000, "sterling untouched")
	assert_eq(d.euros, 2000 - r.cost)
	assert_eq(Markets.buy(_data(), "GVC", 1).ok, false, "no euros, no Irish shares")

func test_dividends_pay_once_per_quarter_held() -> void:
	var d := _data(8, 25)
	assert_true(Markets.buy(d, "SNH", 100).ok)
	var cash := d.money
	d.day_count = 29
	assert_eq(Markets.settle(d).size(), 0, "nothing due yet")
	d.day_count = 31
	var lines := Markets.settle(d)
	assert_eq(lines.size(), 1, "day 30's dividend")
	assert_true(d.money > cash)
	var paid := d.money
	assert_eq(Markets.settle(d).size(), 0, "not twice")
	assert_eq(d.money, paid)
	d.day_count = 95
	assert_eq(Markets.settle(d).size(), 1, "two more quarters, paid in one line")

func test_no_dividend_for_buying_just_after_a_long_absence() -> void:
	var d := _data(8, 5)
	d.markets.settled = 5
	d.day_count = 100
	assert_true(Markets.buy(d, "SNH", 100).ok)
	d.day_count = 101
	var cash := d.money
	Markets.settle(d)
	assert_eq(d.money, cash, "only quarters you held the shares through")

func test_holdings_survive_a_save() -> void:
	var d := _data()
	Markets.buy(d, "PNM", 10)
	d.euros = 500
	Markets.buy(d, "SQY", 3)
	d.markets.ev["badge_stone"] = 4
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(int(Markets.holding(back, "PNM").n), 10)
	assert_eq(int(Markets.holding(back, "SQY").n), 3)
	assert_eq(typeof(back.markets.h.PNM.n), TYPE_INT, "JSON floats back to ints")
	assert_eq(int(back.markets.ev.badge_stone), 4)
	assert_eq(Markets.portfolio_value(back, "gbp"), Markets.portfolio_value(d, "gbp"))

func test_sanitise_shrugs_off_rubbish() -> void:
	var m := Markets.sanitise({"h": {"PNM": {"n": -3}, "MRF": "x"}, "coin": 5, "ev": [1]})
	assert_eq(m.h.size(), 0)
	assert_eq(int(m.coin.n), 0)
	assert_eq(Markets.sanitise(null).h.size(), 0)

func test_headlines_never_empty() -> void:
	var d := _data()
	for day in range(0, 60, 7):
		d.day_count = day
		var h := Markets.headlines(d)
		assert_true(h.size() >= 1)
		for l in h:
			assert_true(str(l) != "" and not str(l).contains("{"), str(l))

# --- Doggerel ---

func test_coin_editions_and_rug_pulls() -> void:
	var rugs := 0
	var last_gen := 0
	for day in 400:
		var s := Markets.coin_state(21, day)
		if int(s.flag) == 2:
			rugs += 1
			assert_eq(Markets.coin_price(21, day), 0.0, "nobody to sell to on the day")
		last_gen = int(s.gen)
	assert_true(rugs >= 4, "rugs get pulled: %d" % rugs)
	assert_eq(last_gen, rugs, "a new edition after each")
	assert_true(Markets.coin_name(1) != Markets.coin_name(0))

func test_coin_buy_sell_and_wipe_after_a_rug() -> void:
	var seed_value := 21
	var rug := -1
	for day in range(5, 400):
		if int(Markets.coin_state(seed_value, day).flag) == 2:
			rug = day
			break
	assert_true(rug > 0)
	var d := _data(seed_value, Markets.coin_state(seed_value, rug).start + 1)
	if d.day_count >= rug:
		d.day_count = rug - 1
	d.badges = ["a"]
	var n := mini(50, Markets.coin_max_buy(d))
	assert_true(n > 0)
	var r := Markets.coin_buy(d, n)
	assert_true(r.ok, str(r.why))
	assert_eq(Markets.coin_held(d), n)
	d.day_count = rug + 1
	var lines := Markets.settle(d)
	assert_true(lines.any(func(l): return l.kind == "rug"), "told about the rug")
	assert_eq(Markets.coin_held(d), 0)
	assert_false(Markets.coin_sell(d, 1).ok)

func test_coin_cap() -> void:
	var d := _data(30, 3)
	d.money = 100000
	var n := Markets.coin_max_buy(d)
	assert_true(n * Markets.coin_ask(Markets.coin_price_for(d)) <= Markets.coin_cap(0) + 0.01)
