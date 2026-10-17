extends TestCase

func test_old_save_defaults_to_zero() -> void:
	var back := GameStateData.from_dict({"player_name": "Sam", "money": 10}, Fixtures.dex())
	for k in TrainerStats.COUNTERS:
		assert_eq(TrainerStats.get_count(back, k), 0)
	assert_true(str(back.stats.get("started", "")).length() == 10)  # stamped with a date on first load

func test_round_trip() -> void:
	var s := GameStateData.new()
	TrainerStats.add(s, "steps", 42)
	TrainerStats.add(s, "wins_wild")
	TrainerStats.add(s, "rail_miles", 130)
	s.stats["started"] = "2026-10-01"
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())), Fixtures.dex())
	assert_eq(TrainerStats.get_count(back, "steps"), 42)
	assert_eq(typeof(back.stats.steps), TYPE_INT)
	assert_eq(TrainerStats.get_count(back, "wins_wild"), 1)
	assert_eq(TrainerStats.get_count(back, "rail_miles"), 130)
	assert_eq(back.stats.started, "2026-10-01")

func test_junk_stats_are_ignored() -> void:
	var back := GameStateData.from_dict({"stats": {"steps": "lots", "money_earned": -5, "bogus": 3, "started": 7}}, Fixtures.dex())
	assert_eq(TrainerStats.get_count(back, "steps"), 0)
	assert_eq(TrainerStats.get_count(back, "money_earned"), 0)
	assert_false(back.stats.has("bogus"))
	assert_true(str(back.stats.started).length() == 10)

func test_battle_wins_split_by_kind() -> void:
	var s := GameStateData.new()
	TrainerStats.record_battle(s, "wild", {"result": "win"})
	TrainerStats.record_battle(s, "trainer", {"result": "win"})
	TrainerStats.record_battle(s, "keeper", {"result": "win"})
	TrainerStats.record_battle(s, "wild", {"result": "lose"})
	TrainerStats.record_battle(s, "wild", {"result": "caught"})
	assert_eq(TrainerStats.get_count(s, "wins_wild"), 1)
	assert_eq(TrainerStats.get_count(s, "wins_trainer"), 2)

func test_earned_ignores_non_positive() -> void:
	var s := GameStateData.new()
	TrainerStats.earned(s, 250)
	TrainerStats.earned(s, 0)
	TrainerStats.earned(s, -40)
	assert_eq(TrainerStats.get_count(s, "money_earned"), 250)

func test_rail_miles_from_map() -> void:
	var m := TrainerStats.rail_miles("macclesfield", "york")
	assert_true(m > 20 and m < 200)
	assert_eq(TrainerStats.rail_miles("macclesfield", "nowhere"), 0)

func test_tea_counts_only_tea() -> void:
	var s := GameStateData.new()
	TrainerStats.note_item(s, "cup_of_tea")
	TrainerStats.note_item(s, "flask_of_tea")
	TrainerStats.note_item(s, "smelling_salts")
	assert_eq(TrainerStats.get_count(s, "teas"), 2)

func test_lines_have_labels_and_fun_rows() -> void:
	var s := GameStateData.new()
	TrainerStats.add(s, "teas", 3)
	var rows := TrainerStats.lines(s)
	var labels := rows.map(func(r): return r[0])
	assert_true(labels.has("Steps walked"))
	assert_true(labels.has("Cups of tea drunk"))
	assert_true(labels.has("Times rained on"))
