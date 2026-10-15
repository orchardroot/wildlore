extends TestCase
## Plan 6 audio: new sfx and music exist, are the right length, peak sensibly, and loop cleanly.

func test_p6_ids_registered_and_files_exist() -> void:
	for id in AudioIds.P6_SFX:
		assert_true(AudioIds.sfx_exists(id), id + " sfx registered and present")
		assert_has(SfxRecipes.ids(), id)
	for id in AudioIds.P6_MUSIC_LOOPING + AudioIds.P6_MUSIC_STINGS:
		assert_true(AudioIds.music_exists(id), id + " music present")
		assert_has(load("res://tools/sfxgen.gd").MUSIC_IDS, id)

func test_p6_sfx_peak_and_ending() -> void:
	for id in AudioIds.P6_SFX:
		var buf := SfxRecipes.render(id)
		var p := Synth.peak(buf)
		assert_true(p >= 0.2 and p <= 0.95, "%s peak %s" % [id, str(p)])
		assert_true(Synth.rms(buf) > 0.01, id + " not silent")
		assert_near(buf[buf.size() - 1], 0.0, 0.01, id + " ends at zero")
		assert_true(SfxRecipes.render(id) == buf, id + " deterministic")

func test_p6_music_peak_length_and_loop_seam() -> void:
	for id in AudioIds.P6_MUSIC_LOOPING + AudioIds.P6_MUSIC_STINGS:
		var c: Composer = load("res://tools/music/%s.gd" % id).build()
		assert_true(c.errors.is_empty(), id + " bar lengths: " + str(c.errors))
		var buf := c.render(22050)
		var secs := buf.size() / 22050.0
		var p := Synth.peak(buf)
		assert_true(p >= 0.2 and p <= 0.95, "%s peak %s" % [id, str(p)])
		if id in AudioIds.P6_MUSIC_LOOPING:
			assert_true(c.loop, id + " loops")
			assert_true(secs >= 30.0 and secs <= 60.0, "%s length %s" % [id, str(secs)])
			assert_true(absf(buf[0]) < 0.05, "%s starts near zero (%s)" % [id, str(buf[0])])
			assert_true(absf(buf[buf.size() - 1]) < 0.05, "%s ends near zero (%s)" % [id, str(buf[buf.size() - 1])])
		else:
			assert_true(not c.loop, id + " does not loop")
			if id == "ending":
				assert_true(secs >= 60.0 and secs <= 90.0, "%s length %s" % [id, str(secs)])
			else:
				assert_true(secs >= 60.0 and secs <= 120.0, "%s length %s" % [id, str(secs)])
			assert_near(buf[buf.size() - 1], 0.0, 0.01, id + " ends at zero")
		var s: AudioStreamWAV = load("res://audio/music/%s.wav" % id)
		assert_near(s.get_length(), secs, 0.05, id + " file length matches the render")
		assert_eq(s.loop_mode, AudioStreamWAV.LOOP_FORWARD if id in AudioIds.P6_MUSIC_LOOPING else AudioStreamWAV.LOOP_DISABLED, id + " loop mode")

func test_p6_tracks_are_distinct() -> void:
	var seen := {}
	var ids: Array = AudioIds.M2_MUSIC_LOOPING + AudioIds.M3_MUSIC_LOOPING + AudioIds.P5_MUSIC_LOOPING + AudioIds.P6_MUSIC_LOOPING + AudioIds.P6_MUSIC_STINGS
	for id in ids:
		var buf: PackedFloat32Array = load("res://tools/music/%s.gd" % id).build().render(8000)
		var h := hash(buf)
		assert_true(not seen.has(h), "%s differs from %s" % [id, str(seen.get(h, ""))])
		seen[h] = id
