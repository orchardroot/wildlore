extends TestCase
## Kit's postcards: a card waits once its story beat is done, any post box hands over everything waiting,
## the album keeps them in story order, and the card data itself hangs together.

const CARDS := [
	{"id": "one", "after": "badge_brook", "place": "Manchester", "zone": "manchester"},
	{"id": "two", "after": "badge_urban", "place": "Liverpool", "zone": "liverpool"},
	{"id": "three", "after": "ch3_ddraig_woke", "place": "Yr Wyddfa", "zone": "llanberis"},
]

func _data(flags := {}) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	return d

func test_nothing_waits_on_a_fresh_journey() -> void:
	assert_eq(Postcards.waiting(_data(), CARDS), [], "no beats done, no post")

func test_a_card_waits_once_its_beat_is_done() -> void:
	var d := _data({"badge_brook": true})
	assert_eq(Postcards.waiting(d, CARDS), ["one"])
	d.set_flag("ch3_ddraig_woke", true)
	assert_eq(Postcards.waiting(d, CARDS), ["one", "three"], "story order, skipping one not earned yet")

func test_falsy_flags_do_not_count() -> void:
	assert_eq(Postcards.waiting(_data({"badge_brook": false, "badge_urban": 0, "ch3_ddraig_woke": ""}), CARDS), [])

func test_collecting_takes_everything_waiting_and_stamps_it() -> void:
	var d := _data({"badge_brook": true, "badge_urban": true})
	var got := Postcards.collect(d, CARDS, "2026-10-18")
	assert_eq(got, ["one", "two"])
	assert_eq(Postcards.waiting(d, CARDS), [], "nothing left once collected")
	assert_eq(d.flag("postcard_one"), "2026-10-18", "the postmark date is kept in the flag")
	assert_true(Postcards.is_collected(d, "two"))
	assert_false(Postcards.is_collected(d, "three"))
	assert_eq(Postcards.collect(d, CARDS, "2026-10-19"), [], "a second visit finds the box empty")
	assert_eq(d.flag("postcard_one"), "2026-10-18", "re-collecting never re-stamps")

func test_the_first_card_brings_the_album() -> void:
	var d := _data({"badge_brook": true})
	assert_eq(int(d.bag.get(Postcards.ALBUM, 0)), 0)
	Postcards.collect(d, CARDS, "2026-10-18")
	assert_eq(int(d.bag.get(Postcards.ALBUM, 0)), 1, "the album turns up with the first card")
	d.set_flag("badge_urban", true)
	Postcards.collect(d, CARDS, "2026-10-18")
	assert_eq(int(d.bag.get(Postcards.ALBUM, 0)), 1, "only ever one album")

func test_empty_box_brings_no_album() -> void:
	var d := _data()
	Postcards.collect(d, CARDS, "2026-10-18")
	assert_false(d.bag.has(Postcards.ALBUM))

func test_album_lists_collected_cards_in_story_order() -> void:
	var d := _data({"postcard_three": "2026-10-01", "postcard_one": "2026-09-01"})
	assert_eq(Postcards.collected(d, CARDS), ["one", "three"])

func test_old_saves_catch_up_with_a_stack_of_post() -> void:
	# a 1.5 save that is already well along: every card it has earned waits at the first post box
	var d := GameStateData.from_dict({"flags": {"badge_brook": true, "badge_urban": true, "ch3_ddraig_woke": true}}, Fixtures.dex())
	assert_eq(Postcards.waiting(d, CARDS).size(), 3)

func test_post_boxes_in_a_zone() -> void:
	var z := ZoneData.from_dict({"id": "pz", "kind": "town", "rows": ["....", "....", "...."],
		"props": [{"type": "post_box", "x": 1, "y": 1}, {"type": "bench", "x": 2, "y": 1}, {"type": "post_box", "x": 3, "y": 2}]})
	assert_eq(Postcards.post_boxes(z), [Vector2i(1, 1), Vector2i(3, 2)])
	assert_true(Postcards.is_post_box(z, Vector2i(3, 2)))
	assert_false(Postcards.is_post_box(z, Vector2i(2, 1)), "a bench is not a post box")

func test_postmark_date_reads_like_a_postmark() -> void:
	assert_eq(Postcards.postmark_date("2026-10-18"), "18 OCT 2026")
	assert_eq(Postcards.postmark_date("2026-01-05"), "5 JAN 2026")
	assert_eq(Postcards.postmark_date(""), "", "nothing sensible to stamp")

# --- the real cards -------------------------------------------------------------

func test_seventeen_cards_with_unique_ids() -> void:
	var cards := Postcards.cards()
	assert_eq(cards.size(), 17, "sixteen story cards and one for the Gazetteer")
	var ids := {}
	for c in cards:
		assert_false(ids.has(str(c.id)), "duplicate card id %s" % c.id)
		ids[str(c.id)] = true

func test_every_card_is_complete_and_writes_without_em_dashes() -> void:
	var dex := Dex.load_default()
	for c in Postcards.cards():
		var tag := "card %s" % c.get("id", "?")
		for k in ["id", "after", "place", "zone", "stamp", "text", "view"]:
			assert_true(c.has(k), "%s: has %s" % [tag, k])
		assert_true(FileAccess.file_exists("res://data/zones/%s.json" % c.get("zone", "")), "%s: picture zone exists" % tag)
		assert_true(dex.has(str(c.get("stamp", ""))), "%s: the stamp's creature exists" % tag)
		var words := " ".join(PackedStringArray(c.get("text", []))) + str(c.get("place", "")) + str(c.get("ps", ""))
		assert_false(words.contains("—") or words.contains("–"), "%s: no em or en dashes" % tag)
		assert_true(words.length() > 120, "%s: a proper card, not a one-liner" % tag)
		assert_true(words.length() < 640, "%s: fits on the back of a postcard" % tag)
		var v: Dictionary = c.get("view", {})
		assert_true(v.has("x") and v.has("y"), "%s: the picture has a focus" % tag)

func test_every_card_follows_a_beat_the_story_really_sets() -> void:
	var set_by_story := {}
	var stack: Array = []
	var dialogue := StoryData.all_dialogue()
	for f in dialogue:
		for sid in dialogue[f]:
			if dialogue[f][sid] is Array:
				stack.append(dialogue[f][sid])
	for tid in StoryData.trainer_ids():
		stack.append(StoryData.trainer(tid).get("intro", []))
		set_by_story["trainer_" + tid] = true
	for m in Gazetteer.MILESTONES:  # the Gazetteer pays its milestones in code (core/gazetteer.gd)
		set_by_story[str(m.flag)] = true
	while not stack.is_empty():
		for c in stack.pop_back():
			if not c is Dictionary:
				continue
			match str(c.get("do", "")):
				"set":
					set_by_story[str(c.get("flag", ""))] = true
				"badge":
					set_by_story["badge_" + str(c.get("id", ""))] = true
				"gauntlet":
					set_by_story[str(c.get("flag", "gauntlet_won"))] = true
			for k in ["then", "else"]:
				if c.get(k) is Array:
					stack.append(c[k])
	for c in Postcards.cards():
		assert_true(set_by_story.has(str(c.after)), "card %s: its beat '%s' is set by the story" % [c.id, c.after])

func test_album_item_exists() -> void:
	var it := ItemDB.load_default().get_item(Postcards.ALBUM)
	assert_eq(str(it.get("kind", "")), "key", "the album is a key item")
