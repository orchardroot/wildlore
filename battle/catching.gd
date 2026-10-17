class_name Catching
extends RefCounted
## Snare maths. Weaken it, send it to sleep, use the right snare.

const SNARES := {"wicker": 1.0, "iron": 1.5, "silver": 2.0}

static func snare_bonus(snare: String, c: Creature, time: String) -> float:
	match snare:
		"night":
			return 3.0 if time in ["dusk", "night"] else 1.0
		"water":
			return 3.0 if ("brook" in c.types() or "tide" in c.types()) else 1.0
		"fae":
			return 3.0 if "fae" in c.types() else 1.0
		"hazel":  # crafted: a Hedgerow creature feels at home in it
			return 3.0 if "hedgerow" in c.types() else 1.0
		"creel":  # crafted: Brook and Tide creatures put their heads in for a look
			return 2.5 if ("brook" in c.types() or "tide" in c.types()) else 1.0
	return float(SNARES.get(snare, 1.0))

static func status_bonus(c: Creature) -> float:
	if c.status == "asleep":
		return 2.0
	return 1.5 if c.status != "" else 1.0

static func chance(c: Creature, snare: String, time: String) -> float:
	var m := float(c.max_hp())
	var a: float = (3.0 * m - 2.0 * c.hp) * c.species.catch_rate * snare_bonus(snare, c, time) / (3.0 * m) * status_bonus(c)
	return clampf(a / 255.0, 0.0, 1.0)

static func attempt(c: Creature, snare: String, time: String, rng: Rng) -> bool:
	return rng.roll() < chance(c, snare, time)
