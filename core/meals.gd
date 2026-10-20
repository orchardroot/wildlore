class_name Meals
extends RefCounted
## Regional dishes (item kind "meal", made at a kitchen or hob, see Crafting). Eating one heals the lead a little and
## starts ONE modest buff; a second dish can't be eaten until the first has done its job. The state is two save
## flags, so a save from before dishes existed simply has no meal going. Pure logic (no autoloads).
##
## An item's "meal" block says what the buff is:
##   {"buff": "stat", "stat": "atk"}   +1 stage on the lead at the start of the next battle
##   {"buff": "catch", "mult": 1.25}   snares work better in the next wild battle
##   {"buff": "purse", "pct": 25}      the next keeper battle pays out more prize money
##   {"buff": "lure", "steps": 60}     wild creatures turn up more often for that many steps

const FLAG := "meal_dish"
const STEPS_FLAG := "meal_steps"
const BUFFS := ["stat", "catch", "purse", "lure"]
const LURE_MULT := 1.4
const STAT_NAMES := {"atk": "Attack", "def": "Defence", "lore": "Lore", "ward": "Ward", "spd": "Speed"}

static func active(data: GameStateData) -> String:
	var v: Variant = data.flag(FLAG)
	return str(v) if typeof(v) == TYPE_STRING else ""

static func steps_left(data: GameStateData) -> int:
	var v: Variant = data.flag(STEPS_FLAG)
	return maxi(0, int(v)) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else 0

static func _clear(data: GameStateData) -> void:
	data.set_flag(FLAG, "")
	data.set_flag(STEPS_FLAG, 0)

## Tucks in: heals the lead (the first creature able to fight) and starts the dish's buff.
static func eat(data: GameStateData, id: String, items: ItemDB) -> Dictionary:
	var it := items.get_item(id)
	var bag := Bag.new(data.bag)
	if it.is_empty() or str(it.get("kind", "")) != "meal" or bag.count(id) < 1:
		return {"ok": false, "text": "You don't have any."}
	var lead: Creature = data.first_able()
	if lead == null:
		return {"ok": false, "text": "Nobody's in a fit state for a sit-down meal."}
	if active(data) != "":
		var cur := items.get_item(active(data))
		return {"ok": false, "text": "You're still full from the %s. Give it a while." % str(cur.get("name", "last one"))}
	bag.remove(id)
	var got := lead.heal(int(it.get("amount", 0)))
	data.set_flag(FLAG, id)
	data.set_flag(STEPS_FLAG, int(it.meal.get("steps", 0)) if it.meal.buff == "lure" else 0)
	var text := "You tuck into the %s." % str(it.name)
	if got > 0:
		text += " %s got %d HP back." % [lead.display_name(), got]
	return {"ok": true, "text": text + " " + str(it.effect_text)}

## What the dish does as a battle of `battle_kind` starts: {} (nothing), or the buff dict plus "text". A buff is
## taken once and the meal is gone; a catch buff waits for a wild battle, a purse buff for a keeper battle.
## The stat text keeps "{name}" for the caller to fill in.
static func take_battle_buff(data: GameStateData, items: ItemDB, battle_kind: String) -> Dictionary:
	var id := active(data)
	if id == "":
		return {}
	var m: Dictionary = items.get_item(id).get("meal", {})
	var buff := str(m.get("buff", ""))
	if buff == "lure" or buff not in BUFFS:
		return {}
	if (buff == "catch" and battle_kind != "wild") or (buff == "purse" and battle_kind == "wild"):
		return {}
	_clear(data)
	var out := m.duplicate()
	var dish := str(items.get_item(id).get("name", id))
	match buff:
		"stat":
			out["text"] = "The %s is still doing {name} good: %s up!" % [dish, STAT_NAMES.get(str(m.stat), "stat")]
		"catch":
			out["text"] = "The %s has you feeling lucky with snares." % dish
		"purse":
			out["text"] = "The %s has you on form for a bit of prize money." % dish
	return out

## One step taken. True on the step a lure wears off.
static func step(data: GameStateData) -> bool:
	var n := steps_left(data)
	if n < 1:
		return false
	n -= 1
	data.set_flag(STEPS_FLAG, n)
	if n == 0:
		_clear(data)
		return true
	return false

## Step-chance multiplier for wild encounters (flags are the save flags).
static func lure_mult(flags: Dictionary) -> float:
	var v: Variant = flags.get(STEPS_FLAG)
	return LURE_MULT if typeof(v) in [TYPE_INT, TYPE_FLOAT] and int(v) > 0 else 1.0

## Everything wrong with a dish item (empty when fine). Buffs stay modest.
static func problems(it: Dictionary) -> Array:
	var e := []
	var m = it.get("meal", {})
	if not m is Dictionary or str(m.get("buff", "")) not in BUFFS:
		return ["meal needs a known buff"]
	if int(it.get("amount", 0)) < 1 or int(it.get("amount", 0)) > 60:
		e.append("heal amount should be 1..60")
	match str(m.buff):
		"stat":
			if str(m.get("stat", "")) not in STAT_NAMES:
				e.append("unknown stat")
		"catch":
			if float(m.get("mult", 0)) <= 1.0 or float(m.get("mult", 0)) > 1.3:
				e.append("catch mult should be above 1 and at most 1.3")
		"purse":
			if int(m.get("pct", 0)) < 1 or int(m.get("pct", 0)) > 30:
				e.append("purse pct should be 1..30")
		"lure":
			if int(m.get("steps", 0)) < 20 or int(m.get("steps", 0)) > 100:
				e.append("lure steps should be 20..100")
	return e
