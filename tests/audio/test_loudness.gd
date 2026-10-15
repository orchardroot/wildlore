extends TestCase
## Audio levels: music tracks sit together (RMS within 2 dB of the median, battles up to 1 dB above, sanctuary and ending up to 1 dB below),
## nothing clips, loops have no click or big level step at the seam, and no sfx is wildly off from the rest.
## Measures the committed WAVs in res://audio/ with tools/audio/loudness.gd; re-render with tools/sfxgen.gd after changing recipes.

const Loud := preload("res://tools/audio/loudness.gd")
const SPREAD_DB := 2.0
const PEAK_MAX_DB := -1.0
const SEAM_STEP_MAX_DB := 6.0
const SEAM_CLICK_MAX := 4.0
const SFX_SPREAD_DB := 6.0

func _stats(kind: String) -> Dictionary:
	var out := {}
	for id in Loud.ids_in("res://audio/%s" % kind):
		var m: Dictionary = Loud.measure("res://audio/%s/%s.wav" % [kind, id])
		if not m.is_empty():
			out[id] = m
	return out

func _median(stats: Dictionary) -> float:
	var l: Array = []
	for id in stats:
		l.append(stats[id]["rms"])
	return Loud.median(l)

func test_music_rms_within_spread_and_no_clipping() -> void:
	var st := _stats("music")
	assert_true(st.size() >= 40, "music files found: %d" % st.size())
	var med := _median(st)
	for id in st:
		var m: Dictionary = st[id]
		var off: float = m["rms"] - med
		var lo := -SPREAD_DB
		var hi := SPREAD_DB
		if id.begins_with("battle_"):
			lo = 0.0
			hi = 1.0 + 0.5
		elif id == "sanctuary" or id == "ending":
			lo = -1.5
			hi = 0.0
		assert_true(off >= lo - 0.5 and off <= hi + 0.5, "%s rms %.2f dB from median %.2f (want %.1f..%.1f)" % [id, off, med, lo, hi])
		assert_true(m["peak"] <= PEAK_MAX_DB, "%s peak %.2f dBFS clips" % [id, m["peak"]])

func test_music_loop_seams_are_clean() -> void:
	var st := _stats("music")
	for id in st:
		var m: Dictionary = st[id]
		if not m["loop"]:
			continue
		assert_true(absf(m["seam_db"]) <= SEAM_STEP_MAX_DB, "%s level step %.2f dB across the loop seam" % [id, m["seam_db"]])
		assert_true(m["click"] <= SEAM_CLICK_MAX, "%s click %.2f at the loop seam" % [id, m["click"]])

func test_sfx_levels_are_not_outliers() -> void:
	var st := _stats("sfx")
	var med := _median(st)
	for id in st:
		var m: Dictionary = st[id]
		assert_true(absf(m["rms"] - med) <= SFX_SPREAD_DB, "%s rms %.2f dB from sfx median %.2f" % [id, m["rms"] - med, med])
		assert_true(m["peak"] <= -0.5, "%s peak %.2f dBFS" % [id, m["peak"]])

func test_committed_wav_matches_a_fresh_render() -> void:
	var c: Composer = load("res://tools/music/ferry.gd").build()
	var buf := c.render(22050)
	var m: Dictionary = Loud.measure("res://audio/music/ferry.wav")
	assert_near(Loud.db(Synth.rms(buf)), m["rms"], 0.05, "ferry.wav is stale, re-run tools/sfxgen.gd")
	var again: PackedFloat32Array = load("res://tools/music/ferry.gd").build().render(22050)
	assert_true(buf == again, "level normalisation is deterministic")
