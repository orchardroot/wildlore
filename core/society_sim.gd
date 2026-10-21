class_name SocietySim
extends RefCounted
## Plays naive strategies against the real Building Society over a year of in-game days, many runs over, to check
## that nothing prints money: borrowing to save or to sit on loses every time, and even saving every pound only earns
## a few per cent. tests/core/test_building_society.gd runs it. Pure logic.

const YEAR := 360
const STEP := 5           # a visit to the branch every few in-game days
const START := 3000
const BADGES := 3
const STRATEGIES := ["save_all", "borrow_and_save", "borrow_and_sit", "random"]

static func _fresh() -> GameStateData:
	var d := GameStateData.new()
	d.money = START
	d.day_count = 0
	for i in BADGES:
		d.badges.append("b%d" % i)
	return d

static func _fund_payment(d: GameStateData) -> void:
	# keep enough in the purse for the next instalment (and the bus fare), from savings if need be
	if not BuildingSociety.has_loan(d):
		return
	var l := BuildingSociety.loan(d)
	var need := int(l.pay) + BuildingSociety.BUS_FARE - d.money
	if need > 0:
		BuildingSociety.withdraw(d, "gbp", mini(need, BuildingSociety.saved(d, "gbp")))

static func _park(d: GameStateData) -> void:
	_fund_payment(d)
	var keep := 0
	if BuildingSociety.has_loan(d):
		keep = int(BuildingSociety.loan(d).pay) + BuildingSociety.BUS_FARE
	if d.money > keep:
		BuildingSociety.deposit(d, "gbp", d.money - keep)

## One run: the change in net worth as a fraction of the start.
static func run(strategy: String, seed_value: int) -> float:
	var d := _fresh()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("society:%d" % seed_value)
	BuildingSociety.settle(d)
	BuildingSociety.collect_letters(d)  # Mum's sub comes with the post, and is owed back, so it nets to nothing
	var start := BuildingSociety.net_worth(d, "gbp")
	while d.day_count < YEAR:
		match strategy:
			"save_all":
				_park(d)
			"borrow_and_save":
				if not BuildingSociety.has_loan(d) and BuildingSociety.limit(d, "gbp") > 0:
					BuildingSociety.borrow(d, "manchester_society", BuildingSociety.limit(d, "gbp"), 24)
				_park(d)
			"borrow_and_sit":
				if not BuildingSociety.has_loan(d):
					BuildingSociety.borrow(d, "manchester_society", BuildingSociety.limit(d, "gbp"), 24)
			"random":
				match rng.randi_range(0, 5):
					0:
						BuildingSociety.borrow(d, "cardiff_society", rng.randi_range(50, BuildingSociety.limit(d, "gbp")), BuildingSociety.TERMS[rng.randi_range(0, 2)])
					1:
						BuildingSociety.repay(d, rng.randi_range(1, 2000))
					2:
						BuildingSociety.deposit(d, "gbp", rng.randi_range(1, maxi(1, d.money)))
					3:
						BuildingSociety.withdraw(d, "gbp", rng.randi_range(1, maxi(1, BuildingSociety.saved(d, "gbp"))))
					4:
						BuildingSociety.repay_mum(d, rng.randi_range(1, 300))
					_:
						pass
				_fund_payment(d)
		d.day_count += STEP
		BuildingSociety.settle(d)
		BuildingSociety.collect_letters(d)
	return float(BuildingSociety.net_worth(d, "gbp") - start) / START

## {strategy: {mean, best, worst}} over `runs` runs.
static func table(runs: int, first_seed := 1) -> Dictionary:
	var out := {}
	for s in STRATEGIES:
		var sum := 0.0
		var best := -INF
		var worst := INF
		for i in runs:
			var x := run(s, first_seed + i)
			sum += x
			best = maxf(best, x)
			worst = minf(worst, x)
		out[s] = {"mean": sum / runs, "best": best, "worst": worst}
	return out
