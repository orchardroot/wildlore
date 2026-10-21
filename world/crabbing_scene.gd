class_name CrabbingScene
extends RefCounted
## The overworld side of crabbing (rules in Crabbing): face harbour water with a crabbing kit and some bait, press
## Confirm, play the crab line, then count the bucket and put every crab back. Without a kit, or away from a harbour
## wall, water is just water and this stays out of the way (fishing gets the first look at it).

static func interact(ow: Node, p: Vector2i) -> bool:
	var zone_id := str(ow.zone.id)
	var tile: String = ow.zone.tile_at(p)
	if not Crabbing.is_water(tile) or not Crabbing.is_spot(zone_id) or not Crabbing.has_kit(Game.data):
		return false
	var why := Crabbing.refusal(Game.data, zone_id, tile)
	if why != "":
		await ow.say([why])
		return true
	var res = await Router.open_menu("crabbing:free:%d:%s" % [mini(Crabbing.bait(Game.data), 10), zone_id])
	await settle(ow, zone_id, res)
	return true

## Spends the bait and puts the bucket back in the sea, with a word about what was in it.
static func settle(ow: Node, zone_id: String, res: Variant) -> Array:
	var bucket: Array = []
	if res is Dictionary:
		bucket = res.get("bucket", [])
		Game.data.bag[Crabbing.BAIT] = maxi(0, Crabbing.bait(Game.data) - int(res.get("used", 0)))
		if Crabbing.bait(Game.data) <= 0:
			Game.data.bag.erase(Crabbing.BAIT)
	if bucket.is_empty():
		await ow.say(["An empty bucket. The crabs are on strike, or just clever."])
		return bucket
	var lines: Array = ["Into the bucket: %s." % ", ".join(PackedStringArray(Crabbing.tally(bucket)))]
	var big := Crabbing.biggest(bucket)
	lines.append("The biggest, a %s, is %d mm across." % [str(big.name).to_lower(), int(big.mm)])
	var fact := Crabbing.fact_for(str(big.id))
	if fact != "":
		lines.append(fact)
	var out := Crabbing.release(Game.data, zone_id, bucket)
	lines.append("Back they go, gently, into the water.")
	if str(out.line) != "":
		lines.append(str(out.line))
	await ow.say(lines)
	return bucket
