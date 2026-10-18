extends TestCase
## 2.1's dressing for the first two rooms: Mum's window and the cat's bowl; the Field Station's owl, kettle,
## specimen jars and the wall map of the Isles.

const NEW_PROPS := ["window", "cat_bowl", "owl_perch", "kettle_table", "specimen_shelf", "wall_map"]

func test_every_new_prop_builds_a_mesh() -> void:
	for name in NEW_PROPS:
		assert_true(name in ZoneBuilder.POINT_PROPS, name + " is registered")
		var mesh: ArrayMesh = ZoneBuilder._ctor(name, 1)
		assert_true(mesh.get_surface_count() > 0, name + " has geometry")

func test_the_map_has_land_on_it() -> void:
	assert_true(Dressing.wall_map().surface_get_array_len(0) > 300, "Britain, Ireland and Man, not just a frame")

func _types(zid: String) -> Array:
	return ZoneData.load_id(zid).props.map(func(p): return str(p.get("type", "")))

func test_the_rooms_are_dressed_and_still_walkable() -> void:
	for t in ["window", "cat_bowl"]:
		assert_has(_types("macc_home"), t)
	for t in ["owl_perch", "kettle_table", "specimen_shelf", "wall_map"]:
		assert_has(_types("macc_fieldstation"), t)
	var home := ZoneData.load_id("macc_home")
	var spawn: Vector2i = home.spawn
	assert_true(home.walkable(spawn), "the spawn is clear")
	assert_true(home.walkable(Vector2i(6, 3)), "you can step over the cat's bowl")
	var mum: Dictionary = home.npcs.filter(func(n): return n.id == "mum")[0]
	assert_true(Vector2i(int(mum.x), int(mum.y)) != spawn + Vector2i(0, 1), "Mum is not between you and the door")
