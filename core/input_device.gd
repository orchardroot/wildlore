extends Node
## Autoload InputDevice: remembers whether the player last used the keyboard or a gamepad, so on-screen prompts
## can name the right buttons. `--pad-hints` (dev builds only) pins it to the pad for screenshots.

signal changed()

var pad := false
var _pinned := false

func _ready() -> void:
	if "--pad-hints" in DevArgs.user_args():
		_pinned = true
		pad = true

## Pure: the device an input event says the player is on (true = pad), or `current` for events that say nothing.
static func device_for(event: InputEvent, current: bool) -> bool:
	if event is InputEventJoypadButton:
		return true
	if event is InputEventJoypadMotion:
		return true if absf(event.axis_value) > 0.5 else current  # stick drift never counts
	if event is InputEventKey:
		return false
	return current

func _input(event: InputEvent) -> void:
	if _pinned:
		return
	set_pad(device_for(event, pad))

func set_pad(on: bool) -> void:
	if on == pad:
		return
	pad = on
	changed.emit()
