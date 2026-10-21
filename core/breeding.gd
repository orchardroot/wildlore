class_name Breeding
extends RefCounted
## STUB of session D's core/breeding.gd (docs/design/2026-10-21-breeding.md section 7), so the pairing screen and the
## pause card's basket line can be built and tested before D lands. The integrator drops this file for D's.
## Flags: breed_basket_<n> = {sire_uid, dam_uid, genome, species, steps_due, started_day}; breed_paired_<zone>_<day>.
## `steps_due` is the TrainerStats "steps" count at which the basket is ready.

const MAX_BASKETS := 3
const STEPS := 2500

static func baskets(data: GameStateData) -> Array:
	var out := []
	for n in MAX_BASKETS:
		var b = data.flag("breed_basket_%d" % n)
		if b is Dictionary:
			out.append(b)
	return out

static func steps_to_go(data: GameStateData, basket: Dictionary) -> int:
	return maxi(0, int(basket.get("steps_due", 0)) - TrainerStats.get_count(data, "steps"))

static func paired_today(data: GameStateData, zone_id: String) -> bool:
	return data.flag("breed_paired_%s_%d" % [zone_id, data.day_count]) == true

## Starts a basket for a pair that Genetics.can_pair allowed. Returns {ok, why}.
static func start(data: GameStateData, sire: Creature, dam: Creature, zone_id: String) -> Dictionary:
	if paired_today(data, zone_id):
		return {"ok": false, "why": "One pairing a day, and you've had yours."}
	var free := -1
	for n in MAX_BASKETS:
		if not (data.flag("breed_basket_%d" % n) is Dictionary):
			free = n
			break
	if free < 0:
		return {"ok": false, "why": "Three baskets on the go is plenty. Walk some off first."}
	data.set_flag("breed_basket_%d" % free, {"sire_uid": sire.uid, "dam_uid": dam.uid, "genome": {}, "species": Genetics.line_of(dam),
		"steps_due": TrainerStats.get_count(data, "steps") + STEPS, "started_day": data.day_count})
	data.set_flag("breed_paired_%s_%d" % [zone_id, data.day_count])
	return {"ok": true, "why": ""}
