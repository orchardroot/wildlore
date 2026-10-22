class_name FormArt
extends RefCounted
## Draws regional forms (see Forms). The form's look delta is applied to the creature's own sprite sheet at runtime,
## like a coat (CoatArt), once per sheet and cached: a palette nudge (hue, saturation, value, a tint carried by the
## sprite's own brightness so the shading and outline survive) and a few cheap features drawn on top (a crest, long
## ears, speckles, a pale belly, a dark dorsal stripe). A coat is then laid over the result, so the two combine.

static var _cache := {}

## The form's version of `tex` (any sheet: front, back or icon). `key` names the source for the cache.
static func texture(tex: Texture2D, key: String, species_id: String, form_id: String) -> Texture2D:
	if form_id == "" or tex == null:
		return tex
	var look := Forms.look_of(species_id, form_id)
	if look.is_empty():
		return tex
	var ck := "%s|%s|%s" % [key, species_id, form_id]
	if _cache.has(ck):
		return _cache[ck]
	var img := tex.get_image()
	if img == null or img.is_empty():
		return tex
	img = img.duplicate()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	apply(img, look)
	var out := ImageTexture.create_from_image(img)
	_cache[ck] = out
	return out

## Applies a look in place to an RGBA8 sheet (frames are square: as wide as the sheet is tall).
static func apply(img: Image, look: Dictionary) -> void:
	var p: Dictionary = look.get("palette", {})
	if not p.is_empty():
		_palette(img, p)
	var fw := img.get_height()
	for f in look.get("features", []):
		for ox in range(0, img.get_width() - fw + 1, fw):
			_feature(img, str(f), ox, fw, p)

static func _palette(img: Image, p: Dictionary) -> void:
	var dh := float(p.get("hue", 0.0)) / 360.0
	var ds := float(p.get("sat", 0.0))
	var dv := float(p.get("val", 0.0))
	var amt := clampf(float(p.get("tint_amount", 0.0)), 0.0, 1.0)
	var tint := Color(str(p.tint)) if p.has("tint") and Color.html_is_valid(str(p.tint)) else Color.WHITE
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a <= 0.01:
				continue
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			if lum < CoatArt.OUTLINE_LUM:
				continue  # the outline and pupils stay as drawn
			var h := fposmod(c.h + dh, 1.0)
			var out := Color.from_hsv(h, clampf(c.s * (1.0 + ds), 0.0, 1.0), clampf(c.v * (1.0 + dv), 0.0, 1.0), c.a)
			if amt > 0.0:  # the tint carries the original brightness, so shading survives
				var k := clampf(lum / 0.55, 0.15, 1.3)
				out = out.lerp(Color(tint.r * k, tint.g * k, tint.b * k, c.a), amt)
			img.set_pixel(x, y, out)

## The opaque rows' first y and the mean x of that first band, within one frame.
static func _top(img: Image, ox: int, fw: int) -> Vector2i:
	for y in fw:
		var sum := 0
		var n := 0
		for x in fw:
			if img.get_pixel(ox + x, y).a > 0.5:
				sum += x
				n += 1
		if n > 0:
			return Vector2i(sum / n, y)
	return Vector2i(-1, -1)

static func _feature(img: Image, f: String, ox: int, fw: int, p: Dictionary) -> void:
	var u := maxi(1, fw / 32)   # one "art pixel": 3 on a 96 px frame, 1 on a 32 px icon
	var top := _top(img, ox, fw)
	if top.x < 0:
		return
	var accent := Color(str(p.tint)) if p.has("tint") and Color.html_is_valid(str(p.tint)) else Color("c8b68a")
	var body := img.get_pixel(ox + top.x, mini(top.y + 2 * u, fw - 1))
	if body.a < 0.5:
		body = accent
	match f:
		"crest":
			for i in 3:
				_block(img, ox + top.x, top.y - (i + 1) * u, u * (3 - i), u, fw, ox, accent.lightened(0.15 * i))
		"ears":
			for side in [-1, 1]:
				for i in 5:
					_block(img, ox + top.x + side * 4 * u, top.y - (i + 1) * u, u * 2, u, fw, ox, body.darkened(0.1))
		"speckle":
			for y in fw:
				for x in fw:
					var c := img.get_pixel(ox + x, y)
					if c.a > 0.5 and 0.299 * c.r + 0.587 * c.g + 0.114 * c.b >= CoatArt.OUTLINE_LUM and CoatArt._hash(x / u, y / u, 7) % 19 == 0:
						img.set_pixel(ox + x, y, c.lightened(0.28))
		"belly":
			var low := _bottom(img, ox, fw)
			var from := top.y + (low - top.y) * 2 / 3
			for y in range(from, low + 1):
				for x in fw:
					var c := img.get_pixel(ox + x, y)
					if c.a > 0.5 and 0.299 * c.r + 0.587 * c.g + 0.114 * c.b >= CoatArt.OUTLINE_LUM:
						img.set_pixel(ox + x, y, c.lerp(Color(0.93, 0.89, 0.8, c.a), 0.45))
		"stripe":
			var low2 := _bottom(img, ox, fw)
			var to := top.y + (low2 - top.y) / 3
			for y in range(top.y, to + 1):
				for x in range(top.x - u, top.x + u + 1):
					if x < 0 or x >= fw:
						continue
					var c := img.get_pixel(ox + x, y)
					if c.a > 0.5 and 0.299 * c.r + 0.587 * c.g + 0.114 * c.b >= CoatArt.OUTLINE_LUM:
						img.set_pixel(ox + x, y, c.darkened(0.4))

static func _bottom(img: Image, ox: int, fw: int) -> int:
	for y in range(fw - 1, -1, -1):
		for x in fw:
			if img.get_pixel(ox + x, y).a > 0.5:
				return y
	return fw - 1

## A w by h block centred on x (absolute) at row y, clipped to the frame starting at `ox`.
static func _block(img: Image, cx: int, y: int, w: int, h: int, fw: int, ox: int, col: Color) -> void:
	for yy in range(y, y + h):
		if yy < 0 or yy >= fw:
			continue
		for xx in range(cx - w / 2, cx - w / 2 + w):
			if xx < ox or xx >= ox + fw:
				continue
			col.a = 1.0
			img.set_pixel(xx, yy, col)
