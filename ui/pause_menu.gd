extends MenuBase
## Pause menu: Team, Fieldbook, Bag, Save, Settings, Close, with the trainer card beside it.

var _buttons: Array = []
var _info: VBoxContainer
var _note: Label

func _build() -> void:
	set_title("Pause")
	header_right.text = Game.data.player_name
	set_hint("Z  Choose        X  Close")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 28)
	content.add_child(row)

	var left := UIKit.panel(Color("1d2230f0"), 14)
	left.custom_minimum_size = Vector2(380, 0)
	row.add_child(left)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 8)
	left.add_child(menu)
	var entries := [["Team", _open_team], ["Fieldbook", _open_pedia], ["Bag", _open_bag],
		["Save", _save], ["Settings", _open_settings], ["Close", func(): close(null)]]
	for e in entries:
		var b := make_button(e[0], e[1])
		b.add_theme_font_size_override("font_size", 32)
		b.custom_minimum_size = Vector2(0, 66)
		menu.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 16)
	row.add_child(right)
	var card := UIKit.panel(Color("1d2230f0"), 22)
	right.add_child(card)
	_info = VBoxContainer.new()
	_info.add_theme_constant_override("separation", 12)
	card.add_child(_info)
	_note = UIKit.label("", 26, UIKit.GOLD)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.add_child(_note)
	_refresh()
	_buttons[0].grab_focus.call_deferred()

func _refresh() -> void:
	UIKit.clear(_info)
	var d: GameStateData = Game.data
	_info.add_child(UIKit.label("Trainer card", 22, UIKit.MUTED))
	_info.add_child(UIKit.label(d.player_name, 44))
	_info.add_child(_stat("Money", UIKit.money_text(d.money)))
	_info.add_child(_stat("Play time", MenuLogic.play_time(d.play_seconds)))
	_info.add_child(_stat("Fieldbook", "%d seen, %d caught" % [d.seen.size(), d.caught.size()]))
	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 8)
	badges.add_child(UIKit.label("Badges", 28, UIKit.MUTED))
	badges.add_child(UIKit.spacer(0, 8))
	for i in 8:
		var earned := i < d.badges.size()
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(28, 28)
		dot.color = UIKit.GOLD if earned else Color("2c3446")
		badges.add_child(dot)
	badges.add_child(UIKit.label("%d / 8" % d.badges.size(), 26))
	_info.add_child(badges)
	_info.add_child(UIKit.spacer(8))
	var team := HBoxContainer.new()
	team.add_theme_constant_override("separation", 6)
	for c in d.party:
		var s := AnimSprite.new()
		s.show_species(c.species.id, "icon", 2)
		if c.is_fainted():
			s.modulate = Color(0.5, 0.5, 0.5)
		team.add_child(s)
	_info.add_child(team)

func _stat(k: String, v: String) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_child(UIKit.label(k, 28, UIKit.MUTED))
	h.add_child(UIKit.fill())
	h.add_child(UIKit.label(v, 30))
	return h

func _open_team() -> void:
	await open_child("party")
	_after_child(0)

func _open_pedia() -> void:
	await open_child("pedia")
	_after_child(1)

func _open_bag() -> void:
	await open_child("bag")
	_after_child(2)

func _open_settings() -> void:
	await open_child("settings")
	_after_child(4)

func _after_child(i: int) -> void:
	_refresh()
	_buttons[i].grab_focus()

func _save() -> void:
	var err := Game.save("auto")
	_note.text = "Saved. Your progress is safe as houses." if err == OK else "That didn't save. Check the disk has room."
	Audio.sfx("heal" if err == OK else "bump")
