class_name QuestNews
extends Node
## Quest toasts: listens for flags set by story scripts (Bus.flag_changed) and, once the scene is over, says what
## moved: "New quest", "Quest updated", "Quest complete" (see Quests.change_news). It compares each touched quest
## with how it stood after the last news, so a hand-in that sets three flags is one toast, and a flag set again
## changes nothing. Plaques read for the Gazetteer come through here too. Toasts go out through the Parish's queue
## (ui/parish_toast.gd), so they wait for dialogue and fades like every other bit of news.

var _game: Node
var _parish: Parish
var _data: GameStateData = null      # the save the baseline belongs to (a load or new game starts afresh)
var _base: Dictionary = {}           # quest id -> snapshot as of the last news
var _dirty: Dictionary = {}          # quest id -> true, touched since

static func connect_bus(game: Node, parish: Parish) -> QuestNews:
	var q := QuestNews.new()
	q.name = "QuestNews"
	q._game = game
	q._parish = parish
	game.add_child(q)
	var bus := game.get_node("/root/Bus")
	bus.flag_changed.connect(q._on_flag)
	bus.zone_entered.connect(func(_z: String): q._baseline())
	return q

func _baseline() -> void:
	var d: GameStateData = _game.data
	if d == _data:
		return
	_data = d
	_base.clear()
	_dirty.clear()
	for q in Quests.all():
		_base[str(q.id)] = Quests.snapshot(d, q)

func _on_flag(key: String, _value: Variant) -> void:
	if _data != _game.data:
		return  # no baseline for this save yet (a dev boot): nothing to compare with
	for q in Quests.touched_by(key):
		_dirty[str(q.id)] = true

func _process(_delta: float) -> void:
	if _dirty.is_empty():
		return
	var router := get_node_or_null("/root/Router")
	if router != null and router.busy:
		return  # mid-scene: wait until it's all played out, then say it once
	for id in _dirty:
		var q := Quests.get_quest(str(id))
		if q.is_empty():
			continue
		var now := Quests.snapshot(_data, q)
		var n := Quests.change_news(q, _base.get(str(id), {"status": Quests.NOT_STARTED, "step": -1}), now)
		_base[str(id)] = now
		if not n.is_empty():
			_parish.news(n[0], n[1])
	_dirty.clear()

## Poets' Corner milestones paid by an arts plaque (PoetsCorner.record), one toast each.
func poets_corner(paid: Array) -> void:
	for m in paid:
		var gift := Gazetteer.reward_text(m, _game.items)
		_parish.news("Poets' Corner", "%s! %s" % [str(m.title), gift] if gift != "" else str(m.title) + "!")

## A plaque read for the first time: the Gazetteer toast, any milestone paid, and anything a quest wanted from it.
func plaque_read(res: Dictionary, title: String) -> void:
	if not bool(res.get("new", false)):
		return
	_parish.news("Gazetteer", "%s added to your Gazetteer" % title)
	for m in res.get("milestones", []):
		var gift := Gazetteer.reward_text(m, _game.items)
		_parish.news("Gazetteer milestone", "%s! %s" % [str(m.title), gift] if gift != "" else str(m.title) + "!")
