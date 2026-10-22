class_name CoatArt
extends RefCounted
## Draws uncommon coats (see Coats). A coat is a gradient map of the creature's own sprite: each pixel's
## brightness is carried along the coat's four palette stops and blended over the original, so the shading,
## outline and eyes all survive and it reads as the same creature in a different coat rather than a colour filter.
## Done once per sheet on the CPU and cached, so every place that draws a creature (battle, summary, team, Ark,
## Fieldbook, follower, garden) can just ask for the coated texture. Plus the glint when one appears, and the
## little swatches the Fieldbook and summary show.

## How far each coat pulls towards its palette (spring is a tint over the usual colours, winter nearly all white).
const STRENGTH := {"winter": 0.86, "autumn": 0.8, "summer": 0.74, "spring": 0.78, "storm": 0.84, "moonlit": 0.82}
const OUTLINE_LUM := 0.12   # darker than this is the outline or a pupil: kept, just nudged towards the shadow stop

static var _cache := {}

## The coated version of `tex` (any sheet: front, back or icon). `key` names the source for the cache.
static func texture(tex: Texture2D, key: String, variant: String) -> Texture2D:
	if variant == "" or tex == null or not parse(variant).valid:
		return tex
	var ck := key + "|" + variant
	if _cache.has(ck):
		return _cache[ck]
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	recolour(img, variant)
	var out := ImageTexture.create_from_image(img)
	_cache[ck] = out
	return out

## "winter" -> one coat; "winter+storm" -> a roan of both; "tortie" (alone or after coats) -> warm patches on top.
static func parse(variant: String) -> Dictionary:
	var coats: Array = []
	var tortie := false
	for t in variant.split("+", false):
		if t == "tortie":
			tortie = true
		elif Coats.PALETTES.has(t):
			coats.append(t)
		else:
			return {"valid": false, "coats": [], "tortie": false}
	return {"valid": not coats.is_empty() or tortie, "coats": coats, "tortie": tortie}

const FRAME_W := 96        # sheets are two square frames (96 art px each): noise repeats per frame so the bob doesn't shimmer
const TORTIE := [Color("2a1410"), Color("9a4a1c"), Color("e08a3a"), Color("ffd9a0")]
const TORTIE_STRENGTH := 0.8
const PATCH := 7           # tortoiseshell patches, in pixels across

## Recolours an RGBA8 image in place. A roan interleaves its two coats pixel by pixel (both palettes in the one
## animal, as in roan cattle); tortoiseshell lays warm patches over whatever coat there is.
static func recolour(img: Image, variant: String) -> void:
	var p := parse(variant)
	var coats: Array = p.coats
	var w := img.get_width()
	var h := img.get_height()
	# a fine sheet (frames taller than 96 px, see tools/spritegen/creature.gd) keeps its roan and patches on the
	# 96 art-pixel grid, so they look the same at any resolution; icons and old sheets are 1:1
	var fw := h if h >= FRAME_W and w % h == 0 else FRAME_W
	var u := maxi(1, h / FRAME_W)
	for y in h:
		for x in w:
			var c := img.get_pixel(x, y)
			if c.a <= 0.01:
				continue
			var fx := (x % fw) / u
			var fy := y / u
			if not coats.is_empty():
				var v: String = coats[0]
				if coats.size() > 1 and _hash(fx, fy, 3) & 1 == 1:
					v = coats[1]
				c = shade(c, Coats.PALETTES[v], STRENGTH.get(v, 0.8))
			if p.tortie and _patch(float(x % fw) / u, float(y) / u):
				c = shade(c, TORTIE, TORTIE_STRENGTH)
			img.set_pixel(x, y, c)

static func _hash(x: int, y: int, seed_v: int) -> int:
	var n := x * 374761393 + y * 668265263 + seed_v * 2147483647
	n = (n ^ (n >> 13)) * 1274126177
	return (n ^ (n >> 16)) & 0x7fffffff

## Patches: value noise on a PATCH-pixel grid, smoothly blended, half the animal.
static func _patch(x: float, y: float) -> bool:
	var gx := float(x) / PATCH
	var gy := float(y) / PATCH
	var ix := int(floor(gx))
	var iy := int(floor(gy))
	var fx := gx - ix
	var fy := gy - iy
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)
	var a := float(_hash(ix, iy, 11) % 1000)
	var b := float(_hash(ix + 1, iy, 11) % 1000)
	var c := float(_hash(ix, iy + 1, 11) % 1000)
	var d := float(_hash(ix + 1, iy + 1, 11) % 1000)
	return lerpf(lerpf(a, b, fx), lerpf(c, d, fx), fy) > 500.0

## One pixel through the coat: outline kept; everything else mapped by brightness and blended by `k`.
static func shade(c: Color, pal: Array, k: float) -> Color:
	var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
	if lum < OUTLINE_LUM:
		var o := c.lerp(pal[0].darkened(0.55), 0.35)
		o.a = c.a
		return o
	var t := clampf((lum - OUTLINE_LUM) / (0.95 - OUTLINE_LUM), 0.0, 1.0)
	var mapped := ramp(pal, t)
	var out := c.lerp(mapped, k)
	out.a = c.a
	return out

## Along the four stops, smoothly.
static func ramp(pal: Array, t: float) -> Color:
	var f := t * (pal.size() - 1)
	var i := clampi(int(f), 0, pal.size() - 2)
	var u := f - i
	u = u * u * (3.0 - 2.0 * u)
	return (pal[i] as Color).lerp(pal[i + 1], u)

# --- the glint ----------------------------------------------------------------------------

static var _star: ArrayMesh
static var _star_mat: StandardMaterial3D

## A few four-point stars that swell and twinkle round a creature as it appears in an uncommon coat.
## `height` is roughly how tall it stands (world units).
static func glint(parent: Node3D, variant: String, height := 2.0) -> void:
	if parent == null or variant == "" or not parent.is_inside_tree():
		return
	if _star == null:
		var st := Meshes._st()
		var r := 0.5
		var wd := r * 0.22
		Meshes._quad(st, Vector3(-wd, 0, 0), Vector3(0, r, 0), Vector3(wd, 0, 0), Vector3(0, -r, 0), Color.WHITE)
		Meshes._quad(st, Vector3(-r, 0, 0), Vector3(0, wd, 0), Vector3(r, 0, 0), Vector3(0, -wd, 0), Color.WHITE)
		_star = Meshes._finish(st)
		_star_mat = StandardMaterial3D.new()
		_star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_star_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		_star_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_star_mat.no_depth_test = true
		_star_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var tint := Coats.swatch(variant).lerp(Color.WHITE, 0.55)
	var spots := [Vector3(-0.45, 0.75, 0.1), Vector3(0.5, 0.45, 0.1), Vector3(0.15, 0.95, 0.1), Vector3(-0.2, 0.3, 0.1), Vector3(0.35, 0.8, 0.1)]
	for i in spots.size():
		var m := MeshInstance3D.new()
		m.mesh = _star
		var mat: StandardMaterial3D = _star_mat.duplicate()
		mat.albedo_color = tint if i % 2 else Color(1, 1, 0.94)
		m.material_override = mat
		m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		m.position = spots[i] * height
		m.scale = Vector3.ZERO
		parent.add_child(m)
		var size := 0.2 if i == 0 else 0.12
		var tw := m.create_tween()
		tw.tween_interval(0.12 * i)
		tw.tween_property(m, "scale", Vector3.ONE * size, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(m, "rotation:z", PI * 0.25, 0.5)
		tw.tween_property(m, "scale", Vector3.ZERO, 0.32).set_trans(Tween.TRANS_SINE)
		tw.tween_callback(m.queue_free)

# --- swatches -------------------------------------------------------------------------------

## A small rounded chip in the coat's colours: "Winter white coat".
static func coat_chip(variant: String, size := 20) -> Control:
	var pal: Array = Coats.PALETTES.get(variant, [])
	var bg: Color = pal[1].darkened(0.25) if pal.size() > 1 else Color("444")
	var c := CenterContainer.new()
	c.add_child(UIKit.chip(Coats.name_of(variant) + " coat", bg, pal[3] if pal.size() > 3 else Color.WHITE, size))
	return c

## The Fieldbook's coat row for a species: a swatch per coat, filled if seen (with a dot when caught),
## an empty outline if not. Hidden entirely until you've seen at least one.
static func swatch_row(data: GameStateData, species_id: String) -> Control:
	var any := false
	for v in Coats.ALL:
		if Coats.status(data, species_id, v) != "":
			any = true
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	if not any:
		return row
	row.add_child(UIKit.label("Coats", 20, UIKit.MUTED))
	for v in Coats.ALL:
		var st := Coats.status(data, species_id, v)
		var p := Panel.new()
		p.custom_minimum_size = Vector2(22, 22)
		p.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var col := Coats.swatch(v)
		p.add_theme_stylebox_override("panel", UIKit.box(col if st != "" else Color(0, 0, 0, 0), col.darkened(0.3) if st != "" else Color("5a5f6e"), 2, 11, 0))
		p.tooltip_text = Coats.name_of(v) + ("" if st == "" else (" (caught)" if st == "caught" else " (seen)"))
		if st == "caught":
			var dot := Panel.new()
			dot.add_theme_stylebox_override("panel", UIKit.box(Color("1d2230"), Color(0, 0, 0, 0), 0, 4, 0))
			dot.position = Vector2(7, 7)
			dot.size = Vector2(8, 8)
			p.add_child(dot)
		row.add_child(p)
	return row
