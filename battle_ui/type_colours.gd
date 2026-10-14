class_name TypeColours
extends RefCounted
## One colour per creature type, shared by the battle menus and later by the party, summary and pedia screens.

const COLOURS := {
	"kin": Color("b8a99a"), "hedgerow": Color("6fa84a"), "brook": Color("4f9bd1"), "tide": Color("2f6fb0"),
	"hearth": Color("e8743b"), "gale": Color("9fc9d9"), "storm": Color("5b6bb5"), "frost": Color("a8e0ee"),
	"stone": Color("a08c6a"), "bog": Color("7a6b3a"), "iron": Color("8d98a6"), "urban": Color("c07a9a"),
	"fae": Color("e49bd6"), "spirit": Color("8a6fc4"), "brawn": Color("c2453f"), "night": Color("3e3a63"),
}
const FALLBACK := Color("8c8c8c")

static func of(type_id: String) -> Color:
	return COLOURS.get(type_id, FALLBACK)

## Dark or cream, whichever reads better on this type's colour.
static func text_on(type_id: String) -> Color:
	return Color("1b1d26") if of(type_id).get_luminance() > 0.5 else Color("f4ecd8")
