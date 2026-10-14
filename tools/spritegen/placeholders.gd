extends RefCounted
## Friendly "?" in a dashed circle, for creatures and characters whose art is missing.

const Canvas = preload("res://tools/spritegen/canvas.gd")

const GLYPH := [
	"01110",
	"10001",
	"00001",
	"00010",
	"00100",
	"00000",
	"00100",
]

static func _stamp(cv, cx: float, cy: float, ring_r: float, scale: int, fill: Color, ink: Color) -> void:
	var m = cv.ellipse_mask(cx, cy, ring_r * 2.0, ring_r * 2.0)
	for j in m.h:
		for i in m.w:
			if m.bits[j * m.w + i] == 0:
				continue
			var x: int = m.x0 + i
			var y: int = m.y0 + j
			var d := Vector2(x + 0.5 - cx, y + 0.5 - cy).length()
			if d < ring_r - maxf(1.0, ring_r * 0.07):
				cv.img.set_pixel(x, y, fill)
			else:
				var a := atan2(y + 0.5 - cy, x + 0.5 - cx)
				var seg := int(floor((a + PI) / TAU * (ring_r * 1.4)))
				if seg % 2 == 0:
					cv.img.set_pixel(x, y, ink)
	var gw := 5 * scale
	var gh := 7 * scale
	var ox := int(round(cx - gw * 0.5))
	var oy := int(round(cy - gh * 0.5))
	for gy in 7:
		for gx in 5:
			if GLYPH[gy][gx] == "1":
				for sy in scale:
					for sx in scale:
						cv.px(ox + gx * scale + sx, oy + gy * scale + sy, ink)

static func creature_sheet() -> Image:
	var out := Image.create(192, 96, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	for f in 2:
		var cv = Canvas.new(96, 96)
		_stamp(cv, 48, 52 + f * 1.0, 34, 5, Color("#dcd6ea"), Color("#5b4f7a"))
		out.blit_rect(cv.img, Rect2i(0, 0, 96, 96), Vector2i(f * 96, 0))
	return out

static func creature_icon() -> Image:
	var cv = Canvas.new(32, 32)
	_stamp(cv, 16, 16, 13, 2, Color("#dcd6ea"), Color("#5b4f7a"))
	return cv.img

static func char_sheet() -> Image:
	var out := Image.create(96, 192, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	for row in 4:
		for col in 3:
			var cv = Canvas.new(32, 48)
			_stamp(cv, 16, 26 + (1 if col != 1 else 0), 14, 2, Color("#dcd6ea"), Color("#5b4f7a"))
			out.blit_rect(cv.img, Rect2i(0, 0, 32, 48), Vector2i(col * 32, row * 48))
	return out
