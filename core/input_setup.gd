class_name InputSetup
extends RefCounted
## Registers the game's input actions in code (keyboard and gamepad), so project.godot stays readable.
## The bindings are data: `defaults()` gives the factory set, Settings stores the player's and calls `apply`.

const ACTIONS := ["move_up", "move_down", "move_left", "move_right", "confirm", "cancel", "menu", "run", "bike", "fly"]
const LABELS := {
	"move_up": "Move up", "move_down": "Move down", "move_left": "Move left", "move_right": "Move right",
	"confirm": "Confirm", "cancel": "Cancel", "menu": "Menu", "run": "Run", "bike": "Bike", "fly": "Fly",
}
## Confirm and cancel can never be left empty or share a button, or menus become impossible to use.
const ESSENTIAL := ["confirm", "cancel"]
const KEYS := {
	"move_up": [KEY_UP, KEY_W], "move_down": [KEY_DOWN, KEY_S],
	"move_left": [KEY_LEFT, KEY_A], "move_right": [KEY_RIGHT, KEY_D],
	"confirm": [KEY_Z, KEY_ENTER, KEY_SPACE], "cancel": [KEY_X, KEY_BACKSPACE],
	"menu": [KEY_ESCAPE, KEY_TAB], "run": [KEY_SHIFT], "bike": [KEY_B], "fly": [KEY_F],
}
const PAD_BUTTONS := {
	"move_up": [JOY_BUTTON_DPAD_UP], "move_down": [JOY_BUTTON_DPAD_DOWN],
	"move_left": [JOY_BUTTON_DPAD_LEFT], "move_right": [JOY_BUTTON_DPAD_RIGHT],
	"confirm": [JOY_BUTTON_A], "cancel": [JOY_BUTTON_B], "menu": [JOY_BUTTON_START], "run": [JOY_BUTTON_X], "bike": [JOY_BUTTON_Y], "fly": [JOY_BUTTON_BACK],
}
const PAD_AXES := {
	"move_up": [JOY_AXIS_LEFT_Y, -1.0], "move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
}
const PAD_NAMES := {
	JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y", JOY_BUTTON_BACK: "Back", JOY_BUTTON_GUIDE: "Guide",
	JOY_BUTTON_START: "Start", JOY_BUTTON_LEFT_STICK: "L-Stick", JOY_BUTTON_RIGHT_STICK: "R-Stick",
	JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB", JOY_BUTTON_DPAD_UP: "D-pad Up",
	JOY_BUTTON_DPAD_DOWN: "D-pad Down", JOY_BUTTON_DPAD_LEFT: "D-pad Left", JOY_BUTTON_DPAD_RIGHT: "D-pad Right",
	JOY_BUTTON_MISC1: "Misc", JOY_BUTTON_TOUCHPAD: "Touchpad",
}

static func defaults() -> Dictionary:
	var out := {}
	for a in ACTIONS:
		out[a] = {"key": KEYS[a].duplicate(), "pad": PAD_BUTTONS.get(a, []).duplicate()}
	return out

## Turns whatever was read from a settings file into a complete, safe binding set. Anything missing,
## malformed or unusable (confirm or cancel empty, or sharing a button) falls back to the defaults.
static func sanitise(raw) -> Dictionary:
	var out := defaults()
	if not (raw is Dictionary):
		return out
	for a in ACTIONS:
		var entry = raw.get(a)
		if not (entry is Dictionary):
			continue
		for dev in ["key", "pad"]:
			var list = entry.get(dev)
			if not (list is Array):
				continue
			var clean := []
			for v in list:
				if (v is float or v is int) and int(v) >= (1 if dev == "key" else 0) and not clean.has(int(v)):
					clean.append(int(v))
			if not clean.is_empty():
				out[a][dev] = clean
	for dev in ["key", "pad"]:
		var bad := false
		for c in out.confirm[dev]:
			if out.cancel[dev].has(c):
				bad = true
		if bad:
			for a in ESSENTIAL:
				out[a][dev] = defaults()[a][dev]
	return out

## Pure rule check: the binding set after giving `action` the new `code` as its main button on `device`.
## Returns {"bindings": Dictionary, "error": String}. The new button becomes the first one; the action's other
## buttons stay. A button used by another action is taken from it, unless that leaves it with nothing.
static func rebound(current: Dictionary, action: String, device: String, code: int) -> Dictionary:
	if not (action in ACTIONS) or not (device in ["key", "pad"]):
		return {"bindings": current, "error": "Unknown control"}
	if device == "key" and code == KEY_ESCAPE:
		return {"bindings": current, "error": "Esc is kept for backing out"}
	var b: Dictionary = current.duplicate(true)
	for other in ACTIONS:
		if other == action or not b[other][device].has(code):
			continue
		b[other][device].erase(code)
		if b[other][device].is_empty():
			return {"bindings": current, "error": "%s needs a %s button" % [LABELS[other], "key" if device == "key" else "pad"]}
	var mine: Array = b[action][device]
	mine.erase(code)
	mine.push_front(code)
	for c in b.confirm[device]:
		if b.cancel[device].has(c):
			return {"bindings": current, "error": "Confirm and Cancel can't share a button"}
	return {"bindings": b, "error": ""}

static func key_name(code: int) -> String:
	return OS.get_keycode_string(code)

static func pad_name(button: int) -> String:
	return PAD_NAMES.get(button, "Button %d" % button)

static func describe(b: Dictionary, action: String, device: String) -> String:
	var parts := []
	for c in b[action][device]:
		parts.append(key_name(c) if device == "key" else pad_name(c))
	return " / ".join(parts) if not parts.is_empty() else "-"

## Registers the actions with the given bindings (the factory set if none are given). Safe to call again.
static func apply(b: Dictionary = {}) -> void:
	InputMap.load_from_project_settings()  # drops our actions and any earlier mirroring into the ui_* ones
	register(b)

static func register(b: Dictionary = {}) -> void:
	if b.is_empty():
		b = defaults()
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.4)
		InputMap.action_erase_events(action)
		for k in b[action]["key"]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(action, e)
		for p in b[action]["pad"]:
			var j := InputEventJoypadButton.new()
			j.button_index = p
			InputMap.action_add_event(action, j)
		if PAD_AXES.has(action):
			var m := InputEventJoypadMotion.new()
			m.axis = PAD_AXES[action][0]
			m.axis_value = PAD_AXES[action][1]
			InputMap.action_add_event(action, m)
	# Godot's built-in UI actions drive Buttons and lists: make the game's keys and the pad agree with them.
	for pair in [["ui_accept", "confirm"], ["ui_cancel", "cancel"], ["ui_up", "move_up"], ["ui_down", "move_down"], ["ui_left", "move_left"], ["ui_right", "move_right"]]:
		for e in InputMap.action_get_events(pair[1]):
			if not InputMap.action_has_event(pair[0], e):
				InputMap.action_add_event(pair[0], e)
