class_name SideStories
extends RefCounted
## Keeper side stories (data/side_stories.json): the cast keeps living after their chapter. Once you've beaten a
## Keeper and won one more Stone, they are out in their town with a short scene of their own; the four Enclosure
## Directors and Garside have one after the ending. Each side waits as an extra NPC the overworld adds to its
## zone (npcs_for) while it is waiting; the scene (data/dialogue/side_stories.json, keeper_side_<id>) ends by
## setting the flag keeper_side_<id>, and next time you're in town they've gone about their day.
## Side: {id, who, sprite, after (flag), badges (Stones held, optional), needs (another flag, optional),
## zone, x, y, facing, hint (for "Where next?")}. Pure logic, no autoloads.

const PATH := "res://data/side_stories.json"
const SCRIPT_FILE := "side_stories"   # data/dialogue/side_stories.json
const PREFIX := "keeper_side_"

static var _sides: Array = []

static func sides() -> Array:
	if _sides.is_empty():
		var d = JsonUtil.read(PATH)
		_sides = d.get("sides", []) if d is Dictionary else []
	return _sides

static func done_flag(id: String) -> String:
	return PREFIX + id

## Is this side's scene there to be had right now?
static func waiting(data: GameStateData, s: Dictionary) -> bool:
	if data.flag(done_flag(str(s.get("id", "")))) == true:
		return false
	if not _truthy(data.flag(str(s.get("after", "")))):
		return false
	if s.has("badges") and data.badges.size() < int(s.badges):
		return false
	if s.has("needs") and not _truthy(data.flag(str(s.needs))):
		return false
	return true

## NPC definitions for the sides waiting in this zone (the overworld spawns them with the zone's own NPCs).
static func npcs_for(zone_id: String, data: GameStateData, list: Array = []) -> Array:
	var out := []
	for s in (list if not list.is_empty() else sides()):
		if str(s.get("zone", "")) != zone_id or not waiting(data, s):
			continue
		out.append({"id": "side_" + str(s.id), "sprite": str(s.get("sprite", "")), "name": str(s.get("who", "")),
			"x": int(s.get("x", 0)), "y": int(s.get("y", 0)), "facing": str(s.get("facing", "down")), "move": "still",
			"script": done_flag(str(s.id)), "script_file": SCRIPT_FILE})
	return out

## The first waiting side, as a "Where next?" entry ({text, town}), or {}.
static func next_hint(data: GameStateData, list: Array = []) -> Dictionary:
	for s in (list if not list.is_empty() else sides()):
		if waiting(data, s):
			return {"text": str(s.get("hint", "")), "town": str(s.get("zone", ""))}
	return {}

## Somewhere a side can stand: walkable, no warp, sign, prop or other NPC on it, and not the spawn.
static func free_tile(z: ZoneData, p: Vector2i, also_taken: Dictionary = {}) -> bool:
	if not z.walkable(p) or p == z.spawn or also_taken.has(p):
		return false
	if not z.warp_at(p).is_empty() or not z.sign_at(p).is_empty():
		return false
	for pr in z.props:
		if str(pr.get("type", "")) != "building" and int(pr.get("x", -1)) == p.x and int(pr.get("y", -1)) == p.y:
			return false
	for n in z.npcs:
		if int(n.get("x", -1)) == p.x and int(n.get("y", -1)) == p.y:
			return false
	return true

## `p` if it's free, else the nearest free tile in growing rings round it (another branch may have put
## something on the spot since the data was written). `p` itself when nothing is free nearby.
static func nearest_free(z: ZoneData, p: Vector2i, also_taken: Dictionary = {}) -> Vector2i:
	if free_tile(z, p, also_taken):
		return p
	for r in range(1, 5):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var q := p + Vector2i(dx, dy)
				if free_tile(z, q, also_taken):
					return q
	return p

static func _truthy(v: Variant) -> bool:
	match typeof(v):
		TYPE_NIL:
			return false
		TYPE_BOOL:
			return v
		TYPE_INT, TYPE_FLOAT:
			return v != 0
		TYPE_STRING:
			return v != ""
	return true
