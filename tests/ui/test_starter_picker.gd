extends TestCase
## The starter picker's "Press Z again" sentence follows the input device without waiting for a refresh.

const Picker = preload("res://ui/starter_picker.gd")

func test_confirm_sentence_follows_device_change() -> void:
	var was := InputDevice.pad
	InputDevice.set_pad(false)
	var old_dex = Game.dex
	Game.dex = Fixtures.dex()
	var old_bind = Settings.bindings
	Settings.bindings = InputSetup.defaults()
	var p := Picker.new()
	p._ready()  # built by hand: the tree is not running yet while tests start
	p._confirming = true
	p._refresh()
	assert_true(p._prompt.text.contains("Press Z again"), "keyboard sentence: " + p._prompt.text)
	InputDevice.set_pad(true)
	assert_true(p._prompt.text.contains("Press A again"), "pad sentence: " + p._prompt.text)
	p._confirming = false
	InputDevice.set_pad(false)
	assert_eq(p._prompt.text, "", "no sentence while not confirming")
	InputDevice.set_pad(was)
	p._exit_tree()  # drops the device signals, as leaving the tree would
	p.free()
	Game.dex = old_dex
	Settings.bindings = old_bind
