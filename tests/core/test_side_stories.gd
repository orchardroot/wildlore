extends TestCase
## Keeper side stories: gating (beaten, then one more Stone), the NPC that waits in town, "Where next?" pointing
## at one once there is no story objective, and the real placements and scripts.

const SIDES := [
	{"id": "maud", "who": "Keeper Maud", "sprite": "keeper_maud", "after": "trainer_keeper_maud", "badges": 2,
		"zone": "buxton", "x": 5, "y": 6, "facing": "left", "hint": "Maud is in Buxton."},
	{"id": "hester", "who": "Keeper Hester", "sprite": "keeper_hester", "after": "trainer_keeper_hester", "needs": "moot_won",
		"zone": "york", "x": 3, "y": 4, "facing": "down", "hint": "Hester is in York."},
	{"id": "garside", "who": "Prof. Garside", "sprite": "prof_garside", "after": "game_complete",
		"zone": "macclesfield", "x": 7, "y": 8, "hint": "Garside is in Macc."},
]

func _data(flags := {}, badges := 0) -> GameStateData:
	var d := GameStateData.new()
	d.flags = flags.duplicate()
	for i in badges:
		d.badges.append("b%d" % i)
	return d

func test_not_before_the_keeper_is_beaten() -> void:
	assert_false(SideStories.waiting(_data({}, 5), SIDES[0]), "never met Maud")

func test_waits_for_one_more_stone() -> void:
	var d := _data({"trainer_keeper_maud": true}, 1)
	assert_false(SideStories.waiting(d, SIDES[0]), "just beaten her: give it a Stone")
	d.badges.append("urban")
	assert_true(SideStories.waiting(d, SIDES[0]), "one more Stone and she's out in town")

func test_done_once_the_scene_has_played() -> void:
	var d := _data({"trainer_keeper_maud": true}, 3)
	d.set_flag(SideStories.done_flag("maud"), true)
	assert_eq(SideStories.done_flag("maud"), "keeper_side_maud")
	assert_false(SideStories.waiting(d, SIDES[0]))

func test_needs_flag_instead_of_a_badge_count() -> void:
	var d := _data({"trainer_keeper_hester": true}, 10)
	assert_false(SideStories.waiting(d, SIDES[1]), "the tenth Stone has no next one: the Moot instead")
	d.set_flag("moot_won", true)
	assert_true(SideStories.waiting(d, SIDES[1]))

func test_npc_def_only_in_its_zone_and_only_while_waiting() -> void:
	var d := _data({"trainer_keeper_maud": true}, 2)
	assert_eq(SideStories.npcs_for("york", d, SIDES), [], "nobody waiting in York")
	var defs := SideStories.npcs_for("buxton", d, SIDES)
	assert_eq(defs.size(), 1)
	var n: Dictionary = defs[0]
	assert_eq(str(n.id), "side_maud")
	assert_eq(str(n.sprite), "keeper_maud")
	assert_eq([int(n.x), int(n.y)], [5, 6])
	assert_eq(str(n.facing), "left")
	assert_eq(str(n.script), "keeper_side_maud")
	assert_eq(str(n.script_file), SideStories.SCRIPT_FILE)
	assert_eq(str(n.name), "Keeper Maud")
	d.set_flag("keeper_side_maud", true)
	assert_eq(SideStories.npcs_for("buxton", d, SIDES), [], "gone home once the scene is done")

func test_next_hint_is_the_first_waiting_side() -> void:
	var d := _data({"trainer_keeper_maud": true, "game_complete": true}, 2)
	assert_eq(SideStories.next_hint(d, SIDES), {"text": "Maud is in Buxton.", "town": "buxton"})
	d.set_flag("keeper_side_maud", true)
	assert_eq(SideStories.next_hint(d, SIDES), {"text": "Garside is in Macc.", "town": "macclesfield"})
	d.set_flag("keeper_side_garside", true)
	assert_eq(SideStories.next_hint(d, SIDES), {})

func test_where_next_points_at_a_side_story_when_the_story_is_done() -> void:
	var o := {"story": [{"flag_done": "starter", "text": "Go and see Garside.", "town": "macclesfield"}],
		"postgame": [{"flag_done": "caught_bran", "text": "Find Bran.", "town": "london"}, {"text": "You've seen it all.", "town": ""}]}
	var d := _data({"starter": "kindlet", "trainer_keeper_maud": true}, 3)
	assert_eq(str(MenuLogic.next_objective(d, 0, o).text), "Go and see Garside.", "a story objective wins")
	d.set_flag("game_complete", true)
	assert_eq(str(MenuLogic.next_objective(d, 0, o).text), "Find Bran.", "a post-game objective still wins")
	d.set_flag("caught_bran", true)
	var next := MenuLogic.next_objective(d, 0, o, SIDES)
	assert_eq(str(next.text), "Maud is in Buxton.", "nothing else on: a waiting side story")
	assert_eq(str(next.town), "buxton")
	assert_true(next.get("postgame", false), "shown under Still to do")
	d.set_flag("keeper_side_maud", true)
	d.set_flag("keeper_side_garside", true)
	var after := str(MenuLogic.next_objective(d, 0, o, SIDES).text)
	assert_false(after.contains("Buxton") or after.contains("Macc."), "all done: back to the Fieldbook milestone or the catch-all")

# --- the real data ----------------------------------------------------------------

const KEEPERS := ["maud", "ray", "eluned", "rhys", "morwen", "declan", "nuala", "ruairi", "isla", "hester"]
const OTHERS := ["pryce", "ashcombe", "kerrigan", "strachan", "garside"]

func test_fifteen_sides_ten_keepers_four_directors_and_garside() -> void:
	var ids := SideStories.sides().map(func(s): return str(s.id))
	for k in KEEPERS + OTHERS:
		assert_has(ids, k)
	assert_eq(ids.size(), 15)

func test_each_keeper_waits_for_their_own_battle_and_a_later_stone() -> void:
	for s in SideStories.sides():
		var id := str(s.id)
		if id not in KEEPERS:
			assert_eq(str(s.after), "game_complete", "%s: after the ending" % id)
			continue
		assert_true(StoryData.trainer_exists(str(s.after).trim_prefix("trainer_")), "%s: gated on a real Keeper battle" % id)
		var i := KEEPERS.find(id)
		if s.has("badges"):
			assert_eq(int(s.badges), i + 2, "%s: one more Stone than theirs" % id)
		else:
			assert_true(str(s.get("needs", "")) != "", "%s: a later beat to wait for" % id)

func test_every_side_stands_somewhere_sensible() -> void:
	for s in SideStories.sides():
		var tag := "side %s" % s.get("id", "?")
		var z := ZoneData.load_id(str(s.zone))
		assert_true(z != null and z.kind != "interior", "%s: out in a town, not indoors" % tag)
		if z == null:
			continue
		var p := Vector2i(int(s.x), int(s.y))
		assert_true(SideStories.free_tile(z, p), "%s: (%d, %d) is free to stand on" % [tag, p.x, p.y])
		assert_true(z.reachable(z.spawn, ["hedge_lay"]).has(p + GridMotion.dir_vec(str(s.get("facing", "down")))) or _any_neighbour_reachable(z, p),
			"%s: you can walk up to them" % tag)
		assert_true(FileAccess.file_exists("res://art/sprites/chars/%s.png" % s.sprite), "%s: sprite has art" % tag)
		assert_true(str(s.get("hint", "")) != "", "%s: has a Where next hint" % tag)

func _any_neighbour_reachable(z: ZoneData, p: Vector2i) -> bool:
	var r := z.reachable(z.spawn, ["hedge_lay"])
	for d in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if r.has(p + d):
			return true
	return false

func test_free_tile_spirals_off_a_taken_tile() -> void:
	var z := ZoneData.from_dict({"id": "sz", "kind": "town", "rows": ["....", "....", "...."],
		"npcs": [{"id": "a", "x": 1, "y": 1}], "props": [{"type": "post_box", "x": 2, "y": 1}]})
	assert_false(SideStories.free_tile(z, Vector2i(1, 1)), "someone's there")
	assert_false(SideStories.free_tile(z, Vector2i(2, 1)), "a post box is there")
	var p := SideStories.nearest_free(z, Vector2i(1, 1))
	assert_true(SideStories.free_tile(z, p))
	assert_true(maxi(absi(p.x - 1), absi(p.y - 1)) == 1, "right next to it")

func test_every_side_has_a_script_that_ends_by_setting_its_flag() -> void:
	for s in SideStories.sides():
		var sid := "keeper_side_" + str(s.id)
		var cmds := StoryData.script(SideStories.SCRIPT_FILE, sid)
		assert_false(cmds.is_empty(), "%s: script exists" % sid)
		if cmds.is_empty():
			continue
		assert_eq(str(cmds[0].get("do", "")), "if", "%s: the afterword once done, else the scene" % sid)
		assert_eq(str(cmds[0].get("flag", "")), sid)
		var scene: Array = cmds[0].get("else", [])
		assert_true(scene.size() >= 4, "%s: a proper little scene" % sid)
		assert_eq(str(scene.back().get("do", "")), "set", "%s: the scene ends by setting its flag" % sid)
		assert_eq(str(scene.back().get("flag", "")), sid)
		var rewards := scene.filter(func(c): return str(c.get("do", "")) in ["give_item", "recipe"])
		assert_false(rewards.is_empty(), "%s: ends with a charm or recipe" % sid)
		var text := JSON.stringify(cmds)
		assert_false(text.contains("—") or text.contains("–"), "%s: no em or en dashes" % sid)
