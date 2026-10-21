class_name Crossword
extends RefCounted
## The daily crossword: a small cryptic-lite grid built from data/crossword.json (answer, clue, and the Gazetteer
## plaque the fact comes from), seeded by the real date so everyone gets the same grid on the same day. Words are
## laid crossing one another with no stray letter runs, so every run of two or more letters is a clue. Solving it
## pays a small prize once per real day. Pure logic; ui/crossword_screen.gd shows it and the quiz command offers it.

const PATH := "res://data/crossword.json"
const SIZE := 7
const TARGET_WORDS := 7
const MIN_WORDS := 5
const FLAG := "crossword_day"
const COUNT_FLAG := "crossword_done"
const PRIZE := 150

static var _bank: Array = []

static func bank() -> Array:
	if _bank.is_empty():
		var raw: Variant = JsonUtil.read(PATH)
		if raw is Array:
			_bank = raw
	return _bank

static func _seed(key: String) -> int:
	var h := 17
	for ch in key:
		h = (h * 31 + ch.unicode_at(0)) % 2147483629
	return h

## {size, grid (rows of letters, "" for a block), words: [{n, dir, x, y, answer, clue, plaque}]}, or {} if the bank is too small.
static func build(key: String, entries: Array, size := SIZE) -> Dictionary:
	if entries.size() < MIN_WORDS:
		return {}
	var rng := Rng.new(_seed(key))
	for attempt in 60:
		var pool: Array = entries.duplicate()
		for i in range(pool.size() - 1, 0, -1):
			var j := rng.roll_int(0, i)
			var t = pool[i]
			pool[i] = pool[j]
			pool[j] = t
		var st := _fresh(size)
		var first: Dictionary = pool[0]
		var fl := str(first.answer).length()
		_put(st, first, (size - fl) / 2, rng.roll_int(1, size - 2), true)
		for k in range(1, pool.size()):
			if st.words.size() >= TARGET_WORDS:
				break
			_cross(st, pool[k])
		if st.words.size() >= MIN_WORDS:
			return _finish(st)
	return {}

static func _fresh(size: int) -> Dictionary:
	var g := []
	var h := []
	var v := []
	for y in size:
		g.append(_row(size, ""))
		h.append(_row(size, false))
		v.append(_row(size, false))
	return {"size": size, "g": g, "h": h, "v": v, "words": []}

static func _row(n: int, fill: Variant) -> Array:
	var r := []
	r.resize(n)
	r.fill(fill)
	return r

static func _put(st: Dictionary, e: Dictionary, x: int, y: int, across: bool) -> void:
	var a := str(e.answer)
	for k in a.length():
		var cx := x + (k if across else 0)
		var cy := y + (0 if across else k)
		st.g[cy][cx] = a[k]
		(st.h if across else st.v)[cy][cx] = true
	st.words.append({"dir": "across" if across else "down", "x": x, "y": y, "answer": a, "clue": str(e.clue), "plaque": str(e.get("plaque", ""))})

static func _empty(st: Dictionary, x: int, y: int) -> bool:
	var n: int = st.size
	return x < 0 or y < 0 or x >= n or y >= n or st.g[y][x] == ""

## Tries every letter the new word shares with a placed one, perpendicular to it; lays it at the first fit.
static func _cross(st: Dictionary, e: Dictionary) -> bool:
	var a := str(e.answer)
	for w in st.words:
		var wa := str(w.answer)
		var across: bool = w.dir == "across"
		for i in wa.length():
			for j in a.length():
				if wa[i] != a[j]:
					continue
				var x: int = int(w.x) + (i if across else -j)
				var y: int = int(w.y) + (-j if across else i)
				if _fits(st, a, x, y, not across):
					_put(st, e, x, y, not across)
					return true
	return false

static func _fits(st: Dictionary, a: String, x: int, y: int, across: bool) -> bool:
	var n: int = st.size
	var dx := 1 if across else 0
	var dy := 0 if across else 1
	if x < 0 or y < 0 or x + dx * (a.length() - 1) >= n or y + dy * (a.length() - 1) >= n:
		return false
	if not _empty(st, x - dx, y - dy) or not _empty(st, x + dx * a.length(), y + dy * a.length()):
		return false
	var crossings := 0
	var same: Array = st.h if across else st.v
	for k in a.length():
		var cx := x + dx * k
		var cy := y + dy * k
		var c: String = st.g[cy][cx]
		if c == "":
			if not _empty(st, cx + dy, cy + dx) or not _empty(st, cx - dy, cy - dx):
				return false
		elif c != a[k] or same[cy][cx]:
			return false
		else:
			crossings += 1
	return crossings >= 1 and crossings < a.length()

static func _finish(st: Dictionary) -> Dictionary:
	var words: Array = st.words
	words.sort_custom(func(p, q): return int(p.y) < int(q.y) or (int(p.y) == int(q.y) and int(p.x) < int(q.x)))
	var nums := {}
	var next := 1
	for w in words:
		var k := "%d,%d" % [w.x, w.y]
		if not nums.has(k):
			nums[k] = next
			next += 1
		w["n"] = nums[k]
	return {"size": st.size, "grid": st.g, "words": words}

## Today's puzzle.
static func today() -> Dictionary:
	return build(Calendar.today_key(), bank())

## The cells a word covers: [Vector2i].
static func cells(w: Dictionary) -> Array:
	var out := []
	for k in str(w.answer).length():
		out.append(Vector2i(int(w.x) + (k if w.dir == "across" else 0), int(w.y) + (0 if w.dir == "across" else k)))
	return out

## True when `entry` (rows of typed letters, "" for empty) matches every letter of the puzzle.
static func solved(puzzle: Dictionary, entry: Array) -> bool:
	for y in int(puzzle.size):
		for x in int(puzzle.size):
			if str(puzzle.grid[y][x]) != "" and str(entry[y][x]) != str(puzzle.grid[y][x]):
				return false
	return true

static func done_today(data: GameStateData) -> bool:
	return DailyKey.done_today(data, FLAG)

## Pays the prize for a solved puzzle once per real day. {paid, money, cur}.
static func complete(data: GameStateData, zone_id: String) -> Dictionary:
	if done_today(data):
		return {"paid": false, "money": 0, "cur": Wallet.GBP}
	data.set_flag(FLAG, DailyKey.stamp(data))
	data.set_flag(COUNT_FLAG, solved_count(data) + 1)
	var p := Wallet.earn_here(data, PRIZE, zone_id)
	return {"paid": true, "money": p.amount, "cur": p.cur}

static func solved_count(data: GameStateData) -> int:
	var v: Variant = data.flag(COUNT_FLAG)
	return int(v) if v != null else 0
