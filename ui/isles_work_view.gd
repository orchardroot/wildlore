class_name IslesWorkView
extends RefCounted
## The Gazetteer's "How these isles work" page (see IslesWork): the summary shown beside its row in the list of
## places, and one topic as a card, its lines once you've heard them from someone, or a hint at who to ask.
## GazetteerTab builds the list rows; this fills the detail panel.

const NAME := "How these isles work"
const CARD := Color("26334a")
const EDGE := Color("7f93b8")

## Beside the row: what the page is and how far you've got.
static func summary(detail: VBoxContainer, d: GameStateData) -> void:
	var name := UIKit.label(NAME, 34)
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(name)
	detail.add_child(UIKit.label(IslesWork.progress_line(d), 20, UIKit.MUTED))
	detail.add_child(UIKit.spacer(2))
	var about := UIKit.label("The UK, Great Britain and Ireland, devolution, the border, Brexit, the Crown Dependencies, the Overseas Territories and the Commonwealth, as the people who live with them explain it.", 21)
	about.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(about)
	var tip := UIKit.label("Talk to people in parliaments, town halls, ferry terminals and on the border road. Open the page to read what you've learnt.", 19, UIKit.MUTED)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_child(UIKit.spacer(4))
	detail.add_child(tip)

## One topic: a card of short lines once learnt; otherwise who knows about it.
static func topic(detail: VBoxContainer, d: GameStateData, t: Dictionary) -> void:
	if not IslesWork.is_learnt(d, t):
		detail.add_child(UIKit.label("Not yet learnt", 32, UIKit.MUTED))
		var l := UIKit.label("Somebody can explain this. Try: %s" % str(t.get("where", "")), 22)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail.add_child(l)
		return
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UIKit.box(CARD, EDGE, 2, 10, 12))
	detail.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	card.add_child(col)
	var title := UIKit.label(str(t.title), 25, UIKit.GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(title)
	for line in t.get("lines", []):
		var l := UIKit.label(str(line), 18, UIKit.CREAM)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		col.add_child(l)
	var w := UIKit.label("Heard from: " + str(t.get("where", "")), 16, UIKit.MUTED)
	w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(w)
