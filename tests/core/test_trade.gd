extends TestCase
## The Trade Ledger (Trade): place-set prices, seasonal and festival demand, gluts that recover, perishables, the
## pannier's carry cap and the Money Box, plus MarketSim-style checks that no loop of buying and selling prints money.

func _d(day := 0) -> GameStateData:
	var d := GameStateData.new()
	d.day_count = day
	return d

func test_unlisted_items_have_a_price_at_the_old_rates() -> void:
	var d := _d()
	var base := int(Trade.items().get_item("cup_of_tea").get("price", 0))
	assert_true(base > 0)
	assert_eq(Trade.buy_price(d, "cup_of_tea", "cardiff"), base)
	assert_eq(Trade.sell_price(d, "cup_of_tea", "cardiff"), base / 2)
	assert_eq(Trade.buy_price(d, "not_an_item", "cardiff"), 0)

func test_regions_group_zones_and_rooms() -> void:
	assert_eq(Trade.group_of("cardiff"), "wales")
	assert_eq(Trade.group_of("cardiff_castle"), "wales")
	assert_eq(Trade.group_of("glasgow"), "scotland")
	assert_eq(Trade.group_of("dublin"), "ireland")
	assert_eq(Trade.group_of("manchester"), "north_west")

func test_staples_cheap_where_made_dear_far_away() -> void:
	Calendar.set_override("2026-06-10")
	var d := _d()
	var base := int(Trade.items().get_item("arbroath_smokie").get("price", 0))
	assert_true(Trade.buy_price(d, "arbroath_smokie", "glasgow") < base)
	assert_true(Trade.buy_price(d, "arbroath_smokie", "cardiff") > base)
	assert_true(Trade.sell_price(d, "arbroath_smokie", "cardiff") > Trade.sell_price(d, "arbroath_smokie", "glasgow"))
	assert_eq(Trade.price_note(d, "arbroath_smokie", "glasgow"), "cheap here")
	assert_eq(Trade.price_note(d, "arbroath_smokie", "cardiff"), "they're crying out for it")
	Calendar.set_override("")

func test_home_region_is_never_dearer_than_today() -> void:
	Calendar.set_override("2026-06-10")
	var d := _d()
	for id in Trade.config().goods:
		var base := Trade.base_price(str(id))
		assert_true(Trade.buy_price(d, str(id), "chester") <= base, "%s in Cheshire" % id)
	Calendar.set_override("")

func test_you_cannot_profit_buying_and_selling_in_one_place() -> void:
	var d := _d()
	for date in ["2026-01-25", "2026-03-01", "2026-03-17", "2026-06-10", "2026-10-30", "2026-12-25"]:
		Calendar.set_override(date)
		for id in Trade.config().goods:
			for z in ["glasgow", "cardiff", "dublin", "york", "bath", "manchester", "douglas", "shrewsbury", "edinburgh"]:
				assert_true(Trade.sell_price(d, str(id), z) < Trade.buy_price(d, str(id), z), "%s in %s on %s" % [id, z, date])

func test_season_and_festival_lift_demand() -> void:
	var d := _d()
	Calendar.set_override("2026-06-10")
	var summer := Trade.sell_price(d, "scotch_broth", "glasgow")
	Calendar.set_override("2026-12-10")
	assert_true(Trade.sell_price(d, "scotch_broth", "glasgow") > summer, "soup is wanted in winter")
	Calendar.set_override("2026-06-10")
	var plain := Trade.sell_price(d, "haggis_neeps_tatties", "edinburgh")
	Calendar.set_override("2026-01-25")
	assert_true(Trade.sell_price(d, "haggis_neeps_tatties", "edinburgh") > plain, "Burns Night")
	assert_eq(Trade.price_note(d, "haggis_neeps_tatties", "dublin"), "they're crying out for it")
	Calendar.set_override("")

func test_glut_falls_per_unit_and_recovers_over_days() -> void:
	Calendar.set_override("2026-06-10")
	var d := _d(10)
	var fresh := Trade.sell_price(d, "welsh_cakes", "bath")
	Trade.record_sale(d, "welsh_cakes", "bath", 6)
	var after := Trade.sell_price(d, "welsh_cakes", "bath")
	assert_true(after < fresh, "the sixth sale hurts")
	assert_eq(Trade.price_note(d, "welsh_cakes", "bath"), "glut")
	assert_eq(Trade.sell_price(d, "welsh_cakes", "oxford"), Trade.sell_price(_d(10), "welsh_cakes", "oxford"), "other towns are untouched")
	d.day_count = 11
	assert_true(Trade.sell_price(d, "welsh_cakes", "bath") > after, "recovering")
	d.day_count = 13
	assert_eq(Trade.sell_price(d, "welsh_cakes", "bath"), fresh, "back to normal after three days")
	Calendar.set_override("")

func test_sell_total_declines_unit_by_unit() -> void:
	Calendar.set_override("2026-06-10")
	var d := _d()
	var one := Trade.sell_price(d, "welsh_cakes", "bath")
	var five := Trade.sell_total(d, "welsh_cakes", "bath", 5)
	assert_true(five < one * 5 and five > one * 3, "five sold for %d against %d each" % [five, one])
	assert_eq(Trade.sell_total(d, "welsh_cakes", "bath", 0), 0)
	Calendar.set_override("")

func test_perishables_go_off() -> void:
	Calendar.set_override("2026-06-10")
	var d := _d(5)
	d.bag["cullen_skink"] = 3
	Trade.stamp(d, "cullen_skink", 0, 3)
	var fresh := Trade.sell_price(d, "cullen_skink", "york")
	d.day_count = 9
	var mid := Trade.sell_price(d, "cullen_skink", "york")
	d.day_count = 30
	var old := Trade.sell_price(d, "cullen_skink", "york")
	assert_true(fresh >= mid and mid > old, "%d %d %d" % [fresh, mid, old])
	assert_true(old <= fresh / 3, "a quarter at best")
	assert_eq(Trade.price_note(d, "cullen_skink", "york"), "a bit off")
	Calendar.set_override("")

func test_old_saves_have_everything_fresh() -> void:
	var d := _d(400)
	assert_eq(Trade.freshness(d, "cullen_skink"), 1.0)
	var r := GameStateData.from_dict(d.to_dict(), null)
	assert_eq(Trade.freshness(r, "cullen_skink"), 1.0)

func test_restocking_blends_the_stamp() -> void:
	var d := _d(0)
	d.bag["cullen_skink"] = 4
	Trade.stamp(d, "cullen_skink", 0, 4)
	d.day_count = 8
	d.bag["cullen_skink"] = 8
	Trade.stamp(d, "cullen_skink", 4, 4)
	assert_eq(int(d.flag(Trade.FRESH_FLAG)["cullen_skink"]), 4, "half old, half new")

func test_pannier_lifts_the_trade_cap_only() -> void:
	var d := _d()
	assert_eq(Trade.carry_cap(d, "welsh_cakes"), 30)
	assert_eq(Trade.carry_cap(d, "cup_of_tea"), Bag.MAX_STACK)
	d.bag["welsh_cakes"] = 28
	assert_eq(Trade.room(d, "welsh_cakes"), 2)
	d.bag["traders_pannier"] = 1
	assert_eq(Trade.carry_cap(d, "welsh_cakes"), 99)
	assert_true(Trade.items().has("traders_pannier"))
	assert_eq(Trade.items().get_item("traders_pannier").kind, "key")

func test_money_box_speaks_and_mondays_report() -> void:
	Calendar.set_override("2026-06-10")
	var tue := Trade.money_box(_d(1), "cardiff")
	var mon := Trade.money_box(_d(7), "cardiff")
	assert_true(tue.size() >= 2 and mon.size() > tue.size(), "Monday adds the report")
	for l in mon:
		assert_false("—" in str(l), "no em-dashes")
	assert_eq(Trade.money_box(_d(7), "cardiff"), mon, "the same day reads the same")
	Calendar.set_override("")

## A trader who buys where it's cheap, pays the fares and sells where it's wanted, 90 in-game days over.
func _run_route(cheap: String, dear: String, id: String, qty: int, fare: int) -> int:
	var d := _d(0)
	var gain := 0
	for trip in 30:
		d.day_count = trip * 3
		var cost := 0
		for i in qty:
			cost += Trade.buy_price(d, id, cheap)
		var got := Trade.sell_total(d, id, dear, qty)
		Trade.record_sale(d, id, dear, qty)
		gain += got - cost - fare * 2
	return gain

func test_no_loop_prints_money() -> void:
	Calendar.set_override("2026-06-10")
	var best := 0
	for id in Trade.config().goods:
		var g: Dictionary = Trade.config().goods[id]
		for h in g.home:
			for w in g.wants:
				var cheap := _town_of(str(h))
				var dear := _town_of(str(w))
				for qty in [1, 5, 10, 30]:
					best = maxi(best, _run_route(cheap, dear, str(id), qty, 40))
	assert_true(best > 0, "a good route exists, or why would anyone trade")
	assert_true(best < 120000, "and it is work, not a tap: best 90-day route %d" % best)
	# a full pannier into one town is a bad idea
	assert_true(_run_route("glasgow", "cardiff", "arbroath_smokie", 30, 40) < 0)
	Calendar.set_override("")

func _town_of(group: String) -> String:
	return {"north_west": "manchester", "north_east": "york", "midlands": "shrewsbury", "east": "cambridge", "south": "bath",
		"wales": "cardiff", "scotland": "glasgow", "ireland": "dublin", "isles": "douglas"}[group]
