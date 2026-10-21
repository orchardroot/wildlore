extends TestCase
## Bell ringing (rows, calls, timing, pay) and drystone walling (puzzles, gravity, pay).

func test_apply_call_swaps_neighbours_and_ignores_bad_pairs() -> void:
	assert_eq(Ringing.apply_call([1, 2, 3, 4, 5, 6], [0, 4]), [2, 1, 3, 4, 6, 5])
	assert_eq(Ringing.apply_call([1, 2, 3, 4, 5, 6], [0, 1]), [2, 1, 3, 4, 5, 6], "overlapping pair skipped")
	assert_eq(Ringing.apply_call([1, 2, 3, 4, 5, 6], [5, -1]), [1, 2, 3, 4, 5, 6], "off the end skipped")

func test_every_piece_stays_a_permutation_and_ends_in_rounds_or_moves() -> void:
	assert_true(Ringing.pieces().size() >= 4)
	for p in Ringing.pieces():
		var rows := Ringing.rows_for(p)
		assert_eq(rows.size(), p.calls.size() + 1, "%s rows" % p.id)
		assert_eq(rows[0], Ringing.rounds())
		for r in rows:
			var sorted: Array = r.duplicate()
			sorted.sort()
			assert_eq(sorted, Ringing.rounds(), "%s: every row has each bell once" % p.id)
		assert_true(int(p.bell) >= 1 and int(p.bell) <= Ringing.BELLS)

func test_queens_reaches_135246() -> void:
	assert_true(Ringing.rows_for(Ringing.piece("queens")).has([1, 3, 5, 2, 4, 6]))

func test_plain_hunt_each_bell_moves_a_place_a_row() -> void:
	var rows := Ringing.rows_for(Ringing.piece("plain_hunt"))
	for k in range(1, rows.size()):
		for b in range(1, 7):
			assert_true(absi(Ringing.place_of(rows[k], b) - Ringing.place_of(rows[k - 1], b)) <= 1)

func test_judge_and_easy_is_kinder() -> void:
	var hard := Ringing.beat(false)
	var easy := Ringing.beat(true)
	assert_true(float(easy.window) > float(hard.window) and float(easy.interval) > float(hard.interval))
	assert_eq(Ringing.judge(0.01, 0.24), "perfect")
	assert_eq(Ringing.judge(-0.2, 0.24), "good")
	assert_eq(Ringing.judge(0.5, 0.24), "miss")

func test_ringing_pay_is_once_a_day() -> void:
	var data := GameStateData.new()
	var p := Ringing.piece("plain_hunt")
	var first := Ringing.finish(data, p, 7, 8)
	assert_true(first.first and first.tip > 0)
	var again := Ringing.finish(data, p, 8, 8)
	assert_false(again.first)
	assert_eq(again.tip, 0, "no second tip the same day")
	assert_eq(Ringing.finish(GameStateData.new(), p, 2, 8).tip, 0, "a ragged touch pays nothing")
	assert_true(TrainerStats.get_count(data, "rows_rung") > 0)

func test_walling_puzzles_tile_the_gap_and_are_solvable() -> void:
	var rng := Rng.new(5)
	for level in Walling.SIZES:
		for n in 20:
			var pz := Walling.generate(level, rng)
			var g := Walling.empty_grid(pz.w, pz.h)
			var cells := 0
			for s in pz.stones:
				cells += int(s.w) * int(s.h)
			assert_eq(cells, int(pz.w) * int(pz.h), "stones fill the gap exactly")
			# place bottom-up at their home cells: always supported
			var order: Array = pz.stones.duplicate()
			order.sort_custom(func(a, b): return a.y + a.h > b.y + b.h)
			for i in order.size():
				var s: Dictionary = order[i]
				assert_true(Walling.can_place(g, s.x, s.y, s.w, s.h), "%s: stone %d goes in" % [level, i])
				Walling.place(g, i + 1, s.x, s.y, s.w, s.h)
			assert_true(Walling.solved(g))

func test_stones_cannot_float_or_overlap() -> void:
	var g := Walling.empty_grid(4, 3)
	assert_false(Walling.can_place(g, 0, 0, 2, 1), "nothing under it")
	assert_true(Walling.can_place(g, 0, 2, 2, 1), "on the ground")
	Walling.place(g, 1, 0, 2, 2, 1)
	assert_false(Walling.can_place(g, 1, 2, 2, 1), "overlaps")
	assert_true(Walling.can_place(g, 0, 1, 2, 1), "on a stone")
	Walling.remove(g, 1)
	assert_eq(Walling.open_cells(g), 12)

func test_walling_pay_once_a_day_and_counts() -> void:
	var data := GameStateData.new()
	var a := Walling.finish(data, "dales", "normal", "")
	assert_true(a.first and a.fee > 0)
	var b := Walling.finish(data, "dales", "normal", "")
	assert_false(b.first)
	assert_eq(b.fee, 0)
	assert_eq(TrainerStats.get_count(data, "walls_built"), 2)
