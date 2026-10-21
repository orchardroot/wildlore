class_name Darts
extends RefCounted
## Pub darts: the board, a steady-hand aiming reticle, 501 with a double to finish, locals who throw with a spread
## of their own, and a pub league ladder per nation (data/darts.json) with small prizes. Pure logic (no autoload
## names); ui/darts_screen.gd draws it and the story command {"do": "darts"} pays it out.
##
## Board units: the outer edge of the double ring is radius 1.0. Real dimensions: bull 12.7 mm and outer bull
## 31.8 mm across, treble and double rings 8 mm wide, 99 mm and 162 mm in from the wire to their inner edges, on a
## 340 mm board. (Stored as fractions of the 170 mm radius.)

const PATH := "res://data/darts.json"
const ORDER := [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5]
const BULL := 6.35 / 170.0
const OUTER_BULL := 15.9 / 170.0
const TREBLE_IN := 99.0 / 170.0
const TREBLE_OUT := 107.0 / 170.0
const DOUBLE_IN := 162.0 / 170.0
const START := 501
const FLAG_PREFIX := "darts_"          # darts_<nation> = rungs beaten (an int)
const FLAG_DAY := "darts_day_"         # once-a-day pub purse, per pub
const FLAG_LEGS := "darts_legs_won"
const DAILY_PURSE := 10                # sterling; a pint-and-a-packet-of-crisps, once a real day per pub

static var _cfg: Dictionary = {}

static func cfg() -> Dictionary:
	if _cfg.is_empty():
		var d = JsonUtil.read(PATH)
		_cfg = d if d is Dictionary else {"leagues": {}}
	return _cfg

# ---- the board

## What a dart at `p` (board units, y down, centre of the bull at 0,0) scores:
## {points, mult, label} where mult is 1, 2 (double, or the bull) or 3, 0 for a miss.
static func score_at(p: Vector2) -> Dictionary:
	var r := p.length()
	if r > 1.0:
		return {"points": 0, "mult": 0, "label": "Miss"}
	if r <= BULL:
		return {"points": 50, "mult": 2, "label": "Bull"}
	if r <= OUTER_BULL:
		return {"points": 25, "mult": 1, "label": "25"}
	var deg := fposmod(rad_to_deg(atan2(p.x, -p.y)) + 9.0, 360.0)
	var n: int = ORDER[int(deg / 18.0) % 20]
	var mult := 1
	if r >= DOUBLE_IN:
		mult = 2
	elif r >= TREBLE_IN and r <= TREBLE_OUT:
		mult = 3
	return {"points": n * mult, "mult": mult, "label": ("D" if mult == 2 else "T" if mult == 3 else "") + str(n)}

## The centre of a named segment ("T20", "D16", "20", "Bull", "25") in board units.
static func centre_of(label: String) -> Vector2:
	if label == "Bull":
		return Vector2.ZERO
	if label == "25":
		return Vector2(0.0, -(BULL + OUTER_BULL) * 0.5)
	var mult := 1
	var num := label
	if label.begins_with("T"):
		mult = 3
		num = label.substr(1)
	elif label.begins_with("D"):
		mult = 2
		num = label.substr(1)
	var i := ORDER.find(int(num))
	var r := 0.35 if mult == 1 else (TREBLE_IN + TREBLE_OUT) * 0.5 if mult == 3 else (DOUBLE_IN + 1.0) * 0.5
	var a := deg_to_rad(float(i) * 18.0)
	return Vector2(sin(a), -cos(a)) * r

# ---- aiming

## The wobbling reticle at `t` seconds around the aim point: a slow figure of eight of radius `wobble`. Readable
## (it never jumps) and fair (it always comes back round); easier play makes `wobble` and `speed` smaller.
static func reticle(aim: Vector2, t: float, wobble: float, speed: float) -> Vector2:
	return aim + Vector2(sin(t * speed), sin(t * speed * 2.0 + 0.8) * 0.5) * wobble

## The player's settings: {wobble, speed}.
static func steadiness(easy: bool) -> Dictionary:
	return {"wobble": 0.07 if easy else 0.12, "speed": 1.6 if easy else 2.4}

# ---- 501

## One dart against `remaining`: {remaining, bust, won}. Bust when it goes below zero, to one, or to zero without a
## double (or the bull); the visit is then void and the caller restores the score from before it.
static func throw_dart(remaining: int, points: int, mult: int) -> Dictionary:
	var left := remaining - points
	if left < 0 or left == 1 or (left == 0 and mult != 2):
		return {"remaining": remaining, "bust": true, "won": false}
	return {"remaining": left, "bust": false, "won": left == 0}

static var _routes: Dictionary = {}

## Three-dart-or-fewer finishes: the best route to leave from `remaining` (2 to 170) as ["T20", "T20", "D20"]; empty
## if it can't be done in three. Prefers fewer darts, then a favourite double.
static func checkout(remaining: int) -> Array:
	if remaining < 2 or remaining > 170:
		return []
	if _routes.is_empty():
		_build_routes()
	return _routes.get(remaining, [])

static func _build_routes() -> void:
	var singles: Array = []
	for n in range(1, 21):
		singles.append([str(n), n, 1])
		singles.append(["T%d" % n, n * 3, 3])
		singles.append(["D%d" % n, n * 2, 2])
	singles.append(["25", 25, 1])
	singles.append(["Bull", 50, 2])
	var doubles: Array = singles.filter(func(s): return s[2] == 2)
	var best := {}
	var rank := func(route: Array) -> int:   # lower is better: fewer darts, then liked doubles
		var d: String = route[route.size() - 1]
		var liked := ["D16", "D20", "D8", "D10", "D18", "D12", "D4", "D2", "D1", "Bull"]
		var li := liked.find(d)
		return route.size() * 100 + (li if li >= 0 else 50)
	for d in doubles:
		_offer(best, [d[0]], d[1], rank)
		for a in singles:
			_offer(best, [a[0], d[0]], a[1] + d[1], rank)
			for b in singles:
				_offer(best, [a[0], b[0], d[0]], a[1] + b[1] + d[1], rank)
	_routes = best

static func _offer(best: Dictionary, route: Array, total: int, rank: Callable) -> void:
	if total > 170:
		return
	if not best.has(total) or rank.call(route) < rank.call(best[total]):
		best[total] = route

# ---- locals

## Where a local of spread `sigma` (board units) lands when aiming at `target`.
static func local_throw(target: Vector2, sigma: float, rng: Rng) -> Vector2:
	var r := sqrt(-2.0 * log(maxf(rng.roll(), 0.0001))) * sigma
	var a := rng.roll() * TAU
	return target + Vector2(cos(a), sin(a)) * r

## What a sensible local aims at: the next dart of a finish if one is on, else treble 20, and the bull is for
## the brave.
static func target_for(remaining: int, darts_left: int) -> Vector2:
	var route := checkout(remaining)
	if not route.is_empty() and route.size() <= darts_left:
		return centre_of(route[0])
	if remaining <= 40 and remaining % 2 == 0:
		return centre_of("D%d" % (remaining / 2))
	if remaining < 62:  # set up a double rather than wander into a bust
		var want := remaining - 32 if remaining > 32 else 1
		return centre_of(str(clampi(want, 1, 20)))
	return centre_of("T20")

## A local's visit: {thrown: [{points, mult, label}], remaining, bust, won}.
static func local_visit(remaining: int, sigma: float, rng: Rng) -> Dictionary:
	var left := remaining
	var thrown: Array = []
	for i in 3:
		var s := score_at(local_throw(target_for(left, 3 - i), sigma, rng))
		thrown.append(s)
		var res := throw_dart(left, int(s.points), int(s.mult))
		if res.bust:
			return {"thrown": thrown, "remaining": remaining, "bust": true, "won": false}
		left = int(res.remaining)
		if res.won:
			return {"thrown": thrown, "remaining": 0, "bust": false, "won": true}
	return {"thrown": thrown, "remaining": left, "bust": false, "won": false}

## Plays a whole leg between a player of spread `me` and a local of `sigma` (both simulated): true if the first wins.
## For the money check and for tuning; the player's own visits use the reticle.
static func sim_leg(me: float, sigma: float, rng: Rng) -> bool:
	var a := START
	var b := START
	for turn in 60:
		var va := local_visit(a, me, rng)
		a = int(va.remaining)
		if va.won:
			return true
		var vb := local_visit(b, sigma, rng)
		b = int(vb.remaining)
		if vb.won:
			return false
	return a <= b

# ---- the league

static func nations() -> Array:
	return cfg().leagues.keys()

static func league(nation: String) -> Dictionary:
	return cfg().leagues.get(nation, {})

static func rungs_beaten(data: GameStateData, nation: String) -> int:
	return int(data.flags.get(FLAG_PREFIX + nation, 0))

## The rung the captain puts you up against next, or an empty dictionary once you are champion.
static func next_rung(data: GameStateData, nation: String) -> Dictionary:
	var rungs: Array = league(nation).get("rungs", [])
	var i := rungs_beaten(data, nation)
	return rungs[i] if i < rungs.size() else {}

static func champion(data: GameStateData, nation: String) -> bool:
	return next_rung(data, nation).is_empty() and not league(nation).is_empty()

## Records a won leg against the next rung and returns what to hand over: {first, money (sterling), line}. A rematch
## (or a win as champion) is worth the pub's daily purse, once a real day per pub.
static func win(data: GameStateData, nation: String, pub: String, rung_index: int) -> Dictionary:
	var rungs: Array = league(nation).get("rungs", [])
	data.set_flag(FLAG_LEGS, int(data.flags.get(FLAG_LEGS, 0)) + 1)
	TrainerStats.add(data, "darts_won")
	if rung_index == rungs_beaten(data, nation) and rung_index < rungs.size():
		data.set_flag(FLAG_PREFIX + nation, rung_index + 1)
		return {"first": true, "money": int(rungs[rung_index].get("prize", 0)), "line": str(rungs[rung_index].get("beaten", ""))}
	if DailyKey.done_today(data, FLAG_DAY + pub):
		return {"first": false, "money": 0, "line": ""}
	data.set_flag(FLAG_DAY + pub, DailyKey.stamp(data))
	return {"first": false, "money": DAILY_PURSE, "line": ""}

## The most a league can ever pay out, once: used by the money check.
static func league_total(nation: String) -> int:
	var t := 0
	for r in league(nation).get("rungs", []):
		t += int(r.get("prize", 0))
	return t
