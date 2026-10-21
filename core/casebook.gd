class_name Casebook
extends RefCounted
## The Casebook (data/cases/<id>.json): a mystery per nation, built on flags like a quest but with evidence and red
## herrings. A case is open once its start_flag is set. Each piece of evidence is held in the flag
## case_<case>_ev_<evidence> (set by an examine spot's "evidence" field or the story command {"do": "evidence"}), each
## step is a plain flag the story sets as you go, and the end is an accusation (the story command {"do": "casebook"}):
## a wrong suspect costs standing and is crossed off (case_<case>_no_<suspect>), the right one closes the case
## (done_flag) and pays the reward once, a little less for every wrong guess. Nothing here can be repeated for money:
## the reward is paid on the done_flag. Old saves have no case flags, so every case is simply unopened.
## Pure logic, no autoloads.

const DIR := "res://data/cases"
const WRONG_STANDING := 3
const WRONG_CUT := 0.25    # each wrong guess takes this share off the reward
const MIN_SHARE := 0.25

static var _cache: Array = []

static func all() -> Array:
	if _cache.is_empty():
		for p in JsonUtil.list_json(DIR):
			var c = JsonUtil.read(p)
			if c is Dictionary and str(c.get("id", "")) != "":
				_cache.append(c)
	return _cache

static func get_case(id: String) -> Dictionary:
	for c in all():
		if str(c.id) == id:
			return c
	return {}

static func ev_flag(case_id: String, ev_id: String) -> String:
	return "case_%s_ev_%s" % [case_id, ev_id]

static func no_flag(case_id: String, suspect_id: String) -> String:
	return "case_%s_no_%s" % [case_id, suspect_id]

static func _on(data: GameStateData, key: String) -> bool:
	return data.flag(key) == true or (data.flag(key) is int and int(data.flag(key)) != 0)

static func started(data: GameStateData, c: Dictionary) -> bool:
	return _on(data, str(c.start_flag)) or solved(data, c)

static func solved(data: GameStateData, c: Dictionary) -> bool:
	return _on(data, str(c.done_flag))

## The cases to show in the tab: opened ones only.
static func open_cases(data: GameStateData) -> Array:
	return all().filter(func(c): return started(data, c))

static func visible(data: GameStateData) -> bool:
	return not open_cases(data).is_empty()

static func has_evidence(data: GameStateData, c: Dictionary, ev_id: String) -> bool:
	return _on(data, ev_flag(str(c.id), ev_id))

## The evidence held so far, in the case's own order.
static func held(data: GameStateData, c: Dictionary) -> Array:
	return c.evidence.filter(func(e): return has_evidence(data, c, str(e.id)))

## Records a piece of evidence (whichever case lists it). Returns the evidence dictionaries newly gained, [] if it was
## already held or no case knows it.
static func collect(data: GameStateData, ev_id: String) -> Array:
	var out := []
	for c in all():
		for e in c.evidence:
			if str(e.id) == ev_id and not has_evidence(data, c, ev_id):
				data.set_flag(ev_flag(str(c.id), ev_id), true)
				out.append(e)
	return out

static func is_evidence(ev_id: String) -> bool:
	for c in all():
		for e in c.evidence:
			if str(e.id) == ev_id:
				return true
	return false

static func steps_done(data: GameStateData, c: Dictionary) -> int:
	return c.steps.filter(func(s): return _on(data, str(s.flag))).size()

## The first step not yet done, {} when they all are.
static func next_step(data: GameStateData, c: Dictionary) -> Dictionary:
	for s in c.steps:
		if not _on(data, str(s.flag)):
			return s
	return {}

## Every lead followed and no verdict yet: time to name someone.
static func ready(data: GameStateData, c: Dictionary) -> bool:
	return started(data, c) and not solved(data, c) and next_step(data, c).is_empty()

## Suspects still in the frame.
static func open_suspects(data: GameStateData, c: Dictionary) -> Array:
	return c.suspects.filter(func(s): return not _on(data, no_flag(str(c.id), str(s.id))))

static func wrong_count(data: GameStateData, c: Dictionary) -> int:
	return c.suspects.size() - open_suspects(data, c).size()

## The share of the reward still on the table.
static func reward_share(data: GameStateData, c: Dictionary) -> float:
	return maxf(MIN_SHARE, 1.0 - WRONG_CUT * wrong_count(data, c))

## Names a suspect. {ok: false} when the case isn't ready or the suspect isn't in the frame; otherwise {ok: true,
## correct, suspect, money, line} where line is the suspect's own reaction. Wrong: standing lost, suspect crossed off.
static func accuse(data: GameStateData, case_id: String, suspect_id: String) -> Dictionary:
	var c := get_case(case_id)
	if c.is_empty() or not ready(data, c):
		return {"ok": false}
	var sus := {}
	for s in open_suspects(data, c):
		if str(s.id) == suspect_id:
			sus = s
	if sus.is_empty():
		return {"ok": false}
	if suspect_id != str(c.culprit):
		data.set_flag(no_flag(case_id, suspect_id), true)
		_lose_standing(data, str(c.nation), WRONG_STANDING)
		return {"ok": true, "correct": false, "suspect": sus, "money": 0, "line": str(sus.get("wrong", ""))}
	var reward: Dictionary = c.get("reward", {})
	var money := int(round(int(reward.get("money", 0)) * reward_share(data, c)))
	data.set_flag(str(c.done_flag), true)
	Purse.pay(data, money)
	Standing.add(data, str(c.nation), int(reward.get("standing", 0)))
	for id in reward.get("items", {}):
		Bag.new(data.bag).add(str(id), int(reward.items[id]))
	return {"ok": true, "correct": true, "suspect": sus, "money": money, "line": str(sus.get("right", ""))}

static func _lose_standing(data: GameStateData, nation: String, n: int) -> void:
	if Standing.is_nation(nation):
		data.set_flag(Standing.FLAG_PREFIX + nation, maxi(0, Standing.points(data, nation) - n))

## Problems in the case files, for the validator: [String]. zone_exists is a Callable(zone_id) -> bool.
static func validate(zone_exists: Callable) -> Array:
	var errors := []
	var ids := {}
	for c in all():
		var id := str(c.id)
		if ids.has(id):
			errors.append("case %s: duplicate id" % id)
		ids[id] = true
		for k in ["title", "nation", "start_flag", "done_flag", "culprit"]:
			if str(c.get(k, "")) == "":
				errors.append("case %s: no %s" % [id, k])
		if not Standing.is_nation(str(c.get("nation", ""))):
			errors.append("case %s: unknown nation" % id)
		var evs := {}
		for e in c.get("evidence", []):
			evs[str(e.id)] = true
			if str(e.get("name", "")) == "" or str(e.get("text", "")) == "":
				errors.append("case %s: evidence %s needs a name and text" % [id, e.id])
		if evs.size() < 4 or not c.evidence.any(func(e): return e.get("red_herring", false)):
			errors.append("case %s: needs 4+ evidence and a red herring" % id)
		var sus: Array = c.get("suspects", []).map(func(s): return str(s.id))
		if sus.size() < 3 or str(c.get("culprit", "")) not in sus:
			errors.append("case %s: 3+ suspects, the culprit among them" % id)
		for s in c.get("suspects", []):
			if not zone_exists.call(str(s.zone)):
				errors.append("case %s: suspect %s in unknown zone" % [id, s.id])
		var steps: Array = c.get("steps", [])
		if steps.size() < 6:
			errors.append("case %s: needs 6+ steps" % id)
		for s in steps:
			if not zone_exists.call(str(s.zone)):
				errors.append("case %s: step %s in unknown zone '%s'" % [id, s.flag, s.zone])
			if not str(s.flag).begins_with("case_%s_" % id):
				errors.append("case %s: step flag %s must start case_%s_" % [id, s.flag, id])
	return errors
