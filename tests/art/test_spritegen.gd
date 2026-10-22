extends TestCase
## Sprite generator: sizes, outline, transparency, determinism, and that every recipe has its PNGs.

const Creature = preload("res://tools/spritegen/creature.gd")
const Character = preload("res://tools/spritegen/character.gd")
const K := Creature.SCALE   # sheet pixels per art unit: coordinates below are art units times K
const FP := 96 * K          # one frame, in pixels

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
	assert_eq(r.front.get_size(), Vector2i(FP * 2, FP), "front size")
	assert_eq(r.back.get_size(), Vector2i(FP * 2, FP), "back size")
	assert_eq(r.icon.get_size(), Vector2i(32, 32), "icon size")

func test_transparent_background() -> void:
	var r := Creature.render(TINY)
	for img in [r.front, r.back]:
		assert_near(img.get_pixel(0, 0).a, 0.0, 0.001, "corner a")
		assert_near(img.get_pixel(FP - 1, FP - 1).a, 0.0, 0.001, "corner b")
		assert_near(img.get_pixel(FP, 0).a, 0.0, 0.001, "second frame corner")
	assert_near(r.icon.get_pixel(0, 0).a, 0.0, 0.001, "icon corner")
	assert_near(r.front.get_pixel(48 * K, 60 * K).a, 1.0, 0.001, "body is opaque")

func test_outline_at_silhouette_edge() -> void:
	var r := Creature.render(TINY)
	var img: Image = r.front
	# the ellipse spans art x 28..68 on row 60, so the outline sits in art unit 27
	var outline := img.get_pixel(27 * K + K / 2, 60 * K)
	var edge := img.get_pixel(29 * K, 60 * K)
	assert_true(outline.a > 0.9, "outline pixel present")
	assert_near(img.get_pixel(25 * K, 60 * K).a, 0.0, 0.001, "nothing beyond the outline")
	assert_true(_luma(outline) < _luma(edge), "outline is darker than the body edge")
	assert_true(img.get_pixel(48 * K, 44 * K + K / 2).a > 0.9, "top outline row")

func test_second_frame_differs_by_a_bob() -> void:
	var r := Creature.render(TINY)
	var a: Image = r.front.get_region(Rect2i(0, 0, FP, FP))
	var b: Image = r.front.get_region(Rect2i(FP, 0, FP, FP))
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
			assert_true(img != null and img.get_size() == Vector2i(FP * 2, FP), "%s_%s.png is %dx%d" % [id, suffix, FP * 2, FP])
		var icon := Image.load_from_file(ProjectSettings.globalize_path("res://art/sprites/creatures/%s_icon.png" % id))
		assert_true(icon != null and icon.get_size() == Vector2i(32, 32), "%s_icon.png is 32x32" % id)
	for id in _recipe_ids("res://art/recipes/chars"):
		var img := Image.load_from_file(ProjectSettings.globalize_path("res://art/sprites/chars/%s.png" % id))
		assert_true(img != null and img.get_size() == Vector2i(96, 192), "%s.png is 96x192" % id)

func test_placeholders_exist() -> void:
	for p in ["res://art/sprites/creatures/_placeholder_front.png", "res://art/sprites/creatures/_placeholder_back.png", "res://art/sprites/creatures/_placeholder_icon.png", "res://art/sprites/chars/_placeholder.png"]:
		assert_true(FileAccess.file_exists(p), p)

# ---------- back views ----------

const TAILED := {
	"id": "tailed",
	"palette": {"c": "#c08040", "tail": "#3060c0"},
	"layers": [
		{"shape": "ellipse", "at": [76, 60], "size": [14, 30], "colour": "tail"},
		{"shape": "ellipse", "at": [48, 60], "size": [44, 40], "colour": "c"},
	],
}

func _region_has(img: Image, rect: Rect2i, pred: Callable) -> bool:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if pred.call(img.get_pixel(x, y)):
				return true
	return false

func _is_blue(c: Color) -> bool:
	return c.a > 0.0 and c.b > c.r + 0.15

func test_back_keeps_the_front_palette() -> void:
	var rec: Dictionary = TINY.duplicate(true)
	rec["back_auto"] = false
	var r := Creature.render(rec)
	var f: Color = r.front.get_pixel(48 * K, 64 * K)
	var b: Color = r.back.get_pixel(48 * K, 64 * K)
	assert_true(absf(_luma(f) - _luma(b)) < 0.06, "back body is not a dark silhouette (%.3f vs %.3f)" % [_luma(f), _luma(b)])

func test_back_gets_a_darker_saddle() -> void:
	var r := Creature.render(TINY)
	var f: Color = r.front.get_pixel(48 * K, 58 * K)
	var b: Color = r.back.get_pixel(48 * K, 58 * K)
	assert_true(_luma(b) < _luma(f) - 0.05, "countershaded back (%.3f vs %.3f)" % [_luma(f), _luma(b)])

func test_tail_behind_the_body_comes_forward_on_the_back() -> void:
	var r := Creature.render(TAILED)
	# front: the tail hides behind the body on the right, so none of it is inside the body
	assert_false(_region_has(r.front, Rect2i(56 * K, 50 * K, 10 * K, 20 * K), _is_blue), "front tail behind body")
	# back: seen from behind it swaps sides and sits over the body
	assert_true(_region_has(r.back, Rect2i(26 * K, 50 * K, 14 * K, 20 * K), _is_blue), "back tail over the body, on the other side")
	assert_false(_region_has(r.back, Rect2i(70 * K, 40 * K, 20 * K, 40 * K), _is_blue), "back tail not left on the front-view side")

func test_back_over_can_be_turned_off() -> void:
	var rec: Dictionary = TAILED.duplicate(true)
	rec["back_over"] = []
	var r := Creature.render(rec)
	assert_false(_region_has(r.back, Rect2i(34 * K, 50 * K, 28 * K, 20 * K), _is_blue), "explicit empty back_over keeps the tail behind")

func test_back_hide_drops_a_layer_even_with_json_float_indices() -> void:
	var rec: Dictionary = JSON.parse_string(JSON.stringify(TAILED))
	rec["back_hide"] = JSON.parse_string("[0]")
	var r := Creature.render(rec)
	assert_false(_region_has(r.back, Rect2i(0, 0, FP, FP), _is_blue), "hidden tail is gone from the back")
	assert_true(_region_has(r.front, Rect2i(0, 0, FP, FP), _is_blue), "front keeps it")

func test_back_marks_draw_over_the_body() -> void:
	var rec: Dictionary = TINY.duplicate(true)
	rec["palette"]["m"] = "#202020"
	rec["back_marks"] = [{"shape": "rect", "at": [48, 60], "size": [4, 20], "colour": "m", "shade": false}]
	var r := Creature.render(rec)
	assert_true(_luma(r.back.get_pixel(48 * K, 60 * K)) < 0.2, "mark on the back")
	assert_true(_luma(r.front.get_pixel(48 * K, 60 * K)) > 0.3, "mark not on the front")

func test_coats_recolour_back_sheets() -> void:
	var r := Creature.render(TINY)
	var img: Image = r.back.duplicate()
	CoatArt.recolour(img, "winter")
	assert_true(img.get_pixel(48 * K, 64 * K) != r.back.get_pixel(48 * K, 64 * K), "coat applies to the back sheet")
	assert_near(img.get_pixel(0, 0).a, 0.0, 0.001, "coat keeps transparency")
