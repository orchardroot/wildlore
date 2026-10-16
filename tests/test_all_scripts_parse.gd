extends TestCase
## Every game script must load: a parse error in a screen only shows up when that screen opens.

func _scripts(dir: String, out: Array) -> void:
	for d in DirAccess.get_directories_at(dir):
		if d.begins_with(".") or d in ["addons", "build"]:
			continue
		_scripts(dir.path_join(d), out)
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))

func test_every_game_script_parses() -> void:
	var paths := []
	for top in ["res://core", "res://ui", "res://world", "res://battle", "res://battle_ui", "res://story", "res://data_api"]:
		_scripts(top, paths)
	assert_true(paths.size() > 50, "found the scripts")
	for p in paths:
		var s: GDScript = load(p)
		assert_true(s != null and s.can_instantiate(), "%s parses" % p)
