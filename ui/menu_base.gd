class_name MenuBase
extends Control
## Shared frame for every menu: themed full-screen backdrop, header, hint bar, cancel handling, sounds.
## Subclasses override _build() (once, in _ready), setup(arg) if they take an argument, and _on_cancel().
## The Router awaits `closed(result)`.

signal closed(result)

var title_text := ""
var content: Control          # where subclasses put their layout (inside the margins)
var header_right: Label
var hint_label: Label
var _done := false
var _locked := false          # true while a child menu or popup owns input

func _ready() -> void:
	theme = load("res://ui/theme.tres")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_frame()
	_build()

func _build_frame() -> void:
	var g := Gradient.new()
	g.set_color(0, Color("10131d"))
	g.set_color(1, Color("262d42"))
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.fill_from = Vector2(0, 0)
	tex.fill_to = Vector2(0.35, 1)
	var bg := TextureRect.new()
	bg.texture = tex
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.modulate = Color(1, 1, 1, 0.96)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var rule := ColorRect.new()
	rule.color = UIKit.HEATHER
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.custom_minimum_size = Vector2(0, 6)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rule)
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 48)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	margin.add_child(col)
	var head := HBoxContainer.new()
	col.add_child(head)
	var t := UIKit.label(title_text, 44, UIKit.CREAM)
	t.name = "Title"
	head.add_child(t)
	head.add_child(UIKit.fill())
	header_right = UIKit.label("", 26, UIKit.GOLD)
	head.add_child(header_right)
	content = Control.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_child(content)
	hint_label = UIKit.label("", 20, UIKit.MUTED)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	col.add_child(hint_label)

func set_title(t: String) -> void:
	title_text = t
	var l := find_child("Title", true, false)
	if l:
		l.text = t

func set_hint(text: String) -> void:
	hint_label.text = text

## Override: build the layout into `content`.
func _build() -> void:
	pass

## Override: back out one level (default: close).
func _on_cancel() -> void:
	close(null)

func close(result = null) -> void:
	if _done:
		return
	_done = true
	Audio.sfx("cancel")
	closed.emit(result)

func _input(event: InputEvent) -> void:
	if _locked or _done:
		return
	if event.is_action_pressed("cancel") or event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		_on_cancel()

## A button with the standard cursor and confirm sounds.
func make_button(text: String, cb: Callable, min_w := 0) -> Button:
	var b := UIKit.button(text, min_w)
	b.focus_entered.connect(func(): Audio.sfx("cursor"))
	b.pressed.connect(func():
		Audio.sfx("confirm")
		cb.call())
	return b

## Runs a nested menu through the Router with this one locked, then unlocks a frame later
## so the closing key press isn't read twice.
func open_child(name: String) -> Variant:
	_locked = true
	var r = await Router.open_menu(name)
	await get_tree().process_frame
	_locked = false
	return r

func party() -> Array:
	return Game.data.party

## Opens a scene that Router doesn't list (summary, popups) on top of this menu and waits for its `closed`.
func open_local(path: String, arg := "") -> Variant:
	_locked = true
	var scene: Node = load(path).instantiate()
	add_child(scene)
	if scene.has_method("setup"):
		scene.setup(arg)
	var r = await scene.closed
	scene.queue_free()
	await get_tree().process_frame
	_locked = false
	return r
