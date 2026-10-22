class_name Biology
extends RefCounted
## Biology you can practise (wave 45 session N): the Almanac's Biology page and Dr Keir's prediction challenges.
## Pure logic over GameStateData flags, no autoloads; pages and challenges live in data/biology.json.
##
## Pages open as you meet each idea: "always", "flag:<f>" (Dr Keir's talk and the moor model set bio_* flags) or
## "idea:<id>" (a Stud Book idea), alternatives joined with "|".
##
## Challenges: once Dr Keir has set them (bio_lab_on), every pairing at a farm asks you for the odds of one thing before
## the basket hatches. She scores the reasoning, not the luck: your odds are right if they match the square for what you
## can know about the parents (a plain parent nobody has tested could be carrying, so the honest answer can be a range).
## The hatchling then shows what chance did, and your record says how often "1 in 4" came true. Each challenge pays a
## small one-off grant the first time your odds are right; after all five they carry on for practice, unpaid.
##
## Flags (all default empty):
##   bio_lab_on            true once Dr Keir has set the challenges
##   bio_ch_<id>           true once that challenge has been met
##   bio_open              {child uid: {ch, said, said_min, said_max, min, max}}  predictions waiting on a hatch
##   bio_record            {said text: [times said, times it happened]}
##   bio_preds / bio_right how many predictions were scored, and how many had the right odds
##   bio_<page flag>       set by dialogue and the moor model (bio_dolly, bio_since_dolly, bio_seedbank, ...)

const PATH := "res://data/biology.json"
const OPEN := "bio_open"
const RECORD := "bio_record"
const PROB_OPTIONS := [[0.0, 0.0, "None"], [0.25, 0.25, "1 in 4"], [0.5, 0.5, "1 in 2"], [0.75, 0.75, "3 in 4"], [1.0, 1.0, "Certain"]]
const COAT_OPTIONS := [[0.0, 0.0, "None"], [0.0, 0.25, "None to 1 in 4"], [0.25, 0.25, "1 in 4"], [0.0, 0.5, "None to 1 in 2"],
	[0.5, 0.5, "1 in 2"], [1.0, 1.0, "Certain"]]
const OPEN_MAX := 6

static var _data := {}

static func data() -> Dictionary:
	if _data.is_empty():
		var d = JsonUtil.read(PATH)
		_data = d if d is Dictionary else {}
	return _data

static func pages() -> Array:
	return data().get("pages", [])

static func page(id: String) -> Dictionary:
	for p in pages():
		if str(p.id) == id:
			return p
	return {}

static func challenges() -> Array:
	return data().get("challenges", [])

static func challenge(id: String) -> Dictionary:
	for c in challenges():
		if str(c.id) == id:
			return c
	return {}

# ---------------------------------------------------------------- the page

## The Biology page appears once you have met Dr Keir or started on the Stud Book.
static func visible(d: GameStateData) -> bool:
	return d.flag("breed_met_keir") == true or StudBook.idea_count(d) > 0 or d.flag("bio_lab_on") == true \
		or d.flag("bio_sim_watched") == true

static func page_open(d: GameStateData, p: Dictionary) -> bool:
	for cond in str(p.get("when", "always")).split("|"):
		if cond == "always":
			return true
		if cond.begins_with("flag:") and d.flag(cond.substr(5)) == true:
			return true
		if cond.begins_with("idea:") and StudBook.unlocked(d, cond.substr(5)):
			return true
	return false

static func open_count(d: GameStateData) -> int:
	return pages().filter(func(p): return page_open(d, p)).size()

# ---------------------------------------------------------------- challenges

static func lab_on(d: GameStateData) -> bool:
	return d.flag("bio_lab_on") == true

static func done(d: GameStateData, id: String) -> bool:
	return d.flag("bio_ch_" + id) == true

static func done_count(d: GameStateData) -> int:
	return challenges().filter(func(c): return done(d, str(c.id))).size()

static func _int(d: GameStateData, key: String) -> int:
	var v = d.flag(key)
	return int(v) if v is int or v is float else 0

## The challenge the next pairing asks about: the first not yet met, then (all met) each in turn for practice. {} if off.
static func current(d: GameStateData) -> Dictionary:
	if not lab_on(d) or challenges().is_empty():
		return {}
	for c in challenges():
		if not done(d, str(c.id)):
			return c
	return challenges()[_int(d, "bio_preds") % challenges().size()]

## The true odds of the challenge's outcome as {min, max}, from what the player can know of the parents (min == max
## when nothing is hidden). Frame gives the mid-parent average in both.
static func truth(d: GameStateData, ch: Dictionary, sire: Creature, dam: Creature) -> Dictionary:
	match str(ch.get("goal", "")):
		"mark_medium":
			var p := 0.0
			for r in Genetics.punnett(sire, dam, "mark", false):
				if r.genotype == "Bb":
					p += float(r.p)
			return {"min": p, "max": p}
		"female":
			var mode := _mode(sire, dam)
			var p := 0.5 if mode == "xy" or mode == "zw" else 0.0
			return {"min": p, "max": p}
		"coat":
			var hide := not (_tested(d, sire) and _tested(d, dam))  # as the Punnett preview does
			for r in Genetics.punnett(sire, dam, "coat", hide):
				if r.genotype == "cc":
					return {"min": float(r.min), "max": float(r.max)}
			return {"min": 0.0, "max": 0.0}
		"tortie":
			var p := tortie_odds(sire, dam)
			return {"min": p, "max": p}
		"frame_mean":
			var m := (int(Genetics.showing(sire).frame) + int(Genetics.showing(dam).frame)) / 2.0
			return {"min": m, "max": m}
	return {"min": 0.0, "max": 0.0}

## Has Roslin read this creature's hand? (PunnettView.tested, kept here so this file needs no UI class.)
static func _tested(d: GameStateData, c: Creature) -> bool:
	return c.uid != 0 and d.flag("stud_tested_%d" % c.uid) == true

static func _mode(sire: Creature, dam: Creature) -> String:
	var mode := Genetics.sex_mode(Genetics.kindred_of(sire))
	if mode == "none":
		mode = Genetics.sex_mode(Genetics.kindred_of(dam))
	return mode

## The chance of a tortoiseshell, leaving sports aside: only the two-copy sex can be tortie, and it gets the one-copy
## parent's ginger allele for certain and one of the other parent's two.
static func tortie_odds(sire: Creature, dam: Creature) -> float:
	var mode := _mode(sire, dam)
	if mode != "xy" and mode != "zw":
		return 0.0
	var het: Array = Genetics.genome_of(sire if mode == "xy" else dam).get("ginger", ["o", "o"])
	var homo: Array = Genetics.genome_of(dam if mode == "xy" else sire).get("ginger", ["o", "o"])
	var a := str(het[0]) if not str(het[0]) in Genetics.SEX_CHROMOSOMES else str(het[1])
	var hits := 0
	for x in homo:
		if a != str(x) and not str(x) in Genetics.SEX_CHROMOSOMES:
			hits += 1
	return 0.5 * hits / 2.0

## The answers offered: [{text, min, max}], always including the true one.
static func options(ch: Dictionary, t: Dictionary) -> Array:
	var out := []
	if str(ch.get("goal", "")) == "frame_mean":
		var vals := {}
		var m := float(t.min)
		for v in [m, m - 1.0, m + 1.0, 4.0, 8.0, 0.0]:
			if v >= 0.0 and v <= 8.0 and vals.size() < 4:
				vals[v] = true
		var keys := vals.keys()
		keys.sort()
		for v in keys:
			out.append({"text": frame_words(float(v)), "min": float(v), "max": float(v)})
		return out
	var table: Array = COAT_OPTIONS if str(ch.get("goal", "")) == "coat" else PROB_OPTIONS
	var found := false
	for o in table:
		out.append({"text": str(o[2]), "min": float(o[0]), "max": float(o[1])})
		found = found or _same(float(o[0]), float(t.min)) and _same(float(o[1]), float(t.max))
	if not found:
		out.append({"text": _range_words(t), "min": float(t.min), "max": float(t.max)})
	return out

static func frame_words(v: float) -> String:
	var whole := floori(v)
	var half := v - whole > 0.25
	return "%d%s plus%s" % [whole, " and a half" if half else "", "" if whole == 1 and not half else "es"]

static func _range_words(t: Dictionary) -> String:
	if _same(float(t.min), 1.0):
		return "Certain"
	if _same(float(t.min), float(t.max)):
		return StudBook.odds_words(float(t.min)) if float(t.min) > 0.0 else "None"
	return "%s to %s" % [StudBook.odds_words(float(t.min)) if float(t.min) > 0.0 else "None", StudBook.odds_words(float(t.max))]

static func _same(a: float, b: float) -> bool:
	return absf(a - b) < 0.01

## What the pairing screen asks: {challenge, ask, options, truth}, or {} when there is nothing to ask.
static func prompt(d: GameStateData, sire: Creature, dam: Creature) -> Dictionary:
	var ch := current(d)
	if ch.is_empty():
		return {}
	var t := truth(d, ch, sire, dam)
	return {"challenge": ch, "ask": str(ch.ask), "options": options(ch, t), "truth": t}

static func _open(d: GameStateData) -> Dictionary:
	var v = d.flag(OPEN)
	return v if v is Dictionary else {}

## Records the player's answer for the basket that will hatch as `child_uid`.
static func predict(d: GameStateData, child_uid: int, p: Dictionary, pick: int) -> void:
	if p.is_empty() or pick < 0 or pick >= p.options.size():
		return
	var o: Dictionary = p.options[pick]
	var open := _open(d)
	open[str(child_uid)] = {"ch": str(p.challenge.id), "said": str(o.text), "said_min": float(o.min), "said_max": float(o.max),
		"min": float(p.truth.min), "max": float(p.truth.max)}
	while open.size() > OPEN_MAX:  # a basket abandoned some other way should not linger for ever
		open.erase(open.keys()[0])
	d.set_flag(OPEN, open)

static func waiting(d: GameStateData, child_uid: int) -> bool:
	return _open(d).has(str(child_uid))

## Did the hatchling show what the challenge asked about?
static func happened(goal: String, child: Creature, mean := 0.0) -> bool:
	var sh := Genetics.showing(child)
	match goal:
		"mark_medium":
			return int(sh.mark) == 1
		"female":
			return child.sex == "f"
		"coat":
			return str(sh.variant) != ""
		"tortie":
			return bool(sh.tortie)
		"frame_mean":
			return absf(float(sh.frame) - mean) <= 1.0
	return false

## Scores a hatchling against its prediction, if it had one. {lines: [String], money: int (sterling, paid here),
## right: bool} or {} when nobody predicted it.
static func score(d: GameStateData, child: Creature) -> Dictionary:
	var open := _open(d)
	var key := str(child.uid)
	if not open.has(key):
		return {}
	var e: Dictionary = open[key]
	open.erase(key)
	d.set_flag(OPEN, open)
	var ch := challenge(str(e.ch))
	var goal := str(ch.get("goal", ""))
	var right := _same(float(e.said_min), float(e.min)) and _same(float(e.said_max), float(e.max))
	var hit := happened(goal, child, float(e.min))
	d.set_flag("bio_preds", _int(d, "bio_preds") + 1)
	if right:
		d.set_flag("bio_right", _int(d, "bio_right") + 1)
	var lines := []
	var truth_words := frame_words(float(e.min)) if goal == "frame_mean" else _range_words(e).to_lower()
	if right:
		lines.append("Dr Keir's challenge: you said %s, and that's right." % str(e.said).to_lower())
	else:
		lines.append("Dr Keir's challenge: you said %s. The square says %s." % [str(e.said).to_lower(), truth_words])
	lines.append(_outcome_line(goal, child, hit))
	if goal != "frame_mean":
		var rec := record(d)
		var said := str(e.said)
		var r: Array = rec.get(said, [0, 0])
		rec[said] = [int(r[0]) + 1, int(r[1]) + (1 if hit else 0)]
		d.set_flag(RECORD, rec)
	var money := 0
	if right and not done(d, str(e.ch)) and not ch.is_empty():
		d.set_flag("bio_ch_" + str(e.ch), true)
		money = int(ch.get("reward", 0))
		Wallet.earn(d, money, Wallet.GBP)
		lines.append("That's her %s challenge met. The lab's outreach fund sends £%d." % [str(ch.title), money])
	return {"lines": lines, "money": money, "right": right, "hit": hit}

static func _outcome_line(goal: String, child: Creature, hit: bool) -> String:
	var sh := Genetics.showing(child)
	match goal:
		"mark_medium":
			return "It hatched with %s markings." % ["faint", "medium", "bold"][clampi(int(sh.mark), 0, 2)]
		"female":
			return "It's a daughter." if hit else "It's a son."
		"coat":
			return "It hatched in a coloured coat." if hit else "It hatched plain. Odds are about many hatchings, not this one."
		"tortie":
			return "It's tortoiseshell!" if hit else "Not tortoiseshell this time."
		"frame_mean":
			return "It came out with %d Frame plus%s. Most young land near the middle of their parents." % [int(sh.frame), "" if int(sh.frame) == 1 else "es"]
	return ""

static func record(d: GameStateData) -> Dictionary:
	var v = d.flag(RECORD)
	return v if v is Dictionary else {}

## 'Said "1 in 4" 5 times; it came true twice.' per answer given, then the right-odds count.
static func record_lines(d: GameStateData) -> Array:
	var out := []
	var rec := record(d)
	var order := PROB_OPTIONS.map(func(o): return str(o[2])) + COAT_OPTIONS.map(func(o): return str(o[2]))
	var keys := rec.keys()
	keys.sort_custom(func(a, b): return order.find(a) < order.find(b))
	for k in keys:
		var r: Array = rec[k]
		var came := "it never came true" if int(r[1]) == 0 else "it came true %s" % _times(int(r[1]))
		out.append("Said \"%s\" %s; %s." % [str(k).to_lower(), _times(int(r[0])), came])
	var n := _int(d, "bio_preds")
	if n > 0:
		out.append("Right odds %d time%s out of %d." % [_int(d, "bio_right"), "" if _int(d, "bio_right") == 1 else "s", n])
	return out

static func _times(n: int) -> String:
	match n:
		0:
			return "never"
		1:
			return "once"
		2:
			return "twice"
	return "%d times" % n
