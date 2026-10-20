class_name FakeOverworld
extends Node3D
## Just enough of the overworld for a real Player and Follower to walk about on: a zone, flat ground, NPC
## occupancy and can_enter's verdicts (blocked, edge, ledge). Steps are driven a frame at a time by `frame`,
## in the engine's own order (physics, then process), so tests can watch every frame. (Tests run before the tree
## does, so nodes here are never inside it: nothing may rely on tweens or timers.)

var zone: ZoneData
var player: Player
var follower: Follower
var npcs: Array = []
var steps: Array = []        # every step_finished, in order
var edge_crossed := Vector2i(-1, -1)

static func make(rows: Array, at: Vector2i, facing := "down", edges := {}) -> FakeOverworld:
	for a in ["run", "move_up", "move_down", "move_left", "move_right", "confirm", "menu", "bike", "photo", "fly"]:
		if not InputMap.has_action(a):  # a -s script runs without the project's input map
			InputMap.add_action(a)
	var ow := FakeOverworld.new()
	ow.zone = ZoneData.from_dict({"id": "fake", "name": "Fake", "kind": "route", "rows": rows, "edges": edges})
	ow.player = Player.new()
	ow.add_child(ow.player)
	ow.player.setup(ow, "player_a")
	ow.player.place(at, facing, 0.0)
	ow.player.step_finished.connect(ow._on_step)
	ow.follower = Follower.attach(ow)
	return ow

func ground_y(_p: Vector2i) -> float:
	return 0.0

func occupied(p: Vector2i) -> bool:
	for n in npcs:
		if n.grid_pos == p:
			return true
	return false

func can_enter(p: Vector2i, dir: Vector2i) -> String:
	if not zone.in_bounds(p):
		return "edge" if zone.edges.has(GridMotion.edge_side(p, zone.width, zone.height)) else "blocked"
	if zone.tile_at(p) == "ledge_south":
		return "ledge" if dir == Vector2i(0, 1) and zone.walkable(p + dir) else "blocked"
	return "ok" if zone.walkable(p, dir) and not occupied(p) else "blocked"

func interact(_p: Vector2i) -> void:
	pass

func _on_step(p: Vector2i) -> void:
	steps.append(p)
	if not zone.in_bounds(p) and edge_crossed.x < 0:
		edge_crossed = p

## One rendered frame of `dt` seconds, the way the engine runs it: the player's physics ticks (`ticks` of them:
## 0 on a quick frame, 2 when it hitches), then _process in tree order, the player before the follower.
func frame(dt: float, ticks := 1) -> void:
	for i in ticks:
		player._physics_process(dt)
	player._process(dt)
	follower._process(dt)
