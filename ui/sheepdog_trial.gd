class_name SheepdogTrial
extends CanvasLayer
## The sheepdog trial overlay: arrows (or the pad) steer your lead creature round the field, the sheep drift away
## from it, and the aim is to drive all four through both gates into the pen before the clock runs out. Rules are
## in Sheepdog. `play` awaits the finished state; Cancel gives up (and keeps whatever is already penned).

const SCALE := 54.0

var _st: Dictionary
var _canvas: Control
var _done := false
var _label := ""
signal finished(state: Dictionary)

static func play(parent: Node, lead_speed: int, easy: bool, seed_text: String, label: String) -> Dictionary:
	var t := SheepdogTrial.new()
	t._st = Sheepdog.start(seed_text, lead_speed, easy)
	t._label = label
	parent.add_child(t)
	var st: Dictionary = await t.finished
	t.queue_free()
	return st

func _ready() -> void:
	layer = 20
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_field)
	add_child(_canvas)

func _process(delta: float) -> void:
	if _done:
		return
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	Sheepdog.step(_st, dir, delta)
	_canvas.queue_redraw()
	if Sheepdog.done(_st) or Input.is_action_just_pressed("cancel"):
		_done = true
		finished.emit(_st)

func _origin() -> Vector2:
	return (_canvas.size - Vector2(Sheepdog.W, Sheepdog.H) * SCALE) * 0.5

func _draw_field() -> void:
	var o := _origin()
	var field := Rect2(o, Vector2(Sheepdog.W, Sheepdog.H) * SCALE)
	_canvas.draw_rect(field.grow(10.0), Color(0.08, 0.1, 0.14, 0.9))
	_canvas.draw_rect(field, Color("6a8c43"))
	_canvas.draw_rect(Rect2(o + Vector2(Sheepdog.PEN_X, 0) * SCALE, Vector2(Sheepdog.W - Sheepdog.PEN_X, Sheepdog.H) * SCALE), Color("8aa35a"))
	for gx in Sheepdog.GATES:
		var gy: float = _st.gate_y
		var gap: float = _st.gap
		var top := o + Vector2(gx, 0) * SCALE
		_canvas.draw_line(top, o + Vector2(gx, gy - gap) * SCALE, Color("e8e4da"), 4.0)
		_canvas.draw_line(o + Vector2(gx, gy + gap) * SCALE, o + Vector2(gx, Sheepdog.H) * SCALE, Color("e8e4da"), 4.0)
	for s in _st.sheep:
		_canvas.draw_circle(o + s.p * SCALE, 9.0, Color("f4f1e8"))
		_canvas.draw_circle(o + (s.p + Vector2(0.14, -0.05)) * SCALE, 4.0, Color("3a3a3a"))
	_canvas.draw_circle(o + _st.dog * SCALE, 11.0, Color("2f5a9e"))
	var font := ThemeDB.fallback_font
	var head := "%s   Penned %d of %d   Time %d   (arrows to steer, Cancel to stop)" % [_label, Sheepdog.penned(_st), Sheepdog.SHEEP, ceili(float(_st.left))]
	_canvas.draw_string(font, o + Vector2(0, -18), head, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
