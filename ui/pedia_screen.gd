extends MenuBase
## Creaturepedia ("Fieldbook"): every species in Dex order. Unseen is "???", seen is a silhouette, caught is the full entry.
## Left/Right (or the pad's shoulder buttons) jump ten entries; Run cycles the filter: All, Caught, Seen, Rumours
## (local gossip about creatures still to catch, and the region stamps: see RumoursTab).
## The Bike key (or the Cry button) plays the creature's cry, once you have met one (see Cries).

const ZONE_DIR := "res://data/zones"
static var _habitats: Dictionary = {}
static var _habitats_loaded := false
static var _last_id := ""      # reopens on the entry you left it on (this session only)
static var _filter := "all"    # all | caught | seen | rumours, also kept for the session

const PAGE := 10
const MAX_PLACES := 3  # the rest are on the map, so a long list can't push the entry off the bottom
const FILTER_NAMES := {"all": "All", "caught": "Caught", "seen": "Seen", "rumours": "Rumours"}

var _all: Array = []           # every species id, Dex order
var _no: Dictionary = {}       # id -> Dex number as shown: "045", or "A01" in the appendix after the 200
var _core := 0                 # how many are in the Fieldbook proper (the appendix is a bonus)
var _extra := 0                # how many in the appendix
var _ids: Array = []           # the ids the current filter shows
var _cur := 0
var _scroll: ScrollContainer
var _list_col: VBoxContainer
var _detail: VBoxContainer
var _buttons: Array = []
var _rumours: Array = []       # the Rumours tab's rows, when it's showing
const WORD_SIZES := [25, 23, 21, 19]  # the body text's size, biggest first, until the entry fits

func _build() -> void:
	set_title("Fieldbook")
	_all = Game.dex.ids()
	for id in _all:
		if Dex.in_appendix(id):
			_extra += 1
			_no[id] = "A%02d" % _extra
		else:
			_core += 1
			_no[id] = "%03d" % _core
	set_hints([["updown", "Browse"], ["shoulders", "Jump 10"], ["run", "Filter"], ["bike", "Cry"], ["confirm", "Map"], ["cancel", "Back"]])
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
	_scroll = sc
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
	_fill_list()

## (Re)builds the list for the current filter and focuses the remembered entry, or the first.
func _fill_list() -> void:
	var d: GameStateData = Game.data
	if _filter == "rumours":
		_rumours = RumoursTab.entries()
		_ids = _rumours.map(func(r): return str(r.species))
	else:
		_ids = MenuLogic.fieldbook_filter(_all, d.seen, d.caught, _filter)
	header_right.text = "%s    Seen %d    Caught %d / %d" % [FILTER_NAMES[_filter], d.seen.size(), FieldbookGoals.caught_count(d), _core]
	var extra_seen := d.seen.keys().filter(func(id): return Dex.in_appendix(id)).size()
	if extra_seen > 0:  # the appendix shows up once you've met something from it
		header_right.text += "    Appendix %d / %d" % [d.caught.size() - FieldbookGoals.caught_count(d), _extra]
	UIKit.clear(_list_col)
	_buttons.clear()
	for i in _ids.size():
		var b := _rumour_button(i) if _filter == "rumours" else _entry_button(i)
		_list_col.add_child(b)
		_buttons.append(b)
	UIKit.wrap_focus(_buttons)
	if _buttons.is_empty():
		UIKit.clear(_detail)
		var none := UIKit.label("Nothing here yet. Get out there with a snare.", 26, UIKit.MUTED)
		_list_col.add_child(none)
		return
	_cur = maxi(0, _ids.find(_last_id))
	UIKit.focus_later(_buttons[_cur])
	_scroll_to_later(_buttons[_cur])

## follow_focus can't scroll before the list has been laid out, so reopening deep in the list scrolls once it has.
func _scroll_to_later(b: Control) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(b) and b.is_inside_tree():
		_scroll.ensure_control_visible(b)

## setup("<species id>") opens on that entry (the filter goes back to All if it would hide it);
## setup("rumours") or setup("stamps") opens the Rumours tab.
func setup(arg: String) -> void:
	if arg in ["rumours", "stamps"]:  # straight to the Rumours tab (on its first rumour, or on the stamps)
		_filter = "rumours"
		_fill_list()
		if arg == "rumours" and _ids.size() > 1:
			_last_id = _ids[1]
			_fill_list()
		return
	if arg == "" or not _all.has(arg):
		return
	_last_id = arg
	if not _ids.has(arg):
		_filter = "all"
	_fill_list()

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	var d := 0
	if event.is_action_pressed("move_left") or _shoulder(event, JOY_BUTTON_LEFT_SHOULDER):
		d = -PAGE
	elif event.is_action_pressed("move_right") or _shoulder(event, JOY_BUTTON_RIGHT_SHOULDER):
		d = PAGE
	if d != 0:
		get_viewport().set_input_as_handled()
		if not _buttons.is_empty():
			_buttons[MenuLogic.page_index(_cur, d, _buttons.size())].grab_focus()
		return
	if event.is_action_pressed("bike"):
		get_viewport().set_input_as_handled()
		if not _ids.is_empty():
			play_cry(_ids[_cur])
		return
	if event.is_action_pressed("run"):
		get_viewport().set_input_as_handled()
		_filter = MenuLogic.next_filter(_filter)
		Audio.sfx("cursor")
		_fill_list()
		return
	super._input(event)

## A pad shoulder press, unless the player has bound that button to something else.
func _shoulder(event: InputEvent, button: int) -> bool:
	if not (event is InputEventJoypadButton) or not event.pressed or event.button_index != button:
		return false
	return not InputSetup.ACTIONS.any(func(a): return event.is_action(a))

## Heard it in the wild (seen or caught): play its cry. True if it played.
func play_cry(id: String) -> bool:
	if state_of(id) == "unseen":
		return false
	Audio.cry(Game.dex.get_species(id), 0.0)
	return true

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
		_cur = i
		_last_id = id
		_show(id))
	b.pressed.connect(func():
		if state_of(id) == "unseen":
			return
		Audio.sfx("confirm")
		await open_child("map:species:" + id)
		b.grab_focus())
	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 10
	h.offset_right = -10
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(h)
	var no := UIKit.label(str(_no.get(id, "%03d" % (i + 1))), 22, UIKit.MUTED)
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

## A Rumours tab row: the stamps, or one bit of gossip (Confirm opens the map once you've seen the creature).
func _rumour_button(i: int) -> Button:
	var r: Dictionary = _rumours[i]
	var b := Button.new()
	b.custom_minimum_size = Vector2(0, 58)
	b.focus_entered.connect(func():
		Audio.sfx("cursor")
		_cur = i
		_last_id = str(r.species)
		RumoursTab.show(r, _detail))
	b.pressed.connect(func():
		if str(r.species) == "" or state_of(str(r.species)) == "unseen":
			return
		Audio.sfx("confirm")
		await open_child("map:species:" + str(r.species))
		b.grab_focus())
	var h := HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 10
	h.offset_right = -10
	h.add_theme_constant_override("separation", 10)
	b.add_child(h)
	RumoursTab.row(r, h)
	for c in h.get_children():
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	info.add_theme_constant_override("separation", 6)
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(info)
	info.add_child(UIKit.label(("Appendix %s" if Dex.in_appendix(id) else "No. %s") % str(_no.get(id, "")), 22, UIKit.MUTED))
	info.add_child(UIKit.label(str(sp.get("name", id)) if st != "unseen" else "???", 40))
	if st != "unseen":
		var type_row := HBoxContainer.new()  # the types, and the Cry button beside them (the Bike key does it too)
		type_row.add_theme_constant_override("separation", 12)
		type_row.add_child(UIKit.types_row(sp.get("types", []), 22))
		var cry := UIKit.pill_button("Cry", 20)
		cry.focus_mode = Control.FOCUS_NONE  # the list keeps focus; this is for the mouse
		cry.tooltip_text = "Play its cry (%s)" % UIKit.key_for("bike")
		cry.pressed.connect(func(): play_cry(id))
		type_row.add_child(cry)
		info.add_child(type_row)
		var kid := Knacks.id_for_species(sp)
		var knack_row := HBoxContainer.new()  # the line's knack once caught, and any uncommon coats
		knack_row.add_theme_constant_override("separation", 16)
		if st == "caught" and kid != "":  # 2.0: the knack, here so the entry keeps its height
			var kl := UIKit.label("Knack: %s" % Knacks.name_of(kid), 21, UIKit.GOLD)
			kl.tooltip_text = Knacks.desc_of(kid)
			kl.mouse_filter = Control.MOUSE_FILTER_PASS
			kl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			knack_row.add_child(kl)
		knack_row.add_child(CoatArt.swatch_row(Game.data, id))
		if knack_row.get_child_count() > 1 or knack_row.get_child(0).get_child_count() > 0:
			info.add_child(knack_row)
		else:
			knack_row.free()
	else:
		var u := UIKit.label("Not met yet. Out there somewhere, being elusive.", 22, UIKit.MUTED)
		u.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		u.custom_minimum_size = Vector2(300, 0)
		info.add_child(u)
	if st == "unseen":
		return
	var evo := evolution_line(sp)
	if evo != "":
		var el := UIKit.label(evo, 21, UIKit.GOLD)
		el.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		el.custom_minimum_size = Vector2(300, 0)
		info.add_child(el)
	# The words below the picture shrink to fit, and scroll if even the smallest size can't (see UIKit.fit_block).
	var wb := UIKit.words_box(WORD_SIZES)
	_detail.add_child(wb[0])
	var words: VBoxContainer = wb[1]
	var zones := MenuLogic.habitats(habitat_index(), id)
	var where := ", ".join(zones.slice(0, MAX_PLACES))
	if zones.size() > MAX_PLACES:
		where += " and %d more" % (zones.size() - MAX_PLACES)
	UIKit.add_words(words, "Found in: " + (where if not zones.is_empty() else "somewhere secret"), -4, Color("d8cfb4"))
	var dex: Dictionary = sp.get("dex", {})
	if st == "caught":
		UIKit.add_words(words, str(dex.get("text", "")), 0)
		UIKit.add_words(words, "Did you know?", -1, UIKit.GOLD)
		UIKit.add_words(words, str(dex.get("fact", "")), -2, Color("d8cfb4"))
	else:
		UIKit.add_words(words, "Spotted, but it didn't hang around. Catch one to fill in the rest of the entry.", 0, UIKit.MUTED)

## "Evolves into X at Lv 20" for a species; the target's name stays hidden until you've seen one.
static func evolution_line(sp: Dictionary) -> String:
	var evo = sp.get("evolves")
	if not (evo is Dictionary):
		return ""
	var to := str(evo.get("to", ""))
	var target := ""
	if Game.data.seen.has(to) or Game.data.caught.has(to):
		target = str(Game.dex.get_species(to).get("name", ""))
	var item := ""
	if evo.has("item") and Game.items != null:
		item = str(Game.items.get_item(str(evo.item)).get("name", ""))
	return MenuLogic.evolution_text(evo, target, item)

## species id -> "Zone (time, weather)" labels, scanned once from data/zones/*.json.
static func habitat_index() -> Dictionary:
	if not _habitats_loaded:
		var zones := []
		for path in JsonUtil.list_json(ZONE_DIR):
			var z = JsonUtil.read(path)
			if z is Dictionary and str(z.get("id", "")) != "testbed":  # the dev zone isn't a real place
				zones.append(z)
		_habitats = MenuLogic.habitat_labels(zones)
		_habitats_loaded = true
	return _habitats
