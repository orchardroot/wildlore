extends TestCase
## The Palace in Douglas, Aintree off Liverpool and the betting shops in Glasgow and Belfast: the rooms load, their
## doors round-trip onto open ground, the staff run the right casino games, and the new words are clean.

const ROOMS := {"douglas_palace": "douglas", "liverpool_aintree": "liverpool", "glasgow_bookies": "glasgow",
	"belfast_bookies": "belfast"}

## room -> {npc id: [game, venue or ""]}
const STAFF := {
	"douglas_palace": {"palace_cashier": ["cage", ""], "palace_change": ["fruit", ""], "palace_croupier": ["roulette", ""],
		"palace_dealer": ["blackjack", ""], "palace_hilo": ["hilo", ""]},
	"liverpool_aintree": {"aintree_bookie": ["races", "aintree"], "aintree_clerk": ["novice", ""]},
	"glasgow_bookies": {"glasgow_bookies_clerk": ["races", "glasgow"]},
	"belfast_bookies": {"belfast_bookies_clerk": ["races", "belfast"]},
}

const NEW_PLAQUES := ["man_palace_casino", "aintree_grand_national", "aintree_red_rum", "glasgow_betting_shops",
	"belfast_fractional_odds"]

func _npc(z: ZoneData, id: String) -> Dictionary:
	for n in z.npcs:
		if str(n.get("id", "")) == id:
			return n
	return {}

## Every command in a script, nested branches included.
func _flatten(cmds: Array, out: Array) -> Array:
	for c in cmds:
		if c is Dictionary:
			out.append(c)
			for k in ["then", "else"]:
				_flatten(c.get(k, []), out)
	return out

func test_rooms_load_as_interiors() -> void:
	for id in ROOMS:
		var z := ZoneData.load_id(id)
		assert_eq(z.id, id)
		assert_eq(z.kind, "interior", id)
		assert_true(z.parse_errors.is_empty(), "%s parses: %s" % [id, z.parse_errors])
		assert_true(z.walkable(z.spawn), id + " spawn is open floor")

func test_doors_round_trip_onto_open_ground() -> void:
	for id in ROOMS:
		var room := ZoneData.load_id(id)
		var town := ZoneData.load_id(ROOMS[id])
		var outs := town.warps.filter(func(w): return str(w.get("to", "")) == id)
		assert_eq(outs.size(), 1, "%s has one door into %s" % [ROOMS[id], id])
		var out_w: Dictionary = outs[0]
		var land_in := Vector2i(int(out_w.tx), int(out_w.ty))
		assert_true(room.walkable(land_in), "%s: you land on open floor" % id)
		assert_eq(town.tile_at(Vector2i(int(out_w.x), int(out_w.y))), "door", "%s: the town door is a door tile" % id)
		assert_eq(room.warps.size(), 1, id + " has one way out")
		var back: Dictionary = room.warps[0]
		assert_eq(str(back.to), ROOMS[id])
		var land_out := Vector2i(int(back.tx), int(back.ty))
		assert_true(town.walkable(land_out), "%s: back outside on open ground" % id)
		assert_eq(land_out, Vector2i(int(out_w.x), int(out_w.y)) + Vector2i(0, 1), "%s: outside, just south of the door" % id)
		assert_eq(room.tile_at(Vector2i(int(back.x), int(back.y))), "door", "%s: the way out is a door tile" % id)

func test_new_buildings_use_the_new_styles() -> void:
	var want := {"douglas": "casino", "liverpool": "grandstand", "glasgow": "bookmaker", "belfast": "bookmaker"}
	for town in want:
		var z := ZoneData.load_id(town)
		var found := z.props.filter(func(p): return str(p.get("type", "")) == "building" and str(p.get("style", "")) == want[town])
		assert_eq(found.size(), 1, "%s has its %s" % [town, want[town]])
		assert_true(want[town] in Landmarks.SPECIAL, want[town] + " is a landmark style")
		var meshes: Array = Meshes.building(int(found[0].w), int(found[0].h), want[town], 2, 1, z.region)
		assert_true((meshes[0] as ArrayMesh).get_surface_count() > 0, want[town] + " builds")

func test_new_props_build() -> void:
	for name in ["slot_machine", "roulette_table", "card_table", "tote_board", "velvet_rope", "horse_statue"]:
		assert_true(name in ZoneBuilder.POINT_PROPS, name + " is registered")
		for v in 3:
			assert_true(ZoneBuilder._ctor(name, v).get_surface_count() > 0, "%s %d has geometry" % [name, v])
	for name in ["slot_glow", "tote_glow"]:
		assert_true(ZoneBuilder._ctor(name, 1).get_surface_count() > 0, name + " has geometry")

func test_staff_run_the_right_games() -> void:
	for room in STAFF:
		var z := ZoneData.load_id(room)
		var scripts: Dictionary = JsonUtil.read("res://data/dialogue/%s.json" % room)
		for npc_id in STAFF[room]:
			var n := _npc(z, npc_id)
			assert_false(n.is_empty(), "%s stands in %s" % [npc_id, room])
			var script_id := str(n.get("script", ""))
			assert_true(scripts.has(script_id), "%s's script '%s' exists" % [npc_id, script_id])
			var games := _flatten(scripts.get(script_id, []), []).filter(func(c): return str(c.get("do", "")) == "casino")
			assert_eq(games.size(), 1, npc_id + " opens one game")
			if games.size() == 1:
				assert_eq(str(games[0].get("game", "")), STAFF[room][npc_id][0], npc_id)
				assert_eq(str(games[0].get("venue", "")), STAFF[room][npc_id][1], npc_id + " venue")

func test_the_doorman_asks() -> void:
	var scripts: Dictionary = JsonUtil.read("res://data/dialogue/douglas_palace.json")
	var lines := _flatten(scripts.doorman, []).filter(func(c): return str(c.get("do", "")) == "say").map(func(c): return str(c.text))
	assert_true(lines.any(func(t): return "You're old enough, aren't you?" in t), "the question")
	assert_true(lines.any(func(t): return "wink" in t), "and the wink")

func test_plaques_are_unique_and_complete() -> void:
	var seen := {}
	var dir := DirAccess.open("res://data/zones")
	for f in dir.get_files():
		if not f.ends_with(".json"):
			continue
		var d: Variant = JsonUtil.read("res://data/zones/" + f)
		if not (d is Dictionary):
			continue
		for s in d.get("signs", []):
			if s is Dictionary and s.has("plaque"):
				var id := str(s.plaque)
				assert_false(seen.has(id), "plaque %s used twice (%s and %s)" % [id, seen.get(id, ""), f])
				seen[id] = f
	for id in NEW_PLAQUES:
		assert_true(seen.has(id), id + " is up")

func test_no_em_dashes_in_the_new_words() -> void:
	var files := []
	for id in ROOMS:
		files.append("res://data/zones/%s.json" % id)
		files.append("res://data/dialogue/%s.json" % id)
	for town in ["douglas", "liverpool", "glasgow", "belfast"]:
		files.append("res://data/zones/%s.json" % town)
	for f in files:
		assert_false("—" in FileAccess.get_file_as_string(f), f + " has no em-dash")
