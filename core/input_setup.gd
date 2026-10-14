class_name InputSetup
extends RefCounted
## Registers the game's input actions in code (keyboard and gamepad), so project.godot stays readable.

const KEYS := {
	"move_up": [KEY_UP, KEY_W], "move_down": [KEY_DOWN, KEY_S],
	"move_left": [KEY_LEFT, KEY_A], "move_right": [KEY_RIGHT, KEY_D],
	"confirm": [KEY_Z, KEY_ENTER, KEY_SPACE], "cancel": [KEY_X, KEY_BACKSPACE],
	"menu": [KEY_ESCAPE, KEY_TAB], "run": [KEY_SHIFT], "bike": [KEY_B],
}
const PAD_BUTTONS := {
	"move_up": [JOY_BUTTON_DPAD_UP], "move_down": [JOY_BUTTON_DPAD_DOWN],
	"move_left": [JOY_BUTTON_DPAD_LEFT], "move_right": [JOY_BUTTON_DPAD_RIGHT],
	"confirm": [JOY_BUTTON_A], "cancel": [JOY_BUTTON_B], "menu": [JOY_BUTTON_START], "run": [JOY_BUTTON_X], "bike": [JOY_BUTTON_Y],
}
const PAD_AXES := {
	"move_up": [JOY_AXIS_LEFT_Y, -1.0], "move_down": [JOY_AXIS_LEFT_Y, 1.0],
	"move_left": [JOY_AXIS_LEFT_X, -1.0], "move_right": [JOY_AXIS_LEFT_X, 1.0],
}

static func register() -> void:
	for action in KEYS:
		if not InputMap.has_action(action):
			InputMap.add_action(action, 0.4)
		for k in KEYS[action]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(action, e)
		for b in PAD_BUTTONS.get(action, []):
			var j := InputEventJoypadButton.new()
			j.button_index = b
			InputMap.action_add_event(action, j)
		if PAD_AXES.has(action):
			var m := InputEventJoypadMotion.new()
			m.axis = PAD_AXES[action][0]
			m.axis_value = PAD_AXES[action][1]
			InputMap.action_add_event(action, m)
	# Godot's built-in UI actions drive Buttons and lists: make Z/X and the pad agree with them.
	for pair in [["ui_accept", "confirm"], ["ui_cancel", "cancel"], ["ui_up", "move_up"], ["ui_down", "move_down"], ["ui_left", "move_left"], ["ui_right", "move_right"]]:
		for e in InputMap.action_get_events(pair[1]):
			if not InputMap.action_has_event(pair[0], e):
				InputMap.action_add_event(pair[0], e)
