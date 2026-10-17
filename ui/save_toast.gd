class_name SaveToast
extends CanvasLayer
## A small "Saved" note in the bottom-right corner that fades after a moment. Never takes input.

const SLATE := Color(0.114, 0.133, 0.188, 0.88)
const CREAM := Color(0.949, 0.91, 0.812)

var _panel: PanelContainer
var _label: Label
var _tween: Tween

func _ready() -> void:
	layer = 60
	_panel = PanelContainer.new()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.anchor_left = 1.0
	_panel.anchor_right = 1.0
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -20
	_panel.offset_right = -20
	_panel.offset_top = -20
	_panel.offset_bottom = -20
	_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var sb := StyleBoxFlat.new()
	sb.bg_color = SLATE
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(2)
	sb.border_color = Color(CREAM, 0.5)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	_panel.add_theme_stylebox_override("panel", sb)
	var l := Label.new()
	_label = l
	l.text = "Saved"
	l.add_theme_font_size_override("font_size", 22)
	l.add_theme_color_override("font_color", CREAM)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(l)
	add_child(_panel)
	_panel.modulate.a = 0.0

## Fades in, holds, fades out. Safe to call again while showing (it just restarts).
func flash(text := "Saved") -> void:
	_label.text = text
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
	_tween.tween_interval(1.2)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.6)
