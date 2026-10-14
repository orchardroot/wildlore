extends TestCase
## Double battles: two creatures a side, per-position actions, targets, spread moves, replacements.

const HIT := {"type": "move", "slot": 0, "target": 0}

func _types(events: Array) -> Array:
	return events.map(func(e): return e.type)

func _all(events: Array, type: String) -> Array:
	return events.filter(func(e): return e.type == type)

## A sturdy hand-made creature with the given speed and moves (default: Scrap only).
func _mon(id: String, spd: int, move_ids := ["scrap"], hp := 200, types := ["kin"]) -> Creature:
	var base := {"hp": hp, "atk": 50, "def": 50, "lore": 50, "ward": 50, "spd": spd}
	var c := Creature.create(Fixtures.species(id, types, 50, {"base": base}), 20, FixedRng.new(), Fixtures.moves())
	c.moves = []
	for m in move_ids:
		c.moves.append(c.make_move_slot(m, Fixtures.moves()))
	return c

func _double(player: Array, foe: Array, opts := {}) -> Battle:
	var o := {"kind": "trainer", "double": true}
	o.merge(opts, true)
	return Fixtures.battle(player, foe, o)

func test_two_a_side_on_the_field() -> void:
	var p := [_mon("pa", 50), _mon("pb", 50), _mon("pc", 50)]
	var f := [_mon("fa", 50), _mon("fb", 50)]
	var b := _double(p, f)
	assert_true(b.double)
	assert_eq(b.active, [[0, 1], [0, 1]])
	assert_eq(b.current(Battle.PLAYER), p[0])
	assert_eq(b.current_at(Battle.PLAYER, 1), p[1])
	assert_eq(b.actives(Battle.FOE), f)
	assert_false(b.needs_switch(Battle.PLAYER))

func test_singles_keep_one_a_side() -> void:
	var b := Fixtures.battle([_mon("pa", 50), _mon("pb", 50)], [_mon("fa", 50)])
	assert_false(b.double)
	assert_eq(b.active, [[0], [0]])
	assert_eq(b.actives(Battle.PLAYER).size(), 1)
	var ev := b.take_turn({"type": "move", "slot": 0}, {"type": "move", "slot": 0})
	for e in ev:
		assert_false(e.has("pos"), "singles events carry no position")

func test_party_of_one_fights_a_double_alone() -> void:
	var b := _double([_mon("pa", 50)], [_mon("fa", 50), _mon("fb", 50)])
	assert_eq(b.active[Battle.PLAYER], [0, -1])
	assert_eq(b.current_at(Battle.PLAYER, 1), null)
	assert_eq(b.actives(Battle.PLAYER).size(), 1)
	assert_false(b.needs_switch(Battle.PLAYER))
	var ev := b.take_turn([HIT], [HIT, HIT])
	assert_eq(_all(ev, "move").size(), 3)

func test_turn_order_across_four_by_speed() -> void:
	var b := _double([_mon("pa", 30), _mon("pb", 90)], [_mon("fa", 60), _mon("fb", 120)])
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var order := _all(ev, "move").map(func(e): return [e.side, e.pos])
	assert_eq(order, [[1, 1], [0, 1], [1, 0], [0, 0]])

func test_priority_beats_speed_in_doubles() -> void:
	var b := _double([_mon("pa", 10, ["quick_nip"]), _mon("pb", 90)], [_mon("fa", 60), _mon("fb", 120)])
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var first: Dictionary = _all(ev, "move")[0]
	assert_eq([first.side, first.pos, first.move], [0, 0, "quick_nip"])

func test_switch_goes_before_moves() -> void:
	var b := _double([_mon("pa", 10), _mon("pb", 10), _mon("pc", 10)], [_mon("fa", 120), _mon("fb", 120)])
	var ev := b.take_turn([HIT, {"type": "switch", "index": 2}], [HIT, HIT])
	assert_eq(ev[0].type, "switch")
	assert_eq(ev[0].pos, 1)
	assert_eq(b.active[Battle.PLAYER], [0, 2])

func test_single_target_move_hits_the_chosen_foe() -> void:
	var b := _double([_mon("pa", 90), _mon("pb", 10)], [_mon("fa", 50), _mon("fb", 50)])
	var ev := b.take_turn([{"type": "move", "slot": 0, "target": 1}, HIT], [HIT, HIT])
	var first: Dictionary = _all(ev, "damage")[0]
	assert_eq([first.side, first.pos], [Battle.FOE, 1])
	assert_true(b.current_at(Battle.FOE, 1).hp < b.current_at(Battle.FOE, 1).max_hp())

func test_spread_move_hits_both_foes_at_three_quarters() -> void:
	assert_eq(Fixtures.moves().get_move("murmuration").get("target", ""), "all_foes")
	var r := FixedRng.new()
	r.f = 0.5  # hits (95% accuracy), no crit
	var single := Fixtures.battle([_mon("pa", 90, ["murmuration"])], [_mon("fa", 10)], {"rng": r})
	var one: int = _all(single.take_turn({"type": "move", "slot": 0}, {"type": "move", "slot": 0}), "damage")[0].amount
	var b := _double([_mon("pa", 90, ["murmuration"]), _mon("pb", 5)], [_mon("fa", 10), _mon("fb", 10)], {"rng": r})
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var spread := _all(ev, "damage").slice(0, 2)
	assert_eq(spread.map(func(e): return [e.side, e.pos]), [[1, 0], [1, 1]])
	for e in spread:
		assert_true(e.amount < one, "spread hits are weaker")
		assert_true(absf(e.amount - one * 0.75) <= 1.0, "about three quarters: %d vs %d" % [e.amount, one])
	assert_eq(_all(ev, "move").size(), 4, "one move event for the spread move, then the other three")

func test_retarget_when_chosen_foe_fainted_earlier_in_the_turn() -> void:
	var weak := _mon("fa", 10, ["scrap"], 1)
	weak.hp = 1
	var b := _double([_mon("pa", 90), _mon("pb", 70)], [weak, _mon("fb", 5)])
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var faint: Dictionary = _all(ev, "faint")[0]
	assert_eq([faint.side, faint.pos], [Battle.FOE, 0])
	var hits := _all(ev, "damage")
	assert_eq([hits[1].side, hits[1].pos], [Battle.FOE, 1], "the second attacker swings at the other foe")

func test_fainted_active_is_replaced_from_reserves_while_partner_fights_on() -> void:
	var weak := _mon("fa", 10, ["scrap"], 1)
	weak.hp = 1
	var reserve := _mon("fc", 10)
	var b := _double([_mon("pa", 90), _mon("pb", 70)], [weak, _mon("fb", 5), reserve])
	b.take_turn([HIT, {"type": "move", "slot": 0, "target": 1}], [HIT, HIT])
	assert_false(b.over)
	assert_true(b.needs_switch(Battle.FOE))
	assert_true(b.needs_switch_at(Battle.FOE, 0))
	assert_false(b.needs_switch_at(Battle.FOE, 1))
	assert_eq(b.take_turn([HIT, HIT], [HIT, HIT])[0].type, "invalid", "turn refused while a replacement is owed")
	assert_eq(b.force_switch(Battle.FOE, 1)[0].type, "invalid", "can't send out the creature already fighting")
	var ev := b.force_switch(Battle.FOE, 2)
	assert_eq(ev[0].type, "switch")
	assert_eq(ev[0].pos, 0)
	assert_eq(b.active[Battle.FOE], [2, 1])
	assert_false(b.needs_switch(Battle.FOE))
	assert_has(_types(b.take_turn([HIT, HIT], [HIT, HIT])), "move")

func test_force_switch_to_a_chosen_position() -> void:
	var a := _mon("pa", 10, ["scrap"], 1)
	var c := _mon("pb", 10, ["scrap"], 1)
	a.hp = 1
	c.hp = 1
	a.status = "stung"
	c.status = "stung"
	var b := _double([a, c, _mon("pc", 10), _mon("pd", 10)], [_mon("fa", 5), _mon("fb", 5)])
	b.take_turn([{"type": "move", "slot": 0, "target": 0}, HIT], [HIT, HIT])
	assert_true(b.needs_switch_at(Battle.PLAYER, 0) and b.needs_switch_at(Battle.PLAYER, 1))
	assert_eq(b.force_switch(Battle.PLAYER, 3, 1)[0].pos, 1)
	assert_eq(b.force_switch(Battle.PLAYER, 2)[0].pos, 0, "no position given: the first one that needs it")
	assert_eq(b.active[Battle.PLAYER], [2, 3])

func test_side_with_one_creature_left_fights_on_alone() -> void:
	var weak := _mon("fa", 10, ["scrap"], 1)
	weak.hp = 1
	var b := _double([_mon("pa", 90), _mon("pb", 70)], [weak, _mon("fb", 5)])
	b.take_turn([HIT, {"type": "move", "slot": 0, "target": 1}], [HIT, HIT])
	assert_false(b.over)
	assert_false(b.needs_switch(Battle.FOE), "no reserves, so nobody to send out")
	assert_eq(b.actives(Battle.FOE).size(), 1)
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var foe_moves := _all(ev, "move").filter(func(e): return e.side == Battle.FOE)
	assert_eq(foe_moves.size(), 1)
	assert_eq(foe_moves[0].pos, 1)
	for e in _all(ev, "damage").filter(func(e): return e.side == Battle.FOE):
		assert_eq(e.pos, 1, "attacks aimed at the empty spot go to the one left")

func test_battle_ends_only_when_a_whole_side_is_out() -> void:
	var fa := _mon("fa", 10, ["scrap"], 1)
	var fb := _mon("fb", 5)
	fa.hp = 1
	var b := _double([_mon("pa", 90), _mon("pb", 70)], [fa, fb])
	b.take_turn([HIT, {"type": "move", "slot": 0, "target": 1}], [HIT, HIT])
	assert_false(b.over, "one foe still standing")
	fb.hp = 1
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	assert_true(b.over)
	assert_eq(b.winner, Battle.PLAYER)
	assert_eq(ev.back(), {"type": "end", "winner": 0})

func test_catch_and_run_are_refused_in_doubles() -> void:
	var r := FixedRng.new()
	r.f = 0.0
	var b := _double([_mon("pa", 90), _mon("pb", 70)], [_mon("fa", 5), _mon("fb", 5)], {"kind": "wild", "rng": r})
	var ev := b.take_turn([{"type": "catch", "snare": "silver"}, {"type": "run"}], [HIT, HIT])
	var bad := _all(ev, "invalid")
	assert_eq(bad.size(), 2)
	assert_eq(bad[0].reason, "no_catch_in_doubles")
	assert_eq(bad[1].reason, "no_run_in_doubles")
	assert_false(b.over)
	assert_eq(b.caught, null)

func test_faint_event_names_the_player_creatures_that_saw_it() -> void:
	var weak := _mon("fa", 10, ["scrap"], 1)
	weak.hp = 1
	var b := _double([_mon("pa", 90), _mon("pb", 70), _mon("pc", 70)], [weak, _mon("fb", 5)])
	var ev := b.take_turn([HIT, HIT], [HIT, HIT])
	var faint: Dictionary = _all(ev, "faint")[0]
	assert_eq(faint.index, 0)
	assert_eq(faint.witnesses, [0, 1])
