extends TestCase

func test_step_and_dirs() -> void:
	assert_eq(GridMotion.step(Vector2i(3, 3), "up"), Vector2i(3, 2))
	assert_eq(GridMotion.step(Vector2i(3, 3), "down"), Vector2i(3, 4))
	assert_eq(GridMotion.step(Vector2i(3, 3), "left"), Vector2i(2, 3))
	assert_eq(GridMotion.step(Vector2i(3, 3), "right"), Vector2i(4, 3))
	assert_eq(GridMotion.dir_vec("nope"), Vector2i.ZERO)

func test_facing_from() -> void:
	assert_eq(GridMotion.facing_from(Vector2i(0, -1)), "up")
	assert_eq(GridMotion.facing_from(Vector2i(1, 0)), "right")
	assert_eq(GridMotion.facing_from(Vector2i(-3, 1)), "left")
	assert_eq(GridMotion.facing_from(Vector2i(0, 2)), "down")

func test_edge_side() -> void:
	assert_eq(GridMotion.edge_side(Vector2i(4, -1), 10, 8), "north")
	assert_eq(GridMotion.edge_side(Vector2i(4, 8), 10, 8), "south")
	assert_eq(GridMotion.edge_side(Vector2i(-1, 3), 10, 8), "west")
	assert_eq(GridMotion.edge_side(Vector2i(10, 3), 10, 8), "east")
	assert_eq(GridMotion.edge_side(Vector2i(4, 3), 10, 8), "")

func test_ledge_hop_arc_has_no_drift() -> void:
	var a := Vector3(1.5, 0, 1.5)
	var b := Vector3(1.5, 0, 3.5)
	assert_eq(Player.hop_pos(a, b, 0.0), a)
	assert_true(Player.hop_pos(a, b, 1.0).is_equal_approx(b))
	var mid := Player.hop_pos(a, b, 0.5)
	assert_near(mid.z, 2.5, 0.001)
	assert_true(mid.y > 0.2, "hops up in the middle")

func test_sky_quality_applies_live() -> void:
	var s := SkyAndLight.new()
	s.sun = DirectionalLight3D.new()
	s.env = Environment.new()
	s.apply_quality("low")
	assert_false(s.sun.shadow_enabled)
	assert_false(s.env.glow_enabled)
	s.apply_quality("high")
	assert_true(s.sun.shadow_enabled)
	assert_eq(s.sun.directional_shadow_mode, DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS)
	s.sun.free()
	s.free()
