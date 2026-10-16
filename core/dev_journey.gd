class_name DevJourney
extends RefCounted
## Dev switch `--journey=<train|ferry|fly>:<town>`. On its own it shows that travel scene held part way
## through (`--journey-at=0..1`, default 0.5) for screenshots. With `--boot=<zone>` it makes the whole
## journey from there for real (platform, scene, warp, arrival), as the rail, ferry or Raven would.

static func parse(arg: String) -> Array:
	var p := arg.split(":")
	return [p[0], p[1] if p.size() > 1 else "york"]

## The ferry route that lands at `to`, and where it sails from: [route, from], or ["", ""] if none does.
static func ferry_to(to: String) -> Array:
	var all := Travel.ferries()
	for r in all:
		if str(all[r].a) == to:
			return [r, str(all[r].b)]
		if str(all[r].b) == to:
			return [r, str(all[r].a)]
	return ["", ""]

static func info_for(kind: String, to: String, from: String) -> Dictionary:
	var info := {"from": from, "to": to}
	if kind == "ferry":
		var f := ferry_to(to)
		info["route"] = f[0]
		info["from"] = f[1]
		info["card"] = str(Travel.ferries().get(f[0], {}).get("card", ""))
	return info

## A scene alone, held still over the title (which is hidden).
static func show_scene(game: Node, arg: String) -> void:
	game.new_game()
	var d: GameStateData = game.data
	for t in Travel.world_map().get("towns", {}):
		d.set_flag("visited_" + t)  # so the map under the Raven has its names
	var kt := parse(arg)
	var js := JourneyScene.new()
	js.setup(kt[0], info_for(kt[0], kt[1], "macclesfield"), "on")
	js.phase = game.phase()
	js.weather = str(game.args.weather) if str(game.args.weather) != "" else "clear"
	js.hold_at = clampf(float(game.args.get("journey_at", 0.5)), 0.0, 1.0)
	await game.get_tree().process_frame
	var cur: Node = game.get_tree().current_scene
	if cur:
		cur.visible = false
	game.get_node("/root/Router").add_child(js)
	js.play_now()

## The whole journey from the zone just booted into, landing where the real thing would.
static func run(game: Node, arg: String) -> void:
	var router := game.get_node("/root/Router")
	var ow: Node = router.overworld
	if ow == null:
		return
	var kt := parse(arg)
	var kind: String = kt[0]
	var to: String = kt[1]
	var here: String = ow.zone.town_id if ow.zone.town_id != "" else ow.zone.id
	var info := info_for(kind, to, here)
	var a: Dictionary
	match kind:
		"train":
			a = Travel.rail_arrival(to)
		"ferry":
			a = Travel.ferry_arrival(str(info.get("route", "")), here)
		_:
			a = Travel.fly_arrival(to)
	if a.is_empty():
		push_warning("DevJourney: no %s to %s from %s" % [kind, to, here])
		return
	router.busy = true
	var played: bool = await Journey.depart(ow, kind, info)
	await router.goto_zone(str(a.zone), a.pos, "down")
	if played:
		await Journey.arrive(ow, kind, info)
	router.busy = false
	print("journey: %s to %s landed at %s %s (scene %s)" % [kind, to, game.data.zone_id, str(game.data.pos), str(played)])
