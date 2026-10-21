extends TestCase
## Darts (board, 501, checkouts, locals, league, money) and crabbing (the line, species, competition, release).

func test_board_scores() -> void:
	assert_eq(Darts.score_at(Vector2.ZERO).points, 50, "bull")
	assert_eq(Darts.score_at(Vector2(0.0, -0.06)).points, 25, "outer bull")
	assert_eq(Darts.score_at(Darts.centre_of("T20")).points, 60, "treble 20")
	assert_eq(Darts.score_at(Darts.centre_of("D16")).points, 32, "double 16")
	assert_eq(Darts.score_at(Darts.centre_of("19")).points, 19, "single 19")
	assert_eq(Darts.score_at(Vector2(1.2, 0.0)).points, 0, "off the board")
	for n in Darts.ORDER:
		assert_eq(Darts.score_at(Darts.centre_of("T%d" % n)).points, n * 3, "T%d round trip" % n)
		assert_eq(Darts.score_at(Darts.centre_of("D%d" % n)).points, n * 2, "D%d round trip" % n)

func test_501_busts_and_doubles() -> void:
	assert_true(Darts.throw_dart(32, 33, 3).bust, "too many")
	assert_true(Darts.throw_dart(20, 19, 1).bust, "leaving one is a bust")
	assert_true(Darts.throw_dart(20, 20, 1).bust, "no double, no finish")
	assert_true(Darts.throw_dart(40, 40, 2).won, "double 20 wins")
	assert_true(Darts.throw_dart(50, 50, 2).won, "the bull is a double")
	assert_eq(Darts.throw_dart(100, 60, 3).remaining, 40)

func test_checkouts() -> void:
	assert_eq(Darts.checkout(170), ["T20", "T20", "Bull"])
	assert_eq(Darts.checkout(40), ["D20"])
	assert_eq(Darts.checkout(2), ["D1"])
	assert_eq(Darts.checkout(169), [], "169 can't be done in three")
	assert_eq(Darts.checkout(171), [])
	for r in range(2, 171):
		var route := Darts.checkout(r)
		if route.is_empty():
			continue
		var total := 0
		for l in route:
			total += int(Darts.score_at(Darts.centre_of(l)).points)
		assert_eq(total, r, "route for %d adds up" % r)
		assert_eq(Darts.score_at(Darts.centre_of(route.back())).mult, 2, "ends on a double: %d" % r)

func test_reticle_is_bounded_and_steadier_when_easy() -> void:
	var hard := Darts.steadiness(false)
	var easy := Darts.steadiness(true)
	assert_true(float(easy.wobble) < float(hard.wobble) and float(easy.speed) < float(hard.speed))
	for i in 200:
		var p := Darts.reticle(Vector2(0.2, -0.3), float(i) * 0.07, float(hard.wobble), float(hard.speed))
		assert_true((p - Vector2(0.2, -0.3)).length() <= float(hard.wobble) * 1.12, "stays within the wobble")

func test_locals_rank_by_skill() -> void:
	var rng := Rng.new(11)
	var avg := func(sigma: float) -> float:
		var tot := 0.0
		for i in 400:
			var v := Darts.local_visit(Darts.START, sigma, rng)
			for d in v.thrown:
				tot += float(d.points)
		return tot / 400.0
	var ace: float = avg.call(0.10)
	var pub: float = avg.call(0.30)
	assert_true(ace > pub * 1.5, "an ace outscores a casual (%.1f vs %.1f)" % [ace, pub])
	assert_true(ace < 100.0, "nobody averages three-treble-twenties")

func test_every_league_is_ordered_and_a_leg_ends() -> void:
	assert_eq(Darts.nations().size(), 5)
	for n in Darts.nations():
		var lg := Darts.league(n)
		assert_eq((lg.rungs as Array).size(), 5)
		var last := 9.0
		var prizes := 0
		for r in lg.rungs:
			assert_true(float(r.sigma) < last, "%s gets harder up the ladder" % n)
			last = float(r.sigma)
			prizes += int(r.prize)
			assert_false(("—" in str(r.intro)) or ("—" in str(r.beaten)), "no em-dashes")
		assert_eq(Darts.league_total(n), prizes)
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % lg.pub), "pub zone exists: " + str(lg.pub))

func test_league_money_is_finite_and_small() -> void:
	var d := GameStateData.new()
	var rng := Rng.new(5)
	var before := d.money
	for rep in 3:  # a thousand rematches in one pub on one real day pay once
		for k in 300:
			Darts.win(d, "wales", "swansea_nosign", 0)
	var rungs: Array = Darts.league("wales").rungs
	assert_true(Darts.rungs_beaten(d, "wales") <= 1, "rematches don't climb the ladder")
	# the climb pays the prizes once, in order
	var e := GameStateData.new()
	var got := 0
	for i in 5:
		var w := Darts.win(e, "wales", "swansea_nosign", i)
		assert_true(w.first)
		got += int(w.money)
	assert_eq(got, Darts.league_total("wales"))
	assert_true(Darts.champion(e, "wales"))
	var again := Darts.win(e, "wales", "swansea_nosign", 2)
	assert_false(again.first)
	assert_true(int(again.money) <= Darts.DAILY_PURSE, "a rematch pays at most the daily purse")
	assert_eq(Darts.win(e, "wales", "swansea_nosign", 3).money, 0, "and only once a day per pub")
	assert_true(rungs.size() == 5 and d.money == before)

func test_a_median_player_cannot_farm_the_league() -> void:
	# a patient simulated player (spread 0.17) wins the opener most of the time and the champion rarely
	var rng := Rng.new(21)
	var wins := [0, 0]
	for i in 200:
		if Darts.sim_leg(0.17, float(Darts.league("england").rungs[0].sigma), rng):
			wins[0] += 1
		if Darts.sim_leg(0.17, float(Darts.league("england").rungs[4].sigma), rng):
			wins[1] += 1
	assert_true(wins[0] > wins[1], "the opener is easier than the champion (%d vs %d)" % [wins[0], wins[1]])
	assert_true(wins[0] >= 100, "the first rung is winnable (%d of 200)" % wins[0])

# ---- crabbing

func test_line_climbs_holds_and_empties() -> void:
	var p := {"interval": 1.0, "hold": 2.0, "max": 4}
	assert_eq(Crabbing.on_line(0.0, p), 0)
	assert_eq(Crabbing.on_line(2.5, p), 2)
	assert_eq(Crabbing.on_line(4.0, p), 4)
	assert_eq(Crabbing.on_line(5.9, p), 4, "holds while full")
	assert_eq(Crabbing.on_line(6.5, p), 3, "then drops")
	assert_eq(Crabbing.on_line(Crabbing.empty_at(p) + 0.1, p), 0)
	var prev := 0
	for i in 200:
		var n := Crabbing.on_line(float(i) * 0.1, p)
		assert_true(n >= 0 and n <= 4)
		prev = n
	assert_eq(prev, 0, "empties by the end")

func test_easy_crabbing_holds_longer() -> void:
	var rng := Rng.new(2)
	var hard := Crabbing.plan(false, rng)
	var easy := Crabbing.plan(true, rng)
	assert_true(float(easy.hold) > float(hard.hold) and float(easy.interval) > float(hard.interval))

func test_species_are_real_and_season_gated() -> void:
	var rng := Rng.new(8)
	assert_true(Crabbing.species().size() >= 5)
	for s in Crabbing.species():
		assert_true(int(s.max) > int(s.min), "size range: " + str(s.id))
		assert_true(str(s.fact).length() > 40, "has a fact")
		assert_false("—" in str(s.fact))
	var winter := {}
	for i in 400:
		winter[Crabbing.pick_species("winter", rng).id] = true
	assert_false(winter.has("spider_crab"), "no spider crabs in winter")
	var catch_ := Crabbing.catch_for(6, "summer", rng)
	assert_eq(catch_.size(), 6)
	for c in catch_:
		assert_true(int(c.mm) >= 8 and int(c.mm) <= 110)

func test_release_counts_and_tips_once_a_day() -> void:
	var d := GameStateData.new()
	var rng := Rng.new(4)
	var bucket := Crabbing.catch_for(12, "summer", rng)
	var out := Crabbing.release(d, "whitby", bucket)
	assert_eq(out.released, 12)
	assert_eq(TrainerStats.get_count(d, "crabs_caught"), 12)
	assert_true(int(d.flags.get(Crabbing.FLAG_BEST, 0)) > 0)
	var s1 := Standing.points(d, "england")
	var out2 := Crabbing.release(d, "whitby", Crabbing.catch_for(12, "summer", rng))
	assert_eq(Standing.points(d, "england"), s1, "the harbour only warms to you once a day")
	assert_eq(Crabbing.release(d, "whitby", []).released, 0)
	assert_true(out2.released == 12)

func test_competition_scoring_and_prizes() -> void:
	var rng := Rng.new(9)
	var rivals := Crabbing.rival_scores(rng)
	assert_eq(rivals.size(), 3)
	assert_eq(Crabbing.place(999, rivals), 0)
	assert_eq(Crabbing.place(0, rivals), 3)
	assert_eq(Crabbing.score([]), 0)
	assert_eq(Crabbing.score([{"mm": 60}, {"mm": 20}]), 2 + 3)
	var total := 0
	for p in 4:
		total += Crabbing.prize(p)
	assert_eq(Crabbing.prize(3), 0)
	assert_true(Crabbing.prize(0) > Crabbing.prize(1) and Crabbing.prize(1) > Crabbing.prize(2))
	# one competition a real day per harbour, so the cap is the first prize less the entry fee
	assert_true(Crabbing.prize(0) <= 150 and total > 0)
	var d := GameStateData.new()
	assert_false(Crabbing.comp_done_today(d, "whitby"))
	Crabbing.comp_enter(d, "whitby")
	assert_true(Crabbing.comp_done_today(d, "whitby"))
	assert_false(Crabbing.comp_done_today(d, "dingle"))

func test_a_best_possible_bucket_still_has_a_ceiling() -> void:
	# eight hauls of a full line: five crabs each, capped by the bucket
	var n := mini(8 * Crabbing.MAX_ON_LINE, Crabbing.bucket_size())
	assert_true(n <= 14)
	var bucket: Array = []
	for i in n:
		bucket.append({"id": "spider_crab", "name": "Spider Crab", "mm": 110})
	var best := Crabbing.score(bucket)
	var worst_rival := 0
	for r in Crabbing.comp().rivals:
		worst_rival = maxi(worst_rival, int(r.mean) + int(r.spread))
	assert_true(best >= worst_rival, "a perfect run wins")
	assert_true(Crabbing.prize(0) - int(Crabbing.comp().fee) <= 150, "and a perfect run still pays modestly")

func test_the_kit_and_story_data_are_valid() -> void:
	for spot in Crabbing.cfg().spots:
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % spot), "spot zone exists: " + str(spot))
	for h in Crabbing.comp().hosts:
		assert_true(Crabbing.is_spot(str(h)), "host harbour is a spot: " + str(h))
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % h))
	var d := GameStateData.new()
	assert_true(Crabbing.refusal(d, "whitby", "water") != "", "no kit, no crabbing")
	d.bag[Crabbing.KIT] = 1
	assert_true(Crabbing.refusal(d, "whitby", "water").contains("bait"))
	d.bag[Crabbing.BAIT] = 3
	assert_eq(Crabbing.refusal(d, "whitby", "water"), "")
	assert_true(Crabbing.refusal(d, "nowhere_in_particular", "water") != "")
	assert_true(Crabbing.refusal(d, "whitby", "grass") != "")
