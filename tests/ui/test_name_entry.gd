extends TestCase

const NameEntry = preload("res://ui/name_entry.gd")

func test_clean_names() -> void:
	assert_eq(NameEntry.clean("  Ffion  "), "Ffion")
	assert_eq(NameEntry.clean("Mary  Jane"), "Mary Jane")
	assert_eq(NameEntry.clean("   "), "")
	assert_eq(NameEntry.clean("Bartholomew the Great"), "Bartholome")

func test_typed_keys() -> void:
	assert_eq(NameEntry.typed_char(_key(KEY_Z, 122)), "z", "Z types a letter here, not confirm")
	assert_eq(NameEntry.typed_char(_key(KEY_W, 87)), "W")
	assert_eq(NameEntry.typed_char(_key(KEY_SPACE, 32)), " ")
	assert_eq(NameEntry.typed_char(_key(KEY_ENTER, 0)), "")

func _key(code: int, uni: int) -> InputEventKey:
	var k := InputEventKey.new()
	k.keycode = code
	k.unicode = uni
	k.pressed = true
	return k
