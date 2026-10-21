extends TestCase
## The Cotswolds and Oxford (3.0 Wider Isles): a route and a university town hang off Birmingham's east side as a
## cul-de-sac, scaled from par 89, with quests, plaques, trainers, two regional creature lines and new building styles.

const ZONES := ["cotswolds", "oxford"]
const FLOOR := 89
const NEW_SPECIES := ["dodo", "gloucelet", "doublewheel"]
const STYLES := ["cotswold_house", "cotswold_cottage", "wool_church", "oxford_college", "oxford_tower", "oxford_church", "radcliffe_camera"]

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func test_joins_birmingham_east_and_edges_mirror() -> void:
	var brum := ZoneData.load_id("birmingham")
	assert_eq(str(brum.edges.east.to), "cotswolds")
	var cw := ZoneData.load_id("cotswolds")
	assert_eq(str(cw.edges.west.to), "birmingham")
	assert_eq(str(cw.edges.east.to), "oxford")
	assert_eq(cw.edges.size(), 3, "the route leads nowhere else new, bar the lane south to RAF Brize Norton")
	assert_eq(str(cw.edges.south.to), "brize_norton")
	var ox := ZoneData.load_id("oxford")
	assert_eq(str(ox.edges.west.to), "cotswolds")
	assert_eq(ox.edges.size(), 1)
	for y in [25, 26, 27]:
		assert_true(brum.walkable(Vector2i(brum.width - 1, y)), "Birmingham's east gate row %d is open" % y)
		assert_true(cw.walkable(Vector2i(0, y)), "the Cotswold road starts at row %d" % y)

func test_zones_are_scaled_and_placed() -> void:
	assert_eq(ZoneData.load_id("cotswolds").region, "midlands")
	assert_eq(ZoneData.load_id("oxford").region, "south_east")
	for zid in ZONES:
		var z := ZoneData.load_id(zid)
		assert_eq(z.scaled_floor, FLOOR, zid)
		for table in z.encounters.values():
			for e in table:
				assert_true(int(e.min) >= FLOOR and int(e.max) <= FLOOR + 3, "%s %s levels" % [zid, e.species])
	assert_true(ZoneData.load_id("oxford").station != Vector2i(-1, -1), "Oxford has a station")
	assert_true(Travel.world_map().towns.has("oxford"), "Oxford is on the world map")
	assert_true(Travel.world_map().places.has("cotswolds"), "the Cotswolds are on the world map")

func test_each_town_has_enough_interiors() -> void:
	var ox := ZoneData.load_id("oxford")
	var cw := ZoneData.load_id("cotswolds")
	assert_true(ox.warps.size() >= 10, "Oxford doors: %d" % ox.warps.size())
	assert_true(cw.warps.size() >= 6, "Cotswold doors: %d" % cw.warps.size())
	for z in [ox, cw]:
		for w in z.warps:
			assert_true(FileAccess.file_exists("res://data/zones/%s.json" % w.to), str(w.to))

func test_trainers_are_scaled_and_fair() -> void:
	var n := 0
	for path in DirAccess.get_files_at("res://data/trainers"):
		var id := str(path).get_basename()
		if not (id.begins_with("cots_") or id.begins_with("ox_")):
			continue
		var t: Dictionary = _json("res://data/trainers/" + path)
		n += 1
		assert_eq(int(t.get("scaled_floor", -1)), FLOOR, id)
		for m in t.party:
			assert_true(int(m.level) <= 95, "%s level %d" % [id, int(m.level)])
	assert_true(n >= 12, "trainers: %d" % n)
	assert_eq((_json("res://data/trainers/cots_legend.json") as Dictionary).party.size(), 6, "the Cotswold legend has a full party")
	assert_eq((_json("res://data/trainers/ox_proctor.json") as Dictionary).party.size(), 6, "the Proctor has a full party")

func test_plaques_unique_and_enough() -> void:
	var seen := {}
	for zid in ZONES:
		var count := 0
		for s in ZoneData.load_id(zid).signs:
			if s.has("plaque"):
				count += 1
				assert_true(str(s.plaque).begins_with(zid + "_"), str(s.plaque))
				assert_false(seen.has(s.plaque), "duplicate plaque " + str(s.plaque))
				seen[s.plaque] = true
				assert_true(str(s.get("title", "")) != "" and str(s.text).length() > 80, str(s.plaque))
				assert_false("—" in str(s.text), "no em-dashes")
		assert_true(count >= (8 if zid == "oxford" else 3), "%s plaques: %d" % [zid, count])

func test_every_quest_flag_is_set_somewhere() -> void:
	var text := ""
	for path in DirAccess.get_files_at("res://data/dialogue"):
		text += FileAccess.get_file_as_string("res://data/dialogue/" + path)
	var total := 0
	for file in ["cotswolds", "oxford"]:
		var quests: Array = (_json("res://data/quests/%s.json" % file) as Dictionary).quests
		for q in quests:
			total += 1
			var flags := [q.start_flag, q.done_flag]
			for s in q.steps:
				flags.append(s.flag)
			for f in flags:
				assert_true(str(f).begins_with("q_cotswolds_") or str(f).begins_with("q_oxford_"), str(f))
				assert_true(('"flag": "%s"' % f) in text, "%s is set by a script" % f)
	assert_eq(total, 3)

func test_new_species_load_as_appendix_with_sprites() -> void:
	var dex := Dex.load_default()
	var order: Array = _json("res://data/dex_order.json")
	for sp in NEW_SPECIES:
		assert_true(dex.has(sp), sp)
		assert_true(bool(dex.get_species(sp).get("appendix", false)), sp + " is appendix")
		assert_true(sp in order, sp + " in dex order")
		assert_true(str(dex.get_species(sp).dex.fact).length() > 60, sp + " has a true fact")
		for side in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [sp, side]), "%s %s" % [sp, side])
	assert_eq(dex.get_species("dodo").types, ["spirit", "kin"])
	assert_eq(dex.get_species("gloucelet").types, ["brawn", "hearth"])
	assert_eq(str(dex.get_species("gloucelet").evolves.to), "doublewheel")
	# placed: the cheese basic is wild on the wold, the dodo is a special encounter in the museum
	var wild := {}
	for zid in ZONES:
		for table in ZoneData.load_id(zid).encounters.values():
			for e in table:
				wild[str(e.species)] = true
	assert_true(wild.has("gloucelet"))
	assert_true('"species": "dodo"' in FileAccess.get_file_as_string("res://data/dialogue/oxford_natural.json"))
	var knacks: Dictionary = (_json("res://data/knacks.json") as Dictionary).species
	for sp in NEW_SPECIES:
		assert_true(knacks.has(sp), sp + " has a knack")

func test_regional_items_and_shops() -> void:
	var items := ItemDB.load_default()
	for id in ["double_gloucester", "banbury_cake", "oxford_marmalade", "coopers_wheel", "rollright_pebble", "readers_ticket", "cotswold_fleece"]:
		assert_true(items.has(id), id)
	assert_true("double_gloucester" in items.shops["cotswolds_corner_shop"].stock)
	assert_true("banbury_cake" in items.shops["oxford_corner_shop"].stock)

func test_building_styles_and_props_build() -> void:
	for style in STYLES:
		assert_true(style in Landmarks.SPECIAL, style)
		var parts: Array = Meshes.building(7, 5, style, 3, 1)
		assert_true((parts[0] as ArrayMesh).get_surface_count() > 0, style)
	assert_true(Landmarks.sighs_bridge(3).get_surface_count() > 0)
	for v in 3:
		assert_true(Landmarks.cheese_wheel(v).get_surface_count() > 0)
	assert_true(Landmarks.cots_prop("sighs_bridge", 3).get_surface_count() > 0)

func test_quiz_questions_added() -> void:
	var qs: Array = _json("res://data/quiz/questions.json")
	var n := 0
	for q in qs:
		if str(q.a) in ["The Bodleian Library", "The Radcliffe Camera", "The Rollright Stones", "The dodo", "The Eagle and Child", "The Scriptorium", "The Cotswold Lion", "Stow-on-the-Wold"]:
			n += 1
	assert_true(n >= 8, "Cotswold and Oxford quiz questions: %d" % n)
