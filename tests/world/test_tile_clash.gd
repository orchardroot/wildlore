extends TestCase
## 2.0 QA: everything the 2.0 features put on the map, in every zone, at every rewild stage and on every show day,
## in the order the overworld dresses a zone (Rewild.apply, then Seasonal's centrepiece, Mum's garden visitors, the
## show ring and its two NPCs, then the side-story Keepers placed round all of that). Nothing may stand on a warp,
## sign, prop or NPC or on each other, and nothing may cut the spawn off from a warp or from anything you talk to.

const NEIGHBOURS := [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]

## Static things on the zone: tile -> label (warps, signs, non-building props, NPC home tiles, the spawn).
func _static(z: ZoneData) -> Dictionary:
	var out := {}
	for w in z.warps:
		out[Vector2i(int(w.x), int(w.y))] = "warp to " + str(w.get("to", ""))
	for s in z.signs:
		out[Vector2i(int(s.x), int(s.y))] = "sign"
	for p in z.props:
		if str(p.get("type", "")) != "building":
			out[Vector2i(int(p.get("x", 0)), int(p.get("y", 0)))] = "prop " + str(p.get("type", ""))
	for n in z.npcs:
		out[Vector2i(int(n.get("x", 0)), int(n.get("y", 0)))] = "npc " + str(n.get("id", ""))
	out[z.spawn] = "spawn"
	return out

## Things you walk up to and press confirm on: tile -> label.
func _talkable(z: ZoneData) -> Dictionary:
	var out := {}
	for s in z.signs:
		out[Vector2i(int(s.x), int(s.y))] = "sign"
	for p in z.props:
		if str(p.get("type", "")) in ["noticeboard", "post_box", "forage", "craft_bench", "garden_plot", "trophy_shelf"]:
			out[Vector2i(int(p.x), int(p.y))] = "prop " + str(p.type)
	for n in z.npcs:
		if str(n.get("move", "still")) == "still":
			out[Vector2i(int(n.x), int(n.y))] = "npc " + str(n.get("id", ""))
	return out

func _reach_next_to(reach: Dictionary, p: Vector2i) -> bool:
	for d in NEIGHBOURS:
		if reach.has(p + d):
			return true
	return false

func _sides_in(zone_id: String) -> Array:
	return SideStories.sides().filter(func(s): return str(s.get("zone", "")) == zone_id)

## One dressing of zone `id`: rewild sites at `stage`, `show` ({} for none) on. Returns [] or the problems found.
func _check(id: String, stage: int, show: Dictionary) -> Array:
	var errs := []
	var tag := "%s (rewild %d%s)" % [id, stage, ", " + str(show.id) if not show.is_empty() else ""]
	var base := ZoneData.load_id(id)
	var base_reach := base.reachable(base.spawn, ["hedge_lay"], base._standing_npcs())
	var z := ZoneData.load_id(id)
	var data := GameStateData.new()
	for s in Rewild.sites_in(id):
		data.set_flag(Rewild.flag_key(str(s.id)), stage)
	Rewild.apply(data, z)
	var things := _static(base)
	var added := {}  # tile -> label: everything the 2.0 dressing puts down that you can't walk through
	var put := func(p: Vector2i, label: String) -> void:
		if things.has(p):
			errs.append("%s: %s lands on %s at %s" % [tag, label, things[p], p])
		elif added.has(p):
			errs.append("%s: %s lands on %s at %s" % [tag, label, added[p], p])
		added[p] = label
	# rewilding: a tile that was open and isn't now
	for y in z.height:
		for x in z.width:
			var p := Vector2i(x, y)
			if base.walkable(p) and not z.walkable(p):
				if things.has(p):
					errs.append("%s: rewilding blocks %s at %s" % [tag, things[p], p])
				added[p] = "rewild " + z.tile_at(p)
			elif things.has(p) and z.tile_at(p) != base.tile_at(p) and str(things[p]).begins_with("prop"):
				errs.append("%s: rewilding turns the ground under %s at %s into %s" % [tag, things[p], p, z.tile_at(p)])
	# Seasonal's square centrepiece (a Christmas tree, a flag) is placed before the ring is known
	if z.kind == "town":
		var sq := Seasonal.square_spot(z)
		if sq != Vector2i(-1, -1):
			put.call(sq, "seasonal centrepiece")
			z.blocked[sq] = true
	if id == HomeBase.GARDEN_ZONE:
		for t in HomeBase.VISITOR_TILES:
			if z.in_bounds(t) and z.walkable(t) and z.warp_at(t).is_empty():
				put.call(t, "garden visitor")
				z.blocked[t] = true
	if not show.is_empty():
		var r := Rect2i(int(show.ring.x), int(show.ring.y), int(show.ring.w), int(show.ring.h))
		for p in ShowRing.footprint(r):
			put.call(p, "the show ring")
			z.blocked[p] = true
		for spot in show.npcs:
			put.call(Vector2i(int(spot.x), int(spot.y)), "show " + str(spot.role))
		ShowRing.add_npcs(z, show)
	var spots := {}  # rewilding's marked spots: you face them to plant or pick litter, so nobody may stand there
	for site in Rewild.sites_in(id):
		for p in Rewild.spots(z, site):
			spots[p] = "rewild spot " + str(site.id)
			if added.has(p) or things.has(p):
				errs.append("%s: %s is under %s" % [tag, spots[p], added.get(p, things.get(p))])
	var taken := {}  # as Overworld._side_npcs does it
	for s in _sides_in(id):
		var p := SideStories.nearest_free(z, Vector2i(int(s.x), int(s.y)), taken)
		taken[p] = true
		if not SideStories.free_tile(z, p):
			errs.append("%s: side story %s has no free tile near %s" % [tag, s.id, Vector2i(int(s.x), int(s.y))])
		if spots.has(p):
			errs.append("%s: side story %s stands on %s at %s" % [tag, s.id, spots[p], p])
		put.call(p, "side story " + str(s.id))
	# moving NPCs must not be shut inside anything
	for n in base.npcs:
		if str(n.get("move", "still")) != "still":
			var home := Vector2i(int(n.x), int(n.y))
			if added.has(home) and not str(added[home]).begins_with("rewild"):
				errs.append("%s: %s's home tile is under %s" % [tag, n.id, added[home]])
	# reachability: the spawn to every warp, and to the side of everything you talk to
	var stand := z._standing_npcs()
	for p in added:
		stand[p] = true
	stand.erase(z.spawn)
	var reach := z.reachable(z.spawn, ["hedge_lay"], stand)
	for w in base.warps:
		var p := Vector2i(int(w.x), int(w.y))
		if base_reach.has(p) and not reach.has(p):
			errs.append("%s: the warp to %s at %s is cut off" % [tag, w.get("to", ""), p])
	var talk := _talkable(z)
	talk.merge(spots)
	for p in added:
		if str(added[p]).begins_with("show ") or str(added[p]).begins_with("side story") or str(added[p]).begins_with("garden"):
			talk[p] = added[p]
	for p in talk:
		var was := _reach_next_to(base_reach, p) or not _talkable(base).has(p)
		if was and not _reach_next_to(reach, p):
			errs.append("%s: you can't walk up to %s at %s" % [tag, talk[p], p])
	return errs

func _zones() -> Array:
	var out := []
	for f in DirAccess.get_files_at(ZoneData.DIR):
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out

func test_nothing_2_0_clashes_in_any_zone() -> void:
	var errs := []
	for id in _zones():
		var shows := [{}] + Tournament.shows().filter(func(s): return str(s.town) == id)
		var stages := [0] if Rewild.sites_in(id).is_empty() else range(0, Rewild.WILD + 1)
		var sides := _sides_in(id)
		var z := ZoneData.load_id(id)
		if z.kind != "town" and shows.size() == 1 and stages.size() == 1 and sides.is_empty() and id != HomeBase.GARDEN_ZONE:
			continue  # nothing from 2.0 is dressed here at run time (its static props are checked by validate)
		for st in stages:
			for s in shows:
				errs.append_array(_check(id, st, s))
	for e in errs:
		fail(e)
	assert_eq(errs.size(), 0, "clashes")
