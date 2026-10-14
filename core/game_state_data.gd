class_name GameStateData
extends RefCounted
## Everything a save file holds. Pure data plus small helpers, so it can be tested without autoloads.

const PARTY_MAX := 6

var player_name := "Sam"
var rival_name := "Kit"
var party: Array = []
var ark: Array = []
var bag: Dictionary = {}
var money := 500
var flags: Dictionary = {}
var zone_id := "macclesfield"
var pos := Vector2i(0, 0)
var facing := "down"
var seen: Dictionary = {}
var caught: Dictionary = {}
var badges: Array = []
var play_seconds := 0.0
var clock_minutes := 480
var last_sanctuary: Dictionary = {"zone": "macclesfield", "pos": [-1, -1]}  # (-1, -1) = the zone's spawn
var rng_seed := 0

func add_creature(c: Creature) -> String:
	mark_seen(c.species.id)
	mark_caught(c.species.id)
	if party.size() < PARTY_MAX:
		party.append(c)
		return "party"
	ark.append(c)
	return "ark"

## Party -> Ark. Returns "" on success or why not.
func deposit(i: int) -> String:
	if i < 0 or i >= party.size():
		return "Nobody there."
	if party.size() <= 1:
		return "You can't travel without a single companion."
	var able := party.filter(func(c): return not c.is_fainted())
	if not party[i].is_fainted() and able.size() <= 1:
		return "That's your last creature fit to battle. Keep them with you."
	ark.append(party[i])
	party.remove_at(i)
	return ""

## Ark -> party. Returns "" on success or why not.
func withdraw(j: int) -> String:
	if j < 0 or j >= ark.size():
		return "Nobody there."
	if party.size() >= PARTY_MAX:
		return "Your team is full. Deposit someone first."
	party.append(ark[j])
	ark.remove_at(j)
	return ""

func mark_seen(id: String) -> void:
	seen[id] = true

func mark_caught(id: String) -> void:
	seen[id] = true
	caught[id] = true

func heal_party() -> void:
	for c in party:
		c.hp = c.max_hp()
		c.status = ""
		c.status_turns = 0
		for m in c.moves:
			m.pp = m.max_pp

func first_able() -> Creature:
	for c in party:
		if not c.is_fainted():
			return c
	return null

func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value

func flag(key: String) -> Variant:
	return flags.get(key)

func to_dict() -> Dictionary:
	return {
		"player_name": player_name, "rival_name": rival_name,
		"party": party.map(func(c): return c.to_dict()),
		"ark": ark.map(func(c): return c.to_dict()),
		"bag": bag.duplicate(), "money": money, "flags": flags.duplicate(true),
		"zone_id": zone_id, "pos": [pos.x, pos.y], "facing": facing,
		"seen": seen.duplicate(), "caught": caught.duplicate(), "badges": badges.duplicate(),
		"play_seconds": play_seconds, "clock_minutes": clock_minutes,
		"last_sanctuary": last_sanctuary.duplicate(true), "rng_seed": rng_seed,
	}

static func from_dict(d: Dictionary, dex: Dex) -> GameStateData:
	var s := GameStateData.new()
	s.player_name = d.get("player_name", "Sam")
	s.rival_name = d.get("rival_name", "Kit")
	for cd in d.get("party", []):
		s.party.append(Creature.from_dict(cd, dex))
	for cd in d.get("ark", []):
		s.ark.append(Creature.from_dict(cd, dex))
	var bag_in: Dictionary = d.get("bag", {})
	for k in bag_in:
		s.bag[k] = int(bag_in[k])
	s.money = int(d.get("money", 0))
	s.flags = d.get("flags", {}).duplicate(true)
	for k in s.flags:
		if typeof(s.flags[k]) == TYPE_FLOAT and s.flags[k] == floorf(s.flags[k]):
			s.flags[k] = int(s.flags[k])
	s.zone_id = d.get("zone_id", "macclesfield")
	var p: Array = d.get("pos", [0, 0])
	s.pos = Vector2i(int(p[0]), int(p[1]))
	s.facing = d.get("facing", "down")
	s.seen = d.get("seen", {}).duplicate()
	s.caught = d.get("caught", {}).duplicate()
	s.badges = d.get("badges", []).duplicate()
	s.play_seconds = float(d.get("play_seconds", 0.0))
	s.clock_minutes = int(d.get("clock_minutes", 480))
	var ls: Dictionary = d.get("last_sanctuary", {})
	var lp: Array = ls.get("pos", [-1, -1])
	s.last_sanctuary = {"zone": str(ls.get("zone", "macclesfield")), "pos": [int(lp[0]), int(lp[1])]}
	s.rng_seed = int(d.get("rng_seed", 0))
	return s
