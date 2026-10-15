class_name TypeColours
extends RefCounted
## One palette for the 16 types, shared by every screen that shows a type chip.
## The colour-blind palette keeps every pair of types apart under normal sight, deuteranopia and protanopia
## (tests/ui/test_accessibility.gd checks it); the glyph on each chip does the rest.

const COLOURS := {
	"kin": Color("b8a98c"), "hedgerow": Color("5fa84e"), "brook": Color("4a90d9"), "tide": Color("2f6fb3"),
	"hearth": Color("e0702f"), "gale": Color("9fc4e0"), "storm": Color("7a6fd0"), "frost": Color("86d4e0"),
	"stone": Color("9a8466"), "bog": Color("6b7a3a"), "iron": Color("8d96a3"), "urban": Color("7d7f8a"),
	"fae": Color("d983c4"), "spirit": Color("8e6fbf"), "brawn": Color("c24a3e"), "night": Color("3f3f6e"),
}
const CB_COLOURS := {
	"kin": Color("b8a88b"), "hedgerow": Color("61b24b"), "brook": Color("41b2f9"), "tide": Color("2b6caa"),
	"hearth": Color("df7031"), "gale": Color("a0c3e2"), "storm": Color("7f8cbc"), "frost": Color("89dcd4"),
	"stone": Color("958c82"), "bog": Color("6d6b4a"), "iron": Color("8e94a5"), "urban": Color("74628a"),
	"fae": Color("ff6cef"), "spirit": Color("7d50ca"), "brawn": Color("b64527"), "night": Color("3f3f6e"),
}
## HP bar colours: Okabe-Ito blue, yellow and vermillion, which stay apart for red-green colour blindness.
const HP_NORMAL := {"green": Color("5fbf6a"), "amber": Color("e8b63c"), "red": Color("d9503f")}
const HP_SAFE := {"green": Color("56b4e9"), "amber": Color("f0e442"), "red": Color("d55e00")}
const DARK_TEXT := Color("1d2230")
const LIGHT_TEXT := Color("f8f1dc")

static func is_colour_blind() -> bool:
	return Settings.colour_blind

static func palette(colour_blind: bool) -> Dictionary:
	return CB_COLOURS if colour_blind else COLOURS

static func colour_in(type_id: String, colour_blind: bool) -> Color:
	return palette(colour_blind).get(type_id, Color("777777"))

static func colour(type_id: String) -> Color:
	return colour_in(type_id, is_colour_blind())

## Dark text on pale chips, cream text on dark ones. The colour-blind palette picks whichever contrasts more.
static func text_colour_in(type_id: String, colour_blind: bool) -> Color:
	var c := colour_in(type_id, colour_blind)
	if colour_blind:
		return DARK_TEXT if contrast(c, DARK_TEXT) >= contrast(c, LIGHT_TEXT) else LIGHT_TEXT
	return DARK_TEXT if c.get_luminance() > 0.5 else LIGHT_TEXT

static func text_colour(type_id: String) -> Color:
	return text_colour_in(type_id, is_colour_blind())

## WCAG contrast ratio between two colours.
static func contrast(a: Color, b: Color) -> float:
	var la := _rel_lum(a)
	var lb := _rel_lum(b)
	return (maxf(la, lb) + 0.05) / (minf(la, lb) + 0.05)

static func _rel_lum(c: Color) -> float:
	var l := c.srgb_to_linear()
	return 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b

static func hp_colour_in(band: String, colour_blind: bool) -> Color:
	return (HP_SAFE if colour_blind else HP_NORMAL)[band]

## "green" | "amber" | "red" (as MenuLogic.hp_band gives them).
static func hp_colour(band: String) -> Color:
	return hp_colour_in(band, is_colour_blind())

## Aliases used by the battle scene.
static func of(type_id: String) -> Color:
	return colour(type_id)

static func text_on(type_id: String) -> Color:
	return text_colour(type_id)

# --- colour-blindness simulation (Machado et al. 2009, severity 1.0, in linear RGB) ---------------------------

const DEUTAN := [[0.367322, 0.860646, -0.227968], [0.280085, 0.672501, 0.047413], [-0.011820, 0.042940, 0.968881]]
const PROTAN := [[0.152286, 1.052583, -0.204868], [0.114503, 0.786281, 0.099216], [-0.003882, -0.048116, 1.051998]]

static func simulate(c: Color, matrix: Array) -> Color:
	var l := c.srgb_to_linear()
	var out := []
	for row in matrix:
		out.append(clampf(row[0] * l.r + row[1] * l.g + row[2] * l.b, 0.0, 1.0))
	return Color(out[0], out[1], out[2]).linear_to_srgb()

## CIE L*a*b* of an sRGB colour (D65).
static func lab(c: Color) -> Vector3:
	var l := c.srgb_to_linear()
	var x := (0.4124 * l.r + 0.3576 * l.g + 0.1805 * l.b) / 0.95047
	var y := 0.2126 * l.r + 0.7152 * l.g + 0.0722 * l.b
	var z := (0.0193 * l.r + 0.1192 * l.g + 0.9505 * l.b) / 1.08883
	var fx := _f(x)
	var fy := _f(y)
	var fz := _f(z)
	return Vector3(116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))

static func _f(t: float) -> float:
	return pow(t, 1.0 / 3.0) if t > 0.008856 else 7.787 * t + 16.0 / 116.0

## How far apart two colours look to someone with normal sight, deuteranopia or protanopia: the smallest
## of the three Lab distances (a pair only counts as distinguishable if it is for everyone).
static func distinguishability(a: Color, b: Color) -> float:
	var d := lab(a).distance_to(lab(b))
	d = minf(d, lab(simulate(a, DEUTAN)).distance_to(lab(simulate(b, DEUTAN))))
	return minf(d, lab(simulate(a, PROTAN)).distance_to(lab(simulate(b, PROTAN))))
