extends TestCase
## Euros in the Republic wherever money changes hands: prize money, jobs, the tourist board, the pub kitty, the
## kitchen, a whiteout; and the story commands that open the bureau, the Exchange and the Doggerel kiosk.

func test_trainer_prize_in_ireland_is_paid_in_euros() -> void:
	var data := GameStateData.new()
	data.zone_id = "galway"
	data.party = [Fixtures.creature("kindlet", 20)]
	var ui := FakeBattleUI.new()
	var f := BattleFlow.new(data, Fixtures.dex(), Fixtures.moves(), Fixtures.chart(), ItemDB.load_default(), Rng.new(7),
		[Fixtures.creature("spikkin", 3)], {"kind": "trainer", "trainer": {"name": "Nuala", "money": 200}, "ai": "trainer"}, ui)
	var pounds := data.money
	f.run()
	assert_eq(f.result.result, "win")
	assert_eq(data.money, pounds, "no sterling")
	assert_eq(data.euros, 230, "200 at the list rate")
	assert_eq(f.result.cur, "eur")
	assert_true(ui.said.any(func(l): return str(l).contains("€230")), "says euros")

func test_trainer_prize_in_belfast_stays_sterling() -> void:
	var data := GameStateData.new()
	data.zone_id = "belfast"
	data.party = [Fixtures.creature("kindlet", 20)]
	var f := BattleFlow.new(data, Fixtures.dex(), Fixtures.moves(), Fixtures.chart(), ItemDB.load_default(), Rng.new(7),
		[Fixtures.creature("spikkin", 3)], {"kind": "trainer", "trainer": {"name": "Ruairi", "money": 200}, "ai": "trainer"}, FakeBattleUI.new())
	var pounds := data.money
	f.run()
	assert_eq(data.money, pounds + 200)
	assert_eq(data.euros, 0)

func test_irish_job_pays_euros() -> void:
	var d := GameStateData.new()
	assert_eq(Jobs.accept(d, "ie_turf", "dublin"), "")
	var slot: int = Jobs.active(d)[0][0]
	var pounds := d.money
	var r := Jobs.complete(d, slot, ItemDB.load_default())
	assert_eq(r.cur, "eur")
	assert_eq(d.money, pounds)
	assert_eq(d.euros, int(r.money))
	assert_eq(int(r.money), Wallet.localise(Jobs.money_for(Jobs.get_job("ie_turf"), 0), "eur"))
	assert_true(Parish.reward_text(r, ItemDB.load_default()).contains("€"))

func test_irish_tourist_board_pays_euros() -> void:
	var d := GameStateData.new()
	var idx := ZoneIndex.get_index()
	var rooms: Array = idx.town_rooms.get("kilkenny", [])
	assert_true(rooms.size() > 0)
	var pay := {}
	for r in rooms:
		var got := VisitorsBook.note(d, str(r), "interior", idx)
		if not got.is_empty():
			pay = got
	assert_eq(pay.cur, "eur")
	assert_eq(d.euros, Wallet.localise(VisitorsBook.MONEY, "eur"))
	assert_true(VisitorsBook.payout_lines("Kilkenny", "Cream Tea", int(pay.money), "eur")[1].contains("€"))

func test_irish_pub_kitty_in_euros() -> void:
	var d := GameStateData.new()
	var r := PubQuiz.award(d, ItemDB.load_default(), "dublin_templebar", 3)
	assert_eq(r.cur, "eur")
	assert_eq(d.euros, Wallet.localise(300, "eur"))

func test_kitchen_shopping_in_euros() -> void:
	var d := GameStateData.new()
	d.zone_id = "dublin"
	var r := {"id": "x", "out": "cup_of_tea", "in": {}, "money": 100}
	assert_eq(Crafting.cost(d, r), 115)
	d.money = 5000
	assert_eq(Crafting.blocker(d, r), "money", "sterling won't do at the market stall")
	d.euros = 115
	assert_eq(Crafting.blocker(d, r), "")

func test_whiteout_halves_both_purses() -> void:
	var h := FakeStoryHost.new()
	h.data.money = 100
	h.data.euros = 60
	var cmd := Commands.new(h)
	cmd.run([{"do": "whiteout"}])
	assert_eq(h.data.money, 50)
	assert_eq(h.data.euros, 30)

func test_market_commands_open_their_screens() -> void:
	var h := FakeStoryHost.new()
	var cmd := Commands.new(h)
	cmd.run([{"do": "bureau"}, {"do": "exchange", "board": "dublin"}, {"do": "crypto"}])
	var menus := h.log.filter(func(e): return e[0] == "menu").map(func(e): return e[1])
	assert_eq(menus, ["bureau", "exchange:dublin", "crypto"])

func test_validator_knows_the_market_commands() -> void:
	assert_has(StoryValidator.COMMANDS, "bureau")
	assert_has(StoryValidator.COMMANDS, "exchange")
	assert_has(StoryValidator.COMMANDS, "crypto")
