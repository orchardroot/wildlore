extends TestCase

func test_orbit_is_clamped() -> void:
	var o := PhotoMode.orbit_step(Vector2(0, 30), Vector2(100, 100), 1.0)
	assert_true(absf(o.x) <= PhotoMode.YAW_MAX)
	assert_true(o.y >= PhotoMode.PITCH_MIN and o.y <= PhotoMode.PITCH_MAX)

func test_zoom_is_clamped() -> void:
	assert_eq(PhotoMode.zoom_step(1.0, 100.0), PhotoMode.ZOOM_MAX)
	assert_eq(PhotoMode.zoom_step(1.0, -100.0), PhotoMode.ZOOM_MIN)

func test_photo_name_is_stamped() -> void:
	var n := PhotoMode.photo_name({"year": 2026, "month": 10, "day": 7, "hour": 9, "minute": 5, "second": 3})
	assert_eq(n, "wildlore_2026-10-07_09-05-03.png")

func test_photo_action_is_registered_with_a_free_key() -> void:
	assert_true("photo" in InputSetup.ACTIONS)
	var d := InputSetup.defaults()
	assert_true(d.photo.key.has(KEY_P))
	var seen := {}
	for a in InputSetup.ACTIONS:
		for c in d[a].key:
			assert_false(seen.has(c))
			seen[c] = true
		for c in d[a].pad:
			assert_false(seen.has(-c - 1000))
			seen[-c - 1000] = true
