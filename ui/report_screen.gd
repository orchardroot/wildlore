extends MenuBase
## Settings > Report a bug: type a line or two, then open a pre-filled GitHub issue in the browser.

var _box: LineEdit

func _build() -> void:
	set_title("Report a bug")
	set_hints([["confirm", "Choose"], ["cancel", "Back"]])
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 12)
	content.add_child(col)
	var p := UIKit.panel(Color("1d2230f0"), 14)
	col.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	var intro := UIKit.label("Something broken, or a bit daft? Say what happened in a line or two. This opens a GitHub issue in your browser with the version, the place and your platform filled in. You'll need a free GitHub account to send it.", 24)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(intro)
	_box = LineEdit.new()
	_box.placeholder_text = "What happened?"
	_box.max_length = BugReport.MAX_TEXT
	_box.add_theme_font_size_override("font_size", 26)
	v.add_child(_box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	v.add_child(row)
	var go := make_button("Open GitHub", _send, 300)
	var back := make_button("Back", func(): close(null), 200)
	var btns := [go, back]
	for b in btns:
		row.add_child(b)
	UIKit.wrap_focus(btns)
	UIKit.focus_later(_box)

func _send() -> void:
	var zone: String = Game.data.zone_id if Game.data else "unknown"
	var v := str(ProjectSettings.get_setting("application/config/version"))
	OS.shell_open(BugReport.url(v, zone, OS.get_name(), _box.text))
	Audio.sfx("confirm")
