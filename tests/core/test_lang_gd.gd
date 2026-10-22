extends TestCase
## Scottish Gaelic (gd) lessons, authored to the wave 45 language contract (docs/briefs/wave45.md): the file's
## shape, each teacher on a free, reachable floor tile indoors in a Highlands and Islands town, and the Gaelic
## signs and NPC lines using words the lessons teach. Checks the data only, so it stands without the lesson loader.

const PATH := "res://data/lang/gd.json"
const LEVELS := [1, 2, 3, 4]

func _gd() -> Dictionary:
	Langs.reset()
	return Langs.data("gd")

func _words() -> Dictionary:
	var out := {}
	for l in _gd().get("lessons", []):
		for w in l.get("words", []):
			out[str(w.local).to_lower().rstrip("!?.")] = true
	return out

func test_gaelic_keeps_its_old_keys_and_names_itself() -> void:
	var d := _gd()
	assert_eq(str(d.get("name", "")), "Scottish Gaelic")
	assert_eq(str(d.get("endonym", "")), "Gàidhlig")
	for k in ["places", "greetings", "phrases"]:
		assert_true(d.has(k), "keeps %s" % k)
	assert_eq(str(d.places.get("stornoway", "")), "Steòrnabhagh", "existing place names untouched")
	var about: Array = d.get("about", [])
	assert_true(about.size() >= 2 and about.size() <= 4, "2 to 4 about lines")

func test_lessons_follow_the_contract() -> void:
	var lessons: Array = _gd().get("lessons", [])
	assert_true(lessons.size() >= 12, "twelve or more lessons")
	var seen_words := {}
	var seen_lessons := {}
	var levels := {}
	for l in lessons:
		var id := str(l.get("id", ""))
		assert_true(id.begins_with("gd_") and id.length() == 5 and id.substr(3).is_valid_int(), "%s: id gd_NN" % id)
		assert_false(seen_lessons.has(id), "%s: unique" % id)
		seen_lessons[id] = true
		assert_true(str(l.get("title", "")) != "", "%s: title" % id)
		assert_true(int(l.get("level", 0)) in LEVELS, "%s: level 1 to 4" % id)
		levels[int(l.level)] = true
		var intro: Array = l.get("intro", [])
		assert_true(intro.size() >= 1 and intro.size() <= 3, "%s: one to three intro lines" % id)
		var words: Array = l.get("words", [])
		assert_true(words.size() >= 6 and words.size() <= 10, "%s: 6 to 10 words" % id)
		for w in words:
			var wid := str(w.get("id", ""))
			assert_true(wid != "" and not seen_words.has(wid), "%s: word id %s unique" % [id, wid])
			seen_words[wid] = true
			for k in ["local", "english", "say"]:
				assert_true(str(w.get(k, "")) != "", "%s/%s: has %s" % [id, wid, k])
			var say := str(w.get("say", ""))
			assert_true(say != say.to_lower(), "%s/%s: stressed syllable in capitals" % [id, wid])
	for lv in LEVELS:
		assert_true(levels.has(lv), "a lesson at level %d" % lv)
	assert_true(lessons.filter(func(l): return int(l.level) == 1).size() >= 3, "three survival lessons")

func test_a_teacher_may_give_several_lessons_from_one_spot() -> void:
	# The same zone, tile and name is one teacher (session D's loader groups by the spot): Ealasaid in An Lanntair.
	var by_spot := {}
	for l in _gd().get("lessons", []):
		var t: Dictionary = l.get("teacher", {})
		var key := "%s@%d,%d" % [t.get("zone", ""), int(t.get("x", 0)), int(t.get("y", 0))]
		if by_spot.has(key):
			assert_eq(str(by_spot[key]), str(t.get("name", "")), "%s: one name per spot" % key)
		by_spot[key] = str(t.get("name", ""))
	assert_eq(str(by_spot.get("stornoway_lanntair@9,6", "")), "Ealasaid", "Ealasaid gives gd_01 and gd_07")
	assert_true(by_spot.size() >= 10, "teachers across the Highlands and Islands, not one classroom")

func test_no_em_dashes_in_gaelic_text() -> void:
	var raw := FileAccess.get_file_as_string(PATH)
	assert_false(raw.contains("—"), "no em-dashes")
	assert_false(raw.contains("–"), "no en-dashes either")

func test_every_teacher_stands_indoors_in_gaelic_country() -> void:
	var idx := ZoneIndex.get_index()
	var spots := {}
	for l in _gd().get("lessons", []):
		var t: Dictionary = l.get("teacher", {})
		var tag := "%s teacher %s" % [l.id, t.get("name", "?")]
		var z := ZoneData.load_id(str(t.get("zone", "")))
		assert_true(z != null, "%s: zone exists" % tag)
		if z == null:
			continue
		assert_eq(z.kind, "interior", "%s: indoors" % tag)
		assert_eq(Langs.code_for(z.id, idx), "gd", "%s: a town where Gaelic is local" % tag)
		var p := Vector2i(int(t.x), int(t.y))
		var key := "%s@%d,%d" % [z.id, p.x, p.y]
		if spots.has(key):  # the same teacher, another lesson
			assert_eq(str(spots[key]), str(t.get("name", "")), "%s: shares the tile only with themself" % tag)
			continue
		spots[key] = str(t.get("name", ""))
		assert_true(SideStories.free_tile(z, p), "%s: (%d, %d) is a free floor tile" % [tag, p.x, p.y])
		assert_true(_neighbour_reachable(z, p), "%s: you can walk up to them" % tag)
		assert_true(FileAccess.file_exists("res://art/sprites/chars/%s.png" % t.get("sprite", "")), "%s: sprite has art" % tag)

func test_gaelic_signs_use_taught_words() -> void:
	var taught := _words()
	for zid in ["skye_braes_hall", "stornoway_cafe", "tobermory_mishnish", "portree_aros", "skye_kylecafe", "inverness_market", "oban_inn"]:
		var z := ZoneData.load_id(zid)
		var found := false
		for s in z.signs:
			var loc: Variant = s.get("local", {})
			if not (loc is Dictionary) or not loc.has("gd"):
				continue
			found = true
			assert_true(SideStories.free_tile(z, Vector2i(int(s.x), int(s.y)) + Vector2i(0, 1)) or SideStories.free_tile(z, Vector2i(int(s.x), int(s.y)) + Vector2i(-1, 0)) \
				or SideStories.free_tile(z, Vector2i(int(s.x), int(s.y)) + Vector2i(1, 0)), "%s sign at (%d, %d): you can stand next to it" % [zid, s.x, s.y])
			for part in str(loc.gd).to_lower().replace(",", "").split(" "):
				if part in ["is"]:
					continue
				assert_true(_taught_has(taught, part.rstrip("!?.")), "%s sign: '%s' is a lesson word" % [zid, part])
		assert_true(found, "%s: has a Gaelic sign" % zid)

func test_npc_lines_use_taught_words() -> void:
	# A line of Gaelic in a mouth is a lesson word, so a player who has met the teacher recognises it.
	var taught := _words()
	# [what the NPC says, the lesson word it rests on] (mo theaghlach is teaghlach softened; Druim na Drochaid is druim)
	var lines := {"portree_aros": [["mo theaghlach", "teaghlach"], ["seanmhair", "seanmhair"]],
		"harris_callanish": [["glas", "glas"], ["donn", "donn"]], "skye_kylecafe": [["tha an t-acras orm", "t-acras"]],
		"inverness_market": [["druim na drochaid", "druim"], ["inbhir nis", "inbhir"]], "oban_inn": [["beannachd leat", "beannachd"], ["mòd", "mòd"]],
		"tobermory_mishnish": [["is toil leam", "toil"]], "harris_blackhouse": [["mòine", "mòine"], ["tha i fuar", "fuar"]]}
	for zid in lines:
		var raw := FileAccess.get_file_as_string("res://data/dialogue/%s.json" % zid).to_lower()
		for pair in lines[zid]:
			assert_true(str(pair[0]) in raw, "%s: an NPC says '%s'" % [zid, pair[0]])
			assert_true(_taught_has(taught, str(pair[1])), "%s: '%s' is taught" % [zid, pair[1]])

func _taught_has(taught: Dictionary, part: String) -> bool:
	for k in taught:
		if part in str(k).split(" "):
			return true
	return false

func _neighbour_reachable(z: ZoneData, p: Vector2i) -> bool:
	var r := z.reachable(z.spawn, ["hedge_lay"])
	for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if r.has(p + d):
			return true
	return false
