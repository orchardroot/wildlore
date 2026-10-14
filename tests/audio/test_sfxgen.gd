extends TestCase

const EXPECTED := {
	"cursor": 0.06, "confirm": 0.16, "cancel": 0.16, "bump": 0.12, "door": 0.45, "step_grass": 0.12,
	"hit": 0.25, "hit_super": 0.4, "hit_weak": 0.22, "faint": 0.8, "snare_throw": 0.35, "snare_wobble": 0.4,
	"caught": 0.9, "level_up": 0.8, "heal": 0.9, "badge": 1.4, "evolve": 1.8,
}
const LOOPING := ["title", "town_cheshire", "route_forest", "route_moor", "battle_wild", "battle_trainer", "battle_keeper", "sanctuary"]

func test_sfx_length_peak_not_silent() -> void:
	for id in EXPECTED:
		var buf := SfxRecipes.render(id)
		var frames_expected: float = float(EXPECTED[id]) * SfxRecipes.SR
		assert_near(float(buf.size()), frames_expected, 1.0, id + " length")
		var p := Synth.peak(buf)
		assert_true(p >= 0.2 and p <= 0.95, "%s peak %s" % [id, str(p)])
		assert_true(Synth.rms(buf) > 0.01, id + " not silent")
		assert_near(buf[buf.size() - 1], 0.0, 0.01, id + " ends at zero")

func test_every_recipe_is_listed() -> void:
	assert_eq(SfxRecipes.ids().size(), EXPECTED.size())
	for id in EXPECTED:
		assert_has(SfxRecipes.ids(), id)

func test_sfx_generation_is_deterministic() -> void:
	for id in ["hit_super", "door", "evolve", "step_grass"]:
		assert_true(SfxRecipes.render(id) == SfxRecipes.render(id), id + " deterministic")

func test_stream_conversion() -> void:
	var s := Synth.to_stream(SfxRecipes.render("confirm"), SfxRecipes.SR)
	assert_eq(s.data.size(), SfxRecipes.render("confirm").size() * 2)
	assert_eq(s.loop_mode, AudioStreamWAV.LOOP_DISABLED)

func test_short_track_renders_and_is_deterministic() -> void:
	var c: Composer = load("res://tools/music/victory.gd").build()
	assert_true(c.errors.is_empty(), "victory melody bar lengths: " + str(c.errors))
	var a := c.render(11025)
	var b: PackedFloat32Array = load("res://tools/music/victory.gd").build().render(11025)
	assert_true(a == b, "music deterministic")
	assert_true(Synth.peak(a) <= 0.95 and Synth.peak(a) >= 0.2)

func test_music_loop_points_inside_data() -> void:
	for id in LOOPING:
		var path := "res://audio/music/%s.wav" % id
		assert_true(ResourceLoader.exists(path), id + " exists")
		var s: AudioStreamWAV = load(path)
		assert_eq(s.loop_mode, AudioStreamWAV.LOOP_FORWARD, id + " loops")
		# The importer may compress the data, so measure frames from the stream length, not the byte count.
		var secs := s.get_length()
		var frames := int(round(secs * s.mix_rate))
		assert_true(s.loop_begin >= 0 and s.loop_begin < s.loop_end, id + " begin < end")
		assert_true(s.loop_end <= frames, id + " end inside data")
		assert_true(secs >= 30.0 and secs <= 60.0, "%s length %s" % [id, str(secs)])
	var v: AudioStreamWAV = load("res://audio/music/victory.wav")
	assert_eq(v.loop_mode, AudioStreamWAV.LOOP_DISABLED)

func test_sfx_files_exist() -> void:
	for id in EXPECTED:
		assert_true(ResourceLoader.exists("res://audio/sfx/%s.wav" % id), id + " wav exists")
