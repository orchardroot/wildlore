extends SceneTree
## Sprite generator. Usage:
##   godot --headless --path . -s res://tools/spritegen.gd -- [id ...] [--sheets] [--scale=N] [--no-write]
## No ids renders every recipe in art/recipes/. --sheets also writes the contact sheets
## docs/screens/t4-creatures.png and t4-chars.png. Output is deterministic.

const Creature = preload("res://tools/spritegen/creature.gd")
const Character = preload("res://tools/spritegen/character.gd")
const Placeholders = preload("res://tools/spritegen/placeholders.gd")
const Sheets = preload("res://tools/spritegen/sheets.gd")

const CREATURE_RECIPES := "res://art/recipes/creatures"
const CHAR_RECIPES := "res://art/recipes/chars"
const CREATURE_OUT := "res://art/sprites/creatures"
const CHAR_OUT := "res://art/sprites/chars"

func _initialize() -> void:
	var ids: Array = []
	var sheets := false
	var preview := ""
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--preview="):
			preview = a.substr(10)
		elif a == "--sheets":
			sheets = true
		elif not a.begins_with("--"):
			ids.append(a)
	var count := 0
	_save(Placeholders.creature_sheet(), CREATURE_OUT + "/_placeholder_front.png")
	_save(Placeholders.creature_sheet(), CREATURE_OUT + "/_placeholder_back.png")
	_save(Placeholders.creature_icon(), CREATURE_OUT + "/_placeholder_icon.png")
	_save(Placeholders.char_sheet(), CHAR_OUT + "/_placeholder.png")
	for id in list_recipes(CREATURE_RECIPES):
		if ids.size() > 0 and not (id in ids):
			continue
		var r := Creature.render(load_recipe(CREATURE_RECIPES, id))
		_save(r.front, "%s/%s_front.png" % [CREATURE_OUT, id])
		_save(r.back, "%s/%s_back.png" % [CREATURE_OUT, id])
		_save(r.icon, "%s/%s_icon.png" % [CREATURE_OUT, id])
		count += 1
	for id in list_recipes(CHAR_RECIPES):
		if ids.size() > 0 and not (id in ids):
			continue
		_save(Character.render(load_recipe(CHAR_RECIPES, id)), "%s/%s.png" % [CHAR_OUT, id])
		count += 1
	if preview != "":
		_save(Sheets.preview(ids, 3), preview)
	if sheets:
		_save(Sheets.creatures(list_recipes(CREATURE_RECIPES), "front"), "res://docs/screens/t4-creatures.png")
		_save(Sheets.creatures(list_recipes(CREATURE_RECIPES), "back"), "res://docs/screens/t4-creatures-back.png")
		_save(Sheets.creatures(list_recipes(CREATURE_RECIPES), "icon"), "res://docs/screens/t4-icons.png")
		_save(Sheets.chars(list_recipes(CHAR_RECIPES)), "res://docs/screens/t4-chars.png")
	print("spritegen: rendered %d recipe(s)" % count)
	quit(0)

static func list_recipes(dir_path: String) -> Array:
	var out: Array = []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out

static func load_recipe(dir_path: String, id: String) -> Dictionary:
	var f := FileAccess.open("%s/%s.json" % [dir_path, id], FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		push_error("spritegen: bad recipe " + id)
		return {}
	return data

static func _save(img: Image, path: String) -> void:
	var err := img.save_png(ProjectSettings.globalize_path(path))
	if err != OK:
		push_error("spritegen: cannot save %s (%d)" % [path, err])
