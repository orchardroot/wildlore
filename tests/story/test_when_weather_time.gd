extends TestCase
## `when` conditions for weather and time of day, so townsfolk can remark on the rain or the dusk.

## A host that knows the overworld's weather (the real ScriptRunner host does).
class SkyHost extends FakeStoryHost:
	var sky := "clear"
	func current_weather() -> String:
		return sky

func _said(h: FakeStoryHost, cond: String) -> bool:
	await Commands.new(h).run([{"do": "when", "cond": cond, "then": [{"do": "say", "text": "yes"}], "else": [{"do": "say", "text": "no"}]}])
	return h.texts() == ["yes"]

func _sky(w: String, clock := 600) -> SkyHost:
	var h := SkyHost.new()
	h.sky = w
	h.data.clock_minutes = clock
	return h

func test_rain_is_drizzle_or_downpour() -> void:
	assert_true(await _said(_sky("drizzle"), "rain"))
	assert_true(await _said(_sky("downpour"), "rain"))
	assert_false(await _said(_sky("fog"), "rain"))
	assert_false(await _said(_sky("clear"), "rain"))

func test_each_weather_matches_only_itself() -> void:
	for w in ["fog", "gale", "frost", "sunshine"]:
		assert_true(await _said(_sky(w), w), w)
		assert_false(await _said(_sky("clear"), w), w + " on a clear day")
	assert_false(await _said(_sky("gale"), "fog"))

func test_time_phases_follow_the_clock() -> void:
	assert_true(await _said(_sky("clear", 6 * 60), "dawn"))
	assert_true(await _said(_sky("clear", 12 * 60), "day"))
	assert_true(await _said(_sky("clear", 19 * 60), "dusk"))
	assert_true(await _said(_sky("clear", 23 * 60), "night"))
	assert_true(await _said(_sky("clear", 2 * 60), "night"))
	assert_false(await _said(_sky("clear", 12 * 60), "dusk"))
	assert_false(await _said(_sky("clear", 19 * 60), "night"))

func test_without_a_sky_the_saved_outdoor_weather_counts() -> void:
	# indoors (and in tests) the weather is the inherited outdoor weather from the save
	var h := FakeStoryHost.new()
	h.data.weather = "downpour"
	assert_true(await _said(h, "rain"))
	var h2 := FakeStoryHost.new()
	assert_false(await _said(h2, "rain"), "no weather rolled yet is clear")
	assert_false(await _said(h2, "sunshine"))

func test_validator_knows_the_new_conditions() -> void:
	for cond in ["rain", "fog", "gale", "frost", "sunshine", "dawn", "day", "dusk", "night"]:
		var errs := StoryValidator.validate_commands([{"do": "when", "cond": cond, "then": [{"do": "say", "text": "x"}]}], "t", Fixtures.dex(), ItemDB.load_default(), {})
		assert_eq(errs, [], cond)
	var bad := StoryValidator.validate_commands([{"do": "when", "cond": "hail"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(bad.size(), 1)
