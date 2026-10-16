extends TestCase
## Rail rules (line ends, caps, level crossings, stations) and the passing-train route finder.

func _zone(rows: Array, extra := {}) -> ZoneData:
	var d := {"id": "t", "name": "T", "kind": "town", "rows": rows, "props": [], "warps": [], "edges": {}, "npcs": [],
		"encounters": {}, "signs": [], "spawn": [1, 0], "weather": {}}
	d.merge(extra, true)
	return ZoneData.from_dict(d)

func _rail_errors(z: ZoneData) -> Array:
	return z.validate({z.id: z}).filter(func(e): return "rail" in e or "level crossing" in e or "station platform" in e)

func _cap(type: String, x: int, y: int, more := {}) -> Dictionary:
	var p := {"type": type, "x": x, "y": y}
	p.merge(more, true)
	return p

func test_level_crossing_is_walkable_rail() -> void:
	var z := _zone(["........", "!!!&!!!!", "........"])
	assert_eq(z.tile_at(Vector2i(3, 1)), "level_crossing")
	assert_true(z.walkable(Vector2i(3, 1)))
	assert_false(z.walkable(Vector2i(2, 1)))
	assert_true(z.is_rail(Vector2i(3, 1)))
	# the crossing joins the line: one line, two ends, both on the map edge
	assert_eq(z.rail_ends().size(), 2)
	assert_eq(_rail_errors(z), [])

func test_line_running_off_both_edges_is_fine() -> void:
	assert_eq(_rail_errors(_zone(["....", "!!!!", "...."])), [])
	assert_eq(_rail_errors(_zone([".!.", ".!.", ".!."])), [])

func test_stub_floating_in_town_is_flagged_at_both_ends() -> void:
	var errs := _rail_errors(_zone(["........", ".!!!!!!.", "........"]))
	assert_eq(errs.size(), 2, str(errs))
	assert_true("1,1" in errs[0] or "1,1" in errs[1], str(errs))
	assert_true("6,1" in errs[0] or "6,1" in errs[1], str(errs))

func test_buffer_stop_on_or_beyond_the_end_caps_it() -> void:
	var on_end := _zone(["........", ".!!!!!!!", "........"], {"props": [_cap("buffer_stop", 1, 1)]})
	assert_eq(_rail_errors(on_end), [])
	var beyond := _zone(["........", ".!!!!!!!", "........"], {"props": [_cap("buffer_stop", 0, 1)]})
	assert_eq(_rail_errors(beyond), [])
	var too_far := _zone(["........", "..!!!!!!", "........"], {"props": [_cap("buffer_stop", 0, 1)]})
	assert_eq(_rail_errors(too_far).size(), 2, "a stop two tiles off caps nothing and touches no rail")

func test_tunnel_portal_caps_a_line() -> void:
	var z := _zone(["........", "RR!!!!!!", "........"], {"props": [_cap("tunnel_portal", 2, 1)]})
	assert_eq(_rail_errors(z), [])
	assert_eq(z.rail_end_cap({"pos": Vector2i(2, 1), "dir": Vector2i(-1, 0)}), "tunnel_portal")
	assert_eq(z.rail_end_cap({"pos": Vector2i(7, 1), "dir": Vector2i(1, 0)}), "edge")

func test_cap_away_from_rail_is_flagged() -> void:
	var z := _zone(["....", "!!!!", "...."], {"props": [_cap("buffer_stop", 0, 0)]})
	assert_eq(_rail_errors(z), [])  # (0, 0) touches the line at (0, 1)
	var far := _zone([".....", ".....", "!!!!!"], {"props": [_cap("tunnel_portal", 2, 0)]})
	var errs := _rail_errors(far)
	assert_eq(errs.size(), 1, str(errs))
	assert_true("not on or next to a rail line" in errs[0])

func test_double_track_ends_and_axis() -> void:
	var rows := ["xxxxxxxx", "x!!!!!!x", "x!!!!!!x", "xxxxxxxx"]
	var z := _zone(rows)
	assert_eq(z.rail_axis(Vector2i(3, 1)), Vector2i(1, 0), "a double track still runs along its rows")
	assert_eq(z.rail_ends().size(), 4, "both rows end at both sides, and nothing ends sideways")
	var capped := _zone(rows, {"props": [_cap("tunnel_portal", 1, 1), _cap("tunnel_portal", 1, 2, {"variant": 1}),
		_cap("tunnel_portal", 6, 1), _cap("tunnel_portal", 6, 2)]})
	assert_eq(_rail_errors(capped), [])
	var vertical := _zone(["x!!x", "x!!x", "x!!x", "x!!x"])
	assert_eq(vertical.rail_axis(Vector2i(1, 1)), Vector2i(0, 1))

func test_t_junction_has_no_false_end() -> void:
	# main line edge to edge along row 0, a branch south from (3, 0) to the bottom edge
	var z := _zone(["!!!!!!!", "...!...", "...!...", "...!..."])
	assert_eq(_rail_errors(z), [])

func test_station_needs_rail_within_two_tiles() -> void:
	var rows := ["......", "......", "......", "......", "!!!!!!"]
	assert_eq(_rail_errors(_zone(rows, {"station": {"x": 2, "y": 2}})), [])
	var errs := _rail_errors(_zone(rows, {"station": {"x": 2, "y": 1}}))
	assert_eq(errs.size(), 1, str(errs))
	assert_true("not within 2 tiles" in errs[0])

func test_npc_on_level_crossing_is_flagged() -> void:
	var z := _zone(["....", "!&!!", "...."], {"npcs": [{"id": "loiterer", "x": 1, "y": 1, "sprite": "villager_1"}]})
	assert_true(_rail_errors(z).any(func(e): return "loiterer" in e))

func test_dev_zones_are_exempt() -> void:
	var z := _zone(["........", ".!!!!!!.", "........"], {"id": "mesh_gallery"})
	assert_eq(_rail_errors(z), [])

func test_shipped_reference_zones_follow_the_rules() -> void:
	for id in ["manchester", "mesh_gallery"]:
		var z := ZoneData.load_id(id)
		for end in z.rail_ends():
			assert_true(z.rail_end_cap(end) != "", "%s: line end %s is capped" % [id, end.pos])
	var m := ZoneData.load_id("manchester")
	assert_eq(_rail_errors(m), [])
	assert_eq(m.tile_at(Vector2i(57, 41)), "level_crossing")
	var r := RailTraffic.find_routes(m)
	assert_eq(r.size(), 1, "Piccadilly: trains come in from the east and back out")
	assert_eq(r[0].kind if r.size() > 0 else "", "terminus")

func test_cap_faces_its_track() -> void:
	var z := _zone(["........", ".!!!!!!.", "........"])
	assert_eq(z.cap_inward(Vector2i(1, 1)), Vector2i(1, 0), "on the west end tile: track runs east")
	assert_eq(z.cap_inward(Vector2i(6, 1)), Vector2i(-1, 0))
	assert_eq(z.cap_inward(Vector2i(0, 1)), Vector2i(1, 0), "just beyond the west end")
	var v := _zone([".!.", ".!.", "..."])
	assert_eq(v.cap_inward(Vector2i(1, 2)), Vector2i(0, -1), "beyond the south end: track runs north")
	assert_near(ZoneBuilder.cap_angle(Vector2i(1, 0)), 0.0)
	assert_near(ZoneBuilder.cap_angle(Vector2i(0, -1)), PI / 2)

# --- trains ---------------------------------------------------------------------

func test_routes_through_and_terminus() -> void:
	var through := _zone(["......", "!!!!!!", "......"])
	var r := RailTraffic.find_routes(through)
	assert_eq(r.size(), 1)
	assert_eq(r[0].kind, "through")
	assert_eq(r[0].path.size(), 6)
	var term := _zone(["......", ".!!!!!", "......"], {"props": [_cap("buffer_stop", 1, 1)]})
	r = RailTraffic.find_routes(term)
	assert_eq(r.size(), 1)
	assert_eq(r[0].kind, "terminus")
	assert_eq(r[0].path[0], Vector2i(5, 1), "it comes in from the open end")
	assert_eq(r[0].path[-1], Vector2i(1, 1), "and runs to the buffers")

func test_no_trains_on_dead_or_blocked_lines() -> void:
	var both_buffers := _zone(["......", ".!!!!.", "......"], {"props": [_cap("buffer_stop", 1, 1), _cap("buffer_stop", 4, 1)]})
	assert_eq(RailTraffic.find_routes(both_buffers), [])
	var parked := _zone(["......", "!!!!!!", "......"], {"props": [{"type": "canal_boat", "x": 3, "y": 1}]})
	assert_eq(RailTraffic.find_routes(parked), [], "something parked on the track")
	assert_eq(RailTraffic.find_routes(_zone(["....", "...."])), [])

func test_double_track_trains_keep_to_their_row() -> void:
	var z := _zone(["xxxxxxxx", "!!!!!!!!", "!!!!!!!!", "xxxxxxxx"])
	var r := RailTraffic.find_routes(z)
	assert_eq(r.size(), 2, "one per row, never hopping across")
	for route in r:
		var y: int = route.path[0].y
		assert_true(route.path.all(func(p): return p.y == y))
		assert_eq(route.path.size(), 8)

func test_point_at_runs_on_past_the_ends() -> void:
	var path := [Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1)]
	assert_eq(RailTraffic.point_at(path, 0.0), Vector2(2.5, 1.5))
	assert_eq(RailTraffic.point_at(path, 1.5), Vector2(4.0, 1.5))
	assert_eq(RailTraffic.point_at(path, -2.0), Vector2(0.5, 1.5))
	assert_eq(RailTraffic.point_at(path, 4.0), Vector2(6.5, 1.5))
	assert_eq(RailTraffic.dir_at(path, -3.0), Vector2(1, 0))

func test_clip_stops_at_tunnel_mouths() -> void:
	var z := _zone(["........", "!!!!!!!R", "........"], {"props": [_cap("tunnel_portal", 6, 1)]})
	var r := RailTraffic.find_routes(z)
	assert_eq(r.size(), 1)
	var clip := RailTraffic.clip_rect(z, r[0].path, r[0].from, r[0].to)
	assert_eq(clip[0], Vector2(0, 0))
	assert_eq(clip[1], Vector2(6.5, 3), "cut at the portal's centre, not the map edge")

func _traffic(z: ZoneData, occupied := {}) -> RailTraffic:
	var t := RailTraffic.new()
	t.setup(z, func() -> Dictionary: return occupied, 0.0)
	return t

func _run_until_done(t: RailTraffic, max_seconds := 120.0) -> float:
	var time := 0.0
	t.tick(0.0)  # starts it (first wait 0)
	while not t.run.is_empty() and time < max_seconds:
		t.tick(1.0 / 30.0)
		time += 1.0 / 30.0
	return time

func test_through_train_runs_and_clears() -> void:
	var z := _zone([".".repeat(40), "!".repeat(40), ".".repeat(40)])
	var t := _traffic(z)
	var secs := _run_until_done(t)
	assert_true(t.run.is_empty(), "the train left")
	assert_true(secs > 5.0 and secs < 20.0, "a 40-tile line takes a sensible time (%.1f s)" % secs)
	assert_true(t.timer >= RailTraffic.WAIT.x and t.timer <= RailTraffic.WAIT.y, "next one in 40-90 s")
	t.free()

func test_terminus_train_stops_at_the_buffers_and_goes_back() -> void:
	var z := _zone([".".repeat(30), "." + "!".repeat(29), ".".repeat(30)], {"props": [_cap("buffer_stop", 1, 1)]})
	var t := _traffic(z)
	t.tick(0.0)
	var nearest := 99.0
	var went_back := false
	var time := 0.0
	while not t.run.is_empty() and time < 120.0:
		t.tick(1.0 / 30.0)
		time += 1.0 / 30.0
		if not t.run.is_empty():
			nearest = minf(nearest, (t.run.path.size() - 1) - t.run.head)
			went_back = went_back or t.run.sign < 0.0
	assert_true(went_back, "it reversed out")
	assert_true(nearest >= 0.15 and nearest < 0.3, "front stopped at the buffers, not through them (%.2f)" % nearest)
	assert_true(t.run.is_empty())
	t.free()

func test_crossing_shuts_and_train_waits_for_someone_on_it() -> void:
	var z := _zone([".".repeat(40), "!".repeat(20) + "&" + "!".repeat(19), ".".repeat(40)])
	var occ := {Vector2i(20, 1): true}
	var t := _traffic(z, occ)
	t.tick(0.0)
	for i in 30 * 20:
		t.tick(1.0 / 30.0)
	assert_false(t.run.is_empty(), "still waiting after 20 s")
	assert_true(t.closed(Vector2i(20, 1)), "the crossing is shut while it waits")
	var c: int = t.run.path.find(Vector2i(20, 1))
	assert_true(t.run.head <= c - 0.5 - RailTraffic.HOLD_SHORT + 0.05, "stopped short of the crossing (%.2f, crossing at %d)" % [t.run.head, c])
	occ.clear()  # they step off
	var secs := _run_until_done(t)
	assert_true(t.run.is_empty(), "and then it goes on its way (%.1f s)" % secs)
	assert_false(t.closed(Vector2i(20, 1)), "and the crossing opens again")
	t.free()

func test_crossing_is_open_when_no_train_is_near() -> void:
	var z := _zone([".".repeat(60), "!".repeat(50) + "&" + "!".repeat(9), ".".repeat(60)])
	var t := _traffic(z)
	t.start(RailTraffic.find_routes(z)[0], false)
	assert_false(t.closed(Vector2i(50, 1)), "a train just coming on far away")
	var shut_seen := false
	while not t.run.is_empty():
		t.tick(1.0 / 30.0)
		shut_seen = shut_seen or t.closed(Vector2i(50, 1))
	assert_true(shut_seen, "it shut as the train came by")
	assert_false(t.closed(Vector2i(50, 1)))
	t.free()

func test_through_train_calls_at_the_station() -> void:
	var z := _zone([".".repeat(40), "_".repeat(40), "!".repeat(40)], {"station": {"x": 20, "y": 1}})
	var t := _traffic(z)
	t.tick(0.0)
	var dwelt := false
	while not t.run.is_empty():
		t.tick(1.0 / 30.0)
		if not t.run.is_empty() and t.run.dwell > 0.0:
			dwelt = true
			var mid: float = t.run.head - t.run.length * 0.5
			var p: Vector2 = RailTraffic.point_at(t.run.path, mid)
			assert_near(p.x, 20.5, 0.3, "stopped with the middle of the train by the platform")
			break
	assert_true(dwelt, "it called at the station")
	t.free()
