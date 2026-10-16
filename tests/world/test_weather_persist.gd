extends TestCase
## Weather lasts WEATHER_MIN to WEATHER_MAX in-game minutes and follows the player between zones of the same region.

const TABLE := {"drizzle": 1, "fog": 1}

func _rng(f := 0.0) -> FixedRng:
	var r := FixedRng.new()
	r.f = f
	return r

func _state(clock := 600, day := 0) -> GameStateData:
	var s := GameStateData.new()
	s.clock_minutes = clock
	s.day_count = day
	return s

func test_first_outdoor_zone_rolls_and_remembers() -> void:
	var s := _state()
	assert_eq(s.weather_for("cheshire", TABLE, false, _rng(0.0)), "drizzle")
	assert_eq(s.weather, "drizzle")
	assert_eq(s.weather_region, "cheshire")
	assert_eq(s.weather_until, 600 + GameStateData.WEATHER_MIN, "lasts the shortest spell on a low roll")

func test_expiry_roll_is_between_the_spell_bounds() -> void:
	var s := _state()
	var r := _rng(0.0)
	r.hi = true
	s.weather_for("cheshire", TABLE, false, r)
	assert_eq(s.weather_until, 600 + GameStateData.WEATHER_MAX)

func test_same_region_keeps_the_weather_until_it_expires() -> void:
	var s := _state()
	s.weather_for("cheshire", TABLE, false, _rng(0.0))
	s.clock_minutes += GameStateData.WEATHER_MIN - 1
	assert_eq(s.weather_for("cheshire", TABLE, false, _rng(0.99)), "drizzle", "not re-rolled zone to zone")
	assert_false(s.weather_expired())
	s.clock_minutes += 1
	assert_true(s.weather_expired())
	assert_eq(s.weather_for("cheshire", TABLE, false, _rng(0.99)), "fog", "re-rolled once it has run out")
	assert_eq(s.weather_until, 600 + 2 * GameStateData.WEATHER_MIN)

func test_changing_region_rerolls() -> void:
	var s := _state()
	s.weather_for("cheshire", TABLE, false, _rng(0.0))
	assert_eq(s.weather_for("peak", TABLE, false, _rng(0.99)), "fog")
	assert_eq(s.weather_region, "peak")

func test_interiors_inherit_the_outdoor_weather() -> void:
	var s := _state()
	assert_eq(s.weather_for("", {}, true, _rng(0.0)), "clear", "nothing rolled yet: clear")
	s.weather_for("cheshire", TABLE, false, _rng(0.0))
	s.clock_minutes += 100
	assert_eq(s.weather_for("", {}, true, _rng(0.99)), "drizzle", "an interior never re-rolls, even when expired")
	assert_eq(s.weather_region, "cheshire")

func test_zone_without_that_weather_shows_its_own_but_keeps_the_regions() -> void:
	var s := _state()
	s.weather_for("scotland", {"downpour": 1}, false, _rng(0.0))
	assert_eq(s.weather_for("scotland", {"clear": 1}, false, _rng(0.0)), "clear", "a hill that never rains")
	assert_eq(s.weather, "downpour", "elsewhere in the region it is still pouring")
	assert_eq(s.weather_for("scotland", {}, false, _rng(0.0)), "clear", "no table: clear")

func test_expiry_counts_across_midnight() -> void:
	var s := _state(1430, 0)
	s.weather_for("cheshire", TABLE, false, _rng(0.0))
	var end := 1430 + GameStateData.WEATHER_MIN - 1440   # minutes after midnight when the spell ends
	s.clock_minutes = end - 1
	s.day_count = 1
	assert_false(s.weather_expired(), "still going just after midnight")
	s.clock_minutes = end
	assert_true(s.weather_expired())

func test_weather_round_trips_and_old_saves_default() -> void:
	var s := _state()
	s.weather_for("cheshire", TABLE, false, _rng(0.0))
	var back := GameStateData.from_dict(JSON.parse_string(JSON.stringify(s.to_dict())), Fixtures.dex())
	assert_eq(back.weather, "drizzle")
	assert_eq(back.weather_region, "cheshire")
	assert_eq(back.weather_until, 600 + GameStateData.WEATHER_MIN)
	var old := GameStateData.from_dict({"zone_id": "buxton"}, Fixtures.dex())
	assert_eq(old.weather, "")
	assert_eq(old.weather_until, 0)
	old.clock_minutes = 600
	assert_eq(old.weather_for("peak", TABLE, false, _rng(0.0)), "drizzle", "an old save rolls fresh weather")
