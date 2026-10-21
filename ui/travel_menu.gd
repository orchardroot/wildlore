extends MenuBase
## Rail fast travel: pick a visited station. setup("rail"). Closes with the town id, or null.

var _list: VBoxContainer

func _build() -> void:
	set_title("Where to?")
	set_hints([["confirm", "Buy a ticket (free with your pass)"], ["cancel", "Back"]])
	var p := UIKit.panel(Color("1d2230f0"), 14)
	p.set_anchors_preset(Control.PRESET_TOP_WIDE)
	content.add_child(p)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	p.add_child(_list)

func setup(arg: String) -> void:
	if arg == "overseas":
		_setup_departures()
		return
	var flying := arg == "fly"
	var here := str(Game.data.flag("last_town")) if Game.data.flag("last_town") else ""
	header_right.text = "Bran's Raven is waiting" if flying else ("Departing " + Travel.town_name(here) if here != "" else "")
	if flying:
		set_title("Fly where?")
		set_hints([["confirm", "Fly there"], ["cancel", "Back"]])
		here = ""
		if Router.overworld and is_instance_valid(Router.overworld) and Router.overworld.get("zone") != null:
			here = Router.overworld.zone.town_id
	var buttons := []
	for town in (Travel.fly_destinations(Game.data, here) if flying else Travel.rail_destinations(Game.data, here)):
		var b := make_button("  " + Travel.town_name(town), func(): close(town))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 64)
		b.add_theme_font_size_override("font_size", 30)
		_list.add_child(b)
		buttons.append(b)
	if buttons.is_empty():
		var none := Travel.rail_empty_text(Game.data, here, flying)
		_list.add_child(UIKit.label(none, 26, UIKit.MUTED))
		return
	UIKit.wrap_focus(buttons)
	UIKit.focus_later(buttons[0])

## RAF Brize Norton's departures board: every registry territory whose unlock flag is set. Closes with its id.
func _setup_departures() -> void:
	set_title("Departures")
	header_right.text = "RAF Brize Norton"
	set_hints([["confirm", "Board"], ["cancel", "Back"]])
	var buttons := []
	var blurb := UIKit.label("", 24, UIKit.MUTED)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for e in Overseas.available(Game.data):
		var how := "ferry via " + Travel.town_name(str(e.get("port", ""))) if Overseas.is_ferry(e) else "RAF"
		var b := make_button("  %s   (%s)" % [str(e.name), how], func(): close(str(e.id)))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.custom_minimum_size = Vector2(0, 64)
		b.add_theme_font_size_override("font_size", 28)
		b.focus_entered.connect(func(): blurb.text = str(e.get("blurb", "")))
		_list.add_child(b)
		buttons.append(b)
	if buttons.is_empty():
		_list.add_child(UIKit.label("Nothing on the board yet. Come back with some paperwork.", 26, UIKit.MUTED))
		return
	_list.add_child(blurb)
	UIKit.wrap_focus(buttons)
	UIKit.focus_later(buttons[0])
