class_name Genetics
extends RefCounted
## Good Stock: the genetics kit (docs/design/2026-10-21-breeding.md, sections 2 and 7). Pure logic, nothing here is
## wired into play yet. A genome is {locus: [a, b]}, the makings; the pair at a locus is its hand.
##  - Mark and Knack are linked: index i of both arrays is the same chromosome copy, so a gamete takes its Mark and
##    Knack from one copy and swaps the Knack to the other copy 15% of the time.
##  - Ginger sits on the sex chromosome. The one-copy sex holds [allele, "Y"] (beasts, male) or [allele, "W"]
##    (fowl, female); the other sex holds two real alleles.
## Genes and kindreds live in data/genes.json; LOCI here is the code's copy and Genetics.check keeps them in step.

const LOCI := {
	"coat": ["+", "c"],
	"tint": ["W", "R", "G", "S", "D", "M"],
	"mark": ["B", "b"],
	"knack": ["K", "k", "f"],
	"ginger": ["O", "o"],
	"frame1": ["+", "-"], "frame2": ["+", "-"], "frame3": ["+", "-"], "frame4": ["+", "-"],
}
const INDEPENDENT := ["coat", "tint", "frame1", "frame2", "frame3", "frame4"]
const FRAME := ["frame1", "frame2", "frame3", "frame4"]
const SEX_CHROMOSOMES := ["Y", "W"]
const GINGER_HUE := 0.08
const GENES_PATH := "res://data/genes.json"
const HYBRIDS_PATH := "res://data/hybrids.json"

static var _genes := {}
static var _hybrids := {}

static func genes() -> Dictionary:
	if _genes.is_empty():
		var d = JsonUtil.read(GENES_PATH)
		_genes = d if d is Dictionary else {}
	return _genes

## data/hybrids.json entries by id; empty until the hybrids session lands the file.
static func hybrids() -> Dictionary:
	if _hybrids.is_empty() and FileAccess.file_exists(HYBRIDS_PATH):
		var d = JsonUtil.read(HYBRIDS_PATH)
		var arr = d.get("hybrids", []) if d is Dictionary else d
		if arr is Array:
			for h in arr:
				if h is Dictionary and h.has("id"):
					_hybrids[str(h.id)] = h
	return _hybrids

## The Dex species for a hybrids.json entry: a complete species in its own one-stage line, flagged `hybrid`. Its
## stand-in art is a copy of its body recipe (art/recipes/creatures/<id>.json); GeneArt blends the face in at runtime.
static func hybrid_species(entry: Dictionary) -> Dictionary:
	return {"id": str(entry.id), "line": str(entry.id), "name": str(entry.get("name", entry.id)), "hybrid": true,
		"types": entry.get("types", []).duplicate(), "base": entry.get("base", {}).duplicate(),
		"growth": str(entry.get("growth", "medium")), "catch_rate": int(entry.get("catch_rate", 0)),
		"base_xp": int(entry.get("base_xp", 0)), "learnset": entry.get("learnset", []).duplicate(true),
		"evolves": null, "habitat": [], "knack": str(entry.get("knack", "")), "fertile": entry.get("fertile", true) == true,
		"dex": entry.get("dex", {}).duplicate(), "sprite": str(entry.id)}

## The hybrids.json entry a sire and dam of different lines would produce, or {} if the pair is not listed.
static func hybrid_for(sire: Creature, dam: Creature) -> Dictionary:
	if line_of(sire) == line_of(dam):
		return {}
	for h in hybrids().values():
		if line_of(sire) in h.get("sire_lines", []) and line_of(dam) in h.get("dam_lines", []):
			return h
	return {}

static func line_of(c: Creature) -> String:
	return str(c.species.get("line", c.species.get("id", "")))

static func kindred_of(c: Creature) -> String:
	var k := str(genes().get("lines", {}).get(line_of(c), ""))
	return k if k != "" else Crossbreeds.kindred(line_of(c))  # a crossbreed is of its parents' kindred

static func sex_mode(kindred: String) -> String:
	return str(genes().get("kindreds", {}).get(kindred, {}).get("sex", "none"))

static func breeds(kindred: String) -> bool:
	return genes().get("kindreds", {}).get(kindred, {}).get("breeds", false) == true

static func is_one_copy(sex: String, mode: String) -> bool:
	return (mode == "xy" and sex == "m") or (mode == "zw" and sex == "f")

## The creature's genome, deriving (without storing) one when it has none yet.
static func genome_of(c: Creature) -> Dictionary:
	return c.genome if not c.genome.is_empty() else derive(c).genome

## A creature that has no genome yet gets one that depends only on what it already is: its inborn values, temper and
## evolution line (never its level or species stage, so evolving changes nothing). {genome, sex}.
static func derive(c: Creature) -> Dictionary:
	var g := genes()
	var w: Dictionary = g.get("wild", {})
	var ivs := []
	for s in Rules.STATS:
		ivs.append(str(c.ivs.get(s, 0)))
	var rng := Rng.new(("%s|%s|%s" % [line_of(c), c.nature, ",".join(ivs)]).hash())
	var genome := {}
	var tints := _tints_for(c.variant)
	if tints.is_empty():
		genome["coat"] = ["+", "c"] if rng.roll() < float(w.get("carrier_coat", 0.125)) else ["+", "+"]
		genome["tint"] = [rng.pick(LOCI.tint), rng.pick(LOCI.tint)]
	else:
		genome["coat"] = ["c", "c"]
		genome["tint"] = [tints[0], tints[tints.size() - 1]]
	# Mark and Knack by chromosome copy; a k copy is usually bold, which is the marker breeders can see.
	var kcopy := -1
	if rng.roll() < float(w.get("carrier_knack", 0.1)):
		kcopy = rng.roll_int(0, 1)
	var mark := []
	var knack := []
	for h in 2:
		var has_k := h == kcopy
		knack.append("k" if has_k else "K")
		mark.append("B" if rng.roll() < float(w.get("bold_given_k" if has_k else "bold", 0.5)) else "b")
	genome["mark"] = mark
	genome["knack"] = knack
	for f in FRAME:
		genome[f] = ["+" if rng.roll() < float(w.get("frame_plus", 0.5)) else "-", "+" if rng.roll() < float(w.get("frame_plus", 0.5)) else "-"]
	var mode := sex_mode(kindred_of(c))
	var sex := ""
	if mode != "none":
		sex = "m" if rng.roll() < 0.5 else "f"
	var ginger_p := float(w.get("ginger", 0.1))
	var first := "O" if rng.roll() < ginger_p else "o"
	var second := "O" if rng.roll() < ginger_p else "o"
	if is_one_copy(sex, mode):
		second = "Y" if mode == "xy" else "W"
	genome["ginger"] = [first, second]
	return {"genome": genome, "sex": sex}

## The tints a coat string wears: "winter" -> ["W"], "winter+storm" -> ["W", "D"]; [] for no coat (or tortie).
static func _tints_for(variant: String) -> Array:
	var out := []
	if variant == "":
		return out
	var names: Dictionary = genes().get("tints", {})
	for part in variant.split("+"):
		for t in names:
			if names[t] == part:
				out.append(t)
	return out

## One gamete: an allele per locus (Ginger is handled by cross, since it decides sex).
static func _gamete(genome: Dictionary, rng: Rng) -> Dictionary:
	var out := {}
	for l in INDEPENDENT:
		out[l] = _hand(genome, l)[rng.roll_int(0, 1)]
	var h := rng.roll_int(0, 1)
	var rec := float(genes().get("linkage", {}).get("recombination", 0.15)) * 100.0
	out["mark"] = _hand(genome, "mark")[h]
	out["knack"] = _hand(genome, "knack")[1 - h if rng.chance(rec) else h]
	return out

static func _hand(genome: Dictionary, locus: String) -> Array:
	var h = genome.get(locus)
	if h is Array and h.size() == 2:
		return h
	var a: String = LOCI[locus][0]
	return [a, a]

## A cross of sire (male) and dam (female): the hatchling's {genome, sex, ivs, temper, heirlooms, sport, sport_locus,
## kinship, pedigree}. Callers check can_pair first; this never refuses.
static func cross(sire: Creature, dam: Creature, rng: Rng) -> Dictionary:
	var sg := genome_of(sire)
	var dg := genome_of(dam)
	var gs := _gamete(sg, rng)
	var gd := _gamete(dg, rng)
	var genome := {}
	for l in INDEPENDENT + ["mark", "knack"]:
		genome[l] = [gs[l], gd[l]]
	var mode := sex_mode(kindred_of(sire))
	if mode == "none":  # a sexless folklore parent (a selkie): the other parent's chromosomes decide
		mode = sex_mode(kindred_of(dam))
	var sex := _cross_sex(sg, dg, mode, genome, rng)
	var sport := ""
	if rng.roll() < 1.0 / float(genes().get("sport_one_in", 64)):
		sport = _mutate(genome, rng)
	var kin := kinship(sire, dam)
	var inb: Dictionary = genes().get("inbreeding", {})
	return {
		"genome": genome, "sex": sex, "ivs": _cross_ivs(sire, dam, kin, float(inb.get("depression_at", 0.125)), rng),
		"temper": _cross_temper(sire, dam, rng), "heirlooms": [], "sport": sport != "", "sport_locus": sport,
		"kinship": kin, "pedigree": {"sire": _node(sire, 1), "dam": _node(dam, 1)},
	}

## Ginger and sex together: the one-copy parent's gamete carries either its allele or the sex chromosome.
static func _cross_sex(sg: Dictionary, dg: Dictionary, mode: String, genome: Dictionary, rng: Rng) -> String:
	var s := _hand(sg, "ginger")
	var d := _hand(dg, "ginger")
	if mode == "xy" or mode == "zw":
		var het: Array = s if mode == "xy" else d
		var homo: Array = d if mode == "xy" else s
		var hg: String = het[rng.roll_int(0, 1)]
		var og: String = homo[rng.roll_int(0, 1)]
		if hg in SEX_CHROMOSOMES:
			genome["ginger"] = [og, hg]
			return "m" if mode == "xy" else "f"
		genome["ginger"] = [hg, og] if mode == "xy" else [og, hg]
		return "f" if mode == "xy" else "m"
	genome["ginger"] = [s[rng.roll_int(0, 1)], d[rng.roll_int(0, 1)]]
	return ""

## A sport: one allele rewritten to a different one. Returns the locus that changed.
static func _mutate(genome: Dictionary, rng: Rng) -> String:
	var locus: String = rng.pick(LOCI.keys())
	var hand: Array = genome[locus]
	var i := rng.roll_int(0, 1)
	if locus == "ginger" and hand[i] in SEX_CHROMOSOMES:
		i = 1 - i
	var options: Array = LOCI[locus].filter(func(a): return a != hand[i])
	hand[i] = rng.pick(options)
	return locus

## Quantitative genetics: mid-parent plus a little spread, capped at the better parent plus 2; unrelated parents get
## the hybrid-vigour lift, close kin the depression.
static func _cross_ivs(sire: Creature, dam: Creature, kin: float, depression_at: float, rng: Rng) -> Dictionary:
	var out := {}
	var lift := 0
	if kin <= 0.0:
		lift = 1
	elif kin >= depression_at:
		lift = -1
	for s in Rules.STATS:
		var a := int(sire.ivs.get(s, 0))
		var b := int(dam.ivs.get(s, 0))
		var v := roundi((a + b) / 2.0) + rng.roll_int(-1, 1) + lift
		var cap := maxi(a, b) + 2 + (1 if lift > 0 else 0) + (-2 if lift < 0 else 0)
		out[s] = clampi(mini(v, cap), 0, Rules.IV_MAX)
	return out

## From one parent two times in three, rolled fresh otherwise.
static func _cross_temper(sire: Creature, dam: Creature, rng: Rng) -> String:
	if rng.roll() < 2.0 / 3.0:
		return sire.nature if rng.roll_int(0, 1) == 0 else dam.nature
	return rng.pick(Rules.NATURES.keys())

## What shows: coat variant ("", "winter", "winter+storm"), tortie, Mark level (0 none, 1 medium, 2 strong), Frame
## (0 to 8 pluses), which knack ("first", "second" or "fault"), and the ginger hue shift.
static func showing(c: Creature) -> Dictionary:
	var g := genome_of(c)
	var sex := c.sex
	if sex == "" and c.genome.is_empty():
		sex = str(derive(c).sex)
	var mode := sex_mode(kindred_of(c))
	var variant := ""
	if _hand(g, "coat") == ["c", "c"]:
		var t := _hand(g, "tint")
		var names: Dictionary = genes().get("tints", {})
		var a := str(names.get(t[0], ""))
		var b := str(names.get(t[1], ""))
		variant = a if a == b else "+".join(_tint_order([a, b]))
	var ginger := _hand(g, "ginger")
	var tortie := false
	var orange := false
	if is_one_copy(sex, mode):
		orange = ginger[0] == "O"
	else:
		tortie = "O" in ginger and "o" in ginger
		orange = ginger[0] == "O" and ginger[1] == "O"
	var mark := _hand(g, "mark")
	var frame := 0
	for f in FRAME:
		for a in _hand(g, f):
			if a == "+":
				frame += 1
	var knack := _hand(g, "knack")
	return {
		"variant": variant, "tortie": tortie, "mark": mark.count("B"), "frame": frame,
		"knack": "fault" if knack == ["f", "f"] else ("second" if knack == ["k", "k"] else "first"),
		"hue": GINGER_HUE if orange else 0.0,
	}

static func _tint_order(names: Array) -> Array:
	var order: Array = Coats.ALL
	names.sort_custom(func(x, y): return order.find(x) < order.find(y))
	return names

## One node of a pedigree: {uid, sire, dam}, ancestors cut off `depth` generations up.
static func _node(c: Creature, depth: int) -> Dictionary:
	var n := {"uid": c.uid}
	if depth > 0:
		for k in ["sire", "dam"]:
			var p = c.pedigree.get(k)
			if p is Dictionary and not p.is_empty():
				n[k] = _trim(p, depth - 1)
	return n

static func _trim(p: Dictionary, depth: int) -> Dictionary:
	var n := {"uid": int(p.get("uid", 0))}
	if depth > 0:
		for k in ["sire", "dam"]:
			if p.get(k) is Dictionary:
				n[k] = _trim(p[k], depth - 1)
	return n

static func _height(n: Dictionary) -> int:
	var h := 0
	for k in ["sire", "dam"]:
		if n.get(k) is Dictionary and not n[k].is_empty():
			h = maxi(h, 1 + _height(n[k]))
	return h

static func _phi(a: Dictionary, b: Dictionary) -> float:
	if a.is_empty() or b.is_empty():
		return 0.0
	var ua := int(a.get("uid", 0))
	if ua != 0 and ua == int(b.get("uid", 0)):
		return 0.5
	var ha := _height(a)
	var hb := _height(b)
	if ha == 0 and hb == 0:
		return 0.0
	if ha >= hb:
		return 0.5 * (_phi(a.get("sire", {}), b) + _phi(a.get("dam", {}), b))
	return 0.5 * (_phi(a, b.get("sire", {})) + _phi(a, b.get("dam", {})))

## Wright's coefficient of kinship over the recorded pedigree: 0 for unrelated stock (or unknown uids), 0.125 for
## half-siblings, 0.25 for full siblings and for parent and child. This is the inbreeding of their young.
static func kinship(a: Creature, b: Creature) -> float:
	return _phi(_node(a, 2), _node(b, 2))

## The notation for a hand: alleles in table order, the sex chromosome last ("+c", "OY").
static func hand_key(locus: String, hand: Array) -> String:
	var order: Array = LOCI[locus]
	var sorted := hand.duplicate()
	sorted.sort_custom(func(x, y): return _rank(order, x, locus) < _rank(order, y, locus))
	return "".join(sorted)

static func _rank(order: Array, allele: String, locus: String) -> int:
	return 99 if locus == "ginger" and allele in SEX_CHROMOSOMES else order.find(allele)

## The possible hands of a parent at a locus given only what shows. A recessive hidden behind its dominant
## (Coat, Knack) could be any carrier; Tint shows only on a cc coat.
static func _possible_hands(g: Dictionary, locus: String, known_only: bool) -> Array:
	var hand := _hand(g, locus)
	if not known_only:
		return [hand]
	var alleles: Array = LOCI[locus]
	if locus == "tint" and _hand(g, "coat") != ["c", "c"]:
		var all := []
		for i in alleles.size():
			for j in range(i, alleles.size()):
				all.append([alleles[i], alleles[j]])
		return all
	if (locus == "coat" or locus == "knack") and alleles[0] in hand:
		var out := [[alleles[0], alleles[0]]]
		for x in alleles.slice(1):
			out.append([alleles[0], x])
		return out
	return [hand]

## The Punnett square for one independent locus as [{genotype, p, min, max}], sorted by genotype. With known_only the
## parents' hidden recessives are unknown: p is the middle of the range and min/max bound every square the evidence
## allows, so the preview never claims odds outside what is possible. (Ginger and the linked pair are not squared here.)
static func punnett(sire: Creature, dam: Creature, locus: String, known_only := false) -> Array:
	if not LOCI.has(locus) or locus == "ginger":
		return []
	var dists := []
	var keys := {}
	for sh in _possible_hands(genome_of(sire), locus, known_only):
		for dh in _possible_hands(genome_of(dam), locus, known_only):
			var dist := {}
			for x in sh:
				for y in dh:
					var key := hand_key(locus, [x, y])
					dist[key] = dist.get(key, 0.0) + 0.25
			dists.append(dist)
			for k in dist:
				keys[k] = true
	var out := []
	var sorted_keys := keys.keys()
	sorted_keys.sort()
	for k in sorted_keys:
		var lo := 1.0
		var hi := 0.0
		for d in dists:
			lo = minf(lo, d.get(k, 0.0))
			hi = maxf(hi, d.get(k, 0.0))
		out.append({"genotype": k, "p": (lo + hi) / 2.0, "min": lo, "max": hi})
	return out

static func _lines_of(c: Creature) -> Array:
	var out := [line_of(c)]
	if c.hybrid != "" and hybrids().has(c.hybrid):
		out.append_array(hybrids()[c.hybrid].get("sire_lines", []))
		out.append_array(hybrids()[c.hybrid].get("dam_lines", []))
	out.append_array(Crossbreeds.parent_lines(line_of(c)))  # a fertile crossbred breeds back into either parent line
	return out

## May these two be paired? {ok, why, kind}: kind is "same_line", "hybrid" (a listed cross) or "". `why` is the
## farmer's reason when refused. Close kin are always refused ("not on my farm").
static func can_pair(sire: Creature, dam: Creature, _dex = null) -> Dictionary:
	var listed := hybrid_for(sire, dam)  # a listed cross is allowed for its own reasons, folklore included
	for pair in [[sire, "m"], [dam, "f"]]:
		var p: Creature = pair[0]
		if p.sex != pair[1] and not (p.sex == "" and not listed.is_empty()):
			return {"ok": false, "why": "It takes a male and a female, and I'm not guessing which is which.", "kind": ""}
	for p in [sire, dam]:
		if listed.is_empty() and not breeds(kindred_of(p)):
			return {"ok": false, "why": "That kind doesn't breed. Not the way you're thinking, anyway.", "kind": ""}
		if (p.hybrid != "" and hybrids().get(p.hybrid, {}).get("fertile", true) == false) or Crossbreeds.sterile(p):
			return {"ok": false, "why": "A cross like that can't have young of its own. Mules are famous for it.", "kind": ""}
	var inb: Dictionary = genes().get("inbreeding", {})
	if kinship(sire, dam) >= float(inb.get("refuse_at", 0.25)):
		return {"ok": false, "why": "Not on my farm.", "kind": ""}
	var sl := _lines_of(sire)
	var dl := _lines_of(dam)
	for l in sl:
		if l in dl:
			return {"ok": true, "why": "", "kind": "same_line"}
	if not listed.is_empty():
		return {"ok": true, "why": "", "kind": "hybrid", "hybrid": str(listed.id), "odds": float(listed.get("odds", 1.0))}
	var cross := Crossbreeds.verdict(sire, dam)  # close kin with no authored hybrid: a generated crossbreed
	if not cross.is_empty():
		return cross
	if kindred_of(sire) != kindred_of(dam):
		return {"ok": false, "why": "Those two aren't even the same kind of animal. It doesn't work, and the postcards lie.", "kind": ""}
	return {"ok": false, "why": "Different species, and nobody has got young out of that pair. I won't try it.", "kind": ""}

## Validator: genes.json agrees with LOCI, every evolution line has a known kindred, nothing stale.
static func check(dex: Dex) -> Array:
	var errors := []
	var g := genes()
	if g.is_empty():
		return ["genes.json: missing or unreadable"]
	var loci: Dictionary = g.get("loci", {})
	for l in LOCI:
		if not loci.has(l) or loci[l].get("alleles", []) != LOCI[l]:
			errors.append("genes.json: locus '%s' does not match Genetics.LOCI" % l)
	for l in loci:
		if not LOCI.has(l):
			errors.append("genes.json: unknown locus '%s'" % l)
	var kindreds: Dictionary = g.get("kindreds", {})
	var lines: Dictionary = g.get("lines", {})
	var seen := {}
	for id in dex.ids():
		var line := str(dex.get_species(id).get("line", id))
		if seen.has(line):
			continue
		seen[line] = true
		if not lines.has(line):
			errors.append("genes.json: line '%s' has no kindred" % line)
		elif not kindreds.has(lines[line]):
			errors.append("genes.json: line '%s' has unknown kindred '%s'" % [line, lines[line]])
	for id in dex.hybrid_ids():
		seen[id] = true  # a hybrid is its own one-species line
	for line in lines:
		if not seen.has(line):
			errors.append("genes.json: line '%s' is not in the Fieldbook" % line)
	return errors

const HYBRID_REAL := ["real", "folklore", "invented"]

static func _total(base: Dictionary) -> int:
	var n := 0
	for s in Rules.STATS:
		n += int(base.get(s, 0))
	return n

## Validator: data/hybrids.json. Parent lines exist, types come from the parents, the stat total stays under the
## better parent's final stage, moves exist, the entry says what it is, and nothing uses an em-dash.
static func check_hybrids(dex: Dex, moves: MoveDB) -> Array:
	var errors := []
	var g := genes()
	for h in hybrids().values():
		var id := str(h.id)
		if dex.ids().has(id):
			errors.append("hybrids.json: '%s' clashes with a species" % id)
		if not HYBRID_REAL.has(str(h.get("real", ""))):
			errors.append("hybrids.json: '%s' needs real: real|folklore|invented" % id)
		if not g.get("lines", {}).has(id):
			errors.append("hybrids.json: '%s' has no kindred in genes.json" % id)
		var types := []
		var best := 0
		var kinds := {}
		for key in ["sire_lines", "dam_lines"]:
			if h.get(key, []).is_empty():
				errors.append("hybrids.json: '%s' has no %s" % [id, key])
			for l in h.get(key, []):
				kinds[str(g.get("lines", {}).get(l, ""))] = true
				var found := false
				for sid in dex.ids():
					var sp := dex.get_species(sid)
					if str(sp.get("line", sid)) == l:
						found = true
						types.append_array(sp.get("types", []))
						best = maxi(best, _total(sp.base))
				if not found:
					errors.append("hybrids.json: '%s' names unknown line '%s'" % [id, l])
		if kinds.size() > 1 and h.get("real", "") == "real":
			errors.append("hybrids.json: '%s' is tagged real but crosses kindreds" % id)
		var ht: Array = h.get("types", [])
		if ht.is_empty() or ht.size() > 2:
			errors.append("hybrids.json: '%s' needs one or two types" % id)
		for t in ht:
			if not types.has(t):
				errors.append("hybrids.json: '%s' type '%s' is not from a parent" % [id, t])
		if _total(h.get("base", {})) >= best:
			errors.append("hybrids.json: '%s' stat total is not under the better parent's final stage (%d)" % [id, best])
		var spr: Dictionary = h.get("sprite", {})
		for key in ["body", "face"]:
			if not FileAccess.file_exists("res://art/recipes/creatures/%s.json" % str(spr.get(key, ""))):
				errors.append("hybrids.json: '%s' sprite %s '%s' has no recipe" % [id, key, spr.get(key, "")])
		for e in h.get("learnset", []):
			if not moves.has(str(e[1])):
				errors.append("hybrids.json: '%s' has unknown move '%s'" % [id, e[1]])
		for txt in [h.get("name", ""), h.get("dex", {}).get("text", ""), h.get("dex", {}).get("fact", "")]:
			if str(txt) == "" or "\u2014" in str(txt):
				errors.append("hybrids.json: '%s' has empty text or an em-dash" % id)
	return errors
