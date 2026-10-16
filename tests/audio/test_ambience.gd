extends TestCase
## Ambience: which bed and weather layer each kind of zone gets, music muffling indoors, town accents,
## footstep surfaces, interaction sounds, the ambience volume setting, and the levels of the rendered loops.

const Loud := preload("res://tools/audio/loudness.gd")
const TMP := "user://test_settings_ambience.json"

func _zone(kind: String, stage := "", extra := {}) -> ZoneData:
	var d := {"id": "t", "name": "T", "kind": kind, "stage": stage, "rows": ["...."], "props": [], "warps": [], "edges": {},
		"npcs": [], "encounters": {}, "signs": [], "spawn": [0, 0], "weather": {}}
	d.merge(extra, true)
	return ZoneData.from_dict(d)

func _bed(kind: String, stage := "", phase := "day", extra := {}) -> String:
	return Ambience.pick(_zone(kind, stage, extra), "clear", phase, "clear").bed

# --- beds -------------------------------------------------------------------------------------------------------

func test_bed_by_stage_outdoors() -> void:
	assert_eq(_bed("route", "coast"), "amb_coast")
	assert_eq(_bed("town", "docks"), "amb_coast")
	assert_eq(_bed("town", "coast"), "amb_coast")
	assert_eq(_bed("town", "city"), "amb_city")
	for st in ["moor", "bog", "mountain", "quarry"]:
		assert_eq(_bed("route", st), "amb_moor", st)
	for st in ["forest", "grass", "valley", ""]:
		assert_eq(_bed("route", st), "amb_country", st)
	for st in ["town", "castle", "valley", ""]:
		assert_eq(_bed("town", st), "amb_country", st)

func test_bed_indoors() -> void:
	assert_eq(_bed("interior"), "amb_interior")
	assert_eq(_bed("interior", "city"), "amb_interior", "a city interior is still a room")
	assert_eq(_bed("interior", "cave"), "amb_cave")
	assert_eq(_bed("interior", "", "day", {"dark": true}), "amb_cave", "dark zones are caves")

func test_night_swaps_birdsong_for_crickets() -> void:
	assert_eq(_bed("route", "grass", "night"), "amb_night")
	assert_eq(_bed("town", "town", "night"), "amb_night")
	assert_eq(_bed("route", "grass", "dusk"), "amb_country", "birds still about at dusk")
	assert_eq(_bed("route", "coast", "night"), "amb_coast", "the sea does not sleep")
	assert_eq(_bed("town", "city", "night"), "amb_city")
	assert_eq(_bed("interior", "", "night"), "amb_interior")

func test_zone_override() -> void:
	assert_eq(_bed("route", "grass", "day", {"ambience": "amb_moor"}), "amb_moor")
	assert_eq(_bed("route", "grass", "day", {"ambience": "none"}), "", "none switches it off")

func test_every_bed_and_layer_has_a_file() -> void:
	for id in Ambience.BEDS + Ambience.LAYERS + ["train_run", "crossing_alarm"]:
		assert_true(ResourceLoader.exists("res://audio/ambience/%s.wav" % id), id + " rendered")

# --- weather -----------------------------------------------------------------------------------------------------

func test_weather_layers_outdoors() -> void:
	var z := _zone("route", "grass")
	assert_eq(Ambience.pick(z, "drizzle", "day", "drizzle").layer, "amb_rain_light")
	assert_eq(Ambience.pick(z, "downpour", "day", "downpour").layer, "amb_rain_heavy")
	assert_eq(Ambience.pick(z, "gale", "day", "gale").layer, "amb_gale")
	for w in ["clear", "sunshine", "fog", "frost"]:
		assert_eq(Ambience.pick(z, w, "day", w).layer, "", w)

func test_rain_on_the_roof_indoors() -> void:
	var room := _zone("interior")
	assert_eq(Ambience.pick(room, "clear", "day", "drizzle").layer, "amb_rain_roof")
	assert_eq(Ambience.pick(room, "clear", "day", "downpour").layer, "amb_rain_roof")
	assert_eq(Ambience.pick(room, "clear", "day", "gale").layer, "", "no rain, no roof")
	assert_eq(Ambience.pick(room, "clear", "day", "clear").layer, "")
	assert_eq(Ambience.pick(_zone("interior", "cave"), "clear", "day", "downpour").layer, "", "no roof in a cave")

# --- music muffling ------------------------------------------------------------------------------------------------

func test_music_muffled_only_in_rooms_without_their_own_tune() -> void:
	assert_true(Ambience.pick(_zone("interior"), "clear", "day", "clear").muffle, "inherits the town tune")
	assert_false(Ambience.pick(_zone("interior", "", {"music": "sanctuary"}), "clear", "day", "clear").muffle)
	assert_false(Ambience.pick(_zone("town", "town"), "clear", "day", "clear").muffle)
	assert_false(Ambience.pick(_zone("route", "grass"), "clear", "day", "clear").muffle)

# --- town accents ------------------------------------------------------------------------------------------------

func test_town_accents() -> void:
	var cath := {"props": [{"type": "building", "style": "cathedral", "x": 0, "y": 0}]}
	assert_eq(Ambience.accents(_zone("town", "city", cath)), ["bell"])
	assert_eq(Ambience.accents(_zone("town", "docks")), ["horn"])
	var both := _zone("town", "docks", cath)
	assert_has(Ambience.accents(both), "bell")
	assert_has(Ambience.accents(both), "horn")
	assert_eq(Ambience.accents(_zone("town", "town")), [])
	assert_eq(Ambience.accents(_zone("route", "coast", cath)), [], "only towns")
	assert_eq(Ambience.accents(_zone("interior", "docks")), [], "not indoors")

func test_bell_tolls_on_the_hour() -> void:
	assert_true(Ambience.hour_struck(599, 600))
	assert_true(Ambience.hour_struck(1439, 0), "midnight")
	assert_true(Ambience.hour_struck(598, 601), "a skipped minute still counts")
	assert_false(Ambience.hour_struck(600, 600), "only once")
	assert_false(Ambience.hour_struck(600, 601))
	assert_false(Ambience.hour_struck(480, 900), "a big jump (sleeping, loading) is not a toll")

# --- footsteps ---------------------------------------------------------------------------------------------------

func test_footstep_surfaces() -> void:
	assert_eq(Ambience.footstep("path", "clear", false, false), "step_path")
	for t in ["road", "cobbles", "platform", "level_crossing", "floor_tile"]:
		assert_eq(Ambience.footstep(t, "clear", false, false), "step_stone", t)
	assert_eq(Ambience.footstep("floor_wood", "clear", true, false), "step_wood")
	assert_eq(Ambience.footstep("sand", "clear", false, false), "step_sand")
	assert_eq(Ambience.footstep("grass", "clear", false, false), "step_soft")
	assert_eq(Ambience.footstep("flowers", "clear", false, false), "step_soft")
	assert_eq(Ambience.footstep("shallow", "clear", false, false), "step_wet")

func test_footsteps_leave_special_tiles_to_their_own_sounds() -> void:
	for t in ["tall_grass", "scree", "bog", "deep_water", "void", ""]:
		assert_eq(Ambience.footstep(t, "clear", false, false), "", t)
		assert_eq(Ambience.footstep(t, "clear", false, true), "", t + " on the bike")

func test_wet_footsteps_in_rain() -> void:
	for t in ["path", "road", "grass"]:
		assert_eq(Ambience.footstep(t, "drizzle", false, false), "step_wet", t)
		assert_eq(Ambience.footstep(t, "downpour", false, false), "step_wet", t)
	assert_eq(Ambience.footstep("sand", "downpour", false, false), "step_sand", "sand stays sand")
	assert_eq(Ambience.footstep("floor_wood", "downpour", true, false), "step_wood", "dry indoors")
	assert_eq(Ambience.footstep("path", "fog", false, false), "step_path")

func test_bike_hisses() -> void:
	assert_eq(Ambience.footstep("road", "clear", false, true), "bike_tyre")
	assert_eq(Ambience.footstep("path", "downpour", false, true), "bike_tyre")

func test_footstep_sounds_exist() -> void:
	for id in ["step_path", "step_stone", "step_wood", "step_sand", "step_soft", "step_wet", "bike_tyre"]:
		assert_true(AudioIds.sfx_exists(id), id)

# --- interaction --------------------------------------------------------------------------------------------------

func test_interaction_sounds() -> void:
	assert_eq(Ambience.interact_kind({"text": "Welcome"}, {}), "sign_creak")
	assert_eq(Ambience.interact_kind({}, {"script": "shopkeeper"}), "shop_bell")
	assert_eq(Ambience.interact_kind({}, {"script": "nurse"}), "sanctuary_chime")
	assert_eq(Ambience.interact_kind({}, {"script": "macc_gran"}), "talk_blip")
	assert_eq(Ambience.interact_kind({}, {"id": "bob"}), "talk_blip")
	assert_eq(Ambience.interact_kind({}, {}), "", "nobody there")
	for id in ["sign_creak", "shop_bell", "sanctuary_chime", "talk_blip", "brake_squeal"]:
		assert_true(AudioIds.sfx_exists(id), id)

# --- settings -------------------------------------------------------------------------------------------------------

func test_ambience_volume_defaults_and_round_trips() -> void:
	var saved_path := Settings.path
	var saved := Settings.ambience_volume
	Settings.path = TMP
	var f := FileAccess.open(TMP, FileAccess.WRITE)
	f.store_string('{"text_speed": "normal", "music_volume": 0.3}')  # an old file without the key
	f.close()
	Settings.ambience_volume = 0.1
	Settings.load_settings()
	assert_near(Settings.ambience_volume, 0.1, 0.0001, "missing key keeps the current value")
	var fresh = load("res://core/settings.gd").new()
	assert_near(fresh.ambience_volume, 0.7, 0.0001, "default")
	fresh.free()
	Settings.ambience_volume = 0.4
	Settings.save_settings()
	Settings.ambience_volume = 0.9
	Settings.load_settings()
	assert_near(Settings.ambience_volume, 0.4, 0.0001, "saved and read back")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP))
	Settings.path = saved_path
	Settings.ambience_volume = saved

# --- levels -------------------------------------------------------------------------------------------------------

func _music_median() -> float:
	var l: Array = []
	for id in Loud.ids_in("res://audio/music"):
		l.append(Loud.measure("res://audio/music/%s.wav" % id)["rms"])
	return Loud.median(l)

func test_ambience_loops_levelled_well_under_the_music() -> void:
	var music := _music_median()
	for id in AmbienceRecipes.ids():
		var m: Dictionary = Loud.measure("res://audio/ambience/%s.wav" % id)
		assert_false(m.is_empty(), id + " exists")
		if m.is_empty():
			continue
		var want: float = AmbienceRecipes.TARGET_DB[id]
		assert_near(m["rms"], want, 0.6, id + " rms at its target (re-run tools/audio/ambgen.gd)")
		assert_true(m["peak"] <= -3.0, "%s peak %.2f dBFS" % [id, m["peak"]])
		assert_true(m["loop"], id + " loops")
		assert_true(absf(m["seam_db"]) <= 3.0, "%s level step %.2f dB at the seam" % [id, m["seam_db"]])
		assert_true(m["click"] <= 3.0, "%s click %.2f at the seam" % [id, m["click"]])
		if id.begins_with("amb_"):
			assert_true(want <= music - 12.0, "%s (%.1f) sits at least 12 dB under the music (%.1f)" % [id, want, music])
			assert_true(want >= -38.0, id + " not inaudibly quiet")

func test_ambience_render_is_deterministic_and_matches_the_file() -> void:
	var a := AmbienceRecipes.render("amb_cave")
	assert_true(a == AmbienceRecipes.render("amb_cave"), "deterministic")
	assert_eq(a.size(), Synth.frames(AmbienceRecipes.LENGTHS["amb_cave"], AmbienceRecipes.SR))
	var m: Dictionary = Loud.measure("res://audio/ambience/amb_cave.wav")
	assert_near(Loud.db(Synth.rms(a)), m["rms"], 0.05, "amb_cave.wav is stale")

# --- trains -------------------------------------------------------------------------------------------------------

func test_train_sound_falls_off_with_distance() -> void:
	assert_near(RailTraffic.hear_db(0.0), 0.0, 0.001, "right by it")
	assert_near(RailTraffic.hear_db(2.0), 0.0, 0.001)
	var last := 0.0
	for d in [4.0, 8.0, 16.0, 24.0, 32.0]:
		var v := RailTraffic.hear_db(d)
		assert_true(v < last, "quieter at %d tiles (%.1f)" % [d, v])
		last = v
	assert_true(RailTraffic.hear_db(8.0) > -12.0, "a train a few tiles off is clearly heard")
	assert_true(RailTraffic.hear_db(RailTraffic.HEAR_RANGE + 1.0) <= -60.0, "out of earshot")

func test_train_squeals_its_brakes_once_coming_into_the_platform() -> void:
	var z := _zone("town", "town", {"rows": [".".repeat(40), "_".repeat(40), "!".repeat(40)], "station": {"x": 20, "y": 1}})
	var t := RailTraffic.new()
	t.setup(z, func() -> Dictionary: return {}, 0.0)
	t.tick(0.0)
	var brakes := 0
	var brake_head := -1.0
	var time := 0.0
	while not t.run.is_empty() and time < 60.0:
		t.tick(1.0 / 30.0)
		time += 1.0 / 30.0
		for e in t.sound_events:
			if e == "brake":
				brakes += 1
				brake_head = t.run.head if not t.run.is_empty() else -1.0
		t.sound_events.clear()
	assert_eq(brakes, 1, "one squeal per stop")
	assert_true(brake_head > 0.0, "while it was still running in")
	t.free()

func test_no_squeal_for_a_train_that_does_not_stop() -> void:
	var z := _zone("town", "town", {"rows": [".".repeat(40), "!".repeat(40), ".".repeat(40)]})
	var t := RailTraffic.new()
	t.setup(z, func() -> Dictionary: return {}, 0.0)
	t.tick(0.0)
	var time := 0.0
	while not t.run.is_empty() and time < 60.0:
		t.tick(1.0 / 30.0)
		time += 1.0 / 30.0
	assert_false("brake" in t.sound_events)
	t.free()

