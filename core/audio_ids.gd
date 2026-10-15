class_name AudioIds
extends RefCounted
## Sound ids used in code, mapped onto the generated files in audio/. Aliases let code say what it means
## ("throw") while the generator keeps its own names ("snare_throw").

const SFX_ALIASES := {
	"throw": "snare_throw", "wobble": "snare_wobble", "broke_free": "cancel", "send_out": "confirm",
	"attack": "hit", "deny": "cancel", "xp": "cursor", "alert": "confirm", "item": "heal", "catch": "caught", "run": "cancel",
}

## Milestone 2 (north and Wales) additions. Ids are used directly, no alias needed.
const M2_SFX := ["cut", "splash", "scramble", "bike_bell", "train", "ship_horn"]
const M2_MUSIC_LOOPING := ["town_city", "town_wales", "route_coast", "route_mountain", "battle_enclosure", "legend"]
const M2_MUSIC_STINGS := ["ferry"]

## Milestone 3 (south and Ireland) additions.
const M3_SFX := ["crow", "tomb_light", "harp_gliss"]
const M3_MUSIC_LOOPING := ["town_ireland", "route_ireland", "town_cornwall", "route_moor_south", "battle_double", "legend_green", "legend_crow"]
const M3_MUSIC_STINGS := ["ferry_irish_sea"]

## Plan 5 (Northern Ireland and Scotland) additions.
const P5_SFX := ["lantern_on", "bog_squelch", "bagpipe_drone"]
const P5_MUSIC_LOOPING := ["town_scotland", "route_highlands", "town_belfast", "route_north_coast", "legend_sea", "legend_hound"]
const P5_MUSIC_STINGS := ["ferry_north_channel"]

## Plan 6 (England east and the finale) additions.
const P6_SFX := ["bell_toll", "raven_caw", "train_rush"]
const P6_MUSIC_LOOPING := ["town_york", "route_moors", "town_north", "town_london", "route_lakes", "dungeon_underground", "battle_moot", "battle_champion", "battle_final", "legend_hound2"]
const P6_MUSIC_STINGS := ["ending", "credits"]

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

## The battle track for a battle's opts: an explicit "music" wins, Keepers get their own reel, doubles a faster one.
static func battle_music(opts: Dictionary) -> String:
	if opts.has("music"):
		return str(opts.music)
	if str(opts.get("trainer", {}).get("class", "")) in ["Warden", "Director", "Lord"]:
		return "battle_enclosure"
	if opts.get("ai", "") == "keeper":
		return "battle_keeper"
	if bool(opts.get("double", false)):
		return "battle_double"
	return "battle_wild" if opts.get("kind", "wild") == "wild" else "battle_trainer"
