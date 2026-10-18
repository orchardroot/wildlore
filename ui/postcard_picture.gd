class_name PostcardPicture
extends RefCounted
## The picture side of a postcard: the real place, built from its zone and photographed once in warm light from
## the card's `view` ({x, y} focus tile, `yaw` degrees round from the south, `dist`, `height`, `fov`, `light`
## "golden" | "day" | "blue"). Rendered into a throwaway SubViewport, copied to a texture and freed, so nothing
## keeps rendering while you read. Cached per card for the session.

const DEFAULT_VIEW := {"yaw": 0.0, "dist": 20.0, "height": 13.0, "fov": 36.0, "light": "golden"}
## sun colour, sun energy, sun pitch, ambient colour, ambient energy, saturation, contrast, exposure
const LIGHTS := {
	"golden": [Color("ffc98f"), 1.05, -24.0, Color("b7a6c6"), 0.42, 1.18, 1.1, 0.92],
	"day": [Color("fff1da"), 0.85, -48.0, Color("c3d4e6"), 0.3, 1.2, 1.12, 0.9],
	"blue": [Color("ffd2a6"), 0.55, -12.0, Color("8d93c4"), 0.5, 1.1, 1.06, 1.0],
}
## sky top, horizon
const SKIES := {
	"golden": [Color("7f9fcc"), Color("f6d2a4")],
	"day": [Color("6f9fd6"), Color("dde9f0")],
	"blue": [Color("4f5f9a"), Color("e7b49a")],
}
const MAX_CACHE := 6

static var _cache := {}
static var _order: Array = []

## A texture of the card's place, or null where nothing can render (headless test runs).
static func render(host: Node, c: Dictionary, size: Vector2i) -> Texture2D:
	var id := str(c.get("id", ""))
	if _cache.has(id):
		return _cache[id]
	if DisplayServer.get_name() == "headless" or not FileAccess.file_exists("res://data/zones/%s.json" % c.get("zone", "")):
		return null
	var vp := SubViewport.new()
	vp.size = size
	vp.own_world_3d = true
	vp.msaa_3d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	host.add_child(vp)
	var z := ZoneData.load_id(str(c.zone))
	vp.add_child(ZoneBuilder.build(z))
	var view: Dictionary = DEFAULT_VIEW.duplicate()
	view.merge(c.get("view", {}), true)
	_light(vp, view)
	var cam := Camera3D.new()
	cam.fov = float(view.fov)
	vp.add_child(cam)
	var focus := Vector3(float(view.get("x", z.width / 2.0)) + 0.5, 0.0, float(view.get("y", z.height / 2.0)) + 0.5)
	var fp := Vector2i(int(focus.x), int(focus.z))
	focus.y = ZoneBuilder.ground_y(z, fp) if z.in_bounds(fp) else 0.0
	var away := Vector3(0, 0, float(view.dist)).rotated(Vector3.UP, deg_to_rad(float(view.yaw)))
	cam.position = focus + away + Vector3(0, float(view.height), 0)
	cam.look_at(focus + Vector3(0, float(view.get("look_up", 1.0)), 0))
	cam.current = true
	for i in 4:  # the zone's first frames settle (water, foliage, shadows) before the shot
		await RenderingServer.frame_post_draw
	if not is_instance_valid(vp):
		return null
	var img := vp.get_texture().get_image()
	vp.queue_free()
	var tex := ImageTexture.create_from_image(img)
	_cache[id] = tex
	_order.append(id)
	if _order.size() > MAX_CACHE:
		_cache.erase(_order.pop_front())
	return tex

static func _light(vp: SubViewport, view: Dictionary) -> void:
	var l: Array = LIGHTS.get(str(view.light), LIGHTS.golden)
	var sun := DirectionalLight3D.new()
	sun.light_color = l[0]
	sun.light_energy = l[1]
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 60.0
	sun.shadow_blur = 1.5
	sun.rotation_degrees = Vector3(l[2], float(view.yaw) - 40.0, 0)
	vp.add_child(sun)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY  # a painted sky behind the far edge of the zone
	var sky_mat := ProceduralSkyMaterial.new()
	var sky_cols: Array = SKIES.get(str(view.light), SKIES.golden)
	sky_mat.sky_top_color = sky_cols[0]
	sky_mat.sky_horizon_color = sky_cols[1]
	sky_mat.ground_horizon_color = sky_cols[1]
	sky_mat.ground_bottom_color = sky_cols[1].darkened(0.2)
	sky_mat.sun_angle_max = 0.0
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = l[3]
	env.ambient_light_energy = l[4]
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = l[7]
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.1
	env.glow_hdr_threshold = 0.9
	env.fog_enabled = true
	env.fog_density = 0.004
	env.fog_sky_affect = 0.0
	env.fog_light_color = Color("e8c9a8")
	env.adjustment_enabled = true
	env.adjustment_saturation = l[5]
	env.adjustment_contrast = l[6]
	we.environment = env
	vp.add_child(we)
