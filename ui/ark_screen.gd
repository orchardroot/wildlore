extends MenuBase
## The Ark: creature storage. Left, the team (choose one to deposit). Right, the Ark box (choose one to withdraw).
## 30 creatures per box; Prev/Next page through boxes.

const PER_BOX := 30

var _box := 0
var _left: VBoxContainer
var _right: GridContainer
var _box_label: Label
var _note: Label

func _build() -> void:
	set_title("The Ark")
	set_hint("Z  Move        X  Back")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 28)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 14)
	lp.custom_minimum_size = Vector2(520, 0)
	row.add_child(lp)
	var lcol := VBoxContainer.new()
	lp.add_child(lcol)
	lcol.add_child(UIKit.label("Your team  (choose to deposit)", 24, UIKit.MUTED))
	_left = VBoxContainer.new()
	_left.add_theme_constant_override("separation", 6)
	lcol.add_child(_left)
	var rcol := VBoxContainer.new()
	rcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rcol.add_theme_constant_override("separation", 10)
	row.add_child(rcol)
	var head := HBoxContainer.new()
	rcol.add_child(head)
	head.add_child(make_button("<", func(): _page(-1), 70))
	_box_label = UIKit.label("", 30, UIKit.CREAM)
	_box_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(_box_label)
	head.add_child(make_button(">", func(): _page(1), 70))
	var rp := UIKit.panel(Color("1d2230f0"), 14)
	rp.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rcol.add_child(rp)
	_right = GridContainer.new()
	_right.columns = 6
	_right.add_theme_constant_override("h_separation", 8)
	_right.add_theme_constant_override("v_separation", 8)
	rp.add_child(_right)
	_note = UIKit.label("", 26, UIKit.GOLD)
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rcol.add_child(_note)
	_refresh()

static func box_count(ark_size: int) -> int:
	return maxi(1, ceili(float(ark_size + 1) / PER_BOX))

func _page(d: int) -> void:
	_box = posmod(_box + d, box_count(Game.data.ark.size()))
	_refresh()

func _refresh(focus_left := -1, focus_right := -1) -> void:
	var data: GameStateData = Game.data
	UIKit.clear(_left)
	UIKit.clear(_right)
	var lefts := []
	for i in data.party.size():
		var b := _creature_button(data.party[i], true)
		b.pressed.connect(_deposit.bind(i))
		_left.add_child(b)
		lefts.append(b)
	var boxes := box_count(data.ark.size())
	_box = clampi(_box, 0, boxes - 1)
	_box_label.text = "Box %d of %d   (%d stored)" % [_box + 1, boxes, data.ark.size()]
	var rights := []
	for j in range(_box * PER_BOX, mini(data.ark.size(), (_box + 1) * PER_BOX)):
		var b := _creature_button(data.ark[j], false)
		b.pressed.connect(_withdraw.bind(j))
		_right.add_child(b)
		rights.append(b)
	if rights.is_empty():
		_right.add_child(UIKit.label("Empty. Plenty of room in here.", 24, UIKit.MUTED))
	UIKit.wrap_focus(lefts)
	if focus_right >= 0 and rights.size() > 0:
		UIKit.focus_later(rights[mini(focus_right, rights.size() - 1)])
	elif lefts.size() > 0:
		UIKit.focus_later(lefts[clampi(focus_left, 0, lefts.size() - 1)])

func _creature_button(c: Creature, wide: bool) -> Button:
	var b := UIKit.button("")
	b.focus_entered.connect(func(): Audio.sfx("cursor"))
	b.custom_minimum_size = Vector2(0, 70) if wide else Vector2(120, 104)
	var box: BoxContainer = HBoxContainer.new() if wide else VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(box)
	var s := AnimSprite.new()
	s.show_species(c.species.id, "icon", 2)
	if c.is_fainted():
		s.modulate = Color(0.5, 0.5, 0.5)
	box.add_child(s)
	var l := UIKit.label(("%s  L%d" % [c.display_name(), c.level]) if wide else "L%d" % c.level, 26 if wide else 20)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(l)
	return b

func _deposit(i: int) -> void:
	var why := Game.data.deposit(i)
	_note.text = why if why != "" else "Safe and sound in the Ark."
	Audio.sfx("bump" if why != "" else "confirm")
	_box = box_count(Game.data.ark.size()) - 1
	_refresh(i)

func _withdraw(j: int) -> void:
	var why := Game.data.withdraw(j)
	_note.text = why if why != "" else "Back on the team."
	Audio.sfx("bump" if why != "" else "confirm")
	_refresh(-1, j - _box * PER_BOX)
