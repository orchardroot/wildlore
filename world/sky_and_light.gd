class_name SkyAndLight
extends Node3D
## Sun, ambient, fog, glow and weather particles, driven by the game clock and the zone's weather.

const PHASES := {
	# sun colour, sun energy, sun pitch, ambient colour, ambient energy, background, window glow
	"dawn": [Color("ffc59a"), 0.8, -22.0, Color("b9a3c9"), 0.32, Color("e7b7a0"), 0.6],
	"day": [Color("fff4e0"), 0.8, -52.0, Color("c3d4e6"), 0.26, Color("9fc3dc"), 0.0],
	"dusk": [Color("ffa36b"), 0.7, -18.0, Color("a98bb0"), 0.3, Color("d98f74"), 1.2],
	"night": [Color("8fa6d9"), 0.25, -40.0, Color("3b4a78"), 0.3, Color("1b2238"), 2.2],
}

var sun: DirectionalLight3D
var env: Environment
var weather := "clear"
var interior := false
var _rain: CPUParticles3D
var follow: Node3D

func _ready() -> void:
	sun = DirectionalLight3D.new()
	sun.directional_shadow_max_distance = 40.0
	sun.shadow_blur = 1.5
	sun.rotation_degrees = Vector3(-52, -35, 0)
	add_child(sun)
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.92
	env.glow_intensity = 0.35
	env.glow_bloom = 0.08
	env.glow_hdr_threshold = 0.95
	env.fog_enabled = true
	env.fog_density = 0.002
	env.adjustment_enabled = true
	env.adjustment_saturation = 1.0
	env.adjustment_contrast = 1.04
	we.environment = env
	add_child(we)
	apply_quality(Settings.quality)
	_rain = CPUParticles3D.new()
	_rain.emitting = false
	_rain.amount = 600
	_rain.lifetime = 0.9
	_rain.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	_rain.emission_box_extents = Vector3(14, 0.5, 10)
	_rain.direction = Vector3(0.15, -1, 0.05)
	_rain.spread = 3.0
	_rain.initial_velocity_min = 14.0
	_rain.initial_velocity_max = 17.0
	_rain.gravity = Vector3(0, -6, 0)
	var streak := QuadMesh.new()
	streak.size = Vector2(0.02, 0.38)
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.albedo_color = Color(0.8, 0.86, 0.95, 0.45)
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	streak.material = rm
	_rain.mesh = streak
	add_child(_rain)

func set_weather(w: String, is_interior: bool) -> void:
	weather = w
	interior = is_interior
	var raining := w in ["drizzle", "downpour"] and not interior
	_rain.emitting = raining
	_rain.amount = 1400 if w == "downpour" else 450
	var foliage_wind := 0.035
	if w == "gale":
		foliage_wind = 0.09
	if Meshes.foliage:
		Meshes.foliage.set_shader_parameter("wind_strength", foliage_wind)
	apply_time(Game.data.clock_minutes)

func apply_time(minutes: int) -> void:
	var ph := GameClock.phase(minutes)
	var p: Array = PHASES[ph]
	var sun_col: Color = p[0]
	var sun_e: float = p[1]
	var amb: Color = p[3]
	var amb_e: float = p[4]
	var bg: Color = p[5]
	var fog_d := 0.002
	match weather:
		"drizzle":
			sun_e *= 0.7
			amb = amb.lerp(Color("a7b0bd"), 0.4)
			fog_d = 0.006
		"downpour":
			sun_e *= 0.45
			amb = amb.lerp(Color("8d97a6"), 0.5)
			fog_d = 0.009
		"fog":
			sun_e *= 0.55
			amb = amb.lerp(Color("c9ccd0"), 0.5)
			fog_d = 0.06
		"frost":
			sun_col = sun_col.lerp(Color("dfe9ff"), 0.5)
		"sunshine":
			sun_e *= 1.2
			sun_col = sun_col.lerp(Color("ffe2a8"), 0.3)
	if interior:
		sun_e = 0.55
		amb = Color("e8d2b0")
		amb_e = 0.32
		sun_col = Color("ffe6c4")
		fog_d = 0.0
		bg = Color("0e0f13")
	sun.light_color = sun_col
	sun.light_energy = sun_e
	sun.rotation_degrees.x = p[2]
	env.ambient_light_color = amb
	env.ambient_light_energy = amb_e
	env.background_color = bg
	env.fog_light_color = bg.lerp(amb, 0.5).darkened(0.25)
	env.fog_density = fog_d
	env.fog_enabled = fog_d > 0.0
	if Meshes.glow:
		Meshes.glow.emission_energy_multiplier = 0.0 if interior else p[6]
		Meshes.glow.albedo_color = Color("3a4658") if p[6] == 0.0 else Color("ffd98a")

func _process(_delta: float) -> void:
	if follow:
		_rain.global_position = follow.global_position + Vector3(0, 9, 2)
	if Engine.get_process_frames() % 30 == 0:
		apply_time(Game.data.clock_minutes)

## Low: no shadows or glow. Medium: 2-split shadows and glow. High: 4-split shadows. Safe to call live.
func apply_quality(q: String) -> void:
	sun.shadow_enabled = q != "low"
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if q == "high" else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	env.glow_enabled = q != "low"
