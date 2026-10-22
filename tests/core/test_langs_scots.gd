extends TestCase
## 4.5 "Learn as you go", session F: Scots and Ulster Scots mapped to the right zones, and the lesson data for Scots,
## Ulster Scots, Manx, Cornish, Jerriais and Guernesiais written to the wave 45 language contract (shape, word counts,
## unique ids, teachers on a free floor tile in a room where that language is local).

const AUTHORED := ["sco", "sco_ulster", "gv", "kw", "jer", "nrf_gg"]

func test_scots_and_ulster_scots_are_mapped() -> void:
	var i := ZoneIndex.get_index()
	for z in ["edinburgh", "edinburgh_castle", "glasgow", "aberdeen", "dundee", "st_andrews", "scottish_borders", "galloway",
			"kirkwall", "lerwick", "lerwick_tearoom", "shetland_mainland"]:
		assert_eq(Langs.code_for(z, i), "sco", z)
	for z in ["belfast", "belfast_linenhall", "bushmills", "antrim_coast", "causeway", "causeway_centre"]:
		assert_eq(Langs.code_for(z, i), "sco_ulster", z)
	for z in ["inverness", "portree", "stornoway"]:
		assert_eq(Langs.code_for(z, i), "gd", z + " keeps its Gaelic")
	assert_eq(Langs.code_for("dublin", i), "ga")
	for z in ["derry", "enniskillen", "mournes", "lough_neagh", "marblearch_cladagh"]:
		assert_eq(Langs.code_for(z, i), "", z + ": no language by default")
	assert_true("sco" in Langs.CODES and "sco_ulster" in Langs.CODES)
	assert_eq(Langs.NAMES["sco_ulster"], "Ulster Scots")

func test_lessons_follow_the_contract() -> void:
	var i := ZoneIndex.get_index()
	var zones := ZoneData.load_all()
	var spots := {}
	for code in AUTHORED:
		var d := Langs.data(code)
		assert_true(str(d.get("name", "")) != "" and str(d.get("endonym", "")) != "", code + " name")
		assert_true(d.get("about", []).size() >= 2 and d.about.size() <= 4, code + " about lines")
		var lessons: Array = d.get("lessons", [])
		assert_true(lessons.size() >= 2, code + " lessons")
		var word_ids := {}
		var lesson_ids := {}
		for l in lessons:
			var lid := str(l.id)
			assert_true(lid.begins_with(code + "_") and lid.substr(code.length() + 1).is_valid_int() and lid.length() == code.length() + 3, lid)
			assert_false(lesson_ids.has(lid), lid + " unique")
			lesson_ids[lid] = true
			assert_true(int(l.level) >= 1 and int(l.level) <= 4, lid + " level")
			assert_true(str(l.title) != "" and l.intro.size() >= 1 and l.intro.size() <= 3, lid + " title and intro")
			assert_true(l.words.size() >= 6 and l.words.size() <= 10, lid + " has 6 to 10 words")
			for w in l.words:
				for k in ["id", "local", "english", "say"]:
					assert_true(str(w.get(k, "")) != "", "%s %s" % [lid, k])
				assert_false(word_ids.has(w.id), "%s word %s unique" % [code, w.id])
				word_ids[w.id] = true
				assert_true(str(w.say) != str(w.say).to_lower(), "%s %s: stress in capitals" % [lid, w.id])
			var t: Dictionary = l.teacher
			assert_true(zones.has(str(t.zone)), lid + " teacher zone")
			assert_eq(Langs.code_for(str(t.zone), i), code, lid + " teacher stands where the language is local")
			assert_true(FileAccess.file_exists("res://art/sprites/chars/%s.png" % t.sprite), lid + " sprite")
			var key := "%s@%d,%d" % [t.zone, int(t.x), int(t.y)]
			assert_false(spots.has(key) and spots[key] != str(t.name), key + " shared by two teachers")
			spots[key] = str(t.name)
			assert_eq(_tile_problem(zones[str(t.zone)], Vector2i(int(t.x), int(t.y))), "", lid)
		assert_false("—" in JSON.stringify(d), code + " em-dash")

## "" when p is a free floor tile: walkable, no prop, NPC, warp or examine spot on it, and standing there blocks
## nothing else in the room.
func _tile_problem(z: ZoneData, p: Vector2i) -> String:
	if not z.walkable(p):
		return "%s %s not walkable" % [z.id, p]
	if p == z.spawn:
		return "%s %s is the spawn" % [z.id, p]
	var still := {}
	for n in z.npcs:
		if p in z.roam_tiles(n) or p == Vector2i(int(n.x), int(n.y)):
			return "%s %s has an NPC" % [z.id, p]
		if str(n.get("move", "still")) == "still":
			still[Vector2i(int(n.x), int(n.y))] = true
	for w in z.warps:
		if absi(int(w.x) - p.x) + absi(int(w.y) - p.y) <= 1:
			return "%s %s on or by a door" % [z.id, p]
	for e in z.examine:
		if Vector2i(int(e.x), int(e.y)) == p:
			return "%s %s is an examine spot" % [z.id, p]
	var before := z.reachable(z.spawn, [], still).size()
	still[p] = true
	if z.reachable(z.spawn, [], still).size() != before - 1:
		return "%s %s cuts the room off" % [z.id, p]
	return ""
