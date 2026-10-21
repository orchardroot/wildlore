extends TestCase
## Overseas, wave 33 agent 4: Bermuda, the Cayman Islands, Turks and Caicos, the British Virgin Islands, Anguilla and
## Montserrat. Each is one big outdoor zone reached through the registry (data/overseas/<id>.json), post-game
## (scaled from par 95), with a Sanctuary, a shop, real-place rooms, plaques, trainers, a quest and new creatures.

const TERRITORIES := {
	"bermuda": "bermuda", "cayman": "cayman", "turks_caicos": "turks_caicos", "bvi": "bvi", "anguilla": "anguilla", "montserrat": "montserrat",
}
const FLOOR := 95
const SPECIES := ["cahowl", "deliverling", "seaventure", "azurana", "raylette", "sandbarray", "conchling", "conchord", "flamingale",
	"bathlet", "bathrock", "rhonewraith", "sloopling", "sloopracer", "saltcrust", "oriolet", "cinderling", "soufrilla"]
const PREFIX := {"bermuda": "bm_", "cayman": "cay_", "turks_caicos": "tci_", "bvi": "bvi_", "anguilla": "angu_", "montserrat": "mont_"}

func _rooms(z: ZoneData) -> Array:
	var out := []
	for w in z.warps:
		out.append(str(w.to))
	return out

func test_registry_files_name_a_real_arrival() -> void:
	var all := ZoneData.load_all()
	for id in TERRITORIES:
		var r = JsonUtil.read("res://data/overseas/%s.json" % id)
		assert_true(r is Dictionary, id + " registry parses")
		assert_eq(str(r.id), id)
		assert_eq(str(r.unlock_flag), "champion", id + " opens after the Moot")
		assert_eq(str(r.via), "raf")
		assert_true(str(r.blurb) != "" and str(r.flight_line) != "", id + " has a blurb and a flight line")
		var z: ZoneData = all[str(r.arrival.zone)]
		assert_true(z.walkable(Vector2i(int(r.arrival.x), int(r.arrival.y))), id + " arrival tile is walkable")

func test_zones_are_post_game_and_have_no_zone_errors() -> void:
	var all := ZoneData.load_all()
	for id in TERRITORIES:
		var z: ZoneData = all[TERRITORIES[id]]
		assert_eq(z.region, "overseas_" + id)
		assert_eq(z.scaled_floor, FLOOR, id + " is scaled from the post-game par")
		assert_eq(z.edges.size(), 0, id + " is an island: no edges")
		for err in z.validate(all):
			assert_true(false, str(err))
		for kind in z.encounters:
			for e in z.encounters[kind]:
				assert_true(int(e.min) >= FLOOR, "%s %s encounter at the floor" % [id, e.species])

func test_each_territory_has_sanctuary_shop_and_real_places() -> void:
	var all := ZoneData.load_all()
	for id in TERRITORIES:
		var rooms := _rooms(all[TERRITORIES[id]])
		var pre: String = {"turks_caicos": "tci", "montserrat": "montserrat"}.get(id, id)
		assert_has(rooms, pre + "_sanctuary")
		assert_has(rooms, pre + "_shop")
		assert_true(rooms.size() >= 7, "%s has %d rooms" % [id, rooms.size()])
		for rid in rooms:
			assert_eq(all[rid].kind, "interior", rid)

func test_plaques_are_unique_plentiful_and_clean() -> void:
	var all := ZoneData.load_all()
	var seen := {}
	for zid in all:
		for s in all[zid].signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
	for id in TERRITORIES:
		var n := 0
		for s in all[TERRITORIES[id]].signs:
			assert_false("—" in str(s.text), "no em-dashes in " + id)
			if s.has("plaque"):
				n += 1
				assert_true(str(s.plaque).begins_with(({"turks_caicos": "tci", "montserrat": "mont", "anguilla": "angu", "cayman": "cayman"}).get(id, id) + "_"), "plaque id namespaced: " + str(s.plaque))
				assert_true(str(s.get("title", "")) != "")
		assert_true(n >= 8, "%s has %d plaques" % [id, n])

func test_trainers_are_scaled_and_there_is_a_legend() -> void:
	var raw_count := {}
	for tid in StoryData.trainer_ids():
		for id in PREFIX:
			if tid.begins_with(PREFIX[id]):
				var raw = JsonUtil.read(StoryData.TRAINER_DIR.path_join(tid + ".json"))
				assert_eq(int(raw.get("scaled_floor", -1)), FLOOR, tid)
				raw_count[id] = int(raw_count.get(id, 0)) + 1
				if str(raw.get("class", "")) == "Local Legend":
					assert_eq(raw.party.size(), 6, tid + " has a full party")
	for id in TERRITORIES:
		assert_true(int(raw_count.get(id, 0)) >= 6, "%s has %d trainers" % [id, int(raw_count.get(id, 0))])

func test_every_quest_flag_is_set_somewhere() -> void:
	var all := ZoneData.load_all()
	for id in TERRITORIES:
		var qf = JsonUtil.read("res://data/quests/overseas_%s.json" % id)
		assert_true(qf is Dictionary and qf.quests.size() >= 1, id + " has a quest")
		var text := FileAccess.get_file_as_string("res://data/dialogue/%s.json" % TERRITORIES[id])
		for rid in _rooms(all[TERRITORIES[id]]):
			if FileAccess.file_exists("res://data/dialogue/%s.json" % rid):
				text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % rid)
		for q in qf.quests:
			var flags := [str(q.start_flag), str(q.done_flag)]
			for s in q.steps:
				flags.append(str(s.flag))
			assert_true(q.steps.size() >= 3, "a chain of steps")
			for f in flags:
				assert_true(f.begins_with("q_overseas_%s_" % id), f + " is namespaced")
				assert_true(('"flag": "%s"' % f) in text, f + " is set by a script")

func test_regional_items_and_shop_stock() -> void:
	var items := ItemDB.load_default()
	var shops := {"bermuda": "bermuda_corner_shop", "cayman": "cayman_corner_shop", "turks_caicos": "tci_corner_shop", "bvi": "bvi_corner_shop",
		"anguilla": "anguilla_corner_shop", "montserrat": "montserrat_corner_shop"}
	for id in shops:
		var stock: Array = items.shops[shops[id]].stock
		assert_true(stock.size() >= 12, shops[id])
		for item in stock:
			assert_true(items.has(str(item)), "%s stocks a real item: %s" % [shops[id], item])
	for id in ["longtail_feather", "silver_thatch_bracelet", "conch_shell_horn", "doubloon_charm", "race_pennant", "pumice_charm", "cay_squid", "tci_saw", "bvi_map", "mont_ash_sample"]:
		assert_true(items.has(id), id)

func test_new_creatures_are_appendix_with_sprites_and_homes() -> void:
	var dex := Dex.load_default()
	var all := ZoneData.load_all()
	var order = JsonUtil.read("res://data/dex_order.json")
	var placed := {}
	for id in TERRITORIES:
		for kind in all[TERRITORIES[id]].encounters:
			for e in all[TERRITORIES[id]].encounters[kind]:
				placed[str(e.species)] = true
	for id in SPECIES:
		assert_true(dex.has(id), id)
		assert_true(bool(dex.get_species(id).get("appendix", false)), id + " is in the appendix")
		for part in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [id, part]), "%s %s" % [id, part])
		assert_has(order, id)
		assert_true(placed.has(id), id + " turns up in a territory")
	assert_true(SPECIES.size() >= 18)

func test_dialogue_has_no_em_dashes() -> void:
	for f in DirAccess.get_files_at("res://data/dialogue"):
		for id in PREFIX:
			var base := f.get_basename()
			if base == TERRITORIES[id] or base.begins_with(TERRITORIES[id] + "_") or base.begins_with(({"turks_caicos": "tci", "montserrat": "montserrat"}).get(id, id) + "_"):
				assert_false("—" in FileAccess.get_file_as_string("res://data/dialogue/" + f), f)
