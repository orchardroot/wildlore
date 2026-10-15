class_name TypeGlyph
extends Control
## A small shape drawn before a type's name on every type chip, so types never rely on colour alone.
## Shapes are polygons in a unit square (see `polygons`), drawn in code at any size (14 px by default).

const SHAPES := {
	"kin": "heart", "hedgerow": "leaf", "brook": "drop", "tide": "wave", "hearth": "flame", "gale": "gust",
	"storm": "bolt", "frost": "snowflake", "stone": "mountain", "bog": "bubbles", "iron": "hexagon",
	"urban": "skyline", "fae": "sparkle", "spirit": "ghost", "brawn": "chevrons", "night": "crescent",
}

var type_id := ""
var colour := Color.WHITE

static func make(t: String, col: Color, px := 14) -> TypeGlyph:
	var g := TypeGlyph.new()
	g.type_id = t
	g.colour = col
	g.custom_minimum_size = Vector2(px, px)
	g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g

func _draw() -> void:
	for poly in polygons(type_id):
		var pts := PackedVector2Array()
		for p in poly:
			pts.append(p * size)
		if Geometry2D.triangulate_polygon(pts).size() >= 3:
			draw_colored_polygon(pts, colour)

## The glyph as polygons with coordinates in 0..1.
static func polygons(type_id: String) -> Array:
	match SHAPES.get(type_id, "disc"):
		"heart":  # kin: family
			var h := PackedVector2Array()
			for i in 28:
				var t := TAU * i / 28.0
				h.append(Vector2(0.5 + 0.5 * pow(sin(t), 3.0), 0.46 - (13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) / 34.0))
			return [h]
		"leaf":  # a pointed oval on the diagonal
			return [_leaf()]
		"drop":
			var d := PackedVector2Array([Vector2(0.5, 0.02)])
			d.append_array(_arc(0.5, 0.62, 0.36, 0.36, -20, 200, 14))
			return [d]
		"wave":
			var top := []
			var bot := []
			for i in 13:
				var x := i / 12.0
				var y := 0.5 + 0.22 * sin(x * TAU * 1.5)
				top.append(Vector2(x, y - 0.17))
				bot.append(Vector2(x, y + 0.17))
			bot.reverse()
			return [PackedVector2Array(top + bot)]
		"flame":
			return [PackedVector2Array([Vector2(0.5, 0.0), Vector2(0.68, 0.28), Vector2(0.78, 0.2), Vector2(0.92, 0.55), Vector2(0.84, 0.82),
				Vector2(0.62, 0.98), Vector2(0.38, 0.98), Vector2(0.16, 0.82), Vector2(0.1, 0.55), Vector2(0.26, 0.34), Vector2(0.36, 0.46)])]
		"gust":  # three staggered bars
			return [_rect(0.05, 0.12, 0.8, 0.18), _rect(0.2, 0.41, 0.75, 0.18), _rect(0.05, 0.7, 0.55, 0.18)]
		"bolt":
			return [PackedVector2Array([Vector2(0.62, 0.0), Vector2(0.18, 0.56), Vector2(0.45, 0.56), Vector2(0.34, 1.0), Vector2(0.84, 0.4), Vector2(0.55, 0.4)])]
		"snowflake":  # three crossing bars
			var out := []
			for a in [0.0, PI / 3.0, 2.0 * PI / 3.0]:
				out.append(_rot_rect(0.5, 0.5, 0.96, 0.15, a))
			return out
		"mountain":
			return [PackedVector2Array([Vector2(0.0, 0.95), Vector2(0.34, 0.2), Vector2(0.5, 0.5), Vector2(0.66, 0.05), Vector2(1.0, 0.95)])]
		"bubbles":
			return [_ellipse(0.3, 0.7, 0.24, 0.24, 12), _ellipse(0.72, 0.62, 0.2, 0.2, 12), _ellipse(0.52, 0.22, 0.17, 0.17, 12)]
		"hexagon":
			return [_ngon(0.5, 0.5, 0.5, 6, 0.0)]
		"skyline":
			return [PackedVector2Array([Vector2(0.0, 1.0), Vector2(0.0, 0.5), Vector2(0.25, 0.5), Vector2(0.25, 0.2), Vector2(0.55, 0.2), Vector2(0.55, 0.0),
				Vector2(0.7, 0.0), Vector2(0.7, 0.62), Vector2(1.0, 0.62), Vector2(1.0, 1.0)])]
		"sparkle":  # a four-pointed star
			return [PackedVector2Array([Vector2(0.5, 0.0), Vector2(0.62, 0.38), Vector2(1.0, 0.5), Vector2(0.62, 0.62), Vector2(0.5, 1.0),
				Vector2(0.38, 0.62), Vector2(0.0, 0.5), Vector2(0.38, 0.38)])]
		"ghost":  # round head, wavy hem
			var g := _arc(0.5, 0.45, 0.42, 0.42, 180, 360, 12)
			g.append(Vector2(0.92, 1.0))
			g.append(Vector2(0.76, 0.84))
			g.append(Vector2(0.62, 1.0))
			g.append(Vector2(0.5, 0.84))
			g.append(Vector2(0.38, 1.0))
			g.append(Vector2(0.24, 0.84))
			g.append(Vector2(0.08, 1.0))
			return [g]
		"chevrons":
			return [PackedVector2Array([Vector2(0.5, 0.0), Vector2(1.0, 0.42), Vector2(1.0, 0.62), Vector2(0.5, 0.2), Vector2(0.0, 0.62), Vector2(0.0, 0.42)]),
				PackedVector2Array([Vector2(0.5, 0.42), Vector2(1.0, 0.84), Vector2(1.0, 1.0), Vector2(0.5, 0.62), Vector2(0.0, 1.0), Vector2(0.0, 0.84)])]
		"crescent":
			var outer := _arc(0.5, 0.5, 0.48, 0.48, 34.6, 325.4, 16)  # horns point right
			var inner := _arc(0.66, 0.5, 0.36, 0.36, 310.7, 49.3, 16)
			var cres := PackedVector2Array(outer)
			cres.append_array(inner)
			return [cres]
	return [_ellipse(0.5, 0.5, 0.45, 0.45, 16)]

static func _arc(cx: float, cy: float, rx: float, ry: float, from_deg: float, to_deg: float, steps: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in steps + 1:
		var a := deg_to_rad(lerpf(from_deg, to_deg, i / float(steps)))
		out.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	return out

static func _ellipse(cx: float, cy: float, rx: float, ry: float, steps: int) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in steps:
		var a := TAU * i / steps
		out.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry))
	return out

static func _ngon(cx: float, cy: float, r: float, n: int, rot: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		var a := rot + TAU * i / n
		out.append(Vector2(cx + cos(a) * r, cy + sin(a) * r))
	return out

static func _rect(x: float, y: float, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])

static func _rot_rect(cx: float, cy: float, w: float, h: float, angle: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for c in [Vector2(-w, -h), Vector2(w, -h), Vector2(w, h), Vector2(-w, h)]:
		out.append(Vector2(cx, cy) + (c * 0.5).rotated(angle))
	return out

static func _leaf() -> PackedVector2Array:
	var out := PackedVector2Array()
	var a := Vector2(0.08, 0.92)
	var b := Vector2(0.94, 0.06)
	var along := (b - a)
	var perp := Vector2(-along.y, along.x).normalized()
	for i in 13:  # one side bulging out
		var t := i / 12.0
		out.append(a.lerp(b, t) + perp * sin(t * PI) * 0.36)
	for i in range(11, 0, -1):
		var t := i / 12.0
		out.append(a.lerp(b, t) - perp * sin(t * PI) * 0.36)
	return out
