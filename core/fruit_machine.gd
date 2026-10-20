class_name FruitMachine
extends RefCounted
## "Creature Feature", the Palace's pub-style fruit machine: three reels of twenty stops, one win line, creature
## symbols for fruit. Like the machines in every British pub, a spin can come with NUDGES (each one drops a reel
## by one stop, bringing the symbol above down onto the line) and a losing spin can offer HOLDS for the next go
## (held reels stay put). Everything is decided when the stake goes in: the stops, how many nudges, whether holds
## are offered. Nudging and holding are the player's skill; the pay table is set so even perfect play returns
## a little under 93p in the pound (see exact_rtp_with_nudges and simulate). Pure logic.

const STOPS := 20
## Lowest to highest. `species` is the creature on the reel.
const SYMBOLS := [
	{"species": "pipkin", "name": "Pipkin"},
	{"species": "puffling", "name": "Puffling"},
	{"species": "kindlet", "name": "Kindlet"},
	{"species": "glowmite", "name": "Glowmite"},
	{"species": "wispet", "name": "Wispet"},
	{"species": "bran", "name": "Bran"},
]
## Three on the line pays this many times the stake.
const PAYS := [5, 8, 12, 20, 40, 100]
## Two Pipkins from the left: your stake back.
const TWO_LOW := 1
const STRIPS := [
	[0, 1, 2, 0, 3, 1, 0, 4, 1, 2, 0, 1, 5, 2, 0, 3, 1, 2, 0, 1],
	[1, 0, 2, 1, 3, 0, 2, 1, 4, 0, 1, 2, 5, 1, 3, 0, 2, 1, 0, 2],
	[2, 1, 0, 3, 1, 2, 4, 1, 0, 2, 3, 1, 2, 5, 1, 2, 0, 3, 1, 2],
]
const NUDGE_CHANCE := 0.08
const NUDGE_WEIGHTS := {1: 0.5, 2: 0.3, 3: 0.2}
const HOLD_CHANCE := 0.10
const STAKES := [1, 2, 5, 10]

static func symbol_at(reel: int, stop: int) -> int:
	return int(STRIPS[reel][posmod(stop, STOPS)])

## The three symbols on the win line.
static func line(pos: Array) -> Array:
	return [symbol_at(0, pos[0]), symbol_at(1, pos[1]), symbol_at(2, pos[2])]

## What a line pays, times the stake.
static func pays(l: Array) -> int:
	if l[0] == l[1] and l[1] == l[2]:
		return PAYS[l[0]]
	if l[0] == 0 and l[1] == 0:
		return TWO_LOW
	return 0

## One nudge on `reel`: the symbol above drops onto the line. Returns new positions.
static func nudge(pos: Array, reel: int) -> Array:
	var out := pos.duplicate()
	out[reel] = posmod(int(out[reel]) - 1, STOPS)
	return out

## A spin. `held` reels keep their stop from `from`. Returns {pos, nudges, holds} where `holds` says whether
## holds are offered on the next go (only shown if this spin ends up losing).
static func spin(rng: Rng, from: Array = [0, 0, 0], held: Array = [false, false, false]) -> Dictionary:
	var pos := []
	for r in 3:
		pos.append(int(from[r]) if held[r] else rng.roll_int(0, STOPS - 1))
	var nudges := 0
	if rng.roll() < NUDGE_CHANCE:
		var roll := rng.roll()
		for k in NUDGE_WEIGHTS:
			roll -= float(NUDGE_WEIGHTS[k])
			nudges = int(k)
			if roll < 0.0:
				break
	var holds := rng.roll() < HOLD_CHANCE
	return {"pos": pos, "nudges": nudges, "holds": holds}

## The best line reachable with up to `n` nudges: {mult, use: [nudges per reel]}.
static func best_nudge(pos: Array, n: int) -> Dictionary:
	var best := {"mult": pays(line(pos)), "use": [0, 0, 0]}
	for a in n + 1:
		for b in n + 1 - a:
			for c in n + 1 - a - b:
				var m := pays(line([pos[0] - a, pos[1] - b, pos[2] - c]))
				if m > int(best.mult):
					best = {"mult": m, "use": [a, b, c]}
	return best

## Expected multiplier of the next spin with `held` reels kept at `pos`, nudges played perfectly.
static func held_value(pos: Array, held: Array) -> float:
	var key := ""
	for r in 3:
		key += ("%d," % int(pos[r])) if held[r] else "-,"
	if not _held_cache.has(key):
		_held_cache[key] = _held_value(pos, held)
	return _held_cache[key]

static var _held_cache := {}

static func _held_value(pos: Array, held: Array) -> float:
	var free := []
	for r in 3:
		if not held[r]:
			free.append(r)
	var total := 0.0
	var count := 0
	var combos := int(pow(STOPS, free.size()))
	for k in combos:
		var p := pos.duplicate()
		var rest := k
		for r in free:
			p[r] = rest % STOPS
			rest /= STOPS
		total += _value_with_nudges(p)
		count += 1
	return total / count

static func _value_with_nudges(p: Array) -> float:
	var v := (1.0 - NUDGE_CHANCE) * pays(line(p))
	for k in NUDGE_WEIGHTS:
		v += NUDGE_CHANCE * float(NUDGE_WEIGHTS[k]) * int(best_nudge(p, int(k)).mult)
	return v

## The holds a sharp player takes on a losing line: whichever set (never all three) makes the next spin worth most.
## Returns [bool, bool, bool].
static func best_hold(pos: Array) -> Array:
	var best: Array = [false, false, false]
	var best_v := held_value(pos, best)
	for h in [[true, false, false], [false, true, false], [false, false, true], [true, true, false], [true, false, true], [false, true, true]]:
		var v := held_value(pos, h)
		if v > best_v + 0.000001:
			best_v = v
			best = h
	return best

## Exact return of the base game with nudges always used perfectly (holds aside): every stop combination.
static func exact_rtp_with_nudges() -> float:
	return held_value([0, 0, 0], [false, false, false])

## A seeded session of `spins` one-pound spins. `sharp`: nudges and holds played perfectly; otherwise ignored.
## Returns {rtp, staked, returned, hits}.
static func simulate(rng: Rng, spins: int, sharp: bool) -> Dictionary:
	var staked := 0
	var back := 0
	var hits := 0
	var pos := [0, 0, 0]
	var held := [false, false, false]
	var offer := false
	var hold_cache := {}
	for i in spins:
		var use_hold := offer and sharp
		if use_hold:
			var key := "%d,%d,%d" % pos
			if not hold_cache.has(key):
				hold_cache[key] = best_hold(pos)
			held = hold_cache[key]
		else:
			held = [false, false, false]
		var s := spin(rng, pos, held)
		pos = s.pos
		var m := pays(line(pos))
		if sharp and s.nudges > 0:
			var b := best_nudge(pos, int(s.nudges))
			if int(b.mult) > m:
				m = int(b.mult)
				for r in 3:
					pos[r] = posmod(int(pos[r]) - int(b.use[r]), STOPS)
		staked += 1
		back += m
		if m > 0:
			hits += 1
		offer = m == 0 and bool(s.holds) and not use_hold
	return {"rtp": float(back) / maxi(1, staked), "staked": staked, "returned": back, "hits": hits}
