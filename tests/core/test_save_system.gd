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
	assert_eq(int(back.version), SaveSystem.VERSION)
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

func test_corrupt_main_is_not_rotated_over_good_backup() -> void:
	SaveSystem.save("slot1", {"n": 1}, dir)
	SaveSystem.save("slot1", {"n": 2}, dir)
	_write_raw("slot1.json", "{not json")
	SaveSystem.save("slot1", {"n": 3}, dir)
	_write_raw("slot1.json", "{not json")
	assert_eq(int(SaveSystem.load_slot("slot1", dir).n), 1)
	_wipe()

func test_underscore_keys_are_not_persisted() -> void:
	SaveSystem.save("slot1", {"n": 1, "_recovered": true}, dir)
	assert_false(SaveSystem.load_slot("slot1", dir).has("_recovered"))
	_wipe()

func _fresh_dir(name: String) -> String:
	var out := "user://test_saves_" + name
	if DirAccess.dir_exists_absolute(out):
		for f in DirAccess.get_files_at(out):
			DirAccess.remove_absolute(out.path_join(f))
	return out

func test_v1_save_migrates() -> void:
	var sd := _fresh_dir("v1")
	DirAccess.make_dir_recursive_absolute(sd)
	var f := FileAccess.open(SaveSystem.slot_path("1", sd), FileAccess.WRITE)
	f.store_string(JSON.stringify({"version": 1, "zone_id": "buxton", "party": [], "last_sanctuary": {"zone": "macclesfield", "pos": [0, 0]}}))
	f.close()
	var d := SaveSystem.load_slot("1", sd)
	assert_eq(int(d.version), 2)
	assert_eq(d.last_sanctuary.pos, [-1, -1], "the old [0,0] default becomes the spawn marker")
	assert_true(d.has("saved_at"))

func test_slots_independent() -> void:
	var sd := _fresh_dir("slots")
	for s in SaveSystem.SLOTS:
		SaveSystem.save(s, {"zone_id": "z_" + s, "play_seconds": 10.0, "badges": ["brook"]}, sd)
	for s in SaveSystem.SLOTS:
		assert_eq(SaveSystem.load_slot(s, sd).zone_id, "z_" + s)
	var info: Dictionary = SaveSystem.slot_info("2", sd)
	assert_true(info.ok)
	assert_eq(info.zone_id, "z_2")
	assert_eq(info.badges, 1)
	assert_false(SaveSystem.slot_info("3", _fresh_dir("empty")).exists)

func test_corrupt_slot_listed() -> void:
	var sd := _fresh_dir("corrupt")
	SaveSystem.save("1", {"zone_id": "a"}, sd)
	var f := FileAccess.open(SaveSystem.slot_path("2", sd), FileAccess.WRITE)
	f.store_string("{not json")
	f.close()
	var infos: Array = SaveSystem.slot_infos(sd)
	assert_eq(infos.size(), 4)
	assert_eq(infos[2].slot, "2")
	assert_true(infos[2].exists)
	assert_false(infos[2].ok)
	assert_eq(SaveSystem.newest_slot(sd), "1")

func test_newest_slot_by_time() -> void:
	var sd := _fresh_dir("newest")
	SaveSystem.save("3", {"zone_id": "a", "saved_at": 100.0}, sd)
	SaveSystem.save("auto", {"zone_id": "b", "saved_at": 50.0}, sd)
	assert_eq(SaveSystem.newest_slot(sd), "3")

func test_v1_badges_become_flags() -> void:
	var d := SaveSystem.migrate({"version": 1, "badges": ["brook"], "flags": {"starter": "kindlet"}})
	assert_true(d.flags.get("badge_brook", false))
	assert_true(d.flags.get("ch2_started", false))
	assert_eq(d.flags.starter, "kindlet")
