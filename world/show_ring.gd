class_name ShowRing
extends RefCounted
## The County Show ring, put up in the town hosting today's show (see Tournament, data/shows.json): a striped
## marquee with its flaps tied back, a roped ring with a show jump and two sheep who have entered themselves,
## hay bales, a rosette board, the nation's flag and a run of bunting. Plus the Steward and the Rosette Stall,
## who are only there on show days. Everything stands inside the show's footprint, which is fenced off for the
## day (ZoneData.blocked), so the town's paths are untouched. Four mesh nodes in all.

const CANVAS := Color("f1ede2")
const STRIPE := Color("2f7a4a")      # marquee roof stripes: a proper show green
const VALANCE := Color("c9483f")
const POLE := Color("e8e4da")
const ROPE := Color("f4f1e8")
const STRAW := Color("d9b65a")
const TURF := Color("6a8c43")
const FELT := Color("2f5a3c")
const ROSETTES := [Color("c8102e"), Color("1f4f9e"), Color("e0b83a")]
const MARQUEE_W := 4
const STEWARD := {"id": "show_steward", "sprite": "farmer", "name": "Steward", "script": "show_steward"}
const STALL := {"id": "show_stall", "sprite": "villager_5", "name": "Rosette Stall", "script": "show_stall"}

## Dresses `z` for today's show if it's here. Safe to call again on a rebuild (the NPCs go in once).
static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	if z.kind == "interior" or z.town_id == "":
		return
	var s := Tournament.on_in(data, z.town_id)
	if s.is_empty():
		return
	var ring: Dictionary = s.ring
	var r := Rect2i(int(ring.x), int(ring.y), int(ring.w), int(ring.h))
	for p in footprint(r):
		z.blocked[p] = true
	add_npcs(z, s)
	_clear_props(zone_node, r)
	zone_node.add_child(build(z, r, int(s.get("flag", -1))))

## Flower patches and tufts already planted on the footprint would poke through the tent: fold them away.
static func _clear_props(zone_node: Node3D, r: Rect2i) -> void:
	var area := Rect2(Vector2(r.position), Vector2(r.size))
	for child in zone_node.get_children():
		if not (child is MultiMeshInstance3D):
			continue
		var mm: MultiMesh = child.multimesh
		for i in mm.instance_count:
			var o := mm.get_instance_transform(i).origin
			if area.has_point(Vector2(o.x, o.z)):
				mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * 0.0001), o))

static func footprint(r: Rect2i) -> Array:
	var out := []
	for y in range(r.position.y, r.end.y):
		for x in range(r.position.x, r.end.x):
			out.append(Vector2i(x, y))
	return out

## The Steward and the Rosette Stall, as zone NPC defs (only once).
static func add_npcs(z: ZoneData, s: Dictionary) -> void:
	for n in z.npcs:
		if str(n.get("id", "")) == STEWARD.id:
			return
	for spot in s.get("npcs", []):
		var def: Dictionary = (STEWARD if str(spot.role) == "steward" else STALL).duplicate()
		def["x"] = int(spot.x)
		def["y"] = int(spot.y)
		def["facing"] = str(spot.get("facing", "down"))
		def["move"] = "still"
		z.npcs.append(def)

## The whole ring as a few mesh nodes, in zone space.
static func build(z: ZoneData, r: Rect2i, flag_variant: int) -> Node3D:
	Meshes.materials()
	var root := Node3D.new()
	root.name = "ShowRing"
	var gy := ZoneBuilder.ground_y(z, r.position)
	root.position = Vector3(r.position.x, gy, r.position.y)
	var w := float(r.size.x)
	var h := float(r.size.y)
	var st := Meshes._st()
	var rng := Meshes._rng(hash(z.id))
	_marquee(st, Vector3(0.1, 0, 0.12), float(MARQUEE_W) - 0.2, 1.76)
	var rx := float(MARQUEE_W) + 1.0  # the ring's west edge: one tile of hay bales between it and the tent
	_ring(st, Vector3(rx, 0, 0), w - rx, h, rng)
	# hay bales between the tent and the ring, stacked two and one, and a spare out front
	_bale(st, Vector3(MARQUEE_W + 0.5, 0, 0.55), 0.0)
	_bale(st, Vector3(MARQUEE_W + 0.5, 0, 1.05), 0.0)
	_bale(st, Vector3(MARQUEE_W + 0.5, 0.36, 0.8), PI * 0.5)
	_bale(st, Vector3(0.55, 0, h - 0.5), 0.3)
	_bale(st, Vector3(MARQUEE_W + 0.5, 0, h - 0.45), -0.2)
	if h >= 3.0:
		_board(st, Vector3(MARQUEE_W - 0.75, 0, h - 0.55))
	# the bunting poles, at the front corners of the ring
	for x in [rx - 0.5, w - 0.12]:
		Meshes.cylinder(st, Vector3(x, 0, h - 0.12), 0.035, 1.78, 6, POLE)
	_add(root, Meshes._finish(st), Meshes.solid, Transform3D.IDENTITY, true)
	# bunting along the front of the ring (Dressing.bunting hangs at lamp-top height, east from its origin)
	var run := (w - 0.12) - (rx - 0.5)
	var bunt := Dressing.bunting(maxi(1, roundi(run)))
	_add(root, bunt, Meshes.flutter, Transform3D(Basis.from_scale(Vector3(run / maxf(1.0, roundf(run)), 1, 1)), Vector3(rx - 0.5, 0.06, h - 0.12)), false)
	if flag_variant >= 0:
		var pole_at := Transform3D(Basis(), Vector3(MARQUEE_W + 0.5, 0, 0.22))
		_add(root, Dressing.flagpole(), Meshes.solid, pole_at, true)
		_add(root, Dressing.flag(flag_variant), Meshes.flutter, pole_at, false)
	return root

static func _add(root: Node3D, mesh: ArrayMesh, mat: Material, tr: Transform3D, shadow: bool) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.transform = tr
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mi)

## Both windings, for thin canvas seen from either side.
static func _quad2(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	Meshes._quad(st, a, b, c, d, col)
	Meshes._quad(st, a, d, c, b, col.darkened(0.12))

static func _tri2(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	Meshes._tri(st, a, b, c, col)
	Meshes._tri(st, a, c, b, col.darkened(0.12))

## A ridge marquee `w` wide (x) and `d` deep (z) from `o`: canvas walls, a striped roof, a scalloped valance and
## the front flaps tied back on a dim inside with a trestle of jam and a cake under a cover.
static func _marquee(st: SurfaceTool, o: Vector3, w: float, d: float) -> void:
	var eave := 1.05
	var ridge := 1.85
	var x0 := o.x
	var x1 := o.x + w
	var z0 := o.z
	var z1 := o.z + d
	var zm := (z0 + z1) * 0.5
	# the dim inside, then the back and end walls
	Meshes.box(st, Vector3(x0 + 0.05, 0, z0 + 0.05), Vector3(w - 0.1, 0.02, d - 0.1), Color("8a7d5c"))
	_quad2(st, Vector3(x0, 0, z0), Vector3(x1, 0, z0), Vector3(x1, eave, z0), Vector3(x0, eave, z0), CANVAS.darkened(0.25))
	for x in [x0, x1]:
		_quad2(st, Vector3(x, 0, z0), Vector3(x, 0, z1), Vector3(x, eave, z1), Vector3(x, eave, z0), CANVAS)
		_tri2(st, Vector3(x, eave, z0), Vector3(x, eave, z1), Vector3(x, ridge, zm), CANVAS)
	# the front: a panel at each end, the middle open with the flaps tied back
	var gap0 := x0 + 0.85
	var gap1 := x1 - 0.85
	_quad2(st, Vector3(x0, 0, z1), Vector3(gap0, 0, z1), Vector3(gap0, eave, z1), Vector3(x0, eave, z1), CANVAS)
	_quad2(st, Vector3(gap1, 0, z1), Vector3(x1, 0, z1), Vector3(x1, eave, z1), Vector3(gap1, eave, z1), CANVAS)
	for gx in [gap0, gap1]:
		var side := 1.0 if gx == gap0 else -1.0
		_tri2(st, Vector3(gx, eave, z1 + 0.02), Vector3(gx + 0.28 * side, eave, z1 + 0.02), Vector3(gx, 0.25, z1 + 0.06), CANVAS.lightened(0.04))
		Meshes.box(st, Vector3(gx - 0.03, 0.55, z1 + 0.02), Vector3(0.06, 0.05, 0.06), VALANCE)  # the tie
	# inside, through the gap: a trestle with a white cloth, jars of jam and a cake under a mesh cover
	Meshes.box(st, Vector3(gap0 + 0.15, 0, z0 + 0.55), Vector3(gap1 - gap0 - 0.3, 0.55, 0.45), Color("f4f1e8"), Color("fbf9f2"))
	for i in 5:
		var jx := gap0 + 0.3 + i * (gap1 - gap0 - 0.6) / 4.0
		var jam: Color = [Color("8c1c2c"), Color("d9852a"), Color("5a2a4a"), Color("c8102e"), Color("e0b83a")][i]
		Meshes.cylinder(st, Vector3(jx, 0.55, z0 + 0.8), 0.06, 0.13, 6, jam)
		Meshes.box(st, Vector3(jx - 0.06, 0.68, z0 + 0.74), Vector3(0.12, 0.03, 0.12), Color("f2ede2"))
	# the roof, striped green and white along its length, both slopes
	var stripes := 8
	for i in stripes:
		var a := x0 - 0.06 + (w + 0.12) * i / stripes
		var b := x0 - 0.06 + (w + 0.12) * (i + 1) / stripes
		var col := STRIPE if i % 2 == 0 else CANVAS
		_quad2(st, Vector3(a, eave, z1 + 0.1), Vector3(b, eave, z1 + 0.1), Vector3(b, ridge, zm), Vector3(a, ridge, zm), col.lightened(0.06))
		_quad2(st, Vector3(a, ridge, zm), Vector3(b, ridge, zm), Vector3(b, eave, z0 - 0.1), Vector3(a, eave, z0 - 0.1), col.darkened(0.05))
	# the scalloped valance round the eaves, red and white
	var tabs := int(w / 0.25)
	for i in tabs:
		var a := x0 - 0.06 + (w + 0.12) * i / tabs
		var b := x0 - 0.06 + (w + 0.12) * (i + 1) / tabs
		var col := VALANCE if i % 2 == 0 else CANVAS
		_tri2(st, Vector3(a, eave + 0.02, z1 + 0.1), Vector3(b, eave + 0.02, z1 + 0.1), Vector3((a + b) * 0.5, eave - 0.14, z1 + 0.11), col)
	# poles at the ridge ends, each with a red pennant
	for x in [x0, x1]:
		Meshes.cylinder(st, Vector3(x, 0, zm), 0.035, ridge + 0.32, 6, POLE)
		_tri2(st, Vector3(x, ridge + 0.32, zm), Vector3(x, ridge + 0.18, zm), Vector3(x + 0.26, ridge + 0.25, zm), VALANCE)

## The show ring: worn turf inside a white rope on posts, a show jump in the middle and two sheep.
static func _ring(st: SurfaceTool, o: Vector3, w: float, d: float, rng: RandomNumberGenerator) -> void:
	var x0 := o.x + 0.15
	var x1 := o.x + w - 0.2
	var z0 := o.z + 0.2
	var z1 := o.z + d - 0.35
	Meshes._quad(st, Vector3(x0, 0.012, z0), Vector3(x1, 0.012, z0), Vector3(x1, 0.012, z1), Vector3(x0, 0.012, z1), TURF)
	# posts round the edge, about a tile apart, with two ropes between
	var corners := [Vector3(x0, 0, z0), Vector3(x1, 0, z0), Vector3(x1, 0, z1), Vector3(x0, 0, z1)]
	for k in 4:
		var a: Vector3 = corners[k]
		var b: Vector3 = corners[(k + 1) % 4]
		var n := maxi(1, roundi(a.distance_to(b)))
		for i in n:
			var p := a.lerp(b, float(i) / n)
			Meshes.box(st, p + Vector3(-0.035, 0, -0.035), Vector3(0.07, 0.62, 0.07), POLE)
			Meshes.box(st, p + Vector3(-0.045, 0.6, -0.045), Vector3(0.09, 0.05, 0.09), VALANCE)
		for y in [0.3, 0.52]:
			Dressing._bar(st, a + Vector3(0, y, 0), b + Vector3(0, y, 0), 0.012, ROPE)
	# a show jump: two striped wings and two red-and-white poles
	var c := Vector3((x0 + x1) * 0.5 + 0.2, 0, (z0 + z1) * 0.5 - 0.05)
	for side in [-1.0, 1.0]:
		var wx: float = c.x + side * 0.62
		for j in 4:
			Meshes.box(st, Vector3(wx - 0.05, j * 0.2, c.z - 0.18), Vector3(0.1, 0.2, 0.36), CANVAS if j % 2 == 0 else Color("2f6f9e"))
		Meshes.box(st, Vector3(wx - 0.06, 0.8, c.z - 0.2), Vector3(0.12, 0.05, 0.4), CANVAS)
	for y in [0.32, 0.58]:
		var segs := 6
		for i in segs:
			var sx := c.x - 0.57 + 1.14 * i / segs
			Meshes.box(st, Vector3(sx, y, c.z - 0.03), Vector3(1.14 / segs, 0.06, 0.06), VALANCE if i % 2 == 0 else CANVAS)
	# two sheep, who have entered themselves
	var ewe := Landmarks.sheep(1)
	var tup := Landmarks.sheep(0)
	_merge(st, ewe, Transform3D(Basis(Vector3.UP, 0.6), Vector3(x0 + 0.65, 0, z1 - 0.45)))
	_merge(st, tup, Transform3D(Basis(Vector3.UP, 2.5 + rng.randf() * 0.4), Vector3(x1 - 0.55, 0, z0 + 0.5)))

## Copies another mesh's triangles into `st` (vertex colours kept), so the sheep cost no extra nodes.
static func _merge(st: SurfaceTool, mesh: ArrayMesh, tr: Transform3D) -> void:
	var arr := mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var cols: PackedColorArray = arr[Mesh.ARRAY_COLOR]
	var idx: PackedInt32Array = arr[Mesh.ARRAY_INDEX] if arr[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var order: Array = Array(idx) if not idx.is_empty() else range(verts.size())
	for t in range(0, order.size(), 3):
		var a: Vector3 = tr * verts[order[t]]
		var b: Vector3 = tr * verts[order[t + 1]]
		var c: Vector3 = tr * verts[order[t + 2]]
		Meshes._tri(st, a, b, c, cols[order[t]] if not cols.is_empty() else Color.WHITE)

## A rectangular straw bale with two strings round it, turned `rot` about its centre.
static func _bale(st: SurfaceTool, c: Vector3, rot: float) -> void:
	var basis := Basis(Vector3.UP, rot)
	var hx := 0.32
	var hz := 0.2
	var hy := 0.36
	var cs := [Vector3(-hx, 0, -hz), Vector3(hx, 0, -hz), Vector3(hx, 0, hz), Vector3(-hx, 0, hz)]
	var lo := cs.map(func(v): return c + basis * v)
	var hi := cs.map(func(v): return c + basis * v + Vector3(0, hy, 0))
	Meshes._quad(st, hi[0], hi[1], hi[2], hi[3], STRAW.lightened(0.1))
	for i in 4:
		var j := (i + 1) % 4
		Meshes._quad(st, hi[j], hi[i], lo[i], lo[j], STRAW.darkened(0.05 + 0.04 * (i % 2)))
	for s in [-0.14, 0.14]:  # the strings
		var a := c + basis * Vector3(s, 0, -hz - 0.005)
		var b := c + basis * Vector3(s, 0, hz + 0.005)
		Dressing._bar(st, a + Vector3(0, hy + 0.005, 0), b + Vector3(0, hy + 0.005, 0), 0.008, Color("8a6a46"))
		Dressing._bar(st, b + Vector3(0, 0.02, 0), b + Vector3(0, hy, 0), 0.008, Color("8a6a46"))

## The prize board: green felt on two legs with a red, a blue and a yellow rosette pinned on.
static func _board(st: SurfaceTool, c: Vector3) -> void:
	for lx in [-0.36, 0.3]:
		Meshes.box(st, c + Vector3(lx, 0, -0.03), Vector3(0.06, 0.95, 0.06), Dressing.WOOD)
	Meshes.box(st, c + Vector3(-0.42, 0.45, -0.04), Vector3(0.84, 0.52, 0.05), Dressing.WOOD.darkened(0.1))
	Meshes.box(st, c + Vector3(-0.38, 0.49, 0.0), Vector3(0.76, 0.44, 0.02), FELT)
	for i in 3:
		var rc: Vector3 = c + Vector3(-0.24 + i * 0.24, 0.76, 0.03)
		var col: Color = ROSETTES[i]
		Dressing._disc_z(st, rc, 0.095, 10, col.lightened(0.12))
		Dressing._disc_z(st, rc + Vector3(0, 0, 0.005), 0.045, 8, Color("f2e6c8"))
		for t in [-1.0, 1.0]:  # the tails
			Meshes._quad(st, rc + Vector3(t * 0.02, -0.06, 0.004), rc + Vector3(t * 0.07, -0.06, 0.004),
				rc + Vector3(t * 0.08, -0.24, 0.004), rc + Vector3(t * 0.03, -0.22, 0.004), col)
