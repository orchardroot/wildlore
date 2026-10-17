extends TestCase
## Charms and friendship through the battle flow: start-of-battle charms are said after the intro, a caught
## creature's charm is mentioned, and a win brings the team closer.

var _items := ItemDB.load_default()

func _flow(party: Array, foes: Array, ui: FakeBattleUI) -> BattleFlow:
	var data := GameStateData.new()
	data.party = party
	return BattleFlow.new(data, Fixtures.dex(), Fixtures.moves(), Fixtures.chart(), _items, Rng.new(7), foes, {}, ui)

func test_oak_acorn_is_announced_after_the_intro() -> void:
	var a := Fixtures.creature("kindlet", 10)
	a.held = "oak_acorn"
	var f := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new())
	f.run()
	var at := f.log.find("Kindlet's Oak Acorn made it feel sturdy!")
	assert_true(at > 0, "said")
	assert_true(at > f.log.find("Go! Kindlet!"), "after the intro")

func test_win_adds_friendship() -> void:
	var a := Fixtures.creature("kindlet", 30)
	var f0 := a.friendship
	var f := _flow([a], [Fixtures.creature("spikkin", 3)], FakeBattleUI.new())
	f.run()
	assert_eq(f.result.result, "win")
	assert_true(a.friendship >= f0 + Bond.WIN)
