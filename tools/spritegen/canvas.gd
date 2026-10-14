extends RefCounted
## Software pixel canvas for the sprite generator. Image API only, fully deterministic.
## Shapes become coverage masks; masks are painted with 3-tone light-from-top-left shading,
## ordered dither at tone boundaries, optional patterns and a rim. Then a 1 px outline.

const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]
const HI_TH := 0.66
const LO_TH := 0.15

var w: int
var h: int
var img: Image

func _init(width: int, height: int) -> void:
	w = width
	h = height
	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

# ---------- colour ----------

static func parse_colour(v) -> Color:
	return Color.html(str(v))

## [base, shadow, highlight]
static func tones(base: Color) -> Array:
	var shadow := base.lerp(Color(0.13, 0.08, 0.30), 0.40)
	shadow = shadow.darkened(0.08)
	var hi := base.lerp(Color(1.0, 0.95, 0.72), 0.36)
	return [Color(base, 1.0), Color(shadow, 1.0), Color(hi, 1.0)]

## Accepts "#hex" or {"base","shadow","highlight"}.
static func tones_from(v, darken := 0.0) -> Array:
	var t: Array
	if v is Dictionary:
		var b := parse_colour(v.get("base", "#888888"))
		t = tones(b)
		if v.has("shadow"):
			t[1] = parse_colour(v["shadow"])
		if v.has("highlight"):
			t[2] = parse_colour(v["highlight"])
	else:
		t = tones(parse_colour(v))
	if darken > 0.0:
		for i in 3:
			t[i] = t[i].darkened(darken)
	return t

# ---------- masks ----------

func _mask(bb: Rect2) -> Dictionary:
	var x0 := maxi(0, int(floor(bb.position.x)))
	var y0 := maxi(0, int(floor(bb.position.y)))
	var x1 := mini(w, int(ceil(bb.end.x)) + 1)
	var y1 := mini(h, int(ceil(bb.end.y)) + 1)
	var mw := maxi(0, x1 - x0)
	var mh := maxi(0, y1 - y0)
	var bits := PackedByteArray()
	bits.resize(mw * mh)
	return {"x0": x0, "y0": y0, "w": mw, "h": mh, "bits": bits, "bb": bb}

func ellipse_mask(cx: float, cy: float, wid: float, hei: float, angle_deg := 0.0) -> Dictionary:
	var rx := wid * 0.5
	var ry := hei * 0.5
	var a := deg_to_rad(angle_deg)
	var ca := cos(a)
	var sa := sin(a)
	var ex := sqrt(rx * rx * ca * ca + ry * ry * sa * sa)
	var ey := sqrt(rx * rx * sa * sa + ry * ry * ca * ca)
	var m := _mask(Rect2(cx - ex, cy - ey, ex * 2.0, ey * 2.0))
	for j in m.h:
		for i in m.w:
			var dx: float = m.x0 + i + 0.5 - cx
			var dy: float = m.y0 + j + 0.5 - cy
			var lx := dx * ca + dy * sa
			var ly := -dx * sa + dy * ca
			if (lx * lx) / (rx * rx) + (ly * ly) / (ry * ry) <= 1.0:
				m.bits[j * m.w + i] = 1
	return m

func rect_mask(cx: float, cy: float, wid: float, hei: float, angle_deg := 0.0, round_r := 0.0) -> Dictionary:
	var hw := wid * 0.5
	var hh := hei * 0.5
	var a := deg_to_rad(angle_deg)
	var ca := cos(a)
	var sa := sin(a)
	var ex := absf(ca) * hw + absf(sa) * hh
	var ey := absf(sa) * hw + absf(ca) * hh
	var m := _mask(Rect2(cx - ex, cy - ey, ex * 2.0, ey * 2.0))
	for j in m.h:
		for i in m.w:
			var dx: float = m.x0 + i + 0.5 - cx
			var dy: float = m.y0 + j + 0.5 - cy
			var lx := absf(dx * ca + dy * sa)
			var ly := absf(-dx * sa + dy * ca)
			if lx > hw or ly > hh:
				continue
			if round_r > 0.0:
				var qx := maxf(lx - (hw - round_r), 0.0)
				var qy := maxf(ly - (hh - round_r), 0.0)
				if qx * qx + qy * qy > round_r * round_r:
					continue
			m.bits[j * m.w + i] = 1
	return m

## Scanline polygon fill (even-odd).
func poly_mask(pts: Array) -> Dictionary:
	var minx := 1e9
	var miny := 1e9
	var maxx := -1e9
	var maxy := -1e9
	for p in pts:
		minx = minf(minx, p.x)
		miny = minf(miny, p.y)
		maxx = maxf(maxx, p.x)
		maxy = maxf(maxy, p.y)
	var m := _mask(Rect2(minx, miny, maxx - minx, maxy - miny))
	var n := pts.size()
	for j in m.h:
		var sy: float = m.y0 + j + 0.5
		var xs: Array = []
		for k in n:
			var a: Vector2 = pts[k]
			var b: Vector2 = pts[(k + 1) % n]
			if (a.y <= sy and b.y > sy) or (b.y <= sy and a.y > sy):
				xs.append(a.x + (sy - a.y) * (b.x - a.x) / (b.y - a.y))
		xs.sort()
		var k := 0
		while k + 1 < xs.size():
			var xa := int(ceil(xs[k] - 0.5))
			var xb := int(floor(xs[k + 1] - 0.5))
			for x in range(maxi(xa, m.x0), mini(xb, m.x0 + m.w - 1) + 1):
				m.bits[j * m.w + (x - m.x0)] = 1
			k += 2
	return m

## Polyline with round caps; pts is an Array of Vector2.
func line_mask(pts: Array, width: float) -> Dictionary:
	var r := maxf(width * 0.5, 0.6)
	var minx := 1e9
	var miny := 1e9
	var maxx := -1e9
	var maxy := -1e9
	for p in pts:
		minx = minf(minx, p.x)
		miny = minf(miny, p.y)
		maxx = maxf(maxx, p.x)
		maxy = maxf(maxy, p.y)
	var m := _mask(Rect2(minx - r, miny - r, maxx - minx + r * 2.0, maxy - miny + r * 2.0))
	for j in m.h:
		for i in m.w:
			var p := Vector2(m.x0 + i + 0.5, m.y0 + j + 0.5)
			for k in pts.size() - 1:
				var a: Vector2 = pts[k]
				var ab: Vector2 = pts[k + 1] - a
				var len2 := maxf(ab.length_squared(), 0.0001)
				var t := clampf((p - a).dot(ab) / len2, 0.0, 1.0)
				if p.distance_to(a + ab * t) <= r:
					m.bits[j * m.w + i] = 1
					break
	return m

func _in(m: Dictionary, x: int, y: int) -> bool:
	var i: int = x - m.x0
	var j: int = y - m.y0
	if i < 0 or j < 0 or i >= m.w or j >= m.h:
		return false
	return m.bits[j * m.w + i] == 1

static func hash2(x: int, y: int, seed_v: int) -> int:
	var n: int = (x * 73856093) ^ (y * 19349663) ^ (seed_v * 83492791)
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)
	return absi(n) % 100

# ---------- painting ----------

## opt: shade(bool), rim(bool), pattern, pcol(tones or null), seed, period, angle, density, n
func paint(m: Dictionary, tn: Array, opt: Dictionary) -> void:
	var bb: Rect2 = m.bb
	var cx := bb.position.x + bb.size.x * 0.5
	var cy := bb.position.y + bb.size.y * 0.5
	var rx := maxf(bb.size.x * 0.5, 1.0)
	var ry := maxf(bb.size.y * 0.5, 1.0)
	var shade: bool = opt.get("shade", true)
	var rim: bool = opt.get("rim", false)
	var pattern: String = opt.get("pattern", "none")
	var pcol = opt.get("pcol", null)
	var sd: int = int(opt.get("seed", 1))
	var period: float = float(opt.get("period", 6.0))
	var ang: float = deg_to_rad(float(opt.get("angle", 60.0)))
	var density: int = int(opt.get("density", 9))
	var nspine: float = float(opt.get("n", 26))
	var ca := cos(ang)
	var sa := sin(ang)
	for j in m.h:
		for i in m.w:
			if m.bits[j * m.w + i] == 0:
				continue
			var x: int = m.x0 + i
			var y: int = m.y0 + j
			var fx := x + 0.5
			var fy := y + 0.5
			var nx := (fx - cx) / rx
			var ny := (fy - cy) / ry
			var tone := 0
			if shade:
				var z := sqrt(maxf(0.0, 1.0 - nx * nx - ny * ny))
				var l := 0.55 * (-(nx * 0.6 + ny * 0.8)) + 0.5 * z
				l += (BAYER[(y & 3) * 4 + (x & 3)] / 16.0 - 0.47) * 0.17
				if l > HI_TH:
					tone = 2
				elif l < LO_TH:
					tone = 1
			var col: Color = tn[tone]
			match pattern:
				"speckle":
					if hash2(x, y, sd) < density:
						col = pcol[tone] if pcol != null else tn[1 if tone < 2 else 0]
				"stripes":
					var u := fx * ca + fy * sa
					if fposmod(u / period, 1.0) < 0.38:
						col = pcol[tone] if pcol != null else tn[1 if tone < 2 else 0]
				"spines":
					var a2 := atan2(fy - cy, fx - cx)
					var fr := fposmod(a2 * nspine / TAU, 1.0)
					var rr := sqrt(nx * nx + ny * ny)
					if rr > 0.28:
						if fr < 0.30:
							col = pcol[tone] if pcol != null else tn[1]
						elif fr > 0.62 and fr < 0.8 and rr > 0.5:
							col = tn[2]
			if rim:
				var edge_tl := (not _in(m, x - 1, y)) or (not _in(m, x, y - 1))
				var edge_br := (not _in(m, x + 1, y)) or (not _in(m, x, y + 1))
				if edge_br:
					col = tn[1].darkened(0.22)
				elif edge_tl:
					col = tn[0].darkened(0.32)
			img.set_pixel(x, y, col)

func disc(cx: float, cy: float, r: float, col: Color) -> void:
	var m := ellipse_mask(cx, cy, r * 2.0, r * 2.0)
	for j in m.h:
		for i in m.w:
			if m.bits[j * m.w + i] == 1:
				img.set_pixel(m.x0 + i, m.y0 + j, col)

func px(x: int, y: int, col: Color) -> void:
	if x >= 0 and y >= 0 and x < w and y < h:
		img.set_pixel(x, y, col)

## 1 px outline around the silhouette (outer pixels). colour null = automatic dark tint of neighbour.
func outline(col = null) -> void:
	var src := img.duplicate() as Image
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.0:
				continue
			var nb := Color(0, 0, 0, 0)
			for d in [Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1)]:
				var qx: int = x + d.x
				var qy: int = y + d.y
				if qx < 0 or qy < 0 or qx >= w or qy >= h:
					continue
				var c := src.get_pixel(qx, qy)
				if c.a > 0.0:
					nb = c
					break
			if nb.a > 0.0:
				if col == null:
					var o := nb.darkened(0.62)
					o = o.lerp(Color(0.08, 0.05, 0.12), 0.35)
					img.set_pixel(x, y, Color(o, 1.0))
				else:
					img.set_pixel(x, y, col)

func eye(cx: float, cy: float, r: float, col: Color, hi := true, pupil = null) -> void:
	disc(cx, cy, r, col)
	if pupil != null:
		var pm := ellipse_mask(cx, cy, float(pupil[0]), float(pupil[1]))
		for j in pm.h:
			for i in pm.w:
				if pm.bits[j * pm.w + i] == 1:
					img.set_pixel(pm.x0 + i, pm.y0 + j, Color("#1d1822"))
	if hi:
		var hx := int(round(cx - r * 0.35 - 0.5))
		var hy := int(round(cy - r * 0.40 - 0.5))
		px(hx, hy, Color.WHITE)
		if r >= 3.5:
			px(hx + 1, hy, Color.WHITE)
			px(int(round(cx + r * 0.4 - 0.5)), int(round(cy + r * 0.45 - 0.5)), Color(0.75, 0.8, 0.9))

func content_bounds() -> Rect2i:
	var x0 := w
	var y0 := h
	var x1 := -1
	var y1 := -1
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.0:
				x0 = mini(x0, x)
				x1 = maxi(x1, x)
				y0 = mini(y0, y)
				y1 = maxi(y1, y)
	if x1 < 0:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1)
