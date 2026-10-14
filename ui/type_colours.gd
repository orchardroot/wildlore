class_name TypeColours
extends RefCounted
## One palette for the 16 types, shared by every screen that shows a type chip.

const COLOURS := {
	"kin": Color("b8a98c"), "hedgerow": Color("5fa84e"), "brook": Color("4a90d9"), "tide": Color("2f6fb3"),
	"hearth": Color("e0702f"), "gale": Color("9fc4e0"), "storm": Color("7a6fd0"), "frost": Color("86d4e0"),
	"stone": Color("9a8466"), "bog": Color("6b7a3a"), "iron": Color("8d96a3"), "urban": Color("7d7f8a"),
	"fae": Color("d983c4"), "spirit": Color("8e6fbf"), "brawn": Color("c24a3e"), "night": Color("3f3f6e"),
}

static func colour(type_id: String) -> Color:
	return COLOURS.get(type_id, Color("777777"))

## Dark text on pale chips, cream text on dark ones.
static func text_colour(type_id: String) -> Color:
	return Color("1d2230") if colour(type_id).get_luminance() > 0.5 else Color("f8f1dc")
