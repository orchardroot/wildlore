extends MenuBase
## Rail fast travel: pick a visited station. setup("rail"). Closes with the town id, or null.

var _list: VBoxContainer

func _build() -> void:
	set_title("Where to?")
	set_hint("Z  Buy a ticket (free with your pass)        X  Back")
	var p := UIKit.panel(Color("1d2230f0"), 14)
	p.set_anchors_preset(Control.PRESET_TOP_WIDE)
	content.add_child(p)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	p.add_child(_list)

func setup(_arg: String) -> void:
	var here := str(Game.data.flag("last_town")) if Game.data.flag("last_town") else ""
	header_right.text = "Departing " + Travel.town_name(here) if here != "" else ""
	var buttons := []
	for town in Travel.rail_destinations(Game.data, here):
		var b := make_button("  " + Travel.town_name(town), func(): close(town))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 64)
		b.add_theme_font_size_override("font_size", 30)
		_list.add_child(b)
		buttons.append(b)
	if buttons.is_empty():
		_list.add_child(UIKit.label("No other stations visited yet. Trains only go where you've been.", 26, UIKit.MUTED))
		return
	UIKit.wrap_focus(buttons)
	UIKit.focus_later(buttons[0])
