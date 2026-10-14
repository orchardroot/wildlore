class_name FakeBattleUI
extends RefCounted
## A stand-in for the battle scene: auto-picks choices so BattleFlow can run headlessly.

var picks: Array = []          # queued choices for choose_action; empty means "use the best move"
var forget_slot := -1
var evolve := true
var replacement := -1           # -1: first able
var said: Array = []
var event_batches: Array = []
var forget_asked: Array = []
var evolve_asked: Array = []
var replacement_asked := 0
var xp_calls := 0
var first_catches: Array = []

func first_catch(c: Creature) -> void:
	first_catches.append(c.species.id)

func intro(_flow) -> void:
	pass

func say(lines: Array, _hold := 0.0) -> void:
	said.append_array(lines)

func play_events(events: Array, _ctx: Dictionary) -> void:
	event_batches.append(events.duplicate(true))

func choose_action(flow) -> Dictionary:
	if not picks.is_empty():
		return picks.pop_front()
	var me: Creature = flow.battle.current(Battle.PLAYER)
	var best := 0
	var power := -1
	for i in me.moves.size():
		var p := int(flow.move_db.get_move(me.moves[i].id).get("power", 0))
		if p > power and int(me.moves[i].pp) > 0:
			power = p
			best = i
	return {"kind": "fight", "slot": best}

func choose_replacement(flow) -> int:
	replacement_asked += 1
	if replacement >= 0:
		return replacement
	var party: Array = flow.battle.parties[Battle.PLAYER]
	for i in party.size():
		if not party[i].is_fainted():
			return i
	return 0

func choose_forget(c: Creature, move_id: String, _flow) -> int:
	forget_asked.append([c.display_name(), move_id])
	return forget_slot

func evolve_anim(c: Creature, to_sp: Dictionary) -> bool:
	evolve_asked.append([c.species.id, to_sp.id])
	return evolve

func xp_gained(_c: Creature, _evs: Array) -> void:
	xp_calls += 1

func event_types() -> Array:
	var out := []
	for batch in event_batches:
		for e in batch:
			out.append(e.type)
	return out
