class_name ExamineScene
extends RefCounted
## Facing an examine spot and pressing confirm (see Examine): the text, then any find, once.

static func interact(ow: Node, p: Vector2i) -> bool:
	var ex: Dictionary = ow.zone.examine_at(p)
	if ex.is_empty():
		return false
	var key := Examine.found_flag(str(ow.zone.id), ex)
	var before := ZoneData.flag_on(Game.data.flag(key))
	var res := Examine.read(Game.data, str(ow.zone.id), ex, Game.items)
	if res.gave:
		Audio.sfx("item")
	if not before and ZoneData.flag_on(Game.data.flag(key)):
		Bus.flag_changed.emit(key, true)  # a quest step or the Timeline of Invention may want it
	await ow.say(res.lines)
	return true
