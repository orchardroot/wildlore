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
var day_count := 0  # in-game midnights passed; drives once-a-day things
var last_sanctuary: Dictionary = {"zone": "macclesfield", "pos": [-1, -1]}  # (-1, -1) = the zone's spawn
var rng_seed := 0
var weather := ""          # the outdoor weather right now ("" = roll it at the next outdoor zone)
var weather_region := ""   # the region it was rolled for
var weather_until := 0     # world minute (see world_minutes) it lasts until

const WEATHER_MIN := 20    # in-game minutes a spell of weather lasts
const WEATHER_MAX := 40

## Where a fresh journey whites out to: the tile just outside Macclesfield's Sanctuary door.
static func default_sanctuary() -> Dictionary:
	var z := ZoneData.load_id("macclesfield")
	for w in z.warps:
		if str(w.get("to", "")) == "macc_sanctuary":
			return {"zone": "macclesfield", "pos": [int(w.x), int(w.y) + 1]}
	return {"zone": "macclesfield", "pos": [-1, -1]}

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

## Minutes since the journey's first midnight: the clock plus whole days.
func world_minutes() -> int:
	return day_count * GameClock.DAY + clock_minutes

func weather_expired() -> bool:
	return weather == "" or world_minutes() >= weather_until

## The weather for a zone. The outdoor weather is kept zone to zone until it runs out or the region changes,
## then re-rolled from `table`. Interiors inherit it (never re-roll). A zone whose table never has the
## region's weather (a cave, a sheltered glen) shows its own pick without changing the region's.
func weather_for(region: String, table: Dictionary, interior: bool, rng: Rng) -> String:
	if interior:
		return weather if weather != "" else "clear"
	if weather_expired() or region != weather_region:
		weather = Weather.pick(table, rng)
		weather_region = region
		weather_until = world_minutes() + rng.roll_int(WEATHER_MIN, WEATHER_MAX)
	if table.is_empty():
		return "clear"
	if float(table.get(weather, 0)) <= 0.0:
		return Weather.pick(table, rng)
	return weather

func to_dict() -> Dictionary:
	return {
		"player_name": player_name, "rival_name": rival_name,
		"party": party.map(func(c): return c.to_dict()),
		"ark": ark.map(func(c): return c.to_dict()),
		"bag": bag.duplicate(), "money": money, "flags": flags.duplicate(true),
		"zone_id": zone_id, "pos": [pos.x, pos.y], "facing": facing,
		"seen": seen.duplicate(), "caught": caught.duplicate(), "badges": badges.duplicate(),
		"play_seconds": play_seconds, "clock_minutes": clock_minutes, "day_count": day_count,
		"last_sanctuary": last_sanctuary.duplicate(true), "rng_seed": rng_seed,
		"weather": weather, "weather_region": weather_region, "weather_until": weather_until,
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
	s.day_count = int(d.get("day_count", 0))
	var ls: Dictionary = d.get("last_sanctuary", {})
	var lp: Array = ls.get("pos", [-1, -1])
	s.last_sanctuary = {"zone": str(ls.get("zone", "macclesfield")), "pos": [int(lp[0]), int(lp[1])]}
	s.rng_seed = int(d.get("rng_seed", 0))
	s.weather = str(d.get("weather", ""))
	s.weather_region = str(d.get("weather_region", ""))
	s.weather_until = int(d.get("weather_until", 0))
	return s
