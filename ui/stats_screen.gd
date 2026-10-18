extends MenuBase
## Trainer stats: the lifetime tallies (steps, wins, catches, journeys, money, a few daft ones). See TrainerStats.

const ONE_COLUMN := 12  # rows that fit in one column
const DAFT_ONES := 9     # the first of the daft ones (cups of tea and so on)

func _build() -> void:
	set_title("Stats")
	header_right.text = Game.data.player_name
	set_hints([["cancel", "Back"]])
	var card := UIKit.panel(Color("1d2230f0"), 14)
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_child(card)
	# one column while it fits; past ONE_COLUMN rows (the County Shows and anything after), two side by side:
	# the journey on the left, the daft ones and the rest on the right
	var rows := TrainerStats.lines(Game.data)
	var two := rows.size() > ONE_COLUMN
	var split := DAFT_ONES if two else rows.size()
	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 40)
	card.add_child(cols)
	var col: VBoxContainer = null
	for i in rows.size():
		if i == 0 or i == split:
			col = VBoxContainer.new()
			col.add_theme_constant_override("separation", 4)
			col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cols.add_child(col)
		elif i == 1 or i == DAFT_ONES:  # a little gap before the walking and before the daft ones
			col.add_child(UIKit.spacer(4))
		var h := HBoxContainer.new()
		h.add_child(UIKit.label(rows[i][0], 24 if two else 26, UIKit.MUTED))
		h.add_child(UIKit.fill())
		h.add_child(UIKit.label(rows[i][1], 26 if two else 28, UIKit.GOLD if i == 0 else UIKit.CREAM))
		col.add_child(h)
