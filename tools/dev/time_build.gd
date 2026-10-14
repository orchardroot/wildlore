extends SceneTree
## Dev: times ZoneData load + ZoneBuilder.build for each zone (headless, no rendering).
func _initialize() -> void:
	for zid in ["testbed", "macclesfield", "macc_forest", "cat_and_fiddle", "buxton"]:
		var t0 := Time.get_ticks_msec()
		var z := ZoneData.load_id(zid)
		var t1 := Time.get_ticks_msec()
		var n := ZoneBuilder.build(z)
		var t2 := Time.get_ticks_msec()
		print("%s load %d ms, build %d ms" % [zid, t1 - t0, t2 - t1])
		n.free()
	quit()
