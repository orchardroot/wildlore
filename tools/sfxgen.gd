extends SceneTree
## Generates every sound effect and music track into res://audio/.
## Usage: godot --headless --path . -s res://tools/sfxgen.gd -- [ids...]   (no ids = everything)

const MUSIC_SR := 22050
const MUSIC_IDS := ["title", "town_cheshire", "route_forest", "route_moor", "battle_wild", "battle_trainer", "battle_keeper", "sanctuary", "victory",
	"town_city", "town_wales", "route_coast", "route_mountain", "battle_enclosure", "legend", "ferry",
	"town_ireland", "route_ireland", "town_cornwall", "route_moor_south", "battle_double", "legend_green", "legend_crow", "ferry_irish_sea"]

func _initialize() -> void:
	var want: Array = Array(OS.get_cmdline_user_args())
	var rows: Array = []
	var failed := false
	for id in SfxRecipes.ids():
		if want.is_empty() or id in want:
			var buf := SfxRecipes.render(id)
			var path := "res://audio/sfx/%s.wav" % id
			if Synth.save_wav(Synth.to_stream(buf, SfxRecipes.SR), path) != OK:
				failed = true
			rows.append([id, buf.size() / float(SfxRecipes.SR), Synth.peak(buf), Synth.rms(buf)])
	for id in MUSIC_IDS:
		if want.is_empty() or id in want:
			var script: GDScript = load("res://tools/music/%s.gd" % id)
			var c: Composer = script.build()
			var buf := c.render(MUSIC_SR)
			if not c.errors.is_empty():
				printerr("music %s: %s" % [id, "; ".join(PackedStringArray(c.errors))])
				failed = true
			var stream: AudioStreamWAV
			if c.loop:
				stream = Synth.to_stream(buf, MUSIC_SR, 0, buf.size())
			else:
				stream = Synth.to_stream(buf, MUSIC_SR)
			if Synth.save_wav(stream, "res://audio/music/%s.wav" % id) != OK:
				failed = true
			rows.append([id, buf.size() / float(MUSIC_SR), Synth.peak(buf), Synth.rms(buf)])
	print("%-16s %8s %6s %6s" % ["id", "seconds", "peak", "rms"])
	for r in rows:
		print("%-16s %8.2f %6.3f %6.3f" % r)
	quit(1 if failed else 0)
