extends TestCase
## Wave 33 integration: every registry arrival zone loads, the arrival tile is walkable, the town has a way home
## (a movements clerk, or a ferry quay for the Channel Islands) and, wherever the money isn't sterling, a bureau.

const STERLING_ONLY := ["tristan", "south_georgia", "antarctic"]

func _npc_runs(z: ZoneData, command: String) -> bool:
	StoryData.clear_cache()
	for n in z.npcs:
		var s = StoryData.script(z.id, str(n.get("script", "")))
		if s is Array:
			for c in s:
				if c is Dictionary and str(c.get("do", "")) == command:
					return true
	return false

func test_every_arrival_zone_loads_walkable_with_a_way_home() -> void:
	Overseas.reset()
	var all := Overseas.all()
	assert_true(all.size() >= 17, "the registry has the territories: %d" % all.size())
	for e in all:
		var a := Overseas.arrival(e)
		var z := ZoneData.load_id(a.zone)
		assert_true(z != null and z.id == a.zone, "%s: arrival zone loads" % e.id)
		assert_true(z.walkable(a.pos), "%s: arrival tile walkable" % e.id)
		var h := Overseas.home(e)
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % h.zone), "%s: home zone exists" % e.id)
		if Overseas.is_ferry(e):
			assert_true(z.ferry.has("route"), "%s: a quay to sail home from" % e.id)
		else:
			assert_true(_npc_runs(z, "overseas_home"), "%s: a way home at the arrival town" % e.id)

func test_bureaus_where_the_money_is_not_sterling() -> void:
	Overseas.reset()
	for e in Overseas.all():
		var z := ZoneData.load_id(str(e.arrival.zone))
		for n in z.npcs:
			var p := Vector2i(int(n.x), int(n.y))
			assert_true(z.walkable(p), "%s: npc %s stands on a walkable tile" % [z.id, n.id])
		if e.id in STERLING_ONLY:
			continue
		assert_true(_npc_runs(z, "bureau"), "%s: a bureau de change in the main town" % e.id)
	assert_true(_npc_runs(ZoneData.load_id("brize_norton"), "bureau"), "a bureau at RAF Brize Norton")
