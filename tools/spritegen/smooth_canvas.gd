extends RefCounted
## The smooth canvas for creature battle sheets: the same shapes, paint and outline as canvas.gd, in the same
## art units (a 96 grid), but drawn at `k` pixels per art unit with anti-aliased edges, soft tone blends in place
## of the ordered dither, round speckles and a soft outline. Image API only, fully deterministic, so it also runs
## in the game (hybrids, see ui/gene_art.gd). Icons and characters keep the crisp canvas.gd.
##
## A mask here is a signed distance field (art units, negative inside) over the shape's pixel box, so coverage,
## the rim and the edge direction all come from the one number.

const Canvas = preload("res://tools/spritegen/canvas.gd")

const HI_TH := Canvas.HI_TH
const LO_TH := Canvas.LO_TH
const TONE_SOFT := 0.075     # half-width of the blend between tones (the old dither spread about this far)
const SPECK_R := 0.6         # a speckle: a round dot on its art cell
const SPECK_K := 0.85        # and how strongly it shows
const FAR := 1000.0

var w: int                   # art units
var h: int
var k: int                   # pixels per art unit
var pw: int                  # pixels
var ph: int
var inv: float
var buf := PackedFloat32Array()   # straight-alpha RGBA, pw * ph * 4
var img: Image:
	get:
		return image()

func _init(width: int, height: int, scale := 2) -> void:
	w = width
	h = height
	k = maxi(1, scale)
	pw = w * k
	ph = h * k
	inv = 1.0 / float(k)
	buf.resize(pw * ph * 4)
	buf.fill(0.0)

func image() -> Image:
	var out := Image.create_from_data(pw, ph, false, Image.FORMAT_RGBAF, buf.to_byte_array())
	out.convert(Image.FORMAT_RGBA8)
	return out

# ---------- masks ----------

func _mask(bb: Rect2) -> Dictionary:
	var x0 := clampi(int(floor((bb.position.x - 1.0) * k)), 0, pw)
	var y0 := clampi(int(floor((bb.position.y - 1.0) * k)), 0, ph)
	var x1 := clampi(int(ceil((bb.end.x + 1.0) * k)), 0, pw)
	var y1 := clampi(int(ceil((bb.end.y + 1.0) * k)), 0, ph)
	var mw := maxi(0, x1 - x0)
	var mh := maxi(0, y1 - y0)
	var d := PackedFloat32Array()
	d.resize(mw * mh)
	d.fill(FAR)
	return {"x0": x0, "y0": y0, "w": mw, "h": mh, "d": d, "bb": bb}

func ellipse_mask(cx: float, cy: float, wid: float, hei: float, angle_deg := 0.0) -> Dictionary:
	var rx := maxf(wid * 0.5, 0.05)
	var ry := maxf(hei * 0.5, 0.05)
	var a := deg_to_rad(angle_deg)
	var ca := cos(a)
	var sa := sin(a)
	var ex := sqrt(rx * rx * ca * ca + ry * ry * sa * sa)
	var ey := sqrt(rx * rx * sa * sa + ry * ry * ca * ca)
	var m := _mask(Rect2(cx - ex, cy - ey, ex * 2.0, ey * 2.0))
	var d: PackedFloat32Array = m.d
	var irx2 := 1.0 / (rx * rx)
	var iry2 := 1.0 / (ry * ry)
	var mw: int = m.w
	for j in m.h:
		var dy: float = (m.y0 + j + 0.5) * inv - cy
		for i in mw:
			var dx: float = (m.x0 + i + 0.5) * inv - cx
			var lx := dx * ca + dy * sa
			var ly := -dx * sa + dy * ca
			var f := lx * lx * irx2 + ly * ly * iry2
			var gx := lx * irx2
			var gy := ly * iry2
			var g := 2.0 * sqrt(gx * gx + gy * gy)
			# first-order distance to the rim, (f - 1) / |grad f|: exact enough within a pixel or two of the edge
			d[j * mw + i] = clampf((f - 1.0) / maxf(g, 0.0001), -FAR, FAR)
	m.d = d
	return m

func rect_mask(cx: float, cy: float, wid: float, hei: float, angle_deg := 0.0, round_r := 0.0) -> Dictionary:
	var hw := wid * 0.5
	var hh := hei * 0.5
	var rr := clampf(round_r, 0.0, minf(hw, hh))
	var a := deg_to_rad(angle_deg)
	var ca := cos(a)
	var sa := sin(a)
	var ex := absf(ca) * hw + absf(sa) * hh
	var ey := absf(sa) * hw + absf(ca) * hh
	var m := _mask(Rect2(cx - ex, cy - ey, ex * 2.0, ey * 2.0))
	var d: PackedFloat32Array = m.d
	var mw: int = m.w
	for j in m.h:
		var dy: float = (m.y0 + j + 0.5) * inv - cy
		for i in mw:
			var dx: float = (m.x0 + i + 0.5) * inv - cx
			var qx := absf(dx * ca + dy * sa) - (hw - rr)
			var qy := absf(-dx * sa + dy * ca) - (hh - rr)
			var ox := maxf(qx, 0.0)
			var oy := maxf(qy, 0.0)
			d[j * mw + i] = sqrt(ox * ox + oy * oy) + minf(maxf(qx, qy), 0.0) - rr
	m.d = d
	return m

## Even-odd polygon: inside from the scanline crossings, distance from the nearest edge. Distances are only
## worked out near each edge (EDGE_BAND art units): further in or out, only the sign matters.
const EDGE_BAND := 1.6

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
	var d: PackedFloat32Array = m.d
	var n := pts.size()
	var mw: int = m.w
	var mh: int = m.h
	var segs: Array = []
	for e in n:
		segs.append([pts[e], pts[(e + 1) % n]])
	_seg_dist(d, m, segs)
	# the sign, row by row
	for j in mh:
		var sy: float = (m.y0 + j + 0.5) * inv
		var xs: Array = []
		for e in n:
			var pa: Vector2 = pts[e]
			var pb: Vector2 = pts[(e + 1) % n]
			if (pa.y <= sy and pb.y > sy) or (pb.y <= sy and pa.y > sy):
				xs.append(pa.x + (sy - pa.y) * (pb.x - pa.x) / (pb.y - pa.y))
		xs.sort()
		var q := 0
		while q + 1 < xs.size():
			var ia := maxi(0, int(ceil(float(xs[q]) * k - 0.5)) - m.x0)
			var ib := mini(mw - 1, int(floor(float(xs[q + 1]) * k - 0.5)) - m.x0)
			for i in range(ia, ib + 1):
				d[j * mw + i] = -d[j * mw + i]
			q += 2
	m.d = d
	return m

## Unsigned distance to a set of segments [[a, b], ...], written into `d` within EDGE_BAND of each one.
func _seg_dist(d: PackedFloat32Array, m: Dictionary, segs: Array, band := EDGE_BAND) -> void:
	var mw: int = m.w
	var mh: int = m.h
	var x0: int = m.x0
	var y0: int = m.y0
	for sg in segs:
		var a: Vector2 = sg[0]
		var b: Vector2 = sg[1]
		var ab := b - a
		var len2 := maxf(ab.length_squared(), 0.000001)
		var i0 := maxi(0, int(floor((minf(a.x, b.x) - band) * k)) - x0)
		var i1 := mini(mw - 1, int(ceil((maxf(a.x, b.x) + band) * k)) - x0)
		var j0 := maxi(0, int(floor((minf(a.y, b.y) - band) * k)) - y0)
		var j1 := mini(mh - 1, int(ceil((maxf(a.y, b.y) + band) * k)) - y0)
		for j in range(j0, j1 + 1):
			var py: float = (y0 + j + 0.5) * inv - a.y
			for i in range(i0, i1 + 1):
				var px_: float = (x0 + i + 0.5) * inv - a.x
				var t := clampf((px_ * ab.x + py * ab.y) / len2, 0.0, 1.0)
				var qx := px_ - ab.x * t
				var qy := py - ab.y * t
				var dist := sqrt(qx * qx + qy * qy)
				var o := j * mw + i
				if dist < d[o]:
					d[o] = dist

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
	var d: PackedFloat32Array = m.d
	var segs: Array = []
	for s in maxi(1, pts.size() - 1):
		segs.append([pts[s], pts[mini(s + 1, pts.size() - 1)]])
	_seg_dist(d, m, segs, r + EDGE_BAND)
	for o in d.size():
		d[o] = d[o] - r
	m.d = d
	return m

# ---------- painting ----------

static func _smooth(e0: float, e1: float, x: float) -> float:
	var t := clampf((x - e0) / (e1 - e0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)

## The three tones blended by light: shadow below LO_TH, highlight above HI_TH, soft in between.
static func _tone(tn: Array, ws: float, wh: float) -> Color:
	var c: Color = tn[0]
	if ws > 0.0:
		c = c.lerp(tn[1], ws)
	if wh > 0.0:
		c = c.lerp(tn[2], wh)
	return c

## Writes `col` with coverage `cov` over the pixel at buffer index `o` (straight alpha, source over).
func _over(o: int, col: Color, cov: float) -> void:
	var da: float = buf[o + 3]
	var oa := cov + da * (1.0 - cov)
	if oa <= 0.0:
		return
	var kd := da * (1.0 - cov)
	buf[o] = (col.r * cov + buf[o] * kd) / oa
	buf[o + 1] = (col.g * cov + buf[o + 1] * kd) / oa
	buf[o + 2] = (col.b * cov + buf[o + 2] * kd) / oa
	buf[o + 3] = oa

## opt: shade(bool), rim(bool), pattern, pcol(tones or null), seed, period, angle, density, n (as canvas.gd)
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
	var period: float = maxf(float(opt.get("period", 6.0)), 0.5)
	var ang: float = deg_to_rad(float(opt.get("angle", 60.0)))
	var density: int = int(opt.get("density", 9))
	var nspine: float = float(opt.get("n", 26))
	var lo_th: float = float(opt.get("lo", LO_TH))
	var hi_th: float = float(opt.get("hi", HI_TH))
	var ca := cos(ang)
	var sa := sin(ang)
	var d: PackedFloat32Array = m.d
	var mw: int = m.w
	var mh: int = m.h
	var fk := float(k)
	var rim_tl: Color = tn[0].darkened(0.32)
	var rim_br: Color = tn[1].darkened(0.22)
	var t0: Color = tn[0]
	var t1: Color = tn[1]
	var t2: Color = tn[2]
	var lo_a := lo_th - TONE_SOFT
	var hi_a := hi_th - TONE_SOFT
	var tone_w := 1.0 / (2.0 * TONE_SOFT)
	for j in mh:
		var y: int = m.y0 + j
		var fy := (y + 0.5) * inv
		var ny := (fy - cy) / ry
		for i in mw:
			var dd: float = d[j * mw + i]
			var cov := clampf(0.5 - dd * fk, 0.0, 1.0)
			if cov <= 0.0:
				continue
			var x: int = m.x0 + i
			var fx := (x + 0.5) * inv
			var nx := (fx - cx) / rx
			var ws := 0.0
			var wh := 0.0
			var col := t0
			if shade:
				var z := sqrt(maxf(0.0, 1.0 - nx * nx - ny * ny))
				var l := 0.55 * (-(nx * 0.6 + ny * 0.8)) + 0.5 * z
				# smoothsteps either side of the two thresholds, written out (this loop is the renderer's hot path)
				var ts := clampf((l - lo_a) * tone_w, 0.0, 1.0)
				ws = 1.0 - ts * ts * (3.0 - 2.0 * ts)
				var th := clampf((l - hi_a) * tone_w, 0.0, 1.0)
				wh = th * th * (3.0 - 2.0 * th)
				if ws > 0.0:
					col = t0.lerp(t1, ws)
				elif wh > 0.0:
					col = t0.lerp(t2, wh)
			if pattern != "none":
				var pc := 0.0
				match pattern:
					"speckle":
						var cxi := int(floor(fx))
						var cyi := int(floor(fy))
						if Canvas.hash2(cxi, cyi, sd) < density:
							var ddx := fx - (cxi + 0.5)
							var ddy := fy - (cyi + 0.5)
							pc = clampf((SPECK_R - sqrt(ddx * ddx + ddy * ddy)) * fk + 0.5, 0.0, 1.0) * SPECK_K
					"stripes":
						var u := fx * ca + fy * sa
						var s := fposmod(u, period)
						var band := 0.38 * period
						var inside := minf(s, band - s) if s < band else -minf(s - band, period - s)
						pc = clampf(inside * fk + 0.5, 0.0, 1.0)
					"spines":
						var a2 := atan2(fy - cy, fx - cx)
						var fr := fposmod(a2 * nspine / TAU, 1.0)
						var rr := sqrt(nx * nx + ny * ny)
						var arc := maxf(sqrt((fx - cx) * (fx - cx) + (fy - cy) * (fy - cy)) * fk * TAU / nspine, 1.0)
						var on := _smooth(0.24, 0.32, rr)
						if fr < 0.30 or fr > 0.95:
							var e := minf(fr, 0.30 - fr) if fr < 0.30 else 0.0
							pc = clampf(e * arc + 0.5, 0.0, 1.0) * on
						elif fr > 0.62 and fr < 0.8:
							var e2 := minf(fr - 0.62, 0.8 - fr)
							var hk := clampf(e2 * arc + 0.5, 0.0, 1.0) * _smooth(0.46, 0.54, rr)
							col = col.lerp(tn[2], hk)
						if pc > 0.0:
							col = col.lerp(pcol[0].lerp(pcol[1], ws) if pcol != null else tn[1], pc)
						pc = 0.0
				if pc > 0.0:
					var p2: Color
					if pcol != null:
						p2 = _tone(pcol, ws, wh)
					else:
						p2 = tn[1] if wh < 0.5 else tn[0]
					col = col.lerp(p2, pc)
			if rim:
				var wr := clampf((dd + 1.0) * fk + 0.5, 0.0, 1.0)
				if wr > 0.0:
					var gx: float = d[j * mw + mini(i + 1, mw - 1)] - d[j * mw + maxi(i - 1, 0)]
					var gy: float = d[mini(j + 1, mh - 1) * mw + i] - d[maxi(j - 1, 0) * mw + i]
					var gl := sqrt(gx * gx + gy * gy)
					var br := 1.0
					if gl > 0.00001:
						br = _smooth(-0.35, 0.15, maxf(gx, gy) / gl)
					col = col.lerp(rim_tl.lerp(rim_br, br), wr)
			var o := (y * pw + x) * 4
			var da: float = buf[o + 3]
			if cov >= 1.0 or da <= 0.0:
				buf[o] = col.r
				buf[o + 1] = col.g
				buf[o + 2] = col.b
				buf[o + 3] = 1.0 if cov >= 1.0 else cov
			else:
				var oa := cov + da * (1.0 - cov)
				var kd := da * (1.0 - cov)
				buf[o] = (col.r * cov + buf[o] * kd) / oa
				buf[o + 1] = (col.g * cov + buf[o + 1] * kd) / oa
				buf[o + 2] = (col.b * cov + buf[o + 2] * kd) / oa
				buf[o + 3] = oa

## A soft disc in one colour.
func disc(cx: float, cy: float, r: float, col: Color) -> void:
	_fill(ellipse_mask(cx, cy, r * 2.0, r * 2.0), col)

func _fill(m: Dictionary, col: Color) -> void:
	var d: PackedFloat32Array = m.d
	var mw: int = m.w
	var fk := float(k)
	for j in m.h:
		for i in mw:
			var cov := clampf(0.5 - d[j * mw + i] * fk, 0.0, 1.0)
			if cov > 0.0:
				_over(((m.y0 + j) * pw + m.x0 + i) * 4, col, cov)

## A one-art-unit outline round the silhouette: the shape's own colours darkened (or `col`), spread one art unit
## out with soft edges, under the drawing.
func outline(col = null) -> void:
	var src := Image.create_from_data(pw, ph, false, Image.FORMAT_RGBAF, buf.to_byte_array())
	var dark := PackedFloat32Array()
	dark.resize(buf.size())
	dark.fill(0.0)
	var ink := Color(0.08, 0.05, 0.12)
	var n := pw * ph
	for p in n:
		var o := p * 4
		var a: float = buf[o + 3]
		if a <= 0.0:
			continue
		var c: Color
		if col == null:
			c = Color(buf[o], buf[o + 1], buf[o + 2]).darkened(0.62).lerp(ink, 0.35)
		else:
			c = col
		dark[o] = c.r
		dark[o + 1] = c.g
		dark[o + 2] = c.b
		dark[o + 3] = clampf(a * 1.6, 0.0, 1.0)
	var dimg := Image.create_from_data(pw, ph, false, Image.FORMAT_RGBAF, dark.to_byte_array())
	var out := Image.create(pw, ph, false, Image.FORMAT_RGBAF)
	var full := Rect2i(0, 0, pw, ph)
	for off in _ring(k):
		out.blend_rect(dimg, full, off)
	out.blend_rect(src, full, Vector2i.ZERO)
	buf = out.get_data().to_float32_array()

## Offsets within `r` pixels, farthest first (so the nearest part's colour ends up on top).
static func _ring(r: int) -> Array:
	var offs: Array = []
	var lim := (float(r) + 0.35) * (float(r) + 0.35)
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if (dx != 0 or dy != 0) and dx * dx + dy * dy <= lim:
				offs.append(Vector2i(dx, dy))
	offs.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.length_squared() > b.length_squared())
	return offs

func eye(cx: float, cy: float, r: float, col: Color, hi := true, pupil = null) -> void:
	disc(cx, cy, r, col)
	if pupil != null:
		_fill(ellipse_mask(cx, cy, float(pupil[0]), float(pupil[1])), Color("#1d1822"))
	if hi:
		# where canvas.gd puts its highlight pixels, as soft round glints
		var hx: float = roundf(cx - r * 0.35 - 0.5) + 0.5
		var hy: float = roundf(cy - r * 0.40 - 0.5) + 0.5
		if r >= 3.5:
			_fill(ellipse_mask(hx + 0.5, hy, 2.0, 1.3), Color.WHITE)
			disc(roundf(cx + r * 0.4 - 0.5) + 0.5, roundf(cy + r * 0.45 - 0.5) + 0.5, 0.5, Color(0.75, 0.8, 0.9))
		else:
			disc(hx, hy, 0.6, Color.WHITE)

## The drawn area in art units (pixels at least half covered).
func content_bounds() -> Rect2i:
	var x0 := pw
	var y0 := ph
	var x1 := -1
	var y1 := -1
	for y in ph:
		for x in pw:
			if buf[(y * pw + x) * 4 + 3] >= 0.5:
				x0 = mini(x0, x)
				x1 = maxi(x1, x)
				y0 = mini(y0, y)
				y1 = maxi(y1, y)
	if x1 < 0:
		return Rect2i(0, 0, 0, 0)
	var ax0 := x0 / k
	var ay0 := y0 / k
	var ax1 := x1 / k
	var ay1 := y1 / k
	return Rect2i(ax0, ay0, ax1 - ax0 + 1, ay1 - ay0 + 1)
