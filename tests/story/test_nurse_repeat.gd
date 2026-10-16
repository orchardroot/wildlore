extends TestCase
## Sanctuary nurses: the first visit keeps the full, witty script; later visits skip the intro and shorten the lines.

func _script(zone: String) -> Array:
	return JsonUtil.read("res://data/dialogue/%s_sanctuary.json" % zone).nurse

func _host(zone: String) -> FakeStoryHost:
	var h := FakeStoryHost.new()
	h.zone = zone + "_sanctuary"
	return h

func test_first_visit_is_the_full_script() -> void:
	var h := _host("chester")
	h.choices = [0]
	await Commands.new(h, "nurse").run(_script("chester"))
	assert_eq(h.said.size(), 3, "intro, pre-heal line, post-heal line")
	assert_eq(h.said[0][1], "Hello, dear. Come in, mind the step. We're Roman, we have excellent heating.")
	assert_true(h.data.flag("nurse_seen_chester_sanctuary") == true, "remembered")

func test_repeat_visit_heals_with_one_short_line() -> void:
	var h := _host("chester")
	h.data.set_flag("nurse_seen_chester_sanctuary")
	h.data.party.append(Fixtures.creature("kindlet", 10))
	h.data.party[0].hp = 1
	h.choices = [0]
	await Commands.new(h, "nurse").run(_script("chester"))
	assert_eq(h.said.size(), 1, "just the after-heal line")
	assert_eq(h.data.party[0].hp, h.data.party[0].max_hp(), "still healed")
	assert_true(h.said[0][1].length() < 30, "short")
	assert_eq(h.said[0][0], "Nurse")

func test_repeat_visit_ark_choice_still_opens_the_ark() -> void:
	var h := _host("chester")
	h.data.set_flag("nurse_seen_chester_sanctuary")
	h.choices = [1]
	await Commands.new(h, "nurse").run(_script("chester"))
	assert_has(h.log, ["menu", "ark"])
	assert_eq(h.said.size(), 0)

func test_repeat_visit_just_looking_is_silent() -> void:
	var h := _host("chester")
	h.data.set_flag("nurse_seen_chester_sanctuary")
	h.choices = [2]
	await Commands.new(h, "nurse").run(_script("chester"))
	assert_eq(h.said.size(), 1, "one short sign-off")

func test_each_sanctuary_remembers_separately() -> void:
	var h := _host("bath")
	h.data.set_flag("nurse_seen_chester_sanctuary")
	h.choices = [0]
	await Commands.new(h, "nurse").run(_script("bath"))
	assert_eq(h.said.size(), 3, "first time in Bath's Sanctuary")

func test_every_nurse_script_has_the_shape_the_shortcut_expects() -> void:
	var dir := DirAccess.open("res://data/dialogue")
	var n := 0
	for f in dir.get_files():
		if not f.ends_with("_sanctuary.json"):
			continue
		n += 1
		var cmds: Array = JsonUtil.read("res://data/dialogue/" + f).nurse
		assert_true(Commands.is_nurse_script(cmds), f)
		assert_true(Commands.nurse_repeat(cmds, 0).size() < cmds.size() + 1)
	assert_true(n >= 40, "found the nurses")
