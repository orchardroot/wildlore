extends SceneTree
## Renders the looping ambience beds (tools/audio/ambience_recipes.gd) into res://audio/ambience/.
## Usage: godot --headless --path . -s res://tools/audio/ambgen.gd -- [ids...]   (no ids = everything)
## Check the levels afterwards with tools/audio/loudness.gd.

func _initialize() -> void:
	var want: Array = Array(OS.get_cmdline_user_args())
	var failed := false
	print("%-16s %8s %7s %7s" % ["id", "seconds", "rms_db", "peak_db"])
	for id in AmbienceRecipes.ids():
		if not want.is_empty() and id not in want:
			continue
		var buf := AmbienceRecipes.render(id)
		var stream := Synth.to_stream(buf, AmbienceRecipes.SR, 0, buf.size())
		if Synth.save_wav(stream, "res://audio/ambience/%s.wav" % id) != OK:
			failed = true
		print("%-16s %8.2f %7.2f %7.2f" % [id, buf.size() / float(AmbienceRecipes.SR), 20.0 * log(Synth.rms(buf)) / log(10.0), 20.0 * log(Synth.peak(buf)) / log(10.0)])
	quit(1 if failed else 0)
