extends TestCase
## 3.0 Wider Isles, region R4: Bristol, off Bath's north side. The Avon Gorge route and the city, scaled to
## Bath's band, their interiors, plaques, trainers and the four quests in data/quests/bristol.json.

const ZONES := ["avon_gorge", "bristol"]
const FLOOR := 40

func _z(id: String) -> ZoneData:
	return ZoneData.load_id(id)

func _json(path: String) -> Variant:
	return JsonUtil.read(path)

func test_bath_opens_north_to_the_gorge_and_on_to_bristol() -> void:
	var bath := _z("bath")
	assert_eq(str(bath.edges.north.to), "avon_gorge")
	var gorge := _z("avon_gorge")
	assert_eq(str(gorge.edges.south.to), "bath")
	assert_eq(str(gorge.edges.north.to), "bristol")
	var city := _z("bristol")
	assert_eq(str(city.edges.south.to), "avon_gorge")
	assert_eq(city.edges.size(), 1, "Bristol is a cul-de-sac: no shortcut to anywhere else")
	assert_eq(gorge.edges.size(), 2)
	# Bath keeps its old neighbours and its spawn
	assert_eq(str(bath.edges.east.to), "mendips")
	assert_eq(str(bath.edges.west.to), "severn_crossing")
	assert_eq(bath.spawn, Vector2i(30, 21))

func test_zones_validate_and_edges_land_on_walkable_tiles() -> void:
	var all := {}
	for id in ZONES + ["bath"]:
		all[id] = _z(id)
	for id in ZONES:
		var errs: Array = all[id].validate(all).filter(func(e): return "unknown zone" not in e and "warp" not in e)
		assert_eq(errs, [], id)

func test_new_areas_are_scaled_to_baths_band() -> void:
	for id in ZONES:
		assert_eq(_z(id).scaled_floor, FLOOR, id)
	var n := 0
	for path in JsonUtil.list_json("res://data/trainers"):
		var t: Dictionary = _json(path)
		var tid := str(t.get("id", ""))
		if tid.begins_with("brs_") or tid.begins_with("gorge_"):
			n += 1
			assert_eq(int(t.get("scaled_floor", -1)), FLOOR, tid)
	assert_true(n >= 6, "six or more Bristol trainers (got %d)" % n)

func test_a_local_legend_with_a_full_team() -> void:
	var t: Dictionary = StoryData.trainer("brs_harbourmaster")
	assert_eq(t.party.size(), 6)

func test_bristol_has_its_services_and_six_landmark_interiors() -> void:
	var city := _z("bristol")
	assert_true(city.station != Vector2i(-1, -1), "Temple Meads is on the rail network")
	assert_eq(city.town_id, "bristol")
	var to := {}
	for w in city.warps:
		to[str(w.to)] = true
	assert_true(to.has("bristol_sanctuary"))
	assert_true(to.has("bristol_shop"))
	var landmarks := to.keys().filter(func(k): return k not in ["bristol_sanctuary", "bristol_shop"])
	assert_true(landmarks.size() >= 6, "landmark interiors: %s" % [landmarks])
	for k in landmarks:
		var room := _z(k)
		assert_eq(room.kind, "interior", k)
		assert_true(room.npcs.size() >= 1, "%s has somebody in it" % k)
	assert_true(FileAccess.file_exists("res://data/shops/bristol_corner_shop.json"))

func test_world_map_knows_bristol() -> void:
	var m := Travel.world_map()
	assert_true(m.towns.has("bristol"))
	assert_true(m.places.has("avon_gorge"))

func test_plaques_are_unique_and_plentiful() -> void:
	var seen := {}
	for path in JsonUtil.list_json("res://data/zones"):
		var d: Dictionary = _json(path)
		for s in d.get("signs", []):
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is used twice" % s.plaque)
				seen[s.plaque] = str(d.get("id", ""))
	var count := {"bristol": 0, "avon_gorge": 0}
	for id in ZONES:
		for s in _z(id).signs:
			if s.has("plaque"):
				count[id] += 1
				assert_true(str(s.get("title", "")) != "", str(s.plaque))
				assert_false("—" in str(s.text), str(s.plaque))
	assert_true(count.bristol >= 8, "plaques in Bristol: %d" % count.bristol)
	assert_true(count.avon_gorge >= 3, "plaques in the gorge: %d" % count.avon_gorge)

## Every flag a quest step needs is set by some dialogue or trainer script of ours.
func _set_flags(cmds: Variant, out: Dictionary) -> void:
	if cmds is Array:
		for c in cmds:
			_set_flags(c, out)
	elif cmds is Dictionary:
		if str(cmds.get("do", "")) == "set":
			out[str(cmds.flag)] = true
		for k in cmds:
			if cmds[k] is Array or cmds[k] is Dictionary:
				_set_flags(cmds[k], out)

func test_every_quest_flag_is_set_somewhere() -> void:
	var flags := {}
	for path in JsonUtil.list_json("res://data/dialogue"):
		var f: String = path.get_file()
		if f.begins_with("bristol") or f.begins_with("avon_gorge"):
			_set_flags(_json(path), flags)
	var q: Dictionary = _json("res://data/quests/bristol.json")
	assert_eq(q.quests.size(), 4)
	for quest in q.quests:
		var need := [str(quest.start_flag), str(quest.done_flag)]
		for st in quest.steps:
			need.append(str(st.flag))
			assert_true(str(st.zone) in ZONES, "%s step zone" % quest.id)
		for f in need:
			assert_true(f.begins_with("q_bristol_"), f)
			assert_true(flags.has(f), "%s: nothing sets %s" % [quest.id, f])

func test_quests_have_a_fight_and_a_show_check() -> void:
	var src := ""
	for path in JsonUtil.list_json("res://data/dialogue"):
		var f: String = path.get_file()
		if f.begins_with("bristol") or f.begins_with("avon_gorge"):
			src += JSON.stringify(_json(path))
	assert_true("brs_crew_chief" in src, "the Fiesta's crew chief fight")
	assert_true("has_peregrin" in src, "the peregrine watch's show-me check")
	assert_true("\"wickerling\"" in src and "\"gaugelet\"" in src, "the gift creatures")

func test_regional_items() -> void:
	var items := ItemDB.load_default()
	for id in ["bristol_cider", "market_pie", "bristol_chocolate", "brunels_top_hat", "peregrine_feather"]:
		assert_true(items.has(id), id)
	var stock: Array = items.shops.bristol_corner_shop.stock
	for id in ["bristol_cider", "market_pie", "bristol_chocolate"]:
		assert_true(id in stock, id)

func test_new_species_live_here() -> void:
	var enc := JSON.stringify(_z("bristol").encounters) + JSON.stringify(_z("avon_gorge").encounters)
	for id in ["gaugelet", "wickerling", "stencilette", "peregrin", "kidgruff"]:
		assert_true("\"%s\"" % id in enc, id)

func test_the_bridge_deck_spans_the_gorge() -> void:
	var g := _z("avon_gorge")
	var deck := 0
	for x in g.width:
		if ZoneBuilder.deck_under(g, Vector2i(x, 24)) >= 0:
			deck += 1
			assert_true(g.walkable(Vector2i(x, 24)), "deck at %d" % x)
	assert_eq(deck, Landmarks.CLIFTON_SPAN - 1, "deck tiles between the towers")
