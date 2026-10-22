class_name Crossbreeds
extends RefCounted
## Crossbreeds: what hatches when two breeding lines are close enough kin to cross and data/hybrids.json has no
## authored hybrid for them (authored ones always win). Nothing about a crossbreed is stored but the creature: its
## species id is `x_<sire line>_<dam line>`, and Dex resolves it at runtime from the two parents, so the same pair
## always gives the same name, types, stats, moves and art, in every save and on every machine.
##
## Closeness mirrors real biology, from data/taxa.json (the real animal behind each line):
##   same species (two breeds)  always takes, fertile: a crossbred, like a Dexter-Highland calf
##   same genus                 takes about half the time; sterile like a mule unless the genus is marked fertile
##   same family                only the genus pairs taxa.json lists, rarely, and always sterile
##   further apart              never
## Both parents must also be of one kindred that breeds (genes.json), which keeps sex and seasons consistent.

const PREFIX := "x_"
const TAXA_PATH := "res://data/taxa.json"
const TIERS := ["species", "genus", "family"]
const ODDS := {"species": 1.0, "genus": 0.5, "family": 0.15}
## Further apart, the less well the two halves fit: the blend of the parents' final stages is scaled by this.
const SCALE := {"species": 0.97, "genus": 0.92, "family": 0.88}
const LIFT := 1.05            # the two stats both parents are best at, as for authored hybrids
const STORY_CAP := 500        # design section 9: no bred creature beats a mid-line final stage
const MAX_MOVES := 16
const NAME_MIN := 5
const NAME_MAX := 11

static var _taxa := {}
static var _cache := {}       # id -> species (a pure function of the data, so safe to keep)
static var _names := {}       # folded species names, for clash checks
static var _dex: Dex          # the last Dex that asked, so art code holding only an id can look one up

# ---------------------------------------------------------------- data

static func taxa() -> Dictionary:
	if _taxa.is_empty():
		var d = JsonUtil.read(TAXA_PATH)
		_taxa = d if d is Dictionary else {}
	return _taxa

static func taxon(line: String) -> Dictionary:
	if is_id(line):
		var p := parse(line)
		if p.is_empty():
			return {}
		var a := taxon(p[0])
		var b := taxon(p[1])
		# a crossbred of two breeds is still that species; a true hybrid belongs to neither
		if not a.is_empty() and str(a.get("species", "")) != "" and a.get("species") == b.get("species"):
			return a
		return {}
	return taxa().get("lines", {}).get(line, {})

static func clear_cache() -> void:
	_taxa = {}
	_cache = {}
	_names = {}

# ---------------------------------------------------------------- ids

static func is_id(id: String) -> bool:
	return id.begins_with(PREFIX)

static func id_for(sire_line: String, dam_line: String) -> String:
	return "%s%s_%s" % [PREFIX, sire_line, dam_line]

## [sire line, dam line] for a crossbreed id, or [] if it is not one. Line ids may hold underscores, so every split
## point is tried and the one where both halves are real lines wins.
static func parse(id: String) -> Array:
	if not is_id(id):
		return []
	var rest := id.substr(PREFIX.length())
	var lines: Dictionary = Genetics.genes().get("lines", {})
	var i := rest.find("_")
	while i > 0:
		var a := rest.substr(0, i)
		var b := rest.substr(i + 1)
		if lines.has(a) and lines.has(b) and not is_id(a) and not is_id(b):
			return [a, b]
		i = rest.find("_", i + 1)
	return []

## The parent lines a creature of this line descends from: [] for anything but a crossbreed.
static func parent_lines(line: String) -> Array:
	return parse(line)

static func kindred(line: String) -> String:
	var p := parse(line)
	return str(Genetics.genes().get("lines", {}).get(p[1], "")) if not p.is_empty() else ""

# ---------------------------------------------------------------- closeness

## {tier, why}: tier is "species", "genus", "family" or "" (they cannot cross), `why` the farmer's reason for a "".
static func closeness(sire_line: String, dam_line: String) -> Dictionary:
	var lines: Dictionary = Genetics.genes().get("lines", {})
	var ka := str(lines.get(sire_line, kindred(sire_line)))
	var kb := str(lines.get(dam_line, kindred(dam_line)))
	if ka != kb or not Genetics.breeds(ka):
		return {"tier": "", "why": ""}
	for r in taxa().get("restricted", []):
		if r is Array and r.size() == 2 and str(r[0]) == sire_line and str(r[1]) == dam_line:
			return {"tier": "", "why": "I've seen that cross tried. Nothing came of it, and I won't try again."}
	var a := taxon(sire_line)
	var b := taxon(dam_line)
	if a.is_empty() or b.is_empty():
		return {"tier": "", "why": ""}
	if str(a.get("species", "")) != "" and a.species == b.get("species"):
		return {"tier": "species", "why": ""}
	var ga := str(a.get("genus", ""))
	var gb := str(b.get("genus", ""))
	if ga != "" and ga == gb:
		var gen: Dictionary = taxa().get("genera", {}).get(ga, {})
		if gen.get("crosses", true) == false:
			return {"tier": "", "why": str(gen.get("why", ""))}
		return {"tier": "genus", "why": ""}
	var fa := str(a.get("family", ""))
	if fa != "" and fa == str(b.get("family", "")):
		var fam: Dictionary = taxa().get("families", {}).get(fa, {})
		for p in fam.get("pairs", []):
			if (str(p[0]) == ga and str(p[1]) == gb) or (str(p[0]) == gb and str(p[1]) == ga):
				return {"tier": "family", "why": ""}
		var why := str(fam.get("why", ""))
		if why == "":
			why = "Same family, different genus. That's further apart than it looks, and nobody's had young from that pair."
		return {"tier": "", "why": why}
	return {"tier": "", "why": ""}

static func fertile_tier(tier: String, genus: String) -> bool:
	match tier:
		"species":
			return true
		"genus":
			return taxa().get("genera", {}).get(genus, {}).get("fertile", false) == true
	return false

## Genetics.can_pair's answer for two different lines with no authored hybrid: {ok, why, kind, crossbreed, odds,
## tier}, or {} when this module has nothing to say (the caller's own refusal stands).
static func verdict(sire: Creature, dam: Creature) -> Dictionary:
	var sl := Genetics.line_of(sire)
	var dl := Genetics.line_of(dam)
	if is_id(sl) or is_id(dl):
		return {}   # a crossbred breeds back through its parents' lines (Genetics._lines_of), never into a new cross
	var c := closeness(sl, dl)
	if str(c.tier) == "":
		return {} if str(c.why) == "" else {"ok": false, "why": str(c.why), "kind": ""}
	return {"ok": true, "why": "", "kind": "crossbreed", "crossbreed": id_for(sl, dl), "odds": float(ODDS[c.tier]),
		"tier": str(c.tier)}

## A crossbreed that cannot have young of its own (the species entry says, since it is derived).
static func sterile(c: Creature) -> bool:
	var line := Genetics.line_of(c)
	return is_id(line) and c.species.get("crossbreed", {}).get("fertile", false) == false

## Dot's word on a pair that may cross, for the pairing screen.
static func odds_line(tier: String) -> String:
	match tier:
		"species":
			return "Two breeds of one kind. That'll take, no bother."
		"genus":
			return "Close kin, not the same kind. Even chance it takes."
		"family":
			return "That's a long shot. Crosses that far apart hardly ever take."
	return ""

# ---------------------------------------------------------------- the species

## The final stage of a line (its first stage's id is the line id), walking the evolutions.
static func final_stage(line: String, dex: Dex) -> Dictionary:
	var sp := dex.get_species(line)
	for _i in 6:
		var evo = sp.get("evolves")
		if not (evo is Dictionary) or not dex.has(str(evo.get("to", ""))):
			break
		sp = dex.get_species(str(evo.to))
	return sp

static func stage_names(line: String, dex: Dex) -> Array:
	var out := []
	var sp := dex.get_species(line)
	for _i in 6:
		if sp.is_empty():
			break
		out.push_front(str(sp.get("name", "")))
		var evo = sp.get("evolves")
		if not (evo is Dictionary):
			break
		sp = dex.get_species(str(evo.get("to", "")))
	return out   # final stage first

## The derived species for a crossbreed id, or {} if the id names no cross that can happen.
static func species(id: String, dex: Dex) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	_dex = dex
	var p := parse(id)
	if p.is_empty() or not dex.has(p[0]) or not dex.has(p[1]):
		return {}
	var c := closeness(p[0], p[1])
	if str(c.tier) == "":
		return {}
	var s := final_stage(p[0], dex)
	var d := final_stage(p[1], dex)
	var tier := str(c.tier)
	var fertile := fertile_tier(tier, str(taxon(p[0]).get("genus", "")))
	var name := name_for(p[0], p[1], dex)
	var sp := {
		"id": id, "line": id, "name": name, "types": merge_types(s.get("types", []), d.get("types", [])),
		"base": blend_stats(s.get("base", {}), d.get("base", {}), tier),
		"growth": str(d.get("growth", "medium")), "catch_rate": 0, "base_xp": int(d.get("base_xp", 0)),
		"learnset": merge_learnsets(s.get("learnset", []), d.get("learnset", [])), "evolves": null,
		"habitat": [], "knack": Knacks.id_for_species(d), "sprite": id,
		"crossbreed": {"sire": p[0], "dam": p[1], "tier": tier, "fertile": fertile,
			"sire_sprite": str(s.get("sprite", s.get("id", ""))), "dam_sprite": str(d.get("sprite", d.get("id", ""))),
			"sire_name": str(s.get("name", "")), "dam_name": str(d.get("name", ""))},
		"dex": {"text": entry_text(str(s.get("name", "")), str(d.get("name", "")), tier),
			"fact": fact_for(p[0], p[1], tier, fertile)},
	}
	_cache[id] = sp
	return sp

## The species for an id from whichever Dex last resolved one (for art code that holds only an id), or {}.
static func lookup(id: String) -> Dictionary:
	if _cache.has(id):
		return _cache[id]
	return species(id, _dex) if _dex != null else {}

## Every crossbreed the data allows, as ids, sire line first; authored hybrid pairs are left to their entries.
static func all_ids(dex: Dex) -> Array:
	var lines := []
	for l in Genetics.genes().get("lines", {}):
		if taxa().get("lines", {}).has(l) and dex.has(l):
			lines.append(str(l))
	lines.sort()
	var out := []
	for a in lines:
		for b in lines:
			if a != b and str(closeness(a, b).tier) != "" and not authored(a, b):
				out.append(id_for(a, b))
	return out

static func authored(sire_line: String, dam_line: String) -> bool:
	for h in Genetics.hybrids().values():
		if sire_line in h.get("sire_lines", []) and dam_line in h.get("dam_lines", []):
			return true
	return false

## Sire's first type, then the dam's; a shared first type takes the next one either parent has. At most two.
static func merge_types(st: Array, dt: Array) -> Array:
	var out := []
	for t in [st[0] if not st.is_empty() else "", dt[0] if not dt.is_empty() else ""] + dt.slice(1) + st.slice(1):
		if str(t) != "" and t not in out and out.size() < 2:
			out.append(t)
	return out

static func _total(base: Dictionary) -> int:
	var n := 0
	for k in Rules.STATS:
		n += int(base.get(k, 0))
	return n

## The mid-parent of the two final stages, scaled for how far apart they are, the two stats both are best at lifted,
## and the total held under the better parent's and the story's cap.
static func blend_stats(sb: Dictionary, db: Dictionary, tier: String) -> Dictionary:
	var out := {}
	var f := float(SCALE.get(tier, 0.88))
	for k in Rules.STATS:
		out[k] = maxi(1, roundi((int(sb.get(k, 0)) + int(db.get(k, 0))) / 2.0 * f))
	var order: Array = Rules.STATS.duplicate()
	order.sort_custom(func(x, y):
		var sx := int(sb.get(x, 0)) + int(db.get(x, 0))
		var sy := int(sb.get(y, 0)) + int(db.get(y, 0))
		return sx > sy if sx != sy else Rules.STATS.find(x) < Rules.STATS.find(y))
	for k in order.slice(0, 2):
		out[k] = roundi(out[k] * LIFT)
	var cap := mini(maxi(_total(sb), _total(db)) - 1, STORY_CAP)
	while _total(out) > cap:
		var top: String = Rules.STATS[0]
		for k in Rules.STATS:
			if int(out[k]) > int(out[top]):
				top = k
		out[top] = int(out[top]) - 1
	return out

## Both parents' moves, each at the earlier of its two levels, taken in turn so neither side drowns the other.
static func merge_learnsets(sl: Array, dl: Array) -> Array:
	var best := {}
	var order := []
	var lists := [_sorted(sl), _sorted(dl)]
	var i := 0
	while order.size() < MAX_MOVES and (i < lists[0].size() or i < lists[1].size()):
		for l in lists:
			if i < l.size():
				var lv := int(l[i][0])
				var m := str(l[i][1])
				if not best.has(m):
					if order.size() >= MAX_MOVES:
						continue
					order.append(m)
					best[m] = lv
				else:
					best[m] = mini(int(best[m]), lv)
		i += 1
	var out := []
	for m in order:
		out.append([int(best[m]), m])
	out.sort_custom(func(x, y): return x[0] < y[0] if x[0] != y[0] else order.find(x[1]) < order.find(y[1]))
	return out

static func _sorted(ls: Array) -> Array:
	var out := ls.duplicate()
	out.sort_custom(func(x, y): return int(x[0]) < int(y[0]) if int(x[0]) != int(y[0]) else str(x[1]) < str(y[1]))
	return out

# ---------------------------------------------------------------- words

static func entry_text(sire_name: String, dam_name: String, tier: String) -> String:
	if tier == "species":
		return "A %s sire and a %s dam, and the calf of the pair has the best of both and the manners of neither. Bred at the farm, never found wild." % [sire_name, dam_name]
	return "%s's face on a %s's frame, and a temper all its own. Bred at the farm, never found wild." % [sire_name, dam_name]

## The one true thing its entry teaches: why this cross could happen at all, and whether it can breed.
static func fact_for(sire_line: String, dam_line: String, tier: String, fertile: bool) -> String:
	var a := taxon(sire_line)
	var b := taxon(dam_line)
	match tier:
		"species":
			return "Both parents are %s, one species in two breeds, so their chromosomes pair up and it can have young of its own. That makes it a crossbred, not a hybrid." % str(a.species)
		"genus":
			if fertile:
				return "Its parents are two species of one genus, %s, close enough that even the young can breed, as a female liger can." % str(a.genus)
			return "Its parents are two species of one genus, %s. Close enough to make young, too far apart for those young to make their own, like a mule." % str(a.genus)
		"family":
			var note := str(taxa().get("families", {}).get(str(a.family), {}).get("fact", ""))
			return "%s It is sterile, as crosses this far apart are." % note if note != "" else "Its parents are different genera of one family, %s. Crosses that far apart hardly ever take, and the young are sterile." % str(a.family)
	return str(b.get("what", ""))

## The real biology, for the Fieldbook's Crossbreeds section: why ligers exist and mules can't breed.
const LESSON := "Only close kin cross. Lions and tigers share a genus and both have 38 chromosomes, so ligers are born, and a female liger can even have cubs. A horse has 64 and a donkey 62, so a mule gets 63, which can't pair up to make eggs or sperm: no foals. Further apart than one family, nothing takes at all."

# ---------------------------------------------------------------- names

const VOWELS := "aeiou"
const ONSETS := ["bl", "br", "ch", "cl", "cr", "dr", "fl", "fr", "gl", "gr", "pl", "pr", "sc", "sh", "sk", "sl", "sm",
	"sn", "sp", "st", "sw", "th", "tr", "tw", "wh", "wr"]
const DIGRAPHS := ["ck", "ch", "sh", "th", "gh", "ph", "ng"]
const SKIP_WORDS := ["y", "the"]
## Nothing rude, cruel or silly may appear anywhere inside a name. Substrings, so it errs on the side of caution.
const DENY := ["anal", "anus", "arse", "ass", "bitch", "bollo", "boob", "bra", "bugger", "bum", "butt", "cack", "chink",
	"cock", "coon", "crap", "cum", "cunt", "damn", "dick", "dong", "dung", "fag", "fanny", "fart", "fuc", "fuk", "gay",
	"god", "gook", "hell", "herpes", "homo", "jap", "jesus", "jizz", "kike", "knob", "minge", "nazi", "nig", "nob",
	"nonce", "paki", "pee", "penis", "piss", "poo", "porn", "prick", "pube", "puke", "pus", "rape", "scat", "sex",
	"shag", "shit", "slag", "slut", "smeg", "snot", "sod", "spaz", "spic", "tit", "todger", "tosser", "turd", "twat",
	"vag", "vomit", "wank", "willy", "wog"]
const FOLD := {"à": "a", "á": "a", "â": "a", "ä": "a", "è": "e", "é": "e", "ê": "e", "ë": "e", "ì": "i", "í": "i",
	"î": "i", "ï": "i", "ò": "o", "ó": "o", "ô": "o", "ö": "o", "ù": "u", "ú": "u", "û": "u", "ü": "u", "ŵ": "w", "ŷ": "y"}

static func _vowel(w: String, i: int) -> bool:
	var ch := w[i]
	return ch in VOWELS or (ch == "y" and i > 0)

## Lower case a-z only, accents folded.
static func fold(s: String) -> String:
	var out := ""
	for ch in s.to_lower():
		if ch >= "a" and ch <= "z":
			out += ch
		elif FOLD.has(ch):
			out += FOLD[ch]
	return out

static func _head_word(name: String) -> String:
	for w in name.split(" ", false):
		if fold(w) not in SKIP_WORDS:
			return fold(w)
	return fold(name)

static func _tail_word(name: String) -> String:
	var ws := name.split(" ", false)
	return fold(ws[ws.size() - 1]) if not ws.is_empty() else ""

## [[start, end]] of each vowel run.
static func _groups(w: String) -> Array:
	var out := []
	var i := 0
	while i < w.length():
		if _vowel(w, i):
			var j := i
			while j < w.length() and _vowel(w, j):
				j += 1
			out.append([i, j])
			i = j
		else:
			i += 1
	return out

## The front of a name: its first syllable (closed by one consonant, or a digraph), then its first two.
static func heads(w: String) -> Array:
	if w.length() > 1 and w[0] == w[1]:
		w = w.substr(1)   # Welsh dd, ll and ff at the front read badly in the middle of a word
	var gs := _groups(w)
	var out := []
	for k in mini(2, gs.size()):
		var e: int = gs[k][1]
		var nxt: int = gs[k + 1][0] if k + 1 < gs.size() else w.length()
		var cl := w.substr(e, nxt - e)
		if k + 1 >= gs.size():
			out.append(w.substr(0, nxt))
		elif w[e - 1] in "yw" or cl == "":
			out.append(w.substr(0, e))
		elif cl.substr(0, 2) in DIGRAPHS:
			out.append(w.substr(0, e + 2))
		else:
			out.append(w.substr(0, e + 1))
	return out

## The back of a name: its last syllable with its onset, then its last two; each also without the onset.
static func tails(w: String) -> Array:
	var core := w
	if w.ends_with("e") and _groups(w).size() > 1 and not _vowel(w, w.length() - 2):
		core = w.substr(0, w.length() - 1)   # a silent final e
	var gs := _groups(core)
	var out := []
	var k := gs.size() - 1
	while k >= 0 and k >= gs.size() - 2:
		var s: int = gs[k][0]
		var prev: int = gs[k - 1][1] if k > 0 else 0
		var cl := w.substr(prev, s - prev)
		var st := s
		if k == 0:
			st = 0
		elif cl.length() >= 2 and cl.right(2) in ONSETS:
			st = s - 2
		elif cl.length() > 0:
			st = s - 1
		out.append(w.substr(st))
		if st < s:
			out.append(w.substr(s))
		k -= 1
	return out

static var _bad_join: RegEx
static var _shape: Array = []

static func _regexes() -> void:
	if _bad_join != null:
		return
	_bad_join = RegEx.create_from_string("(gk|kg|pb|bp|td|dt|vf|fv|cg|gc|kc|q[^u]|x[^t]|hh|jj|vv|ww|yy|kk|[^aeiouy]h[^aeiouy]|[bdgkpt][bdgkpt][^aeiouyrl])")
	for p in ["[^aeiouy]{4}", "[aeiou]{3}", "(.)\\1\\1", "^(.)\\1", "(..)\\1"]:
		_shape.append(RegEx.create_from_string(p))

static func _join(h: String, t: String) -> String:
	_regexes()
	if h != "" and t != "" and h[h.length() - 1] == t[0]:
		t = t.substr(1)
	var j := h + t
	var at := maxi(0, h.length() - 2)
	if _bad_join.search(j.substr(at, 4)) == null:
		return j
	if t.length() > 3 and not _vowel(t, 0) and not _vowel(t, 1):
		j = h + t.substr(1)
		if _bad_join.search(j.substr(at, 4)) == null:
			return j
	return ""

## Why a candidate name fails, or "" if it is fine: shape (pronounceable), length, the deny-list, and no clash with
## a real species' name.
static func name_fault(n: String, dex: Dex = null) -> String:
	_regexes()
	var w := fold(n)
	if w.length() < NAME_MIN or w.length() > NAME_MAX:
		return "length"
	if not w.contains("a") and not w.contains("e") and not w.contains("i") and not w.contains("o") and not w.contains("u") and not w.contains("y"):
		return "no vowel"
	for r in _shape:
		if r.search(w) != null:
			return "shape"
	for i in w.length() - 2:
		if w.substr(i + 3).contains(w.substr(i, 3)):
			return "repeats"
	for bad in DENY:
		if w.contains(bad):
			return "deny:" + bad
	if dex != null and _species_names(dex).has(w):
		return "clash"
	return ""

static func _species_names(dex: Dex) -> Dictionary:
	if _names.is_empty():
		for id in dex.ids() + dex.hybrid_ids():
			_names[fold(str(dex.get_species(id).get("name", "")))] = true
	return _names

## A portmanteau, as real hybrid names are made (a liger's sire is a lion): the front of the sire's name and the
## back of the dam's, trying each stage's name, most natural length first. Two parents whose names will not blend
## cleanly get a plain double-barrelled name instead, which is honest and never rude.
static func name_for(sire_line: String, dam_line: String, dex: Dex) -> String:
	var sn := stage_names(sire_line, dex)
	var dn := stage_names(dam_line, dex)
	var parents := {}
	for n in sn + dn:
		parents[fold(n)] = true
		parents[_head_word(n)] = true
		parents[_tail_word(n)] = true
	for a in sn:
		for b in dn:
			var cands := []
			for h in heads(_head_word(a)):
				for t in tails(_tail_word(b)):
					var score := (1000 if t.substr(0, 1) in ["a", "e", "i", "o", "u"] else 0) + (100 if t.length() < 3 else 0) + absi(h.length() + t.length() - 7)
					cands.append([score, h, t])
			cands.sort_custom(func(x, y): return x[0] < y[0] if x[0] != y[0] else (x[1] + x[2]) < (y[1] + y[2]))
			for cand in cands:
				var n := _join(cand[1], cand[2])
				if n != "" and not parents.has(n) and name_fault(n, dex) == "":
					return n.capitalize()
	return fallback_name(sn[0] if not sn.is_empty() else sire_line, dn[0] if not dn.is_empty() else dam_line)

static func fallback_name(sire_name: String, dam_name: String) -> String:
	return "%s-%s" % [_head_word(sire_name).capitalize(), _tail_word(dam_name).capitalize()]

# ---------------------------------------------------------------- the Fieldbook

## The crossbreeds this save has hatched (or met), in a steady order: [id].
static func met(data: GameStateData) -> Array:
	var out := []
	for id in data.caught:
		if is_id(str(id)):
			out.append(str(id))
	out.sort()
	return out

## "Sire: Dextera (Dexter cattle)  Dam: Heilan (Highland cattle)" and its fertility, for an entry.
static func parents_line(sp: Dictionary) -> String:
	var x: Dictionary = sp.get("crossbreed", {})
	var a := str(taxon(str(x.get("sire", ""))).get("what", ""))
	var b := str(taxon(str(x.get("dam", ""))).get("what", ""))
	return "Sire: %s (%s).  Dam: %s (%s).  %s" % [str(x.get("sire_name", "")), a, str(x.get("dam_name", "")), b,
		"Can have young." if x.get("fertile", false) == true else "Sterile."]

# ---------------------------------------------------------------- validator

## Validator: taxa.json names real breeding lines, and every cross the data allows has a clean name, honest types,
## capped stats, real moves and art to blend.
static func check(dex: Dex, moves: MoveDB) -> Array:
	var errors := []
	var t := taxa()
	if t.is_empty():
		return ["taxa.json: missing or unreadable"]
	var lines: Dictionary = Genetics.genes().get("lines", {})
	for l in t.get("lines", {}):
		if not lines.has(l):
			errors.append("taxa.json: '%s' is not a line in genes.json" % l)
		elif not Genetics.breeds(str(lines[l])):
			errors.append("taxa.json: '%s' is of a kindred that does not breed" % l)
		var e: Dictionary = t.lines[l]
		if str(e.get("genus", "")) == "" or str(e.get("family", "")) == "" or str(e.get("what", "")) == "":
			errors.append("taxa.json: '%s' needs genus, family and what" % l)
	for id in dex.ids() + dex.hybrid_ids():
		if is_id(str(id)):
			errors.append("crossbreeds: species id '%s' uses the reserved x_ prefix" % id)
	for id in all_ids(dex):
		var sp := species(id, dex)
		if sp.is_empty():
			errors.append("crossbreeds: '%s' does not resolve" % id)
			continue
		var p := parse(id)
		if name_fault(str(sp.name), dex) != "":
			errors.append("crossbreeds: '%s' name '%s' fails (%s)" % [id, sp.name, name_fault(str(sp.name), dex)])
		var s := final_stage(p[0], dex)
		var d := final_stage(p[1], dex)
		var ty: Array = sp.types
		if ty.is_empty() or ty.size() > 2:
			errors.append("crossbreeds: '%s' needs one or two types" % id)
		for ti in ty:
			if ti not in s.get("types", []) and ti not in d.get("types", []):
				errors.append("crossbreeds: '%s' type '%s' is not from a parent" % [id, ti])
		var tot := _total(sp.base)
		if tot >= maxi(_total(s.base), _total(d.base)) or tot > STORY_CAP:
			errors.append("crossbreeds: '%s' stat total %d is over its cap" % [id, tot])
		for e in sp.learnset:
			if not moves.has(str(e[1])):
				errors.append("crossbreeds: '%s' has unknown move '%s'" % [id, e[1]])
		for key in ["sire_sprite", "dam_sprite"]:
			if not FileAccess.file_exists("res://art/recipes/creatures/%s.json" % str(sp.crossbreed[key])):
				errors.append("crossbreeds: '%s' has no recipe for %s" % [id, key])
		for txt in [sp.name, sp.dex.text, sp.dex.fact]:
			if "—" in str(txt):
				errors.append("crossbreeds: '%s' has an em-dash" % id)
	return errors
