class_name SaveSystem
extends RefCounted
## Versioned JSON saves. Writes go to a temp file then get renamed into place; the previous save is kept as .bak.

const VERSION := 1
const DEFAULT_DIR := "user://saves"

static func slot_path(slot: String, dir := DEFAULT_DIR) -> String:
	return dir.path_join(slot + ".json")

static func save(slot: String, data: Dictionary, dir := DEFAULT_DIR) -> Error:
	DirAccess.make_dir_recursive_absolute(dir)
	var path := slot_path(slot, dir)
	var payload := data.duplicate(true)
	payload["version"] = VERSION
	var tmp := path + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(path + ".bak"):
			DirAccess.remove_absolute(path + ".bak")
		DirAccess.rename_absolute(path, path + ".bak")
	return DirAccess.rename_absolute(tmp, path)

static func load_slot(slot: String, dir := DEFAULT_DIR) -> Dictionary:
	var path := slot_path(slot, dir)
	var data = _read(path)
	if data == null:
		data = _read(path + ".bak")
		if data == null:
			return {}
		data["_recovered"] = true
	var v := int(data.get("version", 0))
	if v > VERSION:
		return {"_too_new": true, "version": v}
	return migrate(data)

static func migrate(data: Dictionary) -> Dictionary:
	var v := int(data.get("version", 0))
	while v < VERSION:
		match v:
			0:
				data = _v0_to_v1(data)
		v += 1
		data["version"] = v
	return data

static func list_slots(dir := DEFAULT_DIR) -> Array:
	var out := []
	var d := DirAccess.open(dir)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".json"):
			out.append(f.get_basename())
	out.sort()
	return out

## Pre-release saves had no version field and nothing else changed.
static func _v0_to_v1(data: Dictionary) -> Dictionary:
	return data

static func _read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else null
