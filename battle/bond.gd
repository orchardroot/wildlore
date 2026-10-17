class_name Bond
extends RefCounted
## Friendship (Creature.friendship, 0..255): how it grows, how it shows (0 to 5 hearts) and what it does in battle.
## Perks only ever help the player's own creatures; Battle checks the side. Pure: no autoloads.

const MAX := 255
const HEART_AT := [50, 100, 150, 220, 255]  # one heart for each of these reached

# small, gentle amounts
const WALK := 1          # every WALK_STEPS steps walked as the follower
const WALK_STEPS := 96
const FEED := 2          # sharing a bit of food from the bag
const WIN := 1           # on the field for a won battle
const TALK := 1          # a chat with the follower, once per in-game hour
const FAINT := -1

## Data for the perks, lowest first. "min": the friendship needed.
const PERKS := [
	{"id": "shrug", "min": 150, "chance": 10.0, "msg": "{name} shook it off for you!",
		"line": "Shrugs off a status now and then"},
	{"id": "hang_on", "min": 220, "msg": "{name} hung on so you wouldn't worry!",
		"line": "hangs on at 1 HP once a battle"},
	{"id": "crit", "min": 255, "mult": 1.5, "line": "lands more critical hits"},
]

static func hearts(friendship: int) -> int:
	var n := 0
	for at in HEART_AT:
		if friendship >= at:
			n += 1
	return n

## Adds (or, for a negative n, takes) friendship within 0..MAX. Returns the real change.
static func add(c: Creature, n: int) -> int:
	var old := c.friendship
	c.friendship = clampi(old + n, 0, MAX)
	return c.friendship - old

static func perk(id: String) -> Dictionary:
	for p in PERKS:
		if p.id == id:
			return p
	return {}

static func has_perk(c: Creature, id: String) -> bool:
	var p := perk(id)
	return not p.is_empty() and c.friendship >= int(p.min)

## The summary's perk line: what it does for you now, or what the next heart brings.
static func perk_line(c: Creature) -> String:
	var have := []
	for p in PERKS:
		if c.friendship >= int(p.min):
			have.append(p.line)
	if not have.is_empty():
		var t := ", ".join(have)
		return t.left(1).to_upper() + t.substr(1) + "."
	return "At %d hearts: %s." % [hearts(int(PERKS[0].min)), str(PERKS[0].line).to_lower()]

## 150+: a small chance to shrug off a status. Only rolls when the perk is there.
static func shrugs(c: Creature, rng: Rng) -> bool:
	return has_perk(c, "shrug") and rng.chance(float(perk("shrug").chance))

static func crit_mult(c: Creature) -> float:
	return float(perk("crit").mult) if has_perk(c, "crit") else 1.0

static func message(id: String, name: String) -> String:
	return str(perk(id).get("msg", "")).replace("{name}", name)

## Talking to the follower: +TALK once per in-game hour. Returns true if it counted.
static func talk(data: GameStateData, c: Creature) -> bool:
	var hour := data.world_minutes() / 60
	if data.flag("bond_talk_hour") == hour:
		return false
	data.set_flag("bond_talk_hour", hour)
	add(c, TALK)
	return true
