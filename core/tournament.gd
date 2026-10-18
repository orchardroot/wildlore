class_name Tournament
extends RefCounted
## County Shows (from the second badge) and the Open Moot (after the Champion): repeatable tournaments.
## One show is on each real day (Calendar.today_key) in a town you've been to; it's a three-round knockout against
## trainers drawn from data/trainers, re-levelled to just under you and never past the next Keeper's band, with a
## ruleset of the day. The Open Moot at Stonehenge is five back to back, scaled to your team. Your creatures fight
## as exhibition copies (capped to the class, no XP, home exactly as they went), so nothing can be lost.
## Prizes are Show Rosettes (a key item, counted in the bag), traded at the show ring for charms, snares,
## materials and recipes. Pure logic (no autoloads): the story side is story/tournament_run.gd, the
## dressing world/show_ring.gd, the data data/shows.json.

const DATA_PATH := "res://data/shows.json"
const ROSETTE := "show_rosette"
const MIN_BADGES := 2
## The top level of each Keeper's team in badge order, then the Champion: with n badges the cap is entry n.
const KEEPER_CAPS := [12, 22, 28, 35, 50, 50, 54, 68, 79, 88, 91]
const OPEN_CAP := 100
const RULES := ["singles", "doubles", "type", "no_items", "lightweights"]
const RULE_NAMES := {"singles": "Singles", "doubles": "Doubles", "no_items": "No Items", "lightweights": "Lightweights"}
const RULE_TEXT := {
	"singles": "One at a time, the old-fashioned way.",
	"doubles": "Two out at once on each side. Mind your elbows.",
	"type": "Only %s creatures in the ring today. The judges are very particular.",
	"no_items": "Nothing from the bag and no charms held. Your creatures, your wits, and that's your lot.",
	"lightweights": "Only creatures still due to grow up. The big lads can watch from the hay bales.",
}
const SHOW_SIZE := 3       # creatures a side at a show
const MOOT_SIZE := 6
const SHOW_ROUNDS := 3
const MOOT_ROUNDS := 5
const FEE := 50
const WARES_A_DAY := 4
const MOOT_ROSETTES := 3
const TITLE_WINS := 3

# flags (save-safe: all default to nothing)
const TODAY := "show_today"             # {key, id}: today's show, kept once picked
const SHOW_PAID := "show_paid"          # DailyKey stamp of the last rosettes paid at a show
const SHOW_PAID_N := "show_paid_n"      # how many that day
const SHOW_WINS := "show_wins"          # red rosettes won, ever
const MOOT_STREAK := "moot_open_streak" # Open Moot fights won in a row
const MOOT_BEST := "moot_open_best"
const MOOT_WINS := "moot_open_wins"     # whole Open Moots won
const MOOT_RUNS := "moot_open_runs"     # Open Moots entered (seeds each draw)

static var _config: Dictionary = {}
static var _pre: Dictionary = {}        # species -> what it evolved from
static var _pre_dex_id := 0

static func config() -> Dictionary:
	if _config.is_empty():
		var raw: Variant = JsonUtil.read(DATA_PATH)
		_config = raw if raw is Dictionary else {}
		for k in ["shows", "wares", "moot_wares", "moot_prizes"]:
			if not (_config.get(k) is Array):
				_config[k] = []
	return _config

static func shows() -> Array:
	return config().shows

static func show_by_id(id: String) -> Dictionary:
	for s in shows():
		if str(s.id) == id:
			return s
	return {}

static func _rng(seed_text: String) -> Rng:
	return Rng.new(absi(hash(seed_text)))

static func _shuffled(arr: Array, rng: Rng) -> Array:
	var out := arr.duplicate()
	for i in range(out.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = out[i]
		out[i] = out[j]
		out[j] = t
	return out

# ---------------------------------------------------------------- the show of the day

## The show on the date `key`, from the shows in `visited` towns (the Cheshire Show, at home, if none).
static func show_for(key: String, visited: Array) -> Dictionary:
	var pool := shows().filter(func(s): return str(s.town) in visited)
	if pool.is_empty():
		pool = shows().slice(0, 1)
	if pool.is_empty():
		return {}
	return pool[_rng("show/" + key).roll_int(0, pool.size() - 1)]

## Today's show, picked the first time it's asked for each real day and kept, so visiting somewhere new
## halfway through the day doesn't move it.
static func today(data: GameStateData) -> Dictionary:
	for a in DevArgs.user_args():  # dev switch --show=<id>: that show is on today (screenshots)
		if a.begins_with("--show=") and not show_by_id(a.trim_prefix("--show=")).is_empty():
			return show_by_id(a.trim_prefix("--show="))
	var key := Calendar.today_key()
	var kept: Variant = data.flag(TODAY)
	if kept is Dictionary and str(kept.get("key", "")) == key and not show_by_id(str(kept.get("id", ""))).is_empty():
		return show_by_id(str(kept.id))
	var visited := []
	for s in shows():
		if data.flag("visited_" + str(s.town)) == true:
			visited.append(str(s.town))
	var s := show_for(key, visited)
	if not s.is_empty():
		data.set_flag(TODAY, {"key": key, "id": str(s.id)})
	return s

## Today's show if it's in `town`, else {}.
static func on_in(data: GameStateData, town: String) -> Dictionary:
	var s := today(data)
	return s if str(s.get("town", "")) == town else {}

static func open_to(data: GameStateData) -> bool:
	return data.badges.size() >= MIN_BADGES or data.flag("champion") == true

## What the wireless says after Today's Walk.
static func radio_line(data: GameStateData) -> String:
	var s := today(data)
	if s.is_empty():
		return ""
	return "And the County Show today is %s, %s. %s" % [str(s.name), str(s.where), str(s.blurb)]

# ---------------------------------------------------------------- caps and rules

static func level_cap(badges: int, champion: bool) -> int:
	if champion:
		return OPEN_CAP
	return KEEPER_CAPS[clampi(badges, 0, KEEPER_CAPS.size() - 1)]

static func cap_for(data: GameStateData) -> int:
	return level_cap(data.badges.size(), data.flag("champion") == true)

## The ruleset for a seed (a show and a date, or a Moot run): {id} or {id: "type", type}. The type class is
## always one somebody in `party` could enter; a rule nobody in the party can enter falls back to Singles.
static func ruleset(seed_text: String, party: Array) -> Dictionary:
	var rng := _rng("rule/" + seed_text)
	var r := {"id": RULES[rng.roll_int(0, RULES.size() - 1)]}
	if r.id == "type":
		var types := []
		for c in party:
			for t in c.types():
				if t not in types:
					types.append(t)
		types.sort()
		if types.is_empty():
			return {"id": "singles"}
		r["type"] = types[rng.roll_int(0, types.size() - 1)]
	if not party.is_empty() and eligible(party, r, MOOT_SIZE).picks.is_empty():
		return {"id": "singles"}
	return r

static func rule_name(r: Dictionary) -> String:
	if str(r.get("id", "")) == "type":
		return "%s class" % str(r.get("type", "")).capitalize()
	return str(RULE_NAMES.get(str(r.get("id", "")), "Singles"))

static func rule_text(r: Dictionary) -> String:
	var t := str(RULE_TEXT.get(str(r.get("id", "")), RULE_TEXT.singles))
	return t % str(r.get("type", "")).capitalize() if str(r.get("id", "")) == "type" else t

static func fits(sp: Dictionary, r: Dictionary) -> bool:
	match str(r.get("id", "")):
		"type":
			return str(r.get("type", "")) in sp.get("types", [])
		"lightweights":
			return sp.get("evolves") != null
	return true

## Who from `party` can enter (up to `most`, in party order): {picks: [party indices], why: "" or a kind reason}.
## Fainted creatures are fine: everyone is patched up before the first round.
static func eligible(party: Array, r: Dictionary, most: int) -> Dictionary:
	var picks := []
	for i in party.size():
		if picks.size() < most and fits(party[i].species, r):
			picks.append(i)
	var why := ""
	if party.is_empty():
		why = "You'll need at least one creature with you to enter."
	elif picks.is_empty():
		match str(r.id):
			"type":
				why = "It's the %s today, and nobody in your team is %s. Any Sanctuary's Ark can swap someone in." % [rule_name(r), str(r.type).capitalize()]
			"lightweights":
				why = "It's the Lightweights today, for creatures still due to grow up, and your lot have done all their growing. The Ark can lend you someone smaller."
	elif str(r.id) == "doubles" and picks.size() < 2:
		why = "It's Doubles today, so you'll need two creatures with you. Even a small one counts."
		picks = []
	return {"picks": picks, "why": why}

# ---------------------------------------------------------------- foes

static func _pre_map(dex: Dex) -> Dictionary:
	if _pre_dex_id != dex.get_instance_id():
		_pre = {}
		_pre_dex_id = dex.get_instance_id()
		for id in dex.ids():
			var evo: Variant = dex.get_species(id).get("evolves")
			if evo is Dictionary and str(evo.get("to", "")) != "":
				_pre[str(evo.to)] = id
	return _pre

## The species as it would be at `level`: an evolved form too young for its evolution level steps back down.
static func fit_for_level(sid: String, level: int, dex: Dex) -> String:
	var pre := _pre_map(dex)
	while pre.has(sid):
		var evo: Dictionary = dex.get_species(str(pre[sid])).evolves
		if not evo.has("level") or level >= int(evo.level):
			break
		sid = str(pre[sid])
	return sid

static func base_form(sid: String, dex: Dex) -> String:
	var pre := _pre_map(dex)
	while pre.has(sid):
		sid = str(pre[sid])
	return sid

## A trainer's team re-levelled to `level` and kept to the rule: [{species, level}], the last `size` that fit
## (aces usually come last). Moves are left to Creature.create, which picks the right ones for the level.
static func foe_party(def: Dictionary, level: int, r: Dictionary, dex: Dex, size: int) -> Array:
	var out := []
	for m in def.get("party", []):
		var sid := str(m.get("species", ""))
		if not dex.has(sid):
			continue
		if str(r.get("id", "")) == "lightweights":
			sid = base_form(sid, dex)
		sid = fit_for_level(sid, level, dex)
		if not fits(dex.get_species(sid), r):
			continue
		out.append({"species": sid, "level": level})
	return out.slice(maxi(0, out.size() - size))

## Trainers that can be drawn: everyday trainers for a show; for the Moot, every trainer and the Keepers too.
static func trainer_pool(moot: bool) -> Array:
	var out := []
	for id in StoryData.trainer_ids():
		var s := str(id)
		if s.begins_with("dev") or s.begins_with("testbed") or s.begins_with("kit_") or s.contains("rematch") or s.begins_with("reunion_"):
			continue
		if not moot and (s.begins_with("keeper_") or s.begins_with("champion") or s.begins_with("wind_") or s.begins_with("vane")):
			continue
		out.append(s)
	return out

## The bracket: `n` different trainers from `pool`, seeded, each with a team that fits the rule (two at least for
## Doubles). `levels` is one level for every round or an Array, one per round. Returns trainer defs ready to fight.
static func draw(seed_text: String, pool: Array, n: int, r: Dictionary, dex: Dex, levels: Variant, size := SHOW_SIZE, min_party := 1) -> Array:
	var rng := _rng("draw/" + seed_text)
	var need := maxi(min_party, 2 if str(r.get("id", "")) == "doubles" else 1)
	var out := []
	for id in _shuffled(pool, rng):
		if out.size() >= n:
			break
		var lvl := int(levels[out.size()]) if levels is Array else int(levels)
		var def := StoryData.trainer(str(id))
		if def.is_empty():
			continue
		var party := foe_party(def, lvl, r, dex, size)
		if party.size() < need:
			continue
		var t := def.duplicate()
		t["party"] = party
		t["money"] = 0
		t.erase("reward")
		if need == 2:
			t["double"] = true
		out.append(t)
	return out

## The Open Moot's five: four challengers from anywhere (three strong where the rule allows), then a Keeper on the
## heel stone (or one more challenger, if no Keeper's team fits the rule). `levels` has one per round.
static func moot_bracket(seed_text: String, r: Dictionary, dex: Dex, levels: Array) -> Array:
	var keepers := []
	var others := []
	for id in trainer_pool(true):
		if str(id).begins_with("keeper_"):
			keepers.append(id)
		elif not str(id).begins_with("champion"):
			others.append(id)
	var out := draw(seed_text, others, MOOT_ROUNDS - 1, r, dex, levels.slice(0, MOOT_ROUNDS - 1), MOOT_SIZE, 3)
	if out.size() < MOOT_ROUNDS - 1:  # a narrow class: smaller teams will do
		var taken := out.map(func(t): return str(t.id))
		var more := draw(seed_text + "/more", others.filter(func(id): return id not in taken), MOOT_ROUNDS - 1 - out.size(), r, dex, levels.slice(out.size(), MOOT_ROUNDS - 1), MOOT_SIZE)
		out.append_array(more)
	var heel := draw(seed_text + "/heel", keepers, 1, r, dex, [levels[MOOT_ROUNDS - 1]], MOOT_SIZE)
	if heel.is_empty():
		var taken := out.map(func(t): return str(t.id))
		heel = draw(seed_text + "/heel", others.filter(func(id): return id not in taken), 1, r, dex, [levels[MOOT_ROUNDS - 1]], MOOT_SIZE)
	out.append_array(heel)
	return out

## Foe level at a show: a touch under your best entrant in round one, level with it in the final, never past the cap.
static func show_level(round_i: int, top: int, cap: int) -> int:
	return clampi(mini(top, cap) - (SHOW_ROUNDS - 1 - round_i), 2, cap)

## Foe level at the Open Moot: from two under your team's level to two over.
static func moot_level(round_i: int, team: int) -> int:
	return clampi(team - 2 + round_i, 2, OPEN_CAP)

# ---------------------------------------------------------------- prizes

## Rounds won to rosettes: out in the semi (one win) is a yellow, the runner-up a blue, the winner a red.
static func rosettes_for(wins: int) -> int:
	return clampi(wins, 0, SHOW_ROUNDS)

static func rosette_colour(wins: int) -> String:
	return ["", "yellow", "blue", "red"][clampi(wins, 0, 3)]

## Pays show rosettes for a placement worth `earned`, topping up to the best placement today (so the day's most
## is three, and a retry never farms). Returns how many were added. See DailyKey for "today".
static func pay_show(data: GameStateData, earned: int) -> int:
	var already := int(data.flag(SHOW_PAID_N)) if DailyKey.done_today(data, SHOW_PAID) and data.flag(SHOW_PAID_N) != null else 0
	var owed := maxi(0, earned - already)
	if owed <= 0:
		return 0
	var got := Bag.new(data.bag).add(ROSETTE, owed)
	data.set_flag(SHOW_PAID, DailyKey.stamp(data))
	data.set_flag(SHOW_PAID_N, already + got)
	return got

static func _count(data: GameStateData, key: String) -> int:
	var v: Variant = data.flag(key)
	return int(v) if typeof(v) in [TYPE_INT, TYPE_FLOAT] else 0

static func shows_won(data: GameStateData) -> int:
	return _count(data, SHOW_WINS)

static func note_show_win(data: GameStateData) -> void:
	data.set_flag(SHOW_WINS, shows_won(data) + 1)

static func streak(data: GameStateData) -> int:
	return _count(data, MOOT_STREAK)

static func best_streak(data: GameStateData) -> int:
	return _count(data, MOOT_BEST)

static func moot_wins(data: GameStateData) -> int:
	return _count(data, MOOT_WINS)

static func moot_runs(data: GameStateData) -> int:
	return _count(data, MOOT_RUNS)

static func moot_champion(data: GameStateData) -> bool:
	return moot_wins(data) >= TITLE_WINS

## One Open Moot fight done: a win adds to the streak (which carries from one Moot to the next), a loss ends it.
static func note_moot_fight(data: GameStateData, won: bool) -> void:
	var s := streak(data) + 1 if won else 0
	data.set_flag(MOOT_STREAK, s)
	if s > best_streak(data):
		data.set_flag(MOOT_BEST, s)

static func note_moot_win(data: GameStateData) -> void:
	data.set_flag(MOOT_WINS, moot_wins(data) + 1)

## The rare prize for an Open Moot win, in turn.
static func moot_prize(data: GameStateData) -> String:
	var p: Array = config().moot_prizes
	return str(p[moot_wins(data) % p.size()]) if not p.is_empty() else ""

# ---------------------------------------------------------------- the rosette stall

## What the stall has today: WARES_A_DAY from the list (recipes you know left out), plus one piece of Moot stock
## once you're Champion. Stable all day.
static func wares(key: String, data: GameStateData) -> Array:
	var rng := _rng("wares/" + key)
	var pool: Array = config().wares.filter(func(w): return not w.has("recipe") or not Crafting.is_known(data, str(w.recipe)))
	var out := _shuffled(pool, rng).slice(0, WARES_A_DAY)
	var moot: Array = config().moot_wares
	if data.flag("champion") == true and not moot.is_empty():
		out.append(moot[rng.roll_int(0, moot.size() - 1)])
	return out

static func ware_name(w: Dictionary, items: ItemDB) -> String:
	if w.has("recipe"):
		var r := Crafting.get_recipe(str(w.recipe))
		return "Recipe: " + str(items.get_item(str(r.get("out", w.recipe))).get("name", str(w.recipe).capitalize()))
	var nm := str(items.get_item(str(w.item)).get("name", str(w.item).capitalize()))
	return nm + (" x%d" % int(w.n) if int(w.get("n", 1)) > 1 else "")

static func ware_label(w: Dictionary, items: ItemDB) -> String:
	var c := int(w.get("cost", 1))
	return "%s (%d rosette%s)" % [ware_name(w, items), c, "" if c == 1 else "s"]

## Trades rosettes for a ware: {ok, text}.
static func buy(data: GameStateData, w: Dictionary, items: ItemDB) -> Dictionary:
	var bag := Bag.new(data.bag)
	var cost := int(w.get("cost", 1))
	if bag.count(ROSETTE) < cost:
		return {"ok": false, "text": "That one's %d rosette%s, and you've %d. Win a few more and come back." % [cost, "" if cost == 1 else "s", bag.count(ROSETTE)]}
	if w.has("recipe"):
		if Crafting.is_known(data, str(w.recipe)):
			return {"ok": false, "text": "You know that one already, love."}
		Crafting.learn(data, str(w.recipe))
		bag.remove(ROSETTE, cost)
		var nm := ware_name(w, items).trim_prefix("Recipe: ")
		return {"ok": true, "text": "%s learnt how to make %s." % [data.player_name, nm]}
	var got := bag.add(str(w.item), int(w.get("n", 1)))
	if got <= 0:
		return {"ok": false, "text": "Your bag's full of those already."}
	bag.remove(ROSETTE, cost)
	return {"ok": true, "text": "%s received %s." % [data.player_name, ware_name(w, items) if got == int(w.get("n", 1)) else "%s x%d" % [str(items.get_item(str(w.item)).get("name", w.item)), got]]}

# ---------------------------------------------------------------- the Stats page

static func stat_lines(data: GameStateData) -> Array:
	var out := [["County Shows won", str(shows_won(data))], ["Best Open Moot streak", str(best_streak(data))]]
	if moot_champion(data):
		out.append(["Title", "Moot Champion"])
	return out
