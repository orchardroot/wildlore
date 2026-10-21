class_name Walling
extends RefCounted
## Drystone walling: a gap in a wall to fill with the stones the waller has laid out, no mortar, just fit and
## gravity. A stone is a rectangle of cells (it may be turned on its side) and must sit on the ground or on other
## stones, never in mid-air. Puzzles are cut from a finished wall, so there is always a way to do it. Mending a wall
## on a rewilding site (world/rewild.gd) earns the warden's thanks. Pure rules; ui/walling_screen.gd plays it and
## story/walling_run.gd (the `wall` command) starts it.

const FLAG_DONE := "wall_done_"      # wall_done_<site or gap> = the DailyKey stamp of today's paid wall
const FLAG_FIRST := "wall_first"     # the first wall ever mended
const SIZES := {"easy": Vector2i(6, 3), "normal": Vector2i(8, 4), "hard": Vector2i(10, 5)}

## A puzzle cut into stones: {w, h, stones: [{x, y, w, h}]} where x,y is the stone's place in the finished wall
## (y = 0 is the top row, so the ground is at y = h). Cut by splitting rectangles, so the pieces tile the gap.
static func generate(level: String, rng: Rng) -> Dictionary:
	var size: Vector2i = SIZES.get(level, SIZES.normal)
	var pieces: Array = [Rect2i(0, 0, size.x, size.y)]
	var want := size.x * size.y / 3
	var tries := 0
	while pieces.size() < want and tries < 400:
		tries += 1
		var i := rng.roll_int(0, pieces.size() - 1)
		var r: Rect2i = pieces[i]
		var can_v := r.size.x >= 2
		var can_h := r.size.y >= 2 and r.size.x * r.size.y >= 4
		if not can_v and not can_h:
			continue
		var vertical := can_v and (not can_h or rng.roll() < 0.65)
		pieces.remove_at(i)
		if vertical:
			var cut := rng.roll_int(1, r.size.x - 1)
			pieces.append(Rect2i(r.position, Vector2i(cut, r.size.y)))
			pieces.append(Rect2i(r.position + Vector2i(cut, 0), Vector2i(r.size.x - cut, r.size.y)))
		else:
			var cut := rng.roll_int(1, r.size.y - 1)
			pieces.append(Rect2i(r.position, Vector2i(r.size.x, cut)))
			pieces.append(Rect2i(r.position + Vector2i(0, cut), Vector2i(r.size.x, r.size.y - cut)))
	var stones: Array = []
	for r in pieces:
		stones.append({"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y})
	stones.sort_custom(func(a, b): return a.w * a.h > b.w * b.h)
	return {"w": size.x, "h": size.y, "stones": stones}

## An empty grid of `h` rows by `w` columns: 0 is open, otherwise the id (1-based) of the stone filling it.
static func empty_grid(w: int, h: int) -> Array:
	var g: Array = []
	for y in h:
		var row: Array = []
		row.resize(w)
		row.fill(0)
		g.append(row)
	return g

## Can a stone `sw` wide and `sh` tall go with its top-left at (x, y)? It must be inside the gap, on open cells, and
## every cell of its bottom edge must rest on the ground or on a stone.
static func can_place(grid: Array, x: int, y: int, sw: int, sh: int) -> bool:
	var h := grid.size()
	var w: int = grid[0].size()
	if x < 0 or y < 0 or x + sw > w or y + sh > h:
		return false
	for yy in range(y, y + sh):
		for xx in range(x, x + sw):
			if int(grid[yy][xx]) != 0:
				return false
	var below := y + sh
	if below < h:
		for xx in range(x, x + sw):
			if int(grid[below][xx]) == 0:
				return false
	return true

static func place(grid: Array, id: int, x: int, y: int, sw: int, sh: int) -> void:
	for yy in range(y, y + sh):
		for xx in range(x, x + sw):
			grid[yy][xx] = id

## Takes stone `id` back out of the wall.
static func remove(grid: Array, id: int) -> void:
	for row in grid:
		for xx in row.size():
			if int(row[xx]) == id:
				row[xx] = 0

static func solved(grid: Array) -> bool:
	for row in grid:
		for v in row:
			if int(v) == 0:
				return false
	return true

static func open_cells(grid: Array) -> int:
	var n := 0
	for row in grid:
		for v in row:
			if int(v) == 0:
				n += 1
	return n

## A hint for the easier setting: where the stone `s` (a puzzle stone) belongs in the finished wall.
static func hint_for(s: Dictionary) -> Vector2i:
	return Vector2i(int(s.x), int(s.y))

## Is the wall in `grid` stable in the way wallers mean it: no long unbroken vertical seam? (Wallers say "one over
## two, two over one", so that joints in one course are covered by stones in the next.) Returns the longest seam
## in rows; a built wall of one huge stone is 0 seams, a wall of single stacks is the full height.
static func longest_seam(grid: Array) -> int:
	var h := grid.size()
	var w: int = grid[0].size()
	var best := 0
	for x in range(1, w):
		var run := 0
		for y in h:
			if int(grid[y][x]) != int(grid[y][x - 1]):
				run += 1
				best = maxi(best, run)
			else:
				run = 0
	return best

## The reward for a mended wall, in whole pounds: bigger gaps pay a little more, once a real day per `key`.
static func fee(level: String) -> int:
	return {"easy": 2, "normal": 4, "hard": 7}.get(level, 3)

static func paid_today(data: GameStateData, key: String) -> bool:
	return DailyKey.done_today(data, FLAG_DONE + key)

## Books a mended wall: the counter, the first-wall flag, and the day's pay stamp. `site` (a rewilding site id, or
## "") adds the warden's thanks when that land is already on the mend. Returns {first, fee, thanks}.
static func finish(data: GameStateData, key: String, level: String, site: String) -> Dictionary:
	TrainerStats.add(data, "walls_built")
	var out := {"first": false, "fee": 0, "thanks": ""}
	if not data.flags.has(FLAG_FIRST):
		data.set_flag(FLAG_FIRST, 1)
		out.first = true
	if not paid_today(data, key):
		data.set_flag(FLAG_DONE + key, DailyKey.stamp(data))
		out.fee = fee(level)
	if site != "" and not Rewild.site(site).is_empty() and Rewild.stage(data, site) >= 1:
		var s := Rewild.site(site)
		out.thanks = Standing.add(data, str(s.nation), 1)
	return out
