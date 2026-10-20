extends TestCase
## Two purses: sterling and euros, the currency by zone, paying with the wrong money at the tourist rate, saves.

func _data(zone := "macclesfield") -> GameStateData:
	var d := GameStateData.new()
	d.zone_id = zone
	d.rng_seed = 42
	d.money = 1000
	return d

func test_currency_by_zone() -> void:
	assert_eq(Wallet.currency_for_zone("dublin"), Wallet.EUR, "the Republic")
	assert_eq(Wallet.currency_for_zone("dublin_sanctuary"), Wallet.EUR, "a room takes its town's money")
	assert_eq(Wallet.currency_for_zone("galway"), Wallet.EUR)
	assert_eq(Wallet.currency_for_zone("cork"), Wallet.EUR)
	assert_eq(Wallet.currency_for_zone("belfast"), Wallet.GBP, "Northern Ireland is sterling")
	assert_eq(Wallet.currency_for_zone("derry_sanctuary"), Wallet.GBP)
	assert_eq(Wallet.currency_for_zone("douglas"), Wallet.GBP, "the Isle of Man")
	assert_eq(Wallet.currency_for_zone("holyhead_terminal"), Wallet.GBP)
	assert_eq(Wallet.currency_for_zone("manchester"), Wallet.GBP)
	assert_eq(Wallet.currency_for_zone("testbed"), Wallet.GBP)

func test_every_irish_sanctuary_deals_in_euros() -> void:
	for z in ["cork", "dingle", "dublin", "galway", "kilkenny", "newgrange", "sligo"]:
		assert_eq(Wallet.currency_for_zone(z + "_sanctuary"), Wallet.EUR, z)

func test_formatting() -> void:
	assert_eq(Wallet.fmt(1234567, Wallet.GBP), "£1,234,567")
	assert_eq(Wallet.fmt(999, Wallet.EUR), "€999")
	assert_eq(Wallet.fmt(-1500, Wallet.EUR), "-€1,500")
	assert_eq(Wallet.fmt_price(4.2, Wallet.GBP), "£4.20")
	assert_eq(Wallet.fmt_price(1234.567, Wallet.EUR), "€1,234.57")
	assert_eq(UIKit.money_text(2500), "£2,500", "the old helper still says pounds")
	assert_eq(UIKit.money_text(2500, Wallet.EUR), "€2,500")

func test_earn_and_spend_keep_purses_apart() -> void:
	var d := _data()
	assert_eq(Wallet.earn(d, 300, Wallet.EUR), 300)
	assert_eq(d.euros, 300)
	assert_eq(d.money, 1000, "sterling untouched")
	assert_true(Wallet.had_euros(d))
	assert_false(Wallet.spend(d, 301, Wallet.EUR), "can't overspend")
	assert_eq(d.euros, 300)
	assert_true(Wallet.spend(d, 300, Wallet.EUR))
	assert_eq(d.euros, 0)
	assert_true(Wallet.had_euros(d), "remembered once you've had euros")
	assert_eq(Wallet.earn(d, -5, Wallet.GBP), 0, "a negative earn is ignored")
	assert_false(Wallet.spend(d, -5, Wallet.GBP))
	assert_eq(d.money, 1000)

func test_localise_authored_sterling() -> void:
	assert_eq(Wallet.localise(100, Wallet.GBP), 100)
	assert_eq(Wallet.localise(100, Wallet.EUR), 115)
	assert_eq(Wallet.localise(1, Wallet.EUR), 1)
	assert_eq(Wallet.localise(0, Wallet.EUR), 0)
	var d := _data("galway")
	var r := Wallet.earn_here(d, 200, "galway")
	assert_eq(r.cur, Wallet.EUR)
	assert_eq(d.euros, 230)
	assert_eq(d.money, 1000)

func test_tourist_rate_pays_the_rest_in_the_other_money() -> void:
	var d := _data("dublin")
	d.euros = 10
	var m := 1.2
	var r := Wallet.pay(d, 50, Wallet.EUR, m)
	assert_true(r.ok)
	assert_eq(r.local, 10, "own euros first")
	assert_eq(d.euros, 0)
	# 40 euros at the tourist rate (1.2 * 0.88 = 1.056 euros a pound) is 38 pounds, rounded up
	assert_eq(r.foreign, 38)
	assert_eq(d.money, 1000 - 38)
	assert_true(r.foreign > floori(40 / m), "worse than the middle rate")

func test_tourist_rate_the_other_way() -> void:
	var d := _data("manchester")
	d.money = 0
	d.euros = 500
	var r := Wallet.pay(d, 100, Wallet.GBP, 1.2)
	assert_true(r.ok)
	assert_eq(r.foreign, 135, "100 pounds at 1.344 euros a pound, rounded up")
	assert_eq(d.euros, 365)

func test_pay_takes_nothing_when_it_cannot_cover_it() -> void:
	var d := _data("dublin")
	d.money = 10
	d.euros = 5
	var r := Wallet.pay(d, 100, Wallet.EUR, 1.2)
	assert_false(r.ok)
	assert_eq(d.money, 10)
	assert_eq(d.euros, 5)

func test_spendable_matches_what_pay_allows() -> void:
	for m in [1.08, 1.17, 1.26]:
		var d := _data("dublin")
		d.money = 333
		d.euros = 7
		var most := Wallet.spendable(d, Wallet.EUR, m)
		assert_true(most > 7)
		var probe := _data("dublin")
		probe.money = 333
		probe.euros = 7
		assert_true(Wallet.pay(probe, most, Wallet.EUR, m).ok, "the most is payable at %s" % m)
		var probe2 := _data("dublin")
		probe2.money = 333
		probe2.euros = 7
		assert_false(Wallet.pay(probe2, most + 1, Wallet.EUR, m).ok, "one more is not at %s" % m)

func test_halve_all_on_a_whiteout() -> void:
	var d := _data()
	d.money = 101
	d.euros = 51
	Wallet.halve_all(d)
	assert_eq(d.money, 50)
	assert_eq(d.euros, 25)

func test_euros_save_and_load() -> void:
	var d := _data("dublin")
	d.euros = 777
	var back := GameStateData.from_dict(d.to_dict(), Fixtures.dex())
	assert_eq(back.euros, 777)
	assert_eq(back.money, 1000, "no welcome conversion for a save that already knows euros")

func test_old_save_defaults_to_no_euros() -> void:
	var back := GameStateData.from_dict({"player_name": "Sam", "money": 900, "zone_id": "york"}, Fixtures.dex())
	assert_eq(back.euros, 0)
	assert_eq(back.money, 900)
	assert_eq(back.markets.h.size(), 0)

func test_old_save_made_in_ireland_gets_a_friendly_conversion() -> void:
	var back := GameStateData.from_dict({"player_name": "Sam", "money": 1000, "zone_id": "galway", "rng_seed": 9}, Fixtures.dex())
	assert_eq(back.money, 500, "half the sterling")
	var m := Forex.mid(9, 0)
	assert_eq(back.euros, floori(500 * m), "at the middle rate, no commission")
	var line := Wallet.take_welcome_line(back)
	assert_true(line.contains("€"), line)
	assert_eq(Wallet.take_welcome_line(back), "", "said once")
	# and only once: saving and loading again changes nothing
	var again := GameStateData.from_dict(back.to_dict(), Fixtures.dex())
	assert_eq(again.money, 500)
	assert_eq(again.euros, back.euros)
