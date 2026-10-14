extends TestCase

func _zone(id: String, rows: Array, enc: Array, kind := "route") -> ZoneData:
	return ZoneData.from_dict({"id": id, "name": id, "kind": kind, "rows": rows, "spawn": [0, 0], "encounters": {"grass": enc}})

func test_uncatchable_species_is_flagged() -> void:
	var dex := Dex.load_default()
	var zones := {"r": _zone("r", [".,,"], [{"species": "spikkin", "min": 2, "max": 3}])}
	# scuttlet lives in "r" by its habitat note, but no table there has it
	var errs := Coverage.check(dex, zones, {"scuttlet": ["r"]})
	assert_true(errs.any(func(e): return e.contains("scuttlet")))

func test_species_with_unbuilt_habitat_is_skipped() -> void:
	var errs := Coverage.check(Dex.load_default(), {}, {"scuttlet": ["somewhere_not_built"]})
	assert_eq(errs, [])

func test_thin_route_is_flagged() -> void:
	var enc := [{"species": "spikkin", "min": 2, "max": 3}]
	var errs := Coverage.check(Dex.load_default(), {"r": _zone("r", [".,,"], enc)}, {})
	assert_true(errs.any(func(e): return e.contains("only 1 encounter")))
	var no_grass := Coverage.check(Dex.load_default(), {"q": _zone("q", ["..."], [])}, {})
	assert_eq(no_grass, [], "a route without tall grass or deep water needs no table")

func test_stub_habitat_is_skipped() -> void:
	var z := ZoneData.from_dict({"id": "r", "name": "r", "kind": "route", "rows": ["..."], "spawn": [0, 0], "stub": true})
	assert_eq(Coverage.check(Dex.load_default(), {"r": z}, {"scuttlet": ["r"]}), [])
