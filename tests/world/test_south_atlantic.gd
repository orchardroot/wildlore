extends TestCase
## 3.3 "Overseas", wave 33: the South Atlantic (Ascension, St Helena, Tristan da Cunha, the Falkland Islands). Reached from
## the RAF registry (data/overseas), every zone and trainer scaled at post-game par, quests wired to real flags.

const FLOOR := 95
const TERRITORIES := {
	"ascension": {"outdoor": ["ascension", "ascension_green_mountain"], "town": "ascension", "trainer_prefix": "asc_", "quest": "ascension"},
	"st_helena": {"outdoor": ["st_helena_jamestown", "st_helena_plantation"], "town": "st_helena_jamestown", "trainer_prefix": "sth_", "quest": "st_helena"},
	"tristan": {"outdoor": ["tristan_da_cunha"], "town": "tristan_da_cunha", "trainer_prefix": "tri_", "quest": "tristan"},
	"falklands": {"outdoor": ["falklands_stanley", "falklands_camp"], "town": "falklands_stanley", "trainer_prefix": "fal_", "quest": "falklands"},
}
const LINES := {"cindershell": ["cindershell", "ashmantle"], "mistfrond": ["mistfrond"], "plodlet": ["plodlet", "elderplod"], "wirefoot": ["wirefoot"],
	"hopperlet": ["hopperlet", "rockhopper"], "crawfisher": ["crawfisher"], "thumbrail": ["thumbrail"], "warrah": ["warrah"], "pandolph": ["pandolph"],
	"johnnyrook": ["johnnyrook"]}

func _rooms(all: Dictionary, town: String) -> Array:
	var rooms := []
	for w in all[town].warps:
		rooms.append(str(w.to))
	return rooms

func test_registry_files_parse_and_arrive_in_a_real_zone() -> void:
	var all := ZoneData.load_all()
	for t in TERRITORIES:
		var reg = JsonUtil.read("res://data/overseas/%s.json" % t)
		assert_true(reg is Dictionary, t + " registry parses")
		assert_eq(str(reg.id), t)
		assert_eq(str(reg.unlock_flag), "champion")
		assert_true(["raf", "ferry"].has(str(reg.via)), t + " via")
		assert_true(all.has(str(reg.arrival.zone)), t + " arrival zone exists")
		assert_true(all[str(reg.arrival.zone)].walkable(Vector2i(int(reg.arrival.x), int(reg.arrival.y))), t + " arrival tile is walkable")
		assert_true(str(reg.blurb) != "" and str(reg.flight_line) != "")
		assert_false("—" in str(reg.blurb) + str(reg.flight_line), "no em-dashes")

func test_zones_validate_and_are_scaled_at_post_game_par() -> void:
	var all := ZoneData.load_all()
	for t in TERRITORIES:
		for zid in TERRITORIES[t].outdoor:
			var z: ZoneData = all[zid]
			assert_eq(z.validate(all), [], zid)
			assert_eq(z.scaled_floor, FLOOR, zid + " is scaled")
			assert_eq(z.region, "overseas_" + t, zid + " region")

func test_each_territory_has_sanctuary_shop_and_four_real_rooms() -> void:
	var all := ZoneData.load_all()
	for t in TERRITORIES:
		var town: String = TERRITORIES[t].town
		var rooms := _rooms(all, town)
		assert_has(rooms, town + "_sanctuary")
		assert_has(rooms, town + "_shop")
		var others := 0
		for zid in TERRITORIES[t].outdoor:
			for r in _rooms(all, zid):
				if not str(r).ends_with("_sanctuary") and not str(r).ends_with("_shop"):
					others += 1
		assert_true(others >= 4, "%s has %d other rooms" % [t, others])

func test_plaques_are_unique_accurate_in_form_and_plentiful() -> void:
	var all := ZoneData.load_all()
	var seen := {}
	for zid in all:
		for s in all[zid].signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
	for t in TERRITORIES:
		var n := 0
		for zid in TERRITORIES[t].outdoor:
			for s in all[zid].signs:
				if s.has("plaque"):
					n += 1
					assert_true(str(s.get("title", "")) != "", "plaque %s has a title" % s.plaque)
					assert_false("—" in str(s.text), "no em-dashes in " + str(s.plaque))
		assert_true(n >= 8, "%s has %d plaques" % [t, n])

func test_trainers_are_scaled_and_each_territory_has_a_legend() -> void:
	for t in TERRITORIES:
		var n := 0
		var biggest := 0
		for tid in StoryData.trainer_ids():
			if tid.begins_with(str(TERRITORIES[t].trainer_prefix)):
				var raw = JsonUtil.read(StoryData.TRAINER_DIR.path_join(tid + ".json"))
				assert_eq(int(raw.get("scaled_floor", -1)), FLOOR, tid)
				n += 1
				biggest = maxi(biggest, raw.party.size())
		assert_true(n >= 4, "%s has %d trainers" % [t, n])
		assert_true(biggest >= 6, t + " has a local legend with a full party")

func test_every_quest_flag_is_set_somewhere() -> void:
	for t in TERRITORIES:
		var quests = JsonUtil.read("res://data/quests/overseas_%s.json" % TERRITORIES[t].quest)
		assert_true(quests is Dictionary and quests.quests.size() >= 1, t)
		var text := ""
		for f in DirAccess.get_files_at("res://data/dialogue"):
			if f.begins_with(str(TERRITORIES[t].town).replace("_jamestown", "").replace("_stanley", "").replace("_da_cunha", "")) or f.begins_with(t):
				text += FileAccess.get_file_as_string("res://data/dialogue/" + f)
		for q in quests.quests:
			var flags := [str(q.start_flag), str(q.done_flag)]
			for s in q.steps:
				flags.append(str(s.flag))
			for f in flags:
				assert_true(f.begins_with("q_overseas_%s_" % t), f + " is namespaced")
				assert_true(('"flag": "%s"' % f) in text, f + " is set by a script in " + t)

func test_new_creatures_are_appendix_with_sprites_and_homes() -> void:
	var dex := Dex.load_default()
	var all := ZoneData.load_all()
	var order = JsonUtil.read("res://data/dex_order.json")
	var homes := {}
	for t in TERRITORIES:
		for zid in TERRITORIES[t].outdoor:
			for kind in all[zid].encounters:
				for e in all[zid].encounters[kind]:
					homes[str(e.species)] = true
	for line in LINES:
		for id in LINES[line]:
			assert_true(dex.has(id), id)
			var sp: Dictionary = dex.get_species(id)
			assert_true(bool(sp.get("appendix", false)), id + " is in the appendix")
			assert_has(order, id)
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % id), id + " front")
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_back.png" % id), id + " back")
			assert_true(str(sp.dex.fact) != "" and str(sp.dex.text) != "", id + " has dex text and a fact")
			assert_false("—" in str(sp.dex.text) + str(sp.dex.fact), "no em-dashes")
		assert_true(homes.has(LINES[line][0]), line + " lives in a South Atlantic zone")

func test_regional_items_and_shops() -> void:
	var items := ItemDB.load_default()
	for id in ["wahoo_steak", "dampiers_drip", "turtle_tag", "st_helena_fishcake", "st_helena_coffee", "willow_sprig", "tristan_potato", "crawfish_tail",
			"tristan_hat", "diddle_dee_jam", "smoko_scone", "smoko_hamper", "gentoo_pebble"]:
		assert_true(items.has(id), id)
	for t in TERRITORIES:
		var shop: Dictionary = items.shops["%s_corner_shop" % TERRITORIES[t].town]
		assert_true(shop.stock.size() >= 7, t + " shop stock")
		for id in shop.stock:
			assert_true(items.has(id), "%s sells a real item %s" % [t, id])
	assert_has(items.shops.ascension_corner_shop.stock, "wahoo_steak")
	assert_has(items.shops.falklands_stanley_corner_shop.stock, "diddle_dee_jam")

func test_overseas_standing_is_wired_when_the_nation_exists() -> void:
	# the nation itself belongs to the RAF hub; these zones only ask for it once it exists
	var text := FileAccess.get_file_as_string("res://data/dialogue/ascension.json")
	if Standing.is_nation("overseas"):
		assert_true('"nation": "overseas"' in text, "quest rewards pay standing with the Overseas Territories")
	else:
		assert_false('"nation": "overseas"' in text, "no standing command until the nation exists")

func test_south_atlantic_buildings_build() -> void:
	for style in SouthAtlanticStyles.STYLES:
		assert_has(Landmarks.SPECIAL, style)
		var mesh = Landmarks.building(6, 4, style, 2, 7)
		assert_true(mesh is Array and mesh.size() >= 2 and mesh[0] != null, style + " builds")
