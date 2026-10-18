class_name RewildScene
extends RefCounted
## Rewilding in the overworld: dresses each site with its stage's props (one MultiMesh per kind, so a whole
## woodland is a handful of draw calls) and the marked spots of a planting or litter task, and handles facing a spot
## and pressing confirm. The ground, tall grass, pools and trees themselves are tiles that Rewild.apply reshaped
## before the zone was built.

## Props that sway with the wind (the foliage shader); the rest stand still.
const SWAY := ["plug", "cotton", "fern", "young_oak", "young_pine", "young_willow", "willow", "juniper", "gorse",
	"young_gorse", "blaeberry", "reed", "pool_rim", "heather", "meadowsweet", "flowers", "brash"]

## Builds the props for every site in the zone (Rewild.apply put their layouts on the zone as meta "rewild").
static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	if not z.has_meta("rewild"):
		return
	Meshes.materials()
	var root := Node3D.new()
	root.name = "Rewild"
	zone_node.add_child(root)
	for lay in z.get_meta("rewild"):
		for mesh_name in lay.decor:
			root.add_child(_multimesh(z, str(mesh_name), lay.decor[mesh_name]))
		var s := Rewild.site(str(lay.site))
		_spots(z, s, data, root)

static func _multimesh(z: ZoneData, mesh_name: String, list: Array) -> MultiMeshInstance3D:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = RewildMeshes.get_mesh(mesh_name)
	mm.instance_count = list.size()
	for i in list.size():
		var e: Array = list[i]
		var p := Vector2i(floori(float(e[0])), floori(float(e[1])))
		var y := ZoneBuilder.water_y(z, p) if bool(e[4]) else ZoneBuilder.ground_y(z, p)
		if mesh_name == "pool_rim":
			y = z.height_at(p) * ZoneBuilder.LEVEL  # round the pool's lip, not down in it
		var b := Basis(Vector3.UP, float(e[2])).scaled(Vector3.ONE * float(e[3]))
		mm.set_instance_transform(i, Transform3D(b, Vector3(float(e[0]), y, float(e[1]))))
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "R_" + mesh_name
	mmi.multimesh = mm
	mmi.material_override = Meshes.foliage if mesh_name in SWAY else Meshes.solid
	var low := mesh_name in ["plug", "litter", "lily", "flowers", "cotton", "heather", "blaeberry"]
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if low else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	return mmi

## The canes (or litter heaps) of a live plant or litter task, each with a sparkle until it's seen to.
static func _spots(z: ZoneData, s: Dictionary, data: GameStateData, root: Node3D) -> void:
	var id := str(s.id)
	if not Rewild.can_contribute(data, id):
		return
	var st := Rewild.stage(data, id)
	var t := Rewild.task(s, st)
	var kind := str(t.get("kind", ""))
	if kind not in ["plant", "litter"]:
		return
	var list := Rewild.spots(z, s)
	for i in mini(list.size(), int(t.get("spots", 0))):
		var p: Vector2i = list[i]
		var n := spot_node(kind)
		n.name = "Spot_%d_%d" % [p.x, p.y]
		n.position = Vector3(p.x + 0.5, ZoneBuilder.ground_y(z, p), p.y + 0.5)
		n.rotation.y = float(hash(p) % 628) / 100.0
		root.add_child(n)
		show_done(n, data.flag(Rewild.spot_flag(id, st, i)) == true)

## "Todo" (a cane with tape, or a heap of rubbish) and its sparkle, "Done" (a guarded sapling, or nothing).
static func spot_node(kind: String) -> Node3D:
	var n := Node3D.new()
	var todo := MeshInstance3D.new()
	todo.name = "Todo"
	todo.mesh = RewildMeshes.get_mesh("litter_heap" if kind == "litter" else "cane")
	todo.material_override = Meshes.solid
	n.add_child(todo)
	if kind == "plant":
		var done := MeshInstance3D.new()
		done.name = "Done"
		done.mesh = RewildMeshes.get_mesh("guard")
		done.material_override = Meshes.solid
		n.add_child(done)
	var sp := MeshInstance3D.new()
	sp.name = "Sparkle"
	sp.mesh = Forage._cached("sparkle", func(): return Forage._sparkle())
	sp.material_override = Forage._sparkle_material()
	sp.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sp.position.y = 0.95 if kind == "plant" else 0.55
	n.add_child(sp)
	return n

static func show_done(n: Node, done: bool) -> void:
	for k in ["Todo", "Sparkle"]:
		var c := n.get_node_or_null(k)
		if c:
			c.visible = not done
	var d := n.get_node_or_null("Done")
	if d:
		d.visible = done

## Extra birds over a zone with a recovering (1) or wild (2) site; 0 otherwise.
static func bird_bonus(z: ZoneData) -> int:
	var best := 0
	if z and z.has_meta("rewild"):
		for lay in z.get_meta("rewild"):
			best = maxi(best, int(lay.stage) - 1)
	return best

## Facing a marked spot and pressing confirm: plant it (or bag the rubbish). True when it was one of ours.
static func interact(ow: Node, p: Vector2i) -> bool:
	if not ow.zone.has_meta("rewild"):
		return false
	var line := Rewild.mark_spot(Game.data, ow.zone, p)
	if line == "":
		return false
	var node: Node = ow._zone_node.get_node_or_null("Rewild/Spot_%d_%d" % [p.x, p.y]) if ow._zone_node else null
	if node:
		show_done(node, true)
	Audio.sfx("step_grass")
	Audio.sfx("item")
	await ow.say([line])
	return true
