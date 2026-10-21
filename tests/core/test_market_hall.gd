extends TestCase
## The Market Halls: the board lists only trade goods, payouts follow the Ledger, and a buy-and-sell loop can't
## print money (a stall-holder never pays more than the shop charges, wherever you stand).

func _items() -> ItemDB:
	return ItemDB.load_default()

func test_there_are_25_halls() -> void:
	assert_eq(MarketHall.halls().size(), 25)

func test_board_lists_only_trade_goods() -> void:
	var db := _items()
	var mats := []
	for id in db.ids():
		if MarketHall.is_trade_good(db.get_item(id)):
			mats.append(id)
	assert_true(mats.size() > 10, "there are goods to trade")
	var store := {mats[0]: 3, "map_of_the_isles": 1, "no_such_item": 2}
	for id in db.ids():
		if str(db.get_item(id).get("kind", "")) == "key":
			store[id] = 1
			break
	var d := GameStateData.new()
	var b := MarketHall.board(d, store, func(i): return db.get_item(i), "swansea_market")
	assert_eq(b.size(), 1)
	assert_eq(b[0].id, mats[0])
	assert_eq(b[0].n, 3)

func test_payout_is_ledger_price_times_quantity() -> void:
	var db := _items()
	var d := GameStateData.new()
	for id in db.ids():
		if MarketHall.is_trade_good(db.get_item(id)):
			assert_eq(MarketHall.payout(d, "swansea_market", id, 4), 4 * Trade.sell_price(d, id, "swansea"))
			assert_eq(MarketHall.payout(d, "swansea_market", id, 0), 0)
			return
	assert_true(false, "no trade good found")

func test_no_loop_prints_money() -> void:
	var db := _items()
	var d := GameStateData.new()
	var towns := {}
	for id in MarketHall.halls():
		towns[str(MarketHall.hall(id).town)] = true
	for id in db.ids():
		if not MarketHall.is_trade_good(db.get_item(id)):
			continue
		for t in towns:
			var sell := Trade.sell_price(d, id, t)
			var buy := Trade.buy_price(d, id, t)
			assert_true(sell <= buy, "%s sells for %d but costs %d in %s" % [id, sell, buy, t])
			assert_true(sell >= 0)

func test_halls_are_well_formed() -> void:
	assert_eq(MarketHall.check_files(), [])
