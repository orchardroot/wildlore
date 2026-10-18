extends TestCase
## 2.1 battle sounds: an attack voice per type family, the wild sting, stat and weather calls.

const NEW_IDS := ["encounter", "stat_up", "stat_down", "weather_call"]

func test_every_type_has_an_attack_voice_with_a_file() -> void:
	var types: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/types.json")).types
	var voices := {}
	for t in types:
		var id := AudioIds.attack_sfx(str(t))
		assert_true(id.begins_with("atk_"), "%s maps to an attack voice (%s)" % [t, id])
		assert_true(AudioIds.sfx_exists(id), "%s voice %s has a file" % [t, id])
		voices[id] = true
	assert_eq(voices.size(), 12, "twelve voices across the sixteen types")

func test_unknown_or_blank_type_falls_back_to_the_old_hit() -> void:
	assert_eq(AudioIds.attack_sfx(""), "attack")
	assert_eq(AudioIds.attack_sfx("teacake"), "attack")

func test_new_battle_sounds_render_and_exist() -> void:
	var ids: Array = NEW_IDS.duplicate()
	for v in AudioIds.ATTACK_VOICE.values():
		if not ids.has(v):
			ids.append(v)
	for id in ids:
		assert_has(SfxRecipes.ids(), id)
		var buf := SfxRecipes.render(id)
		assert_near(float(buf.size()), float(SfxRecipes.LENGTHS[id]) * SfxRecipes.SR, 1.0, id + " length")
		var p := Synth.peak(buf)
		assert_true(p >= 0.2 and p <= 0.95, "%s peak %s" % [id, str(p)])
		assert_true(Synth.rms(buf) > 0.01, id + " not silent")
		assert_near(buf[buf.size() - 1], 0.0, 0.01, id + " ends at zero")
		assert_true(AudioIds.sfx_exists(id), id + " wav exists")

func test_voices_differ() -> void:
	var a := SfxRecipes.render("atk_thud")
	var b := SfxRecipes.render("atk_zap")
	assert_true(a != b, "the voices are not one sound")
