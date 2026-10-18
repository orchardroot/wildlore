class_name TodaysWalk
extends RefCounted
## Today's Walk: each real day (Calendar.today_key) picks one featured species, uncaught if possible and from a
## region you've visited, whose encounter weight triples in one named zone; one bonus pub, where the quiz prize is
## doubled; and a weather bounty: catch any creature in the named weather today, then collect a reward from the
## wireless or a Sanctuary nurse. The Shipping Forecast reads it out and the pause menu shows it in a line.
## No streaks, no notifications, nothing lost by missing a day. Pure logic (no autoloads): text in data/daily.json.
##
## The day's pick is kept in the flag `todays_walk` ({key, species, zone, pub, weather, reward, reward_n}) the first
## time it's needed, so catching the featured creature doesn't change the walk halfway through the day.

const DATA_PATH := "res://data/daily.json"
const ZONE_DIR := "res://data/zones"
const FLAG := "todays_walk"
const BOUNTY_CAUGHT := "walk_bounty_caught"    # today's key once a creature was caught in the bounty weather
const BOUNTY_CLAIMED := "walk_bounty_claimed"  # today's key once the bounty was paid
const HOME_REGION := "cheshire"                # before you've been anywhere

static var _config: Dictionary = {}
static var _index: Dictionary = {}

static func config() -> Dictionary:
	if _config.is_empty():
		var raw: Variant = JsonUtil.read(DATA_PATH)
		_config = raw if raw is Dictionary else {}
	return _config

## Every zone with wild creatures: {zones: {id: {name, region, species}}, towns: {town_id: region},
## names: {zone id: name}}. Built once (a quick pass over the zone files), only when a new day needs a pick.
static func index() -> Dictionary:
	if not _index.is_empty():
		return _index
	var zones := {}
	var towns := {}
	var names := {}
	var files := Array(DirAccess.get_files_at(ZONE_DIR))
	files.sort()
	for f in files:
		if not str(f).ends_with(".json"):
			continue
		var d: Variant = JsonUtil.read("%s/%s" % [ZONE_DIR, f])
		if not (d is Dictionary):
			continue
		var id := str(f).get_basename()
		var region := str(d.get("region", ""))
		names[id] = str(d.get("name", id))
		if str(d.get("town_id", "")) != "":
			towns[str(d.town_id)] = region
		if region == "" or region == "dev":
			continue
		var sp: Array = []
		for e in d.get("encounters", {}).get("grass", []):
			# always-there entries only: a featured creature that only comes out at night in fog is a cruel joke
			if e.get("time", []).is_empty() and e.get("weather", []).is_empty() and e.get("season", []).is_empty() and str(e.get("species", "")) not in sp:
				sp.append(str(e.species))
		if not sp.is_empty():
			zones[id] = {"name": names[id], "region": region, "species": sp}
	_index = {"zones": zones, "towns": towns, "names": names}
	return _index

## Regions of the towns you've visited (the visited_<town> flags), or the home county before any.
static func visited_regions(data: GameStateData, ix: Dictionary) -> Dictionary:
	var out := {}
	var towns: Dictionary = ix.get("towns", {})
	for t in towns:
		if data.flag("visited_" + str(t)) == true:
			out[towns[t]] = true
	if out.is_empty():
		out[HOME_REGION] = true
	return out

## The walk for the date `key`: deterministic for the same key and save. `items` (may be null) filters the rewards
## to ones that exist.
static func pick(key: String, data: GameStateData, ix: Dictionary, cfg: Dictionary, items) -> Dictionary:
	var rng := Rng.new(absi(hash("walk/" + key)))
	var regions := visited_regions(data, ix)
	var zones: Dictionary = ix.get("zones", {})
	# species -> the visited zones they live in, in a fixed order
	var homes := {}
	var zone_ids := zones.keys()
	zone_ids.sort()
	for z in zone_ids:
		if not regions.has(zones[z].region):
			continue
		for s in zones[z].species:
			if not homes.has(s):
				homes[s] = []
			homes[s].append(z)
	if homes.is_empty():  # nowhere visited has anything: anywhere will do
		for z in zone_ids:
			for s in zones[z].species:
				if not homes.has(s):
					homes[s] = []
				homes[s].append(z)
	var all_sp := homes.keys()
	all_sp.sort()
	var uncaught := all_sp.filter(func(s): return not data.caught.has(s))
	var pool := uncaught if not uncaught.is_empty() else all_sp
	var species := ""
	var zone := ""
	if not pool.is_empty():
		species = str(pool[rng.roll_int(0, pool.size() - 1)])
		var zs: Array = homes[species]
		zone = str(zs[rng.roll_int(0, zs.size() - 1)])
	var pubs: Array = cfg.get("pubs", [])
	# only a pub in a town you've been to: a first-hour player isn't sent to The Cavern (no pub yet, no quiz line)
	var near := pubs.filter(func(p): return data.flag("visited_" + str(p.id)) == true)
	var pub_roll := rng.roll_int(0, (near if not near.is_empty() else pubs).size() - 1) if not pubs.is_empty() else 0  # same roll as ever
	var pub := str(near[pub_roll].id) if not near.is_empty() else ""
	var wkeys: Array = cfg.get("weathers", {}).keys()
	wkeys.sort()
	var weather := str(wkeys[rng.roll_int(0, wkeys.size() - 1)]) if not wkeys.is_empty() else "rain"
	var rewards: Array = cfg.get("rewards", []).filter(func(r): return items == null or items.has(str(r.item)))
	var reward: Dictionary = rewards[rng.roll_int(0, rewards.size() - 1)] if not rewards.is_empty() else {"item": "cup_of_tea", "n": 1}
	var names: Dictionary = ix.get("names", {})
	var pub_name := ""
	for p in pubs:
		if str(p.id) == pub:
			pub_name = str(names.get(str(p.zone), p.get("town", "")))
	return {"key": key, "species": species, "zone": zone, "pub": pub, "weather": weather,
		"reward": str(reward.item), "reward_n": int(reward.get("n", 1)), "reward_text": str(reward.get("text", "")),
		"zone_name": str(zones.get(zone, {}).get("name", names.get(zone, ""))), "pub_name": pub_name}

## Today's walk, picked and remembered the first time it's asked for each day. `ix` defaults to the real zones.
static func today(data: GameStateData, items, ix := {}) -> Dictionary:
	var key := Calendar.today_key()
	var w: Variant = data.flag(FLAG)
	if w is Dictionary and str(w.get("key", "")) == key:
		return w
	var fresh := pick(key, data, ix if not ix.is_empty() else index(), config(), items)
	data.set_flag(FLAG, fresh)
	return fresh

## Today's walk if it has been picked already, else {} (cheap: no zone files read).
static func current(data: GameStateData) -> Dictionary:
	var w: Variant = data.flag(FLAG)
	if w is Dictionary and str(w.get("key", "")) == Calendar.today_key():
		return w
	return {}

## The featured species in `zone_id` today, or "".
static func featured_in(data: GameStateData, zone_id: String) -> String:
	var w: Variant = data.flag(FLAG)
	if not (w is Dictionary) or str(w.get("zone", "")) != zone_id:
		return ""
	return str(w.get("species", "")) if str(w.get("key", "")) == Calendar.today_key() else ""

## Today's double-prize pub id, or "".
static func bonus_pub(data: GameStateData) -> String:
	return str(current(data).get("pub", ""))

# ---- the weather bounty

static func weather_name(w: Dictionary) -> String:
	return str(config().get("weathers", {}).get(str(w.get("weather", "")), {}).get("name", w.get("weather", "")))

## A creature was caught in `weather` (the outdoor weather right now): counts towards today's bounty if it matches.
static func note_catch(data: GameStateData, weather: String) -> void:
	var w := current(data)
	if w.is_empty():
		return
	var kinds: Array = config().get("weathers", {}).get(str(w.weather), {}).get("weathers", [])
	if weather in kinds:
		data.set_flag(BOUNTY_CAUGHT, Calendar.today_key())

static func bounty_ready(data: GameStateData) -> bool:
	var key := Calendar.today_key()
	return data.flag(BOUNTY_CAUGHT) == key and data.flag(BOUNTY_CLAIMED) != key

static func bounty_claimed(data: GameStateData) -> bool:
	return data.flag(BOUNTY_CLAIMED) == Calendar.today_key()

## Pays today's bounty if it's waiting: {ok, item, n, name} (a full bag pays nothing, and the bounty waits).
static func claim_bounty(data: GameStateData, items) -> Dictionary:
	if not bounty_ready(data):
		return {"ok": false}
	var w := current(data)
	var id := str(w.get("reward", "cup_of_tea"))
	var got := Bag.new(data.bag).add(id, int(w.get("reward_n", 1)))
	if got <= 0:
		return {"ok": false}
	data.set_flag(BOUNTY_CLAIMED, Calendar.today_key())
	return {"ok": true, "item": id, "n": got}

## How the radio says the reward: the walk's own words ("two pork pies") or the item's name.
static func reward_text(w: Dictionary, items) -> String:
	if str(w.get("reward_text", "")) != "":
		return str(w.reward_text)
	var id := str(w.get("reward", ""))
	var n := int(w.get("reward_n", 1))
	var nm := id.replace("_", " ")
	if items != null and items.has(id):
		nm = str(items.get_item(id).get("name", nm))
	if n > 1:
		return "%d %s" % [n, nm]
	return ("an " if nm.substr(0, 1).to_lower() in ["a", "e", "i", "o", "u"] else "a ") + nm

# ---- text

static func _fill(t: String, w: Dictionary, dex, items) -> String:
	var sid := str(w.get("species", ""))
	var sname := sid.capitalize()
	if dex != null and dex.has(sid):
		sname = str(dex.get_species(sid).get("name", sname))
	var town := ""
	for p in config().get("pubs", []):
		if str(p.id) == str(w.get("pub", "")):
			town = str(p.get("town", ""))
	return t.replace("{species}", sname).replace("{zone}", str(w.get("zone_name", ""))) \
		.replace("{pub}", str(w.get("pub_name", ""))).replace("{town}", town).replace("{weather}", weather_name(w)) \
		.replace("{reward}", reward_text(w, items))

static func _one(arr: Variant, key: String) -> String:
	if arr is Array and not arr.is_empty():
		return str(arr[absi(hash(key)) % arr.size()])
	return str(arr) if arr is String else ""

## The wireless, after the Shipping Forecast: today's walk read out, and a waiting bounty paid (which changes `data`).
static func radio_lines(data: GameStateData, dex, items, ix := {}) -> Array:
	var w := today(data, items, ix)
	var r: Dictionary = config().get("radio", {})
	var key := str(w.key)
	var lines: Array = [str(r.get("open", "And now, Today's Walk."))]
	if str(w.get("species", "")) != "":
		lines.append(_fill(_one(r.get("featured", []), key + "f"), w, dex, items))
	if str(w.get("pub", "")) != "":
		lines.append(_fill(_one(r.get("pub", []), key + "p"), w, dex, items))
	if bounty_claimed(data):
		lines.append(_fill(str(r.get("bounty_done", "")), w, dex, items))
	else:
		lines.append(_fill(_one(r.get("bounty", []), key + "b"), w, dex, items))
		var paid := claim_bounty(data, items)
		if bool(paid.ok):
			lines.append(_fill(str(r.get("bounty_paid", "")), w, dex, items))
	lines.append_array(Tournament.radio_lines(data))  # today's County Show
	lines.append(_one(r.get("close", []), key + "c"))
	return lines

## The nurse's line when she pays a waiting bounty ("" when there's nothing to pay). Changes `data`.
static func nurse_pays(data: GameStateData, items) -> String:
	var paid := claim_bounty(data, items)
	if not bool(paid.ok):
		return ""
	return _fill(str(config().get("nurse_paid", "")), current(data), null, items)

## The pause menu's one line ("" before today's walk has been picked).
static func summary(data: GameStateData, dex) -> String:
	var w := current(data)
	if w.is_empty() or str(w.get("species", "")) == "":
		return ""
	var quiz := _fill(str(config().get("menu_quiz", "")), w, dex, null) if str(w.get("pub", "")) != "" else ""
	return _fill(str(config().get("menu", "")), w, dex, null).replace("{quiz}", quiz)
