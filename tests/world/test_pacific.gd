extends TestCase
## Wave 33, agent 5: the Pitcairn Islands (Adamstown, Henderson Island) and the British Indian Ocean Territory
## (Diego Garcia, East Point), off the main line and reached from the overseas registry. Registry files, zones,
## scaling, the quests, the plaques, the new creatures and the landmarks.

const PIT := ["adamstown", "henderson_island"]
const BIOT := ["diego_garcia", "east_point"]
const PIT_INT := ["pit_clinic", "pit_store", "pit_church", "pit_post", "pit_hall", "pit_honey", "pit_boathouse", "pit_cave"]
const BIOT_INT := ["biot_sick", "biot_store", "biot_tower", "biot_hq", "biot_galley", "biot_marina", "biot_hut", "biot_chapel", "biot_manager", "biot_copra"]
const TRAINERS := ["pit_coxswain", "pit_beekeeper", "pit_carver", "pit_ham", "pit_legend", "pit_longboat", "pit_ranger", "pit_castaway",
	"biot_flight", "biot_marine", "biot_chief", "biot_stores", "biot_legend", "biot_birder", "biot_diver"]
const NEW_SPECIES := ["charkeel", "bountyflame", "crakeling", "hendercrake", "driftmaw", "cocoshell", "coconabber", "wideling", "wideawake", "ravanne"]
const STYLES := ["pitcairn_house", "boat_shed", "base_hangar", "base_tower", "base_block", "plantation_ruin", "island_church"]

func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _run(h: FakeStoryHost, zone: String, script: String, owner := "") -> void:
	StoryData.clear_cache()
	await Commands.new(h, owner).run(StoryData.script(zone, script))

# ------------------------------------------------------------------ the registry

func test_registry_files_parse_and_arrive_somewhere_real() -> void:
	for id in ["pitcairn", "biot"]:
		var d: Dictionary = _json("res://data/overseas/%s.json" % id)
		assert_eq(str(d.id), id)
		assert_eq(str(d.via), "raf")
		assert_eq(str(d.unlock_flag), "champion")
		assert_true(str(d.blurb) != "" and str(d.flight_line) != "")
		var z := ZoneData.load_id(str(d.arrival.zone))
		assert_true(z.width > 0, "the arrival zone exists")
		assert_true(z.walkable(Vector2i(int(d.arrival.x), int(d.arrival.y))), id + " arrives on walkable ground")
		assert_false("—" in JSON.stringify(d), "no em-dashes")

# ------------------------------------------------------------------ geography

func test_zones_are_scaled_overseas_and_islands() -> void:
	for id in PIT + BIOT:
		var z := ZoneData.load_id(id)
		assert_eq(z.parse_errors.size(), 0, id)
		assert_eq(z.scaled_floor, 95, id + " is post-game")
		assert_true(z.region == "overseas_pitcairn" or z.region == "overseas_biot", id)
		assert_true(z.walkable(z.spawn), id + " spawn")
	assert_eq(ZoneData.load_id("adamstown").edges.size(), 0, "Pitcairn has no neighbours but the sea")
	for id in PIT_INT + BIOT_INT:
		var z := ZoneData.load_id(id)
		assert_eq(z.kind, "interior", id)
		assert_eq(z.parse_errors.size(), 0, id)

func test_diego_garcia_and_east_point_join_up() -> void:
	var d := ZoneData.load_id("diego_garcia")
	var e := ZoneData.load_id("east_point")
	assert_eq(str(d.edges.north.to), "east_point")
	assert_eq(str(e.edges.south.to), "diego_garcia")
	for x in range(58, 61):
		var arr := d.edge_arrival("north", Vector2i(x, 0), e)
		assert_true(d.walkable(Vector2i(x, 0)), "the gap on Diego Garcia's north tip is open at %d" % x)
		assert_true(e.walkable(arr), "north off Diego Garcia at %d lands on East Point's road" % x)
		assert_eq(e.edge_arrival("south", arr, d), Vector2i(x, 0), "and the way back lines up")

func test_towns_have_a_sanctuary_a_shop_and_places() -> void:
	for pair in [["adamstown", "pit_clinic", "pit_store", PIT_INT], ["diego_garcia", "biot_sick", "biot_store", BIOT_INT]]:
		var z := ZoneData.load_id(pair[0])
		var to := []
		for w in z.warps:
			to.append(str(w.to))
		assert_has(to, pair[1])
		assert_has(to, pair[2])
		var places := 0
		for t in to:
			if t in pair[3] and t != pair[1] and t != pair[2]:
				places += 1
		assert_true(places >= 4, "%s has 4+ places to go in besides the sanctuary and shop" % pair[0])
	for id in ["pit_clinic", "biot_sick"]:
		var text := FileAccess.get_file_as_string("res://data/dialogue/%s.json" % id)
		assert_true(text.contains("\"heal\""), id + " heals")
	assert_true(ZoneData.load_id("east_point").warps.size() >= 3, "East Point has its chapel, manager's house and drying shed")

func test_shops_stock_three_local_items() -> void:
	var items := ItemDB.load_default()
	for pair in [["pitcairn_store", ["pitcairn_honey", "pitcairn_orange", "pawpaw"]], ["biot_mess_store", ["chagos_coconut_water", "chagos_fish_curry", "navy_brew"]]]:
		var shop: Dictionary = _json("res://data/shops/%s.json" % pair[0])
		for s in shop.stock:
			assert_true(items.has(str(s)), "%s stocks a real item: %s" % [pair[0], s])
		for l in pair[1]:
			assert_has(shop.stock, l)

# ------------------------------------------------------------------ trainers, plaques, sprites

func test_trainers_are_scaled_with_real_teams() -> void:
	var dex := Dex.load_default()
	for t in TRAINERS:
		var d: Dictionary = _json("res://data/trainers/%s.json" % t)
		assert_eq(int(d.get("scaled_floor", -1)), 95, t + " is scaled")
		for p in d.party:
			assert_true(dex.has(str(p.species)), "%s: %s exists" % [t, p.species])
			assert_true(int(p.level) >= 93, t)
	assert_eq((_json("res://data/trainers/pit_legend.json") as Dictionary).party.size(), 6, "Lookout Lorna has a full team")
	assert_eq((_json("res://data/trainers/biot_legend.json") as Dictionary).party.size(), 6, "Bosun Cato has a full team")
	for z in ["adamstown", "henderson_island", "diego_garcia", "east_point"]:
		var n := 0
		for npc in ZoneData.load_id(z).npcs:
			if npc.has("trainer"):
				n += 1
				assert_true(TRAINERS.has(str(npc.trainer)), str(npc.trainer))
		assert_true(n >= 2, z + " has trainers")

func test_plaques_are_unique_plentiful_and_dash_free() -> void:
	var seen := {}
	var count := {"pitcairn": 0, "biot": 0}
	for zid in PIT + BIOT + PIT_INT + BIOT_INT:
		for s in ZoneData.load_id(zid).signs:
			assert_false("—" in str(s.text), "no em-dashes")
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
				assert_true(str(s.get("title", "")) != "")
				var terr := "pitcairn" if str(s.plaque).begins_with("pitcairn_") else "biot"
				assert_true(str(s.plaque).begins_with(terr + "_"), "%s is prefixed with its territory" % s.plaque)
				count[terr] += 1
	assert_true(count.pitcairn >= 8, "8+ Pitcairn plaques")
	assert_true(count.biot >= 8, "8+ BIOT plaques")
	var removal := false
	for s in ZoneData.load_id("east_point").signs:
		if str(s.get("plaque", "")) == "biot_removal":
			removal = "1967" in str(s.text) and "1973" in str(s.text) and "removed" in str(s.text)
	assert_true(removal, "the removal of the Chagossians is told plainly")

func test_new_species_load_and_have_sprites_and_homes() -> void:
	var dex := Dex.load_default()
	var placed := {}
	for id in PIT + BIOT:
		var z := ZoneData.load_id(id)
		for kind in z.encounters:
			for e in z.encounters[kind]:
				placed[str(e.species)] = true
	for id in NEW_SPECIES:
		assert_true(dex.has(id), id)
		var sp := dex.get_species(id)
		assert_true(sp.get("appendix", false) == true, id + " is in the appendix")
		assert_false(id in dex.core_ids(), id + " does not count towards the 200")
		assert_true(str(sp.dex.text) != "" and str(sp.dex.fact) != "", id)
		assert_false(str(sp.dex.text).contains("—") or str(sp.dex.fact).contains("—"), "no em-dashes: " + id)
		for suffix in ["front", "back", "icon"]:
			assert_true(ResourceLoader.exists("res://art/sprites/creatures/%s_%s.png" % [id, suffix]), "%s %s sprite" % [id, suffix])
		assert_true(placed.has(id), id + " is placed in a zone")
		var bst := 0
		for k in sp.base:
			bst += int(sp.base[k])
		assert_true(bst >= 280 and bst <= 500, "%s base stats total %d" % [id, bst])
	assert_eq(str(dex.get_species("charkeel").evolves.to), "bountyflame")
	assert_eq(str(dex.get_species("crakeling").evolves.to), "hendercrake")
	assert_eq(str(dex.get_species("cocoshell").evolves.to), "coconabber")
	assert_eq(str(dex.get_species("wideling").evolves.to), "wideawake")

func test_landmarks_and_zones_build() -> void:
	for style in STYLES:
		var out: Array = Meshes.building(7, 5, style, 3, 7, "overseas_pitcairn")
		assert_true(out[0] is ArrayMesh and (out[0] as ArrayMesh).get_surface_count() > 0, style + " has a mesh")
	var palm := Meshes.palm(1)
	assert_true(palm.get_surface_count() > 0, "the palm has a mesh")
	for id in PIT + BIOT:
		var root := ZoneBuilder.build(ZoneData.load_id(id))
		assert_true(root.get_child_count() > 0, id + " builds")
		root.free()

# ------------------------------------------------------------------ quests

func test_every_quest_flag_is_set_by_some_script() -> void:
	var text := ""
	for f in DirAccess.get_files_at("res://data/dialogue"):
		if f.begins_with("adamstown") or f.begins_with("pit_") or f.begins_with("diego_garcia") or f.begins_with("east_point") or f.begins_with("biot_") or f.begins_with("henderson"):
			text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
	for pair in [["overseas_pitcairn", "q_overseas_pitcairn_"], ["overseas_biot", "q_overseas_biot_"]]:
		var quests: Array = (_json("res://data/quests/%s.json" % pair[0]) as Dictionary).quests
		assert_true(quests.size() >= 1)
		for q in quests:
			var flags: Array = [q.start_flag, q.done_flag]
			for s in q.steps:
				flags.append(s.flag)
			for fl in flags:
				assert_true(str(fl).begins_with(pair[1]), fl)
				assert_true(text.contains("\"%s\"" % fl), "%s is set in the dialogue" % fl)

func test_every_npc_script_exists() -> void:
	StoryData.clear_cache()
	for zid in PIT + BIOT + PIT_INT + BIOT_INT:
		for n in ZoneData.load_id(zid).npcs:
			if n.has("script"):
				assert_false(StoryData.script(zid, str(n.script)).is_empty(), "%s: script %s" % [zid, n.script])

func test_pitcairn_cover_for_the_ship() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "adamstown", "pit_elder", "pit_elder")
	assert_eq(h.data.flag("q_overseas_pitcairn_started"), true)
	await _run(h, "pit_post", "pit_postmaster", "pit_postmaster")
	assert_eq(h.data.flag("q_overseas_pitcairn_1"), true)
	assert_eq(Bag.new(h.data.bag).count("first_day_cover"), 1)
	await _run(h, "adamstown", "pit_ship", "pit_ship")
	assert_eq(h.last_battle.opts.trainer.id, "pit_longboat", "Rua tests you first")
	assert_eq(h.data.flag("q_overseas_pitcairn_2"), true)
	await _run(h, "adamstown", "pit_elder", "pit_elder")
	assert_false(h.data.flag("q_overseas_pitcairn_done") == true, "no Charkeel, no thanks")
	h.data.mark_caught("charkeel")
	await _run(h, "adamstown", "pit_elder", "pit_elder")
	assert_eq(h.data.flag("q_overseas_pitcairn_done"), true)
	assert_eq(Bag.new(h.data.bag).count("miro_carving"), 1)

func test_biot_before_the_visit() -> void:
	var h := FakeStoryHost.new()
	await _run(h, "biot_hq", "biot_officer", "biot_officer")
	assert_eq(h.data.flag("q_overseas_biot_started"), true)
	await _run(h, "biot_marina", "biot_boat_keeper", "biot_boat_keeper")
	assert_eq(h.last_battle.opts.trainer.id, "biot_stores")
	assert_eq(h.data.flag("q_overseas_biot_1"), true)
	assert_eq(Bag.new(h.data.bag).count("grave_kit"), 1)
	h.data.clock_minutes = 12 * 60
	await _run(h, "east_point", "biot_warden", "biot_warden")
	assert_false(h.data.flag("q_overseas_biot_2") == true, "the drum plays at dusk, not noon")
	h.data.clock_minutes = 19 * 60
	await _run(h, "east_point", "biot_warden", "biot_warden")
	assert_eq(h.data.flag("q_overseas_biot_2"), true)
	await _run(h, "east_point", "biot_warden", "biot_warden")
	assert_false(h.data.flag("q_overseas_biot_done") == true, "heard is not caught")
	h.data.mark_caught("ravanne")
	await _run(h, "east_point", "biot_warden", "biot_warden")
	assert_eq(h.data.flag("q_overseas_biot_done"), true)
	assert_eq(Bag.new(h.data.bag).count("ravanne_charm"), 1)

func test_return_desks_say_their_piece() -> void:
	for zid in ["adamstown", "diego_garcia", "east_point"]:
		var h := FakeStoryHost.new()
		h.choices = [0]
		await _run(h, zid, "raf_home", "x")
		assert_eq(str(h.data.flag("overseas_return")), "pitcairn" if zid == "adamstown" else "biot", zid)
