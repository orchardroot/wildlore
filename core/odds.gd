class_name Odds
extends RefCounted
## British fractional odds, as chalked on a bookies' board: [numerator, denominator], shown "5/2", "100/30",
## "Evens", "4/6". Prices only ever come from LADDER, and a fair price is always rounded DOWN onto it, which is
## where the bookmaker's pennies come from. Pure logic.

## The traditional ladder, shortest first.
const LADDER := [
	[1, 10], [1, 8], [1, 7], [1, 6], [1, 5], [2, 9], [1, 4], [2, 7], [1, 3], [4, 11], [2, 5], [4, 9], [1, 2],
	[8, 15], [4, 7], [8, 13], [4, 6], [8, 11], [4, 5], [5, 6], [10, 11], [20, 21], [1, 1], [21, 20], [11, 10],
	[6, 5], [5, 4], [11, 8], [6, 4], [13, 8], [7, 4], [15, 8], [2, 1], [9, 4], [5, 2], [11, 4], [3, 1], [100, 30],
	[7, 2], [4, 1], [9, 2], [5, 1], [11, 2], [6, 1], [13, 2], [7, 1], [15, 2], [8, 1], [9, 1], [10, 1], [11, 1],
	[12, 1], [14, 1], [16, 1], [18, 1], [20, 1], [25, 1], [33, 1], [40, 1], [50, 1], [66, 1], [100, 1],
]

static func value(f: Array) -> float:
	return float(f[0]) / float(f[1])

static func text(f: Array) -> String:
	if int(f[0]) == int(f[1]):
		return "Evens"
	return "%d/%d" % [int(f[0]), int(f[1])]

## The longest ladder price that is no more than `v` (winnings per pound). Clamped to the ladder's ends.
static func at_most(v: float) -> Array:
	var best: Array = LADDER[0]
	for f in LADDER:
		if value(f) <= v + 0.000001:
			best = f
		else:
			break
	return best

## One step shorter on the ladder (or the shortest price).
static func shorter(f: Array) -> Array:
	var i := LADDER.find(f)
	return LADDER[maxi(0, i - 1)] if i >= 0 else at_most(value(f) - 0.0001)

## Stake back plus winnings, whole pounds, rounded down.
static func returns(stake: int, f: Array) -> int:
	return stake + int(floor(float(stake) * int(f[0]) / int(f[1]) + 0.000001))

## The chance a price implies (no margin taken off).
static func implied(f: Array) -> float:
	return 1.0 / (1.0 + value(f))
