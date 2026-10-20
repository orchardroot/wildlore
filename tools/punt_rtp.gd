extends SceneTree
## Simulates many seeded sessions of every casino game and race bet and prints the return to player.
## Usage: godot --headless --path . -s res://tools/punt_rtp.gd [-- sessions]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var sessions := int(args[0]) if args.size() > 0 else 200
	print("Return to player over %d seeded sessions per game" % sessions)
	_fruit(sessions)
	_roulette(sessions)
	_blackjack(sessions)
	_hilo(sessions)
	_races(sessions)
	quit()

func _line(label: String, staked: float, back: float) -> void:
	print("  %-46s RTP %6.2f%%   (staked %d)" % [label, 100.0 * back / maxf(1.0, staked), int(staked)])

func _fruit(n: int) -> void:
	print("Fruit machine (exact, perfect nudging, no holds): %.2f%%" % (100.0 * FruitMachine.exact_rtp_with_nudges()))
	for sharp in [true, false]:
		var st := 0.0
		var bk := 0.0
		for s in n:
			var r := FruitMachine.simulate(Rng.new(1000 + s), 500, sharp)
			st += r.staked
			bk += r.returned
		_line("Fruit machine, 500 spins, %s" % ("perfect nudges + holds" if sharp else "features ignored"), st, bk)

func _roulette(n: int) -> void:
	var bets := {"straight up": Roulette.straight(17), "red": Roulette.red(), "corner": Roulette.corner(8), "dozen": Roulette.dozen(2)}
	for label in bets:
		var st := 0.0
		var bk := 0.0
		for s in n:
			var rng := Rng.new(2000 + s)
			for i in 200:
				st += 10
				bk += Roulette.returns(bets[label], 10, Roulette.spin(rng))
		_line("Roulette, 200 spins, %s" % label, st, bk)

func _blackjack(n: int) -> void:
	var st := 0.0
	var bk := 0.0
	for s in n:
		var rng := Rng.new(3000 + s)
		for i in 100:
			var g := Blackjack.new(rng, 10)
			while not g.done:
				match Blackjack.basic_strategy(g):
					"double": g.double_down()
					"hit": g.hit()
					_: g.stand()
			st += g.stake
			bk += g.returns()
	_line("Blackjack, 100 hands, basic strategy", st, bk)

func _hilo(n: int) -> void:
	for steps in [1, 3, 5]:
		var st := 0.0
		var bk := 0.0
		for s in n:
			var rng := Rng.new(4000 + s)
			for i in 100:
				var g := HigherLower.new(rng, 10)
				for k in steps:
					if g.done:
						break
					var r: int = g.card().rank
					g.guess("higher" if HigherLower.chance("higher", r) >= HigherLower.chance("lower", r) else "lower")
				g.cash_out()
				st += 10
				bk += g.returns()
		_line("Higher or Lower, likelier call, cash out after %d" % steps, st, bk)

func _races(n: int) -> void:
	var dex := Dex.load_default()
	var kinds := {"win, the favourite": "fav", "win, a random runner": "any", "each-way, a random runner": "ew"}
	for label in kinds:
		var st := 0.0
		var bk := 0.0
		for s in n:
			var rng := Rng.new(5000 + s)
			for k in range(1, 7):
				var c := Racing.card("2026-%02d-%02d" % [s % 12 + 1, s % 28 + 1], k, Racing.going_for(["clear", "downpour", "sunshine", "drizzle"][(s + k) % 4]), dex)
				var pick := rng.roll_int(0, c.runners.size() - 1)
				if kinds[label] == "fav":
					for i in c.runners.size():
						if c.runners[i].p_win > c.runners[pick].p_win:
							pick = i
				var ew: bool = kinds[label] == "ew"
				var res := Racing.run(c, rng)
				st += 20 if ew else 10
				bk += Racing.returns(c, res.order, {"runner": pick, "stake": 10, "each_way": ew})
		_line("Racing, 6-race card, %s" % label, st, bk)
