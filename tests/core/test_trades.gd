extends TestCase
## Trades: levels read off the Stats counters, small perks, and money that can't be printed by cooking or selling.

func test_fresh_save_is_level_one_everywhere() -> void:
	var d := GameStateData.new()
	for t in Trades.IDS:
		assert_eq(Trades.level(d, t), 1, t)
	assert_false(Trades.has_perk(d, "rambler_repel"))

func test_levels_follow_the_counters() -> void:
	var d := GameStateData.new()
	d.stats = {"steps": 10000, "goods_sold": 500, "dishes_cooked": 75, "fish_caught": 5}
	assert_eq(Trades.level(d, "rambler"), 3)
	assert_eq(Trades.level(d, "trader"), 2)
	assert_eq(Trades.level(d, "cook"), 4)
	assert_eq(Trades.level(d, "angler"), 2)
	d.stats.steps = 1000000
	assert_eq(Trades.level(d, "rambler"), 5, "capped at 5")

func test_unknown_trade_is_level_one() -> void:
	assert_eq(Trades.level(GameStateData.new(), "juggler"), 1)

func test_titles_and_progress() -> void:
	var d := GameStateData.new()
	assert_eq(Trades.title(d, "rambler"), "Dawdler")
	assert_true(Trades.to_next(d, "rambler") > 0)
	d.stats = {"steps": 80000}
	assert_eq(Trades.to_next(d, "rambler"), 0)

func test_local_reads_standing() -> void:
	var d := GameStateData.new()
	d.set_flag("standing_wales", 60)
	assert_eq(Trades.level(d, "local"), 4)

func test_perks_unlock_by_level() -> void:
	var d := GameStateData.new()
	d.stats = {"steps": 2000}
	assert_true(Trades.has_perk(d, "rambler_repel"))
	assert_false(Trades.has_perk(d, "rambler_repel_more"))
	assert_eq(Trades.repel_steps(d, 100), 125)
	d.stats = {"steps": 30000}
	assert_eq(Trades.repel_steps(d, 100), 150)

func test_sell_bonus_never_beats_buying() -> void:
	var d := GameStateData.new()
	d.stats = {"goods_sold": 1000000}
	assert_true(Trades.sell_mult(d) <= 1.1, "a modest top-up")
	assert_true(0.5 * Trades.sell_mult(d) < 1.0, "selling still pays less than buying")

func test_second_portion_is_every_nth_dish_and_not_free_money() -> void:
	var d := GameStateData.new()
	assert_eq(Trades.extra_portions(d), 0)
	d.stats = {"dishes_cooked": 25}   # Cook 3
	var bonus := 0
	for i in 100:
		d.stats.dishes_cooked = int(d.stats.dishes_cooked) + 1
		bonus += Trades.extra_portions(d)
	assert_true(bonus >= 10 and bonus <= 25, "about one dish in five or so, got %d" % bonus)

func test_cooking_counts_and_gives_a_second_portion() -> void:
	var items := ItemDB.load_default()
	var rid := ""
	var recipe := {}
	for r in Crafting.all():
		if str(items.get_item(str(r.out)).get("kind", "")) == "meal":
			recipe = r
			rid = str(r.id)
			break
	assert_true(rid != "", "a dish recipe exists")
	var d := GameStateData.new()
	d.stats = {"dishes_cooked": 25}
	d.money = 1000000
	d.set_flag(Crafting.flag_for(rid))
	for k in recipe.get("in", {}):
		d.bag[k] = int(recipe["in"][k]) * 200
	var made := 0
	for i in 20:
		if Crafting.craft(d, recipe, items).ok:
			made += 1
	assert_eq(int(d.stats.dishes_cooked), 25 + made, "each batch is counted")
	assert_true(Bag.new(d.bag).count(str(recipe.out)) > made * int(recipe.get("n", 1)), "some batches gave a second portion")

func test_naturalist_sky_perk_boosts_rarer_weather_only() -> void:
	var l := [{"species": "a", "weight": 10}]
	var t := func(_s): return ["frost"]
	var plain: float = WeatherWild.shift(l, "frost", t)[0].weight
	var boosted: float = WeatherWild.shift(l, "frost", t, 0.3)[0].weight
	assert_true(boosted > plain)
	assert_true(boosted <= plain * 1.5, "a touch")
