extends TestCase
## The daily crossword: a sound bank, a valid grid for any day, a prize once per real day.

func test_bank_is_well_formed_and_cites_real_plaques() -> void:
	var ids := {}
	for p in Gazetteer.all():
		ids[p.id] = true
	var seen := {}
	for e in Crossword.bank():
		var a := str(e.answer)
		assert_true(a.length() >= 4 and a.length() <= Crossword.SIZE, "length of " + a)
		assert_eq(a, a.to_upper(), "capitals: " + a)
		assert_false(seen.has(a), "duplicate " + a)
		seen[a] = true
		for ch in a:
			assert_true(ch >= "A" and ch <= "Z", "letters only: " + a)
		assert_true(str(e.clue).length() > 10 and not ("—" in str(e.clue)), "clue for " + a)
		assert_true(ids.has(str(e.plaque)), "plaque %s exists for %s" % [e.plaque, a])
	assert_true(Crossword.bank().size() >= 20)

func _check(p: Dictionary) -> void:
	assert_true(p.words.size() >= Crossword.MIN_WORDS, "enough words")
	var n: int = p.size
	# every grid letter belongs to a word, and every run of 2+ letters is exactly a word
	var covered := {}
	for w in p.words:
		var cs := Crossword.cells(w)
		for k in cs.size():
			assert_eq(str(p.grid[cs[k].y][cs[k].x]), str(w.answer)[k], "word letters on the grid")
			covered[cs[k]] = true
	var runs := 0
	for y in n:
		for x in n:
			if str(p.grid[y][x]) != "":
				assert_true(covered.has(Vector2i(x, y)), "no stray letter at %d,%d" % [x, y])
	for w in p.words:
		var cs := Crossword.cells(w)
		var before: Vector2i = cs[0] - (Vector2i(1, 0) if w.dir == "across" else Vector2i(0, 1))
		var after: Vector2i = cs[cs.size() - 1] + (Vector2i(1, 0) if w.dir == "across" else Vector2i(0, 1))
		for e in [before, after]:
			assert_true(e.x < 0 or e.y < 0 or e.x >= n or e.y >= n or str(p.grid[e.y][e.x]) == "", "word is bounded")
	for y in n:
		var run := ""
		for x in n + 1:
			var c := str(p.grid[y][x]) if x < n else ""
			if c != "":
				run += c
			else:
				if run.length() >= 2:
					runs += 1
					assert_true(p.words.any(func(w): return w.dir == "across" and w.answer == run), "across run is a word: " + run)
				run = ""
	for x in n:
		var run := ""
		for y in n + 1:
			var c := str(p.grid[y][x]) if y < n else ""
			if c != "":
				run += c
			else:
				if run.length() >= 2:
					runs += 1
					assert_true(p.words.any(func(w): return w.dir == "down" and w.answer == run), "down run is a word: " + run)
				run = ""
	assert_eq(runs, p.words.size(), "every word is a run and every run a word")

func test_every_day_for_a_year_builds_a_valid_grid() -> void:
	for d in 366:
		var key := "2026-%02d-%02d" % [1 + (d % 12), 1 + (d % 28)] + str(d)
		var p := Crossword.build(key, Crossword.bank())
		assert_false(p.is_empty(), "built " + key)
		_check(p)

func test_same_day_same_grid() -> void:
	var a := Crossword.build("2026-10-21", Crossword.bank())
	var b := Crossword.build("2026-10-21", Crossword.bank())
	assert_eq(JSON.stringify(a), JSON.stringify(b))
	var c := Crossword.build("2026-10-22", Crossword.bank())
	assert_true(JSON.stringify(a) != JSON.stringify(c), "a new day, a new grid")

func test_solved_needs_every_letter() -> void:
	var p := Crossword.build("2026-10-21", Crossword.bank())
	var n: int = p.size
	var entry := []
	for y in n:
		var r := []
		for x in n:
			r.append(str(p.grid[y][x]))
		entry.append(r)
	assert_true(Crossword.solved(p, entry))
	var w: Dictionary = p.words[0]
	var c: Vector2i = Crossword.cells(w)[0]
	entry[c.y][c.x] = "?"
	assert_false(Crossword.solved(p, entry))

func test_prize_once_per_real_day() -> void:
	Calendar.set_override("2026-10-17")
	var d := GameStateData.new()
	var before := d.money
	var r := Crossword.complete(d, "york")
	assert_true(r.paid and d.money == before + r.money)
	assert_false(Crossword.complete(d, "york").paid)
	assert_eq(Crossword.solved_count(d), 1)
	Calendar.set_override("2026-10-18")
	assert_true(Crossword.complete(d, "york").paid)
	Calendar.set_override("")

func test_crossword_command() -> void:
	var h := FakeStoryHost.new()
	h.menu_results = {"crossword": {"solved": true}}
	await Commands.new(h).run([{"do": "crossword", "who": "Landlord"}])
	assert_true(Crossword.done_today(h.data))
	var money := h.data.money
	await Commands.new(h).run([{"do": "crossword"}])
	assert_eq(h.data.money, money, "no second prize today")
