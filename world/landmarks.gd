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
const PEAT := Color("4a3626")
const LIMESTONE := Color("c9c0aa")
const PORTLAND := Color("d8d2c2")    # Liver Building granite and Portland stone, near enough
const IRON := Color("3c4450")
const GLASS := Color.WHITE

## Building styles handled here rather than by the generic house in Meshes.building.
const SPECIAL := ["glass_tower", "gantry_crane", "cantilever_crane", "titanic", "mill", "castle", "cathedral", "liver_building", "station", "aqueduct", "chapel", "terrace", "tudor", "slate_cottage", "lighthouse_house", "round_tower", "passage_tomb", "field_barn", "blackpool_tower", "big_one", "blackpool_tram", "pier_pavilion", "veranda_shop", "guest_house"]

## Doors: where each style's door sits on its tile (see _door and friends), for the swing as you go in.
## {x, w, y, h, z}: left edge and width across the door column, bottom and height, z of the door's face from
## the footprint's south edge. Styles drawn by Meshes.building (and anything unknown) use DOOR_PLAIN.
const DOOR_PLAIN := {"x": 0.22, "w": 0.56, "y": 0.18, "h": 0.9, "z": -0.02}
const DOOR_RECTS := {
	"mill": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 1.1, "z": -0.02},
	"station": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 1.0, "z": -0.02},
	"chapel": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 1.1, "z": -0.02},
	"liver_building": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 1.2, "z": -0.02},
	"terrace": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 0.9, "z": -0.02},
	"tudor": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 0.9, "z": -0.02},
	"slate_cottage": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 0.9, "z": -0.02},
	"lighthouse_house": {"x": 0.22, "w": 0.56, "y": 0.16, "h": 0.9, "z": -0.02},
	"castle": {"x": 0.2, "w": 0.6, "y": 0.0, "h": 1.1, "z": 0.11},
	"cathedral": {"x": 0.15, "w": 0.7, "y": 0.0, "h": 1.3, "z": 0.03},
	"glass_tower": {"x": 0.15, "w": 0.7, "y": 0.0, "h": 1.2, "z": 0.02},
}
const DOOR_OPEN_ANGLE := -1.75     # radians about the hinge: swings out toward you, about 100 degrees
const DOOR_SWING_SECS := 0.16
const DOOR_WOOD := Color("3b2a22")
static var _doorway_mat: StandardMaterial3D
static var _leaf_mat: StandardMaterial3D

static func door_rect(style: String) -> Dictionary:
	return DOOR_RECTS.get(style, DOOR_PLAIN)

## A door that opens: a dark doorway over the painted door, and a leaf on a hinge ("Hinge", turned by
## DOOR_OPEN_ANGLE to open). Local origin is the door column's south-west corner at ground level.
static func door_swing(style: String) -> Node3D:
	var r := door_rect(style)
	if _doorway_mat == null:
		_doorway_mat = StandardMaterial3D.new()
		_doorway_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_doorway_mat.albedo_color = Color(0.03, 0.025, 0.03)
		_leaf_mat = StandardMaterial3D.new()
		_leaf_mat.albedo_color = DOOR_WOOD
	var root := Node3D.new()
	root.name = "DoorSwing"
	var hole := MeshInstance3D.new()
	hole.name = "Doorway"
	var hm := BoxMesh.new()
	hm.size = Vector3(float(r.w), float(r.h), 0.02)
	hole.mesh = hm
	hole.material_override = _doorway_mat
	hole.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	hole.position = Vector3(float(r.x) + float(r.w) * 0.5, float(r.y) + float(r.h) * 0.5, float(r.z) + 0.012)
	root.add_child(hole)
	var hinge := Node3D.new()
	hinge.name = "Hinge"
	hinge.position = Vector3(float(r.x), float(r.y), float(r.z) + 0.03)
	root.add_child(hinge)
	var leaf := MeshInstance3D.new()
	leaf.name = "Leaf"
	var lm := BoxMesh.new()
	lm.size = Vector3(float(r.w), float(r.h), 0.05)
	leaf.mesh = lm
	leaf.material_override = _leaf_mat
	leaf.position = Vector3(float(r.w) * 0.5, float(r.h) * 0.5, 0.0)
	hinge.add_child(leaf)
	return root

## Per-window variety for the night: shared by every _window in one building() call.
static var _wr := RandomNumberGenerator.new()
## Chimney tops (local) collected while building, for the smoke.
static var _chimneys := PackedVector3Array()

## A pane's vertex colour: rgb = brightness when lit (0 = an empty, dark room), alpha = how late in the night
## it goes out (1 = burns all night). See SkyAndLight.lateness and art/shaders/windows.gdshader.
static func window_colour(rng: RandomNumberGenerator) -> Color:
	if rng.randf() < 0.15:
		return Color(0, 0, 0, 1)
	var b := rng.randf_range(0.55, 1.0)
	var bedtime := rng.randf_range(0.1, 0.95) if rng.randf() < 0.4 else 1.0
	return Color(b, b, b, bedtime)

## Returns [body_mesh, windows_mesh, chimney tops (PackedVector3Array, local)].
static func building(w: int, d: int, style: String, door_x: int, seed_value: int, region := "") -> Array:
	var rng := Meshes._rng(seed_value)
	var st := Meshes._st()
	var wst := Meshes._st()
	_wr.seed = seed_value * 7 + 3
	_chimneys = PackedVector3Array()
	match style:
		"mill":
			_mill(st, wst, w, d, door_x, rng)
		"castle":
			_castle(st, wst, w, d, door_x, region)
		"cathedral":
			_cathedral(st, wst, w, d, door_x, SANDSTONE)
		"chapel":
			_chapel(st, wst, w, d, door_x)
		"round_tower":
			_round_tower(st, wst, w, d, door_x)
		"passage_tomb":
			_passage_tomb(st, w, d, door_x)
		"field_barn":
			_field_barn(st, w, d, rng)
		"liver_building":
			_liver(st, wst, w, d, door_x)
		"station":
			_station(st, wst, w, d, door_x)
		"aqueduct":
			_aqueduct(st, w, d)
		"gantry_crane":
			_gantry(st, w, d)
		"cantilever_crane":
			_cantilever(st, w, d)
		"titanic":
			_titanic(st, wst, w, d, door_x, rng)
		"glass_tower":
			_glass_tower(st, wst, w, d, door_x)
		"terrace":
			_house(st, wst, w, d, door_x, rng, BRICK, SLATE, 2, true, false)
		"tudor":
			_house(st, wst, w, d, door_x, rng, Color("ece5d2"), Color("5a4a44"), 2, false, true)
		"slate_cottage":
			_house(st, wst, w, d, door_x, rng, SLATE_WALL, SLATE.darkened(0.2), 1, false, false)
		"blackpool_tower":
			_blackpool_tower(st, wst, w, d, door_x)
		"big_one":
			_big_one(st, wst, w, d)
		"blackpool_tram":
			_blackpool_tram(st, wst, w, d)
		"pier_pavilion":
			_pier_pavilion(st, wst, w, d, door_x)
		"veranda_shop":
			_veranda_shop(st, wst, w, d, door_x, rng)
		"guest_house":
			_guest_house(st, wst, w, d, door_x, rng)
		_:
			_house(st, wst, w, d, door_x, rng, BRICK, SLATE, 2, false, false)
	return [Meshes._finish(st), Meshes._finish(wst), _chimneys]

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
			_chimneys.append(Vector3(i, hgt + 1.39, d * 0.5 - 0.07))
	else:
		var cx := rng.randf_range(0.6, maxf(0.7, w - 0.9))
		Meshes.box(st, Vector3(cx, hgt + 0.3, d * 0.5 - 0.2), Vector3(0.35, 0.95, 0.4), wall.darkened(0.2) if not tudor else Color("8a4b3b"))
		_chimneys.append(Vector3(cx + 0.175, hgt + 1.25, d * 0.5))
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
	Meshes.box(wst, Vector3(x + 0.05, y, d - 0.065), Vector3(ww - 0.1, wh - 0.02, 0.04), window_colour(_wr))

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
	_chimneys.append(Vector3(cx, hgt + 3.5, d * 0.4))
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
static func _castle(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, region := "") -> void:
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
	# a pennant on the first tower, and on the far one too on a bigger castle
	var poles := [Vector2(0.4, 0.4)]
	if w >= 6:
		poles.append(Vector2(w - 0.4, 0.4))
	for p in poles:
		Meshes.box(st, Vector3(p.x - 0.025, wall_h + 1.3, p.y - 0.025), Vector3(0.05, 1.0, 0.05), Color("3b2a22"))
		_pennant(st, Vector3(p.x + 0.03, wall_h + 2.25, p.y), region)

## Pennant cloth colours (also the tests' way of telling one nation's from another's).
const PENNANT_RED := Color("c8102e")
const PENNANT_WHITE := Color("f4f1e8")
const PENNANT_BLUE := Color("0065bd")
const PENNANT_GREEN := Color("1f7a3a")
const PENNANT_ORANGE := Color("ff883e")
const PENNANT_BLACK := Color("1c1c1e")
const PENNANT_GOLD := Color("e0b03a")
const PENNANT_L := 0.78     # hoist to tips
const PENNANT_H := 0.42     # at the hoist; it tapers to the fly
const PENNANT_NOTCH := 0.32 # how far the swallowtail's fork cuts back, as a fraction of the length
## Which pennant a region flies.
const PENNANT_KINDS := {
	"cheshire": "st_george", "peak": "st_george", "manchester": "st_george", "merseyside": "st_george",
	"midlands": "st_george", "south_england": "st_george", "yorkshire": "st_george", "north_east": "st_george",
	"cumbria": "st_george", "lancashire": "st_george", "cornwall": "st_piran", "north_wales": "wales", "mid_wales": "wales",
	"south_wales": "wales", "scotland": "saltire", "ireland": "ireland", "ireland_west": "ireland",
	"ireland_east": "ireland", "man": "man",
}

## A castle's swallowtail pennant on its own, the hoist's top at the origin, flying along +x.
static func pennant(region := "") -> ArrayMesh:
	var st := Meshes._st()
	_pennant(st, Vector3.ZERO, region)
	return Meshes._finish(st)

## A tapering, forked pennant hung from `top` (the hoist's top corner), flying east in the XY plane, cloth
## both sides. A grid of cells, each half (upper and lower) squeezed so its fly edge runs from the tip in to
## the fork; a cell takes the colour of the region's design at its centre.
static func _pennant(st: SurfaceTool, top: Vector3, region: String) -> void:
	var kind: String = PENNANT_KINDS.get(region, "")
	var cols := 12
	var rows := 4  # per half
	var yc := top.y - PENNANT_H * 0.5
	for half in 2:
		for r in rows:
			for c in cols:
				var v0 := (r + half * rows) / float(rows * 2)
				var v1 := (r + 1 + half * rows) / float(rows * 2)
				var u0 := c / float(cols)
				var u1 := (c + 1) / float(cols)
				var a := _pennant_pt(top, yc, u0, v0)
				var b := _pennant_pt(top, yc, u1, v0)
				var cc := _pennant_pt(top, yc, u1, v1)
				var d := _pennant_pt(top, yc, u0, v1)
				var mid := (a + b + cc + d) * 0.25
				var col := _pennant_colour(kind, (mid.x - top.x) / PENNANT_L, (v0 + v1) * 0.5)
				Meshes._quad(st, a, b, cc, d, col)
				Meshes._quad(st, a, d, cc, b, col)  # the back

## A point on the pennant: u along its length (0 hoist .. 1 fly edge at this height), v down it (0 .. 1).
static func _pennant_pt(top: Vector3, yc: float, u: float, v: float) -> Vector3:
	var fly := 1.0 - PENNANT_NOTCH * (1.0 - absf(2.0 * v - 1.0))
	var x := u * fly
	var taper := 1.0 - 0.45 * x
	return Vector3(top.x + x * PENNANT_L, yc + (0.5 - v) * PENNANT_H * taper, top.z)

## The design: x along the length (0 .. 1 at the tips), v down it. Crosses sit in the hoist square.
static func _pennant_colour(kind: String, x: float, v: float) -> Color:
	var hoist := x < 0.44
	match kind:
		"st_george":
			if hoist and (absf(x - 0.21) < 0.07 or absf(v - 0.5) < 0.13):
				return PENNANT_RED
			return PENNANT_WHITE
		"st_piran":
			if hoist and (absf(x - 0.21) < 0.07 or absf(v - 0.5) < 0.13):
				return PENNANT_WHITE
			return PENNANT_BLACK
		"saltire":
			if hoist and absf(absf(x - 0.21) / 0.21 - absf(v - 0.5) / 0.5) < 0.3:
				return PENNANT_WHITE
			return PENNANT_BLUE
		"wales":
			if x < 0.16:
				return PENNANT_RED
			return PENNANT_WHITE if v < 0.5 else PENNANT_GREEN
		"ireland":
			if x < 0.33:
				return PENNANT_GREEN
			return PENNANT_WHITE if x < 0.62 else PENNANT_ORANGE
		"man":
			return PENNANT_GOLD if x < 0.16 else PENNANT_RED
	return PENNANT_GOLD if x < 0.16 else PENNANT_RED

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

## An Irish round tower: a tall tapering stone needle with a conical cap, standing at the front of its plot (the door
## faces south); the rest of the footprint is a little walled churchyard.
static func _round_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("a39d8e")
	var r := minf(w, 2.0) * 0.45
	var c := Vector3(w * 0.5, 0, d - r - 0.08)
	var h := 5.6
	Meshes.cylinder(st, c, r, h, 10, stone)
	Meshes.cone(st, c + Vector3(0, h, 0), r * 0.95, 1.3, 10, stone.darkened(0.12), Meshes._rng(41))
	for y in [2.4, 3.6, 4.8]:
		_window(st, wst, c.x - 0.1, y, c.z + r * 0.9 + 0.05, 0.2, 0.32, stone.darkened(0.2))
	if door_x >= 0:  # one door, centred on the tower whichever tile the warp is on
		Meshes.box(st, Vector3(c.x - 0.25, 0.1, c.z + r - 0.12), Vector3(0.5, 0.85, 0.12), Color("3b2a22"))
		Meshes.box(st, Vector3(c.x - 0.31, 0.95, c.z + r - 0.13), Vector3(0.62, 0.08, 0.13), stone.lightened(0.2))
	# churchyard wall round the rest of the plot
	var wall := stone.darkened(0.1)
	var back := c.z - r
	if back > 0.6:
		Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, 0.45, 0.2), wall)
		Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(0.2, 0.45, back), wall)
		Meshes.box(st, Vector3(w - 0.25, 0, 0.05), Vector3(0.2, 0.45, back), wall)

## A Neolithic passage tomb (Newgrange): a low grassy mound ringed at the front by white quartz, with the dark
## passage mouth and its carved entrance stone on the south side.
static func _passage_tomb(st: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var grass := Color("5f8a3e")
	var quartz := Color("eceae2")
	var c := Vector3(w * 0.5, 0, d * 0.5)
	var rx := w * 0.5
	var rz := d * 0.5
	var sides := 16
	var wall_h := 0.75
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.03, d), grass.darkened(0.05))  # turf in the plot's corners
	# quartz revetment: a band round the whole base (the back is hidden in the grass anyway)
	var lo := _ellipse(c, rx, rz, 0.0, sides)
	var hi := _ellipse(c, rx, rz, wall_h, sides)
	for i in sides:
		var j := (i + 1) % sides
		var col := quartz if lo[i].z > c.z - 0.2 else quartz.darkened(0.25)
		Meshes._quad(st, lo[i], lo[j], hi[j], hi[i], col.darkened(0.05 * (i % 2)))
	# the grassy dome on top, in bands
	var bands := [[0.98, wall_h], [0.85, wall_h + 0.45], [0.62, wall_h + 0.8], [0.3, wall_h + 1.0]]
	var prev := _ellipse(c, rx, rz, wall_h, sides)
	for b in bands.slice(1):
		var ring := _ellipse(c, rx * b[0], rz * b[0], b[1], sides)
		for i in sides:
			var j := (i + 1) % sides
			Meshes._quad(st, prev[i], prev[j], ring[j], ring[i], grass.lightened(0.04 * (i % 3)))
		prev = ring
	for i in sides:
		Meshes._tri(st, prev[i], prev[(i + 1) % sides], Vector3(c.x, wall_h + 1.08, c.z), grass.lightened(0.08))
	# the passage mouth, its lintel stones, and the carved kerbstone lying across the front
	var mx := (door_x + 0.5) if door_x >= 0 else c.x
	var fz := c.z + rz
	Meshes.box(st, Vector3(mx - 0.22, 0.2, fz - 0.06), Vector3(0.44, 0.5, 0.1), Color("1d1a17"))
	Meshes.box(st, Vector3(mx - 0.36, 0.7, fz - 0.08), Vector3(0.72, 0.14, 0.14), Color("8d8678"))
	Meshes.box(st, Vector3(mx - 0.3, 0.86, fz - 0.1), Vector3(0.6, 0.12, 0.12), Color("8d8678"))
	Meshes.box(st, Vector3(mx - 0.55, 0, fz - 0.22), Vector3(1.1, 0.26, 0.24), Color("9a9384"))

static func _ellipse(c: Vector3, rx: float, rz: float, y: float, sides: int) -> Array:
	var pts := []
	for i in sides:
		var a := TAU * i / sides
		pts.append(Vector3(c.x + cos(a) * rx, y, c.z + sin(a) * rz))
	return pts

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

## Glasgow's Finnieston Crane: a dark lattice tower on the quay and a hammerhead jib across the top, its long
## arm out over the river to the south (+z) with the hook hanging above the water, the machinery house and
## counterweight on the short tail behind.
static func _cantilever(st: SurfaceTool, w: int, d: int) -> void:
	var steel := Color("2e3236")
	var lit := steel.lightened(0.12)
	var h := 6.8
	var cx := w * 0.5
	var cz := d * 0.5
	# the tower: four legs leaning in, a cross-brace every storey
	var foot := 0.95
	var top := 0.6
	var legs := [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	for c in legs:
		var a := Vector3(cx + c.x * foot, 0, cz + c.y * foot)
		var b := Vector3(cx + c.x * top, h, cz + c.y * top)
		_strut(st, a, b, 0.14, steel)
	for i in 4:
		var y := 1.2 + i * 1.4
		var r := lerpf(foot, top, y / h)
		Meshes.box(st, Vector3(cx - r, y, cz - r), Vector3(r * 2, 0.1, 0.1), lit)
		Meshes.box(st, Vector3(cx - r, y, cz + r - 0.1), Vector3(r * 2, 0.1, 0.1), lit)
		Meshes.box(st, Vector3(cx - r, y, cz - r), Vector3(0.1, 0.1, r * 2), lit)
		Meshes.box(st, Vector3(cx + r - 0.1, y, cz - r), Vector3(0.1, 0.1, r * 2), lit)
	Meshes.box(st, Vector3(cx - 1.15, 0, cz - 1.15), Vector3(2.3, 0.2, 2.3), Color("8a8478"))  # plinth
	# the jib: a deep box girder from the tail (north) out over the water (south)
	var z0 := cz - 2.2
	var z1 := d + 4.3
	Meshes.box(st, Vector3(cx - 0.45, h, z0), Vector3(0.9, 0.7, z1 - z0), steel, lit)
	Meshes.box(st, Vector3(cx - 0.5, h + 0.7, z0), Vector3(1.0, 0.08, z1 - z0), lit)  # walkway on top
	Meshes.box(st, Vector3(cx - 0.75, h + 0.78, z0 + 0.1), Vector3(1.5, 1.0, 1.6), steel.lightened(0.05))  # machinery house
	Meshes.box(st, Vector3(cx - 0.6, h - 0.9, z0), Vector3(1.2, 0.9, 0.9), Color("4a4e52"))  # counterweight
	# trolley, cable and hook out at the end of the arm
	var hz := z1 - 1.2
	Meshes.box(st, Vector3(cx - 0.35, h - 0.25, hz - 0.35), Vector3(0.7, 0.25, 0.7), IRON.lightened(0.15))
	Meshes.box(st, Vector3(cx - 0.04, 1.3, hz - 0.04), Vector3(0.08, h - 1.55, 0.08), Color("1e1e1e"))
	Meshes.box(st, Vector3(cx - 0.22, 0.95, hz - 0.22), Vector3(0.44, 0.35, 0.44), Color("c8a020"))  # hook block, painted

## A square strut from a to b (a mostly vertical member), built as a skewed box.
static func _strut(st: SurfaceTool, a: Vector3, b: Vector3, t: float, col: Color) -> void:
	var h := t * 0.5
	var lo := [a + Vector3(-h, 0, -h), a + Vector3(h, 0, -h), a + Vector3(h, 0, h), a + Vector3(-h, 0, h)]
	var hi := [b + Vector3(-h, 0, -h), b + Vector3(h, 0, -h), b + Vector3(h, 0, h), b + Vector3(-h, 0, h)]
	for i in 4:
		var j := (i + 1) % 4
		Meshes._quad(st, lo[i], lo[j], hi[j], hi[i], col.darkened(0.06 * (i % 2)))

## Titanic Belfast: four angular ship's prows, one rising toward each corner, flaring out as they climb and clad
## in silver shards, round a glass atrium whose front holds the door. The prows' tips stand highest, like bows.
static func _titanic(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var c := Vector2(w * 0.5, d * 0.5)
	var h := maxf(5.4, d * 0.8)
	var glass := Color("35505f")
	var frame := Color("23303a")
	# the atrium: a glass box between the prows, reaching the front edge for the door
	var aw := minf(3.2, w * 0.3)
	Meshes.box(st, Vector3(c.x - aw * 0.5, 0, c.y - d * 0.2), Vector3(aw, h * 0.7, d * 0.7), glass, frame)
	for r in 3:
		for i in int(aw / 0.5):
			var x := c.x - aw * 0.5 + 0.1 + i * 0.5
			if r == 0 and door_x >= 0 and x >= door_x - 0.3 and x <= door_x + 1.0:
				continue
			Meshes.box(wst, Vector3(x, 0.35 + r * 1.1, d - 0.03), Vector3(0.36, 0.7, 0.04), window_colour(_wr))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.12, 0, d - 0.06), Vector3(0.76, 1.1, 0.08), frame)
	# the prows: a kite in plan (inner corner, two flanks, the bow), pointing at a footprint corner
	var half := Vector2(w * 0.5, d * 0.5)
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var o := (corner * half).normalized()
		var perp := Vector2(o.y, -o.x)
		var reach := (corner * half).length() - 0.55
		var flank := reach * 0.5
		var hw := minf(1.4, half.y * 0.42)
		var plan := [c + o * 0.6, c + o * flank + perp * hw, c + o * reach, c + o * flank - perp * hw]
		var tops := [h * 0.8, h * 0.9, h * 1.08, h * 0.9]
		var lo := []
		var hi := []
		for i in 4:
			var p: Vector2 = plan[i]
			# lean out as it climbs: the walls flare, the bow most of all
			var lean: Vector2 = (p - c) * (0.1 if i != 2 else 0.12)
			lo.append(Vector3(p.x, 0, p.y))
			hi.append(Vector3(p.x + lean.x, tops[i], p.y + lean.y))
		hi[2] = Vector3(clampf(hi[2].x, -0.2, w + 0.2), hi[2].y, clampf(hi[2].z, -0.2, d + 0.2))
		for i in 4:
			var j := (i + 1) % 4
			_shards(st, lo[i], lo[j], hi[j], hi[i], 3, 5, rng)
		_shards(st, hi[0], hi[1], hi[2], hi[3], 2, 2, rng, 0.08)  # the deck, darker

## A wall clad in silver shards: the quad a-b-c-d (a, b along the bottom) cut into a cols x rows grid, each
## cell split corner to corner into two triangles of different silvers.
static func _shards(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, cols: int, rows: int, rng: RandomNumberGenerator, dark := 0.0) -> void:
	var base := Color("c4cad0")
	for r in rows:
		for k in cols:
			var u0 := k / float(cols)
			var u1 := (k + 1) / float(cols)
			var v0 := r / float(rows)
			var v1 := (r + 1) / float(rows)
			var p00 := _bilerp(a, b, c, d, u0, v0)
			var p10 := _bilerp(a, b, c, d, u1, v0)
			var p11 := _bilerp(a, b, c, d, u1, v1)
			var p01 := _bilerp(a, b, c, d, u0, v1)
			var s1 := base.lightened(rng.randf_range(0.0, 0.2)).darkened(dark) if rng.randf() < 0.5 else base.darkened(rng.randf_range(0.0, 0.16) + dark)
			var s2 := base.lerp(Color("aebccb"), rng.randf_range(0.2, 0.7)).darkened(dark)
			if (r + k) % 2 == 0:
				Meshes._tri(st, p00, p10, p11, s1)
				Meshes._tri(st, p00, p11, p01, s2)
			else:
				Meshes._tri(st, p00, p10, p01, s2)
				Meshes._tri(st, p10, p11, p01, s1)

static func _bilerp(a: Vector3, b: Vector3, c: Vector3, d: Vector3, u: float, v: float) -> Vector3:
	return a.lerp(b, u).lerp(d.lerp(c, u), v)

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
				Meshes.box(wst, Vector3(x + 0.2, y0 + 0.25 + r * 0.7, d - ins - 0.03), Vector3(0.6, 0.4, 0.04), window_colour(_wr))
	Meshes.box(st, Vector3(w * 0.5 - 0.15, 11.5, d * 0.5 - 0.15), Vector3(0.3, 3.0, 0.3), frame.lightened(0.3))  # spire
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.06), Vector3(0.7, 1.2, 0.08), frame)

# --- point props -------------------------------------------------------------

## A little waterfall where a stream drops a level: a sloping sheet of white water from the upstream (+x) edge
## of its tile, the upper pool's lip, down to a ring of foam on the lower pool. Origin on the lower pool's
## surface (ZoneBuilder stands it there); ZoneBuilder.LEVEL high, so it meets the pool above.
static func cascade(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9500 + variant)
	var st := Meshes._st()
	var top := ZoneBuilder.LEVEL + 0.05
	var strips := 5
	for i in strips:
		var z0 := -0.46 + i * 0.92 / strips
		var z1 := z0 + 0.92 / strips
		var col := Color("eef6f8") if i % 2 == 0 else Color("b9dde6")
		var lip := 0.52 + rng.randf_range(-0.02, 0.02)
		# white water quickening over the lip of the pool above, then the fall itself
		Meshes._quad(st, Vector3(0.8, top - 0.01, z1), Vector3(0.8, top - 0.01, z0), Vector3(lip, top, z0), Vector3(lip, top, z1), col.lerp(Color("9fcbd8"), 0.4))
		Meshes._quad(st, Vector3(lip, top, z1), Vector3(lip, top, z0), Vector3(0.06, 0.02, z0), Vector3(0.06, 0.02, z1), col)
	for i in 8:
		var z := -0.42 + i * 0.12
		Meshes.blob(st, Vector3(rng.randf_range(-0.2, 0.12), 0.02, z), Vector3(0.17, 0.06, 0.12), Color("f2f8fa"), rng, 0.3)
	return Meshes._finish(st)

# --- the countryside ----------------------------------------------------------

## A Dales field barn (a laithe): rubble stone walls with through-stones sticking out, a stone-slate roof, a
## wide cart door and a row of little forking holes. Nobody goes in: it has no door tile.
static func _field_barn(st: SurfaceTool, w: int, d: int, rng: RandomNumberGenerator) -> void:
	var stone := Color("a39b8b")
	var roof := Color("5d5850")
	var h := 1.25
	for row in 5:
		var y := row * h / 5.0
		var c := stone.lightened(rng.randf_range(-0.08, 0.06))
		Meshes.box(st, Vector3(0.08, y, 0.12), Vector3(w - 0.16, h / 5.0, d - 0.24), c)
	for i in w:
		Meshes.box(st, Vector3(i + 0.35, h * 0.55, d - 0.16), Vector3(0.18, 0.08, 0.1), stone.darkened(0.15))  # through-stones
		Meshes.box(st, Vector3(i + 0.4, h * 0.8, d - 0.13), Vector3(0.12, 0.12, 0.02), Color("2a2622"))       # forking holes
	Meshes.box(st, Vector3(w * 0.5 - 0.4, 0, d - 0.13), Vector3(0.8, 0.85, 0.03), Color("4d3b2c"))  # cart door
	Meshes.box(st, Vector3(w * 0.5 - 0.48, 0.85, d - 0.14), Vector3(0.96, 0.1, 0.06), stone.lightened(0.12))  # lintel
	_roof(st, w, d, h, roof, stone, 0.32)

## Field sheep standing about (point props: no creature, just wool). 0 Herdwick (grey fleece, white face, the
## Lakes), 1 Swaledale (white fleece, black face, the Dales), 2 a Herdwick with its head down grazing.
static func sheep(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9700 + variant)
	var st := Meshes._st()
	var fleece := Color("e6e1d6") if variant == 1 else Color("8f8a84")
	var face := Color("24211f") if variant == 1 else Color("e9e6df")
	var leg := Color("2a2725")
	for p in [Vector2(-0.14, -0.09), Vector2(0.14, -0.09), Vector2(-0.14, 0.09), Vector2(0.14, 0.09)]:
		Meshes.box(st, Vector3(p.x - 0.03, 0, p.y - 0.03), Vector3(0.06, 0.18, 0.06), leg)
	Meshes.blob(st, Vector3(0, 0.27, 0), Vector3(0.24, 0.13, 0.16), fleece, rng, 0.12)
	var head_y := 0.14 if variant == 2 else 0.34
	Meshes.box(st, Vector3(0.22, head_y - 0.06, -0.06), Vector3(0.14, 0.12, 0.12), face)
	Meshes.box(st, Vector3(0.23, head_y + 0.03, -0.1), Vector3(0.04, 0.03, 0.2), face.darkened(0.1))  # ears
	if variant == 1:
		Meshes.box(st, Vector3(0.24, head_y + 0.02, -0.09), Vector3(0.06, 0.06, 0.03), Color("c9bfa8"))  # curled horn
		Meshes.box(st, Vector3(0.24, head_y + 0.02, 0.06), Vector3(0.06, 0.06, 0.03), Color("c9bfa8"))
	return Meshes._finish(st)

## A five-bar field gate standing open, folded back against the wall beside a gap: the hanging post at the
## gap side (+x), the gate in front of the wall's face (+z). Stand it on the wall tile next to the gap, turned
## (rot) so +x points into the gap. Variant 1 is weathered grey, 2 painted white.
static func field_gate(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var wood: Color = [Color("8a6a46"), Color("8c8a82"), Color("e8e4da")][variant % 3]
	Meshes.box(st, Vector3(0.36, 0, 0.18), Vector3(0.12, 0.86, 0.12), Color("6d5a44") if variant != 2 else wood.darkened(0.1))
	for i in 5:
		Meshes.box(st, Vector3(-0.48, 0.12 + i * 0.13, 0.27), Vector3(0.86, 0.05, 0.04), wood)
	Meshes.box(st, Vector3(-0.48, 0.1, 0.26), Vector3(0.06, 0.62, 0.06), wood.darkened(0.08))
	Meshes.box(st, Vector3(0.28, 0.1, 0.26), Vector3(0.06, 0.62, 0.06), wood.darkened(0.08))
	# the diagonal brace, in short steps
	for i in 6:
		var t := i / 5.0
		Meshes.box(st, Vector3(lerpf(0.24, -0.44, t), lerpf(0.14, 0.6, t), 0.25), Vector3(0.12, 0.05, 0.03), wood.darkened(0.05))
	return Meshes._finish(st)

## Limestone pavement: flat clints split by dark grikes, lying on its tile. Walk over it.
static func limestone_pavement(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9800 + variant)
	var st := Meshes._st()
	var stone := Color("bdb9ac")
	# two bands of clints, each band split at its own place, so the grikes don't line up like floor tiles
	for j in 2:
		var z0 := -0.5 + j * 0.5 + 0.03
		var cut := rng.randf_range(-0.25, 0.25)
		for part in [[-0.5, cut], [cut, 0.5]]:
			if rng.randf() < 0.1:
				continue  # turf has filled this one in
			var x0: float = part[0] + 0.03
			var x1: float = part[1] - 0.03
			var c := stone.lightened(rng.randf_range(-0.1, 0.06))
			Meshes.box(st, Vector3(x0, 0, z0), Vector3(x1 - x0, rng.randf_range(0.04, 0.08), 0.44 + rng.randf_range(-0.04, 0.0)), c)
	return Meshes._finish(st)

static func standing_stone(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9100 + variant)
	var st := Meshes._st()
	var g := Color("8e8a80")
	var h := 1.3 + variant * 0.3
	Meshes.box(st, Vector3(-0.22, 0, -0.14), Vector3(0.44, h, 0.28), g.lightened(rng.randf_range(-0.05, 0.05)))
	Meshes.box(st, Vector3(-0.17, h, -0.1), Vector3(0.3, 0.18, 0.2), g.darkened(0.06))
	Meshes.blob(st, Vector3(0.1, h * 0.5, 0.15), Vector3(0.1, 0.12, 0.04), Color("9fae6a"), rng)  # lichen
	return Meshes._finish(st)

## Variants 0 to 2 are slate (or slag); variant 3 is a stack of cut peat.
static func slate_heap(variant := 0) -> ArrayMesh:
	var rng := Meshes._rng(9200 + variant)
	var st := Meshes._st()
	var col := PEAT if variant == 3 else SLATE
	for i in 9:
		var y := i * 0.09
		var s := 0.9 - i * 0.08
		Meshes.box(st, Vector3(-s * 0.5 + rng.randf_range(-0.05, 0.05), y, -s * 0.45), Vector3(s, 0.08, s * 0.9), col.lightened(rng.randf_range(-0.08, 0.12)))
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

## Big Ben, near enough: a stone shaft, a clock face on every side, a belfry and a tall pointed roof.
static func clock_tower() -> ArrayMesh:
	var st := Meshes._st()
	var stone := Color("c9b98a")
	var gilt := Color("c9a441")
	Meshes.box(st, Vector3(-0.4, 0, -0.4), Vector3(0.8, 0.25, 0.8), stone.darkened(0.2))
	Meshes.box(st, Vector3(-0.33, 0.25, -0.33), Vector3(0.66, 2.75, 0.66), stone)
	for i in 4:
		Meshes.box(st, Vector3(-0.35, 0.6 + i * 0.6, -0.35), Vector3(0.7, 0.05, 0.7), stone.darkened(0.12))
	# the clock stage, a touch wider, with a face on each side
	Meshes.box(st, Vector3(-0.38, 3.0, -0.38), Vector3(0.76, 0.7, 0.76), stone.lightened(0.05))
	for f in [[Vector3(-0.22, 3.12, 0.385), Vector3(0.44, 0.44, 0.02)], [Vector3(-0.22, 3.12, -0.405), Vector3(0.44, 0.44, 0.02)],
			[Vector3(0.385, 3.12, -0.22), Vector3(0.02, 0.44, 0.44)], [Vector3(-0.405, 3.12, -0.22), Vector3(0.02, 0.44, 0.44)]]:
		Meshes.box(st, f[0], f[1], Color("f4ecd2"))
	Meshes.box(st, Vector3(-0.02, 3.33, 0.4), Vector3(0.04, 0.16, 0.02), Color("1d1d1d"))
	Meshes.box(st, Vector3(-0.02, 3.33, 0.4), Vector3(0.12, 0.03, 0.02), Color("1d1d1d"))
	# belfry and spire
	Meshes.box(st, Vector3(-0.3, 3.7, -0.3), Vector3(0.6, 0.35, 0.6), stone.darkened(0.08))
	for i in 5:
		var r := 0.3 - i * 0.06
		Meshes.box(st, Vector3(-r, 4.05 + i * 0.2, -r), Vector3(r * 2.0, 0.2, r * 2.0), SLATE.lightened(0.1 * (i % 2)))
	Meshes.box(st, Vector3(-0.025, 5.05, -0.025), Vector3(0.05, 0.3, 0.05), gilt)
	return Meshes._finish(st)

## The Shard: a tall, tapering spike of pale blue glass, its tip left ragged.
static func shard() -> ArrayMesh:
	var st := Meshes._st()
	var glass := Color("9fc1d6")
	var n := 12
	for i in n:
		var r := 0.48 * (1.0 - float(i) / n) + 0.04
		Meshes.box(st, Vector3(-r, i * 0.45, -r * 0.8), Vector3(r * 2.0, 0.45, r * 1.6), glass.darkened(0.04 * (i % 3)).lightened(0.02 * i))
	for k in 3:
		Meshes.box(st, Vector3(-0.06 + k * 0.05, n * 0.45, -0.03), Vector3(0.03, 0.25 + 0.15 * k, 0.03), glass.lightened(0.2))
	return Meshes._finish(st)

static func statue(variant := 0) -> ArrayMesh:
	if variant == IRON_MAN:
		return iron_man()
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

# --- the Lancashire coast --------------------------------------------------------

const TOWER_RED := Color("a9442f")
const TERRACOTTA := Color("d9b48a")
## statue variant: one of the cast-iron men on Crosby beach.
const IRON_MAN := 3

## Blackpool Tower: the red-brick and terracotta Tower Buildings, with the red lattice tower rising from the
## roof to a lookout and a flagstaff. Little bulbs on the legs and the lookout go in the window mesh, so the
## whole tower lights up at night like the Illuminations.
static func _blackpool_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var hb := 2.5
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hb, d - 0.1), BRICK, BRICK.darkened(0.3))
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.2, d), DARK_BRICK)
	for s in 2:
		Meshes.box(st, Vector3(0.0, 1.15 + s * 1.2, d - 0.06), Vector3(w, 0.1, 0.05), TERRACOTTA)
		for x in w:
			if x == door_x and s == 0:
				continue
			_window(st, wst, x + 0.25, 0.4 + 1.15 * s, d, 0.5, 0.6, TERRACOTTA)
	Meshes.box(st, Vector3(-0.05, hb - 0.1, -0.05), Vector3(w + 0.1, 0.18, d + 0.1), TERRACOTTA)
	# little corner turrets on the front of the buildings
	for tx in [0.0, w - 0.7]:
		Meshes.box(st, Vector3(tx, 0, d - 0.75), Vector3(0.7, hb + 0.5, 0.7), BRICK.lightened(0.05), TERRACOTTA)
		Meshes.box(st, Vector3(tx + 0.15, hb + 0.5, d - 0.6), Vector3(0.4, 0.35, 0.4), TERRACOTTA)
	# a grand arched entrance in terracotta
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.15, 0.2, d - 0.14), Vector3(1.3, 1.45, 0.08), TERRACOTTA)
	_door(st, door_x, d, BRICK, 1.1)
	# the tower: four legs leaning in from the roof, braced every storey
	var cx := w * 0.5
	var cz := maxf(d * 0.5, d - 2.3)  # towards the front, so the lattice shows over the prom
	var top := hb + 7.0
	var foot := minf(1.7, minf(w, d) * 0.42)
	var neck := 0.32
	var legs := [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	var bulb := Color(1, 0.92, 0.6, 1)
	for c in legs:
		_strut(st, Vector3(cx + c.x * foot, hb, cz + c.y * foot), Vector3(cx + c.x * neck, top, cz + c.y * neck), 0.18, TOWER_RED)
	var levels := 7
	for i in levels:
		var y0 := hb + 0.6 + i * 0.95
		var y1 := y0 + 0.95
		var r0 := lerpf(foot, neck, (y0 - hb) / (top - hb))
		var r1 := lerpf(foot, neck, (y1 - hb) / (top - hb))
		Meshes.box(st, Vector3(cx - r0, y0, cz - r0), Vector3(r0 * 2, 0.08, 0.08), TOWER_RED.lightened(0.08))
		Meshes.box(st, Vector3(cx - r0, y0, cz + r0 - 0.08), Vector3(r0 * 2, 0.08, 0.08), TOWER_RED.lightened(0.08))
		Meshes.box(st, Vector3(cx - r0, y0, cz - r0), Vector3(0.08, 0.08, r0 * 2), TOWER_RED)
		Meshes.box(st, Vector3(cx + r0 - 0.08, y0, cz - r0), Vector3(0.08, 0.08, r0 * 2), TOWER_RED)
		if y1 < top - 1.2:
			# the lattice: a cross on the south face (the one you see), a single brace on the others
			_strut(st, Vector3(cx - r0, y0, cz + r0), Vector3(cx + r1, y1, cz + r1), 0.06, TOWER_RED.darkened(0.1))
			_strut(st, Vector3(cx + r0, y0, cz + r0), Vector3(cx - r1, y1, cz + r1), 0.06, TOWER_RED.darkened(0.1))
			_strut(st, Vector3(cx - r0, y0, cz - r0), Vector3(cx - r1, y1, cz + r1), 0.06, TOWER_RED.darkened(0.15))
			_strut(st, Vector3(cx + r0, y0, cz - r0), Vector3(cx + r1, y1, cz + r1), 0.06, TOWER_RED.darkened(0.15))
		for c in legs:
			Meshes.box(wst, Vector3(cx + c.x * r0 - 0.05, y0 + 0.3, cz + c.y * r0 + 0.02), Vector3(0.1, 0.1, 0.1), bulb)
	# the old ballroom-level platform and the lookout near the top
	var py := hb + 0.6
	Meshes.box(st, Vector3(cx - foot - 0.15, py, cz - foot - 0.15), Vector3(foot * 2 + 0.3, 0.12, foot * 2 + 0.3), TOWER_RED.darkened(0.2))
	var ly := top - 1.4
	var lr := 0.75
	Meshes.box(st, Vector3(cx - lr, ly, cz - lr), Vector3(lr * 2, 0.7, lr * 2), Color("e9dcc0"), TOWER_RED)
	Meshes.box(st, Vector3(cx - lr - 0.08, ly - 0.08, cz - lr - 0.08), Vector3(lr * 2 + 0.16, 0.1, lr * 2 + 0.16), TOWER_RED.darkened(0.2))
	for i in 4:
		Meshes.box(wst, Vector3(cx - lr + 0.12 + i * 0.36, ly + 0.25, cz + lr + 0.005), Vector3(0.24, 0.3, 0.03), Color(1, 0.95, 0.75, 1))
	# the cap: a short spire and a flagstaff with a little flag
	Meshes.box(st, Vector3(cx - neck, top, cz - neck), Vector3(neck * 2, 0.5, neck * 2), TOWER_RED.lightened(0.05))
	for i in 3:
		var r := 0.26 - i * 0.08
		Meshes.box(st, Vector3(cx - r, top + 0.5 + i * 0.3, cz - r), Vector3(r * 2, 0.3, r * 2), TOWER_RED.lightened(0.1 * i))
	Meshes.box(st, Vector3(cx - 0.03, top + 1.4, cz - 0.03), Vector3(0.06, 1.0, 0.06), Color("dcdcdc"))
	Meshes.box(st, Vector3(cx + 0.03, top + 2.0, cz - 0.02), Vector3(0.45, 0.28, 0.04), Color("c8102e"))
	Meshes.box(wst, Vector3(cx - 0.07, top + 0.55, cz + neck), Vector3(0.14, 0.14, 0.05), bulb)

## The Big One at the Pleasure Beach: a long white-legged steel coaster, a lift hill climbing from the west end to
## the top, the famous drop, then a run of smaller camelback hills. Runs east-west along the footprint.
static func _big_one(st: SurfaceTool, wst: SurfaceTool, w: int, d: int) -> void:
	var track := Color("2f6fb3")
	var leg := Color("e8e6df")
	var cz := d * 0.5
	# a height profile over the footprint: [x, height]
	var prof := [[0.2, 0.6], [w * 0.28, 6.0], [w * 0.31, 6.2], [w * 0.42, 0.7], [w * 0.55, 3.6], [w * 0.66, 0.9],
		[w * 0.76, 2.4], [w * 0.86, 0.8], [w - 0.3, 0.6]]
	for i in prof.size() - 1:
		var a := Vector3(prof[i][0], prof[i][1], cz)
		var b := Vector3(prof[i + 1][0], prof[i + 1][1], cz)
		var steps := maxi(1, int(a.distance_to(b) / 0.45))
		for k in steps:
			var p0 := a.lerp(b, float(k) / steps)
			var p1 := a.lerp(b, float(k + 1) / steps)
			# two rails and a spine, as thin slabs between the samples
			for off in [-0.22, 0.22]:
				_strut(st, p0 + Vector3(0, 0, off), p1 + Vector3(0, 0, off), 0.07, track)
			_strut(st, p0 + Vector3(0, -0.12, 0), p1 + Vector3(0, -0.12, 0), 0.1, track.darkened(0.25))
			if k % 2 == 0 and p0.y > 0.5:
				_strut(st, Vector3(p0.x, 0, cz - 0.25), Vector3(p0.x, p0.y - 0.15, cz - 0.08), 0.08, leg)
				_strut(st, Vector3(p0.x, 0, cz + 0.25), Vector3(p0.x, p0.y - 0.15, cz + 0.08), 0.08, leg)
				if p0.y > 2.0:
					Meshes.box(st, Vector3(p0.x - 0.04, p0.y * 0.5, cz - 0.22), Vector3(0.08, 0.06, 0.44), leg.darkened(0.1))
			if k % 3 == 1:
				Meshes.box(wst, Vector3(p0.x - 0.04, p0.y + 0.02, cz + 0.27), Vector3(0.08, 0.08, 0.04), Color(1, 0.85, 0.5, 1))
	# a train of cars cresting the lift hill
	var crest := Vector3(prof[1][0], prof[1][1], cz)
	for i in 3:
		var p := crest + Vector3(-0.45 * (i + 1), -0.45 * (i + 1) * 6.0 / (w * 0.28), 0)
		Meshes.box(st, p + Vector3(-0.2, 0.05, -0.28), Vector3(0.4, 0.28, 0.56), Color("d8352a"), Color("f0c43a"))
	# the station shed at the east end
	Meshes.box(st, Vector3(w - 2.2, 0, 0.1), Vector3(2.0, 0.9, d - 0.2), Color("f2efe6"), Color("2f6fb3"))

## A Blackpool Balloon tram: a double-decker in cream and green, on a footprint one tile wide and three long
## (north-south), with its trolley pole up to the overhead wire.
static func _blackpool_tram(st: SurfaceTool, wst: SurfaceTool, w: int, d: int) -> void:
	var cream := Color("efe3c0")
	var green := Color("3f7a4a")
	var x0 := 0.12
	var bw := w - 0.24
	Meshes.box(st, Vector3(x0, 0.0, 0.1), Vector3(bw, 0.18, d - 0.2), Color("2a2a2a"))
	Meshes.box(st, Vector3(x0, 0.18, 0.15), Vector3(bw, 0.55, d - 0.3), green, cream)
	Meshes.box(st, Vector3(x0, 0.73, 0.15), Vector3(bw, 0.5, d - 0.3), cream)
	Meshes.box(st, Vector3(x0, 1.23, 0.15), Vector3(bw, 0.1, d - 0.3), green)
	Meshes.box(st, Vector3(x0, 1.33, 0.15), Vector3(bw, 0.5, d - 0.3), cream, cream.lightened(0.1))
	# rounded-off ends, near enough
	Meshes.box(st, Vector3(x0 + 0.08, 0.18, 0.05), Vector3(bw - 0.16, 1.6, 0.12), cream.darkened(0.05))
	Meshes.box(st, Vector3(x0 + 0.08, 0.18, d - 0.17), Vector3(bw - 0.16, 1.6, 0.12), cream.darkened(0.05))
	for deck in 2:
		var y := 0.82 + deck * 0.6
		for i in 4:
			Meshes.box(wst, Vector3(x0 - 0.01, y, 0.35 + i * (d - 0.7) / 4.0), Vector3(0.02, 0.3, (d - 0.7) / 4.0 - 0.08), Color(1, 0.95, 0.8, 1))
			Meshes.box(wst, Vector3(x0 + bw - 0.01, y, 0.35 + i * (d - 0.7) / 4.0), Vector3(0.02, 0.3, (d - 0.7) / 4.0 - 0.08), Color(1, 0.95, 0.8, 1))
		Meshes.box(wst, Vector3(x0 + 0.15, y, d - 0.06), Vector3(bw - 0.3, 0.3, 0.02), Color(1, 0.95, 0.8, 1))
	# headlamp and the destination blind
	Meshes.box(wst, Vector3(w * 0.5 - 0.08, 0.4, d - 0.05), Vector3(0.16, 0.12, 0.03), Color(1, 1, 0.85, 1))
	Meshes.box(st, Vector3(x0 + 0.15, 1.6, d - 0.07), Vector3(bw - 0.3, 0.14, 0.03), Color("1d1d1d"))
	_strut(st, Vector3(w * 0.5, 1.83, d * 0.5), Vector3(w * 0.5, 2.5, d * 0.5 - 0.9), 0.05, Color("2a2a2a"))

## A seaside pier pavilion at the end of the boards: white walls, a green dome on top, little pennants.
static func _pier_pavilion(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var white := Color("f3f0e6")
	var green := Color("4f8f7a")
	var hgt := 1.4
	# stilts under the deck, so it reads as standing over the sea
	for x in range(0, w + 1):
		for z in [0.2, d - 0.3]:
			Meshes.box(st, Vector3(minf(x, w - 0.15), -0.8, z), Vector3(0.12, 0.85, 0.12), Color("5a4a3a"))
	Meshes.box(st, Vector3(-0.1, 0, -0.1), Vector3(w + 0.2, 0.12, d + 0.2), Color("8a6a4a"))
	Meshes.box(st, Vector3(0.1, 0.12, 0.1), Vector3(w - 0.2, hgt, d - 0.2), white, white)
	Meshes.box(st, Vector3(0.0, hgt + 0.12, 0.0), Vector3(w, 0.12, d), green)
	var rng := Meshes._rng(4242 + w * 7 + d)
	Meshes.cylinder(st, Vector3(w * 0.5, hgt + 0.24, d * 0.5), minf(w, d) * 0.32, 0.4, 8, white)
	Meshes.cone(st, Vector3(w * 0.5, hgt + 0.64, d * 0.5), minf(w, d) * 0.34, 0.9, 8, green, rng)
	Meshes.box(st, Vector3(w * 0.5 - 0.02, hgt + 1.5, d * 0.5 - 0.02), Vector3(0.04, 0.5, 0.04), Color("dcdcdc"))
	Meshes.box(st, Vector3(w * 0.5 + 0.02, hgt + 1.8, d * 0.5), Vector3(0.3, 0.18, 0.03), Color("c8102e"))
	for x in w:
		if x == door_x:
			continue
		_window(st, wst, x + 0.25, 0.45, d - 0.1, 0.5, 0.6, green)
	for x in range(0, w + 1):
		Meshes.box(wst, Vector3(minf(x, w - 0.1), hgt + 0.18, d + 0.01), Vector3(0.1, 0.1, 0.04), Color(1, 0.9, 0.55, 1))
	_door(st, door_x, d - 0.1, white, 1.0)

## One of the hundred cast-iron men of Another Place on Crosby beach: life size, rust brown, gazing out to sea
## (+z faces front: turn it with "rot" to face the water). Barnacles and weed darken the shins.
static func iron_man() -> ArrayMesh:
	var st := Meshes._st()
	var rng := Meshes._rng(9603)
	var iron := Color("6e4a36")
	var weed := Color("3f4a32")
	Meshes.box(st, Vector3(-0.13, 0, -0.06), Vector3(0.1, 0.32, 0.12), weed)
	Meshes.box(st, Vector3(0.03, 0, -0.06), Vector3(0.1, 0.32, 0.12), weed)
	Meshes.box(st, Vector3(-0.13, 0.32, -0.06), Vector3(0.1, 0.36, 0.12), iron.darkened(0.1))
	Meshes.box(st, Vector3(0.03, 0.32, -0.06), Vector3(0.1, 0.36, 0.12), iron.darkened(0.1))
	Meshes.box(st, Vector3(-0.15, 0.68, -0.08), Vector3(0.3, 0.5, 0.16), iron)
	Meshes.box(st, Vector3(-0.22, 0.7, -0.05), Vector3(0.07, 0.46, 0.1), iron.darkened(0.05))
	Meshes.box(st, Vector3(0.15, 0.7, -0.05), Vector3(0.07, 0.46, 0.1), iron.darkened(0.05))
	Meshes.box(st, Vector3(-0.04, 1.18, -0.04), Vector3(0.08, 0.06, 0.08), iron)
	Meshes.blob(st, Vector3(0, 1.32, 0), Vector3(0.09, 0.11, 0.1), iron.lightened(0.05), rng, 0.04)
	Meshes.box(st, Vector3(-0.02, 1.3, 0.08), Vector3(0.04, 0.04, 0.04), iron.darkened(0.15))
	return Meshes._finish(st)

## Southport's Lord Street: two storeys of pale Victorian stone with an iron-and-glass veranda over the pavement,
## held up on slim painted columns, the shop windows glowing underneath.
static func _veranda_shop(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var stone: Color = [Color("e6dcc6"), Color("d9cbb0"), Color("efe6d4")][rng.randi() % 3]
	var iron: Color = [Color("2f4f46"), Color("3a3f5c"), Color("5a2f36")][rng.randi() % 3]
	var hgt := 2.5
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), stone)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), stone.darkened(0.3))
	Meshes.box(st, Vector3(-0.05, hgt - 0.12, -0.05), Vector3(w + 0.1, 0.18, d + 0.1), stone.lightened(0.1))
	_roof(st, w, d, hgt, SLATE, stone, 0.3)
	for x in w:
		if x != door_x:
			_window(st, wst, x + 0.12, 0.3, d, 0.76, 0.85, iron)
		_window(st, wst, x + 0.3, 1.55, d, 0.4, 0.6, stone.darkened(0.1))
	_door(st, door_x, d, stone, 1.0)
	# the veranda: columns at the kerb, a glass roof sloping back to the wall, a fretwork valance
	for x in range(0, w + 1):
		Meshes.box(st, Vector3(minf(x, w - 0.08), 0, d + 0.78), Vector3(0.08, 1.25, 0.08), iron)
	Meshes.box(st, Vector3(-0.05, 1.25, d - 0.02), Vector3(w + 0.1, 0.06, 0.9), Color("b9cfd4"), Color("cfe2e6"))
	Meshes.box(st, Vector3(-0.05, 1.12, d + 0.8), Vector3(w + 0.1, 0.14, 0.05), iron)

## A Blackpool guest house: a tall red-brick terrace with white bay windows on two floors, a painted porch and a
## little board in the window. Seaside pastel trims vary house to house.
static func _guest_house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var trims := [Color("f2efe6"), Color("bfe0dc"), Color("f4d6dc"), Color("f3e3a6")]
	var hgt := 3.3
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), BRICK)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), DARK_BRICK)
	_roof(st, w, d, hgt, SLATE, BRICK, 0.35)
	for x in range(0, w, 2):
		var trim: Color = trims[rng.randi() % trims.size()]
		var bw := minf(1.3, w - x - 0.5)
		var bx := float(x) + 0.35
		if x <= door_x and door_x < x + 2:
			# the porch: a painted surround and a fanlight over the door, a window beside it
			Meshes.box(st, Vector3(door_x + 0.1, 0.16, d - 0.05), Vector3(0.8, 1.2, 0.14), trim)
			var wx := float(x) + (1.25 if door_x == x else 0.2)
			_window(st, wst, wx, 0.45, d, 0.5, 0.6, trim)
		else:
			# a two-storey bay, painted, with a window on each floor
			Meshes.box(st, Vector3(bx, 0.16, d - 0.05), Vector3(bw, 2.2, 0.26), BRICK.lightened(0.04), trim)
			Meshes.box(st, Vector3(bx - 0.04, 1.08, d - 0.05), Vector3(bw + 0.08, 0.1, 0.32), trim)
			Meshes.box(st, Vector3(bx - 0.04, 2.36, d - 0.05), Vector3(bw + 0.08, 0.1, 0.32), trim)
			_window(st, wst, bx + 0.12, 0.42, d + 0.28, bw - 0.24, 0.58, trim)
			_window(st, wst, bx + 0.12, 1.42, d + 0.28, bw - 0.24, 0.58, trim)
		_window(st, wst, bx + 0.25, 2.62, d, bw - 0.5, 0.45, trim)
		Meshes.box(st, Vector3(x + 0.95, hgt + 0.3, d * 0.5 - 0.2), Vector3(0.35, 0.8, 0.4), BRICK.darkened(0.2))
		_chimneys.append(Vector3(x + 1.12, hgt + 1.1, d * 0.5))
	_door(st, door_x, d + 0.1, BRICK, 0.9)

