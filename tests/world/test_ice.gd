extends TestCase
## The far south (3.3 "Overseas", wave 33): South Georgia and the South Sandwich Islands, and the British Antarctic
## Territory. Reached by the RAF's flights (data/overseas/*.json), so every zone is scaled at the post-game par.

const SG := ["grytviken", "sg_salisbury"]
const BAT := ["port_lockroy", "rothera", "brunt_shelf"]
const FLOOR := 95
const NEW := ["oakling", "kingwalker", "slabpup", "beachmaster", "tussipit", "downlet", "emperyn", "clearfin"]

func _zones() -> Dictionary:
	return ZoneData.load_all()

func _rooms(all: Dictionary, towns: Array) -> Array:
	var out := []
	for t in towns:
		for w in all[t].warps:
			out.append(str(w.to))
	return out

func test_zones_validate_and_are_scaled() -> void:
	var all := _zones()
	for zid in SG + BAT:
		var z: ZoneData = all[zid]
		assert_eq(z.validate(all), [], zid)
		assert_eq(z.scaled_floor, FLOOR, zid + " is post-game")
		assert_true(z.region.begins_with("overseas_"), zid + " has an overseas region")
	for zid in SG:
		assert_eq(all[zid].region, "overseas_south_georgia", zid)
	for zid in BAT:
		assert_eq(all[zid].region, "overseas_antarctic", zid)
	assert_eq(all.grytviken.edges.east.to, "sg_salisbury")
	assert_eq(all.rothera.edges.west.to, "port_lockroy")
	assert_eq(all.rothera.edges.east.to, "brunt_shelf")

func test_registry_files_point_at_real_arrivals() -> void:
	var all := _zones()
	for pair in [["south_georgia", "grytviken"], ["antarctic", "rothera"]]:
		var d = JsonUtil.read("res://data/overseas/%s.json" % pair[0])
		assert_true(d is Dictionary, pair[0])
		assert_eq(d.id, pair[0])
		assert_eq(d.arrival.zone, pair[1])
		assert_true(all[pair[1]].walkable(Vector2i(int(d.arrival.x), int(d.arrival.y))), "arrival tile is walkable")
		assert_eq(d.via, "raf")
		assert_eq(d.unlock_flag, "champion")
		assert_true(str(d.blurb) != "" and str(d.flight_line) != "")

func test_towns_have_a_sanctuary_shop_and_four_rooms() -> void:
	var all := _zones()
	for town in ["grytviken", "port_lockroy", "rothera"]:
		var rooms := _rooms(all, [town])
		assert_has(rooms, town + "_sanctuary")
		assert_has(rooms, town + "_shop")
		assert_true(rooms.size() >= 4, "%s has %d rooms" % [town, rooms.size()])
	assert_true(_rooms(all, ["grytviken"]).size() >= 6, "Grytviken has six rooms")

func test_plaques_are_unique_accurate_looking_and_plentiful() -> void:
	var all := _zones()
	var seen := {}
	for zid in all:
		for s in all[zid].signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
	var counts := {"south_georgia_": 0, "antarctic_": 0}
	for zid in SG + BAT:
		for s in all[zid].signs:
			if s.has("plaque"):
				assert_true(str(s.get("title", "")) != "", "plaque %s has a title" % s.plaque)
				assert_false("—" in str(s.text), "no em-dashes")
				for k in counts:
					if str(s.plaque).begins_with(k):
						counts[k] += 1
	assert_true(counts["south_georgia_"] >= 8 and counts["antarctic_"] >= 8, "8+ plaques per territory: %s" % [counts])

func test_trainers_are_scaled_and_there_is_a_legend_each() -> void:
	var n := {"sg_": 0, "bat_": 0}
	for tid in StoryData.trainer_ids():
		for k in n:
			if tid.begins_with(k):
				n[k] += 1
				var raw = JsonUtil.read(StoryData.TRAINER_DIR.path_join(tid + ".json"))
				assert_eq(int(raw.get("scaled_floor", -1)), FLOOR, tid)
				assert_false("—" in JSON.stringify(raw), tid + " has no em-dashes")
	assert_true(n["sg_"] >= 4 and n["bat_"] >= 4, "four or more trainers each: %s" % [n])
	assert_eq(JsonUtil.read(StoryData.TRAINER_DIR.path_join("sg_cook.json")).party.size(), 6, "Cook has a full party")
	assert_eq(JsonUtil.read(StoryData.TRAINER_DIR.path_join("bat_oldfid.json")).party.size(), 6, "the Old Fid has a full party")

func test_every_quest_flag_is_set_somewhere() -> void:
	var text := ""
	for f in SG + BAT + ["grytviken_museum", "grytviken_shop", "grytviken_lab", "salisbury_hut", "port_lockroy_post", "rothera_lab", "rothera_hangar", "brunt_hub"]:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % f)
	for pair in [["overseas_south_georgia", "q_overseas_south_georgia_"], ["overseas_antarctic", "q_overseas_antarctic_"]]:
		var quests = JsonUtil.read("res://data/quests/%s.json" % pair[0])
		assert_true(quests is Dictionary and quests.quests.size() >= 2, pair[0])
		for q in quests.quests:
			var flags := [str(q.start_flag), str(q.done_flag)]
			for s in q.steps:
				flags.append(str(s.flag))
			for f in flags:
				assert_true(f.begins_with(pair[1]), f + " is namespaced")
				assert_true(('"flag": "%s"' % f) in text, f + " is set by a script")

func test_new_creatures_are_appendix_with_sprites_and_homes() -> void:
	var dex := Dex.load_default()
	var all := _zones()
	var order = JsonUtil.read("res://data/dex_order.json")
	for id in NEW:
		assert_true(dex.has(id), id)
		assert_true(bool(dex.get_species(id).get("appendix", false)), id + " is in the appendix")
		for k in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [id, k]), id + " " + k)
		assert_has(order, id)
	var placed := {}
	for zid in SG + BAT:
		for kind in all[zid].encounters:
			for e in all[zid].encounters[kind]:
				placed[str(e.species)] = true
	for id in NEW:
		assert_true(placed.has(id), id + " lives somewhere in the far south")

func test_regional_items_and_shops() -> void:
	var items := ItemDB.load_default()
	for id in ["ships_biscuit", "whalers_pea_soup", "hot_blackcurrant", "hip_flask", "boss_tot", "pemmican", "midwinter_dinner", "fids_hat", "mail_sack"]:
		assert_true(items.has(id), id)
	for shop in ["grytviken_corner_shop", "port_lockroy_gift_shop", "rothera_station_shop"]:
		assert_true(items.shops.has(shop), shop)
	assert_has(items.shops.grytviken_corner_shop.stock, "ships_biscuit")
	assert_has(items.shops.port_lockroy_gift_shop.stock, "fids_hat")

func test_postcards_for_both_territories() -> void:
	assert_true(Postcards.card_index("grytviken") >= 0 and Postcards.card_index("port_lockroy") >= 0)
