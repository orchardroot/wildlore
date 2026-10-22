extends MenuBase
## The Timeline of Invention (Isles of Invention, 4.5): every era in order, its inventions and discoveries by year
## (found ones in full, the rest as a hint of where to look), and the era's gadget at the foot of each era. The right
## panel tells the focused row's story, what it cost and what it made; on a gadget row, confirm uses it and the panel
## shows what it says. Opened from the Almanac as "invention". See Invention and Gadgets.

const PANEL := Color("1d2230f0")
const BRASS := Color("c9a25a")
const ROW_H := 40

var _scroll: ScrollContainer
var _list_col: VBoxContainer
var _detail: VBoxContainer
var _buttons: Array = []
var _rows: Array = []     # [{kind: "entry"|"gadget", ...}]
var _at := 0
var _said: Dictionary = {}   # gadget id -> the lines it last gave (this visit)

func _build() -> void:
	set_title("Timeline of Invention")
	var d: GameStateData = Game.data
	header_right.text = "%d of %d found" % [Invention.found_count(d), Invention.entries().size()]
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var lp := UIKit.panel(PANEL, 12)
	lp.custom_minimum_size = Vector2(520, 0)
	row.add_child(lp)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.follow_focus = true
	lp.add_child(_scroll)
	_list_col = VBoxContainer.new()
	_list_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_col.add_theme_constant_override("separation", 3)
	_scroll.add_child(_list_col)
	var dp := UIKit.panel(PANEL, 18)
	dp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(dp)
	_detail = VBoxContainer.new()
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.add_theme_constant_override("separation", 10)
	dp.add_child(_detail)
	_fill()

## setup("gadget:<id>") opens with that gadget's row focused (screenshots and the dev menu).
func setup(arg: String) -> void:
	if arg.begins_with("gadget:"):
		for i in _rows.size():
			if _rows[i].kind == "gadget" and str(_rows[i].era.gadget.id) == arg.substr(7):
				_at = i
		if _at < _buttons.size():
			UIKit.focus_later(_buttons[_at])
			_scroll_to_later(_buttons[_at])
			_show(_at)

## follow_focus can't scroll before the list has been laid out, so opening deep in the list scrolls once it has.
func _scroll_to_later(b: Control) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(b) and b.is_inside_tree():
		_scroll.ensure_control_visible(b)

func _fill() -> void:
	var d: GameStateData = Game.data
	UIKit.clear(_list_col)
	_buttons.clear()
	_rows.clear()
	for er in Invention.eras():
		var head := HBoxContainer.new()
		var hl := UIKit.label(str(er.name), 19, UIKit.MUTED)
		hl.uppercase = true
		head.add_child(hl)
		head.add_child(UIKit.fill())
		head.add_child(UIKit.label("%d / %d" % [Invention.era_found(d, str(er.id)), Invention.era_entries(str(er.id)).size()], 19, UIKit.MUTED))
		if not _rows.is_empty():
			_list_col.add_child(UIKit.spacer(6))
		_list_col.add_child(head)
		for e in Invention.era_entries(str(er.id)):
			_rows.append({"kind": "entry", "entry": e, "era": er})
			_list_col.add_child(_entry_button(_rows.size() - 1))
		_rows.append({"kind": "gadget", "era": er})
		_list_col.add_child(_gadget_button(_rows.size() - 1))
	UIKit.wrap_focus(_buttons)
	_at = clampi(_at, 0, _buttons.size() - 1)
	UIKit.focus_later(_buttons[_at])
	_show(_at)
	set_hints([["updown", "Browse"], ["confirm", "Use gadget"], ["cancel", "Back"]])

func _row_button(i: int) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, ROW_H)
	b.focus_neighbor_left = NodePath(".")
	b.focus_neighbor_right = NodePath(".")
	b.focus_entered.connect(func():
		Audio.sfx("cursor")
		_at = i
		_show(i))
	b.pressed.connect(func(): _press(i))
	_buttons.append(b)
	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 12
	h.offset_right = -12
	h.add_theme_constant_override("separation", 14)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(h)
	return b

func _entry_button(i: int) -> Button:
	var e: Dictionary = _rows[i].entry
	var have := Invention.found(Game.data, e)
	var b := _row_button(i)
	var h: HBoxContainer = b.get_child(0)
	var y := UIKit.label(Invention.year_text(e), 21, UIKit.GOLD if have else UIKit.MUTED)
	y.custom_minimum_size.x = 60
	h.add_child(y)
	var t := UIKit.label(str(e.title) if have else "Not yet found", 21, UIKit.CREAM if have else UIKit.MUTED)
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	t.clip_text = true
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(t)
	for c in h.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

func _gadget_button(i: int) -> Button:
	var er: Dictionary = _rows[i].era
	var open := Invention.gadget_open(Game.data, str(er.id))
	var b := _row_button(i)
	var h: HBoxContainer = b.get_child(0)
	var dot := ColorRect.new()
	dot.custom_minimum_size = Vector2(14, 14)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.color = BRASS if open else Color("454d63")
	h.add_child(dot)
	var t := UIKit.label(str(er.gadget.name) if open else "Gadget: find %d to unlock" % int(er.need), 20, BRASS if open else UIKit.MUTED)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(t)
	for c in h.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

func _para(text: String, size: int, colour: Color) -> Label:
	var l := UIKit.label(text, size, colour)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func _show(i: int) -> void:
	if i < 0 or i >= _rows.size():
		return
	UIKit.clear(_detail)
	var r: Dictionary = _rows[i]
	var er: Dictionary = r.era
	if r.kind == "entry":
		var e: Dictionary = r.entry
		if Invention.found(Game.data, e):
			_detail.add_child(UIKit.label(Invention.year_text(e), 40, UIKit.GOLD))
			_detail.add_child(_para(str(e.title), 30, UIKit.CREAM))
			_detail.add_child(_para(str(e.text), 21, UIKit.CREAM))
			if str(e.get("cost", "")) != "":
				_detail.add_child(_para("What it cost, what it made: " + str(e.cost), 19, BRASS))
		else:
			_detail.add_child(UIKit.label(Invention.year_text(e), 40, UIKit.MUTED))
			_detail.add_child(_para("Not yet found.", 28, UIKit.MUTED))
			_detail.add_child(_para("Where to look: " + str(e.where) + ".", 21, UIKit.CREAM))
	else:
		var g: Dictionary = er.gadget
		var open := Invention.gadget_open(Game.data, str(er.id))
		_detail.add_child(_para(str(g.name), 32, BRASS if open else UIKit.MUTED))
		_detail.add_child(_para(str(g.text), 21, UIKit.CREAM))
		if not open:
			var left := int(er.need) - Invention.era_found(Game.data, str(er.id))
			_detail.add_child(_para("Find %d more from %s to unlock it." % [left, str(er.name)], 20, UIKit.MUTED))
		elif _said.has(str(g.id)):
			for line in _said[str(g.id)]:
				_detail.add_child(_para(str(line), 20, UIKit.GOLD))
		else:
			_detail.add_child(_para("Press confirm to use it.", 20, UIKit.MUTED))
	_detail.add_child(UIKit.spacer(4))
	var cost := _para("%s (%s): %s" % [str(er.name), str(er.years), str(er.cost)], 18, UIKit.MUTED)
	_detail.add_child(cost)

func _press(i: int) -> void:
	var r: Dictionary = _rows[i]
	if r.kind != "gadget" or not Invention.gadget_open(Game.data, str(r.era.id)):
		Audio.sfx("bump")
		return
	Audio.sfx("confirm")
	var id := str(r.era.gadget.id)
	var lines: Array = await _use(id)
	if not lines.is_empty():
		_said[id] = lines
	_show(i)
	UIKit.focus_later(_buttons[i])

## What a gadget does now; [] when it opened another screen and has nothing to add.
func _use(id: String) -> Array:
	var d: GameStateData = Game.data
	var idx := ZoneIndex.get_index()
	var name_of := func(s: String) -> String: return str(Game.dex.get_species(s).get("name", s)) if Game.dex.has(s) else s
	match id:
		"steam_whistle":
			return [str(Gadgets.whistle(d).text)]
		"telegraph":
			await open_child("bureau:" + Wallet.local(d))
			return ["The wire is sent. STOP. Money where you need it. STOP."]
		"wireless":
			var actual := Forecast.current_weather()
			var left := d.weather_until - d.world_minutes() if d.weather != "" else -1
			var pos := Gadgets.map_pos(str(d.zone_id), idx)
			var near := Gadgets.nearest_areas(pos, Forecast.AREAS, idx, 1) if pos.x >= 0 else []
			var outlook := Forecast.outlook(actual, left, Forecast.area_table(str(near[0])) if not near.is_empty() else {})
			return Gadgets.wireless_lines(pos, actual, d.day_count, idx, func(a: String) -> Dictionary: return Forecast.area_table(a), outlook)
		"reckoner":
			return Gadgets.reckoner_lines(str(d.zone_id), d.pos, Gazetteer.all(), func(p: String) -> bool: return Gazetteer.is_read(d, p), idx.get("room_town", {}))
		"web":
			return Gadgets.web_lines(d, Game.dex.core_ids(), idx, name_of)
		"field_guide":
			var z := ZoneData.load_id(str(d.zone_id))
			var phase := GameClock.phase(Timezones.local_minutes(d, d.tz_zone))
			var cands := []
			if z != null:
				for kind in ["grass", "water"]:
					cands.append_array(Encounters.candidates(z, kind, phase, Forecast.current_weather(), d.flags))
			return Gadgets.guide(d, cands, name_of).lines
	return []
