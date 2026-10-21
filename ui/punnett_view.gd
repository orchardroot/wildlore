class_name PunnettView
extends RefCounted
## The Punnett preview (design section 6): a 2 by 2 square for one locus, sire across the top and dam down the side,
## and "What you're after" with its chance. What the player does not know shows as `?`, and the odds then come as a
## range that never leaves what the unknowns allow (Genetics.punnett with known_only). Logic is static and pure
## (data in, no autoloads); build() draws it.

const LOCI := ["coat", "tint", "mark", "knack", "frame"]  # "frame" stands for the four Frame loci, which act alike
const NAMES := {"coat": "Coat", "tint": "Tint", "mark": "Mark", "knack": "Knack", "frame": "Frame"}
const GOALS := [
	{"id": "coat", "name": "A coloured coat"}, {"id": "roan", "name": "A roan"}, {"id": "mark", "name": "Bold markings"},
	{"id": "knack", "name": "The second knack"}, {"id": "frame", "name": "A big frame"},
]
const WORDS := {
	"coat": {"++": "plain", "+c": "plain, carries a coloured coat", "cc": "coloured"},
	"mark": {"BB": "bold", "Bb": "medium", "bb": "faint"},
	"knack": {"KK": "the line's knack", "Kk": "the line's knack", "kk": "the second knack", "Kf": "the line's knack", "kf": "the line's knack", "ff": "a weak spot"},
}

static func locus_name(locus: String) -> String:
	return str(NAMES.get(locus, locus.capitalize()))

static func genome_locus(locus: String) -> String:
	return "frame1" if locus == "frame" else locus

## Which loci the preview may cycle: Coat from the start, the rest once the Stud Book has met them.
static func open_loci(data: GameStateData) -> Array:
	return LOCI.filter(func(l): return l == "coat" or StudBook.locus_seen(data, l))

## What a hand looks like to the player ("plain", "roan", "bold"...).
static func outcome_word(locus: String, hand: String) -> String:
	match locus:
		"tint":
			var names: Dictionary = Genetics.genes().get("tints", {})
			var parts := []
			for ch in hand:
				var n := str(names.get(ch, ch))
				if not parts.has(n):
					parts.append(n)
			return " and ".join(parts) + (" roan" if parts.size() > 1 else "")
		"frame", "frame1", "frame2", "frame3", "frame4":
			return "%d of 2 big" % hand.count("+")
	return str(WORDS.get(locus, {}).get(hand, hand))

## Has Roslin read this creature's hand (session F's genotype test)? Then nothing about it is a `?`.
static func tested(data: GameStateData, c: Creature) -> bool:
	return c.uid != 0 and data.flag("stud_tested_%d" % c.uid) == true

## The two alleles a parent offers at a locus as the player knows them: a recessive hidden behind its dominant is `?`
## (Coat, Knack), and Tint on a plain coat is two question marks. Ginger is not squared.
static func axis(c: Creature, locus: String, known: bool) -> Array:
	var gl := genome_locus(locus)
	var g := Genetics.genome_of(c)
	var hand: Array = g[gl].duplicate()
	if not known:
		return hand
	var alleles: Array = Genetics.LOCI[gl]
	if gl == "tint" and g.coat != ["c", "c"]:
		return ["?", "?"]
	if (gl == "coat" or gl == "knack") and alleles[0] in hand:
		return [alleles[0], "?"]
	return hand

## [{genotype, p, min, max, word}] for the locus (the square's odds), or [] for a locus that has none.
static func odds(sire: Creature, dam: Creature, locus: String, known: bool) -> Array:
	var rows := Genetics.punnett(sire, dam, genome_locus(locus), known)
	for r in rows:
		r["word"] = outcome_word(locus, str(r.genotype))
	return rows

static func _sum(rows: Array, pick: Callable, field: String) -> float:
	var t := 0.0
	for r in rows:
		if pick.call(r):
			t += float(r[field])
	return t

static func _bounds(rows: Array, pick: Callable) -> Array:
	return [_sum(rows, pick, "min"), _sum(rows, pick, "max")]

## The chance of a goal as {p, min, max} (p the middle of the range); the bounds hold whatever the unknowns turn out to be.
static func goal_odds(sire: Creature, dam: Creature, goal: String, known: bool) -> Dictionary:
	var lo := 0.0
	var hi := 0.0
	match goal:
		"coat":
			var b := _bounds(odds(sire, dam, "coat", known), func(r): return r.genotype == "cc")
			lo = b[0]
			hi = b[1]
		"roan":
			var c := _bounds(odds(sire, dam, "coat", known), func(r): return r.genotype == "cc")
			var t := _bounds(odds(sire, dam, "tint", known), func(r): return str(r.genotype)[0] != str(r.genotype)[1])
			lo = c[0] * t[0]
			hi = c[1] * t[1]
		"mark":
			var b := _bounds(odds(sire, dam, "mark", known), func(r): return r.genotype == "BB")
			lo = b[0]
			hi = b[1]
		"knack":
			var b := _bounds(odds(sire, dam, "knack", known), func(r): return r.genotype == "kk")
			lo = b[0]
			hi = b[1]
		"frame":
			var dist := {0: 1.0}
			for f in Genetics.FRAME:
				var nxt := {}
				for r in Genetics.punnett(sire, dam, f, false):
					for k in dist:
						var n: int = int(k) + str(r.genotype).count("+")
						nxt[n] = float(nxt.get(n, 0.0)) + float(dist[k]) * float(r.p)
				dist = nxt
			for k in dist:
				if int(k) >= 6:
					lo += float(dist[k])
			hi = lo
	return {"p": (lo + hi) / 2.0, "min": lo, "max": hi}

## "1 in 4", or "none to 1 in 4" when the unknowns leave it open.
static func odds_text(o: Dictionary) -> String:
	if absf(float(o.max) - float(o.min)) < 0.0005:
		return StudBook.odds_words(float(o.p))
	return "%s to %s" % [StudBook.odds_words(float(o.min)) if float(o.min) > 0.0 else "none", StudBook.odds_words(float(o.max))]

## A chip that keeps its case: alleles are case-sensitive (B and b are different makings), which UIKit.chip would upper-case.
static func allele_chip(text: String, bg: Color, size := 22) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UIKit.box(bg, bg.darkened(0.35), 2, 10, 5))
	var l := UIKit.label(text, size, UIKit.CREAM)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p

static func _col(locus: String, hand: String) -> Color:
	var w := outcome_word(locus, hand)
	if w.contains("roan") or w == "coloured" or w == "the second knack" or w == "bold":
		return Color("7a5a8f")
	if w.contains("carries") or w == "medium":
		return Color("5a6f8f")
	return Color("3a4560")

## Draws the square for `locus` for these two, then the odds, then the chosen goal's chance, into `into`.
static func build(into: VBoxContainer, data: GameStateData, sire: Creature, dam: Creature, locus: String, goal: String) -> void:
	UIKit.clear(into)
	var known := not (tested(data, sire) and tested(data, dam))
	var head := HBoxContainer.new()
	head.add_child(UIKit.label("%s" % locus_name(locus), 30, UIKit.GOLD))
	head.add_child(UIKit.fill())
	head.add_child(UIKit.label("< Left   Right >", 20, UIKit.MUTED))
	into.add_child(head)
	var sa := axis(sire, locus, known)
	var da := axis(dam, locus, known)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	into.add_child(grid)
	grid.add_child(UIKit.label("", 22))
	for a in sa:
		grid.add_child(UIKit.label("%s %s" % ["Sire", a], 22, UIKit.MUTED))
	for y in da:
		grid.add_child(UIKit.label("Dam %s" % y, 22, UIKit.MUTED))
		for x in sa:
			var cell: Control
			if x == "?" or y == "?":
				cell = allele_chip("%s%s" % [x, y], Color("2c3446"), 24)
			else:
				var key := Genetics.hand_key(genome_locus(locus), [x, y])
				cell = allele_chip(key, _col(locus, key), 24)
			grid.add_child(cell)
	for r in odds(sire, dam, locus, known):
		var line := "%s  %s: %s" % [r.genotype, r.word, odds_text(r)]
		into.add_child(UIKit.label(line, 22))
	if locus == "mark" or locus == "knack":
		var link := UIKit.label("Mark and Knack travel together. They part company about 15 times in 100.", 18, UIKit.MUTED)
		link.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		into.add_child(link)
	if locus == "frame":
		var fr := UIKit.label("Four Frame makings act alike; this is one of them.", 18, UIKit.MUTED)
		fr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		into.add_child(fr)
	into.add_child(UIKit.spacer(6))
	var g := {}
	for x in GOALS:
		if x.id == goal:
			g = x
	var o := goal_odds(sire, dam, goal, known)
	into.add_child(UIKit.label("What you're after (Up/Down)", 20, UIKit.MUTED))
	into.add_child(UIKit.label("%s: %s" % [g.name, odds_text(o)], 26, UIKit.CREAM))
	if known:
		var q := UIKit.label("Shown as a range where a `?` hides what a creature might carry. A test cross tells you.", 18, UIKit.MUTED)
		q.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		into.add_child(q)
