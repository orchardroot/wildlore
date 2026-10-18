extends TestCase
## 2.0 QA: bugs that live between the 2.0 features (shows, parish, rewilding, coats and home, postcards, battle depth).

class FakeGame extends Node:
	var data := GameStateData.new()
	var dex: Dex
	var items: ItemDB

func _parish() -> Parish:
	var g := FakeGame.new()
	g.dex = Fixtures.dex()
	g.data.zone_id = "macclesfield"
	var p := Parish.new()
	p._game = g
	p._kind = "trainer"
	return p

func test_a_trainer_win_earns_a_little_standing() -> void:
	var p := _parish()
	p._on_battle_ended({"result": "win", "money": 100})
	assert_eq(Standing.points(p._data(), "england"), Standing.FOR_TRAINER)

func test_show_and_moot_bouts_earn_no_standing() -> void:
	# a County Show can be re-entered all day and the Open Moot without end: their wins must not farm standing
	var p := _parish()
	for i in 20:
		p._on_battle_ended({"result": "win", "money": 0, "exhibition": true})
	assert_eq(Standing.points(p._data(), "england"), 0)
