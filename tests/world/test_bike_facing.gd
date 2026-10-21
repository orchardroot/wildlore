extends TestCase
## The bike turns with you: side-on going left or right, end-on going up or down (it used to stay side-on always).

func test_bike_turns_with_the_rider() -> void:
	var p := Player.new()
	p._bike = p._make_bike()
	p.add_child(p._bike)
	p.face("left")
	assert_eq(p._bike.rotation_degrees.y, 0.0)
	p.face("up")
	assert_eq(absf(p._bike.rotation_degrees.y), 90.0, "pointing up the screen")
	p.face("down")
	assert_eq(absf(p._bike.rotation_degrees.y), 90.0, "pointing down the screen")
	p.face("right")
	assert_eq(p._bike.rotation_degrees.y, 0.0)
	p.free()
