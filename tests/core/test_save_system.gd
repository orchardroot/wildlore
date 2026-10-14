extends TestCase

var dir := "user://test_saves_%d" % Time.get_ticks_usec()

func _wipe() -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
	DirAccess.remove_absolute(dir)

func _write_raw(name: String, text: String) -> void:
	var f := FileAccess.open(dir.path_join(name), FileAccess.WRITE)
	f.store_string(text)
	f.close()

func test_round_trip() -> void:
	assert_eq(SaveSystem.save("slot1", {"town": "macclesfield", "badges": 0}, dir), OK)
	var back := SaveSystem.load_slot("slot1", dir)
	assert_eq(back.town, "macclesfield")
	assert_eq(int(back.version), SaveSystem.VERSION)
	_wipe()

func test_second_save_keeps_a_backup() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	SaveSystem.save("slot1", {"n": 2}, dir)
	assert_true(FileAccess.file_exists(dir.path_join("slot1.json.bak")))
	assert_eq(int(SaveSystem.load_slot("slot1", dir).n), 2)
	_wipe()

func test_corrupt_save_falls_back_to_backup() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	SaveSystem.save("slot1", {"n": 2}, dir)
	_write_raw("slot1.json", "{not json")
	var back := SaveSystem.load_slot("slot1", dir)
	assert_eq(int(back.n), 1)
	assert_true(back._recovered)
	_wipe()

func test_missing_save_is_empty() -> void:
	assert_eq(SaveSystem.load_slot("slot3", dir), {})

func test_unversioned_save_migrates() -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	_write_raw("auto.json", '{"town": "buxton"}')
	var back := SaveSystem.load_slot("auto", dir)
	assert_eq(int(back.version), 1)
	assert_eq(back.town, "buxton")
	_wipe()

func test_newer_save_is_flagged_not_dropped() -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	_write_raw("auto.json", '{"version": 99}')
	var back := SaveSystem.load_slot("auto", dir)
	assert_true(back.get("_too_new", false))
	_wipe()

func test_list_slots() -> void:
	SaveSystem.save("slot2", {}, dir)
	SaveSystem.save("auto", {}, dir)
	assert_eq(SaveSystem.list_slots(dir), ["auto", "slot2"])
	_wipe()

func test_no_temp_file_left_behind() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	assert_false(FileAccess.file_exists(dir.path_join("slot1.json.tmp")))
	_wipe()
