extends TestCase
## Sea shanties (timing, pulls, pay) and conkers (season, match rules, rungs, prizes).

func test_every_shanty_has_lines_with_valid_pulls() -> void:
	assert_true(Shanties.shanties().size() >= 4)
	for s in Shanties.shanties():
		assert_true(s.lines.size() >= 3, "%s has lines" % s.id)
		assert_true(str(s.fact) != "")
		for l in s.lines:
			assert_true(l.pulls.size() >= 1)
			for b in l.pulls:
				assert_true(int(b) >= 0 and int(b) < Shanties.LINE_BEATS, "%s: pull in the line" % s.id)

func test_targets_are_in_order_inside_the_song() -> void:
	for s in Shanties.shanties():
		var tg := Shanties.targets(s, 0.55)
		var last := -1.0
		for t in tg:
			assert_true(float(t.t) > last)
			last = float(t.t)
		assert_true(last < Shanties.length(s, 0.55))

func test_judge_and_easy_is_kinder() -> void:
	var hard := Shanties.beat(false)
	var easy := Shanties.beat(true)
	assert_true(float(easy.window) > float(hard.window) and float(easy.interval) > float(hard.interval))
	assert_eq(Shanties.judge(0.01, 0.22), "perfect")
	assert_eq(Shanties.judge(-0.15, 0.22), "good")
	assert_eq(Shanties.judge(0.5, 0.22), "miss")

func test_a_press_goes_to_the_nearest_waiting_pull() -> void:
	var tg := [{"t": 1.0, "line": 0}, {"t": 1.5, "line": 0}]
	assert_eq(Shanties.target_for(tg, ["", ""], 1.4, 0.22), 1)
	assert_eq(Shanties.target_for(tg, ["", "perfect"], 1.4, 0.22), -1, "a judged pull cannot be pulled twice")
	assert_eq(Shanties.target_for(tg, ["", ""], 3.0, 0.22), -1, "nothing near")

func test_shanty_pay_is_once_a_day() -> void:
	var data := GameStateData.new()
	var s := Shanties.shanty("blow_the_man_down")
	var first := Shanties.finish(data, s, 7, 8)
	assert_true(first.first and first.tip > 0)
	var again := Shanties.finish(data, s, 8, 8)
	assert_false(again.first)
	assert_eq(again.tip, 0)
	assert_eq(Shanties.finish(GameStateData.new(), s, 2, 8).tip, 0, "a ragged song pays nothing")
	assert_true(TrainerStats.get_count(data, "pulls_sung") > 0)

func test_pubs_are_real_zones() -> void:
	for z in Shanties.cfg().pubs:
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % z), z)

func test_swing_quality_and_damage() -> void:
	assert_eq(Conkers.swing_quality(0.0, 1.0), "perfect")
	assert_eq(Conkers.swing_quality(-0.3, 1.0), "good")
	assert_eq(Conkers.swing_quality(0.9, 1.0), "miss")
	assert_eq(Conkers.swing_quality(0.3, 1.5), "good")
	assert_eq(Conkers.damage("perfect"), 2)
	assert_eq(Conkers.damage("good"), 1)
	assert_eq(Conkers.damage("miss"), 0)

func test_rival_skill_decides_how_often_it_lands() -> void:
	var rng := Rng.new(3)
	var lo := 0
	var hi := 0
	for i in 400:
		if Conkers.rival_swing(0.2, rng) != "miss":
			lo += 1
		if Conkers.rival_swing(0.8, rng) != "miss":
			hi += 1
	assert_true(hi > lo + 100)

func test_toughness_and_rungs() -> void:
	assert_true(Conkers.toughness(true, 0) > Conkers.toughness(false, 0))
	assert_true(Conkers.toughness(false, 2) > Conkers.toughness(false, 0))
	assert_eq(Conkers.ner_name(0), "")
	assert_eq(Conkers.ner_name(1), "oner")
	assert_eq(Conkers.ner_name(2), "twoer")

func test_only_autumn_is_conker_season() -> void:
	assert_true(Conkers.in_season("autumn"))
	for s in ["spring", "summer", "winter"]:
		assert_false(Conkers.in_season(s))

func test_pick_season_and_collect() -> void:
	var data := GameStateData.new()
	assert_true(Conkers.pick_up(data))
	assert_false(Conkers.pick_up(data), "one a day")
	assert_eq(Conkers.bag_count(data, Conkers.ITEM_FRESH), 1)
	assert_true(Conkers.start_cure(data))
	assert_eq(Conkers.bag_count(data, Conkers.ITEM_FRESH), 0)
	assert_false(Conkers.start_cure(data), "nothing left to cure")
	data.day_count = 1
	assert_false(Conkers.collect(data), "not ready yet")
	assert_true(Conkers.days_left(data) > 0)
	data.day_count += Conkers.season_days()
	assert_true(Conkers.collect(data))
	assert_eq(Conkers.bag_count(data, Conkers.ITEM_SEASONED), 1)
	assert_false(Conkers.curing(data))

func test_win_climbs_a_rung_and_loss_breaks_it() -> void:
	var data := GameStateData.new()
	var r := Conkers.rival("village")
	var a := Conkers.finish(data, r, true)
	assert_true(a.first)
	assert_eq(a.wins, 1)
	assert_true(a.prize > 0)
	var b := Conkers.finish(data, r, true)
	assert_eq(b.wins, 2)
	assert_eq(b.prize, 0, "prize once a day per rival")
	var c := Conkers.finish(data, r, false)
	assert_eq(c.wins, 0)
	assert_eq(int(data.flags.get(Conkers.FLAG_ONER, 0)), 0)
	assert_true(TrainerStats.get_count(data, "conkers_won") == 2)

func test_conker_items_exist() -> void:
	var items := ItemDB.load_default()
	assert_false(items.get_item(Conkers.ITEM_FRESH).is_empty())
	assert_false(items.get_item(Conkers.ITEM_SEASONED).is_empty())
