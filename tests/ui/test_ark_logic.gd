extends TestCase
## Ark ergonomics: sorting stored creatures, direct swaps, and the release rules.

func _mk(id: String, level: int) -> Creature:
	return Fixtures.creature(id, level)

func _order() -> Array:
	return Fixtures.dex().ids()

func test_sort_by_fieldbook_number() -> void:
	var order := _order()
	var ids := ["pipkin", "kindlet", "spikkin"]
	var ark := []
	for id in ids:
		ark.append(_mk(id, 5))
	ArkLogic.sort(ark, "dex", order)
	var got := ark.map(func(c): return c.species.id)
	var want := ids.duplicate()
	want.sort_custom(func(a, b): return order.find(a) < order.find(b))
	assert_eq(got, want)

func test_sort_by_level_highest_first_then_number() -> void:
	var ark := [_mk("kindlet", 5), _mk("spikkin", 20), _mk("pipkin", 5)]
	ArkLogic.sort(ark, "level", _order())
	assert_eq(ark[0].level, 20)
	var order := _order()
	assert_true(order.find(ark[1].species.id) < order.find(ark[2].species.id), "ties fall back to Fieldbook order")

func test_sort_by_type_groups_the_first_type() -> void:
	var ark := []
	for id in ["kindlet", "spikkin", "pipkin", "emberdrey", "bramblehog"]:
		ark.append(_mk(id, 5))
	ArkLogic.sort(ark, "type", _order())
	var types := ark.map(func(c): return str(c.types()[0]))
	var sorted_types := types.duplicate()
	sorted_types.sort()
	assert_eq(types, sorted_types)

func test_sort_modes_cycle() -> void:
	assert_eq(ArkLogic.next_mode("dex"), "level")
	assert_eq(ArkLogic.next_mode("level"), "type")
	assert_eq(ArkLogic.next_mode("type"), "dex")
	assert_eq(ArkLogic.next_mode("nonsense"), "dex")

func _data(party_n: int, ark_ids := []) -> GameStateData:
	var d := GameStateData.new()
	for i in party_n:
		d.party.append(_mk("kindlet", 10))
	for id in ark_ids:
		d.ark.append(_mk(id, 8))
	return d

func test_swap_party_with_ark_is_direct() -> void:
	var d := _data(6, ["spikkin"])
	var out: Creature = d.party[2]
	var inn: Creature = d.ark[0]
	assert_eq(d.swap_with_ark(2, 0), "")
	assert_true(d.party[2] == inn, "takes the same slot")
	assert_true(d.ark[0] == out, "goes to the same place in the Ark")
	assert_eq(d.party.size(), 6)

func test_swap_refuses_to_leave_no_one_fit_to_fight() -> void:
	var d := _data(1, ["spikkin"])
	d.ark[0].hp = 0
	assert_true(d.swap_with_ark(0, 0) != "", "a fainted creature can't replace the only fit one")
	assert_eq(d.party.size(), 1)
	assert_eq(d.ark.size(), 1)

func test_catch_swap_sends_the_replaced_one_to_the_ark() -> void:
	var d := _data(6)
	var old: Creature = d.party[3]
	var fresh := _mk("spikkin", 4)
	assert_eq(d.add_creature_swapping(fresh, 3), "party")
	assert_true(d.party[3] == fresh)
	assert_true(old in d.ark)
	assert_true(d.caught.has("spikkin"))
	assert_eq(d.party.size(), 6)

func test_catch_swap_with_room_just_joins() -> void:
	var d := _data(2)
	assert_eq(d.add_creature_swapping(_mk("spikkin", 4), 0), "party")
	assert_eq(d.party.size(), 3)
	assert_eq(d.ark.size(), 0)

func test_release_from_the_ark() -> void:
	var d := _data(1, ["spikkin", "pipkin"])
	var rule := ArkLogic.release_rule(d, false, 0)
	assert_true(rule.ok)
	assert_eq(rule.confirms, 1)
	assert_eq(d.release(false, 0), "")
	assert_eq(d.ark.size(), 1)
	assert_eq(d.ark[0].species.id, "pipkin")

func test_never_release_the_last_team_member() -> void:
	var d := _data(1)
	var rule := ArkLogic.release_rule(d, true, 0)
	assert_false(rule.ok)
	assert_true(rule.why != "")
	assert_true(d.release(true, 0) != "")
	assert_eq(d.party.size(), 1)

func test_never_release_the_last_fit_team_member() -> void:
	var d := _data(2)
	d.party[1].hp = 0
	assert_false(ArkLogic.release_rule(d, true, 0).ok, "the only fit one stays")
	assert_true(ArkLogic.release_rule(d, true, 1).ok, "the fainted one may go")

func test_legends_need_a_double_confirm() -> void:
	var d := _data(1, ["bran", "spikkin"])
	assert_true(ArkLogic.is_legend(d.ark[0]))
	assert_false(ArkLogic.is_legend(d.ark[1]))
	assert_eq(ArkLogic.release_rule(d, false, 0).confirms, 2)
	assert_eq(ArkLogic.release_rule(d, false, 1).confirms, 1)

func test_story_legends_with_a_normal_catch_rate_still_count() -> void:
	var d := _data(1, ["megalorn", "tylwyth", "spikkin"])
	assert_true(int(d.ark[0].species.catch_rate) > 3, "megalorn is not rock-bottom")
	assert_true(ArkLogic.is_legend(d.ark[0]))
	assert_true(ArkLogic.is_legend(d.ark[1]))
	assert_false(ArkLogic.is_legend(d.ark[2]))
	assert_eq(ArkLogic.release_rule(d, false, 0).confirms, 2)

func test_release_bad_index() -> void:
	var d := _data(2)
	assert_true(d.release(false, 5) != "")
	assert_true(d.release(true, 9) != "")
