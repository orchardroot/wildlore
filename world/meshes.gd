class_name Meshes
extends RefCounted
## Procedural low-poly, flat-shaded, vertex-coloured meshes. No textures: colour lives in the vertices.
## All shapes sit on y = 0 at their origin and fit a 1x1 tile unless noted.

## Shared materials. `solid` for buildings and rocks; `foliage` sways in the wind; `glow` is lamps (and the
## battle backdrops' windows); `windows` is lit windows, each pane's brightness and bedtime in its vertex
## colour; `ground` darkens and shines in the rain and rimes over in a frost; `bobbing` rides the water.
static var solid: StandardMaterial3D
static var foliage: ShaderMaterial
static var glow: StandardMaterial3D
static var windows: ShaderMaterial
static var ground: ShaderMaterial
static var bobbing: ShaderMaterial
static var bobbing_calm: ShaderMaterial  # canal boats: barely a ripple
static var flutter: ShaderMaterial  # bunting, flags and washing
static var pool: ShaderMaterial  # lamplight on the ground, additive, strength set by SkyAndLight
static var firelight: ShaderMaterial  # hearth fire and its glow

static func materials() -> void:
	if solid != null:
		return
	solid = StandardMaterial3D.new()
	solid.vertex_color_use_as_albedo = true
	solid.vertex_color_is_srgb = true
	solid.roughness = 1.0
	solid.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	foliage = ShaderMaterial.new()
	foliage.shader = load("res://art/shaders/foliage.gdshader")
	Seasonal.tint(foliage)  # autumn colour, spring blossom or winter rime from the real date
	glow = StandardMaterial3D.new()
	glow.albedo_color = Color("3a4658")
	glow.emission_enabled = true
	glow.emission = Color("ffc860")
	glow.emission_energy_multiplier = 0.0
	windows = ShaderMaterial.new()
	windows.shader = load("res://art/shaders/windows.gdshader")
	ground = ShaderMaterial.new()
	ground.shader = load("res://art/shaders/ground.gdshader")
	bobbing = ShaderMaterial.new()
	bobbing.shader = load("res://art/shaders/bobbing.gdshader")
	bobbing_calm = ShaderMaterial.new()
	bobbing_calm.shader = bobbing.shader
	bobbing_calm.set_shader_parameter("amount", 0.3)
	flutter = ShaderMaterial.new()
	flutter.shader = load("res://art/shaders/flutter.gdshader")
	pool = ShaderMaterial.new()
	pool.shader = load("res://art/shaders/lamp_pool.gdshader")
	firelight = ShaderMaterial.new()
	firelight.shader = load("res://art/shaders/firelight.gdshader")

# --- primitive helpers -------------------------------------------------------

static func _tri(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, col: Color) -> void:
	var n := (c - a).cross(b - a).normalized()
	for v in [a, b, c]:
		st.set_color(col)
		st.set_normal(n)
		st.add_vertex(v)

static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, col: Color) -> void:
	_tri(st, a, b, c, col)
	_tri(st, a, c, d, col)

## Quad with a colour per corner (smooth painterly ground). Normal is taken from the first triangle.
static func quad4(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ca: Color, cb: Color, cc: Color, cd: Color) -> void:
	var n := (c - a).cross(b - a).normalized()
	for pair in [[a, ca], [b, cb], [c, cc], [a, ca], [c, cc], [d, cd]]:
		st.set_color(pair[1])
		st.set_normal(n)
		st.add_vertex(pair[0])

## Axis-aligned box from min corner `o` with size `s`. Top face gets `top` colour if given.
static func box(st: SurfaceTool, o: Vector3, s: Vector3, col: Color, top := Color(0, 0, 0, 0)) -> void:
	var t := top if top.a > 0.0 else col.lightened(0.08)
	var x0 := o.x
	var x1 := o.x + s.x
	var y0 := o.y
	var y1 := o.y + s.y
	var z0 := o.z
	var z1 := o.z + s.z
	_quad(st, Vector3(x0, y1, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1), Vector3(x0, y1, z1), t)
	_quad(st, Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3(x1, y0, z1), Vector3(x0, y0, z1), col)
	_quad(st, Vector3(x1, y1, z0), Vector3(x0, y1, z0), Vector3(x0, y0, z0), Vector3(x1, y0, z0), col.darkened(0.12))
	_quad(st, Vector3(x0, y1, z0), Vector3(x0, y1, z1), Vector3(x0, y0, z1), Vector3(x0, y0, z0), col.darkened(0.06))
	_quad(st, Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3(x1, y0, z0), Vector3(x1, y0, z1), col.darkened(0.03))

static func _ring(c: Vector3, r: float, y: float, sides: int, phase := 0.0) -> Array:
	var pts := []
	for i in sides:
		var a := TAU * i / sides + phase
		pts.append(Vector3(c.x + cos(a) * r, y, c.z + sin(a) * r))
	return pts

static func cylinder(st: SurfaceTool, base: Vector3, r: float, h: float, sides: int, col: Color) -> void:
	var lo := _ring(base, r, base.y, sides)
	var hi := _ring(base, r * 0.85, base.y + h, sides)
	for i in sides:
		var j := (i + 1) % sides
		_quad(st, lo[i], lo[j], hi[j], hi[i], col.darkened(0.08 * (i % 2)))

static func cone(st: SurfaceTool, base: Vector3, r: float, h: float, sides: int, col: Color, rng: RandomNumberGenerator) -> void:
	var lo := _ring(base, r, base.y, sides, rng.randf() * TAU)
	var tip := base + Vector3(rng.randf_range(-0.04, 0.04), h, rng.randf_range(-0.04, 0.04))
	for i in sides:
		var j := (i + 1) % sides
		_tri(st, lo[i], lo[j], tip, col.lightened(rng.randf_range(-0.05, 0.08)))
	var c := Vector3(base.x, base.y, base.z)
	for i in sides:
		_tri(st, lo[(i + 1) % sides], lo[i], c, col.darkened(0.3))

## A jittered low-poly blob (6 sides x 4 bands), used for canopies, bushes and rocks.
static func blob(st: SurfaceTool, c: Vector3, r: Vector3, col: Color, rng: RandomNumberGenerator, jitter := 0.18) -> void:
	var bands := 4
	var sides := 6
	var rings := []
	for b in range(bands + 1):
		var phi := PI * b / bands
		var ring := []
		for i in sides:
			var th := TAU * i / sides + (0.5 if b % 2 == 1 else 0.0)
			var k := 1.0 + rng.randf_range(-jitter, jitter) if b > 0 and b < bands else 1.0
			ring.append(c + Vector3(sin(phi) * cos(th) * r.x * k, cos(phi) * r.y * k, sin(phi) * sin(th) * r.z * k))
		rings.append(ring)
	for b in range(bands):
		var shade := col.lightened(0.12 - 0.08 * b)
		for i in sides:
			var j := (i + 1) % sides
			var a: Vector3 = rings[b][i]
			var bb: Vector3 = rings[b][j]
			var cc: Vector3 = rings[b + 1][j]
			var d: Vector3 = rings[b + 1][i]
			_quad(st, a, d, cc, bb, shade.lightened(rng.randf_range(-0.04, 0.04)))

static func _finish(st: SurfaceTool) -> ArrayMesh:
	st.index()
	return st.commit()

static func _st() -> SurfaceTool:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	return st

static func _rng(seed_value: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value
	return r

# --- props -------------------------------------------------------------------

const TRUNK := Color("6b4a32")
const OAK_GREENS := [Color("4f7a3a"), Color("5d8a3f"), Color("466d34")]
const PINE_GREEN := Color("2f5a3c")
const BIRCH_BARK := Color("e6e1d6")

static func oak(variant := 0) -> ArrayMesh:
	var rng := _rng(1000 + variant)
	var st := _st()
	cylinder(st, Vector3(0, 0, 0), 0.13, 1.0, 6, TRUNK)
	var g: Color = OAK_GREENS[variant % OAK_GREENS.size()]
	blob(st, Vector3(0, 1.45, 0), Vector3(0.62, 0.55, 0.62), g, rng)
	blob(st, Vector3(-0.28, 1.2, 0.12), Vector3(0.42, 0.38, 0.42), g.darkened(0.06), rng)
	blob(st, Vector3(0.3, 1.25, -0.1), Vector3(0.4, 0.36, 0.4), g.lightened(0.05), rng)
	blob(st, Vector3(0.05, 1.85, 0.05), Vector3(0.36, 0.3, 0.36), g.lightened(0.1), rng)
	return _finish(st)

static func pine(variant := 0) -> ArrayMesh:
	var rng := _rng(2000 + variant)
	var st := _st()
	cylinder(st, Vector3(0, 0, 0), 0.1, 0.6, 5, TRUNK.darkened(0.1))
	var g := PINE_GREEN.lightened(0.04 * (variant % 3))
	cone(st, Vector3(0, 0.45, 0), 0.6, 0.9, 7, g, rng)
	cone(st, Vector3(0, 0.95, 0), 0.47, 0.85, 7, g.lightened(0.05), rng)
	cone(st, Vector3(0, 1.45, 0), 0.33, 0.8, 7, g.lightened(0.1), rng)
	return _finish(st)

static func birch(variant := 0) -> ArrayMesh:
	var rng := _rng(3000 + variant)
	var st := _st()
	cylinder(st, Vector3(0, 0, 0), 0.08, 1.4, 5, BIRCH_BARK)
	blob(st, Vector3(0, 1.6, 0), Vector3(0.42, 0.55, 0.42), Color("7fa24a"), rng)
	return _finish(st)

static func bush(variant := 0) -> ArrayMesh:
	var rng := _rng(4000 + variant)
	var st := _st()
	blob(st, Vector3(0, 0.28, 0), Vector3(0.42, 0.32, 0.42), Color("4c7a39"), rng)
	return _finish(st)

static func rock(variant := 0) -> ArrayMesh:
	var rng := _rng(5000 + variant)
	var st := _st()
	blob(st, Vector3(0, 0.22, 0), Vector3(0.46, 0.34, 0.42), Color("8c8270"), rng, 0.25)
	blob(st, Vector3(0.22, 0.12, 0.18), Vector3(0.22, 0.16, 0.2), Color("7d7462"), rng, 0.25)
	return _finish(st)

static func hedge_segment(variant := 0) -> ArrayMesh:
	var rng := _rng(6000 + variant)
	var st := _st()
	box(st, Vector3(-0.5, 0, -0.38), Vector3(1.0, 0.75, 0.76), Color("3f6b33"), Color("4d7d3b"))
	for i in 3:
		blob(st, Vector3(-0.33 + i * 0.33, 0.78, 0), Vector3(0.24, 0.16, 0.3), Color("4a7a38"), rng)
	return _finish(st)

static func wall_segment(variant := 0) -> ArrayMesh:
	var rng := _rng(7000 + variant)
	var st := _st()
	var stone := Color("9b927f")
	for row in 4:
		var x := -0.5 + (0.12 if row % 2 == 1 else 0.0)
		while x < 0.5:
			var w := rng.randf_range(0.22, 0.36)
			var w2 := minf(w, 0.5 - x)
			var c := stone.lightened(rng.randf_range(-0.12, 0.1))
			box(st, Vector3(x, row * 0.17, -0.2 + rng.randf_range(-0.02, 0.02)), Vector3(w2 - 0.02, 0.16, 0.4), c)
			x += w
	box(st, Vector3(-0.5, 0.68, -0.22), Vector3(1.0, 0.1, 0.44), stone.darkened(0.15))
	return _finish(st)

static func fence_segment() -> ArrayMesh:
	var st := _st()
	var wood := Color("8a6a46")
	box(st, Vector3(-0.45, 0, -0.05), Vector3(0.1, 0.7, 0.1), wood)
	box(st, Vector3(0.35, 0, -0.05), Vector3(0.1, 0.7, 0.1), wood)
	box(st, Vector3(-0.5, 0.45, -0.03), Vector3(1.0, 0.08, 0.06), wood.lightened(0.08))
	box(st, Vector3(-0.5, 0.2, -0.03), Vector3(1.0, 0.08, 0.06), wood.lightened(0.08))
	return _finish(st)

static func flower_patch(variant := 0) -> ArrayMesh:
	var rng := _rng(8000 + variant)
	var st := _st()
	var cols := [Color("e8d34a"), Color("d8566b"), Color("f2f0e6"), Color("9b6fb0")]
	for i in 7:
		var p := Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4))
		box(st, p + Vector3(-0.01, 0, -0.01), Vector3(0.02, 0.12, 0.02), Color("4f7a3a"))
		box(st, p + Vector3(-0.04, 0.12, -0.04), Vector3(0.08, 0.05, 0.08), cols[rng.randi() % cols.size()])
	return _finish(st)

static func tall_grass_tuft(variant := 0) -> ArrayMesh:
	var rng := _rng(9000 + variant)
	var st := _st()
	for i in 14:
		var p := Vector3(rng.randf_range(-0.45, 0.45), 0, rng.randf_range(-0.45, 0.45))
		var a := rng.randf() * TAU
		var side := Vector3(cos(a), 0, sin(a)) * 0.05
		var h := rng.randf_range(0.32, 0.55)
		var tip := p + Vector3(rng.randf_range(-0.08, 0.08), h, rng.randf_range(-0.08, 0.08))
		_tri(st, p - side, p + side, tip, Color("5b8c3a").lightened(rng.randf_range(-0.1, 0.12)))
	return _finish(st)

## Ling heather's bloom: a muted purple-mauve with brown in it (the lighting lifts these a lot, and the old
## violets read as lilac paint on the moor). The paler sprigs and the tufts at a crag's foot use them too.
const HEATHER_BLOOMS := [Color("6e4a5e"), Color("7a5468"), Color("614254"), Color("80596a")]

## Ling heather: low dark woody cushions with the purple bloom on top, a few paler sprigs standing proud.
static func heather_tuft(variant := 0) -> ArrayMesh:
	var rng := _rng(12000 + variant)
	var st := _st()
	var blooms := HEATHER_BLOOMS
	for i in 10:
		var p := Vector3(rng.randf_range(-0.42, 0.42), 0, rng.randf_range(-0.42, 0.42))
		var r := rng.randf_range(0.1, 0.15)
		blob(st, p + Vector3(0, 0.05, 0), Vector3(r * 1.1, 0.06, r * 1.1), Color("4a4532").lightened(rng.randf_range(-0.04, 0.06)), rng, 0.3)
		var c: Color = blooms[rng.randi() % blooms.size()]
		blob(st, p + Vector3(0, 0.12, 0), Vector3(r, rng.randf_range(0.06, 0.1), r), c.lightened(rng.randf_range(-0.06, 0.08)), rng, 0.3)
	for i in 3:
		var p := Vector3(rng.randf_range(-0.38, 0.38), 0.1, rng.randf_range(-0.38, 0.38))
		box(st, p, Vector3(0.035, rng.randf_range(0.12, 0.18), 0.035), HEATHER_BLOOMS[3].lightened(0.15))
	return _finish(st)

## A run of Peak District gritstone edge, one tile long: fallen blocks at the foot, then two to four courses of
## flat-bedded millstone grit weathered round at the corners (flattened blobs, two or three to a course, with dark
## cracks between), lichen-pale on top. Courses overhang the tile a little so a row reads as one crag, and the
## variants step the skyline up and down.
static func gritstone_edge(variant := 0) -> ArrayMesh:
	var rng := _rng(15000 + variant * 7)
	var st := _st()
	var grit := Color("7d7362")
	for i in 3:  # fallen blocks at the foot
		var p := Vector3(rng.randf_range(-0.45, 0.45), 0.1, rng.randf_range(0.42, 0.62))
		blob(st, p, Vector3(rng.randf_range(0.12, 0.2), rng.randf_range(0.08, 0.13), rng.randf_range(0.1, 0.16)), grit.darkened(rng.randf_range(0.0, 0.1)), rng, 0.25)
	box(st, Vector3(-0.6, 0, -0.42), Vector3(1.2, 0.18, 0.84), grit.darkened(0.25))  # a dark root so no daylight shows under the slabs
	var y := 0.08
	var courses: int = [3, 2, 4][variant % 3]
	for c in courses:
		var h := rng.randf_range(0.28, 0.4) * (0.85 if c == courses - 1 else 1.0)
		var depth := 0.42 - 0.04 * c
		var n := 2 + rng.randi() % 2
		var x := -0.62
		for k in n:
			var w := (1.24 / n) * rng.randf_range(0.85, 1.15)
			if k == n - 1:
				w = 0.62 - x
			var col := grit.lightened(rng.randf_range(-0.07, 0.06) + 0.025 * c)
			var cz := rng.randf_range(-0.04, 0.06) - 0.03 * c
			blob(st, Vector3(x + w * 0.5, y + h * 0.5, cz), Vector3(w * 0.54, h * 0.56, depth), col, rng, 0.08)
			x += w
		y += h * 0.92
	blob(st, Vector3(rng.randf_range(-0.2, 0.2), y + 0.03, -0.1), Vector3(0.38, 0.06, 0.3), Color("9a937c"), rng, 0.15)  # lichen-pale top
	blob(st, Vector3(rng.randf_range(-0.35, 0.35), y + 0.06, -0.18), Vector3(0.16, 0.07, 0.14), Color("5e5a3a"), rng, 0.3)  # bilberry on top
	blob(st, Vector3(rng.randf_range(-0.45, 0.45), 0.08, 0.58), Vector3(0.18, 0.08, 0.12), HEATHER_BLOOMS[0], rng, 0.3)  # heather at the foot
	return _finish(st)

static func reeds(variant := 0) -> ArrayMesh:
	var rng := _rng(13000 + variant)
	var st := _st()
	for i in 10:
		var p := Vector3(rng.randf_range(-0.4, 0.4), 0, rng.randf_range(-0.4, 0.4))
		var tip := p + Vector3(rng.randf_range(-0.05, 0.05), rng.randf_range(0.6, 0.9), rng.randf_range(-0.05, 0.05))
		_tri(st, p - Vector3(0.03, 0, 0), p + Vector3(0.03, 0, 0), tip, Color("8a8a4a").lightened(rng.randf_range(-0.1, 0.1)))
		box(st, tip - Vector3(0.025, 0.14, 0.025), Vector3(0.05, 0.14, 0.05), Color("5a3f2a"))
	return _finish(st)

static func lamp_post() -> ArrayMesh:
	var st := _st()
	var iron := Color("2d3138")
	box(st, Vector3(-0.08, 0, -0.08), Vector3(0.16, 0.12, 0.16), iron)
	cylinder(st, Vector3(0, 0.12, 0), 0.04, 1.6, 6, iron)
	box(st, Vector3(-0.12, 1.72, -0.12), Vector3(0.24, 0.05, 0.24), iron)
	return _finish(st)

static func lamp_bulb() -> ArrayMesh:
	var st := _st()
	box(st, Vector3(-0.09, 1.52, -0.09), Vector3(0.18, 0.2, 0.18), Color("ffe2a0"))
	return _finish(st)

static func bench() -> ArrayMesh:
	var st := _st()
	var wood := Color("7a5636")
	var iron := Color("2d3138")
	box(st, Vector3(-0.45, 0, -0.15), Vector3(0.06, 0.3, 0.3), iron)
	box(st, Vector3(0.39, 0, -0.15), Vector3(0.06, 0.3, 0.3), iron)
	box(st, Vector3(-0.48, 0.3, -0.17), Vector3(0.96, 0.05, 0.34), wood)
	box(st, Vector3(-0.48, 0.38, -0.2), Vector3(0.96, 0.25, 0.04), wood)
	return _finish(st)

static func sign_post() -> ArrayMesh:
	var st := _st()
	var wood := Color("7a5636")
	box(st, Vector3(-0.04, 0, -0.04), Vector3(0.08, 0.9, 0.08), wood)
	box(st, Vector3(-0.32, 0.6, -0.03), Vector3(0.64, 0.32, 0.06), wood.lightened(0.15))
	return _finish(st)

static func counter() -> ArrayMesh:
	var st := _st()
	box(st, Vector3(-0.5, 0, -0.45), Vector3(1.0, 0.9, 0.9), Color("8a6240"), Color("b08a5a"))
	return _finish(st)

static func market_stall(variant := 0) -> ArrayMesh:
	var st := _st()
	var wood := Color("7a5636")
	var stripes := [Color("c9483f"), Color("2f6f9e"), Color("3f8a55")]
	var a: Color = stripes[variant % stripes.size()]
	for px in [-0.45, 0.39]:
		for pz in [-0.35, 0.29]:
			box(st, Vector3(px, 0, pz), Vector3(0.06, 1.15, 0.06), wood)
	box(st, Vector3(-0.48, 0.55, -0.38), Vector3(0.96, 0.08, 0.72), wood.lightened(0.1))
	for i in 6:
		var c: Color = a if i % 2 == 0 else Color("f2ede2")
		box(st, Vector3(-0.5 + i * 0.1667, 1.15, -0.42), Vector3(0.1667, 0.06, 0.84), c)
	box(st, Vector3(-0.4, 0.63, -0.25), Vector3(0.25, 0.12, 0.2), Color("d9a441"))
	box(st, Vector3(0.05, 0.63, -0.2), Vector3(0.3, 0.1, 0.25), Color("8fbf4a"))
	return _finish(st)

static func planter(variant := 0) -> ArrayMesh:
	var rng := _rng(11000 + variant)
	var st := _st()
	box(st, Vector3(-0.4, 0, -0.4), Vector3(0.8, 0.35, 0.8), Color("8c8270"), Color("5a4632"))
	blob(st, Vector3(0, 0.5, 0), Vector3(0.32, 0.25, 0.32), Color("4c7a39"), rng)
	for i in 4:
		box(st, Vector3(rng.randf_range(-0.25, 0.2), 0.62, rng.randf_range(-0.25, 0.2)), Vector3(0.07, 0.07, 0.07), [Color("d8566b"), Color("e8d34a")][i % 2])
	return _finish(st)

static func phone_box() -> ArrayMesh:
	var st := _st()
	var red := Color("c0302b")
	box(st, Vector3(-0.3, 0, -0.3), Vector3(0.6, 1.9, 0.6), red)
	box(st, Vector3(-0.34, 1.9, -0.34), Vector3(0.68, 0.12, 0.68), red.darkened(0.1))
	box(st, Vector3(-0.22, 0.5, 0.29), Vector3(0.44, 1.1, 0.02), Color("bfd4dc"))
	return _finish(st)

static func post_box() -> ArrayMesh:
	var st := _st()
	cylinder(st, Vector3(0, 0, 0), 0.2, 0.95, 8, Color("c0302b"))
	box(st, Vector3(-0.21, 0.95, -0.21), Vector3(0.42, 0.1, 0.42), Color("2d3138"))
	return _finish(st)

static func bookshelf(variant := 0) -> ArrayMesh:
	var rng := _rng(14000 + variant)
	var st := _st()
	var wood := Color("6b4a32")
	box(st, Vector3(-0.48, 0, -0.3), Vector3(0.96, 1.7, 0.36), wood)
	var spines := [Color("8c3b3b"), Color("2f5a7a"), Color("4f7a3a"), Color("c9a441"), Color("6a4a7a")]
	for shelf in 4:
		var y := 0.12 + shelf * 0.4
		var x := -0.42
		while x < 0.4:
			var w := rng.randf_range(0.05, 0.1)
			box(st, Vector3(x, y, 0.0), Vector3(w - 0.01, rng.randf_range(0.22, 0.32), 0.07), spines[rng.randi() % spines.size()])
			x += w
	return _finish(st)

static func potted_plant(variant := 0) -> ArrayMesh:
	var rng := _rng(15000 + variant)
	var st := _st()
	cylinder(st, Vector3(0, 0, 0), 0.2, 0.32, 8, Color("a8553a"))
	blob(st, Vector3(0, 0.55, 0), Vector3(0.3, 0.32, 0.3), Color("4c7a39"), rng, 0.3)
	return _finish(st)

static func table(variant := 0) -> ArrayMesh:
	var st := _st()
	var wood := Color("7a5636")
	for px in [-0.4, 0.34]:
		for pz in [-0.34, 0.28]:
			box(st, Vector3(px, 0, pz), Vector3(0.06, 0.62, 0.06), wood)
	box(st, Vector3(-0.46, 0.62, -0.4), Vector3(0.92, 0.07, 0.8), wood.lightened(0.12))
	box(st, Vector3(-0.1, 0.69, -0.1), Vector3(0.18, 0.12, 0.18), Color("e8e2d4"))
	return _finish(st)

static func bed(variant := 0) -> ArrayMesh:
	var st := _st()
	box(st, Vector3(-0.45, 0, -0.48), Vector3(0.9, 0.38, 0.96), Color("6b4a32"))
	box(st, Vector3(-0.42, 0.38, -0.2), Vector3(0.84, 0.12, 0.66), Color("4a6d8c"))
	box(st, Vector3(-0.36, 0.38, -0.44), Vector3(0.72, 0.16, 0.22), Color("f2ede2"))
	box(st, Vector3(-0.45, 0, -0.5), Vector3(0.9, 0.75, 0.08), Color("5a3f2a"))
	return _finish(st)

# --- buildings ---------------------------------------------------------------

const WALLS := {
	"red_brick": Color("9c4a3a"), "stone": Color("b8ad98"), "white_render": Color("e8e2d4"),
	"gritstone": Color("8c8270"), "cream_render": Color("e6d6ae"), "sanctuary": Color("e8e2d4"), "shop": Color("4a6d8c"),
}
const ROOFS := {
	"red_brick": Color("4a5160"), "stone": Color("5a5f6b"), "white_render": Color("8a4b3b"),
	"gritstone": Color("4a5160"), "cream_render": Color("6a4a3a"), "sanctuary": Color("3f7d5a"), "shop": Color("8a4b3b"),
}

## A building occupying w x d tiles with its origin at the footprint's north-west corner (tile edges, not centres).
## `door_x` is the door column relative to the footprint (-1 for none). Returns [body_mesh, windows_mesh,
## chimney tops (PackedVector3Array, local)].
## `region` is the zone's (ZoneData.region): castles fly its pennant.
static func building(w: int, d: int, style: String, door_x := -1, seed_value := 0, region := "") -> Array:
	if style in Landmarks.SPECIAL:
		return Landmarks.building(w, d, style, door_x, seed_value, region)
	var rng := _rng(seed_value)
	var st := _st()
	var wall: Color = WALLS.get(style, WALLS.red_brick)
	var roof: Color = ROOFS.get(style, ROOFS.red_brick)
	var storeys := 2 if w >= 5 and d >= 3 else 1
	var hgt := 1.2 * storeys + 0.25
	box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, hgt, d - 0.1), wall)
	# plinth and quoins
	box(st, Vector3(0.0, 0, 0.0), Vector3(w, 0.18, d), wall.darkened(0.3))
	box(st, Vector3(0.0, 0, d - 0.12), Vector3(0.14, hgt, 0.14), wall.lightened(0.15))
	box(st, Vector3(w - 0.14, 0, d - 0.12), Vector3(0.14, hgt, 0.14), wall.lightened(0.15))
	# pitched roof, ridge running east-west
	var eave := 0.18
	var ry := hgt
	var rise := minf(1.2, d * 0.38)
	var a := Vector3(-eave, ry, -eave)
	var b := Vector3(w + eave, ry, -eave)
	var c := Vector3(w + eave, ry, d + eave)
	var dd := Vector3(-eave, ry, d + eave)
	var r0 := Vector3(-eave, ry + rise, d * 0.5)
	var r1 := Vector3(w + eave, ry + rise, d * 0.5)
	_quad(st, r0, r1, c, dd, roof)
	_quad(st, r1, r0, a, b, roof.darkened(0.15))
	_tri(st, r0, dd, a, wall.darkened(0.05))
	_tri(st, r1, b, c, wall.darkened(0.08))
	# roof underside so the eaves are not see-through
	_quad(st, dd, c, b, a, roof.darkened(0.4))
	# chimney
	var cx := rng.randf_range(0.6, w - 0.9)
	box(st, Vector3(cx, ry + rise * 0.4, d * 0.5 - 0.2), Vector3(0.35, rise * 0.9, 0.4), wall.darkened(0.2))
	var chimneys := PackedVector3Array([Vector3(cx + 0.175, ry + rise * 1.3, d * 0.5)])
	# door
	if door_x >= 0:
		box(st, Vector3(door_x + 0.22, 0.18, d - 0.08), Vector3(0.56, 0.9, 0.06), Color("3b2a22"))
		box(st, Vector3(door_x + 0.15, 1.08, d - 0.09), Vector3(0.7, 0.08, 0.08), wall.lightened(0.2))
	var wst := _st()
	for s in storeys:
		var wy := 0.42 + 1.2 * s
		for x in w:
			if x == door_x and s == 0:
				continue
			box(st, Vector3(x + 0.27, wy - 0.06, d - 0.07), Vector3(0.46, 0.6, 0.04), wall.lightened(0.25))
			box(wst, Vector3(x + 0.32, wy, d - 0.065), Vector3(0.36, 0.48, 0.04), Landmarks.window_colour(rng))
	return [_finish(st), _finish(wst), chimneys]
