extends TestCase
## 3.3 "Overseas", wave 33 agent 1: the registry of territories (data/overseas), RAF Brize Norton and the departures
## board, the "overseas" nation, Gibraltar and the Sovereign Base Areas of Akrotiri and Dhekelia.

const HUB_ZONES := ["brize_norton"]
const GIB_ZONES := ["gibraltar", "gibraltar_rock"]
const CY_ZONES := ["akrotiri", "dhekelia"]
const NEW_SPECIES := ["macaquet", "levanter", "sapperling", "brineling", "brineflame", "tesserite"]
const STYLES := ["raf_hangar", "control_tower", "raf_aircraft", "raf_block", "gib_house", "gib_rock", "europa_lighthouse", "flat_house", "greek_theatre", "raf_terminal"]

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

# ------------------------------------------------------------------ the registry

func test_every_registry_file_parses_and_lands_somewhere_real() -> void:
	Overseas.reset()
	var n := 0
	for f in DirAccess.get_files_at("res://data/overseas"):
		if not f.ends_with(".json"):
			continue
		n += 1
		var d = _json("res://data/overseas/" + f)
		assert_true(d is Dictionary, "%s parses" % f)
		for k in Overseas.REQUIRED:
			assert_true(d.has(k), "%s has '%s'" % [f, k])
		assert_eq(str(d.id), f.get_basename(), "%s: the id is the file name" % f)
		var a := ZoneData.load_id(str(d.arrival.zone))
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % d.arrival.zone), "%s: arrival zone exists" % f)
		assert_true(a.walkable(Vector2i(int(d.arrival.x), int(d.arrival.y))), "%s: the arrival tile is walkable" % f)
		assert_true(str(d.via) in ["raf", "ferry"], "%s: via" % f)
		assert_false(str(d.blurb).contains("—") or str(d.flight_line).contains("—"), "%s: no em-dashes" % f)
	assert_true(n >= 2, "at least Gibraltar and the Base Areas are registered: %d" % n)
	var zones := ZoneData.load_all()
	assert_eq(Overseas.validate(func(zid): return zones.has(zid)), [], "the registry validates")

func test_the_board_lists_only_what_is_unlocked() -> void:
	Overseas.reset()
	var d := GameStateData.new()
	assert_eq(Overseas.available(d), [], "no Champion, no flights")
	d.set_flag("champion")
	var ids := []
	for e in Overseas.available(d):
		ids.append(str(e.id))
	assert_true("gibraltar" in ids and "akrotiri_dhekelia" in ids, str(ids))
	assert_eq(Overseas.name_of("gibraltar"), "Gibraltar")
	assert_eq(Travel.town_name("akrotiri_dhekelia"), "Akrotiri and Dhekelia", "travel scenes read the territory's name")
	assert_eq(Journey.scheme_for("gibraltar"), "coast")

func test_coming_home_lands_on_brize_norton_or_the_port() -> void:
	Overseas.reset()
	var h := Overseas.home(Overseas.get_entry("gibraltar"))
	assert_eq(str(h.zone), "brize_norton")
	assert_true(ZoneData.load_id("brize_norton").walkable(h.pos), "Brize Norton's apron is walkable")
	var ferry := {"id": "x", "via": "ferry", "port": "dover"}
	var p := Overseas.home(ferry)
	assert_eq(str(p.zone), "dover", "a ferry territory comes home to its port")
	assert_true(ZoneData.load_id("dover").walkable(p.pos), "the quay is walkable")

# ------------------------------------------------------------------ nation and standing

func test_overseas_zones_belong_to_the_overseas_nation() -> void:
	assert_true("overseas" in Standing.NATIONS)
	for z in ["brize_norton", "brize_norton_terminal", "gibraltar", "gibraltar_rock", "gibraltar_museum", "akrotiri", "dhekelia", "dhekelia_hall", "overseas_pitcairn"]:
		assert_eq(Standing.nation_for_zone(z), "overseas", z)
	assert_eq(Standing.nation_for_zone("cotswolds"), "england", "the way in is still England")
	for n in Standing.NATIONS:
		assert_true(Standing.EXTRA_STOCK.has(n) and Standing.LANDLORD_FOOD.has(n) and Standing.TROPHY.has(n) and Standing.PILLAR_LINES.has(n), "%s is complete" % n)
		assert_true(Standing.NAMES.has(n), n)
	assert_true(ItemDB.load_default().has(str(Standing.TROPHY.overseas)), "the trophy is a real item")

# ------------------------------------------------------------------ geography

func test_brize_norton_hangs_off_the_cotswolds_south_side() -> void:
	var c := ZoneData.load_id("cotswolds")
	assert_eq(str(c.edges.south.to), "brize_norton")
	assert_eq(c.edges.size(), 3, "west, east and the new way south")
	var b := ZoneData.load_id("brize_norton")
	assert_eq(str(b.edges.north.to), "cotswolds")
	assert_eq(b.edges.size(), 1, "Brize Norton is a cul-de-sac")
	for x in [72, 73, 74, 75]:
		assert_true(c.walkable(Vector2i(x, c.height - 1)), "the gap in the Cotswolds is open at %d" % x)
		assert_true(b.walkable(Vector2i(x, 0)), "the lane starts at %d" % x)
	var police := 0
	for n in c.npcs:
		if str(n.get("script", "")) == "cw_raf_police":
			police += 1
			assert_eq(str(n.hide_if), "champion", "the RAF Police stand aside for the Champion")
	assert_eq(police, 4, "four police fill the four-tile gap")

func test_gibraltar_and_the_base_areas_edges_mirror() -> void:
	assert_eq(str(ZoneData.load_id("gibraltar").edges.east.to), "gibraltar_rock")
	assert_eq(str(ZoneData.load_id("gibraltar_rock").edges.west.to), "gibraltar")
	assert_eq(str(ZoneData.load_id("akrotiri").edges.east.to), "dhekelia")
	assert_eq(str(ZoneData.load_id("dhekelia").edges.west.to), "akrotiri")
	for zid in GIB_ZONES + CY_ZONES + HUB_ZONES:
		assert_eq(ZoneData.load_id(zid).edges.size() <= 2, true, "%s: no shortcuts" % zid)

func test_every_zone_is_scaled_from_par_95_with_a_region() -> void:
	for zid in HUB_ZONES + GIB_ZONES + CY_ZONES:
		var z := ZoneData.load_id(zid)
		assert_eq(z.scaled_floor, 95, zid)
		assert_true(z.region.begins_with("overseas_"), "%s: region %s" % [zid, z.region])
		var wild := 0
		for table in z.encounters.values():
			for e in table:
				wild += 1
				assert_true(int(e.min) >= 95 and int(e.max) <= 98, "%s %s levels" % [zid, e.species])
		assert_true(wild >= 8, "%s has wild things: %d" % [zid, wild])

func test_each_territory_has_enough_places_and_plaques() -> void:
	var want := {"brize_norton": [HUB_ZONES, 4, 8], "gibraltar": [GIB_ZONES, 4, 8], "akrotiri_dhekelia": [CY_ZONES, 4, 8]}
	for t in want:
		var doors := 0
		var plaques := 0
		var ids := {}
		for zid in want[t][0]:
			var z := ZoneData.load_id(zid)
			doors += z.warps.size()
			for s in z.signs:
				if str(s.get("plaque", "")) != "":
					plaques += 1
					assert_false(ids.has(str(s.plaque)), "unique plaque %s" % s.plaque)
					ids[str(s.plaque)] = true
					assert_true(str(s.plaque).begins_with(t.split("_")[0]) or str(s.plaque).begins_with(t), "%s: plaque id %s" % [t, s.plaque])
					assert_true(str(s.get("title", "")) != "" and str(s.text).length() > 80, "%s reads well" % s.plaque)
					assert_false(str(s.text).contains("—"), "no em-dashes in %s" % s.plaque)
		assert_true(doors >= want[t][1] + 2, "%s doors: %d" % [t, doors])
		assert_true(plaques >= want[t][2], "%s plaques: %d" % [t, plaques])
	for zid in HUB_ZONES + GIB_ZONES + CY_ZONES:
		for w in ZoneData.load_id(zid).warps:
			assert_true(FileAccess.file_exists("res://data/zones/%s.json" % w.to), str(w.to))

func test_trainers_are_scaled_and_fair() -> void:
	var n := 0
	var by := {}
	for path in DirAccess.get_files_at("res://data/trainers"):
		var id := str(path).get_basename()
		var prefix := ""
		for p in ["brz_", "gib_", "akr_", "dhk_"]:
			if id.begins_with(p):
				prefix = p
		if prefix == "":
			continue
		var t: Dictionary = _json("res://data/trainers/" + path)
		n += 1
		by[prefix] = int(by.get(prefix, 0)) + 1
		assert_eq(int(t.get("scaled_floor", -1)), 95, id)
		for m in t.party:
			assert_true(int(m.level) <= 95 and int(m.level) >= 90, "%s level %d" % [id, int(m.level)])
	assert_true(by.get("brz_", 0) >= 4 and by.get("gib_", 0) >= 5 and int(by.get("akr_", 0)) + int(by.get("dhk_", 0)) >= 8, str(by))
	assert_true(n >= 17, "trainers: %d" % n)

# ------------------------------------------------------------------ flights

func test_the_movements_officer_wants_a_champion() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "brize_norton_terminal", "brz_movements", "brz_movements")
	assert_true(h.log.filter(func(l): return l[0] == "menu").is_empty(), "no board for a civilian")
	var h2 := FakeStoryHost.new()
	h2.data.set_flag("champion")
	h2.choices = [0]
	h2.menu_results["travel:overseas"] = "gibraltar"
	h2.zone = "brize_norton_terminal"
	await _run(h2, "brize_norton_terminal", "brz_movements", "brz_movements")
	assert_eq(h2.warps.size(), 1, "one flight")
	assert_eq(h2.warps[0][0], "gibraltar")
	assert_eq([h2.warps[0][1], h2.warps[0][2]], [40, 19])
	var h3 := FakeStoryHost.new()
	h3.data.set_flag("champion")
	h3.choices = [1]
	await _run(h3, "brize_norton_terminal", "brz_movements", "brz_movements")
	assert_eq(h3.warps.size(), 0, "Not today means not today")

func test_the_flight_home_from_each_territory() -> void:
	for pair in [["gibraltar_terminal", "gib_movements", "gibraltar"], ["akrotiri_terminal", "akr_movements", "akrotiri_dhekelia"]]:
		var h := FakeStoryHost.new()
		h.choices = [0]
		await _run(h, pair[0], pair[1], pair[1])
		assert_eq(h.warps.size(), 1, pair[0])
		assert_eq(h.warps[0][0], "brize_norton")
		var h2 := FakeStoryHost.new()
		h2.choices = [1]
		await _run(h2, pair[0], pair[1], pair[1])
		assert_eq(h2.warps.size(), 0, "stay put")

# ------------------------------------------------------------------ quests

func test_the_airbridge_manifest_quest() -> void:
	var h := FakeStoryHost.new()
	var z := "brize_norton_airbridge"
	await _run(h, z, "brz_duty", "brz_duty")
	assert_eq(h.data.flag("q_overseas_brize_norton_started"), true)
	assert_eq(h.data.flag("q_overseas_brize_norton_1"), true)
	await _run(h, "brize_norton_tower", "brz_tower_ctrl", "brz_tower_ctrl")
	assert_eq(h.data.flag("q_overseas_brize_norton_2"), true)
	await _run(h, z, "brz_duty", "brz_duty")
	assert_false(h.data.flag("q_overseas_brize_norton_done") == true, "the Loadmaster has not signed yet")
	h.data.set_flag("trainer_brz_loadmaster")
	await _run(h, z, "brz_duty", "brz_duty")
	assert_eq(h.data.flag("q_overseas_brize_norton_3"), true)
	assert_eq(h.data.flag("q_overseas_brize_norton_done"), true)
	assert_true(Standing.points(h.data, "overseas") >= 10, "standing with the territories")

func test_the_rocks_early_story_quest() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "gibraltar_stmichaels", "gib_cavern", "gib_cavern")
	assert_eq(h.data.flag("q_overseas_gibraltar_started"), true)
	await _run(h, "gibraltar_museum", "gib_curator", "gib_curator")
	assert_eq(h.data.flag("q_overseas_gibraltar_1"), true)
	await _run(h, "gibraltar_stmichaels", "gib_cavern", "gib_cavern")
	assert_eq(h.data.flag("q_overseas_gibraltar_2"), true)
	await _run(h, "gibraltar_stmichaels", "gib_cavern", "gib_cavern")
	assert_false(h.data.flag("q_overseas_gibraltar_done") == true, "the Ape Keeper comes first")
	h.data.set_flag("trainer_gib_keeper")
	await _run(h, "gibraltar_stmichaels", "gib_cavern", "gib_cavern")
	assert_eq(h.data.flag("q_overseas_gibraltar_done"), true)
	assert_eq(Bag.new(h.data.bag).count("siege_cannonball"), 1)

func test_the_flamingo_census_quest() -> void:
	var h := FakeStoryHost.new()
	var z := "akrotiri_centre"
	await _run(h, z, "akr_centre_warden", "akr_centre_warden")
	assert_eq(h.data.flag("q_overseas_akrotiri_dhekelia_1"), true)
	await _run(h, z, "akr_centre_warden", "akr_centre_warden")
	assert_false(h.data.flag("q_overseas_akrotiri_dhekelia_2") == true, "no Brineling caught yet")
	h.data.caught["brineling"] = true
	await _run(h, z, "akr_centre_warden", "akr_centre_warden")
	assert_eq(h.data.flag("q_overseas_akrotiri_dhekelia_2"), true)
	h.data.set_flag("trainer_akr_warden")
	await _run(h, z, "akr_centre_warden", "akr_centre_warden")
	assert_eq(h.data.flag("q_overseas_akrotiri_dhekelia_done"), true)
	assert_eq(Bag.new(h.data.bag).count("flamingo_feather"), 1)

func test_quest_flags_are_set_somewhere() -> void:
	for q in ["overseas_brize_norton", "overseas_gibraltar", "overseas_akrotiri_dhekelia"]:
		var d: Dictionary = _json("res://data/quests/%s.json" % q)
		var text := ""
		for f in DirAccess.get_files_at("res://data/dialogue"):
			text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
		for quest in d.quests:
			for s in quest.steps:
				assert_true(text.contains("\"%s\"" % s.flag), "%s is set in the dialogue" % s.flag)
			assert_true(text.contains("\"%s\"" % quest.start_flag) and text.contains("\"%s\"" % quest.done_flag), quest.id)

# ------------------------------------------------------------------ creatures, shops, styles

func test_new_species_are_appendix_placed_and_drawn() -> void:
	var dex := Dex.load_default()
	var order := Array(_json("res://data/dex_order.json"))
	var placed := {}
	for zid in HUB_ZONES + GIB_ZONES + CY_ZONES:
		for table in ZoneData.load_id(zid).encounters.values():
			for e in table:
				placed[str(e.species)] = true
	for sid in NEW_SPECIES:
		assert_true(dex.has(sid), sid)
		var sp := dex.get_species(sid)
		assert_eq(bool(sp.get("appendix", false)), true, sid + " is appendix")
		assert_true(sid in order, sid + " is in dex_order")
		assert_true(placed.has(sid), sid + " is found in the wild")
		for part in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [sid, part]), "%s %s sprite" % [sid, part])
		assert_true(str(sp.dex.text).length() > 60 and str(sp.dex.fact).length() > 60, sid + " dex text")
		assert_true(sp.learnset.size() >= 8, sid + " learnset")
	assert_eq(dex.core_ids().size(), 200, "the appendix leaves the 200 alone")

func test_shops_and_items_exist() -> void:
	var items := ItemDB.load_default()
	for sid in ["brize_norton_corner_shop", "gibraltar_corner_shop", "akrotiri_corner_shop", "dhekelia_corner_shop"]:
		assert_true(items.shops.has(sid), sid)
		for i in items.shops[sid].stock:
			assert_true(items.has(str(i)), "%s stocks %s" % [sid, i])
	for i in ["calentita", "gib_rosto", "gib_fish_chips", "halloumi", "loukoumi", "carob_syrup", "naafi_bacon_roll", "mess_tin_stew", "aircrew_sweets", "siege_cannonball", "flamingo_feather", "parish_airbridge"]:
		assert_true(items.has(i), i)

func test_new_building_styles_are_registered() -> void:
	for s in STYLES:
		assert_true(s in Landmarks.SPECIAL, s)
		assert_true(s in OverseasStyles.STYLES, s)
