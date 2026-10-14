class_name Sight
extends RefCounted
## Trainer line of sight, as pure geometry. `blocked` is a Callable(Vector2i) -> bool for tiles that stop a look.

const RANGE := 5

## Does an NPC at `from`, facing `facing`, see `target` along a straight line within RANGE tiles?
static func sees(from: Vector2i, facing: String, target: Vector2i, blocked: Callable, view := RANGE) -> bool:
	var d := GridMotion.dir_vec(facing)
	if d == Vector2i.ZERO:
		return false
	for i in range(1, view + 1):
		var p := from + d * i
		if blocked.call(p):
			return false
		if p == target:
			return true
	return false

## An undefeated trainer NPC (def has "trainer") that can see the player.
static func triggers(def: Dictionary, data: GameStateData, from: Vector2i, facing: String, target: Vector2i, blocked: Callable) -> bool:
	var tid := str(def.get("trainer", ""))
	if tid == "" or data.flag("trainer_" + tid):
		return false
	return sees(from, facing, target, blocked)

## Steps a trainer takes to stand next to a player they can see in a straight line.
static func approach_path(from: Vector2i, facing: String, target: Vector2i) -> Array:
	var d := GridMotion.dir_vec(facing)
	var dist := absi(target.x - from.x) + absi(target.y - from.y)
	var out := []
	for i in maxi(0, dist - 1):
		out.append(facing)
	if d == Vector2i.ZERO:
		return []
	return out
