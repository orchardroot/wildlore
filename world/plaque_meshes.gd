class_name PlaqueMeshes
extends RefCounted
## The Gazetteer's heritage lectern (a zone sign with "plaque" and no "kind"): a cast-iron post on a stone footing,
## carrying a bronze-framed enamel board tilted up towards the reader, with a roundel and a few lines of lettering.
## Variant 0 is the blue enamel of Britain's heritage boards, 1 the green of Ireland's. Faces +z (south), like the
## building fronts, so the player reads it from the tile below.

const IRON := Color("2a2e35")
const BRONZE := Color("8c6a3c")
const STONE := Color("b8b09f")
const ENAMEL := [Color("23488f"), Color("1f6845")]
const CREAM := Color("f2ead2")
const TILT := deg_to_rad(40.0)  # the board, from horizontal
const BOARD_Y := 0.74           # height of the board's centre

static func lectern(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var enamel: Color = ENAMEL[clampi(variant, 0, ENAMEL.size() - 1)]
	Meshes.box(st, Vector3(-0.2, 0, -0.17), Vector3(0.4, 0.06, 0.3), STONE, STONE.lightened(0.08))       # footing
	Meshes.box(st, Vector3(-0.07, 0.06, -0.12), Vector3(0.14, 0.05, 0.14), IRON.lightened(0.1))          # base collar
	Meshes.box(st, Vector3(-0.04, 0.11, -0.09), Vector3(0.08, BOARD_Y - 0.16, 0.08), IRON)                  # post
	Meshes.box(st, Vector3(-0.1, BOARD_Y - 0.1, -0.11), Vector3(0.2, 0.06, 0.12), IRON.lightened(0.06))  # the bracket under the board
	# the board: local x across, y up the slope, z out of the face
	var xf := Transform3D(Basis(Vector3.RIGHT, -(PI * 0.5 - TILT)), Vector3(0, BOARD_Y, -0.03))
	_tbox(st, xf, Vector3(-0.33, -0.22, -0.045), Vector3(0.66, 0.44, 0.045), BRONZE.darkened(0.25), BRONZE)  # bronze frame
	_tbox(st, xf, Vector3(-0.3, -0.19, 0.0), Vector3(0.6, 0.38, 0.008), enamel, enamel)                     # enamel face
	var roundel := Vector3(-0.2, 0.08, 0.012)
	for r in [[0.075, CREAM], [0.06, enamel.lightened(0.12)]]:
		_disc(st, xf, roundel, float(r[0]), r[1])
	_tbox(st, xf, Vector3(-0.1, 0.1, 0.008), Vector3(0.34, 0.035, 0.006), CREAM, CREAM)  # the title
	for i in 4:  # lines of lettering, ragged on the right like real text
		var w: float = [0.5, 0.46, 0.52, 0.3][i]
		_tbox(st, xf, Vector3(-0.26, -0.02 - i * 0.045, 0.008), Vector3(w, 0.016, 0.005), CREAM.darkened(0.08), CREAM.darkened(0.08))
	return Meshes._finish(st)

## Meshes.box, put through a transform (for the tilted board).
static func _tbox(st: SurfaceTool, xf: Transform3D, o: Vector3, s: Vector3, col: Color, top: Color) -> void:
	var x0 := o.x
	var x1 := o.x + s.x
	var y0 := o.y
	var y1 := o.y + s.y
	var z0 := o.z
	var z1 := o.z + s.z
	var q := func(a: Vector3, b: Vector3, c: Vector3, d: Vector3, cl: Color) -> void:
		Meshes._quad(st, xf * a, xf * b, xf * c, xf * d, cl)
	q.call(Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3(x1, y0, z1), top)        # face (+z)
	q.call(Vector3(x0, y1, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1), Vector3(x0, y1, z1), col.lightened(0.05))  # top edge
	q.call(Vector3(x1, y0, z0), Vector3(x0, y0, z0), Vector3(x0, y0, z1), Vector3(x1, y0, z1), col.darkened(0.1))   # bottom edge
	q.call(Vector3(x0, y1, z0), Vector3(x0, y1, z1), Vector3(x0, y0, z1), Vector3(x0, y0, z0), col.darkened(0.06))
	q.call(Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3(x1, y0, z0), Vector3(x1, y0, z1), col.darkened(0.03))
	q.call(Vector3(x1, y1, z0), Vector3(x0, y1, z0), Vector3(x0, y0, z0), Vector3(x1, y0, z0), col.darkened(0.15))  # back

static func _disc(st: SurfaceTool, xf: Transform3D, c: Vector3, r: float, col: Color, sides := 16) -> void:
	for i in sides:
		var a0 := TAU * i / sides
		var a1 := TAU * (i + 1) / sides
		Meshes._tri(st, xf * c, xf * (c + Vector3(cos(a1), sin(a1), 0) * r), xf * (c + Vector3(cos(a0), sin(a0), 0) * r), col)
