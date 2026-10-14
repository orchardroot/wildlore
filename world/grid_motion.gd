class_name GridMotion
extends RefCounted
## Pure grid helpers shared by the player, NPCs and the playtest bot.

const DIRS := {"up": Vector2i(0, -1), "down": Vector2i(0, 1), "left": Vector2i(-1, 0), "right": Vector2i(1, 0)}

static func dir_vec(dir: String) -> Vector2i:
	return DIRS.get(dir, Vector2i.ZERO)

static func step(pos: Vector2i, dir: String) -> Vector2i:
	return pos + dir_vec(dir)

static func facing_from(delta: Vector2i) -> String:
	if absi(delta.x) > absi(delta.y):
		return "right" if delta.x > 0 else "left"
	return "down" if delta.y > 0 else "up"

## Which edge of a w x h zone a position just left by, or "" if still inside.
static func edge_side(p: Vector2i, w: int, h: int) -> String:
	if p.y < 0:
		return "north"
	if p.y >= h:
		return "south"
	if p.x < 0:
		return "west"
	if p.x >= w:
		return "east"
	return ""
