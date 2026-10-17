extends TestCase

func test_six_nations() -> void:
	assert_eq(Standing.NATIONS, ["england", "wales", "scotland", "northern_ireland", "ireland", "mann"])

func test_nation_for_zone_splits_ni_and_mann() -> void:
	assert_eq(Standing.nation_for_zone("macclesfield"), "england")
	assert_eq(Standing.nation_for_zone("llanberis"), "wales")
	assert_eq(Standing.nation_for_zone("edinburgh"), "scotland")
	assert_eq(Standing.nation_for_zone("belfast"), "northern_ireland")
	assert_eq(Standing.nation_for_zone("causeway"), "northern_ireland")
	assert_eq(Standing.nation_for_zone("mournes"), "northern_ireland")
	assert_eq(Standing.nation_for_zone("dublin"), "ireland")
	assert_eq(Standing.nation_for_zone("connemara"), "ireland")
	assert_eq(Standing.nation_for_zone("douglas"), "mann")
	assert_eq(Standing.nation_for_zone("ogwen"), "wales")
	# regions work too, and Calendar's four-nation answer is left alone
	assert_eq(Standing.nation_for_zone("south_wales"), "wales")
	assert_eq(Standing.nation_for_zone("man"), "mann")
	assert_eq(Calendar.nation_for_region("man"), "england")

func test_interiors_take_their_town_nation() -> void:
	assert_eq(Standing.nation_for_zone("belfast_shop"), "northern_ireland")
	assert_eq(Standing.nation_for_zone("aberdeen_shop"), "scotland")

func test_points_default_to_zero_and_add() -> void:
	var d := GameStateData.new()
	for n in Standing.NATIONS:
		assert_eq(Standing.points(d, n), 0)
		assert_eq(Standing.tier(d, n), Standing.STRANGER)
	Standing.add(d, "wales", 4)
	assert_eq(Standing.points(d, "wales"), 4)
	assert_eq(d.flag("standing_wales"), 4)
	Standing.add(d, "nowhere", 4)  # unknown nations are ignored
	assert_eq(d.flag("standing_nowhere"), null)

func test_tiers() -> void:
	assert_eq(Standing.tier_for(0), Standing.STRANGER)
	assert_eq(Standing.tier_for(9), Standing.STRANGER)
	assert_eq(Standing.tier_for(10), Standing.KNOWN_FACE)
	assert_eq(Standing.tier_for(30), Standing.REGULAR)
	assert_eq(Standing.tier_for(60), Standing.LOCAL)
	assert_eq(Standing.tier_for(100), Standing.PILLAR)
	assert_eq(Standing.tier_for(400), Standing.PILLAR)
	assert_eq(Standing.TIER_NAMES, ["Stranger", "Known Face", "Regular", "Local", "Pillar of the Community"])

func test_add_reports_a_new_tier_once() -> void:
	var d := GameStateData.new()
	assert_eq(Standing.add(d, "wales", 9), "")
	assert_eq(Standing.add(d, "wales", 1), "Wales now counts you as a Known Face")
	assert_eq(Standing.add(d, "wales", 5), "")
	assert_eq(Standing.add(d, "mann", 30), "The Isle of Man now counts you as a Regular")

func test_pillar_brings_a_trophy() -> void:
	var d := GameStateData.new()
	Standing.add(d, "scotland", 99)
	assert_eq(Bag.new(d.bag).count(Standing.TROPHY.scotland), 0)
	Standing.add(d, "scotland", 1)
	assert_eq(Bag.new(d.bag).count(Standing.TROPHY.scotland), 1)
	Standing.add(d, "scotland", 50)
	assert_eq(Bag.new(d.bag).count(Standing.TROPHY.scotland), 1)

func test_discounts() -> void:
	var d := GameStateData.new()
	assert_eq(Standing.price(d, "england", 1000), 1000)
	Standing.add(d, "england", 10)
	assert_eq(Standing.price(d, "england", 1000), 950)
	Standing.add(d, "england", 20)
	assert_eq(Standing.price(d, "england", 1000), 950)  # Regular brings stock, not a bigger discount
	Standing.add(d, "england", 30)
	assert_eq(Standing.price(d, "england", 1000), 900)
	Standing.add(d, "england", 40)
	assert_eq(Standing.price(d, "england", 1000), 850)
	assert_eq(Standing.price(d, "wales", 1000), 1000)
	assert_eq(Standing.price(d, "england", 100), 85)
	assert_eq(Standing.price(d, "england", 1), 1)  # never free

func test_extra_stock_at_regular() -> void:
	var d := GameStateData.new()
	assert_eq(Standing.extra_stock(d, "ireland"), [])
	Standing.add(d, "ireland", 30)
	var extra := Standing.extra_stock(d, "ireland")
	assert_true(extra.size() >= 1 and extra.size() <= 2)
	for n in Standing.NATIONS:
		for e in Standing.EXTRA_STOCK[n]:
			assert_true(int(e[1]) > 0, "extra stock has a price")

func test_pillar_greeting() -> void:
	var d := GameStateData.new()
	assert_eq(Standing.greeting_extra(d, "keswick"), "")
	Standing.add(d, "england", 100)
	assert_true(Standing.greeting_extra(d, "keswick") != "")
	assert_eq(Standing.greeting_extra(d, "cardiff"), "")

func test_old_save_loads_with_no_standing() -> void:
	var back := GameStateData.from_dict({"player_name": "Sam", "flags": {"visited_buxton": true}}, Fixtures.dex())
	assert_eq(Standing.points(back, "england"), 0)
	var d := GameStateData.new()
	Standing.add(d, "ireland", 12)
	back = GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(Standing.points(back, "ireland"), 12)
	assert_eq(Standing.tier(back, "ireland"), Standing.KNOWN_FACE)

func test_lines_for_stats() -> void:
	var d := GameStateData.new()
	Standing.add(d, "wales", 31)
	var rows := Standing.lines(d)
	assert_eq(rows.size(), 6)
	assert_eq(rows[1][0], "Wales")
	assert_eq(rows[1][1], "Regular")
	assert_eq(rows[1][2], 31)
