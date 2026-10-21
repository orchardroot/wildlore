class_name IslandStyles
extends RefCounted
## The Channel Islands: Jersey's rose granite house with its round-headed "Jersey arch" door and gable stacks,
## Guernsey's grey granite with white-painted window surrounds, the round coastal tower of Jersey's shore, and
## Guernsey's Little Chapel, a doll's-house church covered in pebbles, shells and broken china.
## Called from Landmarks.building (see the "jersey_granite" arms there). Same rules as Landmarks: vertex colour,
## low poly, origin at the footprint's north-west corner, door on the south.

const STYLES := ["jersey_granite", "guernsey_granite", "jersey_tower", "little_chapel"]
const JERSEY_ROSE := [Color("a8786a"), Color("b58472"), Color("9c7064")]  # Jersey granite is pink-red
const GUERNSEY_GREY := [Color("8f9498"), Color("9aa0a2"), Color("858a90")]
const SLATE := Color("4c5360")

## A Jersey farmhouse or town house: rose granite, slate roof, a round-headed door with a pale surround (the Jersey
## arch, often dated on its keystone) and a tall stack on each gable.
static func jersey_granite(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = JERSEY_ROSE[rng.randi() % JERSEY_ROSE.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, SLATE, 2, false, false)
	var hgt := 1.15 * 2 + 0.2
	for x in [0.05, w - 0.45]:
		Meshes.box(st, Vector3(x, hgt - 0.2, d * 0.5 - 0.2), Vector3(0.4, 1.7, 0.4), wall.darkened(0.12), wall.lightened(0.1))
		Meshes.box(st, Vector3(x - 0.03, hgt + 1.5, d * 0.5 - 0.23), Vector3(0.46, 0.1, 0.46), Color("d8cfc0"))
	if door_x >= 0:
		var pale := Color("e4dccb")
		Meshes.box(st, Vector3(door_x + 0.1, 0.16, d + 0.02), Vector3(0.1, 1.05, 0.06), pale)
		Meshes.box(st, Vector3(door_x + 0.8, 0.16, d + 0.02), Vector3(0.1, 1.05, 0.06), pale)
		Meshes.box(st, Vector3(door_x + 0.2, 1.1, d + 0.02), Vector3(0.6, 0.12, 0.06), pale)
		Meshes.box(st, Vector3(door_x + 0.38, 1.2, d + 0.02), Vector3(0.24, 0.1, 0.06), pale.darkened(0.1))

## A St Peter Port house: grey granite, painted white string course and window frames, slate roof, two chimney stacks.
static func guernsey_granite(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = GUERNSEY_GREY[rng.randi() % GUERNSEY_GREY.size()]
	Landmarks._house(st, wst, w, d, door_x, rng, wall, SLATE, 3 if d >= 3 else 2, true, false)
	var white := Color("eeeae0")
	Meshes.box(st, Vector3(0.0, 1.25, d), Vector3(w, 0.08, 0.06), white)
	for x in w:
		if x != door_x:
			Meshes.box(st, Vector3(x + 0.22, 0.32, d + 0.01), Vector3(0.56, 0.06, 0.05), white)

## A round coastal tower of the 1780s to 1800s, built against French invasion: a tapering granite drum with a flat
## parapet top, a small door up a step and slit windows. It stands at the front of its plot, door to the south.
static func jersey_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("a98270")
	var r := minf(float(w), 3.0) * 0.46
	var c := Vector3(w * 0.5, 0, d - r - 0.1)
	var h := 4.6
	Meshes.cylinder(st, c, r, 1.0, 12, stone.darkened(0.12))
	Meshes.cylinder(st, c + Vector3(0, 1.0, 0), r * 0.94, h - 1.0, 12, stone)
	Meshes.cylinder(st, c + Vector3(0, h, 0), r * 1.08, 0.35, 12, stone.lightened(0.08))
	for i in 8:  # the crenellated parapet
		var a := TAU * i / 8.0
		Meshes.box(st, c + Vector3(cos(a) * r * 0.98 - 0.15, h + 0.35, sin(a) * r * 0.98 - 0.15), Vector3(0.3, 0.3, 0.3), stone.lightened(0.1))
	for y in [2.0, 3.2]:
		Landmarks._window(st, wst, c.x - 0.1, y, c.z + r * 0.9, 0.2, 0.34, stone.darkened(0.25))
	if door_x >= 0:
		Meshes.box(st, Vector3(c.x - 0.28, 0.45, c.z + r - 0.14), Vector3(0.56, 0.9, 0.14), Color("2f2420"))
		Meshes.box(st, Vector3(c.x - 0.45, 0.0, c.z + r - 0.05), Vector3(0.9, 0.3, 0.4), stone.darkened(0.2))

## The Little Chapel at Les Vauxbelets: a tiny cream chapel with a little spire, every wall studded with pebbles,
## shells and china shards in many colours (a scatter of small coloured boxes, seeded so it never changes).
static func little_chapel(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var cream := Color("d8d0b8")
	var bw := minf(float(w), 4.0)
	var x0 := (w - bw) * 0.5
	var h := 2.0
	Meshes.box(st, Vector3(x0, 0, 0.3), Vector3(bw, h, d - 0.3), cream)
	var a := Vector3(x0 - 0.1, h, 0.2)
	var b := Vector3(x0 + bw + 0.1, h, 0.2)
	var c := Vector3(x0 + bw + 0.1, h, d + 0.1)
	var dd := Vector3(x0 - 0.1, h, d + 0.1)
	var r0 := Vector3(x0 + bw * 0.5, h + 1.0, 0.2)
	var r1 := Vector3(x0 + bw * 0.5, h + 1.0, d + 0.1)
	Meshes._quad(st, r1, r0, a, dd, Color("7a6a62"))
	Meshes._quad(st, r0, r1, c, b, Color("6a5a54"))
	Meshes._tri(st, dd, c, r1, cream.darkened(0.04))
	Meshes._tri(st, b, a, r0, cream.darkened(0.1))
	# spire over the door end
	Meshes.box(st, Vector3(x0 + bw * 0.5 - 0.3, h + 0.8, d - 1.0), Vector3(0.6, 0.7, 0.6), cream)
	Meshes.cone(st, Vector3(x0 + bw * 0.5, h + 1.5, d - 0.7), 0.5, 1.2, 6, Color("8a4a3a"), rng)
	var tones := [Color("c8503c"), Color("3c78b8"), Color("e8c040"), Color("5a9a5a"), Color("f0eee8"), Color("8a5aa8"), Color("e07a9a"), Color("2c3c58")]
	for i in 46:
		var px := x0 + 0.15 + rng.randf() * (bw - 0.45)
		var py := 0.25 + rng.randf() * (h - 0.5)
		if absf(px - (door_x + 0.5)) < 0.45 and py < 1.3:
			continue
		Meshes.box(st, Vector3(px, py, d + 0.0), Vector3(0.14 + rng.randf() * 0.1, 0.14, 0.05), tones[rng.randi() % tones.size()])
	for i in 18:  # the same on the west and east walls
		var pz := 0.5 + rng.randf() * (d - 0.9)
		var py2 := 0.25 + rng.randf() * (h - 0.5)
		Meshes.box(st, Vector3(x0 - 0.04, py2, pz), Vector3(0.05, 0.14, 0.14), tones[rng.randi() % tones.size()])
		Meshes.box(st, Vector3(x0 + bw - 0.01, py2, pz), Vector3(0.05, 0.14, 0.14), tones[rng.randi() % tones.size()])
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.22, 0.0, d - 0.02), Vector3(0.56, 1.0, 0.08), Color("4a3028"))
		Meshes.box(st, Vector3(door_x + 0.15, 1.0, d - 0.03), Vector3(0.7, 0.1, 0.09), Color("e8c040"))
