extends MenuBase
## New game: pick a look and type a name (keyboard or the on-screen letters). Closes with {name, sprite}.

const MAX_LEN := 10
const ROWS := ["ABCDEFGHIJKLM", "NOPQRSTUVWXYZ", "abcdefghijklm", "nopqrstuvwxyz"]

var _name := "Sam"
var _sprite := "player_a"
var _shown: Label
var _looks: Array = []

func _build() -> void:
	set_title("Who's setting off?")
	set_hint("Type your name, or pick letters        Enter  Done        Backspace  Delete")
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.add_theme_constant_override("separation", 14)
	content.add_child(col)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 24)
	col.add_child(top)
	for id in ["player_a", "player_b"]:
		var b := make_button("", func(): _pick_look(id), 150)
		b.custom_minimum_size = Vector2(150, 150)
		var tex := AtlasTexture.new()
		tex.atlas = load("res://art/sprites/chars/%s.png" % id)
		tex.region = Rect2(0, 0, 32, 48)  # facing down, standing
		var s := TextureRect.new()
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		s.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		s.set_anchors_preset(Control.PRESET_FULL_RECT)
		s.offset_left = 10
		s.offset_top = 10
		s.offset_right = -10
		s.offset_bottom = -10
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(s)
		top.add_child(b)
		_looks.append(b)
	var nm := VBoxContainer.new()
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(nm)
	nm.add_child(UIKit.label("Name", 24, UIKit.MUTED))
	_shown = UIKit.label("", 56, UIKit.GOLD)
	nm.add_child(_shown)
	var grid := GridContainer.new()
	grid.columns = 13
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	col.add_child(grid)
	var keys := []
	for row in ROWS:
		for ch in row:
			var b := make_button(ch, func(): _type(ch), 64)
			b.custom_minimum_size = Vector2(64, 52)
			grid.add_child(b)
			keys.append(b)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 12)
	col.add_child(bottom)
	for pair in [["Space", func(): _type(" ")], ["Delete", _delete], ["Done", _done_pressed]]:
		var b := make_button(pair[0], pair[1], 200)
		bottom.add_child(b)
	_refresh()
	UIKit.focus_later(keys[0])

func _pick_look(id: String) -> void:
	_sprite = id
	_refresh()

func _type(ch: String) -> void:
	if _name.length() < MAX_LEN:
		_name += ch
	_refresh()

func _delete() -> void:
	_name = _name.left(maxi(0, _name.length() - 1))
	_refresh()

func _done_pressed() -> void:
	var n := clean(_name)
	if n == "":
		Audio.sfx("bump")
		return
	close({"name": n, "sprite": _sprite})

func _on_cancel() -> void:
	_delete()

## Keyboard typing comes first here: letters (Z and X included) and space type, Backspace deletes,
## Enter finishes. Arrows still move round the on-screen letters, and the pad works as everywhere else.
func _input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k != null and k.pressed and not _locked and not _done:
		var ch := typed_char(k)
		if ch != "":
			_type(ch)
			get_viewport().set_input_as_handled()
			return
		if k.keycode == KEY_BACKSPACE:
			_delete()
			get_viewport().set_input_as_handled()
			return
		if k.keycode == KEY_ENTER or k.keycode == KEY_KP_ENTER:
			_done_pressed()
			get_viewport().set_input_as_handled()
			return
	super._input(event)

## The character a key types, or "" for keys that don't type (Enter, arrows, modifiers).
static func typed_char(k: InputEventKey) -> String:
	if k.ctrl_pressed or k.meta_pressed or k.alt_pressed or k.unicode == 0:
		return ""
	var ch := char(k.unicode)
	if k.unicode == 32 or (k.unicode < 127 and ((ch >= "a" and ch <= "z") or (ch >= "A" and ch <= "Z") or ch == "-" or ch == "'")):
		return ch
	return ""

func _refresh() -> void:
	_shown.text = _name + ("_" if _name.length() < MAX_LEN else "")
	for i in _looks.size():
		_looks[i].modulate = Color.WHITE if ["player_a", "player_b"][i] == _sprite else Color(1, 1, 1, 0.45)

## Trims spaces, collapses doubles, caps the length. Empty means "pick something".
static func clean(s: String) -> String:
	var out := s.strip_edges()
	while out.contains("  "):
		out = out.replace("  ", " ")
	return out.left(MAX_LEN)
