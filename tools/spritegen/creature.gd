extends RefCounted
## Creature renderer: recipe dictionary -> front/back sheets (192x96) and icon (32x32).
## Recipe layers are drawn in order with light from the top-left. See art/recipes/creatures/*.json.
##
## Layer fields: shape (ellipse|circle|rect|poly|tri|line), at [x,y] (centre), size [w,h], r,
## points [[x,y]..], width (line), angle (deg), round (rect corner radius), colour (palette name
## or #hex), shade (default true), rim (default: on for big layers), pattern, pcolour, period,
## density, n, mirror (also draw reflected about x=48), front_only, back_only.
## Recipe fields: palette, layers, back_layers, face_layers (front only, drawn after the outline),
## eyes, outline, anim ("squash" default or "shift"), bob, icon_box.

const Canvas = preload("res://tools/spritegen/canvas.gd")
const SIZE := 96
const AXIS := 96.0

static func render(recipe: Dictionary) -> Dictionary:
	var front := _sheet(recipe, false)
	var back := _sheet(recipe, true)
	var icon := _icon(recipe)
	return {"front": front, "back": back, "icon": icon}

static func _palette(recipe: Dictionary, darken: float) -> Dictionary:
	var pal := {}
	for k in recipe.get("palette", {}):
		pal[k] = Canvas.tones_from(recipe["palette"][k], darken)
	return pal

static func _tones_for(name, pal: Dictionary, darken: float) -> Array:
	var s := str(name)
	if pal.has(s):
		return pal[s]
	return Canvas.tones_from(s, darken)

static func _sheet(recipe: Dictionary, is_back: bool) -> Image:
	var out := Image.create(SIZE * 2, SIZE, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	var layers: Array = recipe.get("layers", [])
	if is_back and recipe.has("back_layers"):
		layers = recipe["back_layers"]
	var base = _draw_all(recipe, layers, is_back, null, true)
	var bounds: Rect2i = base.content_bounds()
	out.blit_rect(base.img, Rect2i(0, 0, SIZE, SIZE), Vector2i(0, 0))
	var xf := {"mode": str(recipe.get("anim", "squash")), "bob": float(recipe.get("bob", 2.0)),
		"bottom": float(bounds.end.y - 1), "height": float(bounds.size.y)}
	var f2 = _draw_all(recipe, layers, is_back, xf, true)
	out.blit_rect(f2.img, Rect2i(0, 0, SIZE, SIZE), Vector2i(SIZE, 0))
	return out

## Applies the breathing transform to a copy of a layer.
static func _xf_layer(layer: Dictionary, xf) -> Dictionary:
	if xf == null:
		return layer
	var l := layer.duplicate(true)
	var b: float = xf.bottom
	var s := 1.0
	var shift := 0.0
	if xf.mode == "shift":
		shift = xf.bob
	else:
		s = maxf(0.5, (xf.height - xf.bob) / xf.height)
	var ty := func(y: float) -> float: return b - (b - y) * s + shift
	if l.has("at"):
		l["at"] = [l["at"][0], ty.call(float(l["at"][1]))]
	if l.has("points"):
		var np: Array = []
		for p in l["points"]:
			np.append([p[0], ty.call(float(p[1]))])
		l["points"] = np
	if s != 1.0:
		if l.has("size"):
			l["size"] = [l["size"][0], float(l["size"][1]) * s]
		elif l.has("r") and str(l.get("shape", "")) == "circle":
			var r := float(l["r"])
			l["shape"] = "ellipse"
			l["size"] = [r * 2.0, r * 2.0 * s]
	return l

static func _mirror_layer(layer: Dictionary) -> Dictionary:
	var l := layer.duplicate(true)
	if l.has("at"):
		l["at"] = [AXIS - float(l["at"][0]), l["at"][1]]
	if l.has("points"):
		var np: Array = []
		for p in l["points"]:
			np.append([AXIS - float(p[0]), p[1]])
		l["points"] = np
	if l.has("angle"):
		l["angle"] = -float(l["angle"])
	if l.has("angle_p"):
		l["angle_p"] = 180.0 - float(l["angle_p"])
	l["seed"] = int(l.get("seed", 1)) + 7
	l.erase("mirror")
	return l

static func _draw_layer(cv, layer: Dictionary, pal: Dictionary, darken: float, xf) -> void:
	var l := _xf_layer(layer, xf)
	var shape := str(l.get("shape", "ellipse"))
	var m: Dictionary
	var minside := 99.0
	match shape:
		"ellipse", "circle":
			var at: Array = l["at"]
			var wh = [float(l["r"]) * 2.0, float(l["r"]) * 2.0] if l.has("r") and not l.has("size") else l["size"]
			m = cv.ellipse_mask(float(at[0]), float(at[1]), float(wh[0]), float(wh[1]), float(l.get("angle", 0.0)))
			minside = minf(float(wh[0]), float(wh[1]))
		"rect":
			var at: Array = l["at"]
			var wh: Array = l["size"]
			m = cv.rect_mask(float(at[0]), float(at[1]), float(wh[0]), float(wh[1]), float(l.get("angle", 0.0)), float(l.get("round", 0.0)))
			minside = minf(float(wh[0]), float(wh[1]))
		"poly", "tri":
			var pts: Array = []
			for p in l["points"]:
				pts.append(Vector2(float(p[0]), float(p[1])))
			m = cv.poly_mask(pts)
			minside = minf(m.bb.size.x, m.bb.size.y)
		"spikes":
			var at: Array = l["at"]
			var wh: Array = l["size"]
			var pts := _spike_points(float(at[0]), float(at[1]), float(wh[0]) * 0.5, float(wh[1]) * 0.5, int(l.get("count", 9)), float(l.get("len", 8.0)), float(l.get("from", -195.0)), float(l.get("to", 15.0)), int(l.get("seed", 1)))
			m = cv.poly_mask(pts)
			minside = minf(float(wh[0]), float(wh[1]))
		"line":
			var lp: Array = []
			for p in l["points"]:
				lp.append(Vector2(float(p[0]), float(p[1])))
			m = cv.line_mask(lp, float(l.get("width", 2.0)))
			minside = 0.0
		_:
			push_error("spritegen: unknown shape " + shape)
			return
	var opt := {
		"shade": bool(l.get("shade", true)),
		"rim": bool(l.get("rim", minside >= 9.0)),
		"pattern": str(l.get("pattern", "none")),
		"seed": int(l.get("seed", 1)),
		"period": float(l.get("period", 6.0)),
		"angle": float(l.get("pangle", 60.0)),
		"density": int(l.get("density", 9)),
		"n": float(l.get("n", 26)),
	}
	if l.has("pcolour"):
		opt["pcol"] = _tones_for(l["pcolour"], pal, darken)
	cv.paint(m, _tones_for(l.get("colour", "#ff00ff"), pal, darken), opt)

## Polygon of a centre point plus spikes around an elliptical arc (angles in degrees, y down).
static func _spike_points(cx: float, cy: float, rx: float, ry: float, count: int, length: float, from_deg: float, to_deg: float, seed_v: int) -> Array:
	var pts: Array = [Vector2(cx, cy)]
	var step := (to_deg - from_deg) / float(count)
	for i in count:
		var a0 := deg_to_rad(from_deg + step * i)
		var a1 := deg_to_rad(from_deg + step * (i + 1))
		var am := (a0 + a1) * 0.5
		var k := 0.7 + 0.3 * float(Canvas.hash2(i, 3, seed_v) % 3) / 2.0
		pts.append(Vector2(cx + cos(a0) * rx, cy + sin(a0) * ry))
		pts.append(Vector2(cx + cos(am) * (rx + length * k), cy + sin(am) * (ry + length * k)))
	var ae := deg_to_rad(to_deg)
	pts.append(Vector2(cx + cos(ae) * rx, cy + sin(ae) * ry))
	return pts

static func _draw_list(cv, layers: Array, pal: Dictionary, darken: float, xf, is_back: bool) -> void:
	for layer in layers:
		if is_back and layer.get("front_only", false):
			continue
		if (not is_back) and layer.get("back_only", false):
			continue
		_draw_layer(cv, layer, pal, darken, xf)
		if layer.get("mirror", false):
			_draw_layer(cv, _mirror_layer(layer), pal, darken, xf)

static func _draw_all(recipe: Dictionary, layers: Array, is_back: bool, xf, with_outline: bool):
	var darken := 0.14 if is_back else 0.0
	var pal := _palette(recipe, darken)
	var cv = Canvas.new(SIZE, SIZE)
	_draw_list(cv, layers, pal, darken, xf, is_back)
	if with_outline:
		var oc = recipe.get("outline", null)
		cv.outline(null if oc == null or str(oc) == "auto" else Canvas.parse_colour(oc))
	if not is_back:
		_draw_list(cv, recipe.get("face_layers", []), pal, darken, xf, false)
		for e in recipe.get("eyes", []):
			_draw_eye(cv, e, pal, xf)
			if e.get("mirror", false):
				var me: Dictionary = e.duplicate(true)
				me["at"] = [AXIS - float(e["at"][0]), e["at"][1]]
				_draw_eye(cv, me, pal, xf)
	return cv

static func _draw_eye(cv, e: Dictionary, pal: Dictionary, xf) -> void:
	var el := _xf_layer({"at": e["at"]}, xf)
	var col := Color.html("#1d1822")
	if e.has("colour"):
		col = _tones_for(e["colour"], pal, 0.0)[0]
	var at: Array = el["at"]
	cv.eye(float(at[0]), float(at[1]), float(e.get("r", 4)), col, bool(e.get("highlight", true)), e.get("pupil", null))

static func _icon(recipe: Dictionary) -> Image:
	var layers: Array = recipe.get("layers", [])
	var raw = _draw_all(recipe, layers, false, null, false)
	var box: Rect2i
	if recipe.has("icon_box"):
		var b: Array = recipe["icon_box"]
		box = Rect2i(int(b[0]), int(b[1]), int(b[2]), int(b[3]))
	else:
		box = raw.content_bounds()
	var side := maxi(box.size.x, box.size.y)
	var ox := box.position.x - (side - box.size.x) / 2.0
	var oy := box.position.y - (side - box.size.y) / 2.0
	var target := 28
	var f := float(side) / float(target)
	var cv = Canvas.new(32, 32)
	for j in target:
		for i in target:
			var x0 := int(floor(ox + i * f))
			var x1 := maxi(x0 + 1, int(floor(ox + (i + 1) * f)))
			var y0 := int(floor(oy + j * f))
			var y1 := maxi(y0 + 1, int(floor(oy + (j + 1) * f)))
			var n := 0
			var cnt := 0
			var rr := 0.0
			var gg := 0.0
			var bb := 0.0
			for y in range(y0, y1):
				for x in range(x0, x1):
					n += 1
					if x < 0 or y < 0 or x >= SIZE or y >= SIZE:
						continue
					var c: Color = raw.img.get_pixel(x, y)
					if c.a > 0.0:
						cnt += 1
						rr += c.r
						gg += c.g
						bb += c.b
			if n > 0 and cnt * 2 >= n:
				cv.img.set_pixel(i + 2, j + 2, Color(rr / cnt, gg / cnt, bb / cnt, 1.0))
	var oc = recipe.get("outline", null)
	cv.outline(null if oc == null or str(oc) == "auto" else Canvas.parse_colour(oc))
	return cv.img
