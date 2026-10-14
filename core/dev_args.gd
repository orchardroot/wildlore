class_name DevArgs
extends RefCounted
## Developer command-line switches, passed after `--`. Used for screenshots, quick boots and the playtest bot.

static func parse(args: PackedStringArray) -> Dictionary:
	var out := {"shot": "", "shot_delay": 2.0, "boot_zone": "", "boot_pos": Vector2i(-1, -1),
		"battle_species": "", "battle_level": 5, "seed": -1, "clock": -1, "weather": "", "fps": false, "playtest": "", "seconds": 0}
	for a in args:
		var kv := a.split("=", true, 1)
		var key: String = kv[0]
		var val: String = kv[1] if kv.size() > 1 else ""
		match key:
			"--shot":
				out.shot = val
			"--shot-delay":
				out.shot_delay = val.to_float()
			"--boot":
				var zp := val.split("@")
				out.boot_zone = zp[0]
				if zp.size() > 1:
					var xy := zp[1].split(",")
					if xy.size() == 2:
						out.boot_pos = Vector2i(int(xy[0]), int(xy[1]))
			"--battle":
				var sl := val.split(":")
				out.battle_species = sl[0]
				if sl.size() > 1:
					out.battle_level = int(sl[1])
			"--seed":
				out.seed = int(val)
			"--clock":
				out.clock = GameClock.parse(val)
			"--weather":
				out.weather = val
			"--fps":
				out.fps = true
			"--playtest":
				out.playtest = val
			"--seconds":
				out.seconds = int(val)
	return out
