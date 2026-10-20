extends TestCase
## Creature racing (core/racing.gd): the card from stats, form and the going; British prices with a bookie's
## margin; win and each-way settling; races that run the same from the same seed; the daily novice race.

func _dex() -> Dex:
	return Fixtures.dex()

func _card(day := "2026-10-20", k := 1, weather := "clear") -> Dictionary:
	return Racing.card(day, k, Racing.going_for(weather), _dex())

func test_cards_have_six_to_eight_real_runners() -> void:
	var dex := _dex()
	for k in range(1, 30):
		var c := Racing.card("2026-10-%02d" % (k % 28 + 1), k, Racing.going_for("clear"), dex)
		var n: int = c.runners.size()
		assert_true(n >= 6 and n <= 8, "%d runners" % n)
		var names := {}
		for r in c.runners:
			assert_true(dex.has(str(r.species)), str(r.species))
			assert_true(str(r.name) != "")
			names[r.name] = true
			assert_true(Odds.LADDER.has(r.odds), "a ladder price")
		assert_eq(names.size(), n, "no two runners share a name")

func test_the_same_day_shows_the_same_card_everywhere() -> void:
	var a := _card()
	var b := _card()
	assert_eq(JSON.stringify(a), JSON.stringify(b))
	assert_true(JSON.stringify(_card("2026-10-21")) != JSON.stringify(a), "a new day, a new card")

func test_prices_follow_the_chances() -> void:
	var c := _card()
	var best := 0
	var worst := 0
	for i in c.runners.size():
		if c.runners[i].p_win > c.runners[best].p_win:
			best = i
		if c.runners[i].p_win < c.runners[worst].p_win:
			worst = i
	assert_true(Odds.value(c.runners[best].odds) < Odds.value(c.runners[worst].odds), "the favourite is the shortest price")

func test_faster_creatures_are_better_rated() -> void:
	var dex := _dex()
	var going := Racing.going_for("clear")
	assert_true(Racing.rating(dex.get_species("stoopfalcon"), going) > Racing.rating(dex.get_species("puffkin"), going))

func test_the_going_comes_from_the_weather() -> void:
	assert_eq(Racing.going_for("sunshine").id, "good_to_firm")
	assert_eq(Racing.going_for("downpour").id, "heavy")
	assert_eq(Racing.going_for("drizzle").id, "good_to_soft")
	assert_eq(Racing.going_for("").id, "good")

func test_the_going_suits_some_more_than_others() -> void:
	var dex := _dex()
	var otter: Dictionary = dex.get_species("rillotter")  # a brook creature loves the mud
	assert_true(Racing.rating(otter, Racing.going_for("downpour")) > Racing.rating(otter, Racing.going_for("sunshine")))

func test_each_way_terms() -> void:
	assert_eq(Racing.places_for(6), 2)
	assert_eq(Racing.places_for(7), 2)
	assert_eq(Racing.places_for(8), 3)
	assert_eq(Racing.place_fraction(7), [1, 4])
	assert_eq(Racing.place_fraction(8), [1, 5])

func test_settling_win_and_each_way_bets() -> void:
	var c := _card()
	c.runners[2].odds = [5, 1]
	var order := [2, 0, 1, 3, 4, 5]
	assert_eq(Racing.returns(c, order, {"runner": 2, "stake": 10, "each_way": false}), 60)
	assert_eq(Racing.returns(c, order, {"runner": 0, "stake": 10, "each_way": false}), 0)
	var frac: Array = Racing.place_fraction(c.runners.size())
	var place_back := Odds.returns(10, [5 * frac[0], frac[1]])
	assert_eq(Racing.returns(c, order, {"runner": 2, "stake": 10, "each_way": true}), 60 + place_back, "won: both halves pay")
	c.runners[0].odds = [5, 1]
	assert_eq(Racing.returns(c, order, {"runner": 0, "stake": 10, "each_way": true}), place_back, "placed: the place half pays")
	assert_eq(Racing.returns(c, order, {"runner": 5, "stake": 10, "each_way": true}), 0, "down the field")

func test_a_race_runs_the_same_from_the_same_seed() -> void:
	var c := _card()
	var a := Racing.run(c, Rng.new(42))
	var b := Racing.run(c, Rng.new(42))
	assert_eq(a.order, b.order)
	assert_eq(a.order.size(), c.runners.size())
	var differs := false
	for s in range(1, 20):
		if Racing.run(c, Rng.new(s)).order != a.order:
			differs = true
	assert_true(differs, "but it isn't fixed")

func test_runs_carry_a_commentary() -> void:
	var c := _card()
	var r := Racing.run(c, Rng.new(1))
	assert_true(r.has("perf") and r.perf.size() == c.runners.size())
	var lines := Racing.commentary(c, r)
	assert_true(lines.size() >= 4)
	for l in lines:
		assert_false("—" in str(l), "no em-dashes")
	assert_true(str(c.runners[r.order[0]].name) in str(lines.back()), "names the winner at the end")

## The book: across many races, backing every runner (win or each-way) gets less back than it costs.
func test_the_bookie_has_an_edge_on_every_kind_of_bet() -> void:
	var dex := _dex()
	var rng := Rng.new(7)
	var win_staked := 0
	var win_back := 0
	var ew_staked := 0
	var ew_back := 0
	for k in range(1, 61):
		var c := Racing.card("2026-%02d-%02d" % [k % 12 + 1, k % 28 + 1], k, Racing.going_for(["clear", "downpour", "sunshine"][k % 3]), dex)
		for i in c.runners.size():
			var ev_w := float(c.runners[i].p_win) * (1.0 + Odds.value(c.runners[i].odds))
			assert_true(ev_w < 1.0, "win EV %.3f" % ev_w)
		for t in 40:
			var res := Racing.run(c, rng)
			for i in c.runners.size():
				win_staked += 10
				win_back += Racing.returns(c, res.order, {"runner": i, "stake": 10, "each_way": false})
				ew_staked += 20
				ew_back += Racing.returns(c, res.order, {"runner": i, "stake": 10, "each_way": true})
	var w := float(win_back) / win_staked
	var e := float(ew_back) / ew_staked
	print("win RTP %.4f, each-way RTP %.4f" % [w, e])
	assert_true(w < 0.95 and w > 0.75, "win RTP %.4f" % w)
	assert_true(e < 0.97 and e > 0.7, "each-way RTP %.4f" % e)

# ---------------------------------------------------------------- the novice race

func test_the_novice_race_includes_your_creature() -> void:
	var mine := Fixtures.creature("kindlet", 20)
	var c := Racing.novice_card("2026-10-20", mine, _dex(), Racing.going_for("clear"))
	var yours: Array = c.runners.filter(func(r): return bool(r.get("yours", false)))
	assert_eq(yours.size(), 1)
	assert_eq(str(yours[0].species), "kindlet")
	assert_true(c.runners.size() >= 6)
	assert_eq(JSON.stringify(c), JSON.stringify(Racing.novice_card("2026-10-20", mine, _dex(), Racing.going_for("clear"))))

func test_novice_prize_money() -> void:
	assert_true(Racing.novice_prize(1, 0) > Racing.novice_prize(2, 0))
	assert_true(Racing.novice_prize(2, 0) > Racing.novice_prize(3, 0))
	assert_eq(Racing.novice_prize(4, 0), 0)
	assert_true(Racing.novice_prize(1, 8) > Racing.novice_prize(1, 0), "a bigger purse once you're known")

func test_novice_race_once_a_real_day() -> void:
	var d := GameStateData.new()
	assert_false(Racing.novice_run_today(d))
	Racing.mark_novice(d)
	assert_true(Racing.novice_run_today(d))

func test_the_meeting_moves_on_race_by_race() -> void:
	var d := GameStateData.new()
	assert_eq(Racing.next_race(d), 1)
	Racing.race_done(d)
	assert_eq(Racing.next_race(d), 2)
	d.set_flag(Racing.DAY_FLAG, "1999-01-01")
	assert_eq(Racing.next_race(d), 1, "a new day, the first race again")
