extends TestCase

const NameEntry = preload("res://ui/name_entry.gd")

func test_clean_names() -> void:
	assert_eq(NameEntry.clean("  Ffion  "), "Ffion")
	assert_eq(NameEntry.clean("Mary  Jane"), "Mary Jane")
	assert_eq(NameEntry.clean("   "), "")
	assert_eq(NameEntry.clean("Bartholomew the Great"), "Bartholome")
