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
	assert_eq(m.towns.size(), 40)
	for t in ["macclesfield", "london", "cardiff", "kirkwall", "dingle", "douglas", "newgrange", "bushmills"]:
		assert_true(m.towns.has(t), t)
	assert_true(m.outlines.gb.size() >= 60)
	assert_true(m.outlines.ireland.size() >= 30)
