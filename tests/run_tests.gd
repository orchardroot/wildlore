extends SceneTree
## Headless test runner. Runs every res://tests/**/test_*.gd; each test_* method is one test.
## Usage: godot --headless --path . -s res://tests/run_tests.gd -- [filter]

var failures := 0
var passed := 0
var current := ""

func fail(msg: String) -> void:
	failures += 1
	printerr("FAIL %s: %s" % [current, msg])

func _initialize() -> void:
	var filter := ""
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		filter = args[0]
	for path in _find_tests("res://tests"):
		var script: GDScript = load(path)
		for m in script.get_script_method_list():
			var method: String = m.name
			if not method.begins_with("test_"):
				continue
			current = "%s::%s" % [path.get_file().get_basename(), method]
			if filter != "" and not current.contains(filter):
				continue
			var inst = script.new()
			inst.runner = self
			var before := failures
			inst.call(method)
			if failures == before:
				passed += 1
	print("\n%d passed, %d failed" % [passed, failures])
	quit(1 if failures > 0 else 0)

func _find_tests(dir_path: String) -> Array:
	var out := []
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if f.begins_with("test_") and f.ends_with(".gd"):
			out.append(dir_path.path_join(f))
	for d in dir.get_directories():
		out.append_array(_find_tests(dir_path.path_join(d)))
	out.sort()
	return out
