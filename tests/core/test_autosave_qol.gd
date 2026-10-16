extends TestCase

func test_toast_signal_fires_only_when_a_save_happens() -> void:
	var g: Node = (Engine.get_main_loop() as SceneTree).root.get_node_or_null("Game")
	if g == null:
		return
	var old_dir: String = g.save_dir
	var old_on: bool = g.autosave_enabled
	g.save_dir = "user://test_autosave_toast"
	var seen := [0]
	var cb := func(): seen[0] += 1
	g.autosaved.connect(cb)
	g.autosave_enabled = false
	g.autosave()
	assert_eq(seen[0], 0, "autosave off: no save, no toast")
	g.autosave_enabled = true
	g.autosave()
	assert_eq(seen[0], 1, "toast signal on a real save")
	g._on_battle_started("wild")
	g.autosave()
	assert_eq(seen[0], 1, "nothing mid-battle")
	g._on_battle_ended({})
	g.autosaved.disconnect(cb)
	g.save_dir = old_dir
	g.autosave_enabled = old_on
