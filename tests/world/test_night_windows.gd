extends TestCase
## Night windows: some are dark, some switch off late at night.

func test_lateness_ramps_through_the_night() -> void:
	assert_near(SkyAndLight.lateness(12 * 60), 0.0)
	assert_near(SkyAndLight.lateness(22 * 60), 0.0)
	assert_near(SkyAndLight.lateness(0), 0.5)
	assert_near(SkyAndLight.lateness(2 * 60), 1.0)
	assert_near(SkyAndLight.lateness(4 * 60 + 59), 1.0)
	assert_near(SkyAndLight.lateness(5 * 60), 0.0, 0.0001, "everyone is up at dawn")

func test_window_colours_vary() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var dark := 0
	var late := 0
	var lit := 0
	for i in 300:
		var c := Landmarks.window_colour(rng)
		assert_true(c.r >= 0.0 and c.r <= 1.0 and c.a > 0.0 and c.a <= 1.0)
		if c.r < 0.1:
			dark += 1
		elif c.a < 1.0:
			late += 1
		else:
			lit += 1
	assert_true(dark > 15 and dark < 90, "some windows stay dark (%d)" % dark)
	assert_true(late > 30, "some switch off late (%d)" % late)
	assert_true(lit > 100, "most burn all night (%d)" % lit)
