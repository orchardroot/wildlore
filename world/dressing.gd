class_name Dressing
extends RefCounted
## Props that make places look lived in: bunting, flags, washing lines, hanging baskets outdoors; rugs,
## fireplaces, pictures, pianos and the like indoors. Same rules as Meshes: vertex colours, y = 0 at the
## origin, one tile unless noted. Anything cloth (bunting, flags, laundry) is built in the local XY plane and
## carries its flutter in the vertex alpha (0 = pinned, 1 = free), see art/shaders/flutter.gdshader. Wall
## things sit against the north wall: their back is at local z = -0.5, so `rot` turns them to another wall.

const IRON := Color("2d3138")
const WOOD := Color("7a5636")
const DARK_WOOD := Color("5a3f2a")
const STONE := Color("9b927f")
const BRASS := Color("c9a441")
const CLOTH := [Color("c9483f"), Color("f2ede2"), Color("2f6f9e"), Color("e0b83a"), Color("3f8a55")]

# --- helpers -------------------------------------------------------------------

static func _a(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, a)

## A quad with its own flutter alpha per corner.
static func _fquad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color, aa: float, ab: float, ac: float, ad: float) -> void:
	var n := Vector3(0, 0, 1)
	for pair in [[a, aa], [b, ab], [c, ac], [a, aa], [c, ac], [d, ad]]:
		st.set_color(_a(col, pair[1]))
		st.set_normal(n)
		st.add_vertex(pair[0])

static func _ftri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color, aa: float, ab: float, ac: float) -> void:
	for pair in [[a, aa], [b, ab], [c, ac]]:
		st.set_color(_a(col, pair[1]))
		st.set_normal(Vector3(0, 0, 1))
		st.add_vertex(pair[0])

## A thin four-sided bar from `a` to `b`.
static func _bar(st: SurfaceTool, a: Vector3, b: Vector3, r: float, col: Color, alpha := 1.0) -> void:
	col = _a(col, alpha)
	var dir := (b - a).normalized()
	var up := Vector3.UP if absf(dir.dot(Vector3.UP)) < 0.9 else Vector3.RIGHT
	var s := dir.cross(up).normalized() * r
	var t := dir.cross(s).normalized() * r
	var ring_a := [a + s + t, a - s + t, a - s - t, a + s - t]
	var ring_b := [b + s + t, b - s + t, b - s - t, b + s - t]
	for i in 4:
		var j := (i + 1) % 4
		Meshes._quad(st, ring_a[i], ring_a[j], ring_b[j], ring_b[i], col.darkened(0.06 * i))
	Meshes._quad(st, ring_b[0], ring_b[1], ring_b[2], ring_b[3], col)

## A disc standing in the XY plane at z, facing +z.
static func _disc_z(st: SurfaceTool, c: Vector3, r: float, sides: int, col: Color) -> void:
	for i in sides:
		var a0 := TAU * i / sides
		var a1 := TAU * (i + 1) / sides
		Meshes._tri(st, c, c + Vector3(cos(a1) * r, sin(a1) * r, 0), c + Vector3(cos(a0) * r, sin(a0) * r, 0), col)

## A flat quad lying on the floor, for rugs and light pools.
static func floor_quad(st: SurfaceTool, x0: float, z0: float, x1: float, z1: float, y: float, col: Color) -> void:
	Meshes._quad(st, Vector3(x0, y, z0), Vector3(x1, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z1), col)

# --- outdoors ------------------------------------------------------------------

## Unit quad (centred, lying flat, UV 0..1) for light pools; the pool shader paints the falloff.
static func pool_quad() -> ArrayMesh:
	var st := Meshes._st()
	for c in [[-0.5, -0.5], [0.5, -0.5], [0.5, 0.5], [-0.5, -0.5], [0.5, 0.5], [-0.5, 0.5]]:
		st.set_normal(Vector3.UP)
		st.set_uv(Vector2(c[0] + 0.5, c[1] + 0.5))
		st.add_vertex(Vector3(c[0], 0, c[1]))
	return Meshes._finish(st)

## Bunting strung from this tile's centre east for `length` tiles (variant), sagging in the middle. It is meant to
## hang between two lamp posts or from eave to eave, so the ends sit at lamp-top height.
static func bunting(length := 3) -> ArrayMesh:
	var st := Meshes._st()
	var l := float(maxi(length, 1))
	var top := 1.7
	var sag := 0.2 + 0.03 * l
	var steps := int(l * 4.0)
	var prev := Vector3(0, top, 0)
	for i in range(1, steps + 1):
		var x := l * i / steps
		var y := top - sag * 4.0 * (x / l) * (1.0 - x / l)
		var cur := Vector3(x, y, 0)
		_bar(st, prev, cur, 0.012, Color("3a3028"), 0.0)
		prev = cur
	var flags := int(l * 4.0)
	for i in flags:
		var x := l * (i + 0.5) / flags
		var y := top - sag * 4.0 * (x / l) * (1.0 - x / l)
		var c: Color = CLOTH[i % CLOTH.size()]
		_ftri(st, Vector3(x - 0.07, y, 0), Vector3(x + 0.07, y, 0), Vector3(x, y - 0.2, 0), c, 0.0, 0.0, 1.0)
	return Meshes._finish(st)

const FLAG_W := 1.0
const FLAG_H := 0.62
const FLAG_Y := 2.2
const FLAG_COLS := 16
const FLAG_ROWS := 10
## Flag names by variant: Welsh dragon, Saltire, Irish tricolour, Manx triskelion, St George, St Piran, Union.
const FLAGS := ["dragon", "saltire", "tricolour", "triskelion", "st_george", "st_piran", "union"]

static func flagpole(_variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	Meshes.box(st, Vector3(-0.1, 0, -0.1), Vector3(0.2, 0.14, 0.2), STONE)
	Meshes.cylinder(st, Vector3(0, 0.14, 0), 0.035, 2.65, 6, Color("d8d4c8"))
	Meshes.blob(st, Vector3(0, 2.85, 0), Vector3(0.06, 0.06, 0.06), BRASS, Meshes._rng(77), 0.02)
	return Meshes._finish(st)

## The cloth of a flagpole, flying east (+x) from the pole. Pinned at the pole, free at the fly.
static func flag(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var name: String = FLAGS[variant % FLAGS.size()]
	var cw := FLAG_W / FLAG_COLS
	var ch := FLAG_H / FLAG_ROWS
	for r in FLAG_ROWS:
		for c in FLAG_COLS:
			var u := (c + 0.5) / FLAG_COLS
			var v := (r + 0.5) / FLAG_ROWS  # 0 top .. 1 bottom
			var col := _flag_colour(name, u, v)
			var x0 := 0.04 + c * cw
			var y1 := FLAG_Y + FLAG_H - r * ch
			var a0 := float(c) / FLAG_COLS
			var a1 := float(c + 1) / FLAG_COLS
			_fquad(st, Vector3(x0, y1 - ch, 0), Vector3(x0 + cw, y1 - ch, 0), Vector3(x0 + cw, y1, 0), Vector3(x0, y1, 0), col, a0, a1, a1, a0)
	return Meshes._finish(st)

static func _flag_colour(name: String, u: float, v: float) -> Color:
	var a := u - 0.5
	var b := (v - 0.5) * (FLAG_H / FLAG_W) * 1.6  # aspect-corrected so diagonals run corner to corner
	var red := Color("c8102e")
	var white := Color("f4f1e8")
	var blue := Color("1f3f8f")
	match name:
		"dragon":
			var col := white if v < 0.5 else Color("1f7a3a")
			var dx := (u - 0.5) / 0.26
			var dy := (v - 0.5) / 0.3
			if dx * dx + dy * dy < 1.0 or (absf(u - 0.28) < 0.07 and absf(v - 0.22) < 0.13) or (u > 0.66 and u < 0.82 and v > 0.5 and v < 0.62):
				col = red
			return col
		"saltire":
			return white if absf(absf(a) - absf((v - 0.5) * 1.0)) < 0.1 else Color("0065bd")
		"tricolour":
			if u < 0.333:
				return Color("169b62")
			return white if u < 0.667 else Color("ff883e")
		"triskelion":
			var col := red
			var dx := u - 0.5
			var dy := (v - 0.5) * 1.5
			var rad := sqrt(dx * dx + dy * dy)
			var ang := fposmod(atan2(dy, dx) + PI * 0.5, TAU / 3.0)
			if rad < 0.07 or (rad < 0.26 and ang < 0.9 and ang > 0.1 and rad > 0.07 + ang * 0.05):
				col = Color("c9ccd2")
			return col
		"st_george":
			return red if (absf(u - 0.5) < 0.09 or absf(v - 0.5) < 0.14) else white
		"st_piran":
			return white if (absf(u - 0.5) < 0.09 or absf(v - 0.5) < 0.14) else Color("111111")
		"union":
			var dgl := absf(absf(a) - absf((v - 0.5) * 1.0))
			if absf(u - 0.5) < 0.05 or absf(v - 0.5) < 0.09:
				return red
			if absf(u - 0.5) < 0.1 or absf(v - 0.5) < 0.17:
				return white
			if dgl < 0.035:
				return red
			if dgl < 0.1:
				return white
			return blue
	return white

## A washing line `length` tiles (variant) east of this tile's centre between two posts, with a mixed load.
static func washing_line(length := 2) -> ArrayMesh:
	var rng := Meshes._rng(31000 + length)
	var st := Meshes._st()
	var l := float(maxi(length, 1))
	var top := 1.35
	for px in [0.0, l]:
		_bar(st, Vector3(px, 0, 0), Vector3(px, top + 0.08, 0), 0.025, WOOD, 0.0)
	var sag := 0.05 + 0.02 * l
	var steps := int(l * 4.0)
	var prev := Vector3(0, top, 0)
	for i in range(1, steps + 1):
		var x := l * i / steps
		var cur := Vector3(x, top - sag * 4.0 * (x / l) * (1.0 - x / l), 0)
		_bar(st, prev, cur, 0.008, Color("e8e2d4"), 0.0)
		prev = cur
	var x := 0.3
	while x < l - 0.25:
		var y := top - sag * 4.0 * (x / l) * (1.0 - x / l)
		var c: Color = [Color("f2ede2"), Color("c9483f"), Color("2f6f9e"), Color("e0b83a"), Color("d8a0b0"), Color("f2ede2")][rng.randi() % 6]
		match rng.randi() % 4:
			0:  # a sheet
				_fquad(st, Vector3(x - 0.16, y - 0.55, 0), Vector3(x + 0.16, y - 0.55, 0), Vector3(x + 0.16, y, 0), Vector3(x - 0.16, y, 0), c, 1.0, 1.0, 0.1, 0.1)
				x += 0.45
			1:  # a shirt: body and sleeves
				_fquad(st, Vector3(x - 0.09, y - 0.38, 0), Vector3(x + 0.09, y - 0.38, 0), Vector3(x + 0.09, y, 0), Vector3(x - 0.09, y, 0), c, 1.0, 1.0, 0.1, 0.1)
				_fquad(st, Vector3(x - 0.2, y - 0.2, 0), Vector3(x + 0.2, y - 0.2, 0), Vector3(x + 0.2, y - 0.04, 0), Vector3(x - 0.2, y - 0.04, 0), c.darkened(0.05), 1.0, 1.0, 0.2, 0.2)
				x += 0.38
			2:  # trousers
				_fquad(st, Vector3(x - 0.1, y - 0.5, 0), Vector3(x - 0.01, y - 0.5, 0), Vector3(x - 0.01, y, 0), Vector3(x - 0.1, y, 0), c, 1.0, 1.0, 0.1, 0.1)
				_fquad(st, Vector3(x + 0.01, y - 0.5, 0), Vector3(x + 0.1, y - 0.5, 0), Vector3(x + 0.1, y, 0), Vector3(x + 0.01, y, 0), c.darkened(0.04), 1.0, 1.0, 0.1, 0.1)
				x += 0.3
			3:  # socks
				for k in 2:
					var sx := x + k * 0.1
					_fquad(st, Vector3(sx - 0.03, y - 0.16, 0), Vector3(sx + 0.03, y - 0.16, 0), Vector3(sx + 0.03, y, 0), Vector3(sx - 0.03, y, 0), c, 1.0, 1.0, 0.1, 0.1)
				x += 0.28
	return Meshes._finish(st)

## A basket of flowers. Variant 0 hangs from a lamp post on this tile (bracket reaching east); variant 1 hangs
## from the south wall of the building on this tile, over the pavement.
static func hanging_basket(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(32000 + variant)
	var st := Meshes._st()
	var at := Vector3(0.3, 1.3, 0)
	if variant == 1:
		at = Vector3(0, 1.05, 0.62)
		_bar(st, Vector3(0, 1.16, 0.44), Vector3(0, 1.16, 0.62), 0.015, IRON)
		_bar(st, Vector3(0, 0.98, 0.44), Vector3(0, 1.16, 0.62), 0.012, IRON)
	else:
		_bar(st, Vector3(0.03, 1.5, 0), Vector3(0.3, 1.5, 0), 0.015, IRON)
		_bar(st, Vector3(0.03, 1.3, 0), Vector3(0.3, 1.5, 0), 0.012, IRON)
	Meshes.blob(st, at + Vector3(0, -0.06, 0), Vector3(0.13, 0.09, 0.13), Color("5a4632"), rng, 0.05)
	Meshes.blob(st, at + Vector3(0, 0.03, 0), Vector3(0.16, 0.08, 0.16), Color("4c7a39"), rng, 0.25)
	for i in 7:
		var p := at + Vector3(rng.randf_range(-0.12, 0.12), 0.08 + rng.randf_range(0.0, 0.04), rng.randf_range(-0.12, 0.12))
		var c: Color = [Color("d8566b"), Color("9b6fb0"), Color("f2f0e6"), Color("e8d34a"), Color("e0703a")][rng.randi() % 5]
		Meshes.box(st, p - Vector3(0.025, 0, 0.025), Vector3(0.05, 0.045, 0.05), c)
	for i in 3:
		var p := at + Vector3(rng.randf_range(-0.12, 0.12), -0.14, rng.randf_range(-0.12, 0.12))
		Meshes.box(st, p, Vector3(0.025, 0.1, 0.025), Color("4c7a39"))
	return Meshes._finish(st)

# --- indoors -------------------------------------------------------------------

const RUGS := [[Color("8c2f39"), Color("e0c27a")], [Color("2f5a7a"), Color("d8d2c2")], [Color("3f6b4a"), Color("c9a441")], [Color("6a4a7a"), Color("e8d8b8")]]

## A rug filling its tile (the builder stretches it over `w` x `h` tiles), border and centre stripe.
static func rug(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var pal: Array = RUGS[variant % RUGS.size()]
	var main: Color = pal[0]
	var trim: Color = pal[1]
	floor_quad(st, -0.46, -0.46, 0.46, 0.46, 0.012, trim)
	floor_quad(st, -0.4, -0.4, 0.4, 0.4, 0.016, main)
	floor_quad(st, -0.3, -0.3, 0.3, 0.3, 0.02, trim.darkened(0.15))
	floor_quad(st, -0.26, -0.26, 0.26, 0.26, 0.024, main.lightened(0.08))
	return Meshes._finish(st)

static func fireplace() -> ArrayMesh:
	var st := Meshes._st()
	var brick := Color("8a5a48")
	Meshes.box(st, Vector3(-0.46, 0, -0.5), Vector3(0.92, 0.08, 0.5), STONE.darkened(0.1))
	Meshes.box(st, Vector3(-0.42, 0.08, -0.5), Vector3(0.14, 1.0, 0.34), brick)
	Meshes.box(st, Vector3(0.28, 0.08, -0.5), Vector3(0.14, 1.0, 0.34), brick)
	Meshes.box(st, Vector3(-0.42, 1.08, -0.5), Vector3(0.84, 0.18, 0.34), brick)
	Meshes.box(st, Vector3(-0.28, 0.08, -0.5), Vector3(0.56, 1.0, 0.1), Color("1d1a18"))
	Meshes.box(st, Vector3(-0.5, 1.26, -0.5), Vector3(1.0, 0.07, 0.44), WOOD.lightened(0.1))
	Meshes.box(st, Vector3(-0.3, 1.33, -0.5), Vector3(0.6, 0.9, 0.2), brick.darkened(0.08))
	Meshes.box(st, Vector3(-0.22, 0.08, -0.35), Vector3(0.44, 0.07, 0.07), DARK_WOOD)
	return Meshes._finish(st)

## The fire itself and the pool of warm light it throws on the floor, additive, flickering (firelight shader).
static func fireplace_fire() -> ArrayMesh:
	var st := Meshes._st()
	var rng := Meshes._rng(33000)
	for i in 3:
		var x := -0.15 + i * 0.15
		var h := 0.38 - absf(i - 1) * 0.1
		var base := Vector3(x, 0.16, -0.36)
		var tip := base + Vector3(0, h, 0.02)
		Meshes._tri(st, base + Vector3(-0.09, 0, 0), base + Vector3(0.09, 0, 0), tip, Color(1.0, 0.45, 0.1, 1.0))
		var core := base + Vector3(0, 0, 0.01)
		Meshes._tri(st, core + Vector3(-0.045, 0, 0), core + Vector3(0.045, 0, 0), core + Vector3(0, h * 0.65, 0.01), Color(1.0, 0.85, 0.35, 1.0))
	# the pool on the floor: warm in the middle, fading out
	var steps := 10
	for i in steps:
		var a0 := TAU * i / steps
		var a1 := TAU * (i + 1) / steps
		var c := Vector3(0, 0.03, 0.15)
		var p0 := c + Vector3(cos(a0) * 1.15, 0, sin(a0) * 0.8)
		var p1 := c + Vector3(cos(a1) * 1.15, 0, sin(a1) * 0.8)
		for pair in [[c, 0.5], [p1, 0.0], [p0, 0.0]]:
			st.set_color(Color(1.0, 0.55, 0.2, pair[1]))
			st.set_normal(Vector3.UP)
			st.add_vertex(pair[0])
	return Meshes._finish(st)

## A framed picture on the north wall. 0 hills, 1 portrait, 2 seascape.
static func wall_picture(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var frame: Color = [Color("8a6a2e"), Color("3a2a22"), Color("c9a441")][variant % 3]
	Meshes.box(st, Vector3(-0.27, 1.25, -0.5), Vector3(0.54, 0.44, 0.04), frame)
	var z := -0.455
	match variant % 3:
		0:
			Meshes.box(st, Vector3(-0.22, 1.3, z), Vector3(0.44, 0.34, 0.01), Color("9fc3dc"))
			Meshes.box(st, Vector3(-0.22, 1.3, z), Vector3(0.44, 0.15, 0.015), Color("5d8a3f"))
			Meshes.box(st, Vector3(-0.1, 1.44, z), Vector3(0.2, 0.08, 0.02), Color("466d34"))
		1:
			Meshes.box(st, Vector3(-0.22, 1.3, z), Vector3(0.44, 0.34, 0.01), Color("4a3b32"))
			Meshes.blob(st, Vector3(0, 1.5, z + 0.01), Vector3(0.09, 0.1, 0.01), Color("e0b99a"), Meshes._rng(5), 0.02)
			Meshes.box(st, Vector3(-0.13, 1.3, z), Vector3(0.26, 0.1, 0.02), Color("2f3a5a"))
		2:
			Meshes.box(st, Vector3(-0.22, 1.3, z), Vector3(0.44, 0.34, 0.01), Color("c9d8dc"))
			Meshes.box(st, Vector3(-0.22, 1.3, z), Vector3(0.44, 0.16, 0.015), Color("2f6f8a"))
			Meshes.box(st, Vector3(-0.05, 1.44, z), Vector3(0.12, 0.1, 0.02), Color("f2ede2"))
	return Meshes._finish(st)

static func clock() -> ArrayMesh:
	var st := Meshes._st()
	var c := Vector3(0, 1.55, -0.47)
	_disc_z(st, c, 0.24, 10, DARK_WOOD)
	_disc_z(st, c + Vector3(0, 0, 0.012), 0.2, 10, Color("f2ede2"))
	for i in 4:
		var a := TAU * i / 4.0
		Meshes.box(st, c + Vector3(cos(a) * 0.15 - 0.012, sin(a) * 0.15 - 0.012, 0.015), Vector3(0.024, 0.024, 0.01), IRON)
	_bar(st, c + Vector3(0, 0, 0.03), c + Vector3(0.0, 0.14, 0.03), 0.01, IRON)
	_bar(st, c + Vector3(0, 0, 0.035), c + Vector3(0.09, -0.03, 0.035), 0.012, IRON)
	return Meshes._finish(st)

static func kitchen_dresser() -> ArrayMesh:
	var st := Meshes._st()
	var blue := Color("3f6a8a")
	Meshes.box(st, Vector3(-0.46, 0, -0.5), Vector3(0.92, 0.7, 0.42), blue)
	Meshes.box(st, Vector3(-0.44, 0.7, -0.5), Vector3(0.88, 0.04, 0.46), blue.lightened(0.15))
	Meshes.box(st, Vector3(-0.44, 0.74, -0.5), Vector3(0.06, 1.0, 0.2), blue)
	Meshes.box(st, Vector3(0.38, 0.74, -0.5), Vector3(0.06, 1.0, 0.2), blue)
	Meshes.box(st, Vector3(-0.44, 1.7, -0.5), Vector3(0.88, 0.06, 0.24), blue.darkened(0.05))
	for y in [0.96, 1.3]:
		Meshes.box(st, Vector3(-0.4, y, -0.46), Vector3(0.8, 0.03, 0.14), blue.lightened(0.1))
		for i in 4:
			Meshes.box(st, Vector3(-0.33 + i * 0.2, y + 0.03, -0.45), Vector3(0.14, 0.14, 0.02), Color("f2ede2"))
	for i in 3:
		Meshes.box(st, Vector3(-0.3 + i * 0.28, 0.74, -0.38), Vector3(0.08, 0.07, 0.08), [Color("c9483f"), Color("e0b83a"), Color("f2ede2")][i])
	Meshes.box(st, Vector3(-0.04, 0.4, -0.08), Vector3(0.08, 0.03, 0.02), BRASS)
	return Meshes._finish(st)

## The chippy's range: a steel counter with two vats and a basket.
static func fryer() -> ArrayMesh:
	var st := Meshes._st()
	var steel := Color("b4bcc4")
	Meshes.box(st, Vector3(-0.46, 0, -0.42), Vector3(0.92, 0.82, 0.84), steel.darkened(0.15), steel)
	for i in 2:
		Meshes.box(st, Vector3(-0.38 + i * 0.4, 0.82, -0.34), Vector3(0.32, 0.03, 0.4), Color("d9a441"))
	Meshes.box(st, Vector3(-0.44, 0.82, 0.26), Vector3(0.88, 0.06, 0.12), steel.lightened(0.1))
	Meshes.box(st, Vector3(-0.3, 0.85, -0.3), Vector3(0.18, 0.08, 0.24), Color("2d3138"))
	_bar(st, Vector3(-0.21, 0.9, -0.3), Vector3(-0.21, 0.95, 0.1), 0.01, Color("2d3138"))
	Meshes.box(st, Vector3(-0.35, 0.9, -0.05), Vector3(0.14, 0.02, 0.14), Color("e8c060"))
	Meshes.box(st, Vector3(0.1, 0.82, -0.42), Vector3(0.24, 0.5, 0.04), steel.lightened(0.1))
	return Meshes._finish(st)

## A chalk menu board on the north wall.
static func menu_board() -> ArrayMesh:
	var st := Meshes._st()
	Meshes.box(st, Vector3(-0.42, 1.0, -0.5), Vector3(0.84, 0.74, 0.05), WOOD)
	Meshes.box(st, Vector3(-0.38, 1.04, -0.455), Vector3(0.76, 0.66, 0.01), Color("2c3a34"))
	var rng := Meshes._rng(34000)
	for i in 5:
		var w := rng.randf_range(0.28, 0.6)
		Meshes.box(st, Vector3(-0.32, 1.58 - i * 0.12, -0.445), Vector3(w, 0.03, 0.01), Color("e8e2d4"))
		Meshes.box(st, Vector3(0.26, 1.58 - i * 0.12, -0.445), Vector3(0.07, 0.03, 0.01), Color("e8e2d4"))
	return Meshes._finish(st)

static func piano() -> ArrayMesh:
	var st := Meshes._st()
	var black := Color("26262c")
	Meshes.box(st, Vector3(-0.46, 0, -0.46), Vector3(0.92, 1.1, 0.4), black)
	Meshes.box(st, Vector3(-0.46, 0.7, -0.08), Vector3(0.92, 0.06, 0.3), black.lightened(0.05))
	for i in 12:
		Meshes.box(st, Vector3(-0.42 + i * 0.07, 0.76, -0.06), Vector3(0.06, 0.02, 0.24), Color("f2ede2"))
	for i in 8:
		Meshes.box(st, Vector3(-0.4 + i * 0.07 + (0.04 if i > 2 else 0.0), 0.78, -0.06), Vector3(0.035, 0.02, 0.14), black)
	for px in [-0.42, 0.34]:
		Meshes.box(st, Vector3(px, 0, -0.08), Vector3(0.08, 0.7, 0.3), black.lightened(0.04))
	Meshes.box(st, Vector3(-0.17, 0.0, 0.26), Vector3(0.34, 0.3, 0.2), DARK_WOOD)
	Meshes.box(st, Vector3(-0.19, 0.3, 0.24), Vector3(0.38, 0.06, 0.24), Color("8c2f39"))
	return Meshes._finish(st)

static func telescope() -> ArrayMesh:
	var st := Meshes._st()
	var hub := Vector3(0, 0.82, 0)
	for ang in [0.0, TAU / 3, 2 * TAU / 3]:
		_bar(st, hub, Vector3(cos(ang) * 0.3, 0, sin(ang) * 0.3), 0.018, WOOD)
	_bar(st, hub + Vector3(-0.2, -0.1, 0.2), hub + Vector3(0.28, 0.5, -0.3), 0.05, BRASS)
	_bar(st, hub + Vector3(0.28, 0.5, -0.3), hub + Vector3(0.38, 0.62, -0.4), 0.065, BRASS.darkened(0.2))
	Meshes.box(st, hub + Vector3(-0.06, -0.08, -0.06), Vector3(0.12, 0.12, 0.12), IRON)
	return Meshes._finish(st)

static func plant_stand(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(35000 + variant)
	var st := Meshes._st()
	for ang in [0.4, 2.5, 4.6]:
		_bar(st, Vector3(0, 0.62, 0), Vector3(cos(ang) * 0.2, 0, sin(ang) * 0.2), 0.015, WOOD)
	Meshes.cylinder(st, Vector3(0, 0.6, 0), 0.22, 0.04, 8, WOOD.lightened(0.1))
	Meshes.cylinder(st, Vector3(0, 0.64, 0), 0.16, 0.22, 8, Color("3f6a8a"))
	Meshes.blob(st, Vector3(0, 1.05, 0), Vector3(0.28, 0.26, 0.28), Color("4c7a39"), rng, 0.3)
	Meshes.blob(st, Vector3(0.18, 0.78, 0.1), Vector3(0.14, 0.2, 0.14), Color("5d8a3f"), rng, 0.3)
	return Meshes._finish(st)

## 0 a sofa, 1 an armchair. Back against the north wall.
static func sofa(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var fabrics := [Color("8c3b3b"), Color("3f6a8a"), Color("4f7a3a")]
	var cloth: Color = fabrics[(variant >> 1) % fabrics.size()]
	var armchair := variant % 2 == 1
	var hw := 0.3 if armchair else 0.44
	Meshes.box(st, Vector3(-hw, 0, -0.45), Vector3(hw * 2, 0.3, 0.8), cloth.darkened(0.15))
	Meshes.box(st, Vector3(-hw + 0.1, 0.3, -0.35), Vector3(hw * 2 - 0.2, 0.12, 0.66), cloth.lightened(0.08))
	Meshes.box(st, Vector3(-hw, 0.3, -0.48), Vector3(hw * 2, 0.5, 0.16), cloth)
	for sx in [-hw, hw - 0.1]:
		Meshes.box(st, Vector3(sx, 0.3, -0.4), Vector3(0.1, 0.24, 0.76), cloth.darkened(0.05))
	return Meshes._finish(st)

## An open glass-style cabinet: four posts, a rim and a few finds on a plinth.
static func display_case(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(36000 + variant)
	var st := Meshes._st()
	Meshes.box(st, Vector3(-0.4, 0, -0.35), Vector3(0.8, 0.5, 0.7), DARK_WOOD, Color("2f3a5a"))
	for px in [-0.4, 0.36]:
		for pz in [-0.35, 0.31]:
			Meshes.box(st, Vector3(px, 0.5, pz), Vector3(0.04, 0.5, 0.04), BRASS)
	Meshes.box(st, Vector3(-0.4, 1.0, -0.35), Vector3(0.8, 0.04, 0.7), BRASS.darkened(0.1))
	var finds: Array = [Color("e0a83a"), Color("c9c0aa"), Color("8c8270"), Color("6a9a8a"), Color("a8553a")]
	for i in 4:
		var c: Color = finds[rng.randi() % finds.size()]
		Meshes.blob(st, Vector3(rng.randf_range(-0.25, 0.25), 0.6, rng.randf_range(-0.2, 0.2)), Vector3(0.08, 0.07, 0.08), c, rng, 0.25)
	return Meshes._finish(st)
