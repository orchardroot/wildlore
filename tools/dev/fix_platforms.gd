extends SceneTree
## One-off repair: for every zone whose station or ferry tile can't reach the spawn, find the shortest way out
## letting point props (benches, lamp posts, signs) be walked through, then delete the props on that path from
## the zone JSON. Prints what it removed. godot --headless --path . -s res://tools/dev/fix_platforms.gd
func _initialize() -> void:
	var all := ZoneData.load_all()
	for zid in all:
		var z: ZoneData = all[zid]
		for tile in [z.station, Vector2i(int(z.ferry.get("x", -1)), int(z.ferry.get("y", -1)))]:
			if tile.x < 0 or not z.walkable(tile):
				continue
			if z.reachable(tile, ZoneData.GATE_ABILITIES, z._standing_npcs()).has(z.spawn):
				continue
			var path := _path_through_props(z, tile)
			var blockers := path.filter(func(p): return z.blocked.has(p))
			_remove_props(zid, blockers)
			print("%s: removed blockers at %s" % [zid, blockers])
	quit()

func _path_through_props(z: ZoneData, from: Vector2i) -> Array:
	var npc := z._standing_npcs()
	var prev := {from: from}
	var q := [from]
	while not q.is_empty():
		var p: Vector2i = q.pop_front()
		if p == z.spawn:
			break
		for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			var n: Vector2i = p + d
			if prev.has(n) or not z.in_bounds(n) or npc.has(n):
				continue
			var t := z.tile_at(n)
			var ok := z.walkable(n, d, ZoneData.GATE_ABILITIES) or (z.blocked.has(n) and t in ZoneData.WALKABLE_TILES)
			if ok:
				prev[n] = p
				q.append(n)
	var out := []
	var c := z.spawn
	while prev.has(c) and c != from:
		out.append(c)
		c = prev[c]
	return out

func _remove_props(zid: String, tiles: Array) -> void:
	var path := "res://data/zones/%s.json" % zid
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
	var keep := func(p): return not tiles.has(Vector2i(int(p.get("x", -1)), int(p.get("y", -1)))) or p.get("type") == "building"
	d.props = d.props.filter(keep)
	d.signs = d.get("signs", []).filter(func(s): return not tiles.has(Vector2i(int(s.x), int(s.y))))
	var f := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	f.store_string(JSON.stringify(d, " "))
	f.close()
