class_name WirelessMeshes
extends RefCounted
## Meshes for the wireless set (a sign of kind "radio") and the round heritage plaque (kind "plaque").
## Both face +z (south), the way a building's front wall and a north-wall sideboard do.

const PLAQUE_R := 0.19
const PLAQUE_HEIGHT := 0.72   # centre height up the wall, above the door's ground
const PLAQUE_BLUE := Color("2a56a8")
const PLAQUE_GREEN := Color("2f7a4a")   # the Irish and Scottish schemes are not blue everywhere

## A flat disc on the XY plane at depth z, facing +z (Godot winds front faces clockwise).
static func _disc(st: SurfaceTool, c: Vector3, r: float, col: Color, sides := 20) -> void:
	for i in sides:
		var a0 := -TAU * i / sides
		var a1 := -TAU * (i + 1) / sides
		Meshes._tri(st, c, c + Vector3(cos(a0), sin(a0), 0) * r, c + Vector3(cos(a1), sin(a1), 0) * r, col)

## Origin is the plaque's centre on the wall's face, so the caller puts it at the wall.
static func plaque(green := false) -> ArrayMesh:
	var st := Meshes._st()
	var body: Color = PLAQUE_GREEN if green else PLAQUE_BLUE
	var cream := Color("f3eedc")
	_disc(st, Vector3(0, PLAQUE_HEIGHT, -0.004), PLAQUE_R + 0.015, body.darkened(0.45))
	_disc(st, Vector3(0, PLAQUE_HEIGHT, 0.004), PLAQUE_R, cream)
	_disc(st, Vector3(0, PLAQUE_HEIGHT, 0.010), PLAQUE_R - 0.022, body)
	# three lines of "lettering"
	Meshes.box(st, Vector3(-0.085, PLAQUE_HEIGHT + 0.05, 0.011), Vector3(0.17, 0.016, 0.004), cream, cream)
	Meshes.box(st, Vector3(-0.1, PLAQUE_HEIGHT + 0.008, 0.011), Vector3(0.2, 0.016, 0.004), cream, cream)
	Meshes.box(st, Vector3(-0.07, PLAQUE_HEIGHT - 0.04, 0.011), Vector3(0.14, 0.016, 0.004), cream, cream)
	return Meshes._finish(st)

## A cabinet wireless on a little sideboard, speaker cloth on the left, dial and knobs on the right, an aerial wire.
## Variant 1 has no sideboard: the set stands on a counter that is already there (Mum's kitchen).
static func radio(variant := 0) -> ArrayMesh:
	var st := Meshes._st()
	var wood := Color("6b4a32")
	var set_wood := Color("8a5a35")
	if variant == 0:
		Meshes.box(st, Vector3(-0.42, 0, -0.44), Vector3(0.84, 0.5, 0.34), wood)
		Meshes.box(st, Vector3(-0.36, 0.06, -0.1), Vector3(0.72, 0.36, 0.02), wood.darkened(0.3))  # cupboard front
	Meshes.box(st, Vector3(-0.27, 0.5, -0.4), Vector3(0.54, 0.34, 0.24), set_wood)
	Meshes.box(st, Vector3(-0.23, 0.55, -0.16), Vector3(0.24, 0.24, 0.02), Color("d9c58f"))   # speaker cloth
	Meshes.box(st, Vector3(-0.2, 0.62, -0.145), Vector3(0.18, 0.02, 0.01), Color("a58f5a"), Color("a58f5a"))
	Meshes.box(st, Vector3(-0.2, 0.7, -0.145), Vector3(0.18, 0.02, 0.01), Color("a58f5a"), Color("a58f5a"))
	Meshes.box(st, Vector3(0.04, 0.6, -0.16), Vector3(0.18, 0.18, 0.02), Color("f2e8c2"))     # dial plate
	Meshes.box(st, Vector3(0.07, 0.69, -0.14), Vector3(0.12, 0.02, 0.01), Color("b0472f"), Color("b0472f"))  # the tuning needle
	Meshes.box(st, Vector3(0.05, 0.54, -0.15), Vector3(0.05, 0.05, 0.03), Color("2b1e16"))
	Meshes.box(st, Vector3(0.16, 0.54, -0.15), Vector3(0.05, 0.05, 0.03), Color("2b1e16"))
	Meshes.box(st, Vector3(0.18, 0.84, -0.3), Vector3(0.012, 0.22, 0.012), Color("2b1e16"))   # aerial
	return Meshes._finish(st)
