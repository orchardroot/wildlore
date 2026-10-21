class_name OccluderFade
extends Node
## Buildings that stand between the camera and the player go see-through while you're behind them, so you can see
## yourself, the path and the doors tucked behind a front row (the camera looks north from the south, so anything
## south of you and a few tiles' height tall can hide you). One per outdoor zone, under the zone node; cheap: it
## checks a handful of rectangles four times a second and only swaps materials when the answer changes.

const BEHIND := 3.5   # tiles north of a building's back wall that its height still hides
const SIDE := 0.6     # slack either side, for the sprite's width
const ALPHA := 0.32

static var faded: StandardMaterial3D

var _player: Node3D
var _items := []      # of {body, rect: Rect2 (x, z, w, d), faded}
var _t := 0.0

## Whether a building occupying `rect` (x, z, width, depth in tiles) hides a point at `pos` (x, z).
static func hides(rect: Rect2, pos: Vector2) -> bool:
	if pos.x < rect.position.x - SIDE or pos.x > rect.end.x + SIDE:
		return false
	return pos.y >= rect.position.y - BEHIND and pos.y <= rect.end.y - 0.3

static func dress(zone: ZoneData, zone_node: Node3D, player: Node3D) -> void:
	if zone.kind == "interior" or player == null:
		return
	var f := OccluderFade.new()
	f.name = "OccluderFade"
	f._player = player
	for pr in zone.props:
		if pr.get("type") != "building":
			continue
		var body := zone_node.get_node_or_null("Building_%d_%d" % [int(pr.x), int(pr.y)])
		if body:
			f._items.append({"body": body, "rect": Rect2(int(pr.x), int(pr.y), int(pr.w), int(pr.h)), "faded": false})
	if not f._items.is_empty():
		zone_node.add_child(f)

static func _faded_material() -> StandardMaterial3D:
	if faded == null:
		faded = Meshes.solid.duplicate()
		faded.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		faded.albedo_color = Color(1, 1, 1, ALPHA)
	return faded

func _process(delta: float) -> void:
	_t += delta
	if _t < 0.25 or not is_instance_valid(_player):
		return
	_t = 0.0
	var pos := Vector2(_player.position.x, _player.position.z)
	for it in _items:
		var want := hides(it.rect, pos)
		if want != it.faded:
			it.faded = want
			var body: MeshInstance3D = it.body
			body.material_override = _faded_material() if want else Meshes.solid
			body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if want else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
			for c in body.get_children():
				if c is MeshInstance3D:
					c.visible = not want  # windows: drawn over the wall, they'd float on a see-through one
