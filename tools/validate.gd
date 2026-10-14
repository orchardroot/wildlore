extends SceneTree
## Headless data validation. Usage: godot --headless --path . -s res://tools/validate.gd

func _initialize() -> void:
	var dex := Dex.load_default()
	var errors := DataValidator.validate(TypeChart.load_default(), dex, MoveDB.load_default(), ItemDB.load_default())
	var zones := ZoneData.load_all()
	for zid in zones:
		var z: ZoneData = zones[zid]
		errors.append_array(z.validate(zones))
		for kind in z.encounters:
			for enc in z.encounters[kind]:
				if not dex.has(str(enc.get("species", ""))):
					errors.append("zone %s: encounter species '%s' does not exist" % [zid, enc.get("species", "")])
	for e in errors:
		printerr("DATA: " + e)
	print("validate: %d error(s)" % errors.size())
	quit(1 if errors.size() > 0 else 0)
