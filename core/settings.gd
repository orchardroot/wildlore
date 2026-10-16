extends Node
## Autoload Settings: player preferences, stored in user://settings.json.

const DEFAULT_PATH := "user://settings.json"
const TEXT_SPEEDS := {"slow": 30.0, "normal": 60.0, "fast": 120.0, "instant": 100000.0}  # characters per second

var path := DEFAULT_PATH   # tests point this somewhere else so they never touch the player's file
var text_speed := "normal"
var quality := "medium"     # low | medium | high
var music_volume := 0.7
var sfx_volume := 0.8
var run_mode := "hold"     # hold | toggle: hold the run key, or press it once to latch running on and off
var colour_blind := false   # palette safe for deuteranopia and protanopia
var reduce_flashing := false  # gentle hit flashes, less shake, no strobing evolution
var bindings := {}          # action -> {"key": [physical keycodes], "pad": [joypad buttons]}, see InputSetup

func _ready() -> void:
	load_settings()

func chars_per_second() -> float:
	return TEXT_SPEEDS.get(text_speed, 60.0)

func is_instant() -> bool:
	return text_speed == "instant"

## 1.0 normally; `gentle` when "reduce flashing" is on. Used to scale shakes and flash brightness.
func flash_scale(gentle := 0.3) -> float:
	return gentle if reduce_flashing else 1.0

## Reads the settings file (missing keys keep their defaults) and applies the key bindings.
func load_settings() -> void:
	bindings = InputSetup.defaults()
	if FileAccess.file_exists(path):
		var d = JSON.parse_string(FileAccess.get_file_as_string(path))
		if d is Dictionary:
			text_speed = str(d.get("text_speed", text_speed))
			if not TEXT_SPEEDS.has(text_speed):
				text_speed = "normal"
			quality = str(d.get("quality", quality))
			music_volume = float(d.get("music_volume", music_volume))
			sfx_volume = float(d.get("sfx_volume", sfx_volume))
			run_mode = str(d.get("run_mode", run_mode))
			if run_mode not in ["hold", "toggle"]:
				run_mode = "hold"
			colour_blind = bool(d.get("colour_blind", colour_blind))
			reduce_flashing = bool(d.get("reduce_flashing", reduce_flashing))
			bindings = InputSetup.sanitise(d.get("bindings", {}))
	InputSetup.apply(bindings)

func save_settings() -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"text_speed": text_speed, "quality": quality, "music_volume": music_volume,
			"sfx_volume": sfx_volume, "run_mode": run_mode, "colour_blind": colour_blind, "reduce_flashing": reduce_flashing, "bindings": bindings}))
	Bus.settings_changed.emit()

## Rebinds one slot. `device` is "key" or "pad"; `code` a physical keycode or joypad button.
## Returns "" on success or a short reason it was refused (nothing changes then).
func rebind(action: String, device: String, code: int) -> String:
	var r := InputSetup.rebound(bindings, action, device, code)
	if r.error != "":
		return r.error
	bindings = r.bindings
	InputSetup.apply(bindings)
	save_settings()
	return ""

func reset_bindings() -> void:
	bindings = InputSetup.defaults()
	InputSetup.apply(bindings)
	save_settings()
