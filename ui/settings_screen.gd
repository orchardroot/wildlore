extends MenuBase
## Settings: text speed, battle speed, quality, volumes, accessibility switches and a Controls page. Left/right changes a row; every change is saved at once.

const SPEEDS := ["slow", "normal", "fast", "instant"]
const BATTLE_SPEEDS := ["normal", "fast", "fastest"]
const QUALITIES := ["low", "medium", "high"]
const SAMPLE := "Oi. That's my sandwich. Also, welcome to Cheshire."

var _rows: Array = []        # {key, button, value_label}
var _preview: Label
var _chips: HFlowContainer
var _t := 0.0

func _build() -> void:
	set_title("Settings")
	set_hint("Left / Right  Change        Z  Select        X  Back")
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 16)
	content.add_child(col)
	var p := UIKit.panel(Color("1d2230f0"), 14)
	col.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 5)
	p.add_child(v)
	var buttons := []
	for def in [["text_speed", "Text speed"], ["battle_speed", "Battle speed"], ["quality", "Graphics quality"], ["music_volume", "Music volume"], ["sfx_volume", "Effects volume"], ["run_mode", "Run key"], ["colour_blind", "Colour-blind friendly"], ["reduce_flashing", "Reduce flashing"]]:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 42)
		UIKit.compact(b, 4)
		var h := HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.offset_left = 18
		h.offset_right = -18
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var k := UIKit.label(def[1], 28)
		h.add_child(k)
		h.add_child(UIKit.fill())
		var bar: ProgressBar = null
		if def[0].ends_with("volume"):
			bar = ProgressBar.new()
			bar.show_percentage = false
			bar.max_value = 1.0
			bar.custom_minimum_size = Vector2(260, 16)
			bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			bar.add_theme_stylebox_override("fill", UIKit.box(UIKit.HEATHER, Color(0, 0, 0, 0), 0, 3, 0))
			h.add_child(bar)
		var val := UIKit.label("", 28, UIKit.GOLD)
		val.custom_minimum_size = Vector2(190, 0)
		val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(val)
		for c in h.get_children():
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(h)
		var key: String = def[0]
		b.focus_entered.connect(func(): Audio.sfx("cursor"))
		b.pressed.connect(func():
			_change(key, 1)
			Audio.sfx("confirm"))
		b.focus_neighbor_left = NodePath(".")
		b.focus_neighbor_right = NodePath(".")
		v.add_child(b)
		buttons.append(b)
		_rows.append({"key": key, "button": b, "value": val, "bar": bar})
	var controls := make_button("Controls...", func(): await open_child("controls"))
	controls.focus_neighbor_left = NodePath(".")
	controls.focus_neighbor_right = NodePath(".")
	UIKit.compact(controls, 4)
	controls.custom_minimum_size.y = 42
	v.add_child(controls)
	buttons.append(controls)
	var back := make_button("Back", func(): close(null))
	UIKit.compact(back, 4)
	back.custom_minimum_size.y = 42
	back.focus_neighbor_left = NodePath(".")
	back.focus_neighbor_right = NodePath(".")
	v.add_child(back)
	buttons.append(back)
	UIKit.wrap_focus(buttons)
	var pp := UIKit.panel(Color("14182199"), 14)
	col.add_child(pp)
	var pv := VBoxContainer.new()
	pp.add_child(pv)
	var ph := HBoxContainer.new()
	ph.add_theme_constant_override("separation", 20)
	pv.add_child(ph)
	_preview = UIKit.label(SAMPLE, 24)
	_preview.custom_minimum_size = Vector2(520, 0)
	_preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ph.add_child(_preview)
	_chips = HFlowContainer.new()
	_chips.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chips.add_theme_constant_override("h_separation", 6)
	_chips.add_theme_constant_override("v_separation", 6)
	ph.add_child(_chips)
	for r in _rows:
		_paint_row(r)
	UIKit.focus_later(buttons[0])

func _process(delta: float) -> void:
	_t += delta
	var cps := Settings.chars_per_second()
	var n := SAMPLE.length()
	var total := n / cps + 1.2  # type it out, then hold a moment
	if _t > total:
		_t = 0.0
	_preview.visible_characters = mini(n, int(_t * cps))

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	var d := 0
	if event.is_action_pressed("move_left"):
		d = -1
	elif event.is_action_pressed("move_right"):
		d = 1
	if d != 0:
		var f := get_viewport().gui_get_focus_owner()
		for r in _rows:
			if r.button == f:
				get_viewport().set_input_as_handled()
				_change(r.key, d)
				return
	super._input(event)

func _change(key: String, d: int) -> void:
	match key:
		"text_speed":
			Settings.text_speed = SPEEDS[MenuLogic.wrap_index(maxi(0, SPEEDS.find(Settings.text_speed)), d, SPEEDS.size())]
			_t = 0.0
		"battle_speed":
			Settings.battle_speed = BATTLE_SPEEDS[MenuLogic.wrap_index(maxi(0, BATTLE_SPEEDS.find(Settings.battle_speed)), d, BATTLE_SPEEDS.size())]
		"quality":
			Settings.quality = QUALITIES[MenuLogic.wrap_index(maxi(0, QUALITIES.find(Settings.quality)), d, QUALITIES.size())]
		"music_volume":
			Settings.music_volume = clampf(snappedf(Settings.music_volume + 0.1 * d, 0.1), 0.0, 1.0)
		"sfx_volume":
			Settings.sfx_volume = clampf(snappedf(Settings.sfx_volume + 0.1 * d, 0.1), 0.0, 1.0)
		"run_mode":
			Settings.run_mode = "toggle" if Settings.run_mode == "hold" else "hold"
		"colour_blind":
			Settings.colour_blind = not Settings.colour_blind
		"reduce_flashing":
			Settings.reduce_flashing = not Settings.reduce_flashing
	Settings.save_settings()
	if key == "sfx_volume":
		Audio.sfx("cursor")
	for r in _rows:
		if r.key == key:
			_paint_row(r)

func _paint_row(r: Dictionary) -> void:
	var l: Label = r.value
	match r.key:
		"text_speed":
			l.text = "<  %s  >" % Settings.text_speed.capitalize()
		"battle_speed":
			l.text = "<  %s  >" % Settings.battle_speed.capitalize()
		"quality":
			l.text = "<  %s  >" % Settings.quality.capitalize()
		"music_volume":
			l.text = _pct(Settings.music_volume)
			r.bar.value = Settings.music_volume
		"sfx_volume":
			l.text = _pct(Settings.sfx_volume)
			r.bar.value = Settings.sfx_volume
		"run_mode":
			l.text = "<  %s  >" % ("Press to toggle" if Settings.run_mode == "toggle" else "Hold")
		"colour_blind":
			l.text = "<  %s  >" % ("On" if Settings.colour_blind else "Off")
			_fill_chips()
		"reduce_flashing":
			l.text = "<  %s  >" % ("On" if Settings.reduce_flashing else "Off")

func _pct(v: float) -> String:
	return "<  %d%%  >" % (roundi(v * 10.0) * 10)

## Every type chip in the current palette, so the colour-blind switch shows what it does.
func _fill_chips() -> void:
	UIKit.clear(_chips)
	for t in TypeColours.COLOURS:
		_chips.add_child(UIKit.type_chip(t, 13))
