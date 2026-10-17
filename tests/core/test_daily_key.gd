extends TestCase
## Real-date dailies (DailyKey): once per real day, with a marathon fallback, and old in-game-day flags count as "not today".

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 3
	d.play_seconds = 100.0
	DailyKey.begin_session(d)
	return d

func test_a_stamp_is_today_until_the_real_date_changes() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	assert_false(DailyKey.done_today(d, "rematch_kit"))
	d.set_flag("rematch_kit", DailyKey.stamp(d))
	assert_true(DailyKey.done_today(d, "rematch_kit"))
	d.day_count += 5  # in-game days no longer reset it
	d.play_seconds += 3600.0
	assert_true(DailyKey.done_today(d, "rematch_kit"), "farming in-game days does nothing")
	Calendar.set_override("2026-10-18")
	assert_false(DailyKey.done_today(d, "rematch_kit"), "a new real day")
	Calendar.set_override("")

func test_old_in_game_day_flags_count_as_not_today() -> void:
	var d := _data()
	d.set_flag("rematch_kit", 3)  # a 1.4 save: the in-game day it was fought
	assert_false(DailyKey.done_today(d, "rematch_kit"))
	d.set_flag("quiz_day_york", 0)
	assert_false(DailyKey.done_today(d, "quiz_day_york"))
	assert_false(DailyKey.is_today(d, true))
	assert_false(DailyKey.is_today(d, null))

func test_marathon_sessions_get_an_in_game_day_reset_after_four_hours() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	d.set_flag("rematch_kit", DailyKey.stamp(d))
	d.play_seconds += DailyKey.MARATHON_SECONDS - 10.0
	d.day_count += 1
	assert_true(DailyKey.done_today(d, "rematch_kit"), "not four hours yet")
	d.play_seconds += 20.0
	assert_false(DailyKey.done_today(d, "rematch_kit"), "four hours on and a new in-game day")
	d.set_flag("rematch_kit", DailyKey.stamp(d))
	d.play_seconds += DailyKey.MARATHON_SECONDS + 1.0
	assert_true(DailyKey.done_today(d, "rematch_kit"), "four hours but the same in-game day")
	Calendar.set_override("")

func test_the_marathon_fallback_needs_a_single_session() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	d.set_flag("rematch_kit", DailyKey.stamp(d))
	# save, quit, reload: a fresh data object is a fresh session
	var again := GameStateData.from_dict(d.to_dict(), Fixtures.dex())
	again.play_seconds += DailyKey.MARATHON_SECONDS + 60.0
	again.day_count += 1
	DailyKey.begin_session(again)
	assert_true(DailyKey.done_today(again, "rematch_kit"), "hours spread over sessions don't add up")
	Calendar.set_override("")

func test_stamps_survive_a_save() -> void:
	Calendar.set_override("2026-10-17")
	var d := _data()
	d.set_flag("quiz_day_york", DailyKey.stamp(d))
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(d.to_dict())), Fixtures.dex())
	assert_true(DailyKey.done_today(back, "quiz_day_york"))
	Calendar.set_override("")
