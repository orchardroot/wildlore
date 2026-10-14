class_name DataValidator
extends RefCounted
## Cross-checks all game data. Returns human-readable errors; an empty array means valid.

static func validate(chart: TypeChart, dex: Dex, moves: MoveDB) -> Array:
	var errors := chart.validate()
	for id in moves.duplicates:
		errors.append("move id '%s' defined more than once" % id)
	for id in dex.duplicates:
		errors.append("species id '%s' defined more than once" % id)
	for id in moves.ids():
		errors.append_array(_check_move(moves.get_move(id), chart))
	for id in dex.ids():
		errors.append_array(_check_species(dex.get_species(id), chart, dex, moves))
	return errors

static func _check_move(m: Dictionary, chart: TypeChart) -> Array:
	var e := []
	var id: String = m.get("id", "?")
	if str(m.get("name", "")) == "":
		e.append("move %s: missing name" % id)
	if m.get("type") not in chart.types:
		e.append("move %s: unknown type '%s'" % [id, m.get("type")])
	if m.get("category") not in Rules.CATEGORIES:
		e.append("move %s: unknown category '%s'" % [id, m.get("category")])
	if m.get("category") != "status" and int(m.power) <= 0:
		e.append("move %s: damaging move needs power > 0" % id)
	if int(m.accuracy) < 1 or int(m.accuracy) > 100:
		e.append("move %s: accuracy must be 1..100" % id)
	if int(m.pp) < 1 or int(m.pp) > 64:
		e.append("move %s: pp must be 1..64" % id)
	var fx: Dictionary = m.get("effect", {})
	if fx.get("id") not in Rules.EFFECTS:
		e.append("move %s: unknown effect '%s'" % [id, fx.get("id")])
	elif fx.id == "stat":
		if fx.get("stat") not in Rules.STAGE_STATS:
			e.append("move %s: unknown stat '%s'" % [id, fx.get("stat")])
		if int(fx.get("stages", 0)) == 0:
			e.append("move %s: stat effect needs non-zero stages" % id)
	elif fx.id == "status" and fx.get("status") not in Rules.STATUSES:
		e.append("move %s: unknown status '%s'" % [id, fx.get("status")])
	if fx.get("target", "foe") not in ["self", "foe"]:
		e.append("move %s: effect target must be self or foe" % id)
	return e

static func _check_species(sp: Dictionary, chart: TypeChart, dex: Dex, moves: MoveDB) -> Array:
	var e := []
	var id: String = sp.get("id", "?")
	if str(sp.get("name", "")) == "":
		e.append("species %s: missing name" % id)
	var types: Array = sp.get("types", [])
	if types.size() < 1 or types.size() > 2:
		e.append("species %s: needs 1 or 2 types" % id)
	for t in types:
		if t not in chart.types:
			e.append("species %s: unknown type '%s'" % [id, t])
	if types.size() == 2 and types[0] == types[1]:
		e.append("species %s: repeats a type" % id)
	for s in Rules.STATS:
		var v: int = sp.base[s]
		if v < 1 or v > 255:
			e.append("species %s: base %s must be 1..255" % [id, s])
	if sp.get("growth") not in Rules.GROWTH_RATES:
		e.append("species %s: unknown growth '%s'" % [id, sp.get("growth")])
	if sp.catch_rate < 1 or sp.catch_rate > 255:
		e.append("species %s: catch_rate must be 1..255" % id)
	if sp.base_xp < 1:
		e.append("species %s: base_xp must be positive" % id)
	if sp.learnset.is_empty():
		e.append("species %s: empty learnset" % id)
	for entry in sp.learnset:
		if entry[0] < 1 or entry[0] > Rules.MAX_LEVEL:
			e.append("species %s: learnset level %d out of range" % [id, entry[0]])
		if not moves.has(entry[1]):
			e.append("species %s: learnset move '%s' does not exist" % [id, entry[1]])
	var evo = sp.evolves
	if evo != null:
		var target: String = evo.get("to", "")
		if not dex.has(target):
			e.append("species %s: evolves into unknown species '%s'" % [id, target])
		elif target == id:
			e.append("species %s: evolves into itself" % id)
		if not evo.has("level"):
			e.append("species %s: evolution needs a level (item and weather rules arrive in plan 2)" % id)
	var d: Dictionary = sp.get("dex", {})
	if str(d.get("text", "")) == "" or str(d.get("fact", "")) == "":
		e.append("species %s: needs Creaturepedia text and a real-world fact" % id)
	return e
