extends SceneTree
## Prints the market balance table: naive strategies over a typical playthrough, 1,000 seeded runs each.
## Usage: godot --headless --path . -s res://tools/dev/market_sim.gd -- [runs]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var runs := int(args[0]) if args.size() > 0 else 1000
	var t := MarketSim.table(runs)
	print("Wealth change over %d in-game days from %d pounds, %d runs (sterling at the middle rate):" % [MarketSim.DAYS, MarketSim.START, runs])
	print("%-10s %8s %8s %8s %8s %8s %8s %7s" % ["strategy", "mean", "median", "p5", "p95", "worst", "best", "lose"])
	for s in MarketSim.STRATEGIES:
		var r: Dictionary = t[s]
		print("%-10s %+7.1f%% %+7.1f%% %+7.1f%% %+7.1f%% %+7.1f%% %+7.1f%% %6.0f%%" % [s, r.mean * 100, r.median * 100, r.p5 * 100, r.p95 * 100, r.worst * 100, r.best * 100, r.lose * 100])
	quit(0)
