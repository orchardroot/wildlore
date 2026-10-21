extends MenuBase
## The pairing screen at the farm gate (design section 6): team and Ark in one list, pick two, read the farmer's
## verdict, Preview the Punnett square, Pair to start a basket (Breeding). Opened by the farm with `pairing`.

var _list: VBoxContainer
var _buttons: Array = []
var _cands: Array = []
var _a: Creature = null
var _b: Creature = null
var _right: VBoxContainer
var _bar: HBoxContainer
var _pair_btn: Button
var _preview_btn: Button
var _preview := false
var _locus := 0
var _goal := 0
var _msg := ""

func _build() -> void:
	set_title("Pairing")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 28)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 14)
	lp.custom_minimum_size = Vector2(520, 0)
	row.add_child(lp)
	var lcol := VBoxContainer.new()
	lp.add_child(lcol)
	lcol.add_child(UIKit.label("Your creatures", 24, UIKit.MUTED))
	var sc := ScrollContainer.new()
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	lcol.add_child(sc)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	sc.add_child(_list)
	var rp := UIKit.panel(Color("1d2230f0"), 18)
	rp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rp)
	var rcol := VBoxContainer.new()
	rcol.add_theme_constant_override("separation", 10)
	rp.add_child(rcol)
	_right = VBoxContainer.new()
	_right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_right.add_theme_constant_override("separation", 8)
	rcol.add_child(_right)
	_bar = HBoxContainer.new()
	_bar.add_theme_constant_override("separation", 12)
	rcol.add_child(_bar)
	_preview_btn = make_button("Preview", _toggle_preview, 150)
	_pair_btn = make_button("Pair", _pair, 150)
	_bar.add_child(_preview_btn)
	_bar.add_child(_pair_btn)
	_bar.add_child(make_button("Back", func(): close(null), 150))
	_fill_list()
	_refresh()

## `pairing:pick` or `pairing:preview` start with the first two creatures chosen (screenshots).
func setup(arg: String) -> void:
	if arg in ["pick", "preview"] and _cands.size() > 1:
		_a = _cands[0].c
		_b = _cands[1].c
		_preview = arg == "preview"
		_refresh()

func _fill_list() -> void:
	UIKit.clear(_list)
	_buttons.clear()
	_cands = PairingLogic.candidates(Game.data)
	if _cands.is_empty():
		_list.add_child(UIKit.label("Nothing here breeds yet. Fowl, scale, shell and wing, beast: the farm will take those.", 22, UIKit.MUTED))
		return
	for i in _cands.size():
		var b := make_button("", func(): _pick(i))
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var h := HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.offset_left = 10
		h.offset_right = -10
		h.add_theme_constant_override("separation", 10)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var c: Creature = _cands[i].c
		var sex := UIKit.chip(c.sex.to_upper() if c.sex != "" else "-", UIKit.HEATHER.darkened(0.2) if c.sex == "m" else Color("8f5a7a"), UIKit.CREAM, 18)
		sex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(sex)
		var ic := AnimSprite.new()
		ic.show_species(c.species.id, "icon", 1, false, c.variant, c.form)
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(ic)
		var nm := UIKit.fit_label(c.nickname if c.nickname != "" else str(c.species.name), 220, 24, 16)
		nm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nm.custom_minimum_size.x = 220  # a clipped label has no width of its own in an HBox
		h.add_child(nm)
		h.add_child(UIKit.fill())
		var tag := "Ark" if _cands[i].where == "ark" else "Team"
		var note := UIKit.label("%s%s" % [tag, "  fond" if PairingLogic.is_fond(c) else ""], 18, UIKit.MUTED if not PairingLogic.is_fond(c) else Color("8fd48f"))
		note.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(note)
		b.add_child(h)
		b.custom_minimum_size = Vector2(0, 56)
		_list.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	UIKit.focus_later(_buttons[0])

func _pick(i: int) -> void:
	var c: Creature = _cands[i].c
	if c == _a:
		_a = null
	elif c == _b:
		_b = null
	elif _a == null:
		_a = c
	elif _b == null:
		_b = c
	else:
		_a = _b
		_b = c
	_preview = false
	_msg = ""
	_refresh()

func _verdict() -> Dictionary:
	return PairingLogic.verdict(Game.data, Game.data.zone_id, _a, _b)

func _refresh() -> void:
	for i in _buttons.size():
		var c: Creature = _cands[i].c
		_buttons[i].modulate = Color("f2d680") if c == _a or c == _b else Color.WHITE
	var v := _verdict()
	for n in PairingLogic.notes_for(v):
		StudBook.note(Game.data, n)
	_pair_btn.disabled = not v.ok
	_preview_btn.disabled = v.get("sire") == null or not v.ok and v.kind == ""
	_preview_btn.text = "Pairing" if _preview else "Preview"
	UIKit.clear(_right)
	if _preview and v.get("sire") != null:
		var open := PunnettView.open_loci(Game.data)
		_locus = clampi(_locus, 0, open.size() - 1)
		PunnettView.build(_right, Game.data, v.sire, v.dam, open[_locus], PunnettView.GOALS[_goal].id)
		set_hints([["leftright", "Locus"], ["updown", "Goal"], ["cancel", "Back"]])
		return
	set_hints([["confirm", "Pick or drop"], ["cancel", "Back"]])
	var faces := HBoxContainer.new()
	faces.alignment = BoxContainer.ALIGNMENT_CENTER
	faces.add_theme_constant_override("separation", 40)
	_right.add_child(faces)
	for pair in [[v.get("sire", _a), "Sire"], [v.get("dam", _b), "Dam"]]:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 4)
		var c: Creature = pair[0]
		if c != null:
			var s := AnimSprite.new()
			s.show_species(c.species.id, "front", 1, false, c.variant, c.form)
			col.add_child(s)
			var fl := UIKit.fit_label(c.nickname if c.nickname != "" else str(c.species.name), 220, 24, 16)
			col.add_child(fl)
			col.add_child(UIKit.label(pair[1], 18, UIKit.MUTED))
		else:
			col.add_child(UIKit.label("(pick)", 24, UIKit.MUTED))
		faces.add_child(col)
	var line := _msg if _msg != "" else (PairingLogic.fine_line(v) if v.ok else str(v.why))
	var dot := UIKit.label("Dot: \"%s\"" % line, 24, UIKit.GOLD if v.ok else (Color("e9998c") if v.get("sire") != null else UIKit.MUTED))
	dot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_right.add_child(dot)
	if v.get("sire") != null:
		_right.add_child(UIKit.label("Kinship: %s" % v.kin_words, 22, UIKit.MUTED))
	var basket := UIKit.label("Baskets: %d of %d" % [Breeding.baskets(Game.data).size(), Breeding.MAX_BASKETS], 20, UIKit.MUTED)
	_right.add_child(basket)

func _toggle_preview() -> void:
	_preview = not _preview
	_refresh()

func _pair() -> void:
	var v := _verdict()
	if not v.ok:
		return
	var r := Breeding.start(Game.data, v.sire, v.dam, Game.data.zone_id, Game.dex, Game.moves, Rng.new(int(Time.get_ticks_usec())), Calendar.season_today())
	_msg = "Right, I'll ring you when it's due." if r.ok else str(r.why)
	_a = null
	_b = null
	_preview = false
	_refresh()

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	if _preview:
		var d := 0
		var g := 0
		if event.is_action_pressed("move_left"):
			d = -1
		elif event.is_action_pressed("move_right"):
			d = 1
		elif event.is_action_pressed("move_up"):
			g = -1
		elif event.is_action_pressed("move_down"):
			g = 1
		if d != 0 or g != 0:
			get_viewport().set_input_as_handled()
			var n := PunnettView.open_loci(Game.data).size()
			_locus = MenuLogic.wrap_index(_locus, d, n) if d != 0 else _locus
			_goal = MenuLogic.wrap_index(_goal, g, PunnettView.GOALS.size()) if g != 0 else _goal
			Audio.sfx("cursor")
			_refresh()
			return
	super._input(event)

func _on_cancel() -> void:
	if _preview:
		_preview = false
		_refresh()
		return
	close(null)
