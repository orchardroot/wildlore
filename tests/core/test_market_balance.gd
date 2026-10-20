extends TestCase
## The markets' balance over a typical playthrough (see MarketSim; tools/dev/market_sim.gd runs 1,000 seeds):
## shares edge up, Doggerel loses on average with wild swings, round trips at the bureau always cost, and no naive
## strategy prints money.

static var _t := {}

func _table() -> Dictionary:
	if _t.is_empty():
		_t = MarketSim.table(60, 500)
	return _t

func test_shares_edge_up_but_not_by_much() -> void:
	var r: Dictionary = _table().index
	assert_true(r.mean > -0.01 and r.mean < 0.15, "buy and hold the board: %s" % r.mean)
	assert_true(r.p5 > -0.25, "and it rarely hurts much: %s" % r.p5)

func test_doggerel_loses_on_average_with_huge_variance() -> void:
	var r: Dictionary = _table().coin_flip
	assert_true(r.mean < -0.1, "negative expectation: %s" % r.mean)
	assert_true(r.best - r.worst > 0.8, "huge swings: %s .. %s" % [r.worst, r.best])

func test_bureau_round_trips_always_cost() -> void:
	assert_true(_table().fx_round.best < 0.0, "every run loses the spread")

func test_nothing_prints_money() -> void:
	for s in MarketSim.STRATEGIES:
		assert_true(_table()[s].p95 < 1.0, "%s p95 under doubling: %s" % [s, _table()[s].p95])
		assert_true(_table()[s].mean < 0.2, "%s mean modest: %s" % [s, _table()[s].mean])

func test_the_villains_shares_crash() -> void:
	assert_true(_table().vane_hold.mean < -0.1, "Vane Industries ends in tears")
