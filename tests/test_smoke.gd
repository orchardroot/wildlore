extends TestCase

func test_project_is_named_wildlore() -> void:
	assert_eq(ProjectSettings.get_setting("application/config/name"), "Wildlore")

func test_renderer_is_compatibility() -> void:
	assert_eq(ProjectSettings.get_setting("rendering/renderer/rendering_method"), "gl_compatibility")
