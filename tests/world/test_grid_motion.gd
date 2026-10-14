extends TestCase

func test_step_and_dirs() -> void:
	assert_eq(GridMotion.step(Vector2i(3, 3), "up"), Vector2i(3, 2))
	assert_eq(GridMotion.step(Vector2i(3, 3), "down"), Vector2i(3, 4))
	assert_eq(GridMotion.step(Vector2i(3, 3), "left"), Vector2i(2, 3))
	assert_eq(GridMotion.step(Vector2i(3, 3), "right"), Vector2i(4, 3))
	assert_eq(GridMotion.dir_vec("nope"), Vector2i.ZERO)

func test_facing_from() -> void:
	assert_eq(GridMotion.facing_from(Vector2i(0, -1)), "up")
	assert_eq(GridMotion.facing_from(Vector2i(1, 0)), "right")
	assert_eq(GridMotion.facing_from(Vector2i(-3, 1)), "left")
	assert_eq(GridMotion.facing_from(Vector2i(0, 2)), "down")

func test_edge_side() -> void:
	assert_eq(GridMotion.edge_side(Vector2i(4, -1), 10, 8), "north")
	assert_eq(GridMotion.edge_side(Vector2i(4, 8), 10, 8), "south")
	assert_eq(GridMotion.edge_side(Vector2i(-1, 3), 10, 8), "west")
	assert_eq(GridMotion.edge_side(Vector2i(10, 3), 10, 8), "east")
	assert_eq(GridMotion.edge_side(Vector2i(4, 3), 10, 8), "")
