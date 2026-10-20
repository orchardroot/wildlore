class_name Roulette
extends RefCounted
## European single-zero roulette at the Palace. A bet is {kind, numbers, label}; it pays 36/n - 1 to 1 where n is
## how many numbers it covers, so every bet returns 36/37 of its stake on average: the green zero is the house's.
## The felt is laid out three rows by twelve columns, 3-6-9... along the top and 1-4-7... along the bottom.
## Pure logic.

## The pockets in wheel order, clockwise from zero.
const WHEEL := [0, 32, 15, 19, 4, 21, 2, 25, 17, 34, 6, 27, 13, 36, 11, 30, 8, 23, 10, 5, 24, 16, 33, 1, 20, 14, 31,
	9, 22, 18, 29, 7, 28, 12, 35, 3, 26]
const RED := [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36]

static func colour(n: int) -> String:
	if n == 0:
		return "green"
	return "red" if n in RED else "black"

static func spin(rng: Rng) -> int:
	return rng.roll_int(0, 36)

## The number at a felt cell: column 0..11 (left to right), row 0..2 (top to bottom).
static func layout_number(col: int, row: int) -> int:
	return col * 3 + (3 - row)

static func _bet(kind: String, numbers: Array, label: String) -> Dictionary:
	return {"kind": kind, "numbers": numbers, "label": label}

static func straight(n: int) -> Dictionary:
	return _bet("straight", [n], "%d straight up" % n) if n >= 0 and n <= 36 else {}

## Two numbers side by side on the felt (in the same street, or one street apart in the same row). Zero splits
## with 1, 2 or 3.
static func split(a: int, b: int) -> Dictionary:
	var lo := mini(a, b)
	var hi := maxi(a, b)
	var ok := false
	if lo == 0:
		ok = hi >= 1 and hi <= 3
	elif hi <= 36:
		ok = (hi - lo == 3) or (hi - lo == 1 and (lo - 1) / 3 == (hi - 1) / 3)
	return _bet("split", [lo, hi], "Split %d/%d" % [lo, hi]) if ok else {}

## A street: three numbers across, from its first (1, 4, 7 ... 34).
static func street(first: int) -> Dictionary:
	if first < 1 or first > 34 or (first - 1) % 3 != 0:
		return {}
	return _bet("street", [first, first + 1, first + 2], "Street %d-%d" % [first, first + 2])

## A corner: four numbers meeting at a point, named by the lowest (which can't sit in the top row).
static func corner(low: int) -> Dictionary:
	if low < 1 or low > 32 or low % 3 == 0:
		return {}
	return _bet("corner", [low, low + 1, low + 3, low + 4], "Corner %d-%d" % [low, low + 4])

## A six line: two streets side by side.
static func line(first: int) -> Dictionary:
	if first < 1 or first > 31 or (first - 1) % 3 != 0:
		return {}
	return _bet("line", [first, first + 1, first + 2, first + 3, first + 4, first + 5], "Line %d-%d" % [first, first + 5])

static func _where(f: Callable) -> Array:
	var out := []
	for n in range(1, 37):
		if f.call(n):
			out.append(n)
	return out

static func red() -> Dictionary:
	return _bet("red", RED.duplicate(), "Red")

static func black() -> Dictionary:
	return _bet("black", _where(func(n): return not (n in RED)), "Black")

static func odd() -> Dictionary:
	return _bet("odd", _where(func(n): return n % 2 == 1), "Odd")

static func even() -> Dictionary:
	return _bet("even", _where(func(n): return n % 2 == 0), "Even")

static func low() -> Dictionary:
	return _bet("low", _where(func(n): return n <= 18), "1 to 18")

static func high() -> Dictionary:
	return _bet("high", _where(func(n): return n >= 19), "19 to 36")

## Dozen 1, 2 or 3.
static func dozen(k: int) -> Dictionary:
	return _bet("dozen", _where(func(n): return (n - 1) / 12 == k - 1), ["1st", "2nd", "3rd"][clampi(k, 1, 3) - 1] + " 12")

## Column 1 (1, 4, 7...), 2 (2, 5, 8...) or 3 (3, 6, 9...).
static func column(k: int) -> Dictionary:
	return _bet("column", _where(func(n): return (n - 1) % 3 == k - 1), "Column %d" % k)

## What a bet pays, to one.
static func pays(bet: Dictionary) -> int:
	var n: int = bet.get("numbers", []).size()
	return 36 / n - 1 if n > 0 else 0

## Stake back plus winnings if `number` came up, else 0.
static func returns(bet: Dictionary, stake: int, number: int) -> int:
	return stake * (pays(bet) + 1) if number in bet.get("numbers", []) else 0
