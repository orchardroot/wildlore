extends TestCase
## The house rules shared by the Palace and the bookies (core/punt.gd, core/purse.gd): money in and out through
## the Purse, chips at the cage, daily stake limits that grow with badges, a dealt-in-advance stream of luck that
## lives in the save (so reloading can't change a result), the stats lines and the big-win rewards.

func _data(badges := 0, money := 5000) -> GameStateData:
	var d := GameStateData.new()
	d.money = money
	d.rng_seed = 1234
	for i in badges:
		d.badges.append("b%d" % i)
	return d

# ---------------------------------------------------------------- the purse

func test_purse_takes_and_pays() -> void:
	var d := _data(0, 100)
	assert_false(Purse.take(d, 101), "can't take what isn't there")
	assert_eq(d.money, 100)
	assert_true(Purse.take(d, 40))
	assert_eq(Purse.balance(d), 60)
	Purse.pay(d, 15)
	assert_eq(d.money, 75)
	assert_false(Purse.take(d, -5), "no negative stakes")
	assert_eq(Purse.text(1250), "£1,250")

# ---------------------------------------------------------------- chips

func test_buying_and_cashing_chips() -> void:
	var d := _data(0, 500)
	assert_true(Punt.buy_chips(d, 200))
	assert_eq(d.money, 300)
	assert_eq(Punt.chips(d), 200)
	assert_false(Punt.buy_chips(d, 1000), "only with money you've got")
	assert_eq(Punt.cash_chips(d), 200)
	assert_eq(d.money, 500)
	assert_eq(Punt.chips(d), 0)

# ---------------------------------------------------------------- limits

func test_daily_limit_grows_with_badges() -> void:
	var a := Punt.limit(_data(0))
	var b := Punt.limit(_data(3))
	var c := Punt.limit(_data(10))
	assert_true(a > 0)
	assert_true(b > a and c > b, "%d < %d < %d" % [a, b, c])

func test_stakes_count_against_todays_limit() -> void:
	var d := _data(0, 100000)
	var lim := Punt.limit(d)
	assert_true(Punt.stake(d, lim - 10, false))
	assert_eq(Punt.left_today(d), 10)
	assert_false(Punt.stake(d, 20, false), "over the limit")
	assert_eq(d.money, 100000 - (lim - 10), "a refused bet takes nothing")
	assert_true(Punt.stake(d, 10, false))
	assert_eq(Punt.left_today(d), 0)

func test_the_limit_resets_on_a_new_real_day() -> void:
	var d := _data(0, 100000)
	Punt.stake(d, 50, false)
	d.set_flag(Punt.DAY_FLAG, "1999-01-01")  # yesterday, as far as the game knows
	assert_eq(Punt.left_today(d), Punt.limit(d))

func test_chip_stakes_need_chips() -> void:
	var d := _data(0, 1000)
	assert_false(Punt.stake(d, 10, true), "no chips yet")
	Punt.buy_chips(d, 50)
	assert_true(Punt.stake(d, 30, true))
	assert_eq(Punt.chips(d), 20)
	assert_eq(d.money, 950, "chip bets never touch the purse")

# ---------------------------------------------------------------- settling, stats and rewards

func test_settling_pays_and_keeps_the_tallies() -> void:
	var d := _data(0, 1000)
	Punt.stake(d, 10, false)
	Punt.settle(d, 10, 0, false)
	Punt.stake(d, 20, false)
	var r := Punt.settle(d, 20, 70, false)
	assert_eq(int(r.net), 50)
	assert_eq(d.money, 1000 - 30 + 70)
	assert_eq(Punt.count(d, "wagered"), 30)
	assert_eq(Punt.count(d, "returned"), 70)
	assert_eq(Punt.count(d, "biggest"), 50)
	var lines := Punt.stat_lines(d)
	assert_true(lines.any(func(l): return "biggest" in str(l[0]).to_lower() and "£50" in str(l[1])), str(lines))
	assert_true(lines.any(func(l): return "wagered" in str(l[0]).to_lower() and "£30" in str(l[1])), str(lines))

func test_no_stats_lines_for_someone_who_never_bet() -> void:
	assert_eq(Punt.stat_lines(_data()), [])

func test_a_big_win_brings_the_charm_once() -> void:
	var d := _data(0, 1000)
	Punt.settle(d, 10, Punt.BIG_WIN + 10, false)
	assert_eq(int(d.bag.get(Punt.CHARM, 0)), 1)
	Punt.settle(d, 10, Punt.BIG_WIN + 10, false)
	assert_eq(int(d.bag.get(Punt.CHARM, 0)), 1, "only the once")

func test_a_huge_win_earns_the_novelty_cheque() -> void:
	var d := _data(0, 1000)
	assert_false(Punt.has_trophy(d))
	var r := Punt.settle(d, 10, Punt.TROPHY_WIN + 10, false)
	assert_true(Punt.has_trophy(d))
	assert_true(r.lines.size() >= 1, "it gets a mention")

func test_the_cheque_goes_on_mums_shelf_and_the_stats_page() -> void:
	var d := _data(0, 1000)
	assert_false(HomeBase.trophies(d, Fixtures.dex()).any(func(t): return t.kind == "cheque"))
	Punt.stake(d, 10, false)
	Punt.settle(d, 10, Punt.TROPHY_WIN + 10, false)
	assert_true(HomeBase.trophies(d, Fixtures.dex()).any(func(t): return t.kind == "cheque"))
	assert_true(TrainerStats.lines(d).any(func(l): return str(l[0]) == "Biggest win"))
	var shelf := HomeMeshes.shelf_node(HomeBase.trophies(d, Fixtures.dex()))
	assert_true(shelf.get_child_count() == 2, "the cabinet and its trophies")
	shelf.free()

func test_the_charm_is_a_real_charm() -> void:
	assert_true(Charms.is_charm(Punt.CHARM))

# ---------------------------------------------------------------- save safety

## The luck is dealt from the save: the same save always gets the same next result, whatever you do first.
func test_the_stream_is_deterministic_from_the_save() -> void:
	var d := _data()
	var before := d.to_dict()
	var first := Punt.rng(d, "roulette").roll_int(0, 1000000)
	var again := GameStateData.from_dict(before, Fixtures.dex())
	assert_eq(Punt.rng(again, "roulette").roll_int(0, 1000000), first, "reload, same spin")

func test_each_bet_moves_the_stream_on() -> void:
	var d := _data()
	var a := Punt.rng(d, "roulette").roll_int(0, 1000000)
	var b := Punt.rng(d, "roulette").roll_int(0, 1000000)
	assert_true(a != b, "the next spin is a new spin")

func test_the_stream_survives_a_save_and_load() -> void:
	var d := _data()
	Punt.rng(d, "fruit")
	Punt.rng(d, "fruit")
	var loaded := GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_eq(Punt.rng(loaded, "fruit").roll_int(0, 1000000), Punt.rng(d, "fruit").roll_int(0, 1000000))

## The scummer's plan: bet, lose, reload the save from before the bet, bet the same again. Same spin, same loss.
func test_reloading_before_a_bet_replays_the_same_roulette_spin() -> void:
	var d := _data(2, 1000)
	var saved := JSON.stringify(d.to_dict())
	var spins := []
	for attempt in 3:
		var dd := GameStateData.from_dict(JSON.parse_string(saved), Fixtures.dex())
		Punt.stake(dd, 10, false)
		spins.append(Roulette.spin(Punt.rng(dd, "roulette")))
	assert_eq(spins[0], spins[1])
	assert_eq(spins[1], spins[2])

func test_old_saves_start_a_fresh_stream_and_no_chips() -> void:
	var d := GameStateData.from_dict({"money": 300, "rng_seed": 7}, Fixtures.dex())
	assert_eq(Punt.chips(d), 0)
	assert_eq(Punt.left_today(d), Punt.limit(d))
	Punt.rng(d, "races")  # doesn't fall over
	assert_true(Punt.count(d, "wagered") == 0)

# ---------------------------------------------------------------- the story command

func test_casino_games_need_chips_from_the_cage() -> void:
	var h := FakeStoryHost.new()
	Commands.new(h).run([{"do": "casino", "game": "roulette", "who": "Croupier"}])
	assert_false(h.log.any(func(e): return e[0] == "menu"), "no table without chips")
	assert_true("cage" in str(h.said))
	Punt.buy_chips(h.data, 50)
	Commands.new(h).run([{"do": "casino", "game": "roulette", "who": "Croupier"}])
	assert_true(h.log.has(["menu", "roulette"]))

func test_races_and_the_novice_race_open_the_race_screen() -> void:
	var h := FakeStoryHost.new()
	Commands.new(h).run([{"do": "casino", "game": "races", "venue": "glasgow"}])
	assert_true(h.log.has(["menu", "races:glasgow"]))
	Commands.new(h).run([{"do": "casino", "game": "novice"}])
	assert_true(h.log.has(["menu", "races:novice"]))
	Racing.mark_novice(h.data)
	h.log.clear()
	Commands.new(h).run([{"do": "casino", "game": "novice"}])
	assert_false(h.log.has(["menu", "races:novice"]), "once a real day")
