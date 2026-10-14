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

func test_water_encounters_on_deep_water() -> void:
	var z := _zone([".o."])
	var hit := {}
	for i in 200:
		var e := Encounters.roll(z, "deep_water", "day", "clear", Rng.new(i))
		if not e.is_empty():
			hit = e
	assert_eq(hit.get("species", ""), "dolphlet")
