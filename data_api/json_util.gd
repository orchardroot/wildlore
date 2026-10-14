class_name JsonUtil
extends RefCounted
## Reads JSON files from res:// (or user://). Numbers come back as floats: callers cast.

static func read(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("JsonUtil: missing %s" % path)
		return null
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		push_error("JsonUtil: invalid JSON in %s" % path)
	return parsed

static func list_json(dir_path: String) -> Array:
	var out := []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.ends_with(".json"):
			out.append(dir_path.path_join(f))
	out.sort()
	return out
