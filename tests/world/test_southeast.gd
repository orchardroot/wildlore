extends TestCase
## The South East off London (wave 21): the South Downs and Brighton, the Kent Downs, Canterbury and Dover.

const ZONES := ["south_downs", "brighton", "kent_downs", "canterbury", "dover"]
const TOWNS := ["brighton", "canterbury", "dover"]
const SPECIES := ["knucker", "chalkling", "longman", "hoplet", "oastcowl", "prinny", "flintling", "flintwarden"]

func test_zones_join_london_south_and_east_only() -> void:
	var lon := ZoneData.load_id("london")
	assert_eq(str(lon.edges.south.to), "south_downs")
	assert_eq(str(lon.edges.east.to), "kent_downs")
	assert_eq(str(lon.edges.west.to), "stonehenge", "London's old edge is untouched")
	assert_eq(str(ZoneData.load_id("south_downs").edges.south.to), "brighton")
	assert_eq(str(ZoneData.load_id("kent_downs").edges.east.to), "canterbury")
	assert_eq(str(ZoneData.load_id("canterbury").edges.south.to), "dover")

func test_every_zone_is_scaled_from_londons_band() -> void:
	for id in ZONES:
		var z := ZoneData.load_id(id)
		assert_eq(z.scaled_floor, 94, id + " is scaled")
		assert_eq(z.region, "south_east")
	for t in TOWNS:
		var z := ZoneData.load_id(t)
		assert_true(z.station != Vector2i(-1, -1), t + " has a station")
		var rooms := 0
		for w in z.warps:
			rooms += 1
		assert_true(rooms >= 7, "%s has plenty of doors (%d)" % [t, rooms])

func test_trainers_here_are_scaled() -> void:
	var n := 0
	for path in JsonUtil.list_json("res://data/trainers"):
		var t = JsonUtil.read(path)
		var id := str(t.get("id", ""))
		if id.substr(0, 3) in ["sd_", "br_", "kd_", "cb_", "dv_"]:
			n += 1
			assert_eq(int(t.get("scaled_floor", -1)), 94, id + " is scaled")
	assert_true(n >= 20, "a good crowd of trainers (%d)" % n)

func test_plaques_are_plentiful_and_unique() -> void:
	var seen := {}
	for id in ZONES:
		var count := 0
		for s in ZoneData.load_id(id).signs:
			if s.has("plaque"):
				assert_false(seen.has(s.plaque), "plaque id %s is unique" % s.plaque)
				seen[s.plaque] = true
				assert_true(str(s.get("title", "")) != "", "plaque %s has a title" % s.plaque)
				assert_false("—" in str(s.text), "no em-dashes")
				count += 1
		assert_true(count >= (8 if id in TOWNS else 3), "%s has %d plaques" % [id, count])

func test_new_species_are_appendix_placed_and_drawn() -> void:
	var order = JsonUtil.read("res://data/dex_order.json")
	for sp in SPECIES:
		var d: Dictionary = {}
		for path in JsonUtil.list_json("res://data/creatures"):
			for s in JsonUtil.read(path).get("species", []):
				if str(s.id) == sp:
					d = s
		assert_false(d.is_empty(), sp + " loads")
		assert_true(bool(d.get("appendix", false)), sp + " is in the appendix")
		assert_true(sp in order, sp + " is in dex order")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_front.png" % sp), sp + " front sprite")
		assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_back.png" % sp), sp + " back sprite")
	var placed := {}
	for id in ZONES:
		for kind in ZoneData.load_id(id).encounters:
			for e in ZoneData.load_id(id).encounters[kind]:
				placed[str(e.species)] = true
	for sp in ["chalkling", "hoplet", "prinny", "flintling"]:
		assert_true(placed.has(sp), sp + " is found in the wild here")
	assert_true("legend" in JSON.stringify(JsonUtil.read("res://data/dialogue/south_downs.json")), "the knucker is met at its hole")

func test_every_quest_flag_is_set_by_a_script() -> void:
	var quests: Array = JsonUtil.read("res://data/quests/south_east.json").quests
	assert_eq(quests.size(), 5)
	var text := ""
	for path in JsonUtil.list_json("res://data/dialogue"):
		text += JSON.stringify(JsonUtil.read(path))
	for q in quests:
		var flags: Array = [q.start_flag, q.done_flag]
		for s in q.steps:
			flags.append(s.flag)
		for f in flags:
			assert_true(("\"flag\":\"%s\"" % f) in text.replace(" ", ""), f + " is set somewhere")

func test_regional_items_load() -> void:
	var items := ItemDB.load_default()
	for id in ["brighton_rock", "sussex_pond_pudding", "gypsy_tart", "kentish_hops", "canterbury_ampulla", "mod_target", "bluebird_brooch"]:
		assert_false(items.get_item(id).is_empty(), id + " loads")
