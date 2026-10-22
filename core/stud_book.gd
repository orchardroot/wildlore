class_name StudBook
extends RefCounted
## The Stud Book (docs/design/2026-10-21-breeding.md section 5): what the player has seen of inheritance. Pure logic over
## GameStateData flags, no autoloads. Session D's hatch calls `observe` once per hatchling; the pairing screen calls
## `note` when it refuses a pair. Flags (all default empty, so old saves are untouched):
##  - book_ideas  {idea_id: true}   pages unlocked
##  - book_loci   {locus: true}     loci that have had a first showing
##  - book_tally  {"locus|sire|dam": {locus, sire, dam, n, seen: {hand: count}}}  observed against expected
##  - book_log    [String]          the Crosses log, newest last, capped
## Expected counts come from the parents' hands (both stored with the tally), the observed ones from the hatchlings.

const LOG_MAX := 30
const TALLY_LOCI := ["coat", "tint", "mark", "knack"]

## One entry per idea: id, title, the hint shown while locked, four short paragraphs ("text"), a worked square and
## one real story. Facts are the ones the design's section 5 vouches for; anything uncertain is left out.
const IDEAS := [
	{"id": "dominance", "title": "Dominance", "hint": "Breed a coloured coat to a plain one to learn this.",
		"text": ["Every creature has two copies of each making, one from each parent. When the two differ, one can speak louder than the other. That is dominance.",
			"The usual coat is dominant: a creature with one usual copy and one coloured copy wears the usual coat. The coloured coat only shows when both copies are the coloured one.",
			"So a coloured parent and a plain parent give plain young, every time, however striking the coloured one was.",
			"The coloured copy has not gone anywhere. It is waiting."],
		"square": "coat", "story": "Gregor Mendel worked this out with peas in the abbey garden at Brno and published in 1866. Nobody took much notice until 1900."},
	{"id": "carriers", "title": "Carriers", "hint": "Get a coloured coat from two plain parents to learn this.",
		"text": ["A creature with one usual copy and one coloured copy looks usual and carries the coloured one. You cannot tell by looking.",
			"Two carriers have a one in four chance of a coloured youngster at each hatching: the odds do not remember the last one.",
			"A test cross finds a carrier. Pair the creature you doubt with a coloured one: if any young come out coloured, it was carrying.",
			"Breeders did exactly this long before anyone had a word for a gene."],
		"square": "coat", "story": "Dark, plain parents throwing a pale lamb is the oldest surprise in the lambing shed, and the one dominance explains."},
	{"id": "codominance", "title": "Co-dominance", "hint": "Hatch a roan: a coloured coat with two different tints.",
		"text": ["Sometimes neither copy wins and both show. A coloured coat with two different tints wears both, mixed through each other: a roan.",
			"Tint is only read on a coloured coat, so a plain creature can carry tints it never shows.",
			"That is a kind of hiding called epistasis: one making deciding whether another is read at all.",
			"Roan is not a blend, like paint. Look closely and both colours are still there, hair by hair."],
		"square": "tint", "story": "Roan cattle are the textbook case: red and white hairs side by side, not pink."},
	{"id": "incomplete", "title": "Incomplete dominance", "hint": "Hatch a medium-marked creature to learn this.",
		"text": ["Here the middle is a third showing of its own. Bold markings from one parent and faint from the other give medium markings.",
			"Two medium-marked parents give bold, medium and faint in the ratio one, two, one.",
			"You can read the hand straight off the creature, which makes this the easiest making to breed on purpose.",
			"Nothing is hidden, so nothing needs a test cross."],
		"square": "mark", "story": "Snapdragons gave the same lesson: red crossed with white gives pink, and pink crossed with pink gives red, pink and white."},
	{"id": "sex_linkage", "title": "Sex linkage", "hint": "Hatch a tortoiseshell to learn this.",
		"text": ["Ginger lives on the sex chromosome. The sex with two copies can carry a ginger and a not-ginger side by side; the sex with one copy has only what it has.",
			"In beasts the female has two copies. A creature with one of each shows both, in patches: tortoiseshell.",
			"A male with one copy is ginger or he is not. So tortoiseshells are, nearly always, female.",
			"Birds are the other way round: the female has the single copy."],
		"square": "ginger", "story": "Nearly every tortoiseshell cat is female, for just this reason. Reginald Punnett's auto-sexing hens used a sex-linked barring so that a chick's sex could be read from its down."},
	{"id": "polygenic", "title": "Polygenic traits", "hint": "Hatch three times to learn this.",
		"text": ["Frame is four makings acting together, each adding a little. Most creatures land in the middle; the very big and very small are rare.",
			"Two big parents usually have big young, but not as big as themselves.",
			"Add the pluses: eight is the most, none the least, four the commonest.",
			"Big is sturdy and slow. Small is quick and light."],
		"square": "frame", "story": "Francis Galton noticed that tall parents have tall children, but not quite as tall, and called it regression."},
	{"id": "linkage", "title": "Linkage", "hint": "Hatch a creature with the second knack to learn this.",
		"text": ["Makings that sit close together on the same chromosome tend to travel together. Bold markings and the second knack are neighbours.",
			"Now and then the two come apart, about fifteen times in a hundred.",
			"So a breeder who notices that bold markings often go with a hidden knack can breed on what shows to get what does not.",
			"It is a marker: not the gene, but a flag beside it."],
		"square": "knack", "story": "William Bateson, Edith Rebecca Saunders and Reginald Punnett found two sweet-pea traits that would not sort independently, and had found linkage."},
	{"id": "mutation", "title": "Mutation", "hint": "Hatch a sport to learn this.",
		"text": ["Once in a long while a copy is rewritten as it is passed on. Breeders call the result a sport.",
			"It is random and it does not aim at anything. Most sports are nothing; a few are something.",
			"It is the only way a new making can enter a closed line.",
			"Whatever you were not expecting, that is probably it."],
		"square": "", "story": "In 1791 a Massachusetts farmer bred from a short-legged lamb that appeared in his flock, and the Ancon sheep were the result."},
	{"id": "vigour", "title": "Vigour and kinship", "hint": "Be refused a close pairing, or pair two unrelated creatures.",
		"text": ["Unrelated parents give young a little hardier than their average. That is hybrid vigour.",
			"Close kin do the reverse. The same hidden faults turn up on both sides, and young get two copies of them.",
			"Kinship is the chance that a making in one creature is a copy of the same making in the other.",
			"That is why the farmer says no to close pairings, and says it flatly."],
		"square": "", "story": "The Florida panther was so inbred by the 1990s that eight Texas pumas were brought in to freshen it, in 1995."},
	{"id": "breed", "title": "Breed versus species", "hint": "Pair two of the same line to learn this.",
		"text": ["A breed is a line within one kind of creature that has been kept to type. A species is a kind that does not mix with others.",
			"Two creatures of one line can always be paired, if they are fond of each other and not close kin.",
			"Within a line you are choosing; between lines you are asking.",
			"Dogs are the great example: one species, hundreds of breeds."],
		"square": "", "story": "The Rare Breeds Survival Trust has looked after native breeds since 1973."},
	{"id": "hybrids", "title": "Hybrids and sterility", "hint": "Meet a pairing that cannot have young.",
		"text": ["Some different kinds can be crossed, and the result is a hybrid, often stronger and stranger than either.",
			"A hybrid's makings do not always match up for the next generation, so many are sterile.",
			"A mule has a horse for one parent and a donkey for the other, and cannot have young of its own.",
			"The farmer will not take a pairing she knows will come to nothing."],
		"square": "", "story": "A horse has 64 chromosomes and a donkey 62, so a mule has 63 and they cannot be paired up evenly."},
	{"id": "selection", "title": "Selection", "hint": "Log six crosses to learn this.",
		"text": ["Choose the best of each hatching to breed from, and the next hatching will be a little better.",
			"It works slowly, because chance keeps getting a vote and regression pulls the extremes back to the middle.",
			"It stops working when everything is the same. Only a sport or a stranger can start it again.",
			"Patience, mostly."],
		"square": "", "story": "Robert Bakewell, farming at Dishley in Leicestershire in the eighteenth century, was among the first to breed livestock this way on purpose."},
	{"id": "conservation", "title": "Conservation", "hint": "Take on a Watchlist breeding goal.",
		"text": ["A rare breed has few animals and so few makings. Every one that is lost is lost for good.",
			"Breeding for conservation is the opposite of breeding for show: keep the makings, keep the kin apart, spread the lines.",
			"Pedigree records are the tool. A herd book is the Stud Book written by someone else.",
			"Nothing is bred here to be sold."],
		"square": "", "story": "Soay sheep on Hirta, in the St Kilda group, have been studied since 1985 and are one of the best-known wild population genetics projects."},
	{"id": "regional_forms", "title": "Regional forms", "hint": "Hatch a creature in a regional form.",
		"text": ["Creatures cut off in one place for long enough drift apart from their cousins elsewhere. Islands are the classic case.",
			"The differences are slight: a darker coat, a heavier build, a shade of colour. They are still the same kind, and can still be paired.",
			"Here that is a simplification. A hatchling takes its dam's form, as if the form came down the female line; real inheritance is messier and runs through both parents.",
			"Hybrids never carry a form, because a form belongs to a population in a place, and a hybrid belongs to none."],
		"square": "", "story": "The St Kilda wren is a larger, paler subspecies of the wren found only on Hirta."},
]

static func idea(id: String) -> Dictionary:
	for i in IDEAS:
		if i.id == id:
			return i
	return {}

static func _dict(data: GameStateData, key: String) -> Dictionary:
	var v = data.flag(key)
	return v if v is Dictionary else {}

static func unlocked(data: GameStateData, id: String) -> bool:
	return _dict(data, "book_ideas").has(id)

static func unlock(data: GameStateData, id: String) -> bool:
	if idea(id).is_empty() or unlocked(data, id):
		return false
	var d := _dict(data, "book_ideas")
	d[id] = true
	data.set_flag("book_ideas", d)
	return true

static func idea_count(data: GameStateData) -> int:
	return _dict(data, "book_ideas").size()

static func locus_seen(data: GameStateData, locus: String) -> bool:
	return _dict(data, "book_loci").has(locus)

## The pairing screen's reports of things it showed the player: "sterile", "close_kin", "unrelated".
static func note(data: GameStateData, what: String) -> void:
	match what:
		"sterile":
			unlock(data, "hybrids")
		"close_kin", "unrelated":
			unlock(data, "vigour")

## Records one hatchling: its first showings, its tally lines, the crosses log, and any idea it unlocks.
## `kind` is Genetics.can_pair's kind; `sport` is the cross kit's flag. Returns the ids of ideas newly unlocked.
static func observe(data: GameStateData, sire: Creature, dam: Creature, child: Creature, kind := "same_line", sport := false) -> Array:
	var had := _dict(data, "book_ideas").duplicate()
	var gs := Genetics.genome_of(sire)
	var gd := Genetics.genome_of(dam)
	var gc := Genetics.genome_of(child)
	var sh := Genetics.showing(sire)
	var dh := Genetics.showing(dam)
	var ch := Genetics.showing(child)
	var loci := _dict(data, "book_loci")
	for l in ["coat", "mark", "ginger", "frame"]:
		loci[l] = true
	if ch.variant != "":
		loci["tint"] = true
	if ch.knack != "first":
		loci["knack"] = true
	data.set_flag("book_loci", loci)
	var tally := _dict(data, "book_tally")
	for l in TALLY_LOCI:
		var hs := Genetics.hand_key(l, gs[l])
		var hd := Genetics.hand_key(l, gd[l])
		var key := "%s|%s|%s" % [l, hs, hd]
		var t: Dictionary = tally.get(key, {"locus": l, "sire": hs, "dam": hd, "n": 0, "seen": {}})
		t.n = int(t.n) + 1
		var hc := Genetics.hand_key(l, gc[l])
		t.seen[hc] = int(t.seen.get(hc, 0)) + 1
		tally[key] = t
	data.set_flag("book_tally", tally)
	var checks := {
		"dominance": Genetics.hand_key("coat", gc.coat) == "+c" and (sh.variant != "") != (dh.variant != ""),
		"carriers": ch.variant != "" and sh.variant == "" and dh.variant == "",
		"codominance": ch.variant.contains("+"),
		"incomplete": ch.mark == 1,
		"sex_linkage": ch.tortie,
		"linkage": ch.knack == "second",
		"mutation": sport,
		"breed": kind == "same_line",
		"hybrids": kind == "hybrid",
		"vigour": Genetics.kinship(sire, dam) > 0.0,
		"regional_forms": child.form != "",
	}
	for id in checks:
		if checks[id]:
			unlock(data, id)
	var log := _log(data)
	log.append("%s x %s: %s" % [_name(sire), _name(dam), _name(child)])
	while log.size() > LOG_MAX:
		log.remove_at(0)
	data.set_flag("book_log", log)
	if log.size() >= 3:
		unlock(data, "polygenic")
	if log.size() >= 6:
		unlock(data, "selection")
	for k in data.flags:
		if str(k).begins_with("breed_goal_") and data.flags[k]:
			unlock(data, "conservation")
	return IDEAS.map(func(i): return i.id).filter(func(id): return unlocked(data, id) and not had.has(id))

static func _name(c: Creature) -> String:
	return c.nickname if c.nickname != "" else str(c.species.get("name", "?"))

static func _log(data: GameStateData) -> Array:
	var v = data.flag("book_log")
	return v if v is Array else []

static func crosses_log(data: GameStateData) -> Array:
	return _log(data).duplicate()

## "1 in 4" for an exact unit fraction, else a percentage.
static func odds_words(p: float) -> String:
	if p <= 0.0:
		return "never"
	for k in range(2, 17):
		if absf(p - 1.0 / k) < 0.002:
			return "1 in %d" % k
	return "%d%%" % roundi(p * 100.0)

## The distribution over a child's hand at an independent locus from two parents' hands ("+c", "+c").
static func expected(locus: String, sire_hand: String, dam_hand: String) -> Dictionary:
	var out := {}
	for x in sire_hand:
		for y in dam_hand:
			var k := Genetics.hand_key(locus, [x, y])
			out[k] = float(out.get(k, 0.0)) + 0.25
	return out

static func _words(locus: String, hand: String) -> String:
	return PunnettView.outcome_word(locus, hand)

## The tally lines, "Coat, +c x +c: coloured expected 1 in 4, seen 2 of 6" (focus is the rarest outcome expected, the recessive one on a tie).
static func tally_lines(data: GameStateData) -> Array:
	var out := []
	var t := _dict(data, "book_tally")
	var keys := t.keys()
	keys.sort()
	for key in keys:
		var e: Dictionary = t[key]
		var locus := str(e.locus)
		var exp := expected(locus, str(e.sire), str(e.dam))
		var focus := ""
		for k in exp:
			if focus == "" or exp[k] <= exp[focus]:
				focus = k
		out.append("%s, %s x %s: %s expected %s, seen %d of %d" % [PunnettView.locus_name(locus), e.sire, e.dam, _words(locus, focus), odds_words(exp[focus]), int(e.seen.get(focus, 0)), int(e.n)])
	return out
