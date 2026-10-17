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
	return float(SNARES.get(snare, 1.0))

static func status_bonus(c: Creature) -> float:
	if c.status == "asleep":
		return 2.0
	return 1.5 if c.status != "" else 1.0

## bonus: anything else that helps (a Four-Leaf Clover on your lead).
static func chance(c: Creature, snare: String, time: String, bonus := 1.0) -> float:
	var m := float(c.max_hp())
	var a: float = (3.0 * m - 2.0 * c.hp) * c.species.catch_rate * snare_bonus(snare, c, time) / (3.0 * m) * status_bonus(c) * bonus
	return clampf(a / 255.0, 0.0, 1.0)

static func attempt(c: Creature, snare: String, time: String, rng: Rng, bonus := 1.0) -> bool:
	return rng.roll() < chance(c, snare, time, bonus)
