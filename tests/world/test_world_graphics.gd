extends TestCase
## World graphics (4.5): light easing through the day, the sun's swing, baked shade at the foot of walls, shore foam,
## room lights, and the Low setting that keeps today's look.

func _zone(rows: Array, props := [], kind := "town") -> ZoneData:
	return ZoneData.from_dict({"id": "gfx", "name": "GFX", "kind": kind, "rows": rows, "props": props, "warps": [],
		"edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [0, 0], "weather": {}})

func test_phase_mix_eases_across_each_change_only() -> void:
	assert_eq(SkyAndLight.phase_mix(12 * 60), ["day", "day", 0.0], "midday is plain day")
	assert_eq(SkyAndLight.phase_mix(2 * 60), ["night", "night", 0.0])
	var at := SkyAndLight.phase_mix(8 * 60)
	assert_eq(at[0], "dawn")
	assert_eq(at[1], "day")
	assert_near(at[2], 0.5, 0.001, "half way at the hour")
	var early := SkyAndLight.phase_mix(8 * 60 - 40)
	var late := SkyAndLight.phase_mix(8 * 60 + 40)
	assert_true(early[2] < 0.1 and late[2] > 0.9, "eases in and out (%.2f, %.2f)" % [early[2], late[2]])
	var dusk_night := SkyAndLight.phase_mix(21 * 60 - 10)
	assert_eq([dusk_night[0], dusk_night[1]], ["dusk", "night"])
	var night_dawn := SkyAndLight.phase_mix(5 * 60)
	assert_eq([night_dawn[0], night_dawn[1]], ["night", "dawn"])

func test_blended_phase_is_continuous_and_keeps_lamp_hours() -> void:
	var prev: Array = SkyAndLight.blended_phase(0)
	for m in range(1, GameClock.DAY):
		var p := SkyAndLight.blended_phase(m)
		assert_true(absf(p[1] - prev[1]) < 0.05, "sun energy never jumps (minute %d)" % m)
		assert_true(absf(p[2] - prev[2]) < 2.0, "sun pitch never jumps (minute %d)" % m)
		prev = p
	assert_eq(SkyAndLight.blended_phase(17 * 60 + 59)[6], SkyAndLight.PHASES.day[6], "lamps still off at 17:59")
	assert_eq(SkyAndLight.blended_phase(18 * 60)[6], SkyAndLight.PHASES.dusk[6], "and on at 18:00")

func test_sun_swings_east_to_west() -> void:
	assert_near(SkyAndLight.sun_yaw(12 * 60), -35.0, 0.001, "noon matches the old fixed sun")
	assert_true(SkyAndLight.sun_yaw(8 * 60) < SkyAndLight.sun_yaw(16 * 60))
	assert_true(SkyAndLight.sun_yaw(3 * 60) >= -70.0 and SkyAndLight.sun_yaw(23 * 60) <= 0.0)

func test_cloud_shadows_by_weather() -> void:
	assert_eq(SkyAndLight.cloud_shadows("clear", "night"), 0.0, "no cloud shadows by moonlight")
	assert_eq(SkyAndLight.cloud_shadows("fog", "day"), 0.0)
	assert_true(SkyAndLight.cloud_shadows("gale", "day") > SkyAndLight.cloud_shadows("downpour", "day"))

func test_shade_gathers_at_the_foot_of_buildings() -> void:
	var z := _zone(["BBB", "...", "..."], [{"type": "building", "x": 0, "y": 0, "w": 3, "h": 1}])
	var occ := ZoneBuilder.occluders(z)
	var p := Vector2i(1, 1)
	var gy := ZoneBuilder.ground_y(z, p)
	assert_near(ZoneBuilder.corner_ao(occ, z.width, p, Vector2i(0, 0), gy), 1.0, 0.001, "tucked against the wall")
	assert_near(ZoneBuilder.corner_ao(occ, z.width, p, Vector2i(0, 1), gy), 0.0, 0.001, "open a tile out")
	var far := Vector2i(1, 2)
	assert_near(ZoneBuilder.corner_ao(occ, z.width, far, Vector2i(1, 1), ZoneBuilder.ground_y(z, far)), 0.0, 0.001)

func test_ground_mesh_carries_shade_and_soft_marks() -> void:
	Meshes.materials()
	var root := ZoneBuilder.build(_zone(["BBB", "...", "..."], [{"type": "building", "x": 0, "y": 0, "w": 3, "h": 1}]))
	var mesh := (root.get_node("Ground") as MeshInstance3D).mesh as ArrayMesh
	var arrays := mesh.surface_get_arrays(0)
	var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
	assert_true(uvs.size() > 0, "the ground has UVs")
	var shaded := 0
	var soft := 0
	for uv in uvs:
		if uv.x > 0.5:
			shaded += 1
		if uv.y > 0.9:
			soft += 1
	assert_true(shaded > 0, "some ground sits in the walls' shade")
	assert_true(soft > 0, "grass is marked for mottling")
	root.free()

func test_water_knows_its_shore() -> void:
	var z := _zone(["....", ".~~~", ".~~~", ".~~~"])
	assert_eq(ZoneBuilder.shore_at(z, Vector2i(1, 1), Vector2i(0, 0)), 1.0, "the bank")
	assert_eq(ZoneBuilder.shore_at(z, Vector2i(2, 2), Vector2i(1, 1)), 0.0, "open water")
	assert_eq(ZoneBuilder.shore_at(z, Vector2i(3, 3), Vector2i(1, 1)), 0.0, "the zone's edge is more water")
	Meshes.materials()
	var root := ZoneBuilder.build(z)
	var water := root.get_node("Water") as MeshInstance3D
	assert_true(water.is_in_group(ZoneBuilder.WATER_GROUP), "SkyAndLight can find it")
	root.free()

func test_rooms_get_a_few_lights_and_caves_a_lantern() -> void:
	var room := _zone(["xxxxx", "x|||x", "x|||x", "xxxxx"], [{"type": "fireplace", "x": 2, "y": 1}, {"type": "window", "x": 1, "y": 1}], "interior")
	var plan := InteriorLight.plan(room)
	var kinds := plan.map(func(s): return s.kind)
	assert_eq(kinds, ["fire", "room", "window"])
	var many := []
	for i in 9:
		many.append({"type": "fireplace", "x": 1 + i % 3, "y": 1})
	assert_true(InteriorLight.plan(_zone(["xxxxx", "x|||x", "xxxxx"], many, "interior")).size() <= InteriorLight.MAX_LIGHTS)
	assert_true("room" in InteriorLight.plan(_zone(["xxxxx", "x|||x", "xxxxx"], many, "interior")).map(func(s): return s.kind),
		"the room light is never crowded out")
	var cave := ZoneData.from_dict({"id": "gfx_cave", "name": "Cave", "kind": "interior", "rows": ["xxx", "x|x", "xxx"], "props": [],
		"warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [1, 1], "weather": {}, "dark": true})
	assert_eq(InteriorLight.plan(cave).map(func(s): return s.kind), ["lantern"])
	var n := Node3D.new()
	assert_true(InteriorLight.dress(_zone(["..."]), n, null, "high") == null, "nothing outdoors")
	n.free()

func test_low_quality_turns_every_touch_off() -> void:
	Meshes.materials()
	var s := SkyAndLight.new()
	s.sun = DirectionalLight3D.new()
	s.env = Environment.new()
	s.apply_quality("medium")
	s.apply_touches()
	assert_eq(Meshes.ground.get_shader_parameter("ao"), 1.0)
	assert_eq(Meshes.ground.get_shader_parameter("detail"), 1.0)
	assert_true(float(Meshes.foliage.get_shader_parameter("gust")) > 0.0)
	s.apply_quality("low")
	s.apply_touches()
	assert_eq(Meshes.ground.get_shader_parameter("ao"), 0.0)
	assert_eq(Meshes.ground.get_shader_parameter("detail"), 0.0)
	assert_eq(Meshes.foliage.get_shader_parameter("gust"), 0.0)
	assert_eq(s.sun.shadow_blur, 1.5, "Low keeps the old shadow settings")
	s.sun.free()
	s.free()

func test_char_sprite_readable_look_toggles() -> void:
	var c := CharSprite.new()
	c.setup("angler")
	c.set_crisp(true)
	assert_true(c.material_override is ShaderMaterial)
	assert_eq((c.material_override as ShaderMaterial).get_shader_parameter("tex"), c.texture)
	c.set_crisp(false)
	assert_true(c.material_override == null, "Low: the plain sprite")
	c.free()
