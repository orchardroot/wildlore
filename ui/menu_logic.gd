class_name MenuLogic
extends RefCounted
## Pure helpers behind the menus, so they can be tested without a scene tree.

const MAX_STACK := 99

static func wrap_index(i: int, delta: int, n: int) -> int:
	if n <= 0:
		return 0
	return posmod(i + delta, n)

static func can_afford(money: int, price: int, qty: int) -> bool:
	return qty > 0 and money >= price * qty

## How many more of an item can be bought: limited by money and by the stack cap.
static func max_buy(money: int, price: int, owned := 0) -> int:
	var room := maxi(0, MAX_STACK - owned)
	if price <= 0:
		return room
	return mini(room, money / price)

static func sell_price(price: int) -> int:
	return maxi(0, price) / 2

## A copy of `arr` with the entries at a and b swapped. Out-of-range indices change nothing.
static func reorder(arr: Array, a: int, b: int) -> Array:
	var out := arr.duplicate()
	if a < 0 or b < 0 or a >= out.size() or b >= out.size():
		return out
	var t = out[a]
	out[a] = out[b]
	out[b] = t
	return out

## species id -> [zone names], in the order the zones were given.
static func habitat_index(zones: Array) -> Dictionary:
	var idx := {}
	for z in zones:
		var seen := {}
		for table in z.get("encounters", {}).values():
			for e in table:
				var sp := str(e.get("species", ""))
				if sp != "" and not seen.has(sp):
					seen[sp] = true
					if not idx.has(sp):
						idx[sp] = []
					idx[sp].append(str(z.get("name", z.get("id", "?"))))
	return idx

static func habitats(index: Dictionary, species_id: String) -> Array:
	return index.get(species_id, []).duplicate()

static func hp_band(hp: int, max_hp: int) -> String:
	if max_hp <= 0 or hp <= 0:
		return "red"
	var f := float(hp) / float(max_hp)
	if f > 0.25 + 0.0001:
		return "green"
	if f > 0.125:
		return "amber"
	return "red"

## "H:MM" from seconds.
static func play_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	return "%d:%02d" % [mins / 60, mins % 60]
