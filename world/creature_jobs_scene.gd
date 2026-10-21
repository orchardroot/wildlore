class_name CreatureJobsScene
extends RefCounted
## The overworld side of creature jobs (rules in CreatureJobs): a small marker prop per spot, and the short
## animation and line when your lead does the job.

const COLOURS := {"ford": Color("5fa6c8"), "fetch": Color("c8d4e0"), "nudge": Color("8a8478"), "sniff": Color("5a8a3c"),
	"cross": Color("cfeaf5"), "reveal": Color("9a7ad0")}
static var _mats := {}

## Builds a marker for each job not yet done (called once the zone node is built).
static func dress(z: ZoneData, zone_node: Node3D, data: GameStateData) -> void:
	var root: Node3D = null
	for pr in z.props:
		if str(pr.get("type", "")) != CreatureJobs.TYPE:
			continue
		var p := Vector2i(int(pr.x), int(pr.y))
		if root == null:
			root = Node3D.new()
			root.name = "CreatureJobs"
			zone_node.add_child(root)
		var n := marker(str(pr.get("job", "")), CreatureJobs.is_done(data, z.id, p))
		n.name = "J_%d_%d" % [p.x, p.y]
		n.position = Vector3(p.x + 0.5, ZoneBuilder.ground_y(z, p), p.y + 0.5)
		n.rotation.y = float(hash(p) % 628) / 100.0
		root.add_child(n)

static func marker(kind: String, done: bool) -> Node3D:
	var n := Node3D.new()
	var mi := MeshInstance3D.new()
	var h: float
	if kind in ["nudge", "reveal"]:
		var sm := SphereMesh.new()
		sm.radius = 0.2 if done else 0.32
		sm.height = sm.radius * 1.4
		h = sm.height
		mi.mesh = sm
	else:
		var cm := CylinderMesh.new()
		cm.top_radius = 0.18
		cm.bottom_radius = 0.26
		cm.height = 0.1 if done else 0.3
		h = cm.height
		mi.mesh = cm
	mi.position.y = h * 0.5
	mi.material_override = _mat(kind, done)
	n.add_child(mi)
	return n

static func _mat(kind: String, done: bool) -> StandardMaterial3D:
	var key := "%s:%s" % [kind, done]
	if not _mats.has(key):
		var m := StandardMaterial3D.new()
		var c: Color = COLOURS.get(kind, Color.WHITE)
		m.albedo_color = c.darkened(0.35) if done else c
		m.roughness = 1.0
		_mats[key] = m
	return _mats[key]

## Facing a job spot and pressing confirm. True when it was one of ours.
static func interact(ow: Node, p: Vector2i) -> bool:
	var pr := CreatureJobs.prop_at(ow.zone, p)
	if pr.is_empty():
		return false
	var res := CreatureJobs.attempt(Game.data, ow.zone, pr, Game.items)
	if not res.ok:
		await ow.say(res.lines)
		return true
	var node: Node3D = ow._zone_node.get_node_or_null("CreatureJobs/J_%d_%d" % [p.x, p.y]) if ow._zone_node else null
	var lead: Creature = Game.data.first_able()
	Audio.cry(lead.species)
	if node:
		await animate(node, str(CreatureJobs.KINDS[res.kind].anim))
		node.queue_free()
		var done := marker(str(res.kind), true)
		done.name = node.name
		done.position = node.position
		node.get_parent().add_child(done)
	if not res.got.is_empty():
		Audio.sfx("item")
	await ow.say(res.lines)
	Bus.foraged.emit(ow.zone.id)  # counts as a find for the parish jobs board
	return true

## A short bit of business on the marker, about half a second.
static func animate(node: Node3D, anim: String) -> void:
	var t := node.create_tween()
	match anim:
		"hop":
			t.tween_property(node, "position:y", node.position.y + 0.25, 0.15).set_ease(Tween.EASE_OUT)
			t.tween_property(node, "position:y", node.position.y, 0.15).set_ease(Tween.EASE_IN)
		"rise":
			t.tween_property(node, "position:y", node.position.y + 0.6, 0.35).set_ease(Tween.EASE_OUT)
		"shove":
			t.tween_property(node, "position:x", node.position.x + 0.3, 0.2)
			t.tween_property(node, "position:x", node.position.x + 0.45, 0.2)
		"slide":
			t.tween_property(node, "position:z", node.position.z - 0.4, 0.4)
		"wiggle", "glow":
			t.tween_property(node, "rotation:y", node.rotation.y + 1.2, 0.2)
			t.tween_property(node, "rotation:y", node.rotation.y - 1.2, 0.2)
			t.tween_property(node, "rotation:y", node.rotation.y, 0.1)
	await t.finished
