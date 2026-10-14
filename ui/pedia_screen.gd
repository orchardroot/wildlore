extends MenuBase
## Creaturepedia ("Fieldbook"): every species in Dex order. Unseen is "???", seen is a silhouette, caught is the full entry.

const ZONE_DIR := "res://data/zones"
static var _habitats: Dictionary = {}
static var _habitats_loaded := false

var _ids: Array = []
var _list_col: VBoxContainer
var _detail: VBoxContainer
var _buttons: Array = []

func _build() -> void:
	set_title("Fieldbook")
	_ids = Game.dex.ids()
	var d: GameStateData = Game.data
	header_right.text = "Seen %d    Caught %d / %d" % [d.seen.size(), d.caught.size(), _ids.size()]
	set_hint("Up / Down  Browse        X  Back")
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", 22)
	content.add_child(row)
	var lp := UIKit.panel(Color("1d2230f0"), 10)
	lp.custom_minimum_size = Vector2(440, 0)
	row.add_child(lp)
	var sc := ScrollContainer.new()
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sc.follow_focus = true
	sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lp.add_child(sc)
	_list_col = VBoxContainer.new()
	_list_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_col.add_theme_constant_override("separation", 4)
	sc.add_child(_list_col)
	var dp := UIKit.panel(Color("1d2230f0"), 20)
	dp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(dp)
	_detail = VBoxContainer.new()
	_detail.add_theme_constant_override("separation", 10)
	dp.add_child(_detail)
	for i in _ids.size():
		var b := _entry_button(i)
		_list_col.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	if not _buttons.is_empty():
		_buttons[0].grab_focus.call_deferred()

func state_of(id: String) -> String:
	if Game.data.caught.has(id):
		return "caught"
	return "seen" if Game.data.seen.has(id) else "unseen"

func _entry_button(i: int) -> Button:
	var id: String = _ids[i]
	var st := state_of(id)
	var sp: Dictionary = Game.dex.get_species(id)
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 58)
	b.focus_entered.connect(func():
		Audio.sfx("cursor")
		_show(id))
	b.pressed.connect(func(): Audio.sfx("confirm"))
	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 10
	h.offset_right = -10
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(h)
	var no := UIKit.label("%03d" % (i + 1), 22, UIKit.MUTED)
	no.custom_minimum_size = Vector2(52, 0)
	h.add_child(no)
	var ic := AnimSprite.new()
	ic.show_species(id if st != "unseen" else "", "icon", 1, st != "caught")
	if st == "unseen":
		ic.modulate = Color(1, 1, 1, 0.35)
	ic.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(ic)
	h.add_child(UIKit.label(str(sp.get("name", id)) if st != "unseen" else "???", 28, UIKit.CREAM if st != "unseen" else UIKit.MUTED))
	h.add_child(UIKit.fill())
	var dot := Panel.new()
	dot.custom_minimum_size = Vector2(16, 16)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if st == "caught":
		dot.add_theme_stylebox_override("panel", UIKit.box(UIKit.GOLD, UIKit.GOLD.darkened(0.4), 2, 8, 0))
	elif st == "seen":
		dot.add_theme_stylebox_override("panel", UIKit.box(Color(0, 0, 0, 0), UIKit.MUTED, 2, 8, 0))
	else:
		dot.visible = false
	h.add_child(dot)
	for c in h.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

func _show(id: String) -> void:
	UIKit.clear(_detail)
	var st := state_of(id)
	var sp: Dictionary = Game.dex.get_species(id)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 20)
	_detail.add_child(top)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UIKit.box(Color("2c3446"), Color("4a4f5e"), 2, 8, 6))
	top.add_child(frame)
	var s := AnimSprite.new()
	s.show_species(id if st != "unseen" else "", "front", 2, st == "seen")
	if st == "unseen":
		s.modulate = Color(1, 1, 1, 0.35)
	frame.add_child(s)
	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 8)
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(info)
	var idx := _ids.find(id) + 1
	info.add_child(UIKit.label("No. %03d" % idx, 22, UIKit.MUTED))
	info.add_child(UIKit.label(str(sp.get("name", id)) if st != "unseen" else "???", 40))
	if st != "unseen":
		info.add_child(UIKit.types_row(sp.get("types", []), 22))
	else:
		var u := UIKit.label("Not met yet. Out there somewhere, being elusive.", 22, UIKit.MUTED)
		u.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u.custom_minimum_size = Vector2(300, 0)
		info.add_child(u)
	if st == "unseen":
		return
	var zones := MenuLogic.habitats(habitat_index(), id)
	var hl := UIKit.label("Found in: " + (", ".join(zones) if not zones.is_empty() else "somewhere secret"), 22, Color("d8cfb4"))
	hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail.add_child(hl)
	_detail.add_child(UIKit.spacer(4))
	var dex: Dictionary = sp.get("dex", {})
	if st == "caught":
		var t := UIKit.label(str(dex.get("text", "")), 25)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_detail.add_child(t)
		_detail.add_child(UIKit.label("Did you know?", 24, UIKit.GOLD))
		var f := UIKit.label(str(dex.get("fact", "")), 23, Color("d8cfb4"))
		f.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_detail.add_child(f)
	else:
		var t := UIKit.label("Spotted, but it didn't hang around. Catch one to fill in the rest of the entry.", 25, UIKit.MUTED)
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_detail.add_child(t)

## species id -> zone names, scanned once from data/zones/*.json.
static func habitat_index() -> Dictionary:
	if not _habitats_loaded:
		var zones := []
		for path in JsonUtil.list_json(ZONE_DIR):
			var z = JsonUtil.read(path)
			if z is Dictionary:
				zones.append(z)
		_habitats = MenuLogic.habitat_index(zones)
		_habitats_loaded = true
	return _habitats
