extends TestCase
## GeneArt (ui/gene_art.gd, tools/spritegen/blend.gd): blended hybrid sprites, roan and tortoiseshell, caching.

const Blend = preload("res://tools/spritegen/blend.gd")
const SpriteCreature = preload("res://tools/spritegen/creature.gd")

func before_each() -> void:
	GeneArt.clear_cache()
	Genetics._hybrids = {}

func after_each() -> void:
	Genetics._hybrids = {}
	GeneArt.clear_cache()

func _mk(species_id: String, genome := {}) -> Creature:
	var c := Fixtures.creature(species_id, 10)
	var g := {"coat": ["+", "+"], "tint": ["W", "W"], "mark": ["B", "b"], "knack": ["K", "K"], "ginger": ["o", "o"],
		"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"]}
	g.merge(genome, true)
	c.genome = g
	c.sex = "f"
	return c

func _hybrid(species_id := "moolet") -> Creature:
	Genetics._hybrids = {"test_x": {"id": "test_x", "sire_lines": ["coolet"], "dam_lines": ["moolet"],
		"sprite": {"body": "dam", "face": "sire", "palette": "mix"}}}
	var c := _mk(species_id)
	c.hybrid = "test_x"
	return c

func _opaque(img: Image) -> int:
	var n := 0
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a > 0.5:
				n += 1
	return n

func test_stock_look_is_the_stock_texture() -> void:
	var c := _mk("moolet")
	assert_true(GeneArt.look_of(c).stock)
	assert_eq(GeneArt.texture(c, "front"), CreatureArt.texture(c.species, false))
	assert_eq(GeneArt.texture(c, "icon"), CreatureArt.icon(c.species))

func test_every_kind_has_the_right_size() -> void:
	var c := _hybrid()
	assert_eq(GeneArt.texture(c, "front").get_size(), Vector2(SpriteCreature.SIZE * SpriteCreature.SCALE * 2, SpriteCreature.SIZE * SpriteCreature.SCALE))
	assert_eq(GeneArt.texture(c, "back").get_size(), Vector2(SpriteCreature.SIZE * SpriteCreature.SCALE * 2, SpriteCreature.SIZE * SpriteCreature.SCALE))
	assert_eq(GeneArt.texture(c, "icon").get_size(), Vector2(32, 32))

func test_blend_is_deterministic_and_not_empty() -> void:
	var c := _hybrid()
	var look := GeneArt.look_of(c)
	var a: Dictionary = SpriteCreature.render(GeneArt.recipe_for(c, look))
	var b: Dictionary = SpriteCreature.render(GeneArt.recipe_for(c, look))
	assert_eq(a.front.get_data(), b.front.get_data(), "same look, same pixels")
	assert_true(_opaque(a.front) > 400, "front has a body")
	assert_true(_opaque(a.back) > 400, "back has a body")
	assert_true(_opaque(a.icon) > 40, "icon is not empty")
	assert_eq(a.front.get_size(), Vector2i(SpriteCreature.SIZE * SpriteCreature.SCALE * 2, SpriteCreature.SIZE * SpriteCreature.SCALE))

func test_blend_differs_from_both_parents() -> void:
	var sire := GeneArt.recipe("coolet")
	var dam := GeneArt.recipe("moolet")
	var r: Dictionary = Blend.blend(sire, dam, {"palette": "mix"})
	var blended: Dictionary = SpriteCreature.render(r)
	assert_true(blended.front.get_data() != SpriteCreature.render(dam).front.get_data(), "not the dam")
	assert_true(blended.front.get_data() != SpriteCreature.render(sire).front.get_data(), "not the sire")
	assert_false(r.has("back_marks"), "hand-tuned back keys are dropped")

func test_blend_does_not_touch_its_inputs() -> void:
	var sire := GeneArt.recipe("coolet").duplicate(true)
	var dam := GeneArt.recipe("moolet").duplicate(true)
	Blend.blend(sire, dam, {"palette": "mix"}, {"mark": 2, "hue": 0.08})
	assert_eq(sire, GeneArt.recipe("coolet"))
	assert_eq(dam, GeneArt.recipe("moolet"))

func test_equal_genomes_share_a_texture_and_different_ones_do_not() -> void:
	var a := _hybrid()
	var b := _hybrid()
	assert_eq(GeneArt.texture(a, "front"), GeneArt.texture(b, "front"), "cached per look")
	var bold := _hybrid()
	bold.genome["mark"] = ["B", "B"]
	assert_true(GeneArt.texture(bold, "front") != GeneArt.texture(a, "front"), "a different showing is a different look")

func test_cache_is_bounded() -> void:
	var c := _mk("moolet")
	for i in GeneArt.MAX_CACHED + 8:
		c.genome["tint"] = ["W", "W"]
		c.genome["coat"] = ["c", "c"]
		c.genome["frame1"] = ["+", "+"] if i % 2 == 0 else ["-", "-"]
		c.genome["frame2"] = ["+", "+"] if i % 3 == 0 else ["-", "-"]
		c.genome["frame3"] = ["+", "+"] if i % 5 == 0 else ["-", "-"]
		c.genome["tint"] = [["W", "R", "G", "S", "D", "M"][i % 6], ["W", "R", "G", "S", "D", "M"][(i / 6) % 6]]
		c.genome["mark"] = [["B", "b"][i % 2], ["B", "b"][(i / 2) % 2]]
		GeneArt.texture(c, "front")
	assert_true(GeneArt._cache.size() <= GeneArt.MAX_CACHED)

func test_frame_scales_the_sprite_inside_its_box() -> void:
	var big := _mk("moolet", {"frame1": ["+", "+"], "frame2": ["+", "+"], "frame3": ["+", "+"], "frame4": ["+", "+"]})
	var small := _mk("moolet", {"frame1": ["-", "-"], "frame2": ["-", "-"], "frame3": ["-", "-"], "frame4": ["-", "-"]})
	var bi := GeneArt.texture(big, "front").get_image()
	var si := GeneArt.texture(small, "front").get_image()
	assert_eq(bi.get_size(), Vector2i(SpriteCreature.SIZE * SpriteCreature.SCALE * 2, SpriteCreature.SIZE * SpriteCreature.SCALE))
	assert_true(_opaque(bi) > _opaque(si), "size 8 is bigger than size 0")
	var fp := bi.get_height()
	for x in [fp - 1, fp * 2 - 1]:   # the right edge of each frame stays clear of the next one's content
		assert_eq(si.get_pixel(x, 0).a, 0.0)

func test_roan_mixes_both_coats() -> void:
	var tex := GeneArt.texture(_mk("moolet", {"coat": ["c", "c"], "tint": ["W", "D"]}), "front").get_image()
	var win := _mk("moolet", {"coat": ["c", "c"], "tint": ["W", "W"]})
	var sto := _mk("moolet", {"coat": ["c", "c"], "tint": ["D", "D"]})
	var wi := GeneArt.texture(win, "front").get_image()
	var st := GeneArt.texture(sto, "front").get_image()
	var from_w := 0
	var from_d := 0
	for y in 96:
		for x in 96:
			var p := tex.get_pixel(x, y)
			if p.a < 0.5:
				continue
			if p.is_equal_approx(wi.get_pixel(x, y)):
				from_w += 1
			if p.is_equal_approx(st.get_pixel(x, y)):
				from_d += 1
	assert_true(from_w > 100 and from_d > 100, "pixels from both coats: %d / %d" % [from_w, from_d])

func test_tortie_patches_a_ginger_carrier_of_the_two_copy_sex() -> void:
	var plain := _mk("moolet")
	var tort := _mk("moolet", {"ginger": ["O", "o"]})
	assert_true(Genetics.showing(tort).tortie)
	var a := GeneArt.texture(plain, "front").get_image()
	var b := GeneArt.texture(tort, "front").get_image()
	var changed := 0
	for y in 96:
		for x in 96:
			if a.get_pixel(x, y).a > 0.5 and not a.get_pixel(x, y).is_equal_approx(b.get_pixel(x, y)):
				changed += 1
	assert_true(changed > 150 and changed < _opaque(a) - 150, "patches, not a wash: %d of %d" % [changed, _opaque(a)])

func test_coatart_parses_roan_and_tortie() -> void:
	assert_true(CoatArt.parse("winter+storm").valid)
	assert_eq(CoatArt.parse("winter+storm").coats.size(), 2)
	assert_true(CoatArt.parse("tortie").tortie)
	assert_true(CoatArt.parse("moonlit+tortie").valid)
	assert_false(CoatArt.parse("plaid").valid)
	assert_false(CoatArt.parse("").valid)

func test_old_single_coats_are_unchanged() -> void:
	var r: Dictionary = SpriteCreature.render(GeneArt.recipe("moolet"))
	var a: Image = r.front.duplicate()
	CoatArt.recolour(a, "winter")
	var b: Image = r.front.duplicate()
	for y in 96:
		for x in 192:
			var c := b.get_pixel(x, y)
			if c.a > 0.01:
				b.set_pixel(x, y, CoatArt.shade(c, Coats.PALETTES["winter"], CoatArt.STRENGTH["winter"]))
	assert_eq(a.get_data(), b.get_data())
