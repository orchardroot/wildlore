class_name Breeding
extends RefCounted
## Good Stock, the loop (docs/design/2026-10-21-breeding.md section 4). Two Fond creatures are paired at a farm; the
## cross is worked out then (Genetics.cross) and parked in a BASKET (eggs) or bundle (young) that comes to you once
## you have walked it off: the kindred's own step range, doubled out of season with a heat-lamp fee. Hatching puts a
## level 1 creature (5 for a hybrid) in the party or the Ark. Pure logic, no autoload names. Everything is a flag, so
## a save without any of it means no baskets and no history, which is a perfectly good save.
##
## Flags (the namespace the UI and the Stud Book read):
##   breed_basket_<0..2>   {sire_uid, dam_uid, sire_name, dam_name, kind, kindred, zone, species, hybrid, level,
##                          genome, sex, ivs, temper, pedigree, uid (the hatchling's own), heirlooms [move ids],
##                          sport, sport_locus, kinship, parents {sire, dam: {locus: hand}}, steps_due, started_day}
##   breed_paired_<zone>_<day>   true: one pairing per farm per in-game day
##   breed_logs            how many hatchings have ever been logged; breed_log_<n> (n from 1, newest last) is
##                          {day, kind, species, child_uid, sire_uid, dam_uid, sire_species, dam_species, sport,
##                          sport_locus, sire, dam, child: {locus: hand_key}} and only the last LOG_KEEP are kept
##   breed_goal_<id>       true once that conservation goal has been paid (soay, kerry, wildcat)
##   breed_uid             the counter behind Creature.uid
## Goals and their rewards are in data/breeding.json.

const PATH := "res://data/breeding.json"
const MAX_BASKETS := 3
const BASKET := "breed_basket_"
const PAIRED := "breed_paired_"
const LOG := "breed_log_"
const LOG_COUNT := "breed_logs"
const GOAL := "breed_goal_"
const UID_COUNTER := "breed_uid"
const FOND_HEARTS := 2          # Bond tier two
const LAMP_FEE := 120           # sterling, out of season
const OUT_OF_SEASON := 2        # steps multiplier
const HATCH_LEVEL := 1
const HYBRID_LEVEL := 5         # hybrids are big babies
const HATCH_FRIENDSHIP := 120   # raised, not caught
const MAX_HEIRLOOMS := 2
const LOG_KEEP := 200

static var _goals: Array = []

# ---------------------------------------------------------------- data

static func goals() -> Array:
	if _goals.is_empty():
		var d = JsonUtil.read(PATH)
		_goals = d.get("goals", []) if d is Dictionary else []
	return _goals

static func goal(id: String) -> Dictionary:
	for g in goals():
		if str(g.id) == id:
			return g
	return {}

## Validator: every goal names a real line that breeds, and a reward that exists.
static func check(dex: Dex) -> Array:
	var errors := []
	if goals().is_empty():
		return ["breeding.json: missing or unreadable"]
	var seen := {}
	for g in goals():
		var id := str(g.get("id", ""))
		if id == "" or seen.has(id):
			errors.append("breeding.json: goal id '%s' missing or duplicated" % id)
		seen[id] = true
		var line := str(g.get("line", ""))
		if not dex.has(line):
			errors.append("breeding.json: goal %s: line '%s' is not a creature" % [id, line])
		elif not Genetics.breeds(str(Genetics.genes().get("lines", {}).get(line, ""))):
			errors.append("breeding.json: goal %s: line '%s' does not breed" % [id, line])
		if str(g.get("rule", "")) not in ["spread", "pairings", "pure"]:
			errors.append("breeding.json: goal %s: unknown rule" % id)
		if int(g.get("need", 0)) < 1:
			errors.append("breeding.json: goal %s: need must be at least 1" % id)
		if str(g.get("title", "")).contains("—"):
			errors.append("breeding.json: goal %s: em-dash in the title" % id)
	return errors

# ---------------------------------------------------------------- baskets

static func _count(data: GameStateData, key: String) -> int:
	var v: Variant = data.flag(key)
	return int(v) if v is int or v is float else 0

static func _basket_key(slot: int) -> String:
	return BASKET + str(slot)

## Occupied baskets as copies, each with its `slot`.
static func baskets(data: GameStateData) -> Array:
	var out := []
	for i in MAX_BASKETS:
		var b: Variant = data.flag(_basket_key(i))
		if b is Dictionary and not b.is_empty():
			var c: Dictionary = b.duplicate(true)
			c["slot"] = i
			out.append(c)
	return out

static func free_slot(data: GameStateData) -> int:
	for i in MAX_BASKETS:
		var b: Variant = data.flag(_basket_key(i))
		if not (b is Dictionary) or b.is_empty():
			return i
	return -1

static func paired_key(zone: String, day: int) -> String:
	return "%s%s_%d" % [PAIRED, zone, day]

static func paired_today(data: GameStateData, zone: String) -> bool:
	return data.flag(paired_key(zone, data.day_count)) == true

static func steps_now(data: GameStateData) -> int:
	return TrainerStats.get_count(data, "steps")

static func steps_left(data: GameStateData, slot: int) -> int:
	var b: Variant = data.flag(_basket_key(slot))
	if not (b is Dictionary) or b.is_empty():
		return 0
	return maxi(0, int(b.get("steps_due", 0)) - steps_now(data))

## Slots whose baskets have been walked off.
static func ready(data: GameStateData) -> Array:
	var out := []
	for b in baskets(data):
		if steps_now(data) >= int(b.get("steps_due", 0)):
			out.append(int(b.slot))
	return out

# ---------------------------------------------------------------- pairing

static func fond(c: Creature) -> bool:
	return Bond.hearts(c.friendship) >= FOND_HEARTS

## A creature without an identity gets one (kinship and the Stud Book need it): derived from the save's seed and a
## counter flag, so two creatures made in the same breath still differ. One it already has is kept.
static func ensure_uid(data: GameStateData, c: Creature) -> void:
	if c.uid != 0:
		return
	c.uid = _next_uid(data)

static func _next_uid(data: GameStateData) -> int:
	var n := _count(data, UID_COUNTER) + 1
	data.set_flag(UID_COUNTER, n)
	var v := ("%d|%d" % [data.rng_seed, n]).hash() & 0x3fffffff
	return v if v != 0 else n

## Which lines do these two share, parents' own lines and a hybrid's two sides: the first one, or "".
static func shared_line(sire: Creature, dam: Creature) -> String:
	var dl: Array = Genetics._lines_of(dam)
	for l in Genetics._lines_of(sire):
		if l in dl:
			return str(l)
	return ""

## The species a pairing hatches: the shared line's first stage, or the listed hybrid. {} if there is none to hatch.
static func offspring_species(sire: Creature, dam: Creature, kind: String, dex: Dex) -> Dictionary:
	if kind == "same_line":
		var l := shared_line(sire, dam)
		return dex.get_species(l) if dex.has(l) else {}
	if kind == "hybrid":
		var sl := Genetics.line_of(sire)
		var dl := Genetics.line_of(dam)
		for id in Genetics.hybrids():
			var h: Dictionary = Genetics.hybrids()[id]
			if sl in h.get("sire_lines", []) and dl in h.get("dam_lines", []) and dex.has(str(id)):
				return dex.get_species(str(id))
	return {}

## May Dot take this pair? {ok, why, kind}: `why` is her reason in her own words.
static func check_pair(data: GameStateData, sire: Creature, dam: Creature, zone: String, dex: Dex) -> Dictionary:
	if sire == null or dam == null:
		return {"ok": false, "why": "I need two, love. Bring me two.", "kind": ""}
	if sire.is_fainted() or dam.is_fainted():
		return {"ok": false, "why": "One of them's not fit. Patch them up first, then we'll talk.", "kind": ""}
	var can := Genetics.can_pair(sire, dam, dex)
	if not can.ok:
		return can
	for p in [sire, dam]:
		if not fond(p):
			return {"ok": false, "why": "%s doesn't know you well enough yet. They have to like you first, and there's no hurrying that." % p.display_name(), "kind": ""}
	if paired_today(data, zone):
		return {"ok": false, "why": "One pairing a day, my yard, my rules. Come back tomorrow.", "kind": ""}
	if free_slot(data) < 0:
		return {"ok": false, "why": "You've three baskets on the go already. Walk some off first.", "kind": ""}
	if offspring_species(sire, dam, str(can.kind), dex).is_empty():
		return {"ok": false, "why": "I've no stock book for that cross yet. Ask me again one day.", "kind": ""}
	return can

static func in_season(kindred: String, season: String) -> bool:
	var want := str(Genetics.genes().get("kindreds", {}).get(kindred, {}).get("season", "any"))
	return want == "any" or want == season

## Steps this pair will take to walk off: the kindred's range, doubled out of season.
static func steps_for(kindred: String, season: String, rng: Rng) -> Dictionary:
	var range_: Array = Genetics.genes().get("kindreds", {}).get(kindred, {}).get("steps", [2000, 3500])
	var n := rng.roll_int(int(range_[0]), int(range_[1]))
	var late := not in_season(kindred, season)
	return {"steps": n * OUT_OF_SEASON if late else n, "late": late}

## Up to two moves either parent knows that the young can also learn and would not know at level 1.
static func heirlooms(sire: Creature, dam: Creature, sp: Dictionary, moves: MoveDB, level: int) -> Array:
	var known := Creature.default_moves(sp, level)
	var learnable := []
	for e in sp.get("learnset", []):
		learnable.append(str(e[1]))
	var out := []
	for p in [sire, dam]:
		for m in p.moves:
			var id := str(m.get("id", ""))
			if id in learnable and id not in known and id not in out and moves.has(id):
				out.append(id)
	return out.slice(0, MAX_HEIRLOOMS)

static func _hands(c: Creature) -> Dictionary:
	var g := Genetics.genome_of(c)
	var out := {}
	for l in Genetics.LOCI:
		if g.has(l):
			out[l] = Genetics.hand_key(l, g[l])
	return out

## Pairs them: the cross is made and parked in a basket. {ok, why, slot, steps, fee, late, kind}. Charges the lamp
## fee out of season. Callers have usually run check_pair for the screen's sake; this runs it again.
static func start(data: GameStateData, sire: Creature, dam: Creature, zone: String, dex: Dex, moves: MoveDB, rng: Rng, season: String) -> Dictionary:
	var can := check_pair(data, sire, dam, zone, dex)
	if not can.ok:
		return {"ok": false, "why": can.why}
	var kindred := Genetics.kindred_of(dam)
	var walk := steps_for(kindred, season, rng)
	var fee := LAMP_FEE if walk.late else 0
	if fee > 0 and not Wallet.can_afford(data, fee, Wallet.GBP):
		return {"ok": false, "why": "It's out of season, so the heat lamp's £%d and you haven't got it on you." % fee}
	var sp := offspring_species(sire, dam, str(can.kind), dex)
	var level := HYBRID_LEVEL if str(can.kind) == "hybrid" else HATCH_LEVEL
	ensure_uid(data, sire)
	ensure_uid(data, dam)
	var kit := Genetics.cross(sire, dam, rng)
	var slot := free_slot(data)
	var basket := {
		"sire_uid": sire.uid, "dam_uid": dam.uid, "sire_name": sire.display_name(), "dam_name": dam.display_name(),
		"sire_species": str(sire.species.id), "dam_species": str(dam.species.id),
		"kind": str(can.kind), "kindred": kindred, "zone": zone, "species": str(sp.id),
		"hybrid": str(sp.id) if str(can.kind) == "hybrid" else "", "level": level,
		"genome": kit.genome, "sex": kit.sex, "ivs": kit.ivs, "temper": kit.temper, "pedigree": kit.pedigree,
		"uid": _next_uid(data), "heirlooms": heirlooms(sire, dam, sp, moves, level),
		"dam_form": dam.form if str(can.kind) != "hybrid" else "",
		"sport": kit.sport, "sport_locus": kit.sport_locus, "kinship": kit.kinship,
		"parents": {"sire": _hands(sire), "dam": _hands(dam)},
		"steps_due": steps_now(data) + int(walk.steps), "started_day": data.day_count,
	}
	if fee > 0:
		Wallet.spend(data, fee, Wallet.GBP)
	data.set_flag(_basket_key(slot), basket)
	data.set_flag(paired_key(zone, data.day_count), true)
	return {"ok": true, "why": "", "slot": slot, "steps": int(walk.steps), "fee": fee, "late": walk.late, "kind": str(can.kind)}

# ---------------------------------------------------------------- hatching

## Hatches a walked-off basket into a creature (not yet in the party: see collect). null if the slot is empty, not yet
## walked off or its species has gone missing. Writes the log entry the Stud Book reads and empties the basket.
static func hatch(data: GameStateData, slot: int, dex: Dex, moves: MoveDB = null) -> Creature:
	var raw: Variant = data.flag(_basket_key(slot))
	if not (raw is Dictionary) or raw.is_empty():
		return null
	var b: Dictionary = raw
	if steps_now(data) < int(b.get("steps_due", 0)) or not dex.has(str(b.species)):
		return null
	var db := moves if moves != null else MoveDB.load_default()
	var c := Creature.create(dex.get_species(str(b.species)), int(b.get("level", HATCH_LEVEL)), Rng.new(int(b.uid)), db)
	c.ivs = b.ivs.duplicate()
	c.nature = str(b.temper)
	c.genome = b.genome.duplicate(true)
	c.sex = str(b.sex)
	c.uid = int(b.uid)
	c.pedigree = b.pedigree.duplicate(true)
	c.hybrid = str(b.get("hybrid", ""))
	c.friendship = HATCH_FRIENDSHIP
	c.variant = str(Genetics.showing(c).variant)
	Forms.inherit(c, str(b.get("dam_form", "")), db)  # maternal, a simplification (see the Stud Book)
	for m in b.get("heirlooms", []):
		if c.moves.size() >= Rules.MAX_MOVES:
			c.moves.remove_at(0)
		c.moves.append(c.make_move_slot(str(m), db))
	c.hp = c.max_hp()
	data.set_flag(_basket_key(slot), {})
	_log(data, b, c)
	return c

static func _log(data: GameStateData, b: Dictionary, c: Creature) -> void:
	var n := _count(data, LOG_COUNT) + 1
	data.set_flag(LOG_COUNT, n)
	var child := {}
	for l in c.genome:
		child[l] = Genetics.hand_key(l, c.genome[l])
	data.set_flag(LOG + str(n), {
		"day": data.day_count, "kind": str(b.kind), "species": str(b.species), "child_uid": c.uid,
		"sire_uid": int(b.sire_uid), "dam_uid": int(b.dam_uid), "sire_species": str(b.get("sire_species", "")),
		"dam_species": str(b.get("dam_species", "")), "sport": bool(b.get("sport", false)),
		"sport_locus": str(b.get("sport_locus", "")), "sire": b.get("parents", {}).get("sire", {}),
		"dam": b.get("parents", {}).get("dam", {}), "child": child,
	})
	if n > LOG_KEEP:
		data.flags.erase(LOG + str(n - LOG_KEEP))

## A log entry made by hand (tests, and the day a creature is added some other way).
static func log_hatch(data: GameStateData, c: Creature, sire_uid: int, dam_uid: int, kind := "same_line") -> void:
	_log(data, {"kind": kind, "species": str(c.species.id), "sire_uid": sire_uid, "dam_uid": dam_uid}, c)

## Every log entry, oldest first.
static func logs(data: GameStateData) -> Array:
	var out := []
	var n := _count(data, LOG_COUNT)
	for i in range(maxi(1, n - LOG_KEEP + 1), n + 1):
		var e: Variant = data.flag(LOG + str(i))
		if e is Dictionary:
			out.append(e)
	return out

## Hatches everything that is ready and sends the young to the party or the Ark. [{creature, where, sport, slot,
## sire_name, dam_name}] for the scene to tell.
static func collect(data: GameStateData, dex: Dex, moves: MoveDB = null) -> Array:
	var out := []
	for slot in ready(data):
		var b: Dictionary = data.flag(_basket_key(int(slot)))
		var c := hatch(data, int(slot), dex, moves)
		if c == null:
			continue
		out.append({"creature": c, "where": data.add_creature(c), "sport": bool(b.get("sport", false)),
			"slot": slot, "sire_name": str(b.get("sire_name", "")), "dam_name": str(b.get("dam_name", ""))})
	return out

# ---------------------------------------------------------------- conservation goals

## The bred creatures you hold, with how they were bred: [{creature, log}] (party and Ark; caught ones have no log).
static func bred_held(data: GameStateData) -> Array:
	var by_uid := {}
	for e in logs(data):
		by_uid[int(e.child_uid)] = e
	var out := []
	for c in data.party + data.ark:
		if c != null and c.uid != 0 and by_uid.has(c.uid):
			out.append({"creature": c, "log": by_uid[c.uid]})
	return out

static func _pair_key(e: Dictionary) -> String:
	return "%d_%d" % [int(e.sire_uid), int(e.dam_uid)]

## {met, have, need, title, claimed}: how far along a goal is.
static func goal_status(data: GameStateData, id: String) -> Dictionary:
	var g := goal(id)
	if g.is_empty():
		return {"met": false, "have": 0, "need": 0, "title": "", "claimed": false}
	var mine := []
	for h in bred_held(data):
		if Genetics.line_of(h.creature) == str(g.line) and not (str(g.rule) == "pure" and str(h.log.kind) != "same_line"):
			mine.append(h.log)
	var have := mine.size()
	var met := false
	var groups := {}
	for e in mine:
		groups[_pair_key(e)] = int(groups.get(_pair_key(e), 0)) + 1
	match str(g.rule):
		"spread":
			have = 0
			for k in groups:
				have += mini(int(groups[k]), 2)
			met = have >= int(g.need) and groups.size() >= 3
		"pairings":
			met = have >= int(g.need) and _disjoint_pairs(mine) >= int(g.get("pairs", 2))
		"pure":
			met = have >= int(g.need)
	return {"met": met, "have": have, "need": int(g.need), "title": str(g.title), "claimed": data.flag(GOAL + id) == true}

## How many pairings among these young share no parent with another (greedy; unrelated stock).
static func _disjoint_pairs(entries: Array) -> int:
	var used := {}
	var n := 0
	var seen := {}
	for e in entries:
		var k := _pair_key(e)
		if seen.has(k):
			continue
		seen[k] = true
		if used.has(int(e.sire_uid)) or used.has(int(e.dam_uid)):
			continue
		used[int(e.sire_uid)] = true
		used[int(e.dam_uid)] = true
		n += 1
	return n

## The breed society's grant for a goal at this many badges.
static func grant(g: Dictionary, badges: int) -> int:
	return int(g.get("base", 0)) + int(g.get("per_badge", 0)) * badges

## Pays a met goal once. {ok, why, money}. The standing and the words are the dialogue's business.
static func claim_goal(data: GameStateData, id: String) -> Dictionary:
	var g := goal(id)
	if g.is_empty():
		return {"ok": false, "why": "No such goal.", "money": 0}
	if data.flag(GOAL + id) == true:
		return {"ok": false, "why": "Already paid.", "money": 0}
	var st := goal_status(data, id)
	if not st.met:
		return {"ok": false, "why": "%d of %d so far." % [st.have, st.need], "money": 0}
	var money := grant(g, data.badges.size())
	data.set_flag(GOAL + id, true)
	Wallet.earn(data, money, Wallet.GBP)
	return {"ok": true, "why": "", "money": money}
