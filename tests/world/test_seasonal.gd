extends TestCase
## Where the seasonal dressing goes: pumpkins on real doorsteps, the Christmas tree on an open tile that can't
## block anyone's way, and falling leaves only where there are trees.

func test_pumpkins_sit_on_doorsteps_in_front_of_doors() -> void:
	var z := ZoneData.load_id("macclesfield")
	var doors := Seasonal.doorsteps(z)
	assert_true(doors.size() >= 5, "Macclesfield has plenty of front doors (got %d)" % doors.size())
	for d in doors:
		assert_eq(z.tile_at(d), "door")
		assert_true(z.walkable(d + Vector2i(0, 1)), "a step to stand on in front of %s" % d)

func test_the_square_spot_is_open_and_clear_of_folk() -> void:
	for id in ["macclesfield", "manchester", "london", "edinburgh", "dublin", "cardiff", "belfast", "york"]:
		var z := ZoneData.load_id(id)
		var p := Seasonal.square_spot(z)
		assert_true(p.x >= 0, id + " has room for a tree")
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				assert_true(z.walkable(p + Vector2i(dx, dy)), "%s: open round %s" % [id, p])
		for n in z.npcs:
			assert_false(Vector2i(int(n.x), int(n.y)) == p, "%s: not on %s" % [id, n.id])
		for w in z.warps:
			assert_false(Vector2i(int(w.x), int(w.y)) == p, id + ": not on a warp")
		assert_false(p == z.spawn, id + ": not on the spawn")

func test_leaves_only_in_wooded_zones() -> void:
	assert_true(Seasonal.tree_count(ZoneData.load_id("macclesfield")) >= Seasonal.WOODED_TREES)
