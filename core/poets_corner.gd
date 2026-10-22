class_name PoetsCorner
extends RefCounted
## Poets' Corner (4.5): the Gazetteer's tally of plaques on writers, poets, musicians and artists. A zone sign with
## "plaque" and "theme": "arts" counts. Reading one goes through the Gazetteer as usual (the flag plaque_<id>); this
## only adds a second count, grouped by nation, with two milestones of its own paid once each (flags poets_corner_10
## and poets_corner_all), so old saves need nothing and catch up on the next arts plaque they read. Pure logic.

const THEME := "arts"
const MILESTONES := [
	{"n": 10, "flag": "poets_corner_10", "title": "Bookworm", "money": 0, "items": {"commonplace_book": 1}},
	{"n": -1, "flag": "poets_corner_all", "title": "Laureate of the Isles", "money": 2000, "items": {"laurel_wreath": 1}},
]

## The arts plaques, from the Gazetteer's list (or `list`, for tests).
static func all(list: Array = []) -> Array:
	return (list if not list.is_empty() else Gazetteer.all()).filter(func(p): return str(p.get("theme", "")) == THEME)

static func is_arts(p: Dictionary) -> bool:
	return str(p.get("theme", "")) == THEME

static func count(d: GameStateData, list: Array = []) -> int:
	return all(list).filter(func(p): return Gazetteer.is_read(d, str(p.id))).size()

static func total(list: Array = []) -> int:
	return all(list).size()

static func _target(m: Dictionary, n_all: int) -> int:
	return n_all if int(m.n) < 0 else int(m.n)

## After an arts plaque is read: pays every milestone passed and not yet paid. Returns the milestones paid (each
## a MILESTONES entry). Any other plaque id returns [] and changes nothing.
static func record(d: GameStateData, id: String, list: Array = [], milestones: Array = []) -> Array:
	var arts := all(list)
	if not arts.any(func(p): return str(p.id) == id):
		return []
	var ms := milestones if not milestones.is_empty() else MILESTONES
	var n := count(d, list)
	var paid := []
	for m in ms:
		if d.flag(str(m.flag)) != true and n >= _target(m, arts.size()) and arts.size() > 0:
			d.set_flag(str(m.flag), true)
			d.money += int(m.get("money", 0))
			var bag := Bag.new(d.bag)
			for it in m.get("items", {}):
				bag.add(str(it), int(m.items[it]))
			paid.append(m)
	return paid

## The best title earned ("" before the first).
static func title(d: GameStateData, milestones: Array = []) -> String:
	var t := ""
	for m in (milestones if not milestones.is_empty() else MILESTONES):
		if d.flag(str(m.flag)) == true:
			t = str(m.title)
	return t

## The next milestone not yet paid (with "target" filled in), or {}.
static func next_milestone(d: GameStateData, list: Array = [], milestones: Array = []) -> Dictionary:
	for m in (milestones if not milestones.is_empty() else MILESTONES):
		if d.flag(str(m.flag)) != true:
			var c: Dictionary = m.duplicate()
			c["target"] = _target(m, total(list))
			return c
	return {}

## "12 of 125", or "None yet".
static func stats_line(d: GameStateData, list: Array = []) -> String:
	var n := count(d, list)
	return "None yet" if n == 0 else "%d of %d" % [n, total(list)]

## [{nation, name, read, total}] in the Gazetteer's nation order, nations with no arts plaques left out.
static func by_nation(d: GameStateData, list: Array = []) -> Array:
	var by := {}
	for p in all(list):
		var n := str(p.nation)
		if not by.has(n):
			by[n] = {"nation": n, "name": Standing.name_of(n), "read": 0, "total": 0}
		by[n].total += 1
		by[n].read += 1 if Gazetteer.is_read(d, str(p.id)) else 0
	var order := Gazetteer.NATION_ORDER.duplicate()
	for n in by:
		if n not in order:
			order.append(n)
	var out := []
	for n in order:
		if by.has(n):
			out.append(by[n])
	return out

## The Almanac's ledger rows [label, value]: a line per nation, then your title and what the next milestone brings.
static func ledger(d: GameStateData, items: ItemDB = null, list: Array = []) -> Array:
	var out := []
	for e in by_nation(d, list):
		out.append([str(e.name), "%d of %d read" % [int(e.read), int(e.total)]])
	if out.is_empty():
		out.append(["No plaques on the arts yet", "Poets, painters and players stand where they belong"])
	var t := title(d)
	if t != "":
		out.append(["Your title", t])
	var nm := next_milestone(d, list)
	if nm.is_empty():
		out.append(["", "Every plaque on the arts read. Take a bow."])
	else:
		var gift := Gazetteer.reward_text(nm, items if items != null else ItemDB.load_default())  # the gift by its name
		out.append(["", "Next: %d read makes you a %s%s." % [int(nm.target), str(nm.title), (", with " + gift) if gift != "" else ""]])
	return out
