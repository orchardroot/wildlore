extends TestCase
## The Economist's notebook (4.5): ideas met through play, history from plaques, worked examples from the game's real
## numbers, and the hooks in the Trade Ledger, the Deeds, the leases, the Building Society and the casino.

func _d() -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 10
	return d

func test_a_fresh_save_has_an_empty_notebook() -> void:
	var d := _d()
	assert_eq(Economist.count(d), 0)
	assert_true(Economist.total() >= 13, "eight ideas and the history plaques")
	assert_false(Almanac.pages(d).any(func(p): return p.id == "economist"))

func test_noting_an_idea_once_sprouts_the_almanac_page() -> void:
	var d := _d()
	Economist.take_fresh()
	assert_true(Economist.note(d, "inflation"))
	assert_false(Economist.note(d, "inflation"), "only new the first time")
	assert_true(Economist.met(d, "inflation"))
	assert_eq(Economist.count(d), 1)
	assert_true(Economist.take_fresh().contains("Inflation"))
	assert_eq(Economist.take_fresh(), "", "the toast is taken once")
	var page: Array = Almanac.pages(d).filter(func(p): return p.id == "economist")
	assert_eq(page.size(), 1)
	assert_true(str(page[0].blurb).contains("1 of"), str(page[0].blurb))

func test_history_is_met_by_reading_its_plaque() -> void:
	var d := _d()
	assert_false(Economist.met(d, "boe_1694"))
	d.set_flag(Gazetteer.flag_key("econ_bank_of_england"), true)
	assert_true(Economist.met(d, "boe_1694"))

func test_unknown_ideas_are_ignored() -> void:
	var d := _d()
	assert_false(Economist.note(d, "not_an_idea"))
	assert_eq(Economist.count(d), 0)

func test_a_glut_teaches_supply_and_demand() -> void:
	var d := _d()
	Trade.record_sale(d, "lancashire_hotpot", "leeds", 1)
	assert_false(Economist.met(d, "supply_demand"), "one sale is no glut")
	Trade.record_sale(d, "lancashire_hotpot", "leeds", 4)
	assert_true(Economist.met(d, "supply_demand"))
	var text := "\n".join(Economist.lines(d, "supply_demand"))
	assert_true(text.contains("Lancashire Hotpot") or text.contains("hotpot"), text)

func test_selling_where_a_thing_is_wanted_teaches_comparative_advantage() -> void:
	var d := _d()
	Trade.record_sale(d, "jute_fibre", "bath", 1)
	assert_true(Economist.met(d, "comparative"))

func test_a_deed_teaches_opportunity_cost_with_the_real_price() -> void:
	var d := _d()
	d.money = 10000000
	d.set_flag("badge_stone", true)
	var id := ""
	for dd in Deeds.all():
		if str(dd.get("unlock_flag", "")) == "" or str(dd.get("unlock_flag", "")) == "badge_stone":
			id = str(dd.id)
			break
	assert_eq(Deeds.buy(d, id), "")
	assert_true(Economist.met(d, "opportunity_cost"))
	var text := "\n".join(Economist.lines(d, "opportunity_cost"))
	assert_true(text.contains("a year"), text)

func test_the_society_teaches_interest_and_apr() -> void:
	var d := _d()
	d.money = 5000
	assert_true(BuildingSociety.deposit(d, "gbp", 100))
	assert_true(Economist.met(d, "compound"))
	var text := "\n".join(Economist.lines(d, "compound"))
	assert_true(text.contains("£1,127"), "1% a month compounded for a year on £1,000: " + text)
	var apr := "\n".join(Economist.lines(d, "apr"))
	assert_true(apr.contains("12.7% APR"), apr)

func test_winning_a_lease_teaches_the_winners_curse() -> void:
	var d := _d()
	var a := {"id": str(Leases.all()[0].id), "cur": "gbp", "reserve": 1000, "step": 100, "bid": 0, "by": "", "over": false,
		"won": false, "price": 0, "round": 1, "rivals": [], "notes": []}
	d.money = 100000
	assert_eq(Leases.bid(a, d, 2), "")  # no rivals in the room: two steps over the reserve and the hammer falls
	assert_true(bool(a.won))
	assert_true(Economist.met(d, "winners_curse"))
	assert_true("\n".join(Economist.lines(d, "winners_curse")).contains("20% over the reserve"))

func test_casino_odds_are_the_real_ones() -> void:
	var text := "\n".join(Economist.examples(_d(), "house_edge"))
	assert_true(text.contains("97.3p"), text)  # 36/37, single zero
	assert_true(text.contains("88.5p"), text)  # 0.96 cubed
	assert_near(Economist.FRUIT_RTP, FruitMachine.exact_rtp_with_nudges(), 0.001)
	for g in ["roulette_screen", "blackjack_screen", "hilo_screen", "fruit_screen", "race_screen"]:
		assert_true(Economist.odds_line(g).begins_with("Real odds"), g)
	assert_eq(Economist.odds_line("cage_screen"), "")

## The measured blackjack figure stays honest: basic strategy over many hands lands near it.
func test_blackjack_figure_matches_a_long_night() -> void:
	var rng := Rng.new(7)
	var staked := 0
	var back := 0
	for i in 20000:
		var g := Blackjack.new(rng, 10)
		while not g.done:
			match Blackjack.basic_strategy(g):
				"double":
					g.double_down()
				"hit":
					g.hit()
				_:
					g.stand()
		staked += g.stake
		back += g.returns()
	assert_near(float(back) / staked, Economist.BLACKJACK_RTP, 0.012)

func test_inflation_sums() -> void:
	var text := "\n".join(Economist.examples(_d(), "inflation"))
	assert_true(text.contains("£6.09"), text)   # £5 at 2% for ten years
	assert_true(text.contains("35 years"), text)

func test_notebook_lines_never_use_em_dashes_and_the_data_checks_out() -> void:
	var d := _d()
	for i in Economist.ideas():
		Economist.note(d, str(i.id), "x")
		for line in Economist.lines(d, str(i.id)):
			assert_false(str(line).contains("—"), str(line))
	assert_eq(Economist.check(Gazetteer.all()), [])
