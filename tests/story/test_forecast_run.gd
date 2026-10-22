extends TestCase
## The `forecast` story command (ForecastRun): the forecaster explains a chart once, opens the challenge, sets the
## quest flag on a pass, pays the day's sweepstake once, and takes a walk-out or a "not now" gracefully.

func _host(result: Variant, choice := 0) -> FakeStoryHost:
	var h := FakeStoryHost.new()
	DailyKey.begin_session(h.data)
	h.choices = [choice]
	h.menu_results = {"forecasting:clear": result}
	return h

func _run(h: FakeStoryHost) -> void:
	await Commands.new(h).run([{"do": "forecast", "who": "Bethan", "set": "q_landsky_chart"}])

func test_a_pass_sets_the_flag_and_pays_once() -> void:
	var h := _host({"score": 6, "total": 8, "today": true})
	var before := h.data.money
	await _run(h)
	assert_true(h.log.has(["menu", "forecasting:clear"]), "the challenge opened with today's weather")
	assert_eq(h.data.flag("q_landsky_chart"), true)
	assert_eq(h.data.flag(ForecastRun.FLAG_EXPLAINED), true)
	assert_eq(h.data.flag(Forecasting.FLAG_MET), true)
	assert_eq(Forecasting.passes(h.data), 1)
	assert_eq(h.data.money, before + 300, "the sweepstake")
	assert_true(h.texts().any(func(t): return t.begins_with("6 out of 8.")))
	assert_true(h.texts().any(func(t): return t.contains("called today's chart right")))
	var explained := h.said.filter(func(s): return str(s[1]).contains("Buys Ballot")).size()
	assert_eq(explained, 1, "the lesson, once")
	# the same day again: no second prize, and no second lesson
	h.choices = [0]
	var said_before := h.said.size()
	await _run(h)
	assert_eq(h.data.money, before + 300)
	assert_true(h.texts().slice(said_before).any(func(t): return t.contains("paid out for today")))
	assert_false(h.texts().slice(said_before).any(func(t): return t.contains("Buys Ballot")))
	assert_eq(Forecasting.passes(h.data), 2)

func test_full_marks_pay_more() -> void:
	var h := _host({"score": 8, "total": 8, "today": true})
	var before := h.data.money
	await _run(h)
	assert_eq(h.data.money, before + 600)

func test_a_fail_sets_nothing() -> void:
	var h := _host({"score": 3, "total": 8, "today": false})
	var before := h.data.money
	await _run(h)
	assert_eq(h.data.flag("q_landsky_chart"), null)
	assert_eq(h.data.money, before)
	assert_eq(Forecasting.passes(h.data), 0)
	assert_eq(Forecasting.best(h.data), 3)
	assert_eq(h.data.flag(Forecasting.FLAG_MET), true, "a finished round still counts for Land and Sky")

func test_walking_out_or_declining() -> void:
	var h := _host(null)
	await _run(h)
	assert_eq(h.data.flag("q_landsky_chart"), null)
	assert_true(h.texts().any(func(t): return t.contains("Walked out")))
	var h2 := _host({"score": 8, "total": 8, "today": true}, 1)
	await _run(h2)
	assert_false(h2.log.has(["menu", "forecasting:clear"]), "not now means no round")
	assert_eq(h2.data.flag("q_landsky_chart"), null)

func test_validator_knows_the_command() -> void:
	var errs := StoryValidator.validate_commands([{"do": "forecast", "who": "Bethan", "set": "q_x"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(errs, [])
