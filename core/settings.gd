extends Node
## Autoload Settings: player preferences, stored in user://settings.json.

const PATH := "user://settings.json"
const TEXT_SPEEDS := {"slow": 30.0, "normal": 60.0, "fast": 120.0}  # characters per second

var text_speed := "normal"
var quality := "medium"     # low | medium | high
var music_volume := 0.7
var sfx_volume := 0.8

func _ready() -> void:
	InputSetup.register()
	load_settings()

func chars_per_second() -> float:
	return TEXT_SPEEDS.get(text_speed, 60.0)

func load_settings() -> void:
	if not FileAccess.file_exists(PATH):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if d is Dictionary:
		text_speed = d.get("text_speed", text_speed)
		quality = d.get("quality", quality)
		music_volume = float(d.get("music_volume", music_volume))
		sfx_volume = float(d.get("sfx_volume", sfx_volume))

func save_settings() -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"text_speed": text_speed, "quality": quality, "music_volume": music_volume, "sfx_volume": sfx_volume}))
	Bus.settings_changed.emit()
