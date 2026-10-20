extends TestCase
## The pound against the euro: seeded, daily, mean-reverting, in a believable band; the bureau's spread.

func test_same_seed_and_day_same_rate() -> void:
	var a := Forex.mid(7, 30)
	Forex.mid(8, 50)  # another seed in between must not disturb it
	assert_eq(Forex.mid(7, 30), a)
	assert_true(Forex.mid(7, 31) != a, "it moves day to day")
	assert_true(Forex.mid(7, 30) != Forex.mid(8, 30), "different journeys, different rates")

func test_stays_in_a_believable_band_and_reverts() -> void:
	var lo := 9.0
	var hi := 0.0
	var sum := 0.0
	var n := 0
	for s in range(1, 41):
		for d in range(0, 400, 4):
			var m := Forex.mid(s, d)
			lo = minf(lo, m)
			hi = maxf(hi, m)
			sum += m
			n += 1
	assert_true(lo >= Forex.LOW and hi <= Forex.HIGH, "clamped %s..%s" % [lo, hi])
	var mean := sum / n
	assert_true(mean > 1.15 and mean < 1.20, "centres on about 1.175: %s" % mean)
	assert_true(lo < 1.13 and hi > 1.22, "but it does wander: %s..%s" % [lo, hi])

func test_mostly_within_110_and_125() -> void:
	var inside := 0
	var n := 0
	for s in range(100, 130):
		for d in range(0, 300, 3):
			var m := Forex.mid(s, d)
			n += 1
			if m >= 1.10 and m <= 1.25:
				inside += 1
	assert_true(inside * 100 / n >= 93, "%d%% of days in 1.10..1.25" % (inside * 100 / n))

func test_story_nudge_lands_on_its_day_and_fades() -> void:
	var ev := {"game_complete": 20}
	assert_eq(Forex.mid(3, 19, ev), Forex.mid(3, 19), "nothing before the day")
	var jump := log(Forex.mid(3, 20, ev)) - log(Forex.mid(3, 20))
	assert_near(jump, Forex.STORY.game_complete, 0.002, "the nudge")
	var later := log(Forex.mid(3, 60, ev)) - log(Forex.mid(3, 60))
	assert_true(absf(later) < absf(jump) / 5.0, "and it fades")

func test_bureau_spread_means_a_round_trip_always_loses() -> void:
	var d := GameStateData.new()
	for s in range(1, 30):
		d.rng_seed = s
		d.day_count = s * 7
		d.money = 1000
		d.euros = 0
		var r := Forex.exchange(d, 1000, Wallet.GBP)
		assert_true(r.ok)
		var back := Forex.exchange(d, d.euros, Wallet.EUR)
		assert_true(back.ok)
		assert_true(d.money < 1000 and d.money > 930, "lost the spread both ways, no more: %d" % d.money)

func test_even_buying_low_and_selling_high_across_the_band_is_modest() -> void:
	# the best possible round trip: euros bought at the top of the band, sold back at the bottom
	var gain := Forex.bureau_buy_eur(Forex.HIGH) / Forex.bureau_sell_eur(Forex.LOW)
	assert_true(gain < 1.18, "a once-in-a-blue-moon trade, not a money printer: %s" % gain)

func test_exchange_refuses_more_than_you_have() -> void:
	var d := GameStateData.new()
	d.money = 50
	assert_false(Forex.exchange(d, 51, Wallet.GBP).ok)
	assert_eq(d.money, 50)
	assert_false(Forex.exchange(d, 0, Wallet.GBP).ok)

func test_history_is_oldest_first_and_ends_today() -> void:
	var h := Forex.history(5, 40, 14)
	assert_eq(h.size(), 14)
	assert_eq(h[13], Forex.mid(5, 40))
	assert_eq(h[0], Forex.mid(5, 27))
	var early := Forex.history(5, 3, 14)
	assert_eq(early.size(), 14, "before day 14 the chart pads with day 0")

func test_tourist_rate_is_worse_than_the_bureau() -> void:
	var m := 1.18
	assert_true(Forex.tourist_eur_per_gbp(m, true) < Forex.bureau_buy_eur(m))
	assert_true(Forex.tourist_eur_per_gbp(m, false) > Forex.bureau_sell_eur(m))
