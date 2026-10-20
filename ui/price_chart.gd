class_name PriceChart
extends Control
## A small line chart for the bureau, the Exchange and the Doggerel kiosk: the last few days of a price, with a soft
## fill under the line, three faint gridlines labelled at the right, the day's dot, and "14 days ago" / "today" along
## the bottom. Drawn once per set_values (no per-frame work). Days at or below `floor_mark` (a pulled rug) go red.

const GRID := Color(0.95, 0.91, 0.81, 0.10)
const AXIS := Color(0.66, 0.64, 0.58)
const UP := Color("8fd18a")
const DOWN := Color("e9998c")
const PAD_L := 8.0
const PAD_R := 74.0      # room for the price labels
const PAD_T := 10.0
const PAD_B := 26.0

var values: Array = []
var label_fn: Callable = func(v: float) -> String: return "%.2f" % v
var line_colour := Color(0, 0, 0, 0)   # transparent: green if up over the window, red if down
var font_size := 16
var floor_mark := -1.0
var caption_left := ""
var caption_right := "today"

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(240, 140)
	resized.connect(queue_redraw)

func set_values(v: Array, labels: Callable, left_caption := "") -> void:
	values = v
	label_fn = labels
	caption_left = left_caption if left_caption != "" else "%d days ago" % maxi(0, v.size() - 1)
	queue_redraw()

func _colour() -> Color:
	if line_colour.a > 0.0:
		return line_colour
	if values.size() < 2:
		return UP
	return UP if float(values.back()) >= float(values[0]) else DOWN

func _draw() -> void:
	var f: Font = ThemeDB.fallback_font
	var r := Rect2(Vector2(PAD_L, PAD_T), size - Vector2(PAD_L + PAD_R, PAD_T + PAD_B))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.05, 0.08, 0.55))
	if values.size() < 2 or r.size.x < 20 or r.size.y < 20:
		return
	var lo := INF
	var hi := -INF
	for v in values:
		lo = minf(lo, float(v))
		hi = maxf(hi, float(v))
	var span := hi - lo
	if span < hi * 0.002:  # a flat line still gets a little room
		span = maxf(hi * 0.004, 0.0001)
		lo -= span * 0.5
		hi += span * 0.5
	lo -= span * 0.08
	hi += span * 0.08
	var to_y := func(v: float) -> float: return r.position.y + r.size.y * (1.0 - (v - lo) / (hi - lo))
	for i in 3:  # gridlines at the bottom, middle and top of the data, labelled
		var gv: float = lerpf(lo + span * 0.08, hi - span * 0.08, i / 2.0)
		var gy: float = to_y.call(gv)
		draw_line(Vector2(r.position.x, gy), Vector2(r.end.x, gy), GRID, 1.0)
		draw_string(f, Vector2(r.end.x + 6, gy + font_size * 0.35), str(label_fn.call(gv)), HORIZONTAL_ALIGNMENT_LEFT, PAD_R - 6, font_size, AXIS)
	var pts := PackedVector2Array()
	var n := values.size()
	for i in n:
		pts.append(Vector2(r.position.x + r.size.x * i / float(n - 1), to_y.call(float(values[i]))))
	var col := _colour()
	var poly := PackedVector2Array(pts)
	poly.append(Vector2(r.end.x, r.end.y))
	poly.append(Vector2(r.position.x, r.end.y))
	draw_colored_polygon(poly, Color(col, 0.16))
	draw_polyline(pts, col, 3.0, true)
	for i in n:
		if floor_mark >= 0.0 and float(values[i]) <= floor_mark:
			draw_circle(pts[i], 5.0, DOWN)
	draw_circle(pts[n - 1], 6.0, Color(col, 0.35))
	draw_circle(pts[n - 1], 4.0, col)
	draw_line(Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.end.y), Color(AXIS, 0.5), 1.0)
	draw_string(f, Vector2(r.position.x, size.y - 6), caption_left, HORIZONTAL_ALIGNMENT_LEFT, r.size.x / 2.0, font_size, AXIS)
	draw_string(f, Vector2(r.position.x + r.size.x / 2.0, size.y - 6), caption_right, HORIZONTAL_ALIGNMENT_RIGHT, r.size.x / 2.0, font_size, AXIS)
