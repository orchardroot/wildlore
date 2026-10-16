extends MenuBase
## Summary: front sprite, types, stats, nature, moves with PP and the Creaturepedia fact. Left/right pages through the team;
## up/down picks a move to read what it does.

const STAT_NAMES := {"hp": "HP", "atk": "Attack", "def": "Defence", "lore": "Lore", "ward": "Ward", "spd": "Speed"}

var _index := 0
var _body: HBoxContainer
var _move := 0  # the highlighted move row (kept while paging through the team)
var _move_rows: Array = []
var _move_info: Label
var _moves_of: Creature
var _in_ark := false  # summarising the Ark's creatures instead of the team

func _build() -> void:
	set_title("Summary")
	_body = HBoxContainer.new()
	_body.set_anchors_preset(Control.PRESET_FULL_RECT)
	_body.add_theme_constant_override("separation", 22)
	content.add_child(_body)

## "3" opens team slot 3; "ark:12" opens Ark entry 12 (and pages through the Ark).
func setup(arg: String) -> void:
	if arg.begins_with("ark:"):
		_in_ark = true
		arg = arg.substr(4)
	_index = clampi(int(arg), 0, maxi(0, _list().size() - 1))
	_show()

func _unhandled_input(event: InputEvent) -> void:
	if _locked or _done:
		return
	var dy := 0
	if event.is_action_pressed("move_up"):
		dy = -1
	elif event.is_action_pressed("move_down"):
		dy = 1
	if dy != 0 and _move_rows.size() > 1:
		get_viewport().set_input_as_handled()
		_move = MenuLogic.wrap_index(_move, dy, _move_rows.size())
		Audio.sfx("cursor")
		_paint_moves()
		return
	if _list().size() < 2:
		return
	var d := 0
	if event.is_action_pressed("move_left"):
		d = -1
	elif event.is_action_pressed("move_right"):
		d = 1
	if d != 0:
		get_viewport().set_input_as_handled()
		_index = MenuLogic.wrap_index(_index, d, _list().size())
		Audio.sfx("cursor")
		_show()

func _list() -> Array:
	return Game.data.ark if _in_ark else party()

func _show() -> void:
	UIKit.clear(_body)
	if _list().is_empty():
		return
	var c: Creature = _list()[_index]
	header_right.text = "%d / %d" % [_index + 1, _list().size()]
	set_hint(("Up / Down  Moves        " if c.moves.size() > 1 else "") + ("Left / Right  Next creature        X  Back" if _list().size() > 1 else "X  Back"))
	_body.add_child(_left(c))
	_body.add_child(_middle(c))
	_body.add_child(_right(c))

func _left(c: Creature) -> Control:
	var p := UIKit.panel(Color("1d2230f0"), 18)
	p.custom_minimum_size = Vector2(340, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	var s := AnimSprite.new()
	s.show_species(c.species.id, "front", 3)
	s.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(s)
	var n := UIKit.label(c.display_name(), 38)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(n)
	if c.nickname != "" and c.nickname != c.species.name:
		var sp := UIKit.label(c.species.name, 22, UIKit.MUTED)
		sp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		v.add_child(sp)
	var lv := UIKit.label("Level %d" % c.level, 30, UIKit.GOLD)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lv)
	var tr := UIKit.types_row(c.types(), 22)
	tr.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(tr)
	var st: Control = UIKit.chip("fainted", Color("6b2f2f")) if c.is_fainted() else UIKit.status_chip(c.status, 20)
	if st:
		var cc := CenterContainer.new()
		cc.add_child(st)
		v.add_child(cc)
	v.add_child(UIKit.fill())
	var evo: String = preload("res://ui/pedia_screen.gd").evolution_line(c.species)
	if evo != "":
		var el := UIKit.label(evo, 20, UIKit.GOLD)
		el.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		el.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(el)
	var nxt := Rules.xp_for_level(c.species.growth, c.level + 1)
	var xp := UIKit.label("XP %d  (next level at %d)" % [c.xp, nxt] if c.level < Rules.MAX_LEVEL else "XP %d  (maxed out)" % c.xp, 20, UIKit.MUTED)
	xp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(xp)
	return p

func _middle(c: Creature) -> Control:
	var p := UIKit.panel(Color("1d2230f0"), 18)
	p.custom_minimum_size = Vector2(380, 0)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	v.add_child(UIKit.label("Stats", 24, UIKit.MUTED))
	var nat: Array = Rules.NATURES.get(c.nature, [])
	for s in Rules.STATS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var tag := ""
		var colour := UIKit.CREAM
		if nat.size() == 2 and nat[0] == s:
			tag = "+"
			colour = Color("8fd48f")
		elif nat.size() == 2 and nat[1] == s:
			tag = "-"
			colour = Color("e9998c")
		var name_l := UIKit.label(STAT_NAMES[s] + tag, 26, colour)
		name_l.custom_minimum_size = Vector2(110, 0)
		row.add_child(name_l)
		var val := c.max_hp() if s == "hp" else c.calc_stat(s)
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.max_value = 130
		bar.value = val
		bar.custom_minimum_size = Vector2(130, 14)
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		bar.add_theme_stylebox_override("fill", UIKit.box(UIKit.HEATHER, Color(0, 0, 0, 0), 0, 3, 0))
		row.add_child(bar)
		var txt := "%d / %d" % [c.hp, val] if s == "hp" else str(val)
		var vl := UIKit.label(txt, 26)
		vl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(vl)
		v.add_child(row)
	v.add_child(UIKit.spacer(6))
	var nl := UIKit.label("%s nature" % c.nature.capitalize(), 26, UIKit.GOLD)
	v.add_child(nl)
	if nat.size() == 2:
		v.add_child(UIKit.label("Likes %s, less keen on %s" % [STAT_NAMES[nat[0]], STAT_NAMES[nat[1]]], 20, UIKit.MUTED))
	else:
		v.add_child(UIKit.label("Perfectly balanced, as all things should be", 20, UIKit.MUTED))
	return p

func _right(c: Creature) -> Control:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 12)
	var mp := UIKit.panel(Color("1d2230f0"), 14)
	col.add_child(mp)
	var mv := VBoxContainer.new()
	mv.add_theme_constant_override("separation", 2)
	mp.add_child(mv)
	_moves_of = c
	_move_rows = []
	for i in c.moves.size():
		var m: Dictionary = c.moves[i]
		var info: Dictionary = Game.moves.get_move(m.id)
		var hl := PanelContainer.new()
		hl.mouse_filter = Control.MOUSE_FILTER_STOP
		hl.mouse_entered.connect(func():
			if _move != i:
				_move = i
				_paint_moves())
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var chip := UIKit.type_chip(str(info.get("type", "kin")), 16)
		chip.custom_minimum_size = Vector2(96, 0)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(chip)
		row.add_child(UIKit.label(str(info.get("name", m.id)), 26))
		row.add_child(UIKit.fill())
		var low: bool = int(m.pp) * 4 <= int(m.max_pp)
		row.add_child(UIKit.label("PP %d/%d" % [m.pp, m.max_pp], 22, Color("e9998c") if low else UIKit.MUTED))
		for k in row.get_children():
			k.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hl.add_child(row)
		mv.add_child(hl)
		_move_rows.append(hl)
	for i in range(c.moves.size(), 4):
		mv.add_child(UIKit.label("-", 26, UIKit.MUTED))
	_move_info = UIKit.label("", 18, Color("d8cfb4"))
	_move_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_move_info.custom_minimum_size = Vector2(0, 50)  # two lines, so paging moves never shifts the layout
	mv.add_child(_move_info)
	_move = clampi(_move, 0, maxi(0, c.moves.size() - 1))
	_paint_moves()
	var fp := UIKit.panel(Color("1d2230f0"), 16)
	fp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	col.add_child(fp)
	var fv := VBoxContainer.new()
	fv.add_theme_constant_override("separation", 6)
	fp.add_child(fv)
	var dex: Dictionary = c.species.get("dex", {})
	var t := UIKit.label(str(dex.get("text", "")), 21)
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fv.add_child(t)
	fv.add_child(UIKit.label("Did you know?", 22, UIKit.GOLD))
	var f := UIKit.label(str(dex.get("fact", "")), 21, Color("d8cfb4"))
	f.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fv.add_child(f)
	return col

## Highlights the chosen move row and says what that move does.
func _paint_moves() -> void:
	for i in _move_rows.size():
		var sb := StyleBoxFlat.new()
		sb.set_corner_radius_all(5)
		sb.content_margin_left = 4
		sb.content_margin_right = 4
		sb.content_margin_top = 2
		sb.content_margin_bottom = 2
		sb.bg_color = Color(UIKit.HEATHER, 0.35) if i == _move else Color(0, 0, 0, 0)
		_move_rows[i].add_theme_stylebox_override("panel", sb)
	if _move_info == null or _moves_of == null or _move >= _moves_of.moves.size():
		return
	var info: Dictionary = Game.moves.get_move(_moves_of.moves[_move].id)
	var power := int(info.get("power", 0))
	_move_info.text = "%sAccuracy %d  ·  %s" % [("Power %d  ·  " % power) if power > 0 else "", int(info.get("accuracy", 100)), MoveText.describe(info)]
