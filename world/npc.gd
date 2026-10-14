class_name Npc
extends Node3D
## A character on the grid. Stands, wanders or paces, talks, and (if a trainer) spots the player and challenges them.
## `interact` and trainer challenges hand the actual conversation to ScriptRunner and return straight away:
## a whiteout rebuilds the zone and frees every NPC, so nothing here may wait on a run.

const STEP_SPEED := 3.0      # tiles per second
const WANDER_RADIUS := 2

static var _dev_talk_done := false

var def: Dictionary = {}
var grid_pos := Vector2i.ZERO
var facing := "down"
var sprite: CharSprite
var ow: Node
var home := Vector2i.ZERO

var _mode := "still"
var _timer := 3.0
var _stepping := false
var _talking := false
var _challenging := false
var _pace_dirs: Array = []
var _pace_i := 0

func setup(d: Dictionary, overworld: Node) -> void:
	def = d
	ow = overworld
	grid_pos = Vector2i(int(d.get("x", 0)), int(d.get("y", 0)))
	home = grid_pos
	facing = str(d.get("facing", "down"))
	_mode = str(d.get("move", "still"))
	sprite = CharSprite.new()
	add_child(sprite)
	sprite.setup(str(d.get("sprite", "")))
	sprite.set_facing(facing)
	position = Vector3(grid_pos.x + 0.5, ow.ground_y(grid_pos), grid_pos.y + 0.5)
	_timer = randf_range(2.0, 5.0)
	if _mode == "pace":
		_build_pace()
	_dev_talk()

func _build_pace() -> void:
	var path: Array = def.get("path", [])
	if path.is_empty():
		path = [facing, facing, facing]
	_pace_dirs = path.duplicate()
	var back := path.duplicate()
	back.reverse()
	for d in back:
		_pace_dirs.append(_opposite(str(d)))

static func _opposite(d: String) -> String:
	return {"up": "down", "down": "up", "left": "right", "right": "left"}.get(d, d)

func face(dir: String) -> void:
	facing = dir
	sprite.set_facing(dir)

func face_toward(p: Vector2i) -> void:
	if p != grid_pos:
		face(GridMotion.facing_from(p - grid_pos))

func is_trainer() -> bool:
	return str(def.get("trainer", "")) != ""

func _process(delta: float) -> void:
	if _mode == "still" or _stepping or _talking or _challenging or Router.busy or ow.player.moving:
		return
	_timer -= delta
	if _timer > 0.0:
		return
	if _mode == "wander":
		_timer = randf_range(2.0, 5.0)
		var dir: String = ["up", "down", "left", "right"].pick_random()
		var target := GridMotion.step(grid_pos, dir)
		if maxi(absi(target.x - home.x), absi(target.y - home.y)) <= WANDER_RADIUS:
			_step(dir)
		else:
			face(dir)
	elif _mode == "pace" and not _pace_dirs.is_empty():
		_timer = randf_range(0.5, 1.0)
		if await _step(_pace_dirs[_pace_i]):
			_pace_i = (_pace_i + 1) % _pace_dirs.size()

func _can_step(target: Vector2i) -> bool:
	return ow.can_enter(target, target - grid_pos) == "ok" and target != ow.player.grid_pos \
		and ow.zone.warp_at(target).is_empty()

## One step. Never into a blocked tile or the player. Returns whether it moved.
func _step(dir: String, keep_walking := false) -> bool:
	face(dir)
	var target := GridMotion.step(grid_pos, dir)
	if not _can_step(target):
		return false
	_stepping = true
	grid_pos = target   # claim the tile at once so nobody walks into it
	sprite.walking = true
	var dest := Vector3(target.x + 0.5, ow.ground_y(target), target.y + 0.5)
	var tw := create_tween()
	tw.tween_property(self, "position", dest, 1.0 / STEP_SPEED)
	await tw.finished
	position = dest
	if not keep_walking:
		sprite.walking = false
	_stepping = false
	return true

## Scripted walk: a list of directions. Blocked steps are skipped.
func walk(path: Array) -> void:
	for d in path:
		if not await _step(str(d), true):
			await get_tree().create_timer(0.15).timeout
	sprite.walking = false

func interact(player: Node) -> void:
	if _talking or _challenging:
		return
	_talking = true
	face_toward(player.grid_pos)
	var tid := str(def.get("trainer", ""))
	var cmds: Array = []
	if tid != "":
		if Game.data.flag("trainer_" + tid):
			var t := StoryData.trainer(tid)
			cmds = [{"do": "say", "who": t.name, "text": t.after if t.after != "" else "..."}]
		else:
			cmds = StoryData.trainer_script(tid)
	elif def.has("script"):
		cmds = StoryData.script(ow.zone.id, str(def.script))
	elif def.has("text"):
		cmds = [{"do": "say", "who": str(def.get("name", "")), "text": str(def.text)}]
	if cmds.is_empty():
		cmds = StoryData.script(ow.zone.id, "nothing_to_say")
	ScriptRunner.start(ow, cmds, str(def.get("id", "")), Callable(self, "_talk_done"))

func _talk_done() -> void:
	_talking = false

## Called by the overworld after every player step. True if this trainer has spotted the player and taken over.
func check_sight(player_pos: Vector2i) -> bool:
	if not is_trainer() or _challenging or _talking or Router.busy:
		return false
	if not Sight.triggers(def, Game.data, grid_pos, facing, player_pos, Callable(self, "_blocks_sight")):
		return false
	_challenging = true
	Router.busy = true   # synchronously, so the overworld stops its own step handling
	_challenge(player_pos)
	return true

func _blocks_sight(p: Vector2i) -> bool:
	if not ow.zone.in_bounds(p) or not ow.zone.walkable(p):
		return true
	var other: Node = ow.npc_at(p)
	return other != null and other != self

func _challenge(player_pos: Vector2i) -> void:
	Audio.sfx("alert")
	await _bubble()
	await walk(Sight.approach_path(grid_pos, facing, player_pos))
	face_toward(ow.player.grid_pos)
	ow.player.face(_opposite(facing))
	var tid := str(def.trainer)
	_challenging = false
	_talking = true
	ScriptRunner.start(ow, StoryData.trainer_script(tid), str(def.get("id", "")), Callable(self, "_talk_done"))

func _bubble() -> void:
	var l := Label3D.new()
	l.text = "!"
	l.font_size = 96
	l.outline_size = 24
	l.modulate = Color(1.0, 0.86, 0.25)
	l.outline_modulate = Color(0.25, 0.1, 0.05)
	l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	l.no_depth_test = true
	l.pixel_size = 0.012
	l.position = Vector3(0, 1.9, 0)
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", 2.1, 0.12).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(0.55)
	await tw.finished
	l.queue_free()

## Dev switch: `-- --talk=<npc_id>` runs that NPC's conversation as soon as the zone is ready.
func _dev_talk() -> void:
	if _dev_talk_done or "--talk=" + str(def.get("id", "")) not in DevArgs.user_args():
		return
	_dev_talk_done = true
	await get_tree().create_timer(0.4).timeout
	while Router.busy:
		await get_tree().process_frame
	interact(ow.player)
