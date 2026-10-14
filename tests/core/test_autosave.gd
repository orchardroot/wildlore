extends TestCase

func _game() -> Node:
	return (Engine.get_main_loop() as SceneTree).root.get_node_or_null("Game")

func test_autosave_on_zone_change() -> void:
	var g := _game()
	assert_true(g != null, "Game autoload present in tests")
	if g == null:
		return
	var d := "user://test_autosave"
	if DirAccess.dir_exists_absolute(d):
		for f in DirAccess.get_files_at(d):
			DirAccess.remove_absolute(d.path_join(f))
	var old_dir: String = g.save_dir
	var old_on: bool = g.autosave_enabled
	g.save_dir = d
	g.autosave_enabled = true
	g.data.zone_id = "buxton"
	g._on_zone_entered("buxton")
	assert_true(FileAccess.file_exists(SaveSystem.slot_path("auto", d)))
	g._on_battle_started("wild")
	g.data.zone_id = "macclesfield"
	g._on_zone_entered("macclesfield")
	assert_eq(SaveSystem.load_slot("auto", d).zone_id, "buxton", "no autosave mid-battle")
	g._on_battle_ended({})
	g.save_dir = old_dir
	g.autosave_enabled = old_on

func test_first_zone_after_load_or_new_game_does_not_autosave() -> void:
	var g := _game()
	if g == null:
		return
	var d := "user://test_autosave_skip"
	if DirAccess.dir_exists_absolute(d):
		for f in DirAccess.get_files_at(d):
			DirAccess.remove_absolute(d.path_join(f))
	var old_dir: String = g.save_dir
	var old_on: bool = g.autosave_enabled
	g.save_dir = d
	g.autosave_enabled = true
	g.skip_next_autosave = true
	g._on_zone_entered("macc_home")
	assert_false(FileAccess.file_exists(SaveSystem.slot_path("auto", d)), "skipped once")
	g._on_zone_entered("macclesfield")
	assert_true(FileAccess.file_exists(SaveSystem.slot_path("auto", d)), "then autosaves as normal")
	g.save_dir = old_dir
	g.autosave_enabled = old_on
