class_name Landmarks
extends RefCounted
## Bigger and stranger meshes for M2: mills, terraces, castles, the Liver Building, stations, an aqueduct,
## plus point props (boats, standing stones, slate heaps). Same rules as Meshes: vertex colour, low poly,
## origin at the footprint's north-west corner for buildings and at the tile centre for props.

const BRICK := Color("9c4a3a")
const DARK_BRICK := Color("7a3a30")
const SANDSTONE := Color("b5654a")   # Chester's red sandstone
const SLATE := Color("4d5563")
const SLATE_WALL := Color("7d838a")
const LIMESTONE := Color("c9c0aa")
const PORTLAND := Color("d8d2c2")    # Liver Building granite and Portland stone, near enough
const IRON := Color("3c4450")
const GLASS := Color.WHITE

## Building styles handled here rather than by the generic house in Meshes.building.
const SPECIAL := ["glass_tower", "gantry_crane", "mill", "castle", "cathedral", "liver_building", "station", "aqueduct", "chapel", "terrace", "tudor", "slate_cottage", "lighthouse_house"]

static func building(w: int, d: int, style: String, door_x: int, seed_value: int) -> Array:
	var rng := Meshes._rng(seed_value)
	var st := Meshes._st()
	var wst := Meshes._st()
	match style:
		"mill":
			_mill(st, wst, w, d, door_x, rng)
		"castle":
			_castle(st, wst, w, d, door_x)
		"cathedral":
			_cathedral(st, wst, w, d, door_x, SANDSTONE)
		"chapel":
			_chapel(st, wst, w, d, door_x)
		"liver_building":
			_liver(st, wst, w, d, door_x)
		"station":
			_station(st, wst, w, d, door_x)
		"aqueduct":
			_aqueduct(st, w, d)
		"gantry_crane":
			_gantry(st, w, d)
		"glass_tower":
			_glass_tower(st, wst, w, d, door_x)
		"terrace":
			_house(st, wst, w, d, door_x, rng, BRICK, SLATE, 2, true, false)
		"tudor":
			_house(st, wst, w, d, door_x, rng, Color("ece5d2"), Color("5a4a44"), 2, false, true)
		"slate_cottage":
			_house(st, wst, w, d, door_x, rng, SLATE_WALL, SLATE.darkened(0.2), 1, false, false)
		_:
			_house(st, wst, w, d, door_x, rng, BRICK, SLATE, 2, false, false)
	return [Meshes._finish(st), Meshes._finish(wst)]

# --- houses ------------------------------------------------------------------

## A pitched-roof house. terrace: a chimney per two tiles and a door per... one door, but party walls marked.
## tudor: black timber framing over white render, jettied upper floor.
static func _house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator,
		wall: Color, roof: Color, storeys: int, terrace: bool, tudor: bool) -> void:
	var hgt := 1.15 * storeys + 0.2
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), wall)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), wall.darkened(0.3))
	if tudor:
		# jetty: the upper floor oversails the street a little
		Meshes.box(st, Vector3(0.0, 1.2, 0.0), Vector3(w, hgt - 1.2, d + 0.12), wall)
		var beam := Color("2b2422")
		Meshes.box(st, Vector3(0, 1.16, d + 0.06), Vector3(w, 0.1, 0.08), beam)
		Meshes.box(st, Vector3(0, hgt - 0.08, d + 0.06), Vector3(w, 0.1, 0.08), beam)
		for i in range(w + 1):
			Meshes.box(st, Vector3(minf(i, w - 0.08), 0.16, d - 0.02), Vector3(0.08, 1.0, 0.06), beam)
			Meshes.box(st, Vector3(minf(i, w - 0.08), 1.26, d + 0.08), Vector3(0.08, hgt - 1.3, 0.06), beam)
			if i < w:
				# a diagonal brace, as two stepped boxes (keeps the low-poly look)
				Meshes.box(st, Vector3(i + 0.3, 1.5, d + 0.09), Vector3(0.4, 0.07, 0.05), beam)
	_roof(st, w, d, hgt, roof, wall)
	if terrace:
		for i in range(1, w, 2):
			Meshes.box(st, Vector3(i - 0.2, hgt + 0.3, d * 0.5 - 0.2), Vector3(0.4, 0.95, 0.4), wall.darkened(0.25))
			Meshes.box(st, Vector3(i - 0.12, hgt + 1.25, d * 0.5 - 0.12), Vector3(0.1, 0.14, 0.1), Color("a0553c"))
			Meshes.box(st, Vector3(i + 0.04, hgt + 1.25, d * 0.5 - 0.12), Vector3(0.1, 0.14, 0.1), Color("a0553c"))
			Meshes.box(st, Vector3(i - 0.03, 0.16, d - 0.04), Vector3(0.06, hgt - 0.2, 0.05), wall.darkened(0.15))
	else:
		var cx := rng.randf_range(0.6, maxf(0.7, w - 0.9))
		Meshes.box(st, Vector3(cx, hgt + 0.3, d * 0.5 - 0.2), Vector3(0.35, 0.95, 0.4), wall.darkened(0.2) if not tudor else Color("8a4b3b"))
	_door(st, door_x, d + (0.0 if not tudor else 0.0), wall)
	for s in storeys:
		var wy := 0.4 + 1.15 * s
		for x in w:
			if x == door_x and s == 0:
				continue
			_window(st, wst, x + 0.27, wy, d + (0.12 if tudor and s > 0 else 0.0), 0.46, 0.56, wall.lightened(0.2))

static func _roof(st: SurfaceTool, w: float, d: float, hgt: float, roof: Color, wall: Color, rise_k := 0.38) -> void:
	var eave := 0.18
	var rise := minf(1.2, d * rise_k)
	var a := Vector3(-eave, hgt, -eave)
	var b := Vector3(w + eave, hgt, -eave)
	var c := Vector3(w + eave, hgt, d + eave)
	var dd := Vector3(-eave, hgt, d + eave)
	var r0 := Vector3(-eave, hgt + rise, d * 0.5)
	var r1 := Vector3(w + eave, hgt + rise, d * 0.5)
	Meshes._quad(st, r0, r1, c, dd, roof)
	Meshes._quad(st, r1, r0, a, b, roof.darkened(0.15))
	Meshes._tri(st, r0, dd, a, wall.darkened(0.05))
	Meshes._tri(st, r1, b, c, wall.darkened(0.08))
	Meshes._quad(st, dd, c, b, a, roof.darkened(0.4))

static func _door(st: SurfaceTool, door_x: int, d: float, wall: Color, h := 0.9) -> void:
	if door_x < 0:
		return
	Meshes.box(st, Vector3(door_x + 0.22, 0.16, d - 0.08), Vector3(0.56, h, 0.06), Color("3b2a22"))
	Meshes.box(st, Vector3(door_x + 0.15, 0.16 + h, d - 0.09), Vector3(0.7, 0.08, 0.08), wall.lightened(0.2))

## A window on the south face: frame into the body mesh, glass into the glow mesh (lit at night).
static func _window(st: SurfaceTool, wst: SurfaceTool, x: float, y: float, d: float, ww: float, wh: float, frame: Color) -> void:
	Meshes.box(st, Vector3(x, y - 0.06, d - 0.07), Vector3(ww, wh + 0.1, 0.04), frame)
	Meshes.box(wst, Vector3(x + 0.05, y, d - 0.065), Vector3(ww - 0.1, wh - 0.02, 0.04), GLASS)

# --- industry ----------------------------------------------------------------

## A Lancashire cotton mill: four storeys of windows, a flat roof and a tall round chimney.
static func _mill(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var storeys := 4
	var hgt := 0.95 * storeys + 0.3
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), BRICK, BRICK.darkened(0.35))
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.2, d), DARK_BRICK)
	Meshes.box(st, Vector3(-0.05, hgt - 0.12, -0.05), Vector3(w + 0.1, 0.16, d + 0.1), LIMESTONE)
	for s in storeys:
		Meshes.box(st, Vector3(0.0, 0.95 * s + 0.88, d - 0.06), Vector3(w, 0.06, 0.04), LIMESTONE)
		for x in w:
			if x == door_x and s == 0:
				continue
			_window(st, wst, x + 0.22, 0.3 + 0.95 * s, d, 0.56, 0.55, LIMESTONE)
	# water tower at one end and the chimney at the other
	Meshes.box(st, Vector3(0.1, hgt, 0.2), Vector3(1.2, 1.0, 1.2), BRICK.darkened(0.1), LIMESTONE)
	var cx := w - 1.0
	Meshes.cylinder(st, Vector3(cx, 0, d * 0.4), 0.45, hgt + 3.4, 8, DARK_BRICK)
	Meshes.cylinder(st, Vector3(cx, hgt + 3.2, d * 0.4), 0.48, 0.25, 8, LIMESTONE)
	_door(st, door_x, d, BRICK, 1.1)

## Station building with a glass canopy reaching one tile south over the platform.
static func _station(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var hgt := 1.6
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), BRICK)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), DARK_BRICK)
	_roof(st, w, d, hgt, SLATE, BRICK, 0.3)
	for x in w:
		if x != door_x:
			_window(st, wst, x + 0.25, 0.45, d, 0.5, 0.7, LIMESTONE)
	_door(st, door_x, d, BRICK, 1.0)
	# canopy on iron columns over the platform
	var green := Color("2f5a4a")
	for x in range(0, w + 1, 2):
		Meshes.box(st, Vector3(minf(x, w - 0.1), 0, d + 0.85), Vector3(0.1, 1.5, 0.1), green)
	Meshes.box(st, Vector3(0, 1.5, d - 0.05), Vector3(w, 0.08, 1.05), Color("9fb3b8"))
	Meshes.box(st, Vector3(0, 1.4, d + 0.9), Vector3(w, 0.12, 0.08), green)
	# station clock
	Meshes.box(st, Vector3(w * 0.5 - 0.25, 1.05, d + 0.88), Vector3(0.5, 0.36, 0.08), Color("f4efe2"))

# --- grand buildings ---------------------------------------------------------

## Crenellated curtain wall with round corner towers and a gatehouse on the door column.
static func _castle(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("9d968a")
	var wall_h := 2.2
	var t := 0.6
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, wall_h, t), stone)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(t, wall_h, d), stone.darkened(0.04))
	Meshes.box(st, Vector3(w - t, 0, 0), Vector3(t, wall_h, d), stone.darkened(0.04))
	Meshes.box(st, Vector3(0, 0, d - t), Vector3(w, wall_h, t), stone)
	# courtyard
	Meshes.box(st, Vector3(t, 0, t), Vector3(w - 2 * t, 0.05, d - 2 * t), Color("7f8a5a"))
	_merlons(st, 0, w, 0.0, wall_h, stone, true)
	_merlons(st, 0, w, d - t, wall_h, stone, true)
	_merlons(st, 0, d, 0.0, wall_h, stone, false)
	_merlons(st, 0, d, w - t, wall_h, stone, false)
	for c in [Vector2(0.4, 0.4), Vector2(w - 0.4, 0.4), Vector2(0.4, d - 0.4), Vector2(w - 0.4, d - 0.4)]:
		Meshes.cylinder(st, Vector3(c.x, 0, c.y), 0.85, wall_h + 1.0, 8, stone.lightened(0.05))
		Meshes.cylinder(st, Vector3(c.x, wall_h + 1.0, c.y), 0.82, 0.3, 8, stone.darkened(0.1))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.4, 0, d - 0.9), Vector3(1.8, wall_h + 1.0, 1.0), stone.lightened(0.08))
		Meshes.box(st, Vector3(door_x + 0.2, 0, d + 0.05), Vector3(0.6, 1.1, 0.06), Color("2a221e"))
		_window(st, wst, door_x + 0.3, wall_h + 0.2, d + 0.1, 0.4, 0.4, stone.lightened(0.2))
	# a flag on the first tower
	Meshes.box(st, Vector3(0.38, wall_h + 1.3, 0.38), Vector3(0.05, 1.0, 0.05), Color("3b2a22"))
	Meshes.box(st, Vector3(0.43, wall_h + 1.8, 0.38), Vector3(0.6, 0.4, 0.03), Color("c8102e"))

static func _merlons(st: SurfaceTool, from: float, to: float, at: float, y: float, col: Color, along_x: bool) -> void:
	var x := from
	while x < to - 0.3:
		if along_x:
			Meshes.box(st, Vector3(x, y, at), Vector3(0.3, 0.3, 0.6), col.lightened(0.05))
		else:
			Meshes.box(st, Vector3(at, y, x), Vector3(0.6, 0.3, 0.3), col.lightened(0.05))
		x += 0.6

## Nave with a steep roof, a square west tower with pinnacles, tall lancet windows.
static func _cathedral(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, stone: Color) -> void:
	var tower_w := mini(3, w - 2)
	var nave_h := 2.6
	Meshes.box(st, Vector3(tower_w, 0, 0.3), Vector3(w - tower_w, nave_h, d - 0.6), stone)
	_roof_at(st, tower_w, w, 0.3, d - 0.3, nave_h, 1.3, SLATE.darkened(0.1), stone)
	var th := 5.6
	Meshes.box(st, Vector3(0, 0, 0), Vector3(tower_w, th, d), stone.darkened(0.04))
	for c in [Vector2(0, 0), Vector2(tower_w - 0.3, 0), Vector2(0, d - 0.3), Vector2(tower_w - 0.3, d - 0.3)]:
		Meshes.box(st, Vector3(c.x, th, c.y), Vector3(0.3, 0.8, 0.3), stone.lightened(0.06))
	_merlons(st, 0, tower_w, d - 0.6, th, stone, true)
	for x in range(tower_w, w):
		_window(st, wst, x + 0.32, 0.6, d - 0.3, 0.36, 1.5, stone.lightened(0.2))
	_window(st, wst, tower_w * 0.5 - 0.3, 3.4, d, 0.6, 1.2, stone.lightened(0.2))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.05), Vector3(0.7, 1.3, 0.08), Color("3b2a22"))

static func _roof_at(st: SurfaceTool, x0: float, x1: float, z0: float, z1: float, h: float, rise: float, roof: Color, wall: Color) -> void:
	var a := Vector3(x0, h, z0)
	var b := Vector3(x1, h, z0)
	var c := Vector3(x1, h, z1)
	var dd := Vector3(x0, h, z1)
	var zm := (z0 + z1) * 0.5
	var r0 := Vector3(x0, h + rise, zm)
	var r1 := Vector3(x1, h + rise, zm)
	Meshes._quad(st, r0, r1, c, dd, roof)
	Meshes._quad(st, r1, r0, a, b, roof.darkened(0.15))
	Meshes._tri(st, r0, dd, a, wall.darkened(0.05))
	Meshes._tri(st, r1, b, c, wall.darkened(0.08))

## A Welsh chapel: grey render, gable to the street, two tall arched windows and a date stone.
static func _chapel(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("a7a59c")
	var h := 2.4
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall)
	# gable faces south: ridge runs north-south
	var a := Vector3(-0.15, h, -0.1)
	var b := Vector3(w + 0.15, h, -0.1)
	var c := Vector3(w + 0.15, h, d + 0.1)
	var dd := Vector3(-0.15, h, d + 0.1)
	var r0 := Vector3(w * 0.5, h + 1.1, -0.1)
	var r1 := Vector3(w * 0.5, h + 1.1, d + 0.1)
	Meshes._quad(st, r1, r0, a, dd, SLATE)
	Meshes._quad(st, r0, r1, c, b, SLATE.darkened(0.15))
	Meshes._tri(st, dd, c, r1, wall.lightened(0.04))
	Meshes._tri(st, b, a, r0, wall.darkened(0.06))
	Meshes.box(st, Vector3(w * 0.5 - 0.35, h + 0.2, d - 0.02), Vector3(0.7, 0.35, 0.06), Color("dcd6c4"))
	for x in [0.5, w - 1.0]:
		_window(st, wst, x, 0.5, d, 0.5, 1.5, wall.lightened(0.25))
	_door(st, door_x, d, wall, 1.1)

## The Liver Building: a tall granite block, two clock towers with green domes and a Liver Bird on each.
static func _liver(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var h := 3.6
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), PORTLAND)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.25, d), PORTLAND.darkened(0.25))
	for s in 4:
		for x in w:
			if x == door_x and s == 0:
				continue
			_window(st, wst, x + 0.3, 0.4 + 0.82 * s, d, 0.4, 0.5, PORTLAND.darkened(0.1))
	var rng := Meshes._rng(77)
	var verdigris := Color("6fae96")
	for tx in [0.6, w - 2.0]:
		Meshes.box(st, Vector3(tx, h, d * 0.5 - 0.7), Vector3(1.4, 1.5, 1.4), PORTLAND.lightened(0.04))
		Meshes.box(st, Vector3(tx + 0.25, h + 0.4, d * 0.5 + 0.71), Vector3(0.9, 0.9, 0.04), Color("f2ead2"))
		Meshes.box(st, Vector3(tx + 0.66, h + 0.5, d * 0.5 + 0.74), Vector3(0.06, 0.4, 0.03), Color("2a2a2a"))
		Meshes.cylinder(st, Vector3(tx + 0.7, h + 1.5, d * 0.5), 0.6, 0.5, 8, verdigris)
		Meshes.blob(st, Vector3(tx + 0.7, h + 2.2, d * 0.5), Vector3(0.5, 0.45, 0.5), verdigris, rng, 0.03)
		# the Liver Bird
		Meshes.blob(st, Vector3(tx + 0.7, h + 2.85, d * 0.5), Vector3(0.16, 0.28, 0.14), Color("4f8a6a"), rng, 0.05)
		Meshes.box(st, Vector3(tx + 0.35, h + 2.85, d * 0.5 - 0.03), Vector3(0.7, 0.12, 0.06), Color("4f8a6a"))
	_door(st, door_x, d, PORTLAND, 1.2)

## Pontcysyllte: tall stone piers, round-ish arches, and an iron trough of canal water on top. Runs east-west.
static func _aqueduct(st: SurfaceTool, w: int, d: int) -> void:
	var stone := Color("8f7f6c")
	var h := 3.4
	var pier := 0.5
	for x in range(0, w, 2):
		Meshes.box(st, Vector3(x + 0.75, 0, d * 0.5 - 0.35), Vector3(pier, h, 0.7), stone.lightened(0.04 * (x % 4)))
	for x in range(0, w - 1, 2):
		# a stepped arch between piers
		Meshes.box(st, Vector3(x + 1.2, h - 0.5, d * 0.5 - 0.3), Vector3(1.6, 0.5, 0.6), stone)
		Meshes.box(st, Vector3(x + 1.25, h - 0.75, d * 0.5 - 0.3), Vector3(0.25, 0.25, 0.6), stone)
		Meshes.box(st, Vector3(x + 2.5, h - 0.75, d * 0.5 - 0.3), Vector3(0.25, 0.25, 0.6), stone)
	Meshes.box(st, Vector3(0, h, d * 0.5 - 0.5), Vector3(w, 0.4, 1.0), IRON)
	Meshes.box(st, Vector3(0, h + 0.38, d * 0.5 - 0.4), Vector3(w, 0.04, 0.8), Color("4f7f8f"))
	Meshes.box(st, Vector3(0, h + 0.4, d * 0.5 + 0.42), Vector3(w, 0.35, 0.05), IRON.lightened(0.2))

## Belfast's Samson and Goliath: a huge yellow gantry crane, two box legs straddling the dock and a beam on top.
static func _gantry(st: SurfaceTool, w: int, d: int) -> void:
	var yellow := Color("e8c228")
	var h := 6.5
	for lx in [0.2, w - 0.9]:
		Meshes.box(st, Vector3(lx, 0, d * 0.5 - 0.35), Vector3(0.7, h, 0.7), yellow)
		Meshes.box(st, Vector3(lx - 0.1, 0, d * 0.5 - 0.6), Vector3(0.9, 0.3, 1.2), IRON)  # bogie on the rail
	Meshes.box(st, Vector3(-0.3, h, d * 0.5 - 0.5), Vector3(w + 0.6, 0.9, 1.0), yellow, yellow.lightened(0.1))
	Meshes.box(st, Vector3(w * 0.5 - 0.6, h - 0.8, d * 0.5 - 0.45), Vector3(1.2, 0.8, 0.9), IRON.lightened(0.15))  # trolley
	Meshes.box(st, Vector3(w * 0.5 - 0.05, 1.4, d * 0.5 - 0.05), Vector3(0.1, h - 2.2, 0.1), Color("2a2a2a"))   # hoist cable
	Meshes.box(st, Vector3(w * 0.5 - 0.25, 1.1, d * 0.5 - 0.25), Vector3(0.5, 0.35, 0.5), IRON)                # hook block

## Lord Vane's tower: a tall tapering block of blue glass with a lit grid of windows and a needle spire.
static func _glass_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var glass := Color("4a6e8c")
	var frame := Color("2a3442")
	var tiers := [[0.0, 4.0, 0.0], [4.0, 4.0, 0.35], [8.0, 3.5, 0.7]]  # [base y, height, inset]
	for t in tiers:
		var y0: float = t[0]
		var h: float = t[1]
		var ins: float = t[2]
		Meshes.box(st, Vector3(ins, y0, ins), Vector3(w - 2 * ins, h, d - 2 * ins), glass, glass.lightened(0.2))
		Meshes.box(st, Vector3(ins - 0.05, y0 + h - 0.12, ins - 0.05), Vector3(w - 2 * ins + 0.1, 0.12, d - 2 * ins + 0.1), frame)
		var rows := int(h / 0.7)
		for r in rows:
			for x in range(int(ins) + 0, w - int(ceil(ins))):
				if r == 0 and y0 == 0.0 and x == door_x:
					continue
				Meshes.box(wst, Vector3(x + 0.2, y0 + 0.25 + r * 0.7, d - ins - 0.03), Vector3(0.6, 0.4, 0.04), Color.WHITE)
	Meshes.box(st, Vector3(w * 0.5 - 0.15, 11.5, d * 0.5 - 0.15), Vector3(0.3, 3.0, 0.3), frame.lightened(0.3))  # spire
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.06), Vector3(0.7, 1.2, 0.08), frame)

# --- point props -------------------------------------------------------------

static func standing_stone(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9100 + variant)
	var st := Meshes._st()
	var g := Color("8e8a80")
	var h := 1.3 + variant * 0.3
	Meshes.box(st, Vector3(-0.22, 0, -0.14), Vector3(0.44, h, 0.28), g.lightened(rng.randf_range(-0.05, 0.05)))
	Meshes.box(st, Vector3(-0.17, h, -0.1), Vector3(0.3, 0.18, 0.2), g.darkened(0.06))
	Meshes.blob(st, Vector3(0.1, h * 0.5, 0.15), Vector3(0.1, 0.12, 0.04), Color("9fae6a"), rng)  # lichen
	return Meshes._finish(st)

static func slate_heap(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9200 + variant)
	var st := Meshes._st()
	for i in 9:
		var y := i * 0.09
		var s := 0.9 - i * 0.08
		Meshes.box(st, Vector3(-s * 0.5 + rng.randf_range(-0.05, 0.05), y, -s * 0.45), Vector3(s, 0.08, s * 0.9), SLATE.lightened(rng.randf_range(-0.08, 0.12)))
	return Meshes._finish(st)

static func scree_rubble(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9300 + variant)
	var st := Meshes._st()
	for i in 6:
		Meshes.blob(st, Vector3(rng.randf_range(-0.35, 0.35), 0.06, rng.randf_range(-0.35, 0.35)), Vector3(0.12, 0.08, 0.1), Color("8a8780").lightened(rng.randf_range(-0.1, 0.1)), rng, 0.3)
	return Meshes._finish(st)

static func bramble(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9400 + variant)
	var st := Meshes._st()
	Meshes.blob(st, Vector3(0, 0.35, 0), Vector3(0.5, 0.38, 0.46), Color("3d5e2c"), rng, 0.3)
	Meshes.blob(st, Vector3(0.2, 0.55, 0.1), Vector3(0.28, 0.22, 0.28), Color("4a6b30"), rng, 0.3)
	for i in 7:
		Meshes.box(st, Vector3(rng.randf_range(-0.4, 0.35), rng.randf_range(0.3, 0.7), rng.randf_range(-0.35, 0.4)), Vector3(0.07, 0.07, 0.07), Color("2b1d33") if i % 2 == 0 else Color("b8344a"))
	return Meshes._finish(st)

## One tile of track running east-west: sleepers across, two steel rails along. Rail tops sit at RAIL_TOP.
const RAIL_TOP := 0.12
static func rail_segment() -> ArrayMesh:
	var st := Meshes._st()
	var wood := Color("4a3b2e")
	var steel := Color("7d838b")
	for i in 3:
		Meshes.box(st, Vector3(-0.42 + i * 0.33, 0.0, -0.4), Vector3(0.17, 0.05, 0.8), wood)
	for zr in [-0.25, 0.19]:
		Meshes.box(st, Vector3(-0.5, 0.05, zr), Vector3(1.0, 0.07, 0.06), steel.darkened(0.25), Color("b8bec6"))
	return Meshes._finish(st)

## Level crossing furniture (track east-west, the road crossing north-south): the deck is the tile's own
## ground, this adds plank seams and two red-and-white barrier posts on opposite corners, warning lamps on top.
static func crossing_deck() -> ArrayMesh:
	var st := Meshes._st()
	var seam := Color("4f4233")
	for zz in [-0.33, 0.33]:
		Meshes.box(st, Vector3(-0.5, 0.075, zz - 0.01), Vector3(1.0, 0.01, 0.02), seam)
	for c in [Vector2(-0.44, -0.46), Vector2(0.38, 0.4)]:
		var x: float = c.x
		var zc: float = c.y
		Meshes.box(st, Vector3(x - 0.02, 0.0, zc - 0.02), Vector3(0.1, 0.06, 0.1), Color("3c4450"))
		for i in 4:
			Meshes.box(st, Vector3(x, 0.06 + i * 0.13, zc), Vector3(0.06, 0.13, 0.06), Color("c8102e") if i % 2 == 0 else Color("f2efe6"))
		Meshes.box(st, Vector3(x - 0.06, 0.58, zc - 0.01), Vector3(0.18, 0.08, 0.08), Color("1d1d1d"))
		for dx in [-0.04, 0.08]:
			Meshes.box(st, Vector3(x + dx, 0.6, zc + 0.07), Vector3(0.04, 0.04, 0.012), Color("e0412e"))
	return Meshes._finish(st)

## Buffer stop at the end of a line. Local +X faces along the track (the way trains come from);
## ZoneBuilder turns it to face its line.
static func buffer_stop() -> ArrayMesh:
	var st := Meshes._st()
	var iron := Color("2e3238")
	var red := Color("b3261e")
	# sleepered base and the rails bending up into the frame
	Meshes.box(st, Vector3(-0.42, 0.0, -0.42), Vector3(0.6, 0.06, 0.84), Color("4a3b2e"))
	for zr in [-0.25, 0.19]:
		Meshes.box(st, Vector3(-0.3, 0.06, zr), Vector3(0.12, 0.42, 0.06), iron)
		Meshes.box(st, Vector3(-0.38, 0.06, zr), Vector3(0.5, 0.1, 0.06), iron)
	# the beam, red with a white stripe, and two sprung buffers facing the train
	Meshes.box(st, Vector3(-0.2, 0.28, -0.46), Vector3(0.18, 0.26, 0.92), red)
	Meshes.box(st, Vector3(-0.02, 0.36, -0.3), Vector3(0.005, 0.07, 0.6), Color("f2efe6"))
	for zb in [-0.38, 0.26]:
		Meshes.box(st, Vector3(-0.02, 0.35, zb), Vector3(0.14, 0.08, 0.12), iron)
		Meshes.box(st, Vector3(0.12, 0.32, zb - 0.02), Vector3(0.04, 0.14, 0.16), Color("9aa0a8"))
	# the lamp on top
	Meshes.box(st, Vector3(-0.15, 0.54, -0.06), Vector3(0.1, 0.16, 0.12), iron)
	Meshes.box(st, Vector3(-0.05, 0.6, -0.04), Vector3(0.012, 0.07, 0.08), Color("ff3b2a"))
	return Meshes._finish(st)

## A tunnel mouth: a stone portal with a dark bore, set in a grassy bank (variant 0) or a sooty brick
## tube mouth with no bank (variant 1, the Underground). Local +X faces along the track, out of the tunnel.
## The bore is 0.9 wide and 1.05 high, so a train fits; RailTraffic clips trains at local x = 0.
static func tunnel_portal(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var tube := variant == 1
	var stone := Color("6b3a2e") if tube else Color("8f8270")
	var bank := Color("3a2f2b") if tube else Color("6a5238")
	var bank_top := Color("2a2220") if tube else Color("527f37")
	var dark := Color("0b0b0d")
	# a tube mouth is exactly one tile wide, so two side by side make a double-track tunnel
	var hw := 0.5 if tube else 0.98
	var pier := 0.5 if tube else 0.82
	# the bank (or brickwork) round the bore, running back over the tile behind and stepping up into a knoll
	Meshes.box(st, Vector3(-1.4, 0, -hw), Vector3(1.68, 1.32, hw - 0.46), bank, bank_top)
	Meshes.box(st, Vector3(-1.4, 0, 0.46), Vector3(1.68, 1.32, hw - 0.46), bank, bank_top)
	Meshes.box(st, Vector3(-0.5, 1.05, -0.46), Vector3(0.78, 0.27, 0.92), bank, bank_top)
	Meshes.box(st, Vector3(-1.4, 0, -0.46), Vector3(0.9, 1.32, 0.92), bank, bank_top)
	if not tube:
		Meshes.box(st, Vector3(-1.25, 1.32, -0.8), Vector3(1.35, 0.28, 1.6), bank, bank_top.darkened(0.04))
		Meshes.box(st, Vector3(-1.0, 1.6, -0.5), Vector3(0.85, 0.2, 1.0), bank, bank_top.lightened(0.04))
	# the bore: black lining inside
	Meshes.box(st, Vector3(-0.5, 0, -0.46), Vector3(0.78, 1.05, 0.01), dark)
	Meshes.box(st, Vector3(-0.5, 0, 0.45), Vector3(0.78, 1.05, 0.01), dark)
	Meshes.box(st, Vector3(-0.5, 1.04, -0.46), Vector3(0.78, 0.01, 0.92), dark)
	Meshes.box(st, Vector3(-0.5, 0, -0.46), Vector3(0.02, 1.05, 0.92), dark)
	Meshes.box(st, Vector3(-0.5, 0.0, -0.46), Vector3(0.78, 0.04, 0.92), Color("1a1816"))
	# the portal face: piers, an arch of voussoirs, a parapet
	Meshes.box(st, Vector3(0.28, 0, -pier), Vector3(0.14, 1.05, pier - 0.46), stone)
	Meshes.box(st, Vector3(0.28, 0, 0.46), Vector3(0.14, 1.05, pier - 0.46), stone)
	Meshes.box(st, Vector3(0.28, 1.05, -pier), Vector3(0.14, 0.36, pier * 2), stone)
	for i in 5:
		var zz := -0.46 + i * 0.184
		var lift := 0.05 * (2 - absi(i - 2))
		Meshes.box(st, Vector3(0.4, 0.92 + lift, zz), Vector3(0.03, 0.14, 0.18), stone.lightened(0.1 if i % 2 == 0 else 0.0))
	var top := 0.5 if tube else 0.9
	Meshes.box(st, Vector3(0.24, 1.41, -top), Vector3(0.22, 0.09, top * 2), stone.darkened(0.15))
	return Meshes._finish(st)

## Train cars for RailTraffic, 1.5 long, nose along +X, wheels on y = 0 (the rail top), centred on the origin.
## `cab` puts a driving cab on the +X end (yellow warning panel, windscreen, lamps).
## Window colours carry alpha 0.4 so the train shader can light them up at night.
static func train_car(livery: Color, cab: bool) -> ArrayMesh:
	var st := Meshes._st()
	var under := Color("26282c")
	var roof := Color("b9bec4")
	var win := Color(0.16, 0.2, 0.26, 0.4)
	Meshes.box(st, Vector3(-0.62, 0.0, -0.28), Vector3(0.34, 0.16, 0.56), under)
	Meshes.box(st, Vector3(0.28, 0.0, -0.28), Vector3(0.34, 0.16, 0.56), under)
	Meshes.box(st, Vector3(-0.72, 0.13, -0.33), Vector3(1.44, 0.1, 0.66), under)
	var band := livery.lightened(0.6)
	Meshes.box(st, Vector3(-0.72, 0.23, -0.37), Vector3(1.44, 0.6, 0.74), livery, roof)
	Meshes.box(st, Vector3(-0.725, 0.44, -0.375), Vector3(1.45, 0.34, 0.75), band, roof)
	Meshes.box(st, Vector3(-0.7, 0.83, -0.33), Vector3(1.4, 0.07, 0.66), roof)
	Meshes.box(st, Vector3(-0.66, 0.9, -0.22), Vector3(1.32, 0.04, 0.44), roof.lightened(0.1))
	# windows down both sides, doors by the ends
	var x0 := -0.5
	var x1 := 0.3 if cab else 0.5
	var n := 4 if cab else 5
	for i in n:
		var wx := x0 + (x1 - x0) * (float(i) / float(n - 1)) - 0.08
		for zs in [-0.38, 0.37]:
			Meshes.box(st, Vector3(wx, 0.5, zs), Vector3(0.16, 0.2, 0.01), win)
	for dx in [-0.68, 0.56 if not cab else 0.42]:
		for zs in [-0.38, 0.37]:
			Meshes.box(st, Vector3(dx, 0.24, zs), Vector3(0.12, 0.55, 0.01), livery.darkened(0.25))
	if cab:
		Meshes.box(st, Vector3(0.72, 0.23, -0.36), Vector3(0.05, 0.36, 0.72), Color("e8c21a"))
		Meshes.box(st, Vector3(0.72, 0.59, -0.33), Vector3(0.04, 0.2, 0.66), win)
		Meshes.box(st, Vector3(0.72, 0.79, -0.36), Vector3(0.05, 0.04, 0.72), livery)
		for zl in [-0.28, 0.2]:
			Meshes.box(st, Vector3(0.77, 0.3, zl), Vector3(0.015, 0.06, 0.08), Color(1.0, 0.96, 0.82, 0.4))
	else:
		Meshes.box(st, Vector3(0.72, 0.23, -0.26), Vector3(0.04, 0.55, 0.52), under)
	Meshes.box(st, Vector3(-0.76, 0.23, -0.26), Vector3(0.04, 0.55, 0.52), under)
	return Meshes._finish(st)

## The ferry (variant 0, long, red funnel) or a fishing boat (variant 1).
static func boat(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	if variant == 0:
		Meshes.box(st, Vector3(-2.2, -0.2, -0.7), Vector3(4.4, 0.8, 1.4), Color("1f2b44"), Color("d9d4c6"))
		Meshes.box(st, Vector3(-1.4, 0.6, -0.55), Vector3(2.6, 0.7, 1.1), Color("f2efe6"))
		Meshes.box(st, Vector3(-1.2, 1.3, -0.45), Vector3(1.6, 0.4, 0.9), Color("f2efe6"))
		Meshes.cylinder(st, Vector3(0.6, 1.3, 0), 0.25, 0.7, 8, Color("c8102e"))
		Meshes.cylinder(st, Vector3(0.6, 2.0, 0), 0.22, 0.15, 8, Color("1d1d1d"))
	else:
		Meshes.box(st, Vector3(-0.7, -0.15, -0.35), Vector3(1.4, 0.45, 0.7), Color("2f6b8a"), Color("a8774f"))
		Meshes.box(st, Vector3(-0.2, 0.3, -0.25), Vector3(0.5, 0.45, 0.5), Color("e8e2d4"))
		Meshes.box(st, Vector3(0.45, 0.3, -0.03), Vector3(0.05, 1.0, 0.05), Color("5a4636"))
	return Meshes._finish(st)

## A narrowboat, long and thin, in canal colours.
static func canal_boat(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var body: Color = [Color("2f5a3c"), Color("7a1f2b"), Color("1f3d6b")][variant % 3]
	Meshes.box(st, Vector3(-1.5, -0.15, -0.28), Vector3(3.0, 0.35, 0.56), Color("1d1d1d"))
	Meshes.box(st, Vector3(-1.1, 0.2, -0.25), Vector3(2.3, 0.4, 0.5), body, Color("c9a96b"))
	for i in 4:
		Meshes.box(st, Vector3(-0.9 + i * 0.55, 0.32, 0.25), Vector3(0.22, 0.16, 0.02), Color("f2d38a"))
	Meshes.cylinder(st, Vector3(0.9, 0.6, 0), 0.05, 0.25, 6, Color("1d1d1d"))
	return Meshes._finish(st)

static func bollard() -> ArrayMesh:
	var st := Meshes._st()
	Meshes.cylinder(st, Vector3(0, 0, 0), 0.16, 0.4, 8, Color("2a2f38"))
	Meshes.cylinder(st, Vector3(0, 0.4, 0), 0.2, 0.08, 8, Color("2a2f38"))
	return Meshes._finish(st)

static func buoy(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var rng := Meshes._rng(9500)
	Meshes.blob(st, Vector3(0, 0.05, 0), Vector3(0.25, 0.2, 0.25), Color("d9481f") if variant == 0 else Color("e8c832"), rng, 0.02)
	Meshes.box(st, Vector3(-0.03, 0.2, -0.03), Vector3(0.06, 0.35, 0.06), Color("2a2f38"))
	return Meshes._finish(st)

static func lighthouse() -> ArrayMesh:
	var st := Meshes._st()
	for i in 5:
		Meshes.cylinder(st, Vector3(0, i * 0.6, 0), 0.5 - i * 0.04, 0.6, 10, Color("f2efe6") if i % 2 == 0 else Color("c8102e"))
	Meshes.cylinder(st, Vector3(0, 3.0, 0), 0.4, 0.4, 10, Color("f8e9a0"))
	Meshes.cylinder(st, Vector3(0, 3.4, 0), 0.45, 0.15, 10, Color("1d1d1d"))
	return Meshes._finish(st)

static func statue(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var rng := Meshes._rng(9600 + variant)
	Meshes.box(st, Vector3(-0.35, 0, -0.35), Vector3(0.7, 0.7, 0.7), LIMESTONE)
	var bronze := Color("5d7a62")
	Meshes.box(st, Vector3(-0.12, 0.7, -0.1), Vector3(0.24, 0.7, 0.2), bronze)
	Meshes.blob(st, Vector3(0, 1.55, 0), Vector3(0.13, 0.15, 0.13), bronze, rng, 0.03)
	return Meshes._finish(st)

static func harp() -> ArrayMesh:
	var st := Meshes._st()
	var wood := Color("a8774f")
	Meshes.box(st, Vector3(-0.3, 0, -0.1), Vector3(0.6, 0.12, 0.2), wood)
	Meshes.box(st, Vector3(-0.3, 0, -0.06), Vector3(0.1, 1.3, 0.12), wood)
	Meshes.box(st, Vector3(-0.3, 1.2, -0.06), Vector3(0.6, 0.1, 0.12), wood.darkened(0.1))
	for i in 5:
		Meshes.box(st, Vector3(-0.15 + i * 0.08, 0.12, -0.01), Vector3(0.012, 1.08 - i * 0.12, 0.012), Color("f2e2a0"))
	return Meshes._finish(st)
