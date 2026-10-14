class_name AudioIds
extends RefCounted
## Sound ids used in code, mapped onto the generated files in audio/. Aliases let code say what it means
## ("throw") while the generator keeps its own names ("snare_throw").

const SFX_ALIASES := {
	"throw": "snare_throw", "wobble": "snare_wobble", "broke_free": "cancel", "send_out": "confirm",
	"attack": "hit", "deny": "cancel", "xp": "cursor", "alert": "confirm", "item": "heal", "catch": "caught", "run": "cancel",
}

static func sfx_file(id: String) -> String:
	return "res://audio/sfx/%s.wav" % SFX_ALIASES.get(id, id)

static func sfx_exists(id: String) -> bool:
	return ResourceLoader.exists(sfx_file(id)) or FileAccess.file_exists(sfx_file(id))

static func music_exists(id: String) -> bool:
	for ext in [".ogg", ".wav"]:
		var p := "res://audio/music/%s%s" % [id, ext]
		if ResourceLoader.exists(p) or FileAccess.file_exists(p):
			return true
	return false

## The battle track for a battle's opts: an explicit "music" wins, Keepers get their own reel.
static func battle_music(opts: Dictionary) -> String:
	if opts.has("music"):
		return str(opts.music)
	if opts.get("ai", "") == "keeper":
		return "battle_keeper"
	return "battle_wild" if opts.get("kind", "wild") == "wild" else "battle_trainer"
