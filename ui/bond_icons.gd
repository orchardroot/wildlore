class_name BondIcons
extends RefCounted
## Little drawn icons for friendship and charms: a row of hearts (filled up to Bond.hearts) and a charm token.
## Drawn rather than font glyphs, so they look the same everywhere.

const HEART := Color("e8707a")
const EMPTY := Color(1, 1, 1, 0.18)
const CHARM := Color("c9b98a")

## One heart, filled or just an outline.
class Heart extends Control:
	var filled := true
	var colour := HEART

	func _init(px := 18.0, on := true) -> void:
		custom_minimum_size = Vector2(px, px)
		filled = on
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var s := size.x
		var pts := PackedVector2Array()
		for i in 24:  # the classic heart curve, scaled into the box
			var t := TAU * i / 24.0
			var x := 16.0 * pow(sin(t), 3)
			var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
			pts.append(Vector2(s * 0.5 + x * s / 36.0, s * 0.45 - y * s / 36.0))
		if filled:
			draw_colored_polygon(pts, colour)
		else:
			pts.append(pts[0])
			draw_polyline(pts, EMPTY, 1.5, true)

## A pebble with a hole through it (a hag stone): the sign for "holding a charm".
class Token extends Control:
	func _init(px := 16.0) -> void:
		custom_minimum_size = Vector2(px, px)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var c := size * 0.5
		var r := size.x * 0.45
		draw_circle(c, r, CHARM)
		draw_circle(c + Vector2(r * 0.15, -r * 0.1), r * 0.38, Color("1d2230"))
		draw_arc(c, r, 0, TAU, 20, Color("8a7d58"), 1.5, true)

## Five hearts, filled up to the creature's friendship.
static func hearts_row(friendship: int, px := 18.0) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 3)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var n := Bond.hearts(friendship)
	for i in Bond.HEART_AT.size():
		row.add_child(Heart.new(px, i < n))
	return row

## The party slot's compact form: one heart and a count.
static func heart_count(friendship: int, size := 20) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := Heart.new(size * 0.85, true)
	h.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(h)
	var l := UIKit.label(str(Bond.hearts(friendship)), size, UIKit.CREAM)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(l)
	return row
