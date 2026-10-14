extends TestCase
## Every Audio.sfx("id") and play_music("id") literal in the game code must resolve to a generated file (or an alias).

func _gd_files(dir: String, out: Array) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for sub in d.get_directories():
		if sub not in ["tests", "tools", ".godot", ".claude", "addons"]:
			_gd_files(dir.path_join(sub), out)

func _ids(pattern: String) -> Dictionary:
	var re := RegEx.new()
	re.compile(pattern)
	var found := {}
	var files := []
	_gd_files("res://", files)
	for path in files:
		for m in re.search_all(FileAccess.get_file_as_string(path)):
			found[m.get_string(1)] = path
	return found

func test_every_sfx_id_exists() -> void:
	var ids := _ids("Audio\\.sfx\\(\"([a-z_]+)\"\\)")
	assert_true(ids.size() > 10, "found sfx calls")
	for id in ids:
		assert_true(AudioIds.sfx_exists(id), "sfx '%s' used in %s has no file or alias" % [id, ids[id]])

func test_every_music_id_exists() -> void:
	var ids := _ids("play_music\\(\"([a-z_]+)\"")
	for id in ids:
		assert_true(AudioIds.music_exists(id), "music '%s' used in %s has no file" % [id, ids[id]])

func test_battle_music_by_kind() -> void:
	assert_eq(AudioIds.battle_music({"kind": "wild"}), "battle_wild")
	assert_eq(AudioIds.battle_music({"kind": "trainer", "ai": "trainer"}), "battle_trainer")
	assert_eq(AudioIds.battle_music({"kind": "trainer", "ai": "keeper"}), "battle_keeper")
	assert_eq(AudioIds.battle_music({"kind": "trainer", "music": "title"}), "title")
	for id in ["battle_wild", "battle_trainer", "battle_keeper", "victory"]:
		assert_true(AudioIds.music_exists(id), id)
