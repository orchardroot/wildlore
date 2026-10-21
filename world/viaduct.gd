class_name Viaduct
extends RefCounted
## A railway viaduct striding across a zone from one edge to the other (Castlefield's Victorian viaducts over the
## Bridgewater Canal): brick piers standing in water or on unwalkable tiles, and an iron deck high overhead that you
## walk underneath. A zone lists them as `"viaducts": [{"y": 49.5, "piers_y": 50, "every": 6, "height": 3.6}]`;
## the deck runs a couple of tiles past both edges so it carries on off the map. Purely scenery: no tiles change.

const BRICK := Color("8a4b3a")
const IRON := Color("4a5652")
const RAIL := Color("6b6f6a")

static func dress(zone: ZoneData, zone_node: Node3D) -> void:
	for v in zone.viaducts:
		var mi := MeshInstance3D.new()
		mi.name = "Viaduct"
		mi.mesh = build_mesh(zone.width, v)
		mi.material_override = Meshes.solid
		zone_node.add_child(mi)
		var pz := float(v.get("piers_y", v.get("y", 0))) + 0.5
		mi.set_meta("occluder_rect", Rect2(-3, pz - 0.6, zone.width + 6, 1.1))  # OccluderFade fades it when you're behind

static func pier_xs(width: int, v: Dictionary) -> Array:
	var out := []
	var every := int(v.get("every", 6))
	var x := int(v.get("first", 2))
	while x < width - 1:
		out.append(x)
		x += every
	return out

static func build_mesh(width: int, v: Dictionary) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var z := float(v.get("y", 0.0))
	var pz := float(v.get("piers_y", z)) + 0.5
	var h := float(v.get("height", 3.6))
	var x0 := -3.0
	var x1 := float(width) + 3.0
	for x in pier_xs(width, v):
		Meshes.box(st, Vector3(x + 0.2, 0, pz - 0.35), Vector3(0.6, h, 0.7), BRICK.lightened(0.03 * (x % 3)))
		Meshes.box(st, Vector3(x + 0.1, h - 0.35, pz - 0.45), Vector3(0.8, 0.35, 0.9), BRICK.darkened(0.08))
	# the deck: lattice girders either side and a track bed between, from beyond one edge to beyond the other
	var dz := pz - 0.6
	var dd := 1.1  # one track wide
	Meshes.box(st, Vector3(x0, h, dz), Vector3(x1 - x0, 0.25, dd), IRON)
	Meshes.box(st, Vector3(x0, h + 0.25, dz), Vector3(x1 - x0, 0.45, 0.12), IRON.darkened(0.1))
	Meshes.box(st, Vector3(x0, h + 0.25, dz + dd - 0.12), Vector3(x1 - x0, 0.45, 0.12), IRON.darkened(0.1))
	Meshes.box(st, Vector3(x0, h + 0.27, dz + dd * 0.5 - 0.25), Vector3(x1 - x0, 0.05, 0.5), RAIL)
	return Meshes._finish(st)
