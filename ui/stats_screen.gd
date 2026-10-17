extends MenuBase
## Trainer stats: the lifetime tallies (steps, wins, catches, journeys, money, a few daft ones). See TrainerStats.

func _build() -> void:
	set_title("Stats")
	header_right.text = Game.data.player_name
	set_hints([["cancel", "Back"]])
	var card := UIKit.panel(Color("1d2230f0"), 14)
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)
	var rows := TrainerStats.lines(Game.data)
	for i in rows.size():
		if i == 1 or i == 9:  # a little gap before the walking and before the daft ones
			col.add_child(UIKit.spacer(4))
		var h := HBoxContainer.new()
		h.add_child(UIKit.label(rows[i][0], 26, UIKit.MUTED))
		h.add_child(UIKit.fill())
		h.add_child(UIKit.label(rows[i][1], 28, UIKit.GOLD if i == 0 else UIKit.CREAM))
		col.add_child(h)
