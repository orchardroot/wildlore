extends TestCase
## 4.1 regional themes: present, well-formed, loop cleanly, are distinct, and every zone that names one finds the file.

func test_regional_tracks_render_and_loop() -> void:
	for id in AudioIds.W41_MUSIC_LOOPING:
		assert_true(AudioIds.music_exists(id), id + " present")
		var c: Composer = load("res://tools/music/%s.gd" % id).build()
		assert_true(c.errors.is_empty(), id + " bar lengths: " + str(c.errors))
		var buf := c.render(22050)
		var secs := buf.size() / 22050.0
		assert_true(secs >= 30.0 and secs <= 60.0, "%s length %s" % [id, str(secs)])
		assert_true(Synth.peak(buf) <= 0.95, id + " peak")
		assert_true(absf(buf[0]) < 0.05 and absf(buf[buf.size() - 1]) < 0.05, id + " seam")
		var s: AudioStreamWAV = load("res://audio/music/%s.wav" % id)
		assert_eq(s.loop_mode, AudioStreamWAV.LOOP_FORWARD, id + " loop mode")

func test_regional_tracks_are_distinct() -> void:
	var seen := {}
	for id in AudioIds.W41_MUSIC_LOOPING:
		var h := hash(load("res://tools/music/%s.gd" % id).build().render(8000))
		assert_true(not seen.has(h), "%s differs from %s" % [id, str(seen.get(h, ""))])
		seen[h] = id

func test_zones_use_regional_tracks() -> void:
	var used := {}
	for f in DirAccess.get_files_at("res://data/zones"):
		if f.ends_with(".json"):
			var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/zones/" + f))
			if d is Dictionary and str(d.get("music", "")) in AudioIds.W41_MUSIC_LOOPING:
				used[d.music] = true
	for id in AudioIds.W41_MUSIC_LOOPING:
		assert_true(used.has(id), id + " is used by at least one zone")
