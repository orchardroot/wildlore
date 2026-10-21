class_name TradesPanel
extends RefCounted
## The Stats page's third card: the six Trades with a title, a level pip row and what you've earned so far. See Trades.

static func build(d: GameStateData) -> PanelContainer:
	var card := UIKit.panel(Color("1d2230f0"), 14)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	card.add_child(col)
	for t in Trades.IDS:
		var lv := Trades.level(d, t)
		var h := HBoxContainer.new()
		h.add_child(UIKit.label(str(Trades.NAMES[t]), 24, UIKit.MUTED))
		h.add_child(UIKit.fill())
		h.add_child(UIKit.label("%s  %s" % [Trades.title(d, t), "●".repeat(lv) + "○".repeat(5 - lv)], 24, UIKit.GOLD if lv >= 4 else UIKit.CREAM))
		col.add_child(h)
		var detail := Trades.progress_text(d, t)
		var perks := Trades.perk_lines(d, t)
		if not perks.is_empty():
			detail += ". " + str(perks[perks.size() - 1])
		var l := UIKit.label(detail, 18, UIKit.MUTED)
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l.clip_text = true
		col.add_child(l)
	return card
