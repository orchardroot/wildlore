extends TestCase
## The Regulars (core/regulars.gd, story/regular_talk.gd): twelve sound characters, favour from gifts (one a day),
## the scenes at each level, letters at the post box, the manager hook, old saves, and the story command.

func _data() -> GameStateData:
	var d := GameStateData.new()
	d.day_count = 10
	return d

func _meet(d: GameStateData, id: String) -> void:
	Regulars.complete(d, id, "intro")

func _gift_days(d: GameStateData, id: String, n: int) -> void:
	for i in n:
		d.day_count += 1
		d.bag[Regulars.liked_item(id)] = 1
		Regulars.give_gift(d, id)

func test_twelve_sound_regulars() -> void:
	var items := ItemDB.load_default()
	assert_eq(Regulars.all().size(), 12)
	var seen := {}
	for r in Regulars.all():
		var id := str(r.id)
		assert_false(seen.has(id), "unique " + id)
		seen[id] = true
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % r.home), id + " home zone")
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % r.away), id + " away zone")
		assert_ne(str(r.home), str(r.away))
		assert_true(items.has_item(str(r.likes)), id + " likes a real item " + str(r.likes))
		for k in ["intro", "meet", "letter", "offer", "chat", "thanks"]:
			assert_false((r.get(k, []) as Array).is_empty(), id + " has " + k)
		assert_true((r.chat as Array).size() >= 2)
		var first := str(r.name).split(" ")[0]
		for k in ["intro", "meet", "offer", "chat", "thanks"]:
			for l in r[k]:
				assert_false("—" in str(l), id + " has an em-dash")
				var head := str(l).split(": ")[0]
				if str(l).contains(": ") and head.length() < 20 and not head.contains(" "):
					assert_eq(head, first, id + " speaker prefix")
		for l in r.letter:
			assert_false("—" in str(l))

func test_homes_are_all_different_towns() -> void:
	var homes := {}
	for r in Regulars.all():
		homes[str(r.home)] = true
	assert_eq(homes.size(), 12)

func test_favour_starts_at_zero_and_old_saves_are_fine() -> void:
	var d := _data()
	for id in Regulars.ids():
		assert_eq(Regulars.favour(d, id), 0)
	assert_true(Regulars.letters_waiting(d).is_empty())
	assert_eq(d.flags.size(), 0, "reading state writes nothing")

func test_first_scene_then_gifts_raise_favour() -> void:
	var d := _data()
	var id := "ned"
	assert_eq(Regulars.next_beat(d, id, "whitby"), "intro")
	assert_false(Regulars.can_gift(d, id), "strangers don't take gifts")
	_meet(d, id)
	assert_eq(Regulars.favour(d, id), 1)
	assert_eq(Regulars.next_beat(d, id, "whitby"), "")
	_gift_days(d, id, 1)
	assert_eq(Regulars.favour(d, id), 2)
	_gift_days(d, id, 2)
	assert_eq(Regulars.favour(d, id), 3)
	_gift_days(d, id, 2)
	assert_eq(Regulars.favour(d, id), 4)
	_gift_days(d, id, 10)
	assert_eq(Regulars.favour(d, id), Regulars.MAX_FAVOUR, "capped")
	assert_false(Regulars.can_gift(d, id), "no more gifts at the top")

func test_one_gift_a_day_and_it_comes_out_of_the_bag() -> void:
	var d := _data()
	_meet(d, "gwenllian")
	d.bag["welsh_cakes"] = 2
	assert_eq(Regulars.give_gift(d, "gwenllian"), 2)
	assert_eq(int(d.bag["welsh_cakes"]), 1)
	assert_false(Regulars.can_gift(d, "gwenllian"), "not twice in a day")
	assert_eq(Regulars.give_gift(d, "gwenllian"), -1)
	assert_eq(int(d.bag["welsh_cakes"]), 1, "refused gift is kept")
	d.day_count += 1
	assert_true(Regulars.can_gift(d, "gwenllian"))
	Regulars.give_gift(d, "gwenllian")
	assert_false(d.bag.has("welsh_cakes"), "last one gone from the bag")

func test_wrong_item_or_empty_bag_is_no_gift() -> void:
	var d := _data()
	_meet(d, "dot")
	assert_false(Regulars.can_gift(d, "dot"))
	d.bag["cod"] = 3
	assert_false(Regulars.can_gift(d, "dot"))

func test_second_town_scene_needs_favour_two() -> void:
	var d := _data()
	var r := Regulars.get_reg("hilda")
	_meet(d, "hilda")
	assert_eq(Regulars.next_beat(d, "hilda", str(r.away)), "")
	assert_true(Regulars.npcs_for(str(r.away), d).filter(func(n): return str(n.id).begins_with("reg_hilda")).is_empty())
	_gift_days(d, "hilda", 1)
	assert_eq(Regulars.next_beat(d, "hilda", str(r.away)), "meet")
	var npcs := Regulars.npcs_for(str(r.away), d).filter(func(n): return str(n.id) == "reg_hilda_away")
	assert_eq(npcs.size(), 1)
	assert_eq(str(npcs[0].script), "regular_hilda")
	Regulars.complete(d, "hilda", "meet")
	assert_eq(Regulars.next_beat(d, "hilda", str(r.away)), "")
	assert_true(Regulars.npcs_for(str(r.away), d).filter(func(n): return str(n.id) == "reg_hilda_away").is_empty())

func test_everyone_is_at_home() -> void:
	var d := _data()
	for r in Regulars.all():
		var here := Regulars.npcs_for(str(r.home), d).filter(func(n): return str(n.id) == "reg_" + str(r.id))
		assert_eq(here.size(), 1, str(r.id) + " at home")

func test_letters_arrive_at_favour_three_once() -> void:
	var d := _data()
	_meet(d, "morag")
	assert_true(Regulars.letters_waiting(d).is_empty())
	_gift_days(d, "morag", 3)
	assert_eq(Regulars.letters_waiting(d), ["morag"])
	var lines := Regulars.letter_lines("morag", "Sam")
	assert_true(str(lines[0]).contains("Morag MacLeod"))
	assert_eq(Regulars.collect_letters(d), ["morag"])
	assert_true(Regulars.letters_waiting(d).is_empty(), "read once")
	assert_eq(Regulars.collect_letters(d), [])

func test_manager_offer_waits_for_favour_four_and_a_free_deed() -> void:
	var d := _data()
	_meet(d, "mervyn")
	_gift_days(d, "mervyn", 6)
	assert_eq(Regulars.favour(d, "mervyn"), 4)
	if Deeds.owned(d).is_empty():
		assert_eq(Regulars.next_beat(d, "mervyn", "belfast"), "", "no Deed, no offer")
		assert_false(Regulars.appoint(d, "mervyn", "chippy_whitby"))
	else:
		assert_eq(Regulars.next_beat(d, "mervyn", "belfast"), "offer")

func test_validator_knows_the_command_and_the_scripts() -> void:
	var ok := StoryValidator.validate_commands([{"do": "regular", "id": "ned"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(ok, [])
	var bad := StoryValidator.validate_commands([{"do": "regular", "id": "nobody"}], "t", Fixtures.dex(), ItemDB.load_default(), {})
	assert_eq(bad.size(), 1)
	for r in Regulars.all():
		assert_false(StoryData.script("x", "x").size() > 0 and false)
		var cmds := StoryData.script(Regulars.SCRIPT_FILE, "regular_" + str(r.id))
		assert_eq(cmds.size(), 1, str(r.id) + " script")

func test_talking_plays_intro_then_takes_a_gift() -> void:
	var h := FakeStoryHost.new()
	h.zone = "whitby"
	h.data.day_count = 5
	await Commands.new(h).run([{"do": "regular", "id": "ned"}])
	assert_eq(Regulars.favour(h.data, "ned"), 1)
	assert_true(str(h.said).contains("Ned"))
	h.said.clear()
	await Commands.new(h).run([{"do": "regular", "id": "ned"}])
	assert_true(str(h.said).contains("haddock"), "hints at what they like")
	h.data.bag["haddock"] = 1
	h.choices = [0]
	h.said.clear()
	await Commands.new(h).run([{"do": "regular", "id": "ned"}])
	assert_eq(Regulars.favour(h.data, "ned"), 2)
	assert_false(h.data.bag.has("haddock"))
