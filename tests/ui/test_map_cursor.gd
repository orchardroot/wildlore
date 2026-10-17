extends TestCase
## The interactive world map: cursor jumps between visited towns, the info panel's facts, and flying.

func _data(visited: Array, flags := {}) -> GameStateData:
	var d := GameStateData.new()
	for t in visited:
		d.set_flag("visited_" + t)
	for k in flags:
		d.set_flag(k, flags[k])
	return d

func test_nearest_picks_the_closest_town_in_that_direction() -> void:
	var c := {"a": Vector2(0, 0), "east": Vector2(50, -5), "far_east": Vector2(200, 0), "north": Vector2(0, -40), "west": Vector2(-30, 0)}
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.right, "a"), "east")
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.left, "a"), "west")
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.up, "a"), "north")
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.down, "a"), "", "nothing south")

func test_nearest_prefers_straight_ahead_over_slightly_closer_sideways() -> void:
	var c := {"a": Vector2(0, 0), "near_diag": Vector2(30, 60), "straight": Vector2(80, 0)}
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.right, "a"), "straight")

func test_nearest_widens_when_nothing_is_dead_ahead() -> void:
	var c := {"a": Vector2(0, 0), "sw": Vector2(-20, 100)}
	assert_eq(MapLogic.nearest(Vector2(0, 0), c, MapLogic.DIRS.down, "a"), "sw", "within the cone")
	var d := {"a": Vector2(0, 0), "wide": Vector2(100, -10)}
	assert_eq(MapLogic.nearest(Vector2(0, 0), d, MapLogic.DIRS.down, "a"), "", "nothing on that side at all")
	var e := {"a": Vector2(0, 0), "shallow": Vector2(100, 90)}
	assert_eq(MapLogic.nearest(Vector2(0, 0), e, MapLogic.DIRS.down, "a"), "shallow", "outside the cone but still that side")

func test_every_visited_town_can_be_reached_by_the_cursor() -> void:
	var d := _data(MapLogic.real_towns())
	var pos := MapLogic.visited_positions(d)
	assert_true(pos.size() > 30, "the whole map")
	var start: String = pos.keys()[0]
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var t: String = queue.pop_back()
		for dir in MapLogic.DIRS.values():
			var n := MapLogic.nearest(pos[t], pos, dir, t)
			if n != "" and not seen.has(n):
				seen[n] = true
				queue.append(n)
	assert_eq(seen.size(), pos.size(), "no town is stranded")

func test_cursor_only_visits_visited_towns() -> void:
	var d := _data(["macclesfield", "buxton"])
	var pos := MapLogic.visited_positions(d)
	assert_eq(pos.keys().size(), 2)
	assert_true(pos.has("buxton") and pos.has("macclesfield"))
	assert_eq(MapLogic.start_town(_data(["macclesfield", "buxton"], {"last_town": "buxton"})), "buxton")
	assert_eq(MapLogic.start_town(_data(["macclesfield"], {"last_town": "york"})), "macclesfield", "an unvisited last town is ignored")
	assert_eq(MapLogic.start_town(_data([])), "")

func test_unvisited_town_is_named_only_when_it_is_the_objective() -> void:
	var d := _data(["macclesfield"])
	assert_eq(MapLogic.named_unvisited(d, "buxton"), ["buxton"])
	assert_eq(MapLogic.named_unvisited(d, "macclesfield"), [])
	assert_eq(MapLogic.named_unvisited(d, ""), [])

func test_info_for_a_keeper_town() -> void:
	var d := _data(["buxton"], {"station_buxton": true})
	var i := MapLogic.info(d, "buxton")
	assert_eq(i.name, "Buxton")
	assert_eq(i.keeper.name, "Maud")
	assert_eq(i.keeper.stone, "Brook Stone")
	assert_false(i.keeper.won)
	assert_true(i.sanctuary)
	assert_true(i.shop)
	assert_true(i.station)
	assert_true(i.nearby > 0, "routes lead out of Buxton")
	d.set_flag("badge_brook")
	assert_true(MapLogic.info(d, "buxton").keeper.won)
	var d2 := _data(["buxton"])
	d2.badges = ["brook"]
	assert_true(MapLogic.info(d2, "buxton").keeper.won, "the badge list counts too")

func test_info_for_a_plain_town_and_a_port() -> void:
	var d := _data(["macclesfield", "liverpool"])
	var m := MapLogic.info(d, "macclesfield")
	assert_true(m.keeper.is_empty(), "no Keeper in Macclesfield")
	assert_true(m.sanctuary and m.shop, "the short macc_ file names are found")
	assert_false(m.station, "no station flag yet")
	assert_eq(MapLogic.info(d, "liverpool").ferries, ["Douglas"])
	assert_eq(MapLogic.info(d, "holyhead").ferries, ["Dublin"])

func test_fieldbook_count_nearby() -> void:
	var near := MapLogic.nearby_species("macclesfield")
	assert_true(near.size() > 0)
	var d := _data(["macclesfield"])
	assert_eq(MapLogic.info(d, "macclesfield").found, 0)
	d.mark_caught(near[0])
	d.mark_seen(near[1] if near.size() > 1 else near[0])
	var i := MapLogic.info(d, "macclesfield")
	assert_eq(i.found, 1, "caught counts, merely seen does not")
	assert_eq(i.nearby, near.size())
	var lines := MapLogic.info_lines(i)
	assert_true(lines.any(func(l): return l == "Fieldbook nearby: 1 of %d found" % near.size()))

func test_info_lines() -> void:
	var lines := MapLogic.info_lines(MapLogic.info(_data(["buxton"]), "buxton"))
	assert_eq(lines[0], "Keeper Maud: Brook Stone not yet won")
	assert_has(lines, "Station: not found yet")
	assert_has(lines, "Ferry: none")
	for l in lines:
		assert_false(str(l).contains("—"), "no em-dashes")

func test_flying_needs_the_champion_and_another_visited_town() -> void:
	var d := _data(["macclesfield", "buxton"])
	assert_false(MapLogic.can_fly_to(d, "macclesfield", "buxton"), "not before the Champion")
	d.set_flag("champion")
	assert_true(MapLogic.can_fly_to(d, "macclesfield", "buxton"))
	assert_false(MapLogic.can_fly_to(d, "buxton", "buxton"), "not to where you stand")
	assert_false(MapLogic.can_fly_to(d, "macclesfield", "york"), "not to an unvisited town")

func test_info_counts_rooms_visited() -> void:
	var d := _data(["buxton"])
	var rooms: Array = ZoneIndex.get_index().town_rooms.buxton
	d.set_flag(VisitorsBook.seen_flag(str(rooms[0])))
	var i := MapLogic.info(d, "buxton")
	assert_eq([i.rooms_seen, i.rooms], [1, rooms.size()])
	assert_has(MapLogic.info_lines(i), "Rooms visited: 1 of %d" % rooms.size())
