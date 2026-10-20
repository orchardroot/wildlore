class_name ValleyStyles
extends RefCounted
## South Wales valleys (Rhondda, Merthyr, Blaenavon): the Pennant-stone terrace, the pit-head winding gear and
## Trevithick's 1804 Penydarren locomotive. Called from Landmarks.building (see the "winding_gear" arms there).
## Same rules as Landmarks: vertex colour, low poly, origin at the footprint's north-west corner, door on the south.

const STYLES := ["winding_gear", "valley_terrace", "steam_loco", "ironworks"]
const PENNANT := Color("857d6f")      # Pennant sandstone, the grey-brown stone of the valley terraces
const RENDER := [Color("9a9488"), Color("b9ad94"), Color("8d8f86"), Color("a89a85")]
const BLUE_SLATE := Color("4a5260")
const COAL := Color("1e1c1e")
const WHEEL := Color("2c3036")

## A row of valley terraced houses: Pennant stone or pebble-dash, blue-slate roof, a pot on every chimney,
## and a tall front door per house. Each building takes its tone from its seed, so a street is not one colour.
static func terrace(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = PENNANT if rng.randf() < 0.55 else RENDER[rng.randi() % RENDER.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, BLUE_SLATE, 2, true, false)
	# a stone step and a lintel over each house's door line, and a back-lane wall: enough to read as a terrace
	for i in range(w):
		Meshes.box(st, Vector3(i + 0.18, 0.0, d - 0.02), Vector3(0.64, 0.08, 0.14), PENNANT.darkened(0.2))

## A colliery pit head: brick engine house with a tall stack, and in front of it the steel head-frame, two sheave
## wheels on top, the cable running down to the winding house. The door sits in the engine house.
static func winding_gear(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var brick := Color("7c3f33")
	var steel := Color("55616e")
	var ew := 3.0
	var ex := clampf(door_x - 1.0, 0.0, w - ew)
	var eh := 2.6
	Meshes.box(st, Vector3(ex, 0, 0.5), Vector3(ew, eh, d - 0.6), brick, brick.lightened(0.05))
	Meshes.box(st, Vector3(ex - 0.05, 0, d - 0.12), Vector3(ew + 0.1, 0.45, 0.14), brick.darkened(0.35))
	Landmarks._roof_at(st, ex - 0.1, ex + ew + 0.1, 0.4, d, eh, 0.9, BLUE_SLATE, brick)
	for x in [ex + 0.3, ex + ew - 0.9]:
		Landmarks._window(st, wst, x, 1.2, d - 0.05, 0.6, 1.1, brick.lightened(0.3))
	Landmarks._door(st, door_x, d - 0.05, brick, 1.1)
	# the stack, brick with a pale cap, at the back of the engine house
	var sx := ex + ew - 0.7
	Meshes.box(st, Vector3(sx, 0, 0.6), Vector3(0.6, 5.6, 0.6), brick.darkened(0.08))
	Meshes.box(st, Vector3(sx - 0.05, 5.6, 0.55), Vector3(0.7, 0.18, 0.7), Color("b8b0a0"))
	# the head-frame beside it: two raking legs meeting at the sheave platform, cross-braced, two big wheels on the
	# front face, the winding rope sloping down to the engine house
	var fx := maxf(0.15, ex - 2.7)
	var spread := minf(2.4, maxf(1.6, ex - fx - 0.2))
	var top := 5.4
	var zf := minf(d - 1.2, 2.0)
	var apex_l := fx + spread * 0.5 - 0.2
	var apex_r := fx + spread * 0.5 + 0.2
	for zz in [zf + 0.1, zf + 0.7]:
		Landmarks._beam(st, Vector3(fx, 0.0, zz), Vector3(apex_l, top, zz), 0.22, steel)
		Landmarks._beam(st, Vector3(fx + spread, 0.0, zz), Vector3(apex_r, top, zz), 0.22, steel)
		var prev_l := Vector3(fx, 0.0, zz)
		var prev_r := Vector3(fx + spread, 0.0, zz)
		for y in [1.3, 2.6, 3.9, 5.2]:
			var k: float = float(y) / top
			var pl := Vector3(lerpf(fx, apex_l, k), y, zz)
			var pr := Vector3(lerpf(fx + spread, apex_r, k), y, zz)
			Landmarks._beam(st, pl, pr, 0.1, steel.lightened(0.1))
			Landmarks._beam(st, prev_l, pr, 0.07, steel.lightened(0.05))
			Landmarks._beam(st, prev_r, pl, 0.07, steel.lightened(0.05))
			prev_l = pl
			prev_r = pr
	for y in [1.3, 3.9]:
		var k2: float = float(y) / top
		Meshes.box(st, Vector3(lerpf(fx, apex_l, k2), y - 0.05, zf + 0.1), Vector3(spread * 0.9, 0.1, 0.7), steel.darkened(0.1))
	Meshes.box(st, Vector3(apex_l - 0.3, top - 0.05, zf + 0.05), Vector3(1.0, 0.16, 0.8), steel)
	_wheel(st, Vector3(fx + spread * 0.5 - 0.5, top + 0.45, zf + 0.85), 0.55, 12, WHEEL)
	_wheel(st, Vector3(fx + spread * 0.5 + 0.5, top + 0.45, zf + 0.85), 0.55, 12, WHEEL)
	_wheel(st, Vector3(fx + spread * 0.5 - 0.5, top + 0.45, zf + 0.86), 0.12, 6, Color("c49a40"))
	_wheel(st, Vector3(fx + spread * 0.5 + 0.5, top + 0.45, zf + 0.86), 0.12, 6, Color("c49a40"))
	# the rope from the wheel down to the engine house roof, and the cage shaft: a dark square under the frame
	Landmarks._beam(st, Vector3(fx + spread * 0.5 + 0.55, top + 0.2, zf + 0.4), Vector3(ex + 0.4, eh + 1.0, zf + 0.4), 0.06, COAL)
	Meshes.box(st, Vector3(fx + spread * 0.5 - 0.5, 0.0, zf + 0.05), Vector3(1.0, 0.04, 0.6), COAL)

## Trevithick's Penydarren locomotive of 1804: a horizontal boiler with its cylinder let into the end, one very tall
## thin chimney, a great flywheel on the side and four small iron wheels on a short length of plate-way.
static func steam_loco(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var boiler := Color("4a4640")
	var brass := Color("b0873a")
	var zc := d - 0.7
	var y0 := 0.8
	# plate-way: two flanged iron rails on sleepers
	Meshes.box(st, Vector3(0, 0, zc - 0.2), Vector3(w, 0.06, 0.12), Color("5a5a5e"))
	Meshes.box(st, Vector3(0, 0, zc + 0.5), Vector3(w, 0.06, 0.12), Color("5a5a5e"))
	for i in range(w * 2):
		Meshes.box(st, Vector3(0.15 + i * 0.5, 0, zc - 0.3), Vector3(0.14, 0.04, 1.0), Color("5a4630"))
	# the boiler: eight facets along x
	var bx0 := 0.9
	var bx1 := w - 0.5
	var r := 0.42
	for i in 8:
		var j := (i + 1) % 8
		var a0 := TAU * i / 8.0
		var a1 := TAU * j / 8.0
		var p0 := Vector3(bx0, y0 + r + sin(a0) * r, zc + 0.15 + cos(a0) * r)
		var p1 := Vector3(bx0, y0 + r + sin(a1) * r, zc + 0.15 + cos(a1) * r)
		var q0 := Vector3(bx1, p0.y, p0.z)
		var q1 := Vector3(bx1, p1.y, p1.z)
		Meshes._quad(st, p0, p1, q1, q0, boiler.lightened(0.07 * (i % 3)))
	# brass bands, the cylinder housing at the right-hand end, the fire-door end on the left
	for x in [bx0 + 0.7, (bx0 + bx1) * 0.5, bx1 - 0.7]:
		Meshes.box(st, Vector3(x, y0 - 0.02, zc - 0.31), Vector3(0.08, 0.88, 0.92), brass)
	Meshes.box(st, Vector3(bx1 - 0.1, y0 - 0.1, zc - 0.2), Vector3(0.55, 0.5, 0.7), boiler.darkened(0.2))
	Meshes.box(st, Vector3(bx0 - 0.3, y0 + 0.1, zc - 0.1), Vector3(0.32, 0.62, 0.5), boiler.darkened(0.3))
	# the chimney: tall, thin, flared lip
	var cx := bx1 - 0.8
	Meshes.cylinder(st, Vector3(cx, y0 + 0.8, zc + 0.15), 0.1, 1.9, 6, COAL.lightened(0.1))
	Meshes.cylinder(st, Vector3(cx, y0 + 2.5, zc + 0.15), 0.16, 0.18, 6, COAL.lightened(0.18))
	# the piston rod and crosshead out over the plate-way, a connecting rod down to the nearest wheel
	Meshes.box(st, Vector3(bx0 + 0.2, y0 + 0.95, zc + 0.5), Vector3(bx1 - bx0 - 0.4, 0.05, 0.05), brass)
	# four wheels (front pair seen from the south), and the big flywheel on the side facing us
	for x in [bx0 + 0.35, bx1 - 0.4]:
		_wheel(st, Vector3(x, 0.36, zc + 0.62), 0.36, 8, WHEEL)
	_wheel(st, Vector3(bx0 + 1.1, y0 + 0.95, zc + 0.64), 0.78, 12, Color("33373d"))
	_wheel(st, Vector3(bx0 + 1.1, y0 + 0.95, zc + 0.65), 0.1, 6, brass)
	# a stoker's step and a little cart of coal behind, so it looks used
	Meshes.box(st, Vector3(0.05, 0.0, zc - 0.25), Vector3(0.7, 0.3, 0.6), Color("5a4630"))
	Meshes.box(st, Vector3(0.1, 0.3, zc - 0.2), Vector3(0.6, 0.12, 0.5), COAL)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.2, 0.0, d - 0.08), Vector3(0.6, 0.05, 0.06), Color("3b2a22"))

## a flat disc on the south-facing plane (XY) with spokes: reads as a wheel from the game camera.
static func _wheel(st: SurfaceTool, c: Vector3, r: float, seg: int, col: Color) -> void:
	for i in seg:
		var a0 := TAU * i / seg
		var a1 := TAU * (i + 1) / seg
		var p0 := c + Vector3(cos(a0) * r, sin(a0) * r, 0)
		var p1 := c + Vector3(cos(a1) * r, sin(a1) * r, 0)
		Meshes._tri(st, c, p0, p1, col if i % 2 == 0 else col.lightened(0.12))
		# the back of the disc, so it isn't see-through from behind
		Meshes._tri(st, c, p1, p0, col.darkened(0.3))

## Blaenavon Ironworks (1789): three squat tapering stone furnace stacks behind a long low cast house with arched
## fronts, and the stone water-balance tower at one end, with its iron incline rail running to the ground.
static func ironworks(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("8a8274")
	var dark := Color("2a2420")
	var slate := Color("4e5662")
	# the furnace stacks at the back: each one three stepped boxes, a dark coping, a dark charging mouth up top
	var n := 3
	var sw := (w - 0.8) / n
	for i in n:
		var x0 := 0.4 + i * sw
		var bw := sw - 0.4
		Meshes.box(st, Vector3(x0, 0, 0.3), Vector3(bw, 2.0, 1.9), stone.darkened(0.08), stone)
		Meshes.box(st, Vector3(x0 + 0.2, 2.0, 0.4), Vector3(bw - 0.4, 1.8, 1.7), stone.darkened(0.04), stone.lightened(0.04))
		Meshes.box(st, Vector3(x0 + 0.4, 3.8, 0.5), Vector3(bw - 0.8, 1.4, 1.5), stone, stone.lightened(0.06))
		Meshes.box(st, Vector3(x0 + 0.3, 5.2, 0.45), Vector3(bw - 0.6, 0.18, 1.6), dark)
		Meshes.box(st, Vector3(x0 + bw * 0.5 - 0.3, 5.3, 1.0), Vector3(0.6, 0.35, 0.6), dark.lightened(0.1))
		# the tuyere arch at the foot of each furnace, facing south
		Meshes.box(st, Vector3(x0 + bw * 0.5 - 0.35, 0.0, 2.15), Vector3(0.7, 1.0, 0.08), dark)
	# the cast house: low stone walls, a single-pitch slate roof, three open arches along the front
	var cz0 := 2.3
	Meshes.box(st, Vector3(0.2, 0, cz0), Vector3(w - 2.6, 1.7, d - cz0 - 0.5), stone, stone.lightened(0.05))
	var a := Vector3(0.1, 1.7, cz0 - 0.1)
	var b := Vector3(w - 2.3, 1.7, cz0 - 0.1)
	var c := Vector3(w - 2.3, 1.7, d - 0.4)
	var dd := Vector3(0.1, 1.7, d - 0.4)
	var r0 := Vector3(0.1, 2.5, cz0 - 0.1)
	var r1 := Vector3(w - 2.3, 2.5, cz0 - 0.1)
	Meshes._quad(st, r0, r1, c, dd, slate)
	Meshes._quad(st, dd, c, b, a, slate.darkened(0.4))
	Meshes._tri(st, r0, dd, a, stone.darkened(0.05))
	Meshes._tri(st, r1, b, c, stone.darkened(0.08))
	var fz := d - 0.5
	for i in range(1, w - 3, 2):
		if abs(i - door_x) > 1 or door_x < 0:
			Meshes.box(st, Vector3(i + 0.1, 0.0, fz - 0.02), Vector3(0.8, 1.2, 0.06), dark)
			Meshes.box(st, Vector3(i + 0.0, 1.2, fz - 0.03), Vector3(1.0, 0.1, 0.07), stone.lightened(0.15))
	# the water-balance tower on the right: a tall stone box with slit windows and the incline's rail
	var tx := w - 2.2
	Meshes.box(st, Vector3(tx, 0, d - 3.4), Vector3(1.8, 4.6, 2.6), stone.darkened(0.06), stone.lightened(0.04))
	Meshes.box(st, Vector3(tx - 0.1, 4.6, d - 3.5), Vector3(2.0, 0.18, 2.8), dark)
	for y in [1.2, 2.4, 3.6]:
		Meshes.box(st, Vector3(tx + 0.7, y, d - 0.82), Vector3(0.3, 0.7, 0.06), dark)
	Landmarks._beam(st, Vector3(tx + 0.2, 4.4, d - 0.9), Vector3(tx - 2.2, 0.15, d - 0.9), 0.14, Color("3a3f46"))
	Landmarks._beam(st, Vector3(tx + 0.5, 4.4, d - 0.9), Vector3(tx - 1.9, 0.15, d - 0.9), 0.14, Color("3a3f46"))
	# the way in
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, fz - 0.03), Vector3(0.8, 1.35, 0.08), Color("3b2a22"))
		Meshes.box(st, Vector3(door_x + 0.0, 1.35, fz - 0.04), Vector3(1.0, 0.12, 0.09), stone.lightened(0.2))
