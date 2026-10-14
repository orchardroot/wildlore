class_name Player
extends Node3D
## The player on the grid. Reads input unless Router is busy; asks the overworld whether a step is allowed.

const WALK_SPEED := 4.0   # tiles per second
const RUN_SPEED := 7.0
const TURN_GRACE := 0.09  # a quick tap turns on the spot, holding walks

signal step_finished(p: Vector2i)

var grid_pos := Vector2i.ZERO
var facing := "down"
var moving := false
var overworld: Node
var sprite: CharSprite
var _held_dir := ""
var _held_t := 0.0
var _bump_cooldown := 0.0
## The playtest bot sets this to drive the player without real input.
var forced_dir := ""

func setup(ow: Node, sprite_id: String) -> void:
	overworld = ow
	sprite = CharSprite.new()
	add_child(sprite)
	sprite.setup(sprite_id)

func place(p: Vector2i, dir: String, y: float) -> void:
	grid_pos = p
	position = Vector3(p.x + 0.5, y, p.y + 0.5)
	face(dir)

func face(dir: String) -> void:
	facing = dir
	if sprite:
		sprite.set_facing(dir)

func busy() -> bool:
	return moving or Router.busy

func _physics_process(delta: float) -> void:
	_bump_cooldown = maxf(0.0, _bump_cooldown - delta)
	if busy():
		return
	if forced_dir == "" and Input.is_action_just_pressed("confirm"):
		overworld.interact(GridMotion.step(grid_pos, facing))
		return
	if forced_dir == "" and Input.is_action_just_pressed("menu"):
		overworld.open_pause()
		return
	var dir := forced_dir if forced_dir != "" else _input_dir()
	if dir == "":
		_held_dir = ""
		_held_t = 0.0
		sprite.walking = false
		return
	if dir != _held_dir:
		_held_dir = dir
		_held_t = 0.0
		if dir != facing and forced_dir == "":
			face(dir)
			return
	_held_t += delta
	if dir != facing:
		face(dir)
	if forced_dir == "" and _held_t < TURN_GRACE and not sprite.walking:
		return
	try_step(dir, Input.is_action_pressed("run"))

func _input_dir() -> String:
	for d in ["up", "down", "left", "right"]:
		if Input.is_action_pressed("move_" + d):
			return d
	return ""

## Attempts one step. Returns false (and bumps) if blocked.
func try_step(dir: String, running := false) -> bool:
	face(dir)
	var target := GridMotion.step(grid_pos, dir)
	var verdict: String = overworld.can_enter(target, GridMotion.dir_vec(dir))
	if verdict == "blocked":
		sprite.walking = false
		if _bump_cooldown <= 0.0:
			Audio.sfx("bump")
			_bump_cooldown = 0.35
		return false
	moving = true
	sprite.walking = true
	var speed := RUN_SPEED if running else WALK_SPEED
	var dest_y: float = overworld.ground_y(target)
	var dest := Vector3(target.x + 0.5, dest_y, target.y + 0.5)
	var tw := create_tween()
	if verdict == "ledge":
		target = target + GridMotion.dir_vec(dir)
		dest = Vector3(target.x + 0.5, overworld.ground_y(target), target.y + 0.5)
		tw.tween_method(func(t: float): position = position.lerp(dest, t) + Vector3(0, sin(t * PI) * 0.06, 0), 0.0, 1.0, 0.35)
	else:
		tw.tween_property(self, "position", dest, 1.0 / speed)
	await tw.finished
	position = dest
	grid_pos = target
	moving = false
	if _input_dir() == "" and forced_dir == "":
		sprite.walking = false
	step_finished.emit(grid_pos)
	return true
