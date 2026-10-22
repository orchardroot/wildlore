extends TestCase

func test_placeholder_is_two_frames() -> void:
	var img := CreatureArt.placeholder_image("hearth", false)
	assert_eq(img.get_width(), 192)
	assert_eq(img.get_height(), 96)
	assert_true(img.get_pixel(48, 60).a > 0.9, "body drawn in frame 1")
	assert_true(img.get_pixel(96 + 48, 60).a > 0.9, "body drawn in frame 2")
	assert_true(img.get_pixel(2, 2).a < 0.1, "corners transparent")

func test_missing_species_art_never_fails() -> void:
	var sp := {"id": "no_such_creature_xyz", "sprite": "no_such_creature_xyz", "types": ["brook"]}
	var t := CreatureArt.texture(sp, true)
	assert_true(t != null)
	assert_eq(t.get_width(), t.get_height() * 2, "two square frames")
	assert_true(CreatureArt.icon(sp) != null)
