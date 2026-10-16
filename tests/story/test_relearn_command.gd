extends TestCase
## {"do": "relearn"}: opens the move relearner and can remember whether anything was learned.

func test_relearn_opens_menu_and_sets_flag() -> void:
	var h := FakeStoryHost.new()
	h.menu_results = {"relearn": {"creature": "Kindlet", "move": "glare"}}
	await Commands.new(h).run([{"do": "relearn", "set": "_relearned"}])
	assert_has(h.log, ["menu", "relearn"])
	assert_eq(h.data.flag("_relearned"), 1)

func test_relearn_backed_out() -> void:
	var h := FakeStoryHost.new()
	await Commands.new(h).run([{"do": "relearn", "set": "_relearned"}])
	assert_eq(h.data.flag("_relearned"), 0)

func test_every_sanctuary_has_a_memory_coach() -> void:
	var dir := DirAccess.open("res://data/zones")
	for f in dir.get_files():
		if not f.ends_with("_sanctuary.json"):
			continue
		var id := f.get_basename()
		var z := ZoneData.load_id(id)
		var coach: Dictionary = {}
		for n in z.npcs:
			if str(n.get("id", "")) == "memory_coach":
				coach = n
		assert_false(coach.is_empty(), "%s has no memory coach" % id)
		if coach.is_empty():
			continue
		var p := Vector2i(int(coach.x), int(coach.y))
		assert_true(z.walkable(p), "%s: coach stands on floor" % id)
		var script := StoryData.script(id, str(coach.script))
		assert_false(script.is_empty(), "%s: coach has lines" % id)
		assert_true(JSON.stringify(script).contains("\"relearn\""), "%s: coach relearns moves" % id)
