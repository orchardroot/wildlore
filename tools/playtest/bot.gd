extends Node
## Headless playtest bot. Plays the slice through the real scenes: walks with the pathfinder,
## talks to NPCs, fights with a sensible move picker, catches a couple of creatures, heals when low,
## grinds if the Keeper wins, and checks invariants every frame.
##   godot --headless --path . -- --playtest=slice [--seed=N] [--seconds=N]
##   godot --headless --path . -- --playtest=fuzz --seconds=120 [--seed=N]
## Exit code 0 on success, 1 on any failure. Prints "PLAYTEST PASS" or "PLAYTEST FAIL: <why>".

const TIME_SCALE := 10.0
const BUSY_LIMIT := 240.0   # game seconds Router may stay busy before we call it a soft-lock

var mode := "slice"
var failures: Array = []
var stats := {"battles": 0, "wins": 0, "losses": 0, "catches": 0, "steps": 0, "cheat_heals": 0, "lines": 0}
var _busy_t := 0.0
var _limit := 0.0
var _elapsed := 0.0
var _rng := RandomNumberGenerator.new()
var _done := false

func start(m: String) -> void:
	mode = m
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.set_meta("autopilot", self)
	Engine.time_scale = TIME_SCALE
	_rng.seed = maxi(0, int(Game.args.get("seed", 1)))
	_limit = float(Game.args.get("seconds", 0))
	if _limit <= 0.0:
		_limit = {"slice": 1500.0, "m2": 9000.0}.get(mode, 120.0)
	Bus.battle_ended.connect(_on_battle_ended)
	Bus.battle_started.connect(func(_k): stats.battles += 1)
	_run()

func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta / Engine.time_scale
	_busy_t = _busy_t + delta if Router.busy else 0.0
	if _busy_t > BUSY_LIMIT:
		_fail("Router stuck busy for %d game seconds in %s" % [int(_busy_t), Game.data.zone_id])
	var ow := _ow()
	if ow and ow.zone and ow.player and not ow.player.moving and not Router.busy:
		var p: Vector2i = ow.player.grid_pos
		if ow.zone.in_bounds(p) and not ow.zone.walkable(p, Vector2i.ZERO, FieldMoves.abilities(Game.data)) and ow.zone.tile_at(p) != "ledge_south":
			_fail("player stands on unwalkable %s at %s in %s" % [ow.zone.tile_at(p), p, ow.zone.id])
	if _elapsed > _limit:
		if mode == "fuzz":
			_finish()
		else:
			_fail("time limit %d s reached (in %s)" % [int(_limit), Game.data.zone_id])

# --- scenario ----------------------------------------------------------------

func _run() -> void:
	Game.new_game()
	await Router.goto_zone(Game.data.zone_id, Vector2i(-1, -1), "down")
	await _settle()
	if mode == "fuzz":
		await _fuzz()
		return
	await _talk("macc_home", "mum")
	await _talk("macc_fieldstation", "garside")
	_check(Game.data.party.size() >= 1, "no starter after Garside")
	_check(Game.data.flag("starter") != null, "starter flag missing")
	print("BOT: starter %s, money %d" % [Game.data.flag("starter"), Game.data.money])
	await _beat("buxton_spa", "maud", "badge_brook", 14)
	if mode == "m2" and not _done:
		await _m2()
	_finish()

## Talks to `npc` until `flag` is set, grinding a bit harder in `grind_zone` before each retry.
func _beat(zone_id: String, npc: String, flag: String, level := 0, grind_zone := "") -> void:
	_restock()
	var attempts := 0
	while not Game.data.flag(flag) and attempts < 4 and not _done:
		attempts += 1
		if level > 0:
			await _grind_to(level + (attempts - 1) * 2, grind_zone)
		await _heal_if_low(1.0)
		await _talk(zone_id, npc)
		var team: Array = Game.data.party.map(func(c): return "%s L%d" % [c.species.id, c.level])
		print("BOT: %s/%s attempt %d -> %s %s, team %s, W/L %d/%d" % [zone_id, npc, attempts, flag, "WON" if Game.data.flag(flag) else "not yet", team, stats.wins, stats.losses])
	_check(Game.data.flag(flag) == true, "%s/%s never set %s in %d attempts" % [zone_id, npc, flag, attempts])

## Buys Wicker Snares (at shop price, if it can afford them) so the team can grow like a real player's.
func _restock() -> void:
	var price := int(Game.items.get_item("wicker_snare").get("price", 200)) if Game.items else 200
	while int(Game.data.bag.get("wicker_snare", 0)) < 5 and Game.data.money >= price:
		Game.data.money -= price
		Game.data.bag["wicker_snare"] = int(Game.data.bag.get("wicker_snare", 0)) + 1

## M2: Manchester to the Storm Stone, following docs/superpowers/plans/2026-10-14-plan-3-story-beats.md.
func _m2() -> void:
	var starter := str(Game.data.flag("starter"))
	await _beat("manc_bikes", "bev", "bev_bike_given")
	_check(int(Game.data.bag.get("bike", 0)) > 0, "no bike from Bev")
	await _beat("liverpool", "kit", "kit3_done", 19, "chat_moss")
	await _beat("liverpool_club", "keeper_ray", "badge_urban", 22, "chat_moss")
	_check(int(Game.data.bag.get("rail_pass", 0)) > 0, "no rail pass after the Urban Stone")
	await _beat("llanberis", "pryce", "trainer_pryce_1", 27, "ogwen")
	await _beat("llanberis_quarry", "keeper_eluned", "badge_stone", 30, "ogwen")
	await _beat("yr_wyddfa", "pryce_summit", "ch3_ddraig_woke")
	await _beat("cardiff", "kit", "kit4_done", 35, "beacons")
	await _beat("cardiff", "pryce", "trainer_pryce_2", 35, "beacons")
	await _beat("cardiff_arena", "keeper_rhys", "badge_storm", 37, "beacons")
	_check(Game.data.flag("v02_complete") == true, "no end card after the Storm Stone")
	if not _done:
		print("BOT: M2 done with %s, badges %s" % [starter, Game.data.badges])

## Walks to an NPC (across zones if needed) and talks to them, then waits for the script to finish.
func _talk(zone_id: String, npc_id: String) -> void:
	for tries in 6:
		if _done:
			return
		var ow := _ow()
		if Game.data.zone_id == zone_id:
			var n := _npc(npc_id)
			if n == null:
				_fail("NPC %s not found in %s" % [npc_id, zone_id])
				return
			var spot := _talk_spot(ow, n)
			if spot.is_empty():
				_fail("no tile to talk to %s from" % npc_id)
				return
			await _walk_to(zone_id, spot.stand)
			if ow.player.grid_pos == spot.stand:
				ow.player.face(spot.face)
				await ow.interact(GridMotion.step(ow.player.grid_pos, spot.face))
				await _settle()
				return
		else:
			await _walk_to(zone_id, ZoneData.load_id(zone_id).spawn)
	_fail("could not reach %s in %s" % [npc_id, zone_id])

## Where to stand to talk to an NPC: a walkable neighbour, or across a counter.
func _talk_spot(ow: Node, n: Node) -> Dictionary:
	for dir in ["down", "up", "left", "right"]:
		var v := GridMotion.dir_vec(dir)
		var stand: Vector2i = n.grid_pos + v
		if ow.zone.walkable(stand) and not ow.occupied(stand) and ow.zone.warp_at(stand).is_empty():
			return {"stand": stand, "face": GridMotion.facing_from(-v)}
		if ow.zone.tile_at(stand) == "counter":
			var across: Vector2i = stand + v
			if ow.zone.walkable(across) and not ow.occupied(across):
				return {"stand": across, "face": GridMotion.facing_from(-v)}
	return {}

## Walks to a tile, replanning after every step (NPCs move, trainers interrupt, whiteouts teleport).
func _walk_to(zone_id: String, target: Vector2i) -> void:
	var stuck := 0
	var zones := ZoneData.load_all()
	while not _done:
		await _settle()
		var ow := _ow()
		if Game.data.zone_id == zone_id and ow.player.grid_pos == target:
			return
		await _heal_if_low(0.35)
		Pathfinder.abilities = FieldMoves.abilities(Game.data)
		if not ow.player.on_bike and ow.zone.kind != "interior" and FieldMoves.bike_refusal(Game.data, ow.zone, ow.player.wading) == "":
			ow.player.set_bike(true)
		var blocked := {}
		for n in ow.npcs:
			if is_instance_valid(n) and n.grid_pos != target:
				blocked[n.grid_pos] = true
		var legs := Pathfinder.route(zones, Game.data.zone_id, ow.player.grid_pos, zone_id, target, blocked)
		if legs.is_empty():
			stuck += 1
			if stuck > 20:
				_fail("no route from %s %s to %s %s" % [Game.data.zone_id, ow.player.grid_pos, zone_id, target])
				return
			await _wait(0.5)
			continue
		var leg: Dictionary = legs[0]
		var dir := ""
		if leg.path.is_empty():
			dir = leg.exit.dir
		else:
			dir = GridMotion.facing_from(leg.path[0] - ow.player.grid_pos)
		if dir == "":
			return
		var before: Vector2i = ow.player.grid_pos
		var ok: bool = await ow.player.try_step(dir, true)
		stats.steps += 1
		stuck = 0 if ok else stuck + 1
		if stuck > 30:
			_fail("blocked repeatedly at %s in %s heading %s" % [before, Game.data.zone_id, dir])
			return

## Walks up and down tall grass until the lead creature reaches `level`.
func _grind_to(level: int, zone := "") -> void:
	var lead := _strongest()
	if lead == null or lead.level >= level:
		return
	print("BOT: grinding %s from %d to %d" % [lead.display_name(), lead.level, level])
	var guard := 0
	while _strongest().level < level and not _done and guard < 4000:
		guard += 1
		var grind_zone := zone if zone != "" else ("macc_forest" if _strongest().level < 9 else "cat_and_fiddle")
		var spot := _grass_spot(grind_zone)
		await _walk_to(grind_zone, spot)
		var ow := _ow()
		for d in ["left", "right"]:
			await _settle()
			await ow.player.try_step(d, false)
			stats.steps += 1
		await _heal_if_low(0.4)

func _grass_spot(zone_id: String) -> Vector2i:
	var z := ZoneData.load_id(zone_id)
	FieldMoves.apply_cuts(Game.data, z)
	var reach := z.reachable(z.spawn, FieldMoves.abilities(Game.data))  # only grass you can actually walk to
	for y in z.height:
		for x in range(1, z.width - 1):
			var p := Vector2i(x, y)
			if z.tile_at(p) == "tall_grass" and reach.has(p) and reach.has(p + Vector2i(-1, 0)) and reach.has(p + Vector2i(1, 0)):
				return p
	return z.spawn

## Out of battle, top the team up when the lead is low. Counted, since a real player would walk to a Sanctuary.
func _heal_if_low(threshold: float) -> void:
	var lead := Game.data.first_able()
	if lead == null or float(lead.hp) / lead.max_hp() < threshold or Game.data.party.any(func(c): return c.is_fainted()):
		Game.data.heal_party()
		stats.cheat_heals += 1

func _strongest() -> Creature:
	var best: Creature = null
	for c in Game.data.party:
		if best == null or c.level > best.level:
			best = c
	return best

# --- fuzz --------------------------------------------------------------------

func _fuzz() -> void:
	var zones := ZoneData.load_all().keys()
	Game.data.party = [Creature.create(Game.dex.get_species("kindlet"), 12, Game.rng, Game.moves)]
	Game.data.set_flag("starter", "kindlet")
	while not _done:
		await _settle()
		var ow := _ow()
		if _rng.randf() < 0.01:
			var zid: String = zones[_rng.randi() % zones.size()]
			await Router.goto_zone(zid, Vector2i(-1, -1), "down")
			continue
		var d: String = ["up", "down", "left", "right"][_rng.randi() % 4]
		if _rng.randf() < 0.1:
			await ow.interact(GridMotion.step(ow.player.grid_pos, ow.player.facing))
		else:
			await ow.player.try_step(d, _rng.randf() < 0.5)
		stats.steps += 1
		await _heal_if_low(0.3)

# --- autopilot interface (called by dialogue box, router, battle scene) --------

func log_line(_who: String, _text: String) -> void:
	stats.lines += 1

func choose_option(_text: String, _options: Array) -> int:
	return 0

func menu_result(menu: String) -> Variant:
	if menu == "starter":
		return ["spikkin", "holtling", "kindlet"][int(Game.args.get("seed", 1)) % 3]
	return null

func choose_action(f: BattleFlow) -> Dictionary:
	var b := f.battle
	var me := b.current(Battle.PLAYER)
	var foe := b.current(Battle.FOE)
	var snares := int(Game.data.bag.get("wicker_snare", 0))
	if b.kind == "wild" and snares > 0 and Game.data.party.size() < 4 and foe.hp * 2 < foe.max_hp():
		Game.data.bag["wicker_snare"] = snares - 1
		return {"kind": "item", "item": "wicker_snare"}
	var best := -1
	var best_score := -1.0
	for i in me.moves.size():
		if int(me.moves[i].pp) <= 0:
			continue
		var s := BattleAI.score(b, me, foe, Game.moves.get_move(me.moves[i].id))
		if s > best_score:
			best_score = s
			best = i
	return {"kind": "fight", "slot": maxi(best, 0)}

func choose_replacement(f: BattleFlow) -> int:
	var party: Array = f.battle.parties[Battle.PLAYER]
	var best := 0
	for i in party.size():
		if not party[i].is_fainted() and (party[best].is_fainted() or party[i].hp > party[best].hp):
			best = i
	return best

func choose_forget(c: Creature, move_id: String) -> int:
	var new_power := int(Game.moves.get_move(move_id).get("power", 0))
	var weakest := -1
	var weakest_power := new_power
	for i in c.moves.size():
		var p := int(Game.moves.get_move(c.moves[i].id).get("power", 0))
		if p < weakest_power:
			weakest_power = p
			weakest = i
	return weakest

# --- helpers -------------------------------------------------------------------

func _on_battle_ended(result: Dictionary) -> void:
	if mode != "fuzz" and str(result.get("result", "")) == "lose":
		print("BOT: lost a battle in %s (weather %s)" % [Game.data.zone_id, Router.overworld.weather if Router.overworld else "?"])
	match str(result.get("result", "")):
		"win":
			stats.wins += 1
		"lose":
			stats.losses += 1
		"caught":
			stats.catches += 1

func _ow() -> Node:
	return Router.overworld if Router.overworld and is_instance_valid(Router.overworld) else null

func _npc(id: String) -> Node:
	var ow := _ow()
	for n in ow.npcs:
		if is_instance_valid(n) and n.def.get("id", "") == id:
			return n
	return null

## Waits until nothing is going on (fades, battles, scripts, menus) for a few frames.
func _settle() -> void:
	var calm := 0
	while calm < 3 and not _done:
		await get_tree().process_frame
		var ow := _ow()
		if not Router.busy and ow != null and ow.zone != null and not ow.player.moving:
			calm += 1
		else:
			calm = 0

func _wait(sec: float) -> void:
	await get_tree().create_timer(sec).timeout

func _check(cond: bool, why: String) -> void:
	if not cond:
		_fail(why)

func _fail(why: String) -> void:
	if _done:
		return
	failures.append(why)
	_finish()

func _finish() -> void:
	if _done:
		return
	_done = true
	Engine.time_scale = 1.0
	var lead := _strongest()
	print("BOT: stats %s, party %s, badges %s, %.0f s" % [stats, Game.data.party.map(func(c): return "%s L%d" % [c.species.id, c.level]), Game.data.badges, _elapsed])
	if failures.is_empty():
		print("PLAYTEST PASS")
		get_tree().quit(0)
	else:
		print("PLAYTEST FAIL: " + "; ".join(failures))
		get_tree().quit(1)
