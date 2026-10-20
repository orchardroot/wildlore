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
const SPECIAL := ["glass_tower", "gantry_crane", "cantilever_crane", "titanic", "mill", "castle", "cathedral", "liver_building", "station", "aqueduct", "chapel", "terrace", "tudor", "slate_cottage", "lighthouse_house", "round_tower", "passage_tomb", "field_barn",
	"gault", "flint", "flint_gable", "thatch", "college", "kings_chapel", "portico", "ely_cathedral", "norwich_cathedral",
	"norman_keep", "football_stand"]

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
	"portico": {"x": 0.15, "w": 0.7, "y": 0.22, "h": 1.4, "z": -0.7},
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
		"gault", "flint", "flint_gable", "thatch", "college", "kings_chapel", "portico", "ely_cathedral", "norwich_cathedral", "norman_keep", "football_stand":
			ea_building(st, wst, style, w, d, door_x, rng)
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
	"cumbria": "st_george", "cornwall": "st_piran", "north_wales": "wales", "mid_wales": "wales",
	"south_wales": "wales", "scotland": "saltire", "ireland": "ireland", "ireland_west": "ireland",
	"ireland_east": "ireland", "man": "man",
	"east_anglia": "st_george",
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

# --- East Anglia ---------------------------------------------------------------
# Cambridge's pale stone colleges and gault brick, the Fens' great cathedral, Norfolk flint, pantiles and reed
# thatch, Norwich's spire and keep, and the props of the waterways (punts, wherries, drainage mills).

const KETTON := Color("dacfae")      # Cambridge's pale oolitic limestone
const GAULT := Color("d4c79c")       # gault brick, "Cambridge white"
const FLINT := Color("43464c")
const PANTILE := Color("b0552f")
const REED := Color("a88f55")
const CAEN := Color("e2d9c2")        # Norwich Cathedral's Normandy stone
const LEAD := Color("8f979d")
const TARRED := Color("27282b")
const EA_PROPS := ["windpump", "punt", "maths_bridge", "wherry"]

static func ea_building(st: SurfaceTool, wst: SurfaceTool, style: String, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	match style:
		"gault":
			_house(st, wst, w, d, door_x, rng, GAULT, SLATE, 2, true, false)
		"flint":
			_flint(st, wst, w, d, door_x, rng, false)
		"flint_gable":
			_flint(st, wst, w, d, door_x, rng, true)
		"thatch":
			_thatch(st, wst, w, d, door_x, rng)
		"college":
			_college(st, wst, w, d, door_x)
		"kings_chapel":
			_kings_chapel(st, wst, w, d, door_x)
		"portico":
			_portico(st, wst, w, d, door_x)
		"ely_cathedral":
			_ely(st, wst, w, d, door_x)
		"norwich_cathedral":
			_norwich_cathedral(st, wst, w, d, door_x)
		"norman_keep":
			_norman_keep(st, wst, w, d, door_x)
		"football_stand":
			_football_stand(st, wst, w, d, door_x)

## A window on a face that sits at `face` (z), standing just proud of it.
static func _ewin(st: SurfaceTool, wst: SurfaceTool, x: float, y: float, face: float, ww: float, wh: float, frame: Color) -> void:
	_window(st, wst, x, y, face + 0.08, ww, wh, frame)

## A flat panel seen from both sides (sails, punt poles' blades, banners).
static func _panel(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, e: Vector3, col: Color) -> void:
	Meshes._quad(st, a, b, c, e, col)
	Meshes._quad(st, e, c, b, a, col.darkened(0.15))

## Flint walling: the body in dark flint, the street face peppered with knapped nodules of grey, black and
## blue-white, brick at the corners. Deterministic per building.
static func _flint_face(st: SurfaceTool, rng: RandomNumberGenerator, x0: float, x1: float, y0: float, y1: float, z: float) -> void:
	var y := y0
	while y < y1 - 0.05:
		var x := x0 + rng.randf_range(0.0, 0.12)
		while x < x1 - 0.1:
			var s := rng.randf_range(0.12, 0.2)
			var k := rng.randf()
			var col := FLINT.lightened(0.35) if k < 0.2 else (FLINT.darkened(0.35) if k < 0.55 else Color("5a6068"))
			Meshes._quad(st, Vector3(x, y + s * 0.8, z + 0.012), Vector3(x + s, y + s * 0.8, z + 0.012), Vector3(x + s, y, z + 0.012), Vector3(x, y, z + 0.012), col)
			x += s + rng.randf_range(0.06, 0.14)
		y += rng.randf_range(0.2, 0.27)

## Pantile ridges: the S-shaped clay tiles read from a distance as stripes running down the roof.
static func _pantiles(st: SurfaceTool, w: float, d: float, hgt: float, rise: float) -> void:
	var eave := 0.18
	var x := -eave + 0.06
	while x < w + eave - 0.1:
		var top := Vector3(x, hgt + rise + 0.02, d * 0.5)
		var bot := Vector3(x, hgt + 0.02, d + eave)
		Meshes._quad(st, top, top + Vector3(0.07, 0, 0), bot + Vector3(0.07, 0, 0), bot, PANTILE.darkened(0.25))
		x += 0.24

static func _flint(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator, gable: bool) -> void:
	var storeys := 2 if d >= 3 and w >= 4 else 1
	var hgt := 1.15 * storeys + 0.2
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), FLINT)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), DARK_BRICK)
	_flint_face(st, rng, 0.2, w - 0.2, 0.18, hgt - 0.05, d - 0.05)
	for qx in [0.0, w - 0.22]:  # brick quoins, in alternating long and short blocks
		var y := 0.16
		var i := 0
		while y < hgt - 0.05:
			var lw := 0.22 if i % 2 == 0 else 0.15
			Meshes.box(st, Vector3(qx if qx == 0.0 else w - lw, y, d - 0.12), Vector3(lw, 0.13, 0.14), BRICK)
			y += 0.15
			i += 1
	var rise := minf(1.2, d * 0.42)
	_roof(st, w, d, hgt, PANTILE, FLINT, 0.42)
	_pantiles(st, w, d, hgt, rise)
	if gable:
		# Dutch gables in brick at both ends, curved shoulders stepping up past the roof line
		for gx in [-0.05, w - 0.25]:
			var steps := [[0.05, d - 0.05, hgt, hgt + rise * 0.55], [d * 0.18, d * 0.82, hgt + rise * 0.55, hgt + rise * 0.95],
					[d * 0.3, d * 0.7, hgt + rise * 0.95, hgt + rise * 1.3], [d * 0.4, d * 0.6, hgt + rise * 1.3, hgt + rise * 1.45]]
			for s in steps:
				Meshes.box(st, Vector3(gx, s[2], s[0]), Vector3(0.3, s[3] - s[2], s[1] - s[0]), BRICK)
			Meshes.box(st, Vector3(gx - 0.03, hgt + rise * 1.45, d * 0.37), Vector3(0.36, 0.06, d * 0.26), LIMESTONE)
	else:
		Meshes.box(st, Vector3(0.15, hgt + 0.2, d * 0.5 - 0.2), Vector3(0.4, 1.0, 0.4), BRICK)
		_chimneys.append(Vector3(0.35, hgt + 1.2, d * 0.5))
	Meshes.box(st, Vector3(w - 0.6, hgt + 0.25, d * 0.5 - 0.2), Vector3(0.4, 0.95, 0.4), BRICK)
	_chimneys.append(Vector3(w - 0.4, hgt + 1.2, d * 0.5))
	_door(st, door_x, d, BRICK)
	for s in storeys:
		var wy := 0.4 + 1.15 * s
		for x in w:
			if x == door_x and s == 0:
				continue
			Meshes.box(st, Vector3(x + 0.2, wy - 0.12, d - 0.06), Vector3(0.6, 0.72, 0.05), BRICK)
			_ewin(st, wst, x + 0.27, wy, d + 0.02, 0.46, 0.52, Color("efe8d8"))

## Reed thatch: colour-washed walls under a deep, steep, round-shouldered roof with a cut sedge ridge.
static func _thatch(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall := Color("ebe2c8")
	var hgt := 1.3
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), wall)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.18, d), FLINT)
	var rise := minf(1.2, d * 0.6)
	_roof(st, w, d, hgt, REED, wall, 0.6)
	# thick eaves and a block-cut ridge in darker sedge
	Meshes.box(st, Vector3(-0.22, hgt - 0.12, d - 0.05), Vector3(w + 0.44, 0.22, 0.32), REED.darkened(0.08))
	Meshes.box(st, Vector3(-0.22, hgt - 0.12, -0.27), Vector3(w + 0.44, 0.22, 0.32), REED.darkened(0.12))
	Meshes.box(st, Vector3(-0.2, hgt + rise - 0.12, d * 0.5 - 0.22), Vector3(w + 0.4, 0.24, 0.44), REED.darkened(0.3))
	var x := 0.3
	while x < w - 0.2:  # the ridge's scalloped edge
		Meshes.box(st, Vector3(x, hgt + rise - 0.26, d * 0.5 + 0.18), Vector3(0.3, 0.14, 0.12), REED.darkened(0.3))
		x += 0.55
	var cx := rng.randf_range(0.8, maxf(0.9, w - 1.0))
	Meshes.box(st, Vector3(cx, hgt + rise - 0.4, d * 0.5 - 0.2), Vector3(0.38, 0.9, 0.4), BRICK)
	_chimneys.append(Vector3(cx + 0.19, hgt + rise + 0.5, d * 0.5))
	_door(st, door_x, d, wall)
	for x2 in w:
		if x2 != door_x:
			_ewin(st, wst, x2 + 0.3, 0.45, d, 0.42, 0.5, Color("f4efe2"))

## A Cambridge college range: pale stone, a battlemented parapet and a gatehouse with two turrets on the door.
static func _college(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var h := 2.5
	Meshes.box(st, Vector3(0.05, 0, 0.1), Vector3(w - 0.1, h, d - 0.2), KETTON)
	Meshes.box(st, Vector3(0, 0, 0.05), Vector3(w, 0.2, d - 0.1), KETTON.darkened(0.25))
	Meshes.box(st, Vector3(0, h - 0.15, d - 0.15), Vector3(w, 0.1, 0.08), KETTON.lightened(0.1))
	_roof_at(st, 0.05, w - 0.05, 0.4, d - 0.4, h, 0.5, SLATE, KETTON)
	_merlons(st, 0, w, d - 0.45, h, KETTON, true)
	for s in 2:
		for x in w:
			if absi(x - door_x) <= 1 and door_x >= 0:
				continue
			_ewin(st, wst, x + 0.3, 0.45 + 1.05 * s, d - 0.1, 0.4, 0.62, KETTON.lightened(0.2))
	if door_x >= 0:
		var gx := door_x - 0.45
		var gh := 3.4
		Meshes.box(st, Vector3(gx, 0, d - 1.2), Vector3(1.9, gh, 1.25), KETTON.lightened(0.04))
		_merlons(st, gx, gx + 1.9, d - 0.6, gh, KETTON, true)
		for tx in [gx, gx + 1.9]:
			Meshes.cylinder(st, Vector3(tx, 0, d - 0.2), 0.3, gh + 0.9, 8, KETTON.lightened(0.08))
			Meshes.cylinder(st, Vector3(tx, gh + 0.9, d - 0.2), 0.3, 0.18, 8, KETTON.darkened(0.08))
		Meshes.box(st, Vector3(door_x + 0.15, 0.1, d + 0.04), Vector3(0.7, 1.15, 0.06), Color("2e2420"))
		Meshes.box(st, Vector3(door_x + 0.08, 1.25, d + 0.04), Vector3(0.84, 0.1, 0.08), KETTON.lightened(0.2))
		_ewin(st, wst, door_x + 0.25, 1.75, d + 0.05, 0.5, 0.75, KETTON.lightened(0.2))
		# a coat of arms over the gate
		Meshes.box(st, Vector3(door_x + 0.35, 2.7, d + 0.06), Vector3(0.3, 0.36, 0.04), Color("b8322a"))
		Meshes.box(st, Vector3(door_x + 0.42, 2.82, d + 0.08), Vector3(0.16, 0.12, 0.03), Color("e0b03a"))

## King's College Chapel: one tall, long stone box, a forest of pinnacled buttresses with huge windows between,
## and four slender corner turrets with ogee caps.
static func _kings_chapel(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := KETTON.lightened(0.04)
	var h := 4.6
	var z0 := 0.35
	var z1 := d - 0.35
	Meshes.box(st, Vector3(0.3, 0, z0), Vector3(w - 0.6, h, z1 - z0), stone)
	_roof_at(st, 0.3, w - 0.3, z0, z1, h, 0.45, LEAD, stone)
	_merlons(st, 0.3, w - 0.3, z1 - 0.3, h, stone, true)
	_merlons(st, 0.3, w - 0.3, z0, h, stone, true)
	var bays := w - 1
	for i in range(bays + 1):
		var bx := 0.3 + (w - 0.6) * float(i) / bays
		Meshes.box(st, Vector3(bx - 0.13, 0, z1 - 0.05), Vector3(0.26, h + 0.25, 0.32), stone.darkened(0.05))
		Meshes.box(st, Vector3(bx - 0.06, h + 0.25, z1 + 0.04), Vector3(0.12, 0.55, 0.12), stone.lightened(0.05))
		if i < bays:
			var wx := bx + 0.2
			var ww := (w - 0.6) / bays - 0.4
			_ewin(st, wst, wx, 0.9, z1 + 0.02, ww, 3.2, stone.lightened(0.15))
			for m in range(1, 3):  # mullions and a transom
				Meshes.box(st, Vector3(wx + ww * m / 3.0 - 0.02, 0.9, z1 + 0.03), Vector3(0.04, 3.2, 0.03), stone.lightened(0.15))
			Meshes.box(st, Vector3(wx, 2.4, z1 + 0.03), Vector3(ww, 0.05, 0.03), stone.lightened(0.15))
	for c in [Vector2(0.3, z0), Vector2(w - 0.3, z0), Vector2(0.3, z1), Vector2(w - 0.3, z1)]:
		Meshes.cylinder(st, Vector3(c.x, 0, c.y), 0.38, h + 1.5, 8, stone.lightened(0.06))
		Meshes.cylinder(st, Vector3(c.x, h + 1.5, c.y), 0.34, 0.15, 8, stone.darkened(0.1))
		Meshes.cone(st, Vector3(c.x, h + 1.65, c.y), 0.3, 0.75, 8, stone.lightened(0.1), Meshes._rng(int(c.x * 7 + c.y)))
		Meshes.box(st, Vector3(c.x - 0.05, h + 2.4, c.y - 0.05), Vector3(0.1, 0.18, 0.1), Color("c9a441"))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0, z1 + 0.25), Vector3(0.7, 1.25, 0.12), Color("2e2420"))
		Meshes.box(st, Vector3(door_x + 0.05, 1.25, z1 + 0.25), Vector3(0.9, 0.12, 0.14), stone.lightened(0.15))

## A Greek-temple museum front (the Fitzwilliam): a stone block behind a row of columns and a pediment.
static func _portico(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("ddd3bb")
	var h := 2.6
	var front := d - 0.7
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, front - 0.05), stone)
	Meshes.box(st, Vector3(0.05, h, 0.05), Vector3(w - 0.1, 0.3, front - 0.05), stone.lightened(0.06))
	Meshes.box(st, Vector3(0, 0, front - 0.1), Vector3(w, 0.22, 0.85), stone.darkened(0.15))
	var cols := maxi(4, w - 2)
	var c0 := 0.9
	var c1 := w - 0.9
	for i in cols:
		var cx := c0 + (c1 - c0) * float(i) / (cols - 1)
		Meshes.cylinder(st, Vector3(cx, 0.22, d - 0.3), 0.14, h - 0.22, 8, stone.lightened(0.08))
	Meshes.box(st, Vector3(0.5, h, front - 0.1), Vector3(w - 1.0, 0.3, 0.8), stone.lightened(0.04))
	var py := h + 0.3
	var pz := d - 0.25
	Meshes._tri(st, Vector3(0.5, py, pz), Vector3(w * 0.5, py + 0.9, pz), Vector3(w - 0.5, py, pz), stone.lightened(0.1))
	Meshes._quad(st, Vector3(w * 0.5, py + 0.9, pz), Vector3(w * 0.5, py + 0.9, 0.2), Vector3(w - 0.5, py, 0.2), Vector3(w - 0.5, py, pz), LEAD)
	Meshes._quad(st, Vector3(0.5, py, pz), Vector3(0.5, py, 0.2), Vector3(w * 0.5, py + 0.9, 0.2), Vector3(w * 0.5, py + 0.9, pz), LEAD.darkened(0.12))
	for x in w:
		if x != door_x:
			_ewin(st, wst, x + 0.3, 0.7, front, 0.4, 1.2, stone.lightened(0.2))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0.22, front - 0.04), Vector3(0.7, 1.4, 0.06), Color("2e2420"))

## Ely, the ship of the Fens: a long Romanesque nave, a tall west tower crowned by its own octagon, and over the
## crossing the great stone Octagon with its timber-and-lead lantern.
static func _ely(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("cfc3a2")
	var nave_h := 3.1
	var tw := 2.6
	Meshes.box(st, Vector3(tw, 0, 0.6), Vector3(w - tw, nave_h, d - 1.2), stone)
	_roof_at(st, tw, w, 0.6, d - 0.6, nave_h, 1.1, LEAD, stone)
	# west tower with corner turrets and its octagonal top stage
	var th := 6.4
	Meshes.box(st, Vector3(0, 0, 0.3), Vector3(tw, th, d - 0.6), stone.darkened(0.03))
	for y in [1.6, 3.2, 4.8]:
		Meshes.box(st, Vector3(-0.03, y, 0.27), Vector3(tw + 0.06, 0.08, d - 0.54), stone.lightened(0.08))
	for c in [Vector2(0.2, 0.5), Vector2(tw - 0.2, 0.5), Vector2(0.2, d - 0.5), Vector2(tw - 0.2, d - 0.5)]:
		Meshes.cylinder(st, Vector3(c.x, 0, c.y), 0.32, th + 0.7, 8, stone.lightened(0.05))
		Meshes.cone(st, Vector3(c.x, th + 0.7, c.y), 0.3, 0.5, 8, stone, Meshes._rng(int(c.y * 13)))
	Meshes.cylinder(st, Vector3(tw * 0.5, th, d * 0.5), 0.95, 1.4, 8, stone.lightened(0.04))
	_merlons(st, tw * 0.5 - 0.6, tw * 0.5 + 0.6, d * 0.5 + 0.55, th + 1.25, stone, true)
	for y in [2.2, 3.8, 5.3]:
		_ewin(st, wst, tw * 0.5 - 0.25, y, d - 0.3, 0.5, 0.8, stone.lightened(0.2))
	# the Octagon at the crossing, and its lantern
	var ox := tw + (w - tw) * 0.55
	var oc := Vector3(ox, 0, d * 0.5)
	Meshes.box(st, Vector3(ox - 1.0, 0, 0.0), Vector3(2.0, nave_h + 0.2, d), stone.darkened(0.02))  # transepts
	_roof_at(st, ox - 1.0, ox + 1.0, 0.0, d, nave_h + 0.2, 1.0, LEAD, stone)
	Meshes.cylinder(st, oc, 1.55, nave_h + 2.0, 8, stone.lightened(0.03))
	Meshes.cylinder(st, oc + Vector3(0, nave_h + 2.0, 0), 1.35, 0.3, 8, LEAD)
	Meshes.cylinder(st, oc + Vector3(0, nave_h + 2.3, 0), 0.8, 1.3, 8, LEAD.lightened(0.15))
	for i in 8:
		var a := TAU * i / 8.0
		_ewin(st, wst, ox + cos(a) * 0.75 - 0.12, nave_h + 2.6, d * 0.5 + sin(a) * 0.75, 0.24, 0.5, LEAD.lightened(0.3))
		Meshes.box(st, Vector3(ox + cos(a) * 1.3 - 0.06, nave_h + 2.0, d * 0.5 + sin(a) * 1.3 - 0.06), Vector3(0.12, 0.6, 0.12), stone.lightened(0.1))
	Meshes.cone(st, oc + Vector3(0, nave_h + 3.6, 0), 0.72, 0.7, 8, LEAD, Meshes._rng(77))
	# the nave's two tiers of round-headed windows
	for x in range(ceili(tw) + 1, w):
		if absf(x + 0.5 - ox) < 1.3:
			continue
		_ewin(st, wst, x + 0.32, 0.55, d - 0.6, 0.36, 0.9, stone.lightened(0.2))
		_ewin(st, wst, x + 0.35, 2.0, d - 0.6, 0.3, 0.6, stone.lightened(0.2))
		Meshes.box(st, Vector3(x - 0.06, 0, d - 0.65), Vector3(0.14, nave_h, 0.18), stone.darkened(0.06))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.1, 0, d - 0.7), Vector3(1.2, 1.7, 0.7), stone.lightened(0.05))
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.02), Vector3(0.7, 1.3, 0.06), Color("2e2420"))

## Norwich Cathedral: a long, pale Norman nave, and a slim spire over the crossing that tops everything in town.
static func _norwich_cathedral(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := CAEN
	var nave_h := 3.2
	Meshes.box(st, Vector3(0.1, 0, 0.6), Vector3(w - 0.2, nave_h, d - 1.2), stone)
	_roof_at(st, 0.1, w - 0.1, 0.6, d - 0.6, nave_h, 1.0, LEAD, stone)
	# west front with a big window and flanking turrets
	Meshes.box(st, Vector3(0, 0, 0.4), Vector3(0.5, nave_h + 0.9, d - 0.8), stone.lightened(0.04))
	for zc in [0.6, d - 0.6]:
		Meshes.cylinder(st, Vector3(0.25, 0, zc), 0.25, nave_h + 1.6, 8, stone.lightened(0.06))
		Meshes.cone(st, Vector3(0.25, nave_h + 1.6, zc), 0.24, 0.6, 8, stone, Meshes._rng(int(zc * 31)))
	# transepts and the crossing tower
	var cx := w * 0.58
	Meshes.box(st, Vector3(cx - 1.0, 0, 0.0), Vector3(2.0, nave_h, d), stone.darkened(0.02))
	_roof_at(st, cx - 1.0, cx + 1.0, 0.0, d, nave_h, 0.9, LEAD, stone)
	var t := 1.8
	var th := 6.0
	Meshes.box(st, Vector3(cx - t * 0.5, 0, d * 0.5 - t * 0.5), Vector3(t, th, t), stone.lightened(0.02))
	for y in [4.1, 4.7, 5.3]:  # Norman blind arcading and roundels round the tower
		for i in 4:
			Meshes.box(st, Vector3(cx - t * 0.5 + 0.15 + i * 0.4, y, d * 0.5 + t * 0.5 + 0.01), Vector3(0.2, 0.42, 0.03), stone.darkened(0.18))
	for c in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var p := Vector3(cx + c.x * (t * 0.5 - 0.12), th, d * 0.5 + c.y * (t * 0.5 - 0.12))
		Meshes.cylinder(st, p, 0.14, 0.9, 6, stone.lightened(0.05))
		Meshes.cone(st, p + Vector3(0, 0.9, 0), 0.13, 0.5, 6, stone, Meshes._rng(int(c.x * 3 + c.y * 5 + 9)))
	# the spire: a tall, slim octagonal needle with little lucarnes partway up
	var sp := Vector3(cx, th, d * 0.5)
	Meshes.cone(st, sp, 0.82, 7.2, 8, Color("d3c9b0"), Meshes._rng(1096))
	for i in 4:
		var a := TAU * i / 4.0 + PI * 0.25
		Meshes.box(st, Vector3(cx + cos(a) * 0.55 - 0.08, th + 1.4, d * 0.5 + sin(a) * 0.55 - 0.08), Vector3(0.16, 0.35, 0.16), stone.lightened(0.05))
	Meshes.box(st, Vector3(cx - 0.03, th + 7.1, d * 0.5 - 0.03), Vector3(0.06, 0.45, 0.06), Color("c9a441"))
	for x in range(1, w - 1):
		if absf(x + 0.5 - cx) < 1.2:
			continue
		_ewin(st, wst, x + 0.33, 0.6, d - 0.6, 0.34, 0.85, stone.lightened(0.2))
		_ewin(st, wst, x + 0.36, 2.0, d - 0.6, 0.28, 0.65, stone.lightened(0.2))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.1, 0, d - 0.7), Vector3(1.2, 1.6, 0.7), stone.lightened(0.05))
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.02), Vector3(0.7, 1.25, 0.06), Color("2e2420"))

## Norwich Castle: a great square Norman keep refaced in pale stone, its walls covered in blind arcades.
static func _norman_keep(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("d9cba6")
	var h := 4.2
	Meshes.box(st, Vector3(0.2, 0, 0.2), Vector3(w - 0.4, h, d - 0.4), stone)
	Meshes.box(st, Vector3(0.1, 0, 0.1), Vector3(w - 0.2, 0.3, d - 0.2), stone.darkened(0.2))
	for c in [Vector2(0.1, 0.1), Vector2(w - 0.6, 0.1), Vector2(0.1, d - 0.6), Vector2(w - 0.6, d - 0.6)]:
		Meshes.box(st, Vector3(c.x, 0, c.y), Vector3(0.5, h + 0.45, 0.5), stone.lightened(0.05))
	_merlons(st, 0.2, w - 0.2, d - 0.5, h, stone, true)
	_merlons(st, 0.2, w - 0.2, 0.2, h, stone, true)
	_merlons(st, 0.2, d - 0.2, 0.2, h, stone, false)
	_merlons(st, 0.2, d - 0.2, w - 0.5, h, stone, false)
	for row in [[1.3, 0.9], [2.45, 0.7], [3.35, 0.55]]:  # three tiers of blind arches on the south face
		var x := 0.75
		while x < w - 0.85:
			Meshes.box(st, Vector3(x, row[0], d - 0.19), Vector3(0.24, row[1], 0.02), stone.darkened(0.2))
			Meshes.box(st, Vector3(x - 0.05, row[0] + row[1], d - 0.18), Vector3(0.34, 0.06, 0.03), stone.lightened(0.1))
			x += 0.45
	for x in [1.0, w - 1.3]:
		_ewin(st, wst, x, 2.45, d - 0.15, 0.3, 0.5, stone.lightened(0.2))
	if door_x >= 0:
		# the Bigod Tower forebuilding over the entrance
		Meshes.box(st, Vector3(door_x - 0.35, 0, d - 0.55), Vector3(1.7, 2.4, 0.55), stone.lightened(0.04))
		_merlons(st, door_x - 0.35, door_x + 1.35, d - 0.55, 2.4, stone, true)
		Meshes.box(st, Vector3(door_x + 0.18, 0, d + 0.01), Vector3(0.64, 1.2, 0.05), Color("2e2420"))
		Meshes.box(st, Vector3(door_x + 0.1, 1.2, d + 0.01), Vector3(0.8, 0.1, 0.06), stone.lightened(0.15))

## Carrow Road: the back of a stand in yellow and green, a cantilevered roof and four floodlight pylons.
static func _football_stand(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var yellow := Color("f2d21c")
	var green := Color("0f6b3c")
	var h := 2.6
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), green)
	for i in 3:
		Meshes.box(st, Vector3(0.02, 0.5 + i * 0.7, d - 0.08), Vector3(w - 0.04, 0.3, 0.05), yellow)
	Meshes.box(st, Vector3(-0.2, h, -0.1), Vector3(w + 0.4, 0.15, d + 0.25), Color("e8e8e4"))
	for c in [Vector2(0.15, 0.15), Vector2(w - 0.3, 0.15), Vector2(0.15, d - 0.3), Vector2(w - 0.3, d - 0.3)]:
		Meshes.box(st, Vector3(c.x, 0, c.y), Vector3(0.14, h + 2.4, 0.14), Color("b8bcc0"))
		Meshes.box(st, Vector3(c.x - 0.25, h + 2.2, c.y - 0.05), Vector3(0.64, 0.42, 0.22), Color("3c4450"))
		Meshes.box(wst, Vector3(c.x - 0.2, h + 2.25, c.y + 0.17), Vector3(0.54, 0.32, 0.02), Color(1, 1, 1, 1))
	# a canary on the crest over the turnstiles
	var bx := w * 0.5
	Meshes.box(st, Vector3(bx - 0.5, h - 0.05, d + 0.0), Vector3(1.0, 0.7, 0.08), green.darkened(0.2))
	Meshes.box(st, Vector3(bx - 0.18, h + 0.1, d + 0.06), Vector3(0.32, 0.22, 0.04), yellow)
	Meshes.box(st, Vector3(bx + 0.1, h + 0.28, d + 0.06), Vector3(0.14, 0.12, 0.04), yellow)
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.15, 0, d - 0.02), Vector3(0.7, 1.1, 0.06), Color("1e2a24"))
		Meshes.box(st, Vector3(door_x + 0.05, 1.1, d - 0.02), Vector3(0.9, 0.12, 0.07), yellow)

# --- East Anglia props -----------------------------------------------------------

static func ea_prop(name: String, variant: int) -> ArrayMesh:
	match name:
		"windpump":
			return windpump(variant)
		"punt":
			return punt(variant)
		"maths_bridge":
			return maths_bridge(variant)
		"wherry":
			return wherry(variant)
	return Meshes.rock(0)

## A Norfolk drainage mill: a tapering tarred brick tower, a white boat-shaped cap, a fantail and four white
## sails facing south.
static func windpump(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var tower_h := 3.2
	var sides := 8
	var lo := Meshes._ring(Vector3.ZERO, 0.5, 0.0, sides, PI / 8)
	var hi := Meshes._ring(Vector3.ZERO, 0.32, tower_h, sides, PI / 8)
	for i in sides:
		var j := (i + 1) % sides
		Meshes._quad(st, lo[i], lo[j], hi[j], hi[i], TARRED.lightened(0.06 * (i % 2)))
	Meshes.box(st, Vector3(-0.14, 0, 0.42), Vector3(0.28, 0.6, 0.06), Color("f2efe6"))
	for y in [1.2, 2.2]:
		Meshes.box(st, Vector3(-0.08, y, 0.4 - y * 0.05), Vector3(0.16, 0.22, 0.04), Color("f2efe6"))
	Meshes.cylinder(st, Vector3(0, tower_h, 0), 0.42, 0.08, sides, Color("f2efe6"))  # the gallery
	Meshes.box(st, Vector3(-0.3, tower_h + 0.05, -0.38), Vector3(0.6, 0.32, 0.76), Color("f2efe6"))
	Meshes._quad(st, Vector3(-0.3, tower_h + 0.37, 0.38), Vector3(0.3, tower_h + 0.37, 0.38), Vector3(0.3, tower_h + 0.37, -0.38), Vector3(-0.3, tower_h + 0.37, -0.38), Color("f2efe6"))
	Meshes.box(st, Vector3(-0.22, tower_h + 0.37, -0.32), Vector3(0.44, 0.16, 0.64), Color("e6e2d6"))
	# fantail at the back keeps the sails into the wind
	Meshes.box(st, Vector3(-0.02, tower_h + 0.2, -0.95), Vector3(0.04, 0.04, 0.6), Color("e6e2d6"))
	for k in 4:
		var a := TAU * k / 4.0
		_panel(st, Vector3(0, tower_h + 0.22, -0.95), Vector3(cos(a) * 0.32, tower_h + 0.22 + sin(a) * 0.32, -0.95),
				Vector3(cos(a + 0.5) * 0.32, tower_h + 0.22 + sin(a + 0.5) * 0.32, -0.95), Vector3(0, tower_h + 0.22, -0.95), Color("f2efe6"))
	# the sails, an X from a hub on the front of the cap
	var hub := Vector3(0, tower_h + 0.2, 0.48)
	Meshes.box(st, hub + Vector3(-0.07, -0.07, -0.1), Vector3(0.14, 0.14, 0.14), TARRED)
	var turn := 0.25 * PI + variant * 0.3
	for k in 4:
		var a := turn + k * PI * 0.5
		var dir := Vector3(cos(a), sin(a), 0)
		var side := Vector3(-sin(a), cos(a), 0)
		var r0 := hub + dir * 0.18 + Vector3(0, 0, 0.06)
		var r1 := hub + dir * 1.75 + Vector3(0, 0, 0.06)
		_panel(st, r0 - side * 0.03, r1 - side * 0.03, r1 + side * 0.03, r0 + side * 0.03, Color("f2efe6"))  # the stock
		_panel(st, r0 + dir * 0.15 + side * 0.03, r1 + side * 0.03, r1 + side * 0.36, r0 + dir * 0.15 + side * 0.36, Color("e9e4d6"))
		for s in 5:  # shutters
			var p := r0 + dir * (0.3 + s * 0.28) + Vector3(0, 0, 0.01)
			_panel(st, p + side * 0.03, p + dir * 0.04 + side * 0.03, p + dir * 0.04 + side * 0.36, p + side * 0.36, Color("b9b4a8"))
	return Meshes._finish(st)

## A Cambridge punt: long, flat and varnished, with cushions, a till at the back to stand on, and a pole.
static func punt(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var wood := Color("8a5a32")
	Meshes.box(st, Vector3(-0.38, -0.12, -1.2), Vector3(0.76, 0.3, 2.4), wood, wood.darkened(0.35))
	Meshes.box(st, Vector3(-0.36, 0.14, 0.8), Vector3(0.72, 0.04, 0.4), wood.lightened(0.15))  # the till
	var cushion: Color = [Color("b8322a"), Color("2f5a8a"), Color("3d7a4a")][posmod(variant, 3)]
	Meshes.box(st, Vector3(-0.3, 0.1, -0.9), Vector3(0.6, 0.12, 0.5), cushion)
	Meshes.box(st, Vector3(-0.3, 0.1, -0.2), Vector3(0.6, 0.12, 0.5), cushion.darkened(0.1))
	_strut(st, Vector3(0.25, 0.1, 1.05), Vector3(0.45, 2.6, 0.7), 0.04, Color("c9b48a"))
	return Meshes._finish(st)

## The Mathematical Bridge at Queens': a timber arch made only of straight beams, laid on lines that just touch
## the curve. `variant` is its length in tiles, running east from its tile.
static func maths_bridge(variant := 4) -> ArrayMesh:
	var st := Meshes._st()
	var n := maxi(2, variant)
	var x0 := -0.5
	var x1 := n - 0.5
	var oak := Color("8c7a62")
	var segs := 8
	var deck := []
	for i in segs + 1:
		var t := float(i) / segs
		deck.append(Vector3(lerpf(x0, x1, t), 0.15 + 0.55 * sin(PI * t), 0))
	for i in segs:
		var a: Vector3 = deck[i]
		var b: Vector3 = deck[i + 1]
		Meshes._quad(st, a + Vector3(0, 0.02, -0.42), b + Vector3(0, 0.02, -0.42), b + Vector3(0, 0.02, 0.42), a + Vector3(0, 0.02, 0.42), oak.lightened(0.12))
		Meshes._quad(st, a + Vector3(0, -0.08, 0.42), b + Vector3(0, -0.08, 0.42), b + Vector3(0, -0.08, -0.42), a + Vector3(0, -0.08, -0.42), oak.darkened(0.3))
	for z in [-0.42, 0.42]:
		var off := Vector3(0, 0, z)
		for i in segs:  # top rail, and the arch rib below the deck
			_strut(st, deck[i] + off + Vector3(0, 0.62, 0), deck[i + 1] + off + Vector3(0, 0.62, 0), 0.06, oak)
			_strut(st, deck[i] + off + Vector3(0, -0.2, 0), deck[i + 1] + off + Vector3(0, -0.2, 0), 0.08, oak.darkened(0.15))
		for i in range(0, segs + 1, 2):  # radial posts
			_strut(st, deck[i] + off + Vector3(0, -0.2, 0), deck[i] + off + Vector3(0, 0.62, 0), 0.05, oak.darkened(0.1))
		for i in range(1, segs - 1):  # the tangent beams, crossing each other in the famous lattice
			_strut(st, deck[i] + off + Vector3(0, -0.15, 0), deck[i + 2] + off + Vector3(0, 0.55, 0), 0.04, oak.lightened(0.05))
			_strut(st, deck[i + 2] + off + Vector3(0, -0.15, 0), deck[i] + off + Vector3(0, 0.55, 0), 0.04, oak.lightened(0.05))
	for xe in [x0, x1]:  # brick abutments
		Meshes.box(st, Vector3(xe - 0.3, -0.6, -0.55), Vector3(0.6, 0.8, 1.1), DARK_BRICK)
	return Meshes._finish(st)

## A Norfolk wherry: a black-tarred hull with a single huge black gaff sail and a white-tipped mast.
static func wherry(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var hull := TARRED
	Meshes.box(st, Vector3(-0.45, -0.2, -1.8), Vector3(0.9, 0.55, 3.6), hull, Color("8a6a46"))
	Meshes.box(st, Vector3(-0.35, 0.35, -0.6), Vector3(0.7, 0.3, 1.8), Color("5a4632"))  # hatch covers
	Meshes.box(st, Vector3(-0.06, 0.35, -1.2), Vector3(0.12, 3.6, 0.12), TARRED)
	Meshes.box(st, Vector3(-0.07, 3.8, -1.21), Vector3(0.14, 0.2, 0.14), Color("f2efe6"))
	var sail := Color("1d1c1c") if variant == 0 else Color("4a2a20")
	_panel(st, Vector3(0, 3.7, -1.15), Vector3(0, 3.1, 1.3), Vector3(0, 0.75, 1.5), Vector3(0, 0.75, -1.1), sail)
	return Meshes._finish(st)
