extends RefCounted
const Placeholders = preload("res://tools/spritegen/placeholders.gd")
static func render(recipe: Dictionary) -> Image:
	return Placeholders.char_sheet()
