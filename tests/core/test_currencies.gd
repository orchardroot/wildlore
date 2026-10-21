extends TestCase
## The overseas territories' own money: the region mapping, pegs, par pounds, the two new floating walks, purses that
## default empty in old saves, the bureau pairs and the tourist rate for the wrong money.

func _data(zone := "macclesfield") -> GameStateData:
	var d := GameStateData.new()
	d.zone_id = zone
	d.rng_seed = 42
	d.money = 1000
	return d

func test_region_to_currency_mapping() -> void:
	var want := {
		"overseas_gibraltar": "gip", "overseas_akrotiri": "eur", "overseas_dhekelia": "eur",
		"overseas_sovereign_base_areas": "eur", "overseas_ascension": "shp", "overseas_st_helena": "shp",
		"overseas_saint_helena": "shp", "overseas_tristan": "gbp", "overseas_tristan_da_cunha": "gbp",
		"overseas_falklands": "fkp", "overseas_falkland_islands": "fkp", "overseas_south_georgia": "gbp",
		"overseas_antarctic": "gbp", "overseas_bat": "gbp", "overseas_bermuda": "bmd", "overseas_cayman": "kyd",
		"overseas_turks_caicos": "usd", "overseas_bvi": "usd", "overseas_virgin_islands": "usd",
		"overseas_anguilla": "xcd", "overseas_montserrat": "xcd", "overseas_pitcairn": "nzd",
		"overseas_biot": "usd", "overseas_diego_garcia": "usd",
	}
	for r in want:
		assert_eq(Wallet.currency_for_region(r), want[r], r)
	assert_eq(Wallet.currency_for_region("channel_islands", "jersey_st_helier"), "jep", "St Helier is Jersey, not St Helena")
	assert_eq(Wallet.currency_for_region("channel_islands", "st_peter_port"), "ggp")
	assert_eq(Wallet.currency_for_region("channel_islands", "sark"), "ggp")
	assert_eq(Wallet.currency_for_region("overseas_jersey"), "jep")
	assert_eq(Wallet.currency_for_region("overseas_guernsey"), "ggp")
	assert_eq(Wallet.currency_for_region("cotswolds"), "", "no opinion on the mainland")

func test_symbols_and_names() -> void:
	assert_eq(Wallet.fmt(1500, "usd"), "US$1,500")
	assert_eq(Wallet.fmt(20, "bmd"), "BD$20")
	assert_eq(Wallet.fmt(20, "kyd"), "CI$20")
	assert_eq(Wallet.fmt(20, "xcd"), "EC$20")
	assert_eq(Wallet.fmt(20, "nzd"), "NZ$20")
	assert_eq(Wallet.fmt(20, "gip"), "£20")
	assert_eq(Wallet.name_of("gip"), "Gibraltar pounds")
	assert_eq(Wallet.name_of("fkp"), "Falkland Islands pounds")
	assert_eq(Wallet.name_of("shp"), "Saint Helena pounds")
	assert_eq(Wallet.name_of("jep"), "Jersey pounds")
	assert_eq(Wallet.name_of("ggp"), "Guernsey pounds")
	assert_eq(Wallet.name_of("gbp"), "sterling")

func test_new_purses_default_empty_and_old_saves_load() -> void:
	var d := _data()
	assert_eq(d.purses, {}, "no new purses until you earn some")
	var back := GameStateData.from_dict(d.to_dict(), null)
	assert_eq(back.purses, {})
	var old := d.to_dict()
	old.erase("purses")
	assert_eq(GameStateData.from_dict(old, null).purses, {}, "an old save has none")
	Wallet.earn(d, 40, "usd")
	Wallet.earn(d, 7, "gip")
	var again := GameStateData.from_dict(d.to_dict(), null)
	assert_eq(Wallet.balance(again, "usd"), 40)
	assert_eq(Wallet.balance(again, "gip"), 7)
	assert_eq(again.money, 1000, "sterling untouched")
	assert_eq(again.euros, 0)

func test_junk_in_purses_is_ignored() -> void:
	var raw := _data().to_dict()
	raw["purses"] = {"usd": 12, "bogus": 5, "nzd": -3, "kyd": "x"}
	var d := GameStateData.from_dict(raw, null)
	assert_eq(Wallet.balance(d, "usd"), 12)
	assert_eq(Wallet.balance(d, "nzd"), 0)
	assert_eq(Wallet.balance(d, "kyd"), 0)
	assert_false(d.purses.has("bogus"))

func test_purses_stay_apart() -> void:
	var d := _data()
	Wallet.earn(d, 100, "usd")
	assert_false(Wallet.spend(d, 101, "usd"))
	assert_true(Wallet.spend(d, 100, "usd"))
	assert_eq(Wallet.balance(d, "usd"), 0)
	assert_eq(d.money, 1000)
	Wallet.earn(d, 50, "gip")
	assert_eq(Wallet.balance(d, "jep"), 0, "Gibraltar notes are not Jersey notes")

func test_halve_all_halves_every_purse() -> void:
	var d := _data()
	Wallet.earn(d, 100, "usd")
	Wallet.earn(d, 9, "gip")
	Wallet.halve_all(d)
	assert_eq(Wallet.balance(d, "usd"), 50)
	assert_eq(Wallet.balance(d, "gip"), 4)
	assert_eq(d.money, 500)

func test_pegs() -> void:
	for s in [1, 2, 3]:
		for day in [0, 10, 100]:
			var usd := Forex.per_gbp("usd", s, day)
			assert_near(Forex.per_gbp("bmd", s, day), usd, 0.000001, "BMD is 1:1 with USD")
			assert_near(Forex.per_gbp("kyd", s, day), usd / 1.2, 0.000001, "1 KYD = 1.20 USD")
			assert_near(Forex.per_gbp("xcd", s, day), usd * 2.7, 0.000001, "2.70 XCD to the USD")
			for p in ["gip", "fkp", "shp", "jep", "ggp"]:
				assert_eq(Forex.per_gbp(p, s, day), 1.0, p + " is at par")

func test_floating_walks_are_seeded_and_believable() -> void:
	assert_eq(Forex.per_gbp("usd", 7, 30), Forex.per_gbp("usd", 7, 30))
	Forex.per_gbp("usd", 8, 90)
	assert_eq(Forex.per_gbp("usd", 7, 30), Forex.per_gbp("usd", 7, 30), "another seed in between doesn't disturb it")
	assert_true(Forex.per_gbp("usd", 7, 31) != Forex.per_gbp("usd", 7, 30), "it moves")
	assert_true(Forex.per_gbp("nzd", 7, 31) != Forex.per_gbp("nzd", 7, 30))
	var lo := {"usd": 9.0, "nzd": 9.0}
	var hi := {"usd": 0.0, "nzd": 0.0}
	for s in range(1, 21):
		for day in range(0, 300, 5):
			for c in ["usd", "nzd"]:
				var v := Forex.per_gbp(c, s, day)
				lo[c] = minf(lo[c], v)
				hi[c] = maxf(hi[c], v)
	assert_true(lo.usd >= 1.15 and hi.usd <= 1.50, "USD %s..%s" % [lo.usd, hi.usd])
	assert_true(lo.nzd >= 2.00 and hi.nzd <= 2.55, "NZD %s..%s" % [lo.nzd, hi.nzd])
	assert_true(hi.usd - lo.usd > 0.04, "and it does wander")
	assert_eq(Forex.per_gbp("eur", 7, 30), Forex.mid(7, 30), "the euro walk is untouched")
	assert_eq(Forex.per_gbp("gbp", 7, 30), 1.0)

func test_bureau_pair_round_trips_lose_and_par_fee_is_small() -> void:
	var d := _data("gibraltar")
	Wallet.earn(d, 1000, "gip")
	var r := Forex.exchange(d, 1000, "gip", "gbp")
	assert_true(r.ok)
	assert_eq(r.cur, "gbp")
	assert_true(int(r.got) < 1000 and int(r.got) >= 970, "a small fee: %s" % r.got)
	assert_eq(Wallet.balance(d, "gip"), 0)
	assert_eq(d.money, 1000 + int(r.got))
	var back := Forex.exchange(d, 500, "gbp", "gip")
	assert_true(back.ok and int(back.got) < 500 and int(back.got) >= 480)

func test_bureau_usd_against_sterling() -> void:
	var d := _data()
	var m := Forex.per_gbp("usd", d.rng_seed, d.day_count, Markets.events_of(d))
	var r := Forex.exchange(d, 100, "gbp", "usd")
	assert_true(r.ok)
	assert_eq(r.cur, "usd")
	assert_eq(Wallet.balance(d, "usd"), int(r.got))
	assert_true(int(r.got) <= floori(100 * m), "never better than the middle rate")
	assert_true(int(r.got) >= floori(100 * m * 0.95))
	var back := Forex.exchange(d, int(r.got), "usd", "gbp")
	assert_true(back.ok and int(back.got) < 100, "a round trip costs")
	assert_false(Forex.exchange(d, 10, "usd", "gbp").ok, "can't change what you haven't got")

func test_old_two_argument_exchange_still_works() -> void:
	var d := _data()
	var r := Forex.exchange(d, 100, Wallet.GBP)
	assert_eq(r.cur, Wallet.EUR)
	assert_eq(d.euros, int(r.got))

func test_list_rates_and_localise() -> void:
	assert_eq(Wallet.localise(100, "gip"), 100, "par pounds, par prices")
	assert_eq(Wallet.localise(100, "eur"), 115)
	assert_eq(Wallet.localise(100, "usd"), 130)
	assert_eq(Wallet.localise(100, "bmd"), 130)
	assert_eq(Wallet.localise(100, "xcd"), 351)
	assert_eq(Wallet.localise(100, "kyd"), 108)
	assert_eq(Wallet.localise(100, "nzd"), 220)
	assert_eq(Wallet.localise(1, "kyd"), 1)
	assert_eq(Wallet.in_sterling(130, "usd"), 100)
	assert_eq(Wallet.in_sterling(100, "jep"), 100)

func test_zone_currency_uses_the_region() -> void:
	assert_eq(Wallet.currency_for_zone("dublin"), Wallet.EUR, "the old mapping stands")
	assert_eq(Wallet.currency_for_zone("manchester"), Wallet.GBP)

func test_wrong_money_at_the_tourist_rate() -> void:
	var d := _data("bermuda")
	var rate := Forex.per_gbp("usd", d.rng_seed, d.day_count)
	Wallet.earn(d, 5, "usd")
	assert_eq(Wallet.other("usd"), "gbp")
	var cost := Wallet.foreign_cost(100, "usd", rate)
	assert_true(cost > ceili(100 / rate), "dearer than the middle rate: %s" % cost)
	assert_true(Wallet.spendable(d, "usd", rate) > 5)
	var res := Wallet.pay(d, 100, "usd", rate)
	assert_true(res.ok)
	assert_eq(res.foreign_cur, "gbp")
	assert_eq(Wallet.balance(d, "usd"), 0)
	assert_eq(d.money, 1000 - int(res.foreign))

func test_the_mainland_wont_take_jersey_notes_and_vice_versa() -> void:
	var d := _data()
	Wallet.earn(d, 500, "jep")
	assert_eq(Wallet.spendable(d, "gbp", 1.175), 1000, "the shop in England won't take Jersey pounds")
	assert_eq(Wallet.spendable(d, "jep", 1.175), 1500, "but Jersey takes sterling at par")
	assert_eq(Wallet.foreign_cost(100, "jep", 1.175), 100, "no tourist penalty")
	var res := Wallet.pay(d, 600, "jep", 1.175)
	assert_true(res.ok)
	assert_eq(Wallet.balance(d, "jep"), 0, "local pounds first")
	assert_eq(d.money, 900, "the rest in sterling, one for one")
	assert_false(Wallet.pay(d, 5000, "jep", 1.175).ok)
	assert_eq(d.money, 900, "nothing taken from a failed payment")

func test_purse_text_lists_local_and_sterling() -> void:
	var d := _data()
	assert_eq(Wallet.purse_text(d, "gbp"), "£1,000", "unchanged on the mainland")
	Wallet.earn(d, 40, "usd")
	assert_eq(Wallet.purse_text(d, "usd"), "US$40   £1,000")
	Wallet.earn(d, 5, "jep")
	assert_eq(Wallet.purse_text(d, "jep"), "£5 Jersey   £1,000")

func test_foreign_purse_lines_for_the_pause_menu() -> void:
	var d := _data()
	assert_eq(Wallet.foreign_lines(d), [], "nothing foreign, no lines")
	Wallet.earn(d, 40, "usd")
	Wallet.earn(d, 5, "jep")
	var lines := Wallet.foreign_lines(d)
	assert_eq(lines.size(), 2)
	assert_eq(lines[0], ["US dollars", "US$40"])
	assert_eq(lines[1], ["Jersey pounds", "£5"])

func test_bureau_command_can_name_a_currency() -> void:
	var h := FakeStoryHost.new()
	var cmd := Commands.new(h)
	cmd.run([{"do": "bureau", "currency": "usd"}])
	var menus := h.log.filter(func(e): return e[0] == "menu").map(func(e): return e[1])
	assert_eq(menus, ["bureau:usd"])
