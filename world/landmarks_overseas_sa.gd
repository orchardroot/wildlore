class_name SouthAtlanticStyles
extends RefCounted
## The South Atlantic territories (Ascension, St Helena, Tristan da Cunha, the Falklands): the Georgian island house
## with its balcony, Jacob's Ladder, a radome, the Stanley tin-roofed cottage and the Whalebone Arch.
## Called from Landmarks.building (see the "sa_colonial" arms there). Same rules as Landmarks: vertex colour, low
## poly, origin at the footprint's north-west corner, door on the south.

const STYLES := ["sa_colonial", "jacobs_ladder", "radome", "tin_cottage", "whalebone_arch"]
const WALLS := [Color("efe6cc"), Color("ecd9a0"), Color("f2f0e8"), Color("c9dbe0"), Color("e8c9b4")]
const SLATE := Color("62666c")
const SHUTTER := Color("3f6a4c")
const TIN := [Color("b8352e"), Color("3f7a52"), Color("3a62a0"), Color("8a5a3a"), Color("b8b0a0")]
const WOOD := [Color("f0ece0"), Color("e8dcc0"), Color("d8e4e8"), Color("e6d0c0")]
const BONE := Color("ebe3cf")

## A two-storey island house in painted stucco: a slate roof, green shutters, a first-floor balcony on thin posts.
static func colonial(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = WALLS[rng.randi() % WALLS.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, SLATE, 2, false, false)
	for i in range(w):
		if i != door_x:
			Meshes.box(st, Vector3(i + 0.1, 0.5, d - 0.04), Vector3(0.1, 0.7, 0.05), SHUTTER)
			Meshes.box(st, Vector3(i + 0.74, 0.5, d - 0.04), Vector3(0.1, 0.7, 0.05), SHUTTER)
		Meshes.box(st, Vector3(i + 0.1, 1.65, d - 0.04), Vector3(0.1, 0.7, 0.05), SHUTTER)
		Meshes.box(st, Vector3(i + 0.74, 1.65, d - 0.04), Vector3(0.1, 0.7, 0.05), SHUTTER)
	# the balcony: a floor, a rail and posts down to the ground
	Meshes.box(st, Vector3(0.0, 1.3, d), Vector3(w, 0.07, 0.5), wall.darkened(0.25))
	Meshes.box(st, Vector3(0.0, 1.7, d + 0.45), Vector3(w, 0.06, 0.05), SHUTTER)
	for i in range(w + 1):
		Meshes.box(st, Vector3(minf(i, w - 0.06), 0.0, d + 0.42), Vector3(0.06, 1.7, 0.06), SHUTTER)

## Jacob's Ladder: 699 steps straight up the cliff from Jamestown. A steep flight on a stone ramp, a rail each side.
static func ladder(st: SurfaceTool, w: int, d: int) -> void:
	var stone := Color("8c8478")
	var rise := 3.6
	var n := maxi(8, d * 3)
	Meshes.box(st, Vector3(0.0, 0.0, 0.0), Vector3(w, 0.4, d), stone.darkened(0.2))
	for i in range(n):
		var z := d - (i + 1) * float(d) / n
		var y := 0.2 + rise * float(i + 1) / n
		Meshes.box(st, Vector3(w * 0.5 - 0.5, 0.0, z), Vector3(1.0, y, float(d) / n + 0.02), stone.lightened(0.12 * (i % 2)))
	for sx in [w * 0.5 - 0.58, w * 0.5 + 0.5]:
		Landmarks._beam(st, Vector3(sx, 0.5, d), Vector3(sx, rise + 0.7, 0.0), 0.08, Color("d8d4c8"))
		Meshes.box(st, Vector3(sx - 0.03, 0.0, d - 0.06), Vector3(0.06, 0.9, 0.06), Color("d8d4c8"))
	Meshes.box(st, Vector3(w * 0.5 - 0.7, rise, 0.0), Vector3(1.4, 0.6, 0.5), stone.darkened(0.1))

## A radome: a white golf ball on a low plinth, with a small white block of a building at its foot.
static func radome(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var white := Color("f0f0ec")
	Meshes.box(st, Vector3(0.0, 0.0, d * 0.4), Vector3(w, 1.1, d * 0.6), white.darkened(0.08), white)
	Landmarks._door(st, door_x, d, white)
	Landmarks._window(st, wst, 0.3, 0.5, d, 0.5, 0.4, white.darkened(0.3))
	var cx := w * 0.5
	Meshes.cylinder(st, Vector3(cx, 1.1, d * 0.4), minf(w, d) * 0.28, 0.35, 12, white.darkened(0.15))
	Meshes.blob(st, Vector3(cx, 2.7, d * 0.4), Vector3(1.5, 1.5, 1.5), white, rng, 0.0)
	for k in [-0.9, 0.0, 0.9]:
		Meshes.box(st, Vector3(cx + k - 0.04, 1.5, d * 0.4 - 1.4), Vector3(0.08, 2.5, 0.06), white.darkened(0.2))

## A Stanley house: timber cladding, a brightly painted corrugated iron roof, dormers and a little porch.
static func tin_cottage(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = WOOD[rng.randi() % WOOD.size()]
	var roof: Color = TIN[rng.randi() % TIN.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, roof, 1, false, false)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.05, 0.16, d), Vector3(0.9, 0.95, 0.4), wall.darkened(0.05))
		Landmarks._roof_at(st, door_x - 0.1, door_x + 1.0, d - 0.05, d + 0.45, 1.1, 0.4, roof, wall)
	for i in range(1, w, 2):
		Meshes.box(st, Vector3(i + 0.1, 1.35, d * 0.5), Vector3(0.7, 0.55, 0.5), wall)
		Landmarks._roof_at(st, i, i + 0.9, d * 0.5 - 0.05, d * 0.5 + 0.55, 1.9, 0.3, roof.darkened(0.1), wall)

## The Whalebone Arch: two blue whale jawbones set in the ground, curved together at the top, on stone plinths.
static func whalebone_arch(st: SurfaceTool, w: int, d: int) -> void:
	var half := w * 0.42
	var cx := w * 0.5
	var z := d * 0.5
	for side in [-1.0, 1.0]:
		var prev := Vector3(cx + side * half, 0.0, z)
		for i in range(1, 9):
			var t := float(i) / 8.0
			var p := Vector3(cx + side * half * (1.0 - t * t * 0.96), 3.3 * sin(t * PI * 0.5), z)
			Landmarks._beam(st, prev, p, 0.34 * (1.0 - t * 0.45), BONE.darkened(0.04 * i))
			prev = p
		Meshes.box(st, Vector3(cx + side * half - 0.35, 0.0, z - 0.35), Vector3(0.7, 0.25, 0.7), Color("8c8478"))
