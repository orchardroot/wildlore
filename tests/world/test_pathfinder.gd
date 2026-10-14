extends TestCase

func _zones() -> Dictionary:
	return ZoneData.load_all()

func test_path_within_zone_avoids_walls() -> void:
	var z := ZoneData.load_id("testbed")
	var path := Pathfinder.within(z, Vector2i(4, 6), Vector2i(4, 9), {})
	assert_true(path.size() > 0, "found a path")
	assert_eq(path.back(), Vector2i(4, 9))
	for p in path:
		assert_true(z.walkable(p), "walkable %s" % p)

func test_path_blocked_returns_empty() -> void:
	var z := ZoneData.load_id("testbed")
	assert_eq(Pathfinder.within(z, Vector2i(4, 6), Vector2i(0, 0), {}), [])

func test_route_across_zones_uses_warps() -> void:
	var r := Pathfinder.route(_zones(), "testbed", Vector2i(4, 6), "testbed_house", Vector2i(1, 3))
	assert_true(r.size() >= 2, "two legs")
	assert_eq(r[0].zone, "testbed")
	assert_eq(r.back().zone, "testbed_house")

func test_route_across_edges() -> void:
	var r := Pathfinder.route(_zones(), "macclesfield", Vector2i(8, 11), "buxton", Vector2i(24, 21))
	var zones_visited := r.map(func(leg): return leg.zone)
	assert_eq(zones_visited, ["macclesfield", "macc_forest", "cat_and_fiddle", "buxton"])

func test_route_from_home_interior_to_forest() -> void:
	var r := Pathfinder.route(_zones(), "macc_home", Vector2i(4, 5), "macc_forest", Vector2i(30, 13))
	assert_eq(r[0].zone, "macc_home")
	assert_eq(r.back().zone, "macc_forest")

func test_blocked_tiles_only_apply_to_the_starting_zone() -> void:
	var a := ZoneData.from_dict({"id": "a", "name": "A", "kind": "route", "rows": ["....", "...."], "spawn": [0, 0], "edges": {"east": {"to": "b"}}})
	var b := ZoneData.from_dict({"id": "b", "name": "B", "kind": "route", "rows": ["TT..", "...."], "spawn": [0, 1], "edges": {"west": {"to": "a"}}})
	# an NPC on a's (1,1) must not wall off b's (1,1), which is b's only way in
	var legs := Pathfinder.route({"a": a, "b": b}, "a", Vector2i(2, 0), "b", Vector2i(3, 1), {Vector2i(1, 1): true})
	assert_true(legs.size() >= 2, "route found into b")
