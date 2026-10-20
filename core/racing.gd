class_name Racing
extends RefCounted
## Creature racing at Aintree, shown live in the bookies in Glasgow and Belfast. Each real day has a meeting: race
## k's card (runners, form, prices) comes from the date and k alone, so every venue shows the same card. Prices
## come from the runners' stats, their form and the going (from the weather), turned into British fractional odds
## with the bookmaker's margin. The result is NOT on the card: it's rolled from the save's stream (Punt.rng) when
## the race goes off, which is when the bets are struck.
## Plus the daily novice race, where you can run one of your own team for prize money. Pure logic.

const DAY_FLAG := "race_day"
const NEXT_FLAG := "race_k"
const NOVICE_FLAG := "race_novice_day"

## How much a runner's day can vary (the luck of the race).
const SIGMA := 0.08
## The book's overround: a fair price is cut to 1 / (p x MARGIN) before rounding down the ladder.
const MARGIN := 1.04
## No each-way bet may be worth more than this per pound staked.
const EW_CAP := 0.95
const TRIALS := 3000
const CHECKPOINTS := 5

## Runners for the daily meeting: fleet-footed creatures, no legends.
const POOL := ["foalmoor", "tormane", "connie", "connemarr", "horselet", "horseshoe", "kelpie", "leveret", "gealhare",
	"snowhare", "barkdeer", "stagmor", "fawnlet", "sikawhistle", "roachroo", "scuttlet", "warrender", "binfox",
	"raidtail", "greyhaul", "loaghtan", "glisglis", "stoatlet", "ermine", "redbreast", "dipling", "minkshade",
	"ratty", "rillotter", "wildkit", "highlynx", "pooka", "natterjack", "whiffhorn", "duneskink", "kidgruff", "billgruff"]

const RACES := [
	["The Mersey Novices' Hurdle", "2m 1f", "hurdle"], ["The Red Rum Handicap Chase", "2m", "chase"],
	["The Sefton Novices' Hurdle", "3m", "hurdle"], ["The Becher Handicap Chase", "3m 2f", "chase"],
	["The Liverpool Hurdle", "3m", "hurdle"], ["The Melling Chase", "2m 4f", "chase"],
	["The Maghull Novices' Chase", "2m", "chase"], ["The Foxhunters' Open", "2m 5f", "chase"],
	["The Topham Handicap Chase", "2m 5f", "chase"], ["The Anniversary Juvenile Hurdle", "2m 1f", "hurdle"],
	["The Grand Sefton Chase", "2m 5f", "chase"], ["The Scouse Bumper", "2m 1f", "flat"],
]
const NAME_A := ["Mersey", "Scouse", "Kipper", "Chippy", "Brass", "Mardy", "Proper", "Dead", "Our", "Lucky", "Tidy",
	"Cheeky", "Red", "Mucky", "Soft", "Champion", "Canny", "Bonny", "Wee", "Grand", "Big", "Little", "Wise", "Fair"]
const NAME_B := ["Beat", "Pride", "Tea", "Neck", "Bum", "Job", "Ringer", "Our Kid", "Lad", "Lass", "Dancer", "Pudding",
	"Rumble", "Lark", "Fella", "Gravy", "Butty", "Rascal", "Ferry", "Charmer", "Ticket", "Biscuit", "Brew", "Nudge"]
const SILKS := ["c8282c", "2f5fb0", "e8c872", "2f7a3a", "f2e8cf", "1d2230", "9b6fb0", "e07a2a", "6fc0d8", "7a3a30"]

const GOINGS := {
	"good_to_firm": {"id": "good_to_firm", "name": "Good to Firm", "value": -1},
	"good": {"id": "good", "name": "Good", "value": 0},
	"good_to_soft": {"id": "good_to_soft", "name": "Good to Soft", "value": 1},
	"soft": {"id": "soft", "name": "Soft", "value": 2},
	"heavy": {"id": "heavy", "name": "Heavy", "value": 3},
}
## Types that love a bit of cut in the ground, and those that want it fast.
const MUD_LOVERS := ["brook", "bog", "tide", "hedgerow", "frost"]
const FIRM_LOVERS := ["stone", "hearth", "iron", "gale", "storm", "urban"]

static func going_for(weather: String) -> Dictionary:
	match weather:
		"sunshine":
			return GOINGS.good_to_firm
		"drizzle", "fog":
			return GOINGS.good_to_soft
		"downpour":
			return GOINGS.heavy
		"frost", "gale":
			return GOINGS.soft
	return GOINGS.good

## +1 for a mudlark, -1 for a fast-ground creature, 0 for neither.
static func going_pref(sp: Dictionary) -> int:
	var t: Array = sp.get("types", [])
	if t.is_empty():
		return 0
	if str(t[0]) in MUD_LOVERS:
		return 1
	if str(t[0]) in FIRM_LOVERS:
		return -1
	return 0

## A runner's ability: pace first, then stamina (more over a long trip), a little power, then the going.
static func rating(sp: Dictionary, going: Dictionary, long := 0.5, base_override := {}) -> float:
	var b: Dictionary = base_override if not base_override.is_empty() else sp.get("base", {})
	var r := float(b.get("spd", 50)) + float(b.get("hp", 50)) * (0.2 + 0.2 * long) + float(b.get("atk", 50)) * 0.15 \
		+ float(b.get("def", 50)) * 0.05
	return r * (1.0 + 0.03 * going_pref(sp) * float(going.get("value", 0)))

static func places_for(runners: int) -> int:
	return 3 if runners >= 8 else (2 if runners >= 5 else 1)

static func place_fraction(runners: int) -> Array:
	return [1, 5] if runners >= 8 else [1, 4]

static func _seed(text: String) -> Rng:
	return Rng.new(posmod(hash(text), 2147483647))

static func _gauss(rng: Rng) -> float:
	var u := maxf(rng.roll(), 0.000001)
	return sqrt(-2.0 * log(u)) * cos(TAU * rng.roll())

static func _long(distance: String) -> float:
	var miles := float(distance.substr(0, 1))
	var f := distance.find("f")
	var furlongs := float(distance.substr(f - 1, 1)) if f > 0 else 0.0
	return clampf((miles + furlongs / 8.0 - 2.0) / 1.25, 0.0, 1.0)

## Race k of the meeting on `day` (a Calendar.today_key) on this going.
static func card(day: String, k: int, going: Dictionary, dex: Dex) -> Dictionary:
	var rng := _seed("card/%s/%d" % [day, k])
	var race: Array = RACES[posmod(hash(day) + k, RACES.size())]
	var long := _long(str(race[1]))
	var pool := POOL.filter(func(id): return dex.has(id))
	var rated := {}
	for id in pool:
		rated[id] = rating(dex.get_species(id), going, long)
	# a competitive field: everyone within a band of a randomly chosen yardstick runner
	var anchor: float = rated[pool[rng.roll_int(0, pool.size() - 1)]]
	var n := rng.roll_int(6, 8)
	var field := []
	for band in [0.08, 0.12, 0.18, 0.3, 1.0]:
		field = pool.filter(func(id): return absf(float(rated[id]) - anchor) <= anchor * band)
		if field.size() >= n:
			break
	var runners := []
	var names := {}
	while runners.size() < n and not field.is_empty():
		var id: String = field.pop_at(rng.roll_int(0, field.size() - 1))
		runners.append(_runner(dex.get_species(id), _name(rng, names), float(rated[id]), rng, anchor))
	var mins := 13 * 60 + 30 + (k - 1) * 35
	var c := {"id": "%s/%d" % [day, k], "day": day, "k": k, "name": race[0], "distance": race[1], "kind": race[2],
		"time": "%d:%02d" % [(mins / 60 - 1) % 12 + 1, mins % 60], "going": going, "runners": runners}
	_price(c, rng)
	return c

static func _name(rng: Rng, used: Dictionary) -> String:
	for attempt in 50:
		var nm := "%s %s" % [NAME_A[rng.roll_int(0, NAME_A.size() - 1)], NAME_B[rng.roll_int(0, NAME_B.size() - 1)]]
		if not used.has(nm):
			used[nm] = true
			return nm
	return "Unnamed %d" % used.size()

## A runner: its rating with today's form folded in, recent form figures and racing silks.
## `par` is the field's yardstick rating: the form figures say how this one has been running against its class.
static func _runner(sp: Dictionary, nm: String, base_rating: float, rng: Rng, par: float, yours := false) -> Dictionary:
	var form_factor := _gauss(rng) * 0.03
	var figures := ""
	for i in 4:
		var mean := 3.5 - form_factor * 50.0 - (base_rating - par) / par * 25.0
		var pos := clampi(roundi(mean + _gauss(rng) * 1.8), 1, 9)
		figures += ("F" if rng.roll() < 0.04 else ("P" if rng.roll() < 0.03 else str(pos)))
	var a := rng.roll_int(0, SILKS.size() - 1)
	var b := posmod(a + rng.roll_int(1, SILKS.size() - 1), SILKS.size())
	return {"species": str(sp.id), "name": nm, "rating": snappedf(base_rating * (1.0 + form_factor), 0.001),
		"form": figures, "silks": [SILKS[a], SILKS[b], rng.roll_int(0, 3)], "yours": yours,
		"pace": int(sp.get("base", {}).get("spd", 50)), "stamina": int(sp.get("base", {}).get("hp", 50))}

## Win and place chances by simulation (seeded from the card), then the bookmaker's prices.
static func _price(c: Dictionary, rng: Rng) -> void:
	var runners: Array = c.runners
	var n := runners.size()
	var places := places_for(n)
	var wins := []
	var placed := []
	wins.resize(n)
	placed.resize(n)
	wins.fill(0)
	placed.fill(0)
	var perf := []
	perf.resize(n)
	for t in TRIALS:
		for i in n:
			perf[i] = float(runners[i].rating) * (1.0 + _gauss(rng) * SIGMA)
		for i in n:
			var ahead := 0
			for j in n:
				if perf[j] > perf[i]:
					ahead += 1
			if ahead == 0:
				wins[i] += 1
			if ahead < places:
				placed[i] += 1
	var frac := place_fraction(n)
	for i in n:
		var pw := maxf(float(wins[i]) / TRIALS, 0.002)
		var pp := maxf(float(placed[i]) / TRIALS, pw)
		var odds := Odds.at_most(1.0 / (pw * MARGIN) - 1.0)
		while Odds.LADDER.find(odds) > 0 and _ew_value(pw, pp, odds, frac) > EW_CAP:
			odds = Odds.shorter(odds)
		runners[i]["p_win"] = snappedf(pw, 0.0001)
		runners[i]["p_place"] = snappedf(pp, 0.0001)
		runners[i]["odds"] = odds

static func _ew_value(pw: float, pp: float, odds: Array, frac: Array) -> float:
	var o := Odds.value(odds)
	return 0.5 * pw * (1.0 + o) + 0.5 * pp * (1.0 + o * frac[0] / frac[1])

## Runs a race: {order (runner indices, winner first), perf, legs (per checkpoint, each runner's standing value)}.
static func run(c: Dictionary, rng: Rng) -> Dictionary:
	var runners: Array = c.runners
	var n := runners.size()
	var perf := []
	for i in n:
		perf.append(float(runners[i].rating) * (1.0 + _gauss(rng) * SIGMA))
	var order := range(n)
	order.sort_custom(func(a, b): return perf[a] > perf[b])
	var legs := []
	for cp in CHECKPOINTS:
		var spread := 1.0 - float(cp + 1) / CHECKPOINTS  # the luck in running fades out by the line
		var leg := []
		for i in n:
			leg.append(perf[i] + _gauss(rng) * float(runners[i].rating) * SIGMA * 0.8 * spread)
		legs.append(leg)
	legs[CHECKPOINTS - 1] = perf.duplicate()
	return {"order": order, "perf": perf, "legs": legs}

static func _order_of(values: Array) -> Array:
	var o := range(values.size())
	o.sort_custom(func(a, b): return values[a] > values[b])
	return o

## Stake back plus winnings for a bet {runner, stake, each_way}. Each-way: `stake` on the win and `stake` on the
## place (so it costs twice the stake); the place half pays a fraction of the odds.
static func returns(c: Dictionary, order: Array, bet: Dictionary) -> int:
	var i := int(bet.runner)
	var stake := int(bet.stake)
	var odds: Array = c.runners[i].odds
	var back := 0
	if order[0] == i:
		back += Odds.returns(stake, odds)
	if bool(bet.get("each_way", false)):
		var n: int = c.runners.size()
		var pos := order.find(i)
		if pos >= 0 and pos < places_for(n):
			var f := place_fraction(n)
			back += stake + int(floor(float(stake) * int(odds[0]) * int(f[0]) / (int(odds[1]) * int(f[1])) + 0.000001))
	return back

## Distance between two finishers, in racing terms.
static func margin_text(a: float, b: float) -> String:
	var lengths := (a - b) / maxf(a, 1.0) * 120.0
	if lengths < 0.1:
		return "a short head"
	if lengths < 0.25:
		return "a head"
	if lengths < 0.5:
		return "a neck"
	if lengths < 0.9:
		return "half a length"
	if lengths < 15.0:
		var whole := roundi(lengths)
		return "%s length%s" % [["", "a", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"][clampi(whole, 1, 14)], "" if whole <= 1 else "s"]
	return "a distance"

## The commentary: a line per checkpoint and the result. No em-dashes.
static func commentary(c: Dictionary, r: Dictionary) -> Array:
	var nm := func(i: int) -> String: return str(c.runners[i].name)
	var lines := []
	var legs: Array = r.legs
	var o0 := _order_of(legs[0])
	var slow: int = o0[o0.size() - 1]
	lines.append("And they're off! %s jumps out smartly, %s a bit slow away." % [nm.call(o0[0]), nm.call(slow)])
	var o1 := _order_of(legs[1])
	var obstacle := "Over the first" if str(c.kind) != "flat" else "Into the first furlong"
	lines.append("%s, %s leads from %s, with %s tucked in on the rail." % [obstacle, nm.call(o1[0]), nm.call(o1[1]), nm.call(o1[2])])
	var o2 := _order_of(legs[2])
	var mover: int = o2[0]
	var gained := -1
	for i in o2.size():
		var was := o1.find(o2[i])
		if was - i > gained:
			gained = was - i
			mover = o2[i]
	if mover != o2[0] and gained >= 2:
		lines.append("Halfway, and %s's still in front, but here comes %s, making ground hand over fist!" % [nm.call(o2[0]), nm.call(mover)])
	else:
		lines.append("Halfway, and %s is bowling along in front. The rest are going to have to find something." % nm.call(o2[0]))
	var o3 := _order_of(legs[3])
	lines.append("Turning for home, %s and %s, head to head, and the crowd are up!" % [nm.call(o3[0]), nm.call(o3[1])])
	var order: Array = r.order
	var perf: Array = r.perf
	var w: int = order[0]
	var odds := Odds.text(c.runners[w].odds)
	var by := margin_text(float(perf[order[0]]), float(perf[order[1]]))
	var tail := "" if order.size() < 3 else ", %s third" % nm.call(order[2])
	lines.append("%s wins it by %s at %s! %s second%s." % [nm.call(w), by, odds, nm.call(order[1]), tail])
	return lines

# ---------------------------------------------------------------- the meeting, day by day

static func next_race(data: GameStateData) -> int:
	if str(data.flag(DAY_FLAG)) != Calendar.today_key():
		return 1
	var v: Variant = data.flag(NEXT_FLAG)
	return maxi(1, int(v)) if (v is int or v is float) else 1

static func race_done(data: GameStateData) -> void:
	var k := next_race(data) + 1
	data.set_flag(DAY_FLAG, Calendar.today_key())
	data.set_flag(NEXT_FLAG, k)

# ---------------------------------------------------------------- the novice race

## One run a real day.
static func novice_run_today(data: GameStateData) -> bool:
	return str(data.flag(NOVICE_FLAG)) == Calendar.today_key()

static func mark_novice(data: GameStateData) -> void:
	data.set_flag(NOVICE_FLAG, Calendar.today_key())

## Prize money for finishing `place` (1st, 2nd, 3rd), more for a trainer with Stones to their name.
static func novice_prize(place: int, badges: int) -> int:
	var first := 400 + 100 * badges
	match place:
		1:
			return first
		2:
			return first * 2 / 5
		3:
			return first / 5
	return 0

## Your creature's own stats as racing stats: its species' base plus its IVs, training and nature.
static func own_base(c: Creature) -> Dictionary:
	var out := {}
	for s in ["hp", "atk", "def", "spd"]:
		var b := float(c.species.base.get(s, 50)) + float(c.ivs.get(s, 0)) + float(c.training.get(s, 0)) / 8.0
		out[s] = b * c.nature_mod(s)
	return out

## The novice race: your creature against five newcomers of a similar class, all on today's going.
static func novice_card(day: String, mine: Creature, dex: Dex, going: Dictionary) -> Dictionary:
	var rng := _seed("novice/%s/%s" % [day, mine.species.id])
	var total := 0.0
	for v in mine.species.base.values():
		total += float(v)
	var pool := []
	for id in dex.ids():
		var sp := dex.get_species(id)
		if bool(sp.get("legend", false)) or id == str(mine.species.id):
			continue
		var t := 0.0
		for v in sp.get("base", {}).values():
			t += float(v)
		if absf(t - total) <= total * 0.15:
			pool.append(id)
	var names := {}
	var mine_name := mine.display_name()
	names[mine_name] = true
	var mine_rating := rating(mine.species, going, 0.4, own_base(mine))
	var runners := [_runner(mine.species, mine_name, mine_rating, rng, mine_rating, true)]
	while runners.size() < 6 and not pool.is_empty():
		var sp := dex.get_species(pool.pop_at(rng.roll_int(0, pool.size() - 1)))
		var b: Dictionary = sp.get("base", {}).duplicate()
		for s in b:
			b[s] = float(b[s]) + 7.0  # an average newcomer: middling IVs, a bit of schooling
		runners.append(_runner(sp, _name(rng, names), rating(sp, going, 0.4, b), rng, mine_rating))
	# shuffle the draw so yours isn't always in stall 1
	for i in range(runners.size() - 1, 0, -1):
		var j := rng.roll_int(0, i)
		var t = runners[i]
		runners[i] = runners[j]
		runners[j] = t
	var c := {"id": "novice/%s" % day, "day": day, "k": 0, "name": "The Aintree Novice Stakes", "distance": "1m 4f",
		"kind": "flat", "time": "5:15", "going": going, "runners": runners, "novice": true}
	_price(c, rng)
	return c

static func yours(c: Dictionary) -> int:
	for i in c.runners.size():
		if bool(c.runners[i].get("yours", false)):
			return i
	return -1
