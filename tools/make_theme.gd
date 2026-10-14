extends SceneTree
## Writes ui/theme.tres: dark slate panels, cream border and text, heather accent. Rerun after changing colours.
## Usage: godot --headless --path . -s res://tools/make_theme.gd

const SLATE := Color("1d2230f0")
const SLATE_LIGHT := Color("2c3446")
const CREAM := Color("f2e8cf")
const HEATHER := Color("9b6fb0")
const MUTED := Color("a9a294")

func _initialize() -> void:
	var t := Theme.new()
	t.default_font_size = 28
	var panel := _box(SLATE, CREAM, 2, 8, 18)
	t.set_stylebox("panel", "PanelContainer", panel)
	t.set_stylebox("panel", "Panel", panel)
	var normal := _box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 6, 10)
	var hover := _box(SLATE_LIGHT, HEATHER, 2, 6, 10)
	for state in ["normal", "disabled"]:
		t.set_stylebox(state, "Button", normal)
	for state in ["hover", "pressed", "focus", "hover_pressed"]:
		t.set_stylebox(state, "Button", hover)
	t.set_color("font_color", "Button", CREAM)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_focus_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", MUTED)
	t.set_constant("h_separation", "Button", 12)
	t.set_color("font_color", "Label", CREAM)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.5))
	t.set_constant("shadow_offset_x", "Label", 2)
	t.set_constant("shadow_offset_y", "Label", 2)
	t.set_color("default_color", "RichTextLabel", CREAM)
	t.set_stylebox("background", "ProgressBar", _box(Color("0d0f15"), CREAM, 1, 3, 0))
	t.set_stylebox("fill", "ProgressBar", _box(Color("5fbf6a"), Color(0, 0, 0, 0), 0, 3, 0))
	t.set_constant("separation", "VBoxContainer", 6)
	t.set_constant("separation", "HBoxContainer", 10)
	var err := ResourceSaver.save(t, "res://ui/theme.tres")
	print("theme: ", error_string(err))
	quit(0 if err == OK else 1)

func _box(bg: Color, border: Color, bw: int, radius: int, margin: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.set_content_margin_all(margin)
	s.anti_aliasing = false
	return s
