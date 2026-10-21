extends TestCase

func _zone(rows: Array, kind := "route") -> ZoneData:
	return ZoneData.from_dict({"id": "fz", "name": "F", "kind": kind, "rows": rows, "spawn": [0, 0],
		"encounters": {"water": [{"species": "dolphlet", "min": 20, "max": 20, "weight": 1}]}})

func test_field_ability_from_badges() -> void:
	var d := GameStateData.new()
	assert_eq(FieldMoves.abilities(d), [])
	d.badges = ["brook"]
	assert_eq(FieldMoves.abilities(d), ["hedge_lay"])
	d.badges = ["brook", "urban", "stone"]
	assert_eq(FieldMoves.abilities(d), ["hedge_lay", "brook_wade", "fell_scramble"])

func test_bike_rules() -> void:
	var d := GameStateData.new()
	var route := _zone(["...", "..."])
	assert_true(FieldMoves.bike_refusal(d, route, false) != "", "no bike yet")
	d.bag["bike"] = 1
	assert_eq(FieldMoves.bike_refusal(d, route, false), "")
	assert_true(FieldMoves.bike_refusal(d, _zone(["|||"], "interior"), false).contains("indoors"))
	assert_true(FieldMoves.bike_refusal(d, route, true) != "", "not while wading")

func test_bramble_cut_persists() -> void:
	var d := GameStateData.new()
	var z := _zone([".%."])
	FieldMoves.cut(d, z, Vector2i(1, 0))
	assert_true(z.walkable(Vector2i(1, 0)))
	var back := GameStateData.from_dict(d.to_dict(), Dex.load_default())
	var fresh := _zone([".%."])
	assert_false(fresh.walkable(Vector2i(1, 0)))
	FieldMoves.apply_cuts(back, fresh)
	assert_true(fresh.walkable(Vector2i(1, 0)), "cut survives save/load and a rebuild")

func test_wade_needs_ability() -> void:
	var d := GameStateData.new()
	var z := _zone([".o."])
	assert_eq(FieldMoves.verdict(d, z, Vector2i(1, 0)), "blocked")
	d.badges = ["brook", "urban"]
	assert_eq(FieldMoves.verdict(d, z, Vector2i(1, 0)), "wade")
	var z2 := _zone([".%/"])
	assert_eq(FieldMoves.verdict(d, z2, Vector2i(1, 0)), "cut")
	assert_eq(FieldMoves.verdict(d, z2, Vector2i(2, 0)), "blocked", "scree needs the Stone Stone")

func test_blocked_tile_says_what_is_missing() -> void:
	var d := GameStateData.new()
	var z := _zone([".o%"])
	assert_true(FieldMoves.block_hint(d, z, Vector2i(1, 0)).contains("Brook-wade"), FieldMoves.block_hint(d, z, Vector2i(1, 0)))
	assert_true(FieldMoves.block_hint(d, z, Vector2i(2, 0)).contains("Hedge-lay"))
	assert_eq(FieldMoves.block_hint(d, z, Vector2i(0, 0)), "", "plain ground needs no excuse")
	d.badges = ["brook", "urban"]
	assert_eq(FieldMoves.block_hint(d, z, Vector2i(1, 0)), "")

func test_water_encounters_on_deep_water() -> void:
	var z := _zone([".o."])
	var hit := {}
	for i in 200:
		var e := Encounters.roll(z, "deep_water", "day", "clear", Rng.new(i))
		if not e.is_empty():
			hit = e
	assert_eq(hit.get("species", ""), "dolphlet")

func test_sanctuary_default_is_macclesfield_door() -> void:
	var ls: Dictionary = GameStateData.default_sanctuary()
	assert_eq(ls.zone, "macclesfield")
	var z := ZoneData.load_id("macclesfield")
	assert_true(z.walkable(Vector2i(int(ls.pos[0]), int(ls.pos[1]))), "lands on a walkable tile")
	assert_true(z.warp_at(Vector2i(int(ls.pos[0]), int(ls.pos[1]) - 1)).get("to", "") == "macc_sanctuary", "just outside the Sanctuary door")

func test_northern_abilities() -> void:
	var d := GameStateData.new()
	d.badges = ["brook", "urban", "stone", "storm", "fae", "kin", "tide", "iron"]
	assert_true("lantern" in FieldMoves.abilities(d))
	assert_false("bog_cross" in FieldMoves.abilities(d))
	assert_eq(FieldMoves.light_radius(d), 6.0)
	assert_eq(FieldMoves.light_radius(GameStateData.new()), 2.0)
	var z := _zone([".*."])
	assert_eq(z.tile_at(Vector2i(1, 0)), "bog")
	assert_eq(FieldMoves.verdict(d, z, Vector2i(1, 0)), "blocked", "bog needs the Frost Stone")
	d.badges.append("frost")
	assert_eq(FieldMoves.verdict(d, z, Vector2i(1, 0)), "squelch")
	assert_true(z.walkable(Vector2i(1, 0), Vector2i.ZERO, FieldMoves.abilities(d)))

func test_dark_zone_key() -> void:
	var z := ZoneData.from_dict({"id": "c", "name": "C", "kind": "interior", "rows": ["..."], "spawn": [0, 0], "dark": true})
	assert_true(z.dark)
	assert_false(_zone(["..."]).dark)
