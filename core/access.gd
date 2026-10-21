class_name Access
extends RefCounted
## Accessibility helpers: text size steps and the readable (Atkinson Hyperlegible) font. Pure logic plus one theme hook.

const TEXT_SIZES := {"normal": 1.0, "large": 1.25, "largest": 1.5}
const FONT_PATH := "res://art/fonts/atkinson_hyperlegible/AtkinsonHyperlegible.ttf"
const BASE_SIZE := 28  # ui/theme.tres default_font_size

static func scale_of(text_size: String) -> float:
	return TEXT_SIZES.get(text_size, 1.0)

## A font size under the chosen text size, never below the original.
static func scaled(size: int, text_size: String) -> int:
	return maxi(size, roundi(size * scale_of(text_size)))

## Applies the text size and font choice to the shared UI theme.
static func apply_theme(theme: Theme, text_size: String, readable: bool) -> void:
	theme.default_font_size = scaled(BASE_SIZE, text_size)
	theme.default_font = load(FONT_PATH) if readable and ResourceLoader.exists(FONT_PATH) else null
