extends TestCase
## The Palace casino's games (core/odds.gd, roulette.gd, blackjack.gd, higher_lower.gd, fruit_machine.gd):
## the odds maths, the payouts, and a house edge on every bet.

# ---------------------------------------------------------------- fractional odds

func test_odds_read_like_a_bookies_board() -> void:
	assert_eq(Odds.text([1, 1]), "Evens")
	assert_eq(Odds.text([5, 2]), "5/2")
	assert_eq(Odds.text([100, 30]), "100/30")
	assert_eq(Odds.text([4, 6]), "4/6")
	assert_near(Odds.value([100, 30]), 3.3333, 0.001)

func test_odds_ladder_is_sorted_and_has_the_classics() -> void:
	for i in range(1, Odds.LADDER.size()):
		assert_true(Odds.value(Odds.LADDER[i]) > Odds.value(Odds.LADDER[i - 1]), "ladder ascends at %d" % i)
	for f in [[1, 1], [5, 2], [100, 30], [11, 8], [4, 6], [33, 1], [100, 1]]:
		assert_true(Odds.LADDER.has(f), "has %s" % Odds.text(f))

func test_odds_round_down_never_up() -> void:
	assert_eq(Odds.at_most(3.4), [100, 30])
	assert_eq(Odds.at_most(3.3), [3, 1])
	assert_eq(Odds.at_most(1.0), [1, 1])
	assert_eq(Odds.at_most(0.99), [20, 21])
	assert_eq(Odds.at_most(0.0001), Odds.LADDER[0], "never below the shortest price")
	assert_eq(Odds.at_most(5000.0), Odds.LADDER.back(), "never above the longest")

func test_odds_returns_stake_plus_winnings_rounded_down() -> void:
	assert_eq(Odds.returns(10, [5, 2]), 35)
	assert_eq(Odds.returns(10, [1, 1]), 20)
	assert_eq(Odds.returns(10, [4, 6]), 16, "£6.66 of winnings is £6, the bookie keeps the pennies")
	assert_eq(Odds.returns(3, [100, 30]), 13)

# ---------------------------------------------------------------- roulette

func test_wheel_is_european_single_zero() -> void:
	assert_eq(Roulette.WHEEL.size(), 37)
	var seen := {}
	for n in Roulette.WHEEL:
		seen[n] = true
	assert_eq(seen.size(), 37, "0 to 36 once each")
	assert_false(seen.has(37), "no double zero")
	assert_eq(Roulette.colour(0), "green")
	assert_eq(Roulette.colour(1), "red")
	assert_eq(Roulette.colour(2), "black")
	assert_eq(Roulette.RED.size(), 18)

func test_roulette_payouts_are_the_standard_table() -> void:
	assert_eq(Roulette.pays(Roulette.straight(17)), 35)
	assert_eq(Roulette.pays(Roulette.split(17, 20)), 17)
	assert_eq(Roulette.pays(Roulette.street(13)), 11)
	assert_eq(Roulette.pays(Roulette.corner(1)), 8)
	assert_eq(Roulette.pays(Roulette.line(1)), 5)
	assert_eq(Roulette.pays(Roulette.dozen(2)), 2)
	assert_eq(Roulette.pays(Roulette.column(3)), 2)
	for b in [Roulette.red(), Roulette.black(), Roulette.odd(), Roulette.even(), Roulette.low(), Roulette.high()]:
		assert_eq(Roulette.pays(b), 1, str(b.label))

func test_roulette_bets_cover_the_right_numbers() -> void:
	assert_eq(Roulette.street(13).numbers, [13, 14, 15])
	assert_eq(Roulette.corner(1).numbers, [1, 2, 4, 5])
	assert_eq(Roulette.line(31).numbers, [31, 32, 33, 34, 35, 36])
	assert_eq(Roulette.column(1).numbers.size(), 12)
	assert_true(Roulette.column(1).numbers.has(34))
	assert_false(Roulette.red().numbers.has(0), "zero is nobody's colour")
	assert_false(Roulette.even().numbers.has(0), "zero isn't even, at the Palace")
	assert_true(Roulette.split(17, 18).numbers == [17, 18])
	assert_true(Roulette.split(17, 19).is_empty(), "not neighbours on the layout")
	assert_true(Roulette.split(3, 4).is_empty(), "3 and 4 sit in different streets, not side by side")
	assert_true(Roulette.corner(3).is_empty(), "no corner hangs off the top row")

func test_roulette_returns() -> void:
	assert_eq(Roulette.returns(Roulette.straight(17), 10, 17), 360)
	assert_eq(Roulette.returns(Roulette.straight(17), 10, 18), 0)
	assert_eq(Roulette.returns(Roulette.red(), 10, 1), 20)
	assert_eq(Roulette.returns(Roulette.red(), 10, 0), 0)

func test_roulette_layout_matches_the_felt() -> void:
	assert_eq(Roulette.layout_number(0, 0), 3, "top row: 3, 6, 9 ...")
	assert_eq(Roulette.layout_number(0, 2), 1)
	assert_eq(Roulette.layout_number(11, 0), 36)

## Every bet on the table returns 36/37 of the stake on average: the single zero is the house edge.
func test_roulette_has_a_house_edge_on_every_bet() -> void:
	var bets := [Roulette.straight(7), Roulette.split(1, 2), Roulette.street(4), Roulette.corner(8), Roulette.line(10),
		Roulette.red(), Roulette.black(), Roulette.odd(), Roulette.even(), Roulette.low(), Roulette.high(),
		Roulette.dozen(1), Roulette.column(2)]
	for b in bets:
		var back := 0
		for n in 37:
			back += Roulette.returns(b, 100, n)
		assert_near(back / 3700.0, 36.0 / 37.0, 0.0001, str(b.label))

func test_spins_land_on_every_pocket() -> void:
	var rng := Rng.new(3)
	var seen := {}
	for i in 2000:
		seen[Roulette.spin(rng)] = true
	assert_eq(seen.size(), 37)

# ---------------------------------------------------------------- blackjack

func _c(rank: int) -> Dictionary:
	return {"rank": rank, "suit": 0}

func test_hand_values_count_aces_both_ways() -> void:
	assert_eq(Blackjack.value([_c(1), _c(13)]).total, 21)
	assert_true(Blackjack.value([_c(1), _c(6)]).soft, "ace and six is soft 17")
	assert_eq(Blackjack.value([_c(1), _c(6), _c(10)]).total, 17)
	assert_false(Blackjack.value([_c(1), _c(6), _c(10)]).soft)
	assert_eq(Blackjack.value([_c(1), _c(1), _c(9)]).total, 21)
	assert_true(Blackjack.is_blackjack([_c(1), _c(12)]))
	assert_false(Blackjack.is_blackjack([_c(7), _c(4), _c(10)]))

func test_dealer_stands_on_every_17_including_soft() -> void:
	assert_false(Blackjack.dealer_hits([_c(1), _c(6)]), "stands on soft 17")
	assert_false(Blackjack.dealer_hits([_c(10), _c(7)]))
	assert_true(Blackjack.dealer_hits([_c(10), _c(6)]))
	assert_true(Blackjack.dealer_hits([_c(1), _c(5)]))

func test_blackjack_pays_three_to_two() -> void:
	var g := Blackjack.rigged(20, [_c(1), _c(13)], [_c(9), _c(8)], [])
	assert_eq(g.result, "blackjack")
	assert_eq(g.returns(), 50, "£20 back plus £30")
	assert_true(g.done)

func test_blackjack_win_push_and_bust() -> void:
	var g := Blackjack.rigged(10, [_c(10), _c(9)], [_c(10), _c(7)], [])
	g.stand()
	assert_eq(g.result, "win")
	assert_eq(g.returns(), 20)
	var p := Blackjack.rigged(10, [_c(10), _c(7)], [_c(10), _c(7)], [])
	p.stand()
	assert_eq(p.result, "push")
	assert_eq(p.returns(), 10)
	var b := Blackjack.rigged(10, [_c(10), _c(6)], [_c(10), _c(7)], [_c(9)])
	b.hit()
	assert_eq(b.result, "bust")
	assert_eq(b.returns(), 0)
	assert_true(b.done)

func test_dealer_draws_to_17_then_stops() -> void:
	var g := Blackjack.rigged(10, [_c(10), _c(8)], [_c(10), _c(2)], [_c(3), _c(4), _c(9)])
	g.stand()
	assert_eq(Blackjack.value(g.dealer).total, 19, "12, 15, then 19")
	assert_eq(g.result, "lose")

func test_double_down_takes_one_card_and_pays_double() -> void:
	var g := Blackjack.rigged(10, [_c(6), _c(5)], [_c(10), _c(6)], [_c(10), _c(10)])
	assert_true(g.can_double())
	g.double_down()
	assert_eq(g.player.size(), 3, "exactly one more card")
	assert_eq(g.stake, 20)
	assert_true(g.done)
	assert_eq(g.result, "win", "21 against a dealer who bust on 26")
	assert_eq(g.returns(), 40)

func test_dealer_blackjack_wins_straight_away() -> void:
	var g := Blackjack.rigged(10, [_c(10), _c(9)], [_c(1), _c(10)], [])
	assert_true(g.done)
	assert_eq(g.result, "dealer_blackjack")
	assert_eq(g.returns(), 0)

func test_a_shoe_is_six_full_decks() -> void:
	var shoe := Blackjack.shoe(Rng.new(1))
	assert_eq(shoe.size(), 312)
	var aces := shoe.filter(func(c): return c.rank == 1).size()
	assert_eq(aces, 24)

## Basic strategy (no splits at the Palace) still loses a little over a long night.
func test_blackjack_has_a_house_edge_under_basic_strategy() -> void:
	var rng := Rng.new(2026)
	var staked := 0
	var back := 0
	for i in 12000:
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
	var rtp := float(back) / staked
	assert_true(rtp < 1.0, "house wins in the end, RTP %.4f" % rtp)
	assert_true(rtp > 0.96, "but it's a fair game, RTP %.4f" % rtp)

# ---------------------------------------------------------------- higher or lower

func test_higher_lower_chances_and_prices() -> void:
	assert_near(HigherLower.chance("higher", 2), 12.0 / 13.0)
	assert_near(HigherLower.chance("lower", 2), 0.0)
	assert_near(HigherLower.chance("higher", 14), 0.0)
	assert_near(HigherLower.chance("lower", 8), 6.0 / 13.0, 0.0001, "a tie loses")
	assert_eq(HigherLower.multiplier("higher", 14), 0.0, "no price on the impossible")
	for r in range(2, 15):
		for g in ["higher", "lower"]:
			var p := HigherLower.chance(g, r)
			if p > 0.0:
				var ev := p * HigherLower.multiplier(g, r)
				assert_true(ev <= 1.0 - HigherLower.EDGE + 0.0001, "%s on %d: EV %.3f" % [g, r, ev])
				assert_true(ev > 0.9, "%s on %d still worth a punt: EV %.3f" % [g, r, ev])

func test_higher_lower_ladder() -> void:
	var g := HigherLower.rigged(10, [5, 9, 3, 3])
	assert_eq(g.card().rank, 5)
	assert_true(g.guess("higher"), "9 is higher than 5")
	assert_near(g.pot, 10 * HigherLower.multiplier("higher", 5), 0.001)
	assert_true(g.guess("lower"), "3 is lower than 9")
	var pot: float = g.pot
	assert_false(g.guess("higher"), "3 on 3 is a tie, and a tie loses")
	assert_eq(g.returns(), 0)
	assert_true(g.done)
	assert_true(pot > 10)

func test_higher_lower_cash_out_and_refund() -> void:
	var g := HigherLower.rigged(10, [5, 9])
	assert_eq(g.cash_out(), 10, "walk away before guessing: your stake back")
	var h := HigherLower.rigged(10, [5, 9])
	h.guess("higher")
	var pot: float = h.pot
	assert_eq(h.cash_out(), int(floor(pot)))
	assert_true(h.done)

func test_higher_lower_rtp_for_a_sensible_punter() -> void:
	var rng := Rng.new(99)
	var staked := 0
	var back := 0
	for i in 20000:
		var g := HigherLower.new(rng, 10)
		for step in 3:  # always the likelier side, cash out after three
			if g.done:
				break
			var r: int = g.card().rank
			g.guess("higher" if HigherLower.chance("higher", r) >= HigherLower.chance("lower", r) else "lower")
		if not g.done:
			g.cash_out()
		staked += 10
		back += g.returns()
	var rtp := float(back) / staked
	assert_true(rtp < 0.95, "RTP %.4f" % rtp)
	assert_true(rtp > 0.8, "RTP %.4f" % rtp)

# ---------------------------------------------------------------- the fruit machine

func test_fruit_machine_symbols_are_real_creatures() -> void:
	var dex := Fixtures.dex()
	for s in FruitMachine.SYMBOLS:
		assert_true(dex.has(str(s.species)), str(s.species))
	assert_eq(FruitMachine.PAYS.size(), FruitMachine.SYMBOLS.size())
	for strip in FruitMachine.STRIPS:
		assert_eq(strip.size(), FruitMachine.STOPS)

func test_fruit_machine_pay_table() -> void:
	for i in FruitMachine.SYMBOLS.size():
		assert_eq(FruitMachine.pays([i, i, i]), FruitMachine.PAYS[i])
	assert_eq(FruitMachine.pays([0, 0, 3]), FruitMachine.TWO_LOW, "two of the lowest from the left")
	assert_eq(FruitMachine.pays([3, 0, 0]), 0, "only from the left")
	assert_eq(FruitMachine.pays([1, 2, 3]), 0)

func test_nudging_brings_the_symbol_above_down_onto_the_line() -> void:
	var pos := [5, 5, 5]
	var above: int = FruitMachine.symbol_at(0, 4)
	var nudged := FruitMachine.nudge(pos, 0)
	assert_eq(FruitMachine.line(nudged)[0], above)
	assert_eq(pos, [5, 5, 5], "the original isn't touched")
	assert_eq(FruitMachine.nudge([0, 0, 0], 1)[1], FruitMachine.STOPS - 1, "wraps round")

func test_held_reels_stay_put() -> void:
	var rng := Rng.new(5)
	for i in 50:
		var s := FruitMachine.spin(rng, [3, 7, 11], [true, false, true])
		assert_eq(s.pos[0], 3)
		assert_eq(s.pos[2], 11)

func test_best_nudge_finds_a_win_when_there_is_one() -> void:
	# put reel 0 one stop below a symbol that would complete a line
	for a in FruitMachine.STOPS:
		for b in FruitMachine.STOPS:
			var l := FruitMachine.line([a, b, 0])
			if l[1] == l[2] and FruitMachine.symbol_at(0, a - 1) == l[1] and l[0] != l[1]:
				var best := FruitMachine.best_nudge([a, b, 0], 1)
				assert_true(int(best.mult) >= FruitMachine.PAYS[l[1]])
				return
	fail("no test position found")

## Exact: every stop combination, with nudges always used as well as possible.
func test_fruit_machine_returns_less_than_it_takes_even_played_perfectly() -> void:
	var rtp := FruitMachine.exact_rtp_with_nudges()
	assert_true(rtp < 0.93, "base game plus perfect nudging %.4f" % rtp)
	assert_true(rtp > 0.8, "%.4f" % rtp)

func test_fruit_machine_session_rtp_with_holds() -> void:
	var r := FruitMachine.simulate(Rng.new(11), 30000, true)
	assert_true(r.rtp < 0.95, "perfect play RTP %.4f" % r.rtp)
	assert_true(r.rtp > 0.85, "perfect play RTP %.4f" % r.rtp)
	var lazy := FruitMachine.simulate(Rng.new(11), 30000, false)
	assert_true(lazy.rtp < r.rtp, "ignoring the nudges and holds costs you")
