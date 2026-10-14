extends TestCase

func test_dev_args_parse() -> void:
	var a := DevArgs.parse(PackedStringArray(["--shot=docs/screens/x.png", "--shot-delay=3.5", "--boot=testbed@4,6", "--battle=spikkin:5", "--seed=9", "--clock=21:30", "--weather=fog", "--fps"]))
	assert_eq(a.shot, "docs/screens/x.png")
	assert_eq(a.shot_delay, 3.5)
	assert_eq(a.boot_zone, "testbed")
	assert_eq(a.boot_pos, Vector2i(4, 6))
	assert_eq(a.battle_species, "spikkin")
	assert_eq(a.battle_level, 5)
	assert_eq(a.seed, 9)
	assert_eq(a.clock, 1290)
	assert_eq(a.weather, "fog")
	assert_true(a.fps)

func test_dev_args_defaults() -> void:
	var a := DevArgs.parse(PackedStringArray())
	assert_eq(a.shot, "")
	assert_eq(a.shot_delay, 2.0)
	assert_eq(a.boot_zone, "")
	assert_eq(a.clock, -1)
	assert_false(a.fps)

func test_dev_args_ignored_in_release() -> void:
	var a := DevArgs.parse(PackedStringArray(["--boot=testbed@4,6", "--playtest=slice", "--shot=x.png"]), false)
	assert_eq(a.boot_zone, "")
	assert_eq(a.playtest, "")
	assert_eq(a.shot, "")
	assert_eq(DevArgs.user_args(false).size(), 0)
