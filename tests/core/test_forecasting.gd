extends TestCase
## The forecaster's chart challenge (Forecasting): Buys Ballot's law for the wind, the rules for the sky, the data
## agreeing with both, rounds with no repeats, questions with the answer among four options, and the once-a-day prize.

## The Shipping Forecast synopses the game's radio reads (world/forecast.gd), which today's charts must match.
const RADIO := {
	"clear": ["high", "Biscay", 1024], "sunshine": ["high", "Fair Isle", 1032], "drizzle": ["low", "Shannon", 1002],
	"downpour": ["low", "Rockall", 990], "fog": ["high", "Dogger", 1026], "gale": ["low", "Hebrides", 976], "frost": ["high", "Scandinavia", 1036],
}

func test_buys_ballot_round_a_low() -> void:
	# anticlockwise: back to the wind, the low is on your left
	assert_eq(Forecasting.wind_for("low", "north-west"), "south-westerly")
	assert_eq(Forecasting.wind_for("low", "north"), "westerly")
	assert_eq(Forecasting.wind_for("low", "west"), "southerly")
	assert_eq(Forecasting.wind_for("low", "south"), "easterly")
	assert_eq(Forecasting.wind_for("low", "east"), "northerly")
	assert_eq(Forecasting.wind_for("low", "north-east"), "north-westerly")
	assert_eq(Forecasting.wind_for("low", "south-west"), "south-easterly")
	assert_eq(Forecasting.wind_for("low", "south-east"), "north-easterly")

func test_buys_ballot_round_a_high() -> void:
	# clockwise: a Scandinavian high sends an easterly, the Azores high a north-westerly
	assert_eq(Forecasting.wind_for("high", "north"), "easterly")
	assert_eq(Forecasting.wind_for("high", "south-west"), "north-westerly")
	assert_eq(Forecasting.wind_for("high", "east"), "southerly")
	assert_eq(Forecasting.wind_for("high", "west"), "northerly")
	assert_eq(Forecasting.wind_for("high", "south"), "westerly")

func test_over_britain_is_light_and_variable() -> void:
	assert_eq(Forecasting.wind_for("high", "over"), Forecasting.LIGHT)
	assert_eq(Forecasting.wind_for("low", "nowhere"), Forecasting.LIGHT)
	assert_eq(Forecasting.wind_line({"centre": "high", "bearing": "over"}), "light and variable, force 1 to 3")
	assert_eq(Forecasting.wind_line({"centre": "low", "bearing": "north-west", "spacing": "tight"}), "south-westerly, force 7 to 9, gale")

func test_the_sky_rules() -> void:
	assert_eq(Forecasting.rule_weather({"centre": "low", "spacing": "tight", "front": "warm"}), "gale", "tight isobars blow a gale whatever the front")
	assert_eq(Forecasting.rule_weather({"centre": "low", "spacing": "moderate", "front": "cold"}), "downpour")
	assert_eq(Forecasting.rule_weather({"centre": "low", "spacing": "moderate", "front": "warm"}), "drizzle")
	assert_eq(Forecasting.rule_weather({"centre": "low", "spacing": "loose", "front": "none"}), "drizzle", "grey and damp under a low")
	assert_eq(Forecasting.rule_weather({"centre": "high", "air": "moist", "season": "winter"}), "fog", "damp air under a high fogs before it frosts")
	assert_eq(Forecasting.rule_weather({"centre": "high", "air": "dry", "season": "winter"}), "frost")
	assert_eq(Forecasting.rule_weather({"centre": "high", "air": "dry", "season": "summer"}), "sunshine")
	assert_eq(Forecasting.rule_weather({"centre": "high", "air": "dry", "season": "spring"}), "clear")

func test_data_agrees_with_the_rules() -> void:
	assert_eq(Forecasting.check(), [])
	assert_true(Forecasting.charts().size() >= 8, "a decent pool of practice charts")
	for c in Forecasting.charts():
		assert_eq(str(c.weather), Forecasting.rule_weather(c), str(c.id))

func test_today_charts_match_the_radio_synopses() -> void:
	for w in RADIO:
		var t := Forecasting.today(w)
		assert_eq(str(t.get("centre", "")), RADIO[w][0], w)
		assert_true(str(t.get("place", "")).contains(RADIO[w][1]), w + " place")
		assert_eq(int(t.get("pressure", 0)), RADIO[w][2], w + " pressure")
		assert_eq(str(t.get("weather", "")), w)
	assert_eq(str(Forecasting.today("hail").get("weather", "")), "clear", "an unknown weather reads as clear")
	assert_eq(Forecasting.synopsis(Forecasting.today("gale")), "Low, the Hebrides, 976, deepening rapidly, expected Fair Isle 968 by midnight")

func test_rounds_have_no_repeats_and_both_kinds() -> void:
	for seed in range(1, 30):
		var r := Forecasting.pick_round(Rng.new(seed))
		assert_eq(r.size(), Forecasting.PRACTICE, "seed %d" % seed)
		var ids := {}
		var kinds := {}
		for c in r:
			ids[str(c.id)] = true
			kinds[str(c.centre)] = true
		assert_eq(ids.size(), Forecasting.PRACTICE, "seed %d repeats a chart" % seed)
		assert_eq(kinds.size(), 2, "seed %d is all one kind" % seed)

func test_questions_offer_four_options_with_the_answer() -> void:
	var c := Forecasting.chart("rockall_gale")
	var rng := Rng.new(3)
	var wq := Forecasting.wind_question(c, rng)
	assert_eq(wq.options.size(), 4)
	assert_eq(str(wq.options[wq.answer]), "south-westerly")
	assert_true(str(wq.why) != "")
	var sq := Forecasting.weather_question(c, rng)
	assert_eq(sq.options.size(), 4)
	assert_eq(str(sq.options[sq.answer]), "Gale", "the pretty name")
	var seen := {}
	for o in sq.options:
		seen[o] = true
	assert_eq(seen.size(), 4, "no option twice")

func test_a_round_ends_with_todays_chart() -> void:
	var r := Forecasting.build_round(Rng.new(5), "fog")
	assert_eq(r.size(), Forecasting.PRACTICE + 1)
	assert_false(bool(r[0].today))
	assert_true(bool(r.back().today))
	assert_eq(str(r.back().chart.weather), "fog")
	assert_eq(r.back().questions.size(), Forecasting.PER_CHART)
	assert_eq(Forecasting.total(), 8)
	assert_eq(Forecasting.pass_mark(), 5)
	assert_true(Forecasting.passed(5))
	assert_false(Forecasting.passed(4))

func test_record_keeps_best_and_passes() -> void:
	var d := GameStateData.new()
	var r := Forecasting.record(d, 3)
	assert_false(bool(r.passed))
	assert_eq(Forecasting.best(d), 3)
	assert_eq(Forecasting.passes(d), 0)
	assert_eq(d.flag(Forecasting.FLAG_MET), true, "a finished round counts for Land and Sky even when failed")
	r = Forecasting.record(d, 6)
	assert_true(bool(r.passed))
	assert_true(bool(r.first_pass))
	assert_eq(Forecasting.best(d), 6)
	assert_false(bool(Forecasting.record(d, 5).first_pass))
	assert_eq(Forecasting.passes(d), 2)
	assert_eq(Forecasting.best(d), 6, "a lower pass keeps the best")

func test_prize_once_a_day_and_more_for_full_marks() -> void:
	var d := GameStateData.new()
	DailyKey.begin_session(d)
	assert_eq(Forecasting.prize(d, 4, 8), 0, "no prize for a fail")
	assert_eq(Forecasting.prize(d, 8, 8), 600)
	assert_eq(Forecasting.prize(d, 8, 8), 0, "paid already today")
	var d2 := GameStateData.new()
	DailyKey.begin_session(d2)
	assert_eq(Forecasting.prize(d2, 5, 8), 300)

func test_player_text_has_no_em_dashes() -> void:
	for s in [0, 4, 5, 8]:
		assert_false("—" in Forecasting.reaction(s, 8))
	for c in Forecasting.charts():
		for k in ["title", "why_wind", "why_weather"]:
			assert_false("—" in str(c[k]), str(c.id))
