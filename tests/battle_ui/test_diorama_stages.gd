extends TestCase

func test_every_stage_builds() -> void:
	for st in Diorama.STAGES:
		var d := Diorama.new()
		(Engine.get_main_loop() as SceneTree).root.add_child(d)
		d.build(st)
		assert_eq(d.stage, st)
		assert_true(d.props.get_child_count() > 0, "props for " + st)
		d.free()
