extends TestCase
## The County Show ring (world/show_ring.gd): every show's footprint sits on clear, flat, open ground in its town,
## the Steward and the Stall stand where you can reach them, and fencing it off cuts nothing else off.

func _occupied(z: ZoneData) -> Dictionary:
	var out := {}
	for n in z.npcs:
		out[Vector2i(int(n.x), int(n.y))] = "npc " + str(n.get("id", ""))
	for w in z.warps:
		out[Vector2i(int(w.x), int(w.y))] = "warp"
	for s in z.signs:
		out[Vector2i(int(s.x), int(s.y))] = "sign"
	for p in z.props:
		out[Vector2i(int(p.get("x", 0)), int(p.get("y", 0)))] = "prop " + str(p.get("type", ""))
	return out

func test_every_show_ring_fits_its_town() -> void:
	for s in Tournament.shows():
		var z := ZoneData.load_id(str(s.town))
		assert_eq(z.town_id, str(s.town), "%s: a town" % s.id)
		var r := Rect2i(int(s.ring.x), int(s.ring.y), int(s.ring.w), int(s.ring.h))
		assert_true(r.size.x >= ShowRing.MARQUEE_W + 4 and r.size.y >= 3, "%s: room for the tent and the ring" % s.id)
		var occ := _occupied(z)
		var h0 := z.height_at(r.position)
		var before := z.reachable(z.spawn)
		for p in ShowRing.footprint(r):
			assert_true(z.walkable(p), "%s: %s is open ground" % [s.id, p])
			assert_false(occ.has(p), "%s: %s is clear (%s)" % [s.id, p, occ.get(p, "")])
			assert_eq(z.height_at(p), h0, "%s: %s is flat" % [s.id, p])
			assert_true(z.tile_at(p) in ["grass", "flowers"], "%s: %s is grass, not %s" % [s.id, p, z.tile_at(p)])
		for p in ShowRing.footprint(r):
			z.blocked[p] = true
		var after := z.reachable(z.spawn)
		for p in before:
			if not r.has_point(p):
				assert_true(after.has(p), "%s: fencing the ring cuts off %s" % [s.id, p])
		for spot in s.npcs:
			var at := Vector2i(int(spot.x), int(spot.y))
			assert_false(r.has_point(at), "%s: %s stands outside the ring" % [s.id, spot.role])
			assert_false(occ.has(at), "%s: %s's tile is free" % [s.id, spot.role])
			var reach := false
			for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
				reach = reach or after.has(at + d)
			assert_true(reach, "%s: you can walk up to the %s" % [s.id, spot.role])

func test_dress_adds_the_npcs_once_and_only_on_show_day() -> void:
	var d := GameStateData.new()
	d.set_flag("visited_macclesfield", true)
	var z := ZoneData.load_id("macclesfield")
	var n0 := z.npcs.size()
	var node := Node3D.new()
	ShowRing.dress(z, node, d)
	ShowRing.dress(z, node, d)
	assert_eq(z.npcs.size(), n0 + 2, "Steward and Stall, once")
	assert_true(node.get_child_count() == 2, "the ring built (once per call)")
	var ring: Node3D = node.get_child(0)
	assert_true(ring.get_child_count() <= 4, "a handful of mesh nodes")
	var y := ZoneData.load_id("york")
	var m0 := y.npcs.size()
	ShowRing.dress(y, node, d)
	assert_eq(y.npcs.size(), m0, "no show in York today")
	node.free()
