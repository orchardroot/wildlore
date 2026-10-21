extends TestCase
## Highland games, hurling and shinty: the caber's clock, the tug's rope, shots at goal, and the pay.

func test_every_event_has_rules_and_a_plaque() -> void:
	for id in Games.EVENTS:
		var e := Games.event(id)
		assert_true(not e.is_empty(), id)
		assert_true(str(e.rules).length() > 40 and not ("—" in str(e.rules)), "%s rules" % id)
		assert_true(e.has("plaque") and e.has("won") and int(e.prize) > 0, "%s plaque and prize" % id)

func test_caber_sweet_spot_is_twelve_o_clock() -> void:
	assert_eq(Games.caber_offset(Games.CABER_SWEET, false), 0)
	assert_eq(Games.caber_points(0), 12)
	assert_eq(Games.caber_offset(1.0, false), 6, "held to the end is a drop")
	assert_true(Games.caber_offset(0.2, false) > Games.caber_offset(0.6, false), "softer is further off")
	assert_true(Games.caber_offset(0.7, true) <= Games.caber_offset(0.7, false), "easier is more forgiving")
	assert_eq(Games.caber_points(6), 0)

func test_caber_target_is_reachable_but_not_free() -> void:
	var e := Games.event("caber")
	assert_true(int(e.target) <= int(e.tosses) * 12, "can be won")
	assert_true(int(e.target) > 0)

func test_tug_stronger_creature_pulls_harder_and_the_rope_clamps() -> void:
	assert_true(Games.tug_pull(150) > Games.tug_pull(50))
	assert_eq(Games.tug_step(-0.99, 10.0, false), -1.0)
	assert_eq(Games.tug_tap(0.99, 150, 1.0), 1.0)
	assert_eq(Games.tug_judge(0.0, false), 1.0)
	assert_eq(Games.tug_judge(0.5, false), 0.0)
	# perfect tapping out-pulls the drag even for a middling creature, so the game is winnable
	assert_true(Games.tug_pull(60) / Games.TUG_BEAT > Games.tug_drag(false))

func test_shots_hurling_scores_goals_and_points_shinty_only_goals() -> void:
	assert_eq(Games.shot(Vector2(0.9, 0.3), 0, "hurling").pts, 3, "goal under the bar")
	assert_eq(Games.shot(Vector2(0.0, 1.3), 1, "hurling").pts, 1, "point over the bar")
	assert_eq(Games.shot(Vector2(0.0, 1.3), 1, "shinty").pts, 0, "no points in shinty")
	assert_eq(Games.shot(Vector2(0.0, 1.3), 1, "shinty").kind, "over")
	assert_eq(Games.shot(Vector2(0.0, 0.3), 1, "hurling").kind, "saved")
	assert_eq(Games.shot(Vector2(1.3, 0.3), 1, "shinty").kind, "wide")
	assert_eq(Games.shot(Vector2(-0.9, 0.5), 2, "shinty").pts, 1)

func test_keeper_leans_honestly_when_easy_more_than_hard() -> void:
	var rng := Rng.new(7)
	var honest := [0, 0]
	for k in 400:
		for m in 2:
			var kp := Games.keeper(rng, m == 1)
			if kp.lean == kp.zone:
				honest[m] += 1
	assert_true(honest[1] > honest[0], "easy tells the truth more")
	assert_true(honest[0] > 150, "and hard still isn't all lies")

func test_win_pays_once_a_day_and_first_win_gives_standing_and_plaque_money() -> void:
	var d := GameStateData.new()
	var a := Games.win(d, "shinty", "fort_william")
	assert_true(a.first)
	assert_eq(a.prize, int(Games.event("shinty").first_prize))
	var b := Games.win(d, "shinty", "fort_william")
	assert_true(not b.first)
	assert_eq(b.prize, 0, "no second prize the same day")
	assert_eq(TrainerStats.get_count(d, "games_won"), 2)
	assert_true(Standing.points(d, "scotland") > 0)

func test_lead_atk_defaults_without_a_creature() -> void:
	assert_eq(Games.lead_atk(GameStateData.new()), Games.NO_LEAD_ATK)
