class_name UIKit
extends RefCounted
## Small widget builders shared by every menu, so they all look like one game.

const CREAM := Color("f2e8cf")
const MUTED := Color("a9a294")
const HEATHER := Color("9b6fb0")
const SLATE := Color("1d2230")
const GOLD := Color("e8c872")
const HP_COLOURS := {"green": Color("5fbf6a"), "amber": Color("e8b63c"), "red": Color("d9503f")}
const STATUS_COLOURS := {
	"soaked": Color("4a90d9"), "chilled": Color("86d4e0"), "muddled": Color("c9a33c"),
	"hexed": Color("8e6fbf"), "stung": Color("c24a3e"), "asleep": Color("7d7f8a"),
}

static func box(bg: Color, border := Color(0, 0, 0, 0), bw := 0, radius := 6, margin := 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	s.anti_aliasing = false
	return s

static func label(text: String, size := 28, colour := CREAM) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", colour)
	return l

static func spacer(h := 0, w := 0) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	return c

static func fill() -> Control:
	var c := Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c

static func panel(bg := Color("1d2230f0"), margin := 16) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, CREAM, 2, 8, margin))
	return p

## A rounded coloured tag: types, statuses, kinds.
static func chip(text: String, bg: Color, fg := Color("f8f1dc"), size := 20) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, bg.darkened(0.35), 2, 10, 5))
	var l := label(text.to_upper(), size, fg)
	l.add_theme_constant_override("shadow_offset_x", 0)
	l.add_theme_constant_override("shadow_offset_y", 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	p.add_child(l)
	p.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return p

static func type_chip(t: String, size := 20) -> PanelContainer:
	return chip(t, TypeColours.colour(t), TypeColours.text_colour(t), size)

static func status_chip(status: String, size := 18) -> Control:
	if status == "":
		return null
	return chip(status, STATUS_COLOURS.get(status, MUTED), Color("f8f1dc"), size)

static func types_row(types: Array, size := 20) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 8)
	for t in types:
		h.add_child(type_chip(str(t), size))
	return h

static func hp_bar(hp: int, max_hp: int, width := 200, height := 14) -> ProgressBar:
	var b := ProgressBar.new()
	b.show_percentage = false
	b.min_value = 0
	b.max_value = maxi(1, max_hp)
	b.value = clampi(hp, 0, max_hp)
	b.custom_minimum_size = Vector2(width, height)
	b.add_theme_stylebox_override("background", box(Color("0d0f15"), CREAM, 2, 3, 0))
	b.add_theme_stylebox_override("fill", box(HP_COLOURS[MenuLogic.hp_band(hp, max_hp)], Color(0, 0, 0, 0), 0, 3, 0))
	return b

static func button(text: String, min_w := 0) -> Button:
	var b := Button.new()
	b.text = text
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size = Vector2(min_w, 52)
	return b

## Makes the first and last of a vertical run of controls loop round on up/down.
static func wrap_focus(items: Array) -> void:
	if items.size() < 2:
		return
	var first: Control = items[0]
	var last: Control = items[items.size() - 1]
	first.focus_neighbor_top = first.get_path_to(last)
	last.focus_neighbor_bottom = last.get_path_to(first)

static func clear(node: Node) -> void:
	for c in node.get_children():
		node.remove_child(c)
		c.queue_free()

static func kind_name(kind: String) -> String:
	return {"heal": "Healing", "cure": "Remedies", "revive": "Revivals", "pp": "Pudding", "snare": "Snares",
		"evo": "Curios", "key": "Key Items"}.get(kind, kind.capitalize())

static func money_text(n: int) -> String:
	var s := str(absi(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3) + out
		s = s.substr(0, s.length() - 3)
	return s + out + "p"
