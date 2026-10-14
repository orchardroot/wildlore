class_name MapView
extends Control
## Draws the isles from data/world_map.json: coastlines, towns (visited bright, known dim, unbuilt hidden),
## the player's last town, and optional highlighted places (Creaturepedia habitats).

const SEA := Color("2b4157")
const LAND := Color("8fa66b")
const LAND_EDGE := Color("e9e2c8")
const DIM := Color("c9c2a8")
const LIT := Color("ffd166")

var highlight: Array = []   # zone ids to ring in heather purple
var zoom := 1.8             # around `centre` (map units); 1.0 shows all the isles
var centre := Vector2(-1, -1)
var font: Font

func _ready() -> void:
	clip_contents = true
	font = get_theme_default_font()
	resized.connect(queue_redraw)

func _xf() -> Array:
	var m := Travel.world_map()
	var space: Array = m.get("space", [1000, 1300])
	var k := minf(size.x / float(space[0]), size.y / float(space[1])) * zoom
	var c := centre if centre.x >= 0 else Vector2(space[0], space[1]) * 0.5
	var off := size * 0.5 - c * k
	# keep the map on screen: don't scroll past its own edges
	var w := Vector2(space[0], space[1]) * k
	off.x = clampf(off.x, size.x - w.x, 0.0) if w.x > size.x else (size.x - w.x) * 0.5
	off.y = clampf(off.y, size.y - w.y, 0.0) if w.y > size.y else (size.y - w.y) * 0.5
	return [k, off]

func _p(x: float, y: float, xf: Array) -> Vector2:
	return Vector2(x, y) * float(xf[0]) + xf[1]

func _draw() -> void:
	var m := Travel.world_map()
	var xf := _xf()
	draw_rect(Rect2(Vector2.ZERO, size), SEA)
	for key in m.get("outlines", {}):
		var pts := PackedVector2Array()
		for q in m.outlines[key]:
			pts.append(_p(q[0], q[1], xf))
		if pts.size() >= 3:
			var tris := Geometry2D.triangulate_polygon(pts)
			if tris.is_empty():
				draw_polyline(pts, LAND, 6.0)
			else:
				draw_colored_polygon(pts, LAND)
			var closed := pts.duplicate()
			closed.append(pts[0])
			draw_polyline(closed, LAND_EDGE, 2.0, true)
	var d: GameStateData = Game.data
	var here := str(d.flag("last_town")) if d.flag("last_town") else ""
	var labels: Array = []  # Rect2s already drawn, so neighbours like Macclesfield and Buxton don't overprint
	for town in m.get("towns", {}):
		var t: Dictionary = m.towns[town]
		if not FileAccess.file_exists("res://data/zones/%s.json" % town):
			continue
		var pos := _p(float(t.x), float(t.y), xf)
		var visited: bool = d.flag("visited_" + town) == true
		draw_circle(pos, 7.0 if visited else 5.0, LIT if visited else DIM)
		if visited:
			var txt := str(t.name)
			var ts := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
			# a close neighbour to the east pushes this label to the west, and vice versa
			var east_neighbour := false
			for other in m.towns:
				if other != town and d.flag("visited_" + other) == true:
					var op := _p(float(m.towns[other].x), float(m.towns[other].y), xf)
					if op.distance_to(pos) < 80.0 and op.x > pos.x:
						east_neighbour = true
			var tries := [Vector2(-10 - ts.x, 6), Vector2(10, 6)] if east_neighbour else [Vector2(10, 6), Vector2(-10 - ts.x, 6)]
			tries.append_array([Vector2(-ts.x * 0.5, -12), Vector2(-ts.x * 0.5, 24)])
			for o in tries:
				var r := Rect2(pos + o - Vector2(0, ts.y * 0.75), ts)
				if not labels.any(func(l): return l.intersects(r)):
					labels.append(r)
					draw_string(font, pos + o, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("f8f1dc"))
					break
		if town == here:
			draw_arc(pos, 13.0, 0, TAU, 24, Color("ff6b6b"), 3.0)
	for zid in highlight:
		var src: Dictionary = m.get("towns", {}).get(zid, m.get("places", {}).get(zid, {}))
		if not src.is_empty():
			draw_arc(_p(float(src.x), float(src.y), xf), 10.0, 0, TAU, 20, UIKit.HEATHER, 4.0)
