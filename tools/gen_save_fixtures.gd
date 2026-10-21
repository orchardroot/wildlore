extends SceneTree
## Entry point for tools/gen_save_fixtures_body.gd (loaded at run time so the autoloads it leans on exist).
## godot --headless --path . -s res://tools/gen_save_fixtures.gd -- /tmp/full_save.json

func _initialize() -> void:
	load("res://tools/gen_save_fixtures_body.gd").new().run(OS.get_cmdline_user_args()[0])
	quit()
