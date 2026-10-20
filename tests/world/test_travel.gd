extends TestCase

func test_rail_destinations_only_visited() -> void:
	var d := GameStateData.new()
	assert_eq(Travel.rail_destinations(d, "buxton"), [])
	d.set_flag(Travel.station_flag("macclesfield"))
	d.set_flag(Travel.station_flag("buxton"))
	assert_eq(Travel.rail_destinations(d, "buxton"), ["macclesfield"], "never the town you're in")
	d.set_flag(Travel.station_flag("atlantis"))
	assert_false("atlantis" in Travel.rail_destinations(d, "buxton"), "only towns whose zone exists")

func test_note_visit_sets_station_and_town() -> void:
	var d := GameStateData.new()
	var z := ZoneData.from_dict({"id": "t", "name": "T", "kind": "town", "town_id": "t", "rows": ["..."], "spawn": [0, 0], "station": {"x": 1, "y": 0}})
	Travel.note_visit(d, z)
	assert_true(d.flag(Travel.station_flag("t")))
	assert_true(d.flag("visited_t"))
	assert_eq(d.flag("last_town"), "t")

func test_travel_arrival_walkable() -> void:
	var all := ZoneData.load_all()
	for zid in all:
		var z: ZoneData = all[zid]
		if z.station != Vector2i(-1, -1):
			var a := Travel.rail_arrival(zid)
			assert_eq(a.zone, zid)
			assert_true(z.walkable(a.pos), "station arrival in " + zid)
	for route in Travel.ferries():
		for end in ["a", "b"]:
			var town: String = Travel.ferries()[route][end]
			if all.has(town):
				var arr := Travel.ferry_arrival(route, Travel.ferries()[route]["b" if end == "a" else "a"])
				assert_eq(arr.zone, town)
				assert_true(all[town].walkable(arr.pos), "ferry arrival in " + town)

func test_world_map_has_all_spec_towns() -> void:
	var m := Travel.world_map()
	assert_true(m.towns.size() >= 42, "the 40 spec towns plus the ferry ports Holyhead and Cairnryan")
	for t in ["macclesfield", "london", "cardiff", "kirkwall", "dingle", "douglas", "newgrange", "bushmills"]:
		assert_true(m.towns.has(t), t)
	assert_true(m.outlines.gb.size() >= 60)
	assert_true(m.outlines.ireland.size() >= 30)

func test_rail_stays_on_island() -> void:
	var d := GameStateData.new()
	for t in ["cardiff", "dublin", "liverpool"]:
		d.set_flag(Travel.station_flag(t))
	assert_eq(Travel.island_of("dublin"), "ireland")
	assert_eq(Travel.island_of("cardiff"), "gb")
	assert_false("dublin" in Travel.rail_destinations(d, "liverpool"), "no train across the Irish Sea")
	assert_false("cardiff" in Travel.rail_destinations(d, "dublin"))

func test_northern_islands() -> void:
	assert_eq(Travel.island_of("belfast"), "ireland")
	assert_eq(Travel.island_of("derry"), "ireland")
	assert_eq(Travel.island_of("glasgow"), "gb")
	assert_eq(Travel.island_of("kirkwall"), "orkney")
	assert_true(Travel.ferries().has("belfast_cairnryan"))
	assert_true(Travel.ferries().has("aberdeen_kirkwall"))

func test_fly_goes_anywhere_visited_across_the_sea() -> void:
	var d := GameStateData.new()
	for t in ["macclesfield", "dublin", "inverness"]:
		d.set_flag("visited_" + t)
	var dest := Travel.fly_destinations(d, "macclesfield")
	assert_true("dublin" in dest, "across the Irish Sea")
	assert_true("inverness" in dest)
	assert_false("macclesfield" in dest, "not where you are")
	assert_false("york" in dest, "not unvisited")
	var a := Travel.fly_arrival("dublin")
	assert_true(ZoneData.load_id("dublin").walkable(a.pos))

func test_fly_lists_the_last_town_when_you_are_elsewhere() -> void:
	var d := GameStateData.new()
	d.set_flag("visited_london")
	d.set_flag("last_town", "london")
	assert_true("london" in Travel.fly_destinations(d, ""), "standing in Mum's house (no town_id), London is listed")
	assert_false("london" in Travel.fly_destinations(d, "london"), "but not when you are in it")
	assert_eq(ZoneData.load_id("macc_home").town_id, "", "Mum's house is not in a town")
