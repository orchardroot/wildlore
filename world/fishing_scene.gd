class_name FishingScene
extends RefCounted
## The overworld side of fishing (rules in Fishing): face water with a rod, press Confirm, wait for the float, play
## the bite bar. A catch is a fish (into the bag, counted, valued by the Ledger) or, now and then, a creature that is
## only ever found on a line. Without a rod, water is just scenery and this stays out of the way.

static func interact(ow: Node, p: Vector2i) -> bool:
	var tile: String = ow.zone.tile_at(p)
	if not Fishing.is_water(tile) or Fishing.rod_tier(Game.data) == 0:
		return false
	var data: GameStateData = Game.data
	var why := Fishing.refusal(data, tile, str(ow.zone.region))
	if why != "":
		await ow.say([why])
		return true
	Fishing.spend_cast(data)
	var tier := Fishing.rod_tier(data)
	Audio.sfx("splash")
	var was := Router.busy
	Router.busy = true
	await ow.get_tree().create_timer(Fishing.wait_seconds(Game.rng)).timeout
	Audio.sfx("splash")
	Router.busy = was
	await ow.say(["The float dips. Something's interested."])
	var landed: bool = await FishingBar.play(ow, tier, Settings.easy_fishing, Game.rng)
	if not landed:
		await ow.say(["It got away. It'll be telling the others."])
		return true
	var list := Fishing.pool(str(ow.zone.region), tile, Calendar.season_today(), data.badges.size(), tier)
	if list.is_empty():
		await ow.say(["Nothing but weed. Honest weed, at least."])
		return true
	var e := Fishing.pick(list, Game.rng.roll())
	if e.has("species"):
		await _creature(ow, e)
	else:
		Fishing.land(data, str(e.id))
		var it: Dictionary = Game.items.get_item(str(e.id))
		var cur := Wallet.currency_for_zone(str(ow.zone.id))
		var worth := Wallet.fmt(Wallet.localise(Trade.sell_price(data, str(e.id), str(ow.zone.id)), cur), cur)
		await ow.say(["You land a %s!" % str(it.get("name", e.id)), "Worth about %s at a fair market." % worth])
	return true

static func _creature(ow: Node, e: Dictionary) -> void:
	if Game.data.first_able() == null or not Game.dex.has(str(e.species)):
		await ow.say(["Something heavy tugs, thinks better of it, and lets go."])
		return
	var lv := Game.rng.roll_int(int(e.min), maxi(int(e.min), int(e.max)))
	var foe := Creature.create(Game.dex.get_species(str(e.species)), lv, Game.rng, Game.moves)
	Game.data.mark_seen(str(e.species))
	await ow.say(["That's no fish. It's looking back at you."])
	var result: Dictionary = await Router.battle([foe], {"kind": "wild", "weather": ow.weather, "time": Game.phase(), "stage": ow._stage()})
	await ow._after_battle(result)
