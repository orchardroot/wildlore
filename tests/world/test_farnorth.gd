extends TestCase
## The far north (wave 21, region farnorth): the Flow Country, Thurso and the Pentland Coast, hung off Inverness.

const ZONES := ["flow_country", "thurso", "pentland_coast"]
const NEW_SPECIES := ["dubhlet", "flowmoor", "swelklet", "swelkie", "stoorworm", "nuckelavee"]

func test_zones_join_inverness_as_a_cul_de_sac() -> void:
	var inv := ZoneData.load_id("inverness")
	assert_eq(str(inv.edges.north.to), "flow_country")
	var fc := ZoneData.load_id("flow_country")
	assert_eq(str(fc.edges.south.to), "inverness")
	assert_eq(str(fc.edges.north.to), "thurso")
	var th := ZoneData.load_id("thurso")
	assert_eq(str(th.edges.east.to), "pentland_coast")
	var pc := ZoneData.load_id("pentland_coast")
	assert_eq(pc.edges.keys(), ["west"], "the coast is the end of the road")

func test_zones_are_scaled_from_the_frost_band() -> void:
	for zid in ZONES:
		var z := ZoneData.load_id(zid)
		assert_eq(z.scaled_floor, 76, zid)
		assert_eq(z.region, "scotland", zid)
	for path in JsonUtil.list_json("res://data/trainers"):
		var id: String = path.get_file().get_basename()
		if id.begins_with("fc_") or id.begins_with("th_") or id.begins_with("pc_"):
			var t := StoryData.trainer(id)
			assert_eq(int(t.get("scaled_floor", -1)), 76, id)
	assert_eq(int(StoryData.trainer("e2e_cornwall").get("scaled_floor", -1)), 48, "Penzance's own band")

func test_the_bridge_is_shut_until_the_frost_stone() -> void:
	var inv := ZoneData.load_id("inverness")
	var n := 0
	for npc in inv.npcs:
		if str(npc.get("id", "")).begins_with("kessock_"):
			assert_eq(str(npc.hide_if), "badge_frost")
			n += 1
	assert_eq(n, 3)

func test_town_has_the_essentials() -> void:
	var th := ZoneData.load_id("thurso")
	assert_eq(th.town_id, "thurso")
	assert_true(th.station != Vector2i(-1, -1), "Britain's most northerly station")
	assert_eq(str(th.ferry.route), "thurso_kirkwall")
	assert_true(Travel.ferries().has("thurso_kirkwall"))
	assert_true(Travel.world_map().towns.has("thurso"))
	var targets := th.warps.map(func(w): return str(w.to))
	assert_true("thurso_sanctuary" in targets)
	assert_true("thurso_shop" in targets)
	assert_true(targets.size() >= 8, "at least six real places besides the Sanctuary and shop")

func test_plaques_unique_and_plentiful() -> void:
	var seen := {}
	var per_zone := {}
	for zid in ZONES:
		per_zone[zid] = 0
		for s in ZoneData.load_id(zid).signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "duplicate plaque " + str(s.plaque))
				seen[s.plaque] = true
				assert_true(str(s.get("title", "")) != "", str(s.plaque))
				assert_false(str(s.text).contains("—"), "no em-dashes")
				per_zone[zid] += 1
	assert_true(per_zone.thurso >= 8, "8+ plaques in town")
	assert_true(per_zone.flow_country >= 3)
	assert_true(per_zone.pentland_coast >= 3)

func test_every_quest_flag_is_set_somewhere() -> void:
	var q: Dictionary = JsonUtil.read("res://data/quests/farnorth.json")
	var text := ""
	for f in ["flow_country", "forsinard_centre", "thurso", "pentland_coast", "kirkwall", "penzance"]:
		text += FileAccess.get_file_as_string("res://data/dialogue/%s.json" % f)
	assert_eq(q.quests.size(), 4)
	for quest in q.quests:
		var flags := [str(quest.start_flag), str(quest.done_flag)]
		for st in quest.steps:
			flags.append(str(st.flag))
		for fl in flags:
			assert_true(fl.begins_with("q_farnorth_"), fl)
			assert_true(text.contains('"flag": "%s"' % fl), "nothing sets " + fl)

func test_regional_items_are_stocked() -> void:
	var db := ItemDB.load_default()
	for id in ["crowdie_oatcakes", "partan_bree", "groatie_buckie", "bog_myrtle_sprig", "caithness_flagstone", "burn_water_flask"]:
		assert_true(db.has(id), id)
	assert_true("crowdie_oatcakes" in db.shops.thurso_corner_shop.stock)
	assert_true("groatie_buckie" in db.shops.jog_lasthouse.stock)

func test_new_creatures_load_as_appendix_with_art_and_homes() -> void:
	var dex := Dex.load_default()
	var order: Array = JsonUtil.read("res://data/dex_order.json")
	for id in NEW_SPECIES:
		assert_true(dex.has(id), id)
		assert_true(bool(dex.get_species(id).get("appendix", false)), id + " is in the appendix")
		assert_true(id in order, id + " in dex order")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % id), id + " front")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_back.png" % id), id + " back")
	assert_true(bool(dex.get_species("nuckelavee").get("legend", false)))
	var placed := {}
	for zid in ZONES:
		for kind in ZoneData.load_id(zid).encounters.values():
			for e in kind:
				placed[str(e.species)] = true
	for id in ["dubhlet", "swelklet", "stoorworm"]:
		assert_true(placed.has(id), id + " is wild somewhere")
	assert_true(FileAccess.get_file_as_string("res://data/dialogue/pentland_coast.json").contains('"species": "nuckelavee"'))
