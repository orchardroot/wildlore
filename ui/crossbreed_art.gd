class_name CrossbreedArt
extends RefCounted
## A crossbreed's art (core/crossbreeds.gd): never drawn by hand and never saved as a file, but blended at runtime
## from its parents' final-stage recipes through the sprite generator's public entry points (tools/spritegen/blend.gd
## and creature.gd, as GeneArt does for hybrids): the dam's body and markings, the sire's head, limbs, face and eyes,
## the two palettes mixed. Rendered once per crossbreed and cached; there are only a handful of them.

const SpriteCreature = preload("res://tools/spritegen/creature.gd")
const Blend = preload("res://tools/spritegen/blend.gd")
const KINDS := ["front", "back", "icon"]

static var _cache := {}   # crossbreed id -> {front, back, icon}

## The blended recipe for a crossbreed species, or {} if a parent has no recipe.
static func recipe(sp: Dictionary) -> Dictionary:
	var x: Dictionary = sp.get("crossbreed", {})
	var face := GeneArt.recipe(str(x.get("sire_sprite", "")))
	var body := GeneArt.recipe(str(x.get("dam_sprite", "")))
	if face.is_empty() or body.is_empty():
		return {}
	return Blend.blend(face, body, {"palette": "mix"})

## {front, back, icon} textures, or {} when there is nothing to blend (callers fall back to their placeholder).
static func sheets(sp: Dictionary) -> Dictionary:
	var id := str(sp.get("id", ""))
	if _cache.has(id):
		return _cache[id]
	var out := {}
	var r := recipe(sp)
	if not r.is_empty():
		var imgs: Dictionary = SpriteCreature.render(r)
		for k in KINDS:
			if imgs.get(k) is Image:
				out[k] = ImageTexture.create_from_image(imgs[k])
	_cache[id] = out
	return out

## kind "front", "back" or "icon"; null if it cannot be drawn.
static func texture(sp: Dictionary, kind: String) -> Texture2D:
	return sheets(sp).get(kind)

static func clear_cache() -> void:
	_cache.clear()
