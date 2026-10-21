extends TestCase
## The post-game Underground reunion fights must stay reachable: no tile a trainer can come to rest on (or a pacer
## can stand on) may be the only way to a reunion fight. Trainers walk straight along their sight line and stop
## next to the player, then stay put; standing NPCs and trainers' starting tiles are treated as walls.

const REUNIONS := ["reunion_a", "reunion_b"]

func _npc(z: ZoneData, id: String) -> Dictionary:
	for n in z.npcs:
		if str(n.get("id", "")) == id:
			return n
	return {}

func _tile(n: Dictionary) -> Vector2i:
	return Vector2i(int(n.x), int(n.y))

## Tiles a trainer may come to rest on: its own, then along its sight line (it walks up to the player and stops).
func _rest_tiles(z: ZoneData, n: Dictionary, others: Dictionary) -> Array:
	var p := _tile(n)
	var out := [p]
	var d := GridMotion.dir_vec(str(n.get("facing", "down")))
	for i in range(1, Sight.RANGE):
		var q := p + d * i
		if not z.walkable(q) or others.has(q):
			break
		out.append(q)
	return out

func test_no_single_tile_walls_off_a_reunion_fight() -> void:
	var z := ZoneData.load_id("underground")
	var fixed_all := {}    # standing NPCs never move; pacers step aside, trainers are tried one at a time below
	var trainers := []
	for n in z.npcs:
		if n.has("trainer"):
			trainers.append(n)
		elif str(n.get("move", "still")) == "still":
			fixed_all[_tile(n)] = true
	for id in REUNIONS:
		var npc := _npc(z, id)
		# reunion_a bars the only way to the north tunnels, so it has been beaten (and has left) by reunion_b
		var fixed := fixed_all.duplicate()
		if id == "reunion_b":
			fixed.erase(_tile(_npc(z, "reunion_a")))
		var stand := _tile(npc) + GridMotion.dir_vec(str(npc.facing))
		assert_true(Pathfinder.within(z, z.spawn, stand, fixed).size() > 0, "%s: no route from the spawn to %s" % [id, stand])
		for t in trainers:
			var base := fixed.duplicate()
			for o in trainers:
				if o != t:
					base[_tile(o)] = true
			for c in _rest_tiles(z, t, fixed):
				var blocked := base.duplicate()
				blocked[c] = true
				assert_true(Pathfinder.within(z, z.spawn, stand, blocked).size() > 0,
					"%s: %s resting on %s walls off the fight at %s" % [id, t.id, c, stand])
