extends SceneTree
## Headless data validation. Usage: godot --headless --path . -s res://tools/validate.gd

func _initialize() -> void:
	var dex := Dex.load_default()
	var errors := DataValidator.validate(TypeChart.load_default(), dex, MoveDB.load_default(), ItemDB.load_default())
	var zones := ZoneData.load_all()
	errors.append_array(StoryValidator.validate(dex, MoveDB.load_default(), ItemDB.load_default(), zones))
	for zid in zones:
		var z: ZoneData = zones[zid]
		errors.append_array(z.validate(zones))
		for kind in z.encounters:
			for enc in z.encounters[kind]:
				if not dex.has(str(enc.get("species", ""))):
					errors.append("zone %s: encounter species '%s' does not exist" % [zid, enc.get("species", "")])
		if zid != "testbed":
			for n in z.npcs:
				# every NPC must have real art, or it shows up in game as a "?" placeholder
				var sid := str(n.get("sprite", ""))
				var path := ("res://art/sprites/creatures/%s_icon.png" % sid.substr(9)) if sid.begins_with("creature:") else ("res://art/sprites/chars/%s.png" % sid)
				if not FileAccess.file_exists(path):
					errors.append("zone %s: npc '%s' sprite '%s' has no art" % [zid, n.get("id", ""), sid])
	errors.append_array(Quests.validate(Quests.all(), zones, Quests.all_settable()))  # data/quests: zones, flags set somewhere
	errors.append_array(Festivals.validate(zones, dex, Quests.all()))  # data/festivals.json: towns, scripts, quests, creatures
	errors.append_array(Gazetteer.validate(Gazetteer.all()))  # heritage plaques: unique ids, titles, no em-dashes
	errors.append_array(Knacks.check(dex))  # every line has a knack, legends their own
	errors.append_array(Coverage.check(dex, zones))
	errors.append_array(Coverage.reachability(zones, JsonUtil.read("res://data/ferries.json"), Coverage.script_warp_targets()))
	for e in errors:
		printerr("DATA: " + e)
	print("validate: %d error(s)" % errors.size())
	quit(1 if errors.size() > 0 else 0)
