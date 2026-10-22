extends TestCase
## Yr Wyddfa: the summit beat (Director Pryce, ch3_ddraig_woke) and the door to Dinas Emrys must be reachable on
## foot from where you arrive in the zone. Wave 45 put the "Fossils on the summit" plaque on the one gap between the
## cairn and the standing stones, which walled off the summit ring: the story bot reported a soft-lock.

const ZONE := "yr_wyddfa"

## The bot's view of the zone: props and signs block (ZoneData does that), as do NPCs that stand still, as the
## flags stand now. Unbeaten trainers walk up to you, so they are not walls.
func _bot_zone(flags: Array) -> ZoneData:
	var z := ZoneData.load_id(ZONE)
	for n in z.npcs:
		if str(n.get("move", "still")) != "still" or str(n.get("trainer", "")) != "":
			continue
		if n.has("hide_if") and str(n.hide_if) in flags:
			continue
		if n.has("show_if") and not (str(n.show_if) in flags):
			continue
		z.blocked[Vector2i(int(n.x), int(n.y))] = true
	return z

func _npc_pos(z: ZoneData, id: String) -> Vector2i:
	for n in z.npcs:
		if str(n.get("id", "")) == id:
			return Vector2i(int(n.x), int(n.y))
	return Vector2i(-1, -1)

## Free tiles to talk to (or read) something at p from, in the order the bot tries them: down, up, left, right.
## The bot walks to the first of these; a player may use any.
func _stands_beside(z: ZoneData, p: Vector2i) -> Array:
	var out := []
	for dir in ["down", "up", "left", "right"]:
		var stand: Vector2i = p + GridMotion.dir_vec(dir)
		if z.walkable(stand) and z.warp_at(stand).is_empty():
			out.append(stand)
	return out

## Some free tile beside p has a route from the entry (what a player needs).
func _assert_some_stand_reachable(z: ZoneData, p: Vector2i, what: String) -> void:
	var stands := _stands_beside(z, p)
	assert_true(not stands.is_empty(), "a tile %s from" % what)
	for stand in stands:
		if not _route_from_entry(z, stand).is_empty():
			return
	assert_true(false, "no route from %s to any tile beside %s %s (%s)" % [z.spawn, p, stands, what])

## The bot's route from the zone entry (its spawn, where the south edge from Llanberis lands you) to `to`.
func _route_from_entry(z: ZoneData, to: Vector2i) -> Array:
	Pathfinder.abilities = ["fell_scramble"]  # the Stone badge: the only way up is over the scree
	var path := Pathfinder.within(z, z.spawn, to, {})
	Pathfinder.abilities = []
	return path

func _assert_walkable_path(z: ZoneData, path: Array, to: Vector2i, what: String) -> void:
	assert_true(path.size() > 0, "a route from %s to %s (%s)" % [z.spawn, to, what])
	if path.is_empty():
		return
	assert_eq(path.back(), to, what)
	for p in path:
		assert_true(z.walkable(p, Vector2i.ZERO, ["fell_scramble"]), "%s steps on %s" % [what, p])

func test_pryce_at_the_summit_is_reachable_from_the_zone_entry() -> void:
	var z := _bot_zone([])
	var pryce := _npc_pos(z, "pryce_summit")
	assert_true(pryce != Vector2i(-1, -1), "Director Pryce stands at the summit")
	var stands := _stands_beside(z, pryce)
	assert_true(not stands.is_empty(), "a tile to talk to Pryce from")
	# the bot walks to the first free tile beside him, so that one in particular must have a route
	var stand: Vector2i = stands[0]
	_assert_walkable_path(z, _route_from_entry(z, stand), stand, "to Pryce")

func test_kit_after_the_summit_is_reachable_from_the_zone_entry() -> void:
	var z := _bot_zone(["ch3_ddraig_woke"])
	var kit := _npc_pos(z, "kit_summit_after")
	assert_true(kit != Vector2i(-1, -1), "Kit waits at the summit afterwards")
	_assert_some_stand_reachable(z, kit, "to talk to Kit")

func test_the_dinas_emrys_door_is_reachable_from_the_zone_entry() -> void:
	for flags in [[], ["ch3_ddraig_woke"]]:
		var z := _bot_zone(flags)
		var door := Vector2i(-1, -1)
		for w in z.warps:
			if str(w.to) == "dinas_emrys":
				door = Vector2i(int(w.x), int(w.y))
		assert_true(door != Vector2i(-1, -1), "a way into Dinas Emrys")
		_assert_walkable_path(z, _route_from_entry(z, door), door, "to the Dinas Emrys door with flags %s" % [flags])

func test_the_summit_plaque_and_the_geology_student_do_not_wall_off_the_ring() -> void:
	var z := _bot_zone([])
	var plaque := Vector2i(-1, -1)
	for s in z.signs:
		if str(s.get("plaque", "")) == "landsky_wyddfa_volcano":
			plaque = Vector2i(int(s.x), int(s.y))
	assert_true(plaque != Vector2i(-1, -1), "the Fossils on the summit plaque is in the zone")
	var student := _npc_pos(z, "landsky_wyddfa_geo")
	assert_true(student != Vector2i(-1, -1), "the Geology Student is in the zone")
	_assert_some_stand_reachable(z, plaque, "to read the plaque")
	_assert_some_stand_reachable(z, student, "to talk to the Geology Student")
