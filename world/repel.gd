class_name Repel
extends RefCounted
## Lavender Sachets: while one is going, wild creatures below your lead's level leave you alone.
## The steps left live in a save flag, so a save from before sachets existed simply has none going.

const FLAG := "repel_steps"
const ITEM := "lavender_sachet"
const DEFAULT_STEPS := 100
const WORN_LINE := "The Lavender Sachet's scent has faded."

static func steps_left(data: GameStateData) -> int:
	var v: Variant = data.flag(FLAG)
	return maxi(0, int(v)) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else 0

static func active(data: GameStateData) -> bool:
	return steps_left(data) > 0

## Opens a sachet from the bag. Returns {"ok", "text"}; refuses while one is still going.
static func use(data: GameStateData, id: String, items: ItemDB) -> Dictionary:
	var bag := Bag.new(data.bag)
	var it := items.get_item(id)
	if it.is_empty() or bag.count(id) < 1:
		return {"ok": false, "text": "You don't have any."}
	if active(data):
		return {"ok": false, "text": "The last one's still going strong (%d steps left)." % steps_left(data)}
	bag.remove(id)
	data.set_flag(FLAG, int(it.get("steps", DEFAULT_STEPS)))
	return {"ok": true, "text": "You tuck the %s in a pocket. Weaker wild creatures will keep their distance." % it.get("name", id)}

## One step taken. True on the step it wears off.
static func step(data: GameStateData) -> bool:
	if not active(data):
		return false
	var n := steps_left(data) - 1
	data.set_flag(FLAG, n)
	return n == 0

## Would a wild creature of this level be kept away?
static func blocks(data: GameStateData, foe_level: int) -> bool:
	if not active(data):
		return false
	var lead := data.first_able()
	return lead != null and foe_level < lead.level
