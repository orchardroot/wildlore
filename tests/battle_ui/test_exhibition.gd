extends TestCase
## County Show and Open Moot bouts (opts.exhibition, opts.no_items): no XP, and the "No Items" class shuts the bag.

var _items := ItemDB.load_default()

func _flow(party: Array, foes: Array, ui: FakeBattleUI, opts := {}, bag := {}) -> BattleFlow:
	var data := GameStateData.new()
	data.party = party
	data.bag = bag
	return BattleFlow.new(data, Fixtures.dex(), Fixtures.moves(), Fixtures.chart(), _items, Rng.new(7), foes, opts, ui)

func test_an_exhibition_bout_gives_no_xp() -> void:
	var a := Fixtures.creature("kindlet", 10)
	var xp0 := a.xp
	var ui := FakeBattleUI.new()
	var f := _flow([a], [Fixtures.creature("spikkin", 3)], ui, {"kind": "trainer", "ai": "trainer", "trainer": {"name": "Angler Meirion"}, "exhibition": true})
	f.run()
	assert_eq(f.result.result, "win")
	assert_eq(a.xp, xp0, "no XP at a show")
	assert_eq(ui.xp_calls, 0)
	assert_true(bool(f.result.get("exhibition", false)), "the result says it was a show bout (no standing for it)")

func test_no_items_shuts_the_bag() -> void:
	var a := Fixtures.creature("kindlet", 10)
	var bag := {"cup_of_tea": 3}
	var open := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new(), {"kind": "trainer"}, bag)
	assert_true(open.battle_items().size() > 0, "a normal bout has the tea")
	var shut := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new(), {"kind": "trainer", "no_items": true}, bag)
	assert_eq(shut.battle_items(), [])
	assert_true(shut.empty_bag_text().contains("rules"), shut.empty_bag_text())
	var snares := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new(), {"kind": "trainer"}, {"wicker_snare": 2})
	assert_true(snares.empty_bag_text().contains("another keeper"), snares.empty_bag_text())
	var bare := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new(), {"kind": "trainer"}, {})
	assert_true(bare.empty_bag_text().contains("Nothing in your bag"), bare.empty_bag_text())
