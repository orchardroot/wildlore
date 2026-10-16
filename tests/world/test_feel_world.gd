extends TestCase
## Overworld feel: doors swing open onto a dark doorway before a quick fade, the camera drifts a touch when you
## stand still, glides in when you cross into the next zone, and leans in when a trainer spots you.

func test_every_door_style_has_a_doorway() -> void:
	for style in Landmarks.SPECIAL + ["red_brick", "sandstone"]:
		var r := Landmarks.door_rect(style)
		assert_true(float(r.w) >= 0.5 and float(r.w) <= 0.8, "%s door width %.2f" % [style, r.w])
		assert_true(float(r.h) >= 0.85 and float(r.h) <= 1.35, "%s door height %.2f" % [style, r.h])
		assert_true(float(r.x) >= 0.1 and float(r.x) + float(r.w) <= 0.9, "%s door sits within its tile" % style)

func test_door_swing_opens_onto_a_dark_doorway() -> void:
	var n := Landmarks.door_swing("red_brick")
	assert_true(n.has_node("Doorway"), "the dark opening")
	assert_true(n.has_node("Hinge/Leaf"), "the door leaf on its hinge")
	var hinge: Node3D = n.get_node("Hinge")
	assert_near(hinge.rotation.y, 0.0, 0.001, "starts shut")
	assert_true(absf(Landmarks.DOOR_OPEN_ANGLE) > deg_to_rad(70.0), "swings well open")
	n.free()

func test_going_through_a_door_is_snappy() -> void:
	var total := Router.DOOR_FADE.x + Router.DOOR_FADE.y
	assert_true(total >= 0.3 and total <= 0.4, "door fade out + in %.2f s" % total)
	assert_true(Landmarks.DOOR_SWING_SECS < 0.25, "the door is open before the step ends")

func test_idle_drift_only_after_standing_still() -> void:
	assert_eq(CameraRig.idle_drift(0.0, 10.0), Vector3.ZERO, "moving: none")
	assert_eq(CameraRig.idle_drift(CameraRig.IDLE_AFTER - 0.1, 10.0), Vector3.ZERO, "not yet")
	var biggest := 0.0
	var last := CameraRig.idle_drift(CameraRig.IDLE_AFTER, 0.0)
	var jump := 0.0
	for i in 600:
		var t := i / 60.0
		var d := CameraRig.idle_drift(CameraRig.IDLE_AFTER + t, t)
		biggest = maxf(biggest, d.length())
		jump = maxf(jump, d.distance_to(last))
		last = d
		assert_near(d.y, 0.0, 0.0001, "level")
	assert_true(biggest > 0.05 and biggest < 0.4, "very slight: %.3f" % biggest)
	assert_true(jump < 0.01, "smooth, no jumps (%.4f per frame)" % jump)

func test_edge_glide_starts_behind_you() -> void:
	assert_true(CameraRig.edge_offset("right").x < -0.5, "came in heading east: start a little west")
	assert_true(CameraRig.edge_offset("up").z > 0.5, "heading north: start a little south")
	assert_true(CameraRig.edge_offset("down").z < -0.5)
	assert_true(CameraRig.edge_offset("left").x > 0.5)
	assert_true(CameraRig.edge_offset("right").length() < 3.0, "but only a little")

func test_spotted_nudge_leans_toward_the_trainer() -> void:
	var off := CameraRig.nudge_offset(Vector3(0, 0, 0), Vector3(4, 0, 0))
	assert_true(off.x > 0.3 and off.x < 2.0, "leans toward them: %s" % off)
	assert_near(off.y, 0.0, 0.0001)
	var far := CameraRig.nudge_offset(Vector3(0, 0, 0), Vector3(40, 0, 0))
	assert_true(far.length() <= 2.0, "never far")
	assert_true(CameraRig.NUDGE_ZOOM < 1.0 and CameraRig.NUDGE_ZOOM > 0.8, "tightens a little")
