class_name FishingBar
extends CanvasLayer
## The bite bar: a marker sweeps slowly to and fro; press Confirm while it is over the green sweet spot to land the
## fish. A few tries, no penalty for missing, and a wider and slower bar in the "easier fishing" setting. The numbers
## come from Fishing.bar; awaiting `play` gives true (landed) or false (it got away). Escape / Back gives up.

const W := 640.0
const H := 44.0

var _cfg: Dictionary
var _centre := 0.5
var _t := 0.0
var _tries := 0
var _done := false
var _msg := "Press Confirm when the float is over the green."
var _canvas: Control
signal finished(landed: bool)

static func play(parent: Node, tier: int, easy: bool, rng: Rng) -> bool:
	var bar := FishingBar.new()
	bar._cfg = Fishing.bar(tier, easy)
	bar._centre = Fishing.centre(rng, float(bar._cfg.half))
	bar._tries = int(bar._cfg.tries)
	parent.add_child(bar)
	var landed: bool = await bar.finished
	bar.queue_free()
	return landed

func _ready() -> void:
	layer = 20
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_bar)
	add_child(_canvas)

func _process(delta: float) -> void:
	if _done:
		return
	_t += delta
	_canvas.queue_redraw()
	if Input.is_action_just_pressed("confirm"):
		var m := Fishing.marker(_t, float(_cfg.period))
		if Fishing.hit(m, _centre, float(_cfg.half)):
			_end(true)
		else:
			_tries -= 1
			if _tries <= 0:
				_end(false)
			else:
				_msg = "Missed. It's still nibbling: %d %s left." % [_tries, "try" if _tries == 1 else "tries"]
	elif Input.is_action_just_pressed("cancel"):
		_end(false)

func _end(landed: bool) -> void:
	_done = true
	Audio.sfx("confirm" if landed else "cursor")
	finished.emit(landed)

func _draw_bar() -> void:
	var vp := _canvas.size
	var r := Rect2((vp.x - W) * 0.5, vp.y * 0.72, W, H)
	_canvas.draw_rect(r.grow(10.0), Color(0.08, 0.1, 0.14, 0.88))
	_canvas.draw_rect(r, Color("2c3a4c"))
	var half := float(_cfg.half)
	_canvas.draw_rect(Rect2(r.position.x + (_centre - half) * W, r.position.y, half * 2.0 * W, H), Color("4fae6a"))
	var mx := r.position.x + Fishing.marker(_t, float(_cfg.period)) * W
	_canvas.draw_rect(Rect2(mx - 4.0, r.position.y - 8.0, 8.0, H + 16.0), Color("f4e3a1"))
	var font := ThemeDB.fallback_font
	_canvas.draw_string(font, Vector2(r.position.x, r.position.y - 22.0), _msg, HORIZONTAL_ALIGNMENT_LEFT, W, 22, Color("f3ecd8"))
