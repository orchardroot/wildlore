class_name OverseasStyles
extends RefCounted
## 3.3 "Overseas": RAF Brize Norton, Gibraltar and the Sovereign Base Areas of Akrotiri and Dhekelia. Called from
## Landmarks.building (see the "raf_hangar" arms there). Same rules as Landmarks: vertex colour, low poly, origin at
## the footprint's north-west corner, door on the south face.

const STYLES := ["raf_hangar", "control_tower", "raf_aircraft", "raf_block", "gib_house", "gib_rock", "europa_lighthouse",
	"flat_house", "greek_theatre", "raf_terminal"]

const RAF_GREY := Color("9aa3ab")
const RAF_BLUE := Color("2a4a86")
const LIMESTONE := Color("c9c0aa")
const ROCK_GREY := Color("a9a493")
const PASTELS := [Color("e8c98a"), Color("e3a89a"), Color("a9c7d8"), Color("e9dfc0"), Color("cfa27a"), Color("b8cfa4")]
const SHUTTER := Color("3e6b4a")
const PANTILE := Color("b4623e")
const SANDSTONE := Color("d8c39a")

## A large aircraft hangar: pale cladding, a barrel roof, a big dark door-gap with a small person-door beside it.
static func raf_hangar(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var clad := RAF_GREY.lightened(0.1)
	var h := 2.2
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), clad, clad.darkened(0.1))
	# barrel roof as three stepped slabs, then a ridge
	var steps := [[0.0, 0.0, 0.25], [0.12, 0.35, 0.3], [0.3, 0.6, 0.3]]
	for s in steps:
		var inset: float = w * float(s[0]) * 0.5
		Meshes.box(st, Vector3(inset, h + float(s[1]), 0.0), Vector3(w - inset * 2.0, float(s[2]), d), clad.darkened(0.04), clad.lightened(0.12))
	# the great door, across the middle of the south face, with a dark gap and tracks
	var gw := maxf(2.0, w - 3.0)
	Meshes.box(st, Vector3((w - gw) * 0.5, 0.0, d - 0.12), Vector3(gw, h - 0.25, 0.06), Color("4a5260"))
	for i in range(1, int(gw)):
		Meshes.box(st, Vector3((w - gw) * 0.5 + i, 0.0, d - 0.14), Vector3(0.05, h - 0.25, 0.04), Color("333a46"))
	Meshes.box(st, Vector3((w - gw) * 0.5, h - 0.25, d - 0.15), Vector3(gw, 0.1, 0.1), RAF_BLUE)
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.02, clad, 0.9)

## An air traffic control tower: a block with a tall slim shaft and a glazed watch room, lit at night, radar on top.
static func control_tower(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("d8d6cc")
	Meshes.box(st, Vector3(0.1, 0, 0.3), Vector3(w - 0.2, 1.3, d - 0.5), wall, wall.darkened(0.1))
	Meshes.box(st, Vector3(0.0, 1.3, 0.2), Vector3(w, 0.12, d - 0.3), RAF_BLUE)
	for x in range(w):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.1, 0.45, d - 0.2, 0.8, 0.6, Color("5a6674"))
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.2, wall, 0.9)
	var cx := w * 0.5 - 0.35
	var cz := d * 0.4
	Meshes.box(st, Vector3(cx, 1.4, cz), Vector3(0.7, 3.6, 0.7), wall, wall.lightened(0.05))
	Meshes.box(st, Vector3(cx - 0.55, 5.0, cz - 0.55), Vector3(1.8, 0.14, 1.8), Color("e8e6dc"))
	Meshes.box(st, Vector3(cx - 0.45, 5.14, cz - 0.45), Vector3(1.6, 0.8, 1.6), Color("3e4c5a"))
	Meshes.box(wst, Vector3(cx - 0.48, 5.2, cz - 0.48), Vector3(1.66, 0.62, 1.66), Landmarks.window_colour(Landmarks._wr))
	Meshes.box(st, Vector3(cx - 0.55, 5.95, cz - 0.55), Vector3(1.8, 0.12, 1.8), Color("e8e6dc"))
	# radar bar and mast
	Meshes.box(st, Vector3(cx + 0.3, 6.07, cz + 0.3), Vector3(0.1, 0.5, 0.1), Color("555a62"))
	Meshes.box(st, Vector3(cx - 0.25, 6.45, cz + 0.32), Vector3(1.2, 0.28, 0.06), Color("c8c8c0"))
	Meshes.box(st, Vector3(cx + 0.1, 6.07, cz + 0.1), Vector3(0.04, 0.9, 0.04), Color("c83030"))

## A big grey RAF transport (a Voyager or an Atlas): long fuselage, high swept wings, tailplane and fin, engines
## slung under the wings, roundels on the fin. There is no door: it is something to look at on the apron.
static func raf_aircraft(st: SurfaceTool, w: int, d: int) -> void:
	var hull := Color("8d949c")
	var belly := Color("c6cbd0")
	var zc := d * 0.5
	var y0 := 0.5
	# wheels
	for p in [[w * 0.28, 0.0], [w * 0.62, -0.36], [w * 0.62, 0.36]]:
		Meshes.box(st, Vector3(p[0], 0.0, zc + p[1] - 0.12), Vector3(0.3, y0, 0.24), Color("2a2c30"))
	Meshes.box(st, Vector3(0.6, y0, zc - 0.5), Vector3(w - 1.7, 0.95, 1.0), hull, belly)
	Meshes.box(st, Vector3(0.25, y0 + 0.12, zc - 0.4), Vector3(0.45, 0.7, 0.8), hull.lightened(0.04))         # the nose
	Meshes.box(st, Vector3(0.45, y0 + 0.62, zc - 0.3), Vector3(0.28, 0.2, 0.6), Color("2a3442"))              # cockpit glass
	Meshes.box(st, Vector3(w - 1.2, y0 + 0.35, zc - 0.34), Vector3(1.1, 0.6, 0.68), hull.darkened(0.04))     # tail cone
	Meshes.box(st, Vector3(w - 1.0, y0 + 0.9, zc - 0.05), Vector3(0.6, 1.0, 0.1), hull.lightened(0.06))      # fin
	Meshes.box(st, Vector3(w - 0.9, y0 + 1.4, zc - 0.04), Vector3(0.22, 0.22, 0.12), RAF_BLUE)               # roundel on the fin
	Meshes.box(st, Vector3(w - 1.0, y0 + 0.5, zc - 1.0), Vector3(0.5, 0.08, 2.0), hull)                       # tailplane
	var wx := w * 0.38
	Meshes.box(st, Vector3(wx, y0 + 0.75, zc - 2.0), Vector3(1.1, 0.1, 4.0), hull.lightened(0.03))            # wings
	for zz in [zc - 1.1, zc + 0.7]:
		Meshes.box(st, Vector3(wx - 0.3, y0 + 0.45, zz), Vector3(0.9, 0.34, 0.4), hull.darkened(0.14))         # engines
		Meshes.box(st, Vector3(wx - 0.34, y0 + 0.5, zz + 0.04), Vector3(0.05, 0.26, 0.32), Color("2a2a2e"))
	Meshes.box(st, Vector3(1.4, y0 + 0.4, zc + 0.48), Vector3(w - 3.2, 0.08, 0.04), RAF_BLUE)                # cheat line
	for x in range(2, w - 3, 1):
		Meshes.box(st, Vector3(x + 0.2, y0 + 0.62, zc + 0.5), Vector3(0.16, 0.12, 0.02), Color("2a3442"))

## A 1930s-to-1960s station building: brick, flat roof, windows in rows, a flagpole and a blue band.
static func raf_block(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var brick := Color("a9755a") if rng.randf() < 0.6 else Color("b8a78a")
	var h := 2.7
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), brick, brick.darkened(0.2))
	Meshes.box(st, Vector3(0.0, h, 0.0), Vector3(w, 0.14, d), Color("dcd8cc"))
	Meshes.box(st, Vector3(0.0, 1.3, 0.0), Vector3(w, 0.07, d + 0.04), RAF_BLUE)
	for row in [0.3, 1.5]:
		for x in range(w):
			if row < 1.0 and x == door_x:
				continue
			Landmarks._window(st, wst, x + 0.14, row + 0.1, d, 0.72, 0.8, Color("e8e4d8"))
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.02, brick, 1.0)
		Meshes.box(st, Vector3(door_x - 0.1, 1.2, d - 0.05), Vector3(1.2, 0.07, 0.34), Color("dcd8cc"))   # canopy
	Meshes.box(st, Vector3(w - 0.55, h, d * 0.5), Vector3(0.07, 1.0, 0.07), Color("e4e2da"))
	Meshes.box(st, Vector3(w - 0.4, h + 0.62, d * 0.5 + 0.01), Vector3(0.34, 0.24, 0.02), Color("2a4a86"))

## An air terminal: long low white building, a deep blue roof edge, a glazed front with a canopy over the door,
## a squat tower at one end and a Union flag on a pole.
static func raf_terminal(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var wall := Color("e8e6de")
	var h := 1.7
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall, Color("8a8e94"))
	Meshes.box(st, Vector3(-0.1, h, -0.1), Vector3(w + 0.2, 0.22, d + 0.3), RAF_BLUE)
	Meshes.box(st, Vector3(-0.1, h + 0.22, -0.1), Vector3(w + 0.2, 0.08, d + 0.3), Color("f4f4f0"))
	for x in w:
		if abs(x - door_x) > 0:
			Landmarks._window(st, wst, x + 0.06, 0.28, d, 0.88, 1.05, Color("46525e"))
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x - 0.15, 1.35, d - 0.02), Vector3(1.3, 0.1, 0.55), RAF_BLUE)
		Landmarks._door(st, door_x, d - 0.02, wall, 1.1)
	var tx := w - 1.5
	Meshes.box(st, Vector3(tx, h + 0.3, d * 0.3), Vector3(1.1, 1.0, 1.1), wall)
	Meshes.box(st, Vector3(tx - 0.1, h + 1.3, d * 0.3 - 0.1), Vector3(1.3, 0.14, 1.3), RAF_BLUE)
	Meshes.box(st, Vector3(tx + 0.5, h + 1.44, d * 0.3 + 0.5), Vector3(0.06, 0.8, 0.06), Color("c83030"))
	# the flagpole by the door and a small Union flag
	var fx := 0.5
	Meshes.box(st, Vector3(fx, 0, d + 0.25), Vector3(0.07, 2.4, 0.07), Color("e4e2da"))
	Meshes.box(st, Vector3(fx + 0.07, 1.8, d + 0.26), Vector3(0.55, 0.36, 0.03), Color("1f3f8f"))
	Meshes.box(st, Vector3(fx + 0.07, 1.94, d + 0.24), Vector3(0.55, 0.07, 0.03), Color("f4f1e8"))
	Meshes.box(st, Vector3(fx + 0.3, 1.8, d + 0.24), Vector3(0.07, 0.36, 0.03), Color("f4f1e8"))
	Meshes.box(st, Vector3(fx + 0.07, 1.96, d + 0.23), Vector3(0.55, 0.035, 0.03), Color("c8102e"))
	Meshes.box(st, Vector3(fx + 0.315, 1.8, d + 0.23), Vector3(0.035, 0.36, 0.03), Color("c8102e"))

## Gibraltar's townhouses: Genoese and Georgian, pastel stucco, green louvred shutters, wrought-iron balconies, pantile
## or parapet roofs. Each one takes its colour from the seed so Main Street is not one colour.
static func gib_house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = PASTELS[rng.randi() % PASTELS.size()]
	var storeys := 3
	var h := 1.1 * storeys + 0.2
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall)
	Meshes.box(st, Vector3(0, 0, 0), Vector3(w, 0.16, d), wall.darkened(0.3))
	Meshes.box(st, Vector3(-0.04, h, -0.04), Vector3(w + 0.08, 0.16, d + 0.08), wall.lightened(0.18))        # cornice
	if rng.randf() < 0.5:
		Landmarks._roof_at(st, 0.0, w, 0.1, d - 0.1, h + 0.16, 0.55, PANTILE, wall)
	for s in range(storeys):
		for x in range(w):
			if s == 0 and x == door_x:
				continue
			var y := 0.3 + s * 1.1
			Landmarks._window(st, wst, x + 0.2, y, d, 0.6, 0.72, SHUTTER)
			Meshes.box(st, Vector3(x + 0.12, y - 0.04, d - 0.04), Vector3(0.12, 0.84, 0.03), SHUTTER.darkened(0.1))
			Meshes.box(st, Vector3(x + 0.76, y - 0.04, d - 0.04), Vector3(0.12, 0.84, 0.03), SHUTTER.darkened(0.1))
			if s == 1:
				Meshes.box(st, Vector3(x + 0.05, y - 0.02, d), Vector3(0.9, 0.06, 0.3), Color("2a2a30"))      # balcony floor
				Meshes.box(st, Vector3(x + 0.05, y + 0.28, d + 0.26), Vector3(0.9, 0.04, 0.04), Color("2a2a30"))
	Landmarks._door(st, door_x, d - 0.02, wall, 1.0)

## The Rock: a great ridge of Jurassic limestone, craggy blobs rising towards the sheer east end, scrub-green
## shoulders on the western front, with a mast on the summit. Door: a tunnel mouth at the foot.
static func gib_rock(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var rock := ROCK_GREY
	var scrub := Color("77824f")
	var n := maxi(4, int(w / 3.0))
	var top := 0.0
	var top_x := 0.0
	for i in n:
		var k: float = float(i) / float(n - 1)
		var cx: float = 1.5 + k * (w - 3.0)
		var peak: float = 3.0 + 4.2 * pow(k, 0.8) + rng.randf() * 0.7
		var cz: float = d * 0.38 + rng.randf() * 0.4
		var col: Color = rock.darkened(rng.randf() * 0.12) if i % 2 == 0 else rock.lightened(rng.randf() * 0.06)
		Meshes.blob(st, Vector3(cx, peak * 0.5, cz), Vector3(w / float(n) * 0.85 + 0.6, peak * 0.5, d * 0.36), col, rng, 0.3)
		if peak > top:
			top = peak
			top_x = cx
	# the lower western shoulders, scrubby
	for i in n + 3:
		var cx2: float = 1.2 + rng.randf() * (w - 2.4)
		var hh: float = 0.9 + rng.randf() * 1.2
		Meshes.blob(st, Vector3(cx2, hh * 0.5, d * 0.7 + rng.randf() * 0.2), Vector3(1.6 + rng.randf(), hh * 0.5, d * 0.24), scrub.darkened(rng.randf() * 0.18), rng, 0.25)
	# the sheer east face, a darker slab and a few ledges on the right-hand end
	Meshes.box(st, Vector3(w - 1.3, 0.0, d * 0.2), Vector3(1.2, top * 0.8, d * 0.45), rock.darkened(0.22))
	for i in range(3):
		Meshes.box(st, Vector3(w - 3.0 - i * 1.2, 1.2 + i * 1.1, d * 0.62), Vector3(1.2, 0.12, 0.5), rock.lightened(0.12))
	# summit mast
	Meshes.box(st, Vector3(top_x, top, d * 0.34), Vector3(0.12, 1.4, 0.12), Color("c8c8c0"))
	Meshes.box(st, Vector3(top_x - 0.2, top + 0.9, d * 0.34 - 0.02), Vector3(0.52, 0.06, 0.06), Color("c83030"))
	# the tunnel mouth at the foot
	if door_x >= 0:
		Meshes.box(st, Vector3(door_x + 0.1, 0.0, d - 0.32), Vector3(0.8, 1.2, 0.1), Color("2c2a28"))
		Meshes.box(st, Vector3(door_x - 0.05, 1.2, d - 0.34), Vector3(1.1, 0.14, 0.14), rock.lightened(0.15))

## Europa Point Lighthouse: a white round tower with a red band, a gallery and a lantern.
static func europa_lighthouse(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var white := Color("f0eee6")
	var cx := w * 0.5
	var cz := d * 0.5 - 0.2
	Meshes.box(st, Vector3(0.1, 0, d - 1.4), Vector3(w - 0.2, 0.9, 1.2), white.darkened(0.06))          # keeper's block
	Meshes.cylinder(st, Vector3(cx, 0.0, cz), 0.9, 2.2, 10, white)
	Meshes.cylinder(st, Vector3(cx, 2.2, cz), 0.82, 1.4, 10, Color("c63a36"))
	Meshes.cylinder(st, Vector3(cx, 3.6, cz), 0.74, 1.8, 10, white)
	Meshes.box(st, Vector3(cx - 1.0, 5.4, cz - 1.0), Vector3(2.0, 0.12, 2.0), Color("353a40"))
	Meshes.box(st, Vector3(cx - 0.5, 5.52, cz - 0.5), Vector3(1.0, 0.7, 1.0), Color("e6e0b0"))
	Meshes.box(wst, Vector3(cx - 0.52, 5.56, cz - 0.52), Vector3(1.04, 0.6, 1.04), Landmarks.window_colour(Landmarks._wr))
	Landmarks._roof_at(st, cx - 0.65, cx + 0.65, cz - 0.65, cz + 0.65, 6.22, 0.55, Color("353a40"), white)
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.2, white, 0.8)

## A flat-roofed Cypriot village house: sand-coloured stone, a deep door arch, an outside stair, a water tank and
## solar panel on the roof, pots at the door and blue shutters.
static func flat_house(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int, rng: RandomNumberGenerator) -> void:
	var wall: Color = SANDSTONE if rng.randf() < 0.6 else Color("efe6d0")
	var h := 1.9
	Meshes.box(st, Vector3(0.05, 0, 0.05), Vector3(w - 0.1, h, d - 0.1), wall, wall.darkened(0.12))
	Meshes.box(st, Vector3(0.0, h, 0.0), Vector3(w, 0.14, d), wall.lightened(0.1))
	for x in range(w):
		if x != door_x:
			Landmarks._window(st, wst, x + 0.2, 0.7, d, 0.6, 0.7, Color("3a6ea8"))
	Landmarks._door(st, door_x, d - 0.02, wall, 1.0)
	Meshes.box(st, Vector3(door_x + 0.0, 1.16, d - 0.06), Vector3(1.0, 0.1, 0.14), wall.darkened(0.18))
	# roof clutter: a black water tank on a stand and a tilted solar panel, a stair up the side
	Meshes.box(st, Vector3(0.4, h + 0.14, 0.4), Vector3(0.6, 0.5, 0.6), Color("25282c"))
	if w >= 3:
		Meshes.box(st, Vector3(w - 1.5, h + 0.14, 0.5), Vector3(1.0, 0.1, 0.7), Color("2a3a5a"))
	for i in range(4):
		Meshes.box(st, Vector3(-0.28, i * 0.45, d - 0.9 + i * 0.0), Vector3(0.3, 0.45 * (i + 1) * 0.5 + 0.1, 0.8 - i * 0.12), wall.darkened(0.08))
	Meshes.box(st, Vector3(door_x + 0.8, 0.0, d + 0.05), Vector3(0.22, 0.26, 0.22), PANTILE)

## The Greek theatre at Kourion: a half-bowl of limestone seating cut into the slope, the stage at the foot.
## The door is on the stage side.
static func greek_theatre(st: SurfaceTool, wst: SurfaceTool, w: int, d: int, door_x: int) -> void:
	var stone := Color("d6cbb0")
	var rows := 6
	for i in range(rows):
		var k: float = float(i) / rows
		var x0: float = 0.1 + k * 0.9
		var z0: float = 0.1 + k * 0.5
		Meshes.box(st, Vector3(x0, i * 0.34, z0), Vector3(w - 0.2 - 2.0 * k * 0.9, 0.34, d * 0.55 - k * 0.5), stone.darkened(0.03 * (i % 2)), stone.lightened(0.1))
	Meshes.box(st, Vector3(w * 0.5 - 1.6, 0.0, d * 0.6), Vector3(3.2, 0.2, d * 0.4 - 0.2), stone.darkened(0.12))    # the stage
	for x in [w * 0.5 - 1.5, w * 0.5 - 0.5, w * 0.5 + 0.5, w * 0.5 + 1.1]:                                          # standing columns
		Meshes.box(st, Vector3(x, 0.2, d * 0.62), Vector3(0.22, 1.0, 0.22), stone.lightened(0.05))
	if door_x >= 0:
		Landmarks._door(st, door_x, d - 0.02, stone, 0.9)
