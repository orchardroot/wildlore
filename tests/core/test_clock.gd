extends TestCase

func test_clock_phases() -> void:
	assert_eq(GameClock.phase(5 * 60), "dawn")
	assert_eq(GameClock.phase(7 * 60 + 59), "dawn")
	assert_eq(GameClock.phase(8 * 60), "day")
	assert_eq(GameClock.phase(18 * 60), "dusk")
	assert_eq(GameClock.phase(21 * 60), "night")
	assert_eq(GameClock.phase(4 * 60 + 59), "night")
	assert_eq(GameClock.phase(0), "night")

func test_clock_text_and_wrap() -> void:
	assert_eq(GameClock.text(8 * 60 + 5), "08:05")
	assert_eq(GameClock.wrap(1440 + 30), 30)
	assert_eq(GameClock.parse("21:30"), 1290)
