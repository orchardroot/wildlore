class_name AmbientLife
extends Node3D
## Life in the background of an outdoor zone: birds crossing the sky (gulls on the coast and at the docks,
## rooks and songbirds inland, bats at dusk and night) and smoke from chimneys. Cheap on purpose: a handful of
## flat flapping meshes and one particle emitter, all off on Low quality, none indoors or in dark caves.

const MAX_BIRDS := 6
const MAX_SMOKING := 12          # chimneys smoking at once (the ones nearest the player)
const SKY_HEIGHT := 4.5          # how far above the player birds fly
const RANGE := 17.0              # birds turn up and leave this far from the player, east-west
## kind -> [colour, wing colour, wingspan, flap rate, flap amp, glide, speed min, speed max]
const KINDS := {
	"gull": [Color("f4f2ec"), Color("9aa3ad"), 1.05, 5.0, 0.45, 1.0, 2.6, 3.6],
	"rook": [Color("1e1f24"), Color("2a2b31"), 0.85, 6.5, 0.4, 0.2, 2.8, 3.8],
	"songbird": [Color("6b4e36"), Color("8a6a4a"), 0.45, 15.0, 0.5, 0.0, 3.4, 4.6],
	"bat": [Color("2a2224"), Color("3a3034"), 0.55, 14.0, 0.6, 0.0, 2.6, 3.6],
}
const COAST := ["coast", "docks"]

var sky: SkyAndLight
var _zone: ZoneData
var _rng := RandomNumberGenerator.new()
var _birds: Array = []           # of Dictionary {node, kind, vel, wait, alive, base_y, wob}
var _meshes := {}
var _smoke: CPUParticles3D
var _chimneys := PackedVector3Array()
var _tick := 0

func _ready() -> void:
	_smoke = CPUParticles3D.new()
	_smoke.emitting = false
	_smoke.emission_shape = CPUParticles3D.EMISSION_SHAPE_POINTS
	_smoke.amount = 60
	_smoke.lifetime = 4.0
	_smoke.direction = Vector3(0, 1, 0)
	_smoke.spread = 12.0
	_smoke.initial_velocity_min = 0.45
	_smoke.initial_velocity_max = 0.75
	_smoke.damping_min = 0.05
	_smoke.damping_max = 0.1
	var grow := Curve.new()
	grow.add_point(Vector2(0, 0.35))
	grow.add_point(Vector2(1, 1.0))
	_smoke.scale_amount_curve = grow
	var fade := Gradient.new()
	fade.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	fade.offsets = PackedFloat32Array([0.0, 0.15, 1.0])
	_smoke.color_ramp = fade
	var q := QuadMesh.new()
	q.size = Vector2(0.55, 0.55)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.albedo_texture = SkyAndLight._soft_texture()
	q.material = m
	_smoke.mesh = q
	add_child(_smoke)
	Bus.settings_changed.connect(_refresh)

## Called by the overworld after each zone is built.
func setup(z: ZoneData, zone_node: Node3D, sky_ref: SkyAndLight) -> void:
	_zone = z
	sky = sky_ref
	_rng.seed = hash(z.id) + Game.data.clock_minutes
	_chimneys = zone_node.get_meta("chimneys", PackedVector3Array()) if zone_node else PackedVector3Array()
	for b in _birds:
		b.node.queue_free()
	_birds.clear()
	_refresh()

func _active() -> bool:
	return _zone != null and Settings.quality != "low" and _zone.kind != "interior" and not _zone.dark

func _refresh() -> void:
	var on := _active()
	if not on:
		_smoke.emitting = false
		for b in _birds:
			b.node.queue_free()
		_birds.clear()
		return
	while _birds.size() < MAX_BIRDS:
		var mi := MeshInstance3D.new()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.visible = false
		add_child(mi)
		var mat := ShaderMaterial.new()
		mat.shader = preload("res://art/shaders/bird.gdshader")
		mat.set_shader_parameter("phase", _rng.randf() * TAU)
		mi.material_override = mat
		_birds.append({"node": mi, "kind": "", "vel": Vector3.ZERO, "wait": _rng.randf_range(0.0, 6.0), "alive": false, "base_y": 0.0, "wob": _rng.randf() * TAU})
	_update_smoke()

## How many birds may be up at once, and of which kinds, for the time and weather.
func _wanted() -> Array:
	var ph := Game.phase()
	var w := sky.weather if sky else "clear"
	if w == "downpour" or (w == "frost" and ph == "night"):
		return [0, []]
	if ph in ["dusk", "night"]:
		return [0 if w == "gale" else (3 if ph == "dusk" else 2), ["bat"]]
	var coast := _zone.stage in COAST
	var n := 5 if coast else 4
	if w in ["fog", "drizzle"]:
		n = 2
	if w == "gale":
		n = 3 if coast else 0  # only gulls ride a gale
	var wild := RewildScene.bird_bonus(_zone)  # a rewilded site brings the songbirds back
	if wild > 0 and n > 0:
		return [mini(MAX_BIRDS, n + wild), ["gull", "songbird"] if coast else ["rook", "songbird", "songbird"]]
	return [n, ["gull"] if coast else ["rook", "rook", "songbird"]]

func _process(delta: float) -> void:
	if not _active() or sky == null or sky.follow == null:
		return
	_tick += 1
	if _tick % 90 == 0:
		_update_smoke()
	var centre := sky.follow.global_position
	var want: Array = _wanted()
	var flying := 0
	for b in _birds:
		if b.alive:
			flying += 1
	for b in _birds:
		var node: MeshInstance3D = b.node
		if not b.alive:
			b.wait -= delta
			if b.wait <= 0.0 and flying < int(want[0]):
				_launch(b, want[1], centre)
				flying += 1
			continue
		var vel: Vector3 = b.vel
		var p := node.global_position + vel * delta
		b.wob += delta * (5.0 if b.kind == "bat" else 1.2)
		p.y = b.base_y + sin(b.wob) * (0.35 if b.kind == "bat" else 0.15)
		if b.kind == "bat":
			p.z += cos(b.wob * 1.3) * delta * 2.2  # jinking after moths
		node.global_position = p
		if absf(p.x - centre.x) > RANGE + 2.0 or absf(p.z - centre.z) > RANGE:
			b.alive = false
			node.visible = false
			b.wait = _rng.randf_range(2.0, 9.0)

func _launch(b: Dictionary, kinds: Array, centre: Vector3) -> void:
	var kind: String = kinds[_rng.randi() % kinds.size()]
	var spec: Array = KINDS[kind]
	var node: MeshInstance3D = b.node
	node.mesh = _bird_mesh(kind)
	var mat := node.material_override as ShaderMaterial
	var rate: float = spec[3]
	if kind == "bat" and Settings.reduce_flashing:
		rate *= 0.5  # a slower flutter: less flicker
	mat.set_shader_parameter("rate", rate)
	mat.set_shader_parameter("amp", spec[4])
	mat.set_shader_parameter("glide", spec[5])
	mat.set_shader_parameter("dim", 0.55 if Game.phase() in ["dusk", "night", "dawn"] else 1.0)
	var dir := 1.0 if _rng.randf() < 0.5 else -1.0
	var speed := _rng.randf_range(spec[6], spec[7])
	b.kind = kind
	b.vel = Vector3(dir * speed, 0, _rng.randf_range(-0.6, 0.6))
	b.base_y = centre.y + (2.6 if kind == "bat" else SKY_HEIGHT) + _rng.randf_range(-0.6, 1.2)
	node.global_position = Vector3(centre.x - dir * RANGE, b.base_y, centre.z + _rng.randf_range(-7.0, 4.0))
	node.basis = Basis.looking_at(b.vel.normalized(), Vector3.UP)
	b.alive = true
	node.visible = true

## A flat bird in the xz plane, head towards -z, wings along x (the shader lifts the wingtips).
func _bird_mesh(kind: String) -> ArrayMesh:
	if _meshes.has(kind):
		return _meshes[kind]
	var spec: Array = KINDS[kind]
	var body: Color = spec[0]
	var wing: Color = spec[1]
	var s: float = spec[2]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := Vector3.UP
	var tris := [
		# body: a slim diamond
		[Vector3(0, 0, -0.32 * s), Vector3(0.07 * s, 0, 0), Vector3(-0.07 * s, 0, 0), body],
		[Vector3(0.07 * s, 0, 0), Vector3(0, 0, 0.4 * s), Vector3(-0.07 * s, 0, 0), body],
		# wings, swept back a little; tips darker on gulls
		[Vector3(0.06 * s, 0, -0.1 * s), Vector3(0.5 * s, 0, 0.12 * s), Vector3(0.06 * s, 0, 0.12 * s), wing],
		[Vector3(-0.06 * s, 0, -0.1 * s), Vector3(-0.06 * s, 0, 0.12 * s), Vector3(-0.5 * s, 0, 0.12 * s), wing],
	]
	if kind == "bat":
		tris[2] = [Vector3(0.06 * s, 0, -0.12 * s), Vector3(0.5 * s, 0, 0.0), Vector3(0.06 * s, 0, 0.16 * s), wing]
		tris[3] = [Vector3(-0.06 * s, 0, -0.12 * s), Vector3(-0.06 * s, 0, 0.16 * s), Vector3(-0.5 * s, 0, 0.0), wing]
	for t in tris:
		for i in 3:
			st.set_color(t[3])
			st.set_normal(n)
			st.add_vertex(t[i])
	if kind == "gull":
		for sx in [1.0, -1.0]:
			var a := Vector3(sx * 0.4 * s, 0.001, 0.08 * s)
			for v in [a, Vector3(sx * 0.5 * s, 0.001, 0.12 * s), Vector3(sx * 0.38 * s, 0.001, 0.12 * s)]:
				st.set_color(Color("2a2b31"))
				st.set_normal(n)
				st.add_vertex(v)
	var mesh := st.commit()
	_meshes[kind] = mesh
	return mesh

# --- chimney smoke ----------------------------------------------------------------

## Smoke from the chimneys nearest the player: more at dusk and night and in a frost, thin in the rain,
## blown sideways in a gale.
func _update_smoke() -> void:
	if _chimneys.is_empty() or sky == null or not _active():
		_smoke.emitting = false
		return
	var centre := sky.follow.global_position if sky.follow else Vector3.ZERO
	var near := Array(_chimneys)
	if near.size() > MAX_SMOKING:
		near.sort_custom(func(a: Vector3, b: Vector3): return _flat_d2(a, centre) < _flat_d2(b, centre))
		near.resize(MAX_SMOKING)
	_smoke.emission_points = PackedVector3Array(near)
	var ph := Game.phase()
	var s: float = {"dawn": 0.8, "day": 0.55, "dusk": 1.0, "night": 0.85}.get(ph, 0.7)
	var frost := sky.fx[SkyAndLight.FX_FROST]
	var gale := sky.fx[SkyAndLight.FX_SLANT]
	s += 0.45 * frost
	s *= 1.0 - 0.4 * sky.fx[SkyAndLight.FX_RAIN]
	var tint: Color = {"dawn": Color(0.8, 0.76, 0.78), "day": Color(0.86, 0.86, 0.86), "dusk": Color(0.72, 0.66, 0.68), "night": Color(0.34, 0.37, 0.45)}.get(ph, Color(0.8, 0.8, 0.8))
	tint.a = clampf(0.3 * s, 0.0, 0.42)
	_smoke.color = tint
	_smoke.scale_amount_min = 0.7 + 0.4 * s
	_smoke.scale_amount_max = 1.0 + 0.7 * s
	_smoke.gravity = Vector3(3.2 * gale, 0.05, 0.4 * gale)
	_smoke.emitting = true

static func _flat_d2(a: Vector3, b: Vector3) -> float:
	return (a.x - b.x) * (a.x - b.x) + (a.z - b.z) * (a.z - b.z)
