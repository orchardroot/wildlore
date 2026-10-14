class_name DevArgs
extends RefCounted
## Developer command-line switches, passed after `--`. Used for screenshots, quick boots and the playtest bot.

## The user args after `--`, or none at all in a release build (players never get dev switches).
static func user_args(is_debug := OS.is_debug_build()) -> PackedStringArray:
	return OS.get_cmdline_user_args() if is_debug else PackedStringArray()

static func parse(args: PackedStringArray, is_debug := OS.is_debug_build()) -> Dictionary:
	if not is_debug:
		args = PackedStringArray()
	var out := {"shot": "", "shot_delay": 2.0, "boot_zone": "", "boot_pos": Vector2i(-1, -1),
		"battle_species": "", "battle_level": 5, "seed": -1, "clock": -1, "weather": "", "fps": false, "playtest": "", "seconds": 0, "ride": ""}
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
			"--ride":
				out.ride = val
			"--seconds":
				out.seconds = int(val)
	return out

## True when any switch that boots straight into the game is present (screenshots, boots, menus, battles,
## talks, the bot). Such runs must never touch the player's real saves.
static func is_dev_session(parsed: Dictionary, cmdline: PackedStringArray) -> bool:
	if parsed.get("shot", "") != "" or parsed.get("boot_zone", "") != "" or parsed.get("battle_species", "") != "" or parsed.get("playtest", "") != "":
		return true
	for a in cmdline:
		if a.begins_with("--menu=") or a.begins_with("--talk=") or a.begins_with("--battle"):
			return true
	return false
