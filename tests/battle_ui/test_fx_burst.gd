extends TestCase

func test_burst_sparks_start_where_aimed() -> void:
	var root := (Engine.get_main_loop() as SceneTree).root
	var dio := Diorama.new()
	dio.position = Vector3(3, 0, -2)  # the stage need not sit at the origin
	root.add_child(dio)
	var fx := BattleFX.new()
	root.add_child(fx)
	fx.dio = dio
	await (Engine.get_main_loop() as SceneTree).process_frame
	var aim := Vector3(2.7, 1.5, -2.5)
	var before := dio.get_child_count()
	fx.burst(aim, Color.RED, 8)
	var sparks := dio.get_children().slice(before)
	assert_eq(sparks.size(), 8)
	for s in sparks:
		assert_true((s as Node3D).global_position.distance_to(aim) < 0.01, "spark starts on the target")
	dio.free()
	fx.free()
