class_name CameraRig
extends Node3D
## HD-2D camera: narrow-FOV perspective looking down at about 35 degrees, following the player smoothly
## with a little lead, clamped so the void outside the zone stays off screen.

const PITCH := 35.0
var distance := 21.0
var fov := 30.0
var target: Node3D
var bounds := Rect2(0, 0, 10, 10)
var camera: Camera3D
var _lead := Vector3.ZERO

func _ready() -> void:
	camera = Camera3D.new()
	camera.fov = fov
	camera.near = 0.3
	camera.far = 120.0
	add_child(camera)
	camera.current = true
	_apply_offset()

func configure(zone_w: int, zone_h: int, interior: bool) -> void:
	bounds = Rect2(0, 0, zone_w, zone_h)
	distance = 12.0 if interior else 21.0
	fov = 32.0 if interior else 30.0
	if camera:
		camera.fov = fov
		_apply_offset()
	snap()

func _apply_offset() -> void:
	var p := deg_to_rad(PITCH)
	camera.position = Vector3(0, sin(p) * distance, cos(p) * distance)
	camera.rotation = Vector3(-p, 0, 0)

func snap() -> void:
	if target:
		global_position = _clamped(target.global_position)

func _process(delta: float) -> void:
	if target == null:
		return
	var want := target.global_position
	if target is Player and target.moving:
		_lead = _lead.lerp(Vector3(GridMotion.dir_vec(target.facing).x, 0, GridMotion.dir_vec(target.facing).y) * 0.8, delta * 3.0)
	else:
		_lead = _lead.lerp(Vector3.ZERO, delta * 2.0)
	global_position = global_position.lerp(_clamped(want + _lead), 1.0 - exp(-delta * 6.0))

func _clamped(p: Vector3) -> Vector3:
	var half_w := distance * tan(deg_to_rad(fov) * 0.5) * (16.0 / 9.0) * 0.95
	var x := p.x
	if bounds.size.x > half_w * 2.0:
		x = clampf(p.x, bounds.position.x + half_w, bounds.end.x - half_w)
	else:
		x = bounds.get_center().x
	var near_margin := distance * 0.22
	var far_margin := distance * 0.32
	var z := p.z
	if bounds.size.y > near_margin + far_margin:
		z = clampf(p.z, bounds.position.y + far_margin, bounds.end.y - near_margin)
	else:
		z = bounds.get_center().y
	return Vector3(x, p.y, z)
