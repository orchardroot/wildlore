class_name GenomePage
extends RefCounted
## The summary screen's genome page (design section 6): seven rows of allele chips with the showing in words, Frame as
## eight pips, and a "Tested" stamp once Roslin has read the creature. Hidden recessives show as `?` until tested,
## because a plain coat could be carrying one. Static and pure apart from building controls.

const ROWS := ["coat", "tint", "mark", "knack", "ginger", "frame"]
const NAMES := {"coat": "Coat", "tint": "Tint", "mark": "Mark", "knack": "Knack", "ginger": "Ginger", "frame": "Frame"}

## The alleles to show for a row ("?" for what is not known).
static func alleles(data: GameStateData, c: Creature, row: String) -> Array:
	var known := PunnettView.tested(data, c)
	if row == "ginger":
		return Genetics.genome_of(c)["ginger"].duplicate()
	if row == "frame":
		return []
	return PunnettView.axis(c, row, not known)

## What the row shows, in words.
static func showing_words(c: Creature, row: String, tested := false) -> String:
	var sh := Genetics.showing(c)
	var g := Genetics.genome_of(c)
	match row:
		"coat":
			if sh.variant != "":
				return "wears a %s coat" % sh.variant.replace("+", " and ")
			return "carries a coloured coat" if tested and "c" in g.coat else "plain"
		"tint":
			if sh.variant == "":
				return "not read on a plain coat"
			return "a roan, both tints showing" if sh.variant.contains("+") else "one tint, both copies"
		"mark":
			return ["faint markings", "medium markings", "bold markings"][clampi(int(sh.mark), 0, 2)]
		"knack":
			return {"first": "the line's knack", "second": "the line's second knack", "fault": "a weak spot"}.get(sh.knack, "")
		"ginger":
			if sh.tortie:
				return "tortoiseshell"
			return "a warm hue" if sh.hue > 0.0 else "none"
		"frame":
			var f := int(sh.frame)
			return "small" if f <= 2 else ("big" if f >= 6 else "middling")
	return ""

static func build(data: GameStateData, c: Creature) -> Control:
	var p := UIKit.panel(Color("1d2230f0"), 18)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var head := HBoxContainer.new()
	head.add_child(UIKit.label("Makings", 26, UIKit.MUTED))
	head.add_child(UIKit.fill())
	var tested := PunnettView.tested(data, c)
	if tested:
		head.add_child(UIKit.chip("TESTED", UIKit.GOLD.darkened(0.25), UIKit.SLATE, 18))
	var sx: String = {"m": "Male", "f": "Female"}.get(c.sex, "No sex")
	head.add_child(UIKit.label("  " + sx, 22, UIKit.CREAM))
	v.add_child(head)
	for row in ROWS:
		var h := HBoxContainer.new()
		h.add_theme_constant_override("separation", 12)
		var nm := UIKit.label(NAMES[row], 24, UIKit.CREAM)
		nm.custom_minimum_size = Vector2(110, 0)
		h.add_child(nm)
		if row == "frame":
			var pips := HBoxContainer.new()
			pips.add_theme_constant_override("separation", 4)
			var n := int(Genetics.showing(c).frame)
			for i in 8:
				var dot := ColorRect.new()
				dot.custom_minimum_size = Vector2(18, 18)
				dot.color = UIKit.GOLD if i < n else Color("2c3446")
				pips.add_child(dot)
			h.add_child(pips)
		else:
			var chips := HBoxContainer.new()
			chips.custom_minimum_size = Vector2(120, 0)
			chips.add_theme_constant_override("separation", 6)
			for a in alleles(data, c, row):
				chips.add_child(PunnettView.allele_chip(str(a), Color("2c3446") if a == "?" else Color("3a4560")))
			h.add_child(chips)
		var w := UIKit.label(showing_words(c, row, tested), 20, Color("d8cfb4"))
		w.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		w.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_child(w)
		v.add_child(h)
	var kind := Genetics.kindred_of(c)
	var foot := "Wild-caught: no pedigree." if c.pedigree.is_empty() else "Bred: its pedigree is on record."
	if not Genetics.breeds(kind):
		foot = "This kind doesn't breed."
	var f := UIKit.label(foot, 18, UIKit.MUTED)
	f.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(f)
	return p
