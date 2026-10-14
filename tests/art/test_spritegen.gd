extends TestCase
## Sprite generator: sizes, outline, transparency, determinism, and that every recipe has its PNGs.

const Creature = preload("res://tools/spritegen/creature.gd")
const Character = preload("res://tools/spritegen/character.gd")

const TINY := {
	"id": "tiny",
	"palette": {"c": "#c08040"},
	"layers": [{"shape": "ellipse", "at": [48, 60], "size": [40, 30], "colour": "c"}],
	"eyes": [{"at": [40, 56], "r": 3}],
}

const TINY_CHAR := {
	"id": "tiny_char", "build": "adult",
	"palette": {"skin": "#f0c8a0", "hair": "#4a3426", "top": "#5a7ab8", "bottom": "#4a4a5a", "shoes": "#3a2a24"},
	"hair": "short", "accessories": [],
}

func _luma(c: Color) -> float:
	return c.r * 0.3 + c.g * 0.59 + c.b * 0.11

func _recipe_ids(dir_path: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out

func test_creature_sizes() -> void:
	var r := Creature.render(TINY)
	assert_eq(r.front.get_size(), Vector2i(192, 96), "front size")
	assert_eq(r.back.get_size(), Vector2i(192, 96), "back size")
	assert_eq(r.icon.get_size(), Vector2i(32, 32), "icon size")

func test_transparent_background() -> void:
	var r := Creature.render(TINY)
	for img in [r.front, r.back]:
		assert_near(img.get_pixel(0, 0).a, 0.0, 0.001, "corner a")
		assert_near(img.get_pixel(95, 95).a, 0.0, 0.001, "corner b")
		assert_near(img.get_pixel(96, 0).a, 0.0, 0.001, "second frame corner")
	assert_near(r.icon.get_pixel(0, 0).a, 0.0, 0.001, "icon corner")
	assert_near(r.front.get_pixel(48, 60).a, 1.0, 0.001, "body is opaque")

func test_outline_at_silhouette_edge() -> void:
	var r := Creature.render(TINY)
	var img: Image = r.front
	# the ellipse spans x 28..67 on row 60, so the outline sits at x 27
	var outline := img.get_pixel(27, 60)
	var edge := img.get_pixel(28, 60)
	assert_near(outline.a, 1.0, 0.001, "outline pixel present")
	assert_near(img.get_pixel(25, 60).a, 0.0, 0.001, "nothing beyond the outline")
	assert_true(_luma(outline) < _luma(edge), "outline is darker than the body edge")
	assert_near(img.get_pixel(48, 44).a, 1.0, 0.001, "top outline row")

func test_second_frame_differs_by_a_bob() -> void:
	var r := Creature.render(TINY)
	var a: Image = r.front.get_region(Rect2i(0, 0, 96, 96))
	var b: Image = r.front.get_region(Rect2i(96, 0, 96, 96))
	assert_true(a.get_data() != b.get_data(), "frames differ")

func test_creature_deterministic() -> void:
	var a := Creature.render(TINY)
	var b := Creature.render(TINY)
	assert_true(a.front.get_data() == b.front.get_data(), "front bytes")
	assert_true(a.back.get_data() == b.back.get_data(), "back bytes")
	assert_true(a.icon.get_data() == b.icon.get_data(), "icon bytes")

func test_character_sheet() -> void:
	var a := Character.render(TINY_CHAR)
	var b := Character.render(TINY_CHAR)
	assert_eq(a.get_size(), Vector2i(96, 192), "sheet size")
	assert_true(a.get_data() == b.get_data(), "character deterministic")
	for row in 4:
		for col in 3:
			var frame := a.get_region(Rect2i(col * 32, row * 48, 32, 48))
			var opaque := 0
			for y in 48:
				for x in 32:
					if frame.get_pixel(x, y).a > 0.0:
						opaque += 1
			assert_true(opaque > 200, "frame %d,%d has a figure" % [col, row])
			assert_near(frame.get_pixel(0, 0).a, 0.0, 0.001, "frame corner transparent")

func test_every_recipe_has_sprites() -> void:
	var creatures := _recipe_ids("res://art/recipes/creatures")
	assert_true(creatures.size() >= 20, "at least 20 creature recipes")
	for id in creatures:
		for suffix in ["front", "back"]:
			var img := Image.load_from_file(ProjectSettings.globalize_path("res://art/sprites/creatures/%s_%s.png" % [id, suffix]))
			assert_true(img != null and img.get_size() == Vector2i(192, 96), "%s_%s.png is 192x96" % [id, suffix])
		var icon := Image.load_from_file(ProjectSettings.globalize_path("res://art/sprites/creatures/%s_icon.png" % id))
		assert_true(icon != null and icon.get_size() == Vector2i(32, 32), "%s_icon.png is 32x32" % id)
	for id in _recipe_ids("res://art/recipes/chars"):
		var img := Image.load_from_file(ProjectSettings.globalize_path("res://art/sprites/chars/%s.png" % id))
		assert_true(img != null and img.get_size() == Vector2i(96, 192), "%s.png is 96x192" % id)

func test_placeholders_exist() -> void:
	for p in ["res://art/sprites/creatures/_placeholder_front.png", "res://art/sprites/creatures/_placeholder_back.png", "res://art/sprites/creatures/_placeholder_icon.png", "res://art/sprites/chars/_placeholder.png"]:
		assert_true(FileAccess.file_exists(p), p)
