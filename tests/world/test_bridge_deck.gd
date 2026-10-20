extends TestCase
## A bridge deck (legend_extra "deck": n): a walkable slab high over a gorge, with the river n levels below,
## drawn as a thin slab rather than an embankment down to the water.

## Three columns: rim, deck over the river, rim. Rows above and below the deck are river at level 0.
func _gorge() -> ZoneData:
	return ZoneData.from_dict({"id": "t", "name": "T", "kind": "route", "rows": ["#~#", "#k#", "#~#"],
		"heights": ["606", "666", "606"],
		"legend_extra": {"k": {"tile": "path", "deck": 0}},
		"props": [], "warps": [], "edges": {}, "npcs": [], "encounters": {}, "signs": [], "spawn": [0, 1], "weather": {}})

func test_deck_is_walkable_at_its_height() -> void:
	var z := _gorge()
	assert_true(z.walkable(Vector2i(1, 1), Vector2i(1, 0)), "on to the deck from the rim")
	assert_false(z.walkable(Vector2i(1, 0), Vector2i(0, -1)), "not off the side into the river")

func test_deck_has_water_under_it() -> void:
	var z := _gorge()
	var root := ZoneBuilder.build(z)
	var water := root.get_node_or_null("Water") as MeshInstance3D
	assert_true(water != null, "the river surface")
	var arr: Array = water.mesh.surface_get_arrays(0)
	var tris: int = (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3 if arr[Mesh.ARRAY_INDEX] != null else (arr[Mesh.ARRAY_VERTEX] as PackedVector3Array).size() / 3
	assert_eq(tris, 6, "two river tiles and the one under the deck, two triangles each")
	root.free()

func test_deck_sides_are_a_thin_slab() -> void:
	var z := _gorge()
	var root := ZoneBuilder.build(z)
	var ground := root.get_node("Ground") as MeshInstance3D
	var arr: Array = ground.mesh.surface_get_arrays(0)
	var verts: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var deck_top := 6 * ZoneBuilder.LEVEL
	for v in verts:
		# nothing hangs below the deck's slab within the deck column, except the riverbed itself
		if v.x > 1.01 and v.x < 1.99 and v.y < deck_top - ZoneBuilder.DECK_SLAB - 0.01:
			assert_true(v.y < 0.0, "only the riverbed lies below the slab, got %s" % v)
	root.free()
