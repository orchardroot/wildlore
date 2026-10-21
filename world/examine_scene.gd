class_name ExamineScene
extends RefCounted
## Facing an examine spot and pressing confirm (see Examine): the text, then any find, once.

static func interact(ow: Node, p: Vector2i) -> bool:
	var ex: Dictionary = ow.zone.examine_at(p)
	if ex.is_empty():
		return false
	var res := Examine.read(Game.data, str(ow.zone.id), ex, Game.items)
	if res.gave:
		Audio.sfx("item")
	await ow.say(res.lines)
	return true
