extends Node3D
## Dev check: renders Meshes.box with back-face culling to see which faces survive.
func _ready() -> void:
	Meshes.materials()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	Meshes.box(st, Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1), Color.RED, Color.GREEN)
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = Meshes.solid
	add_child(mi)
	var cam := Camera3D.new()
	cam.position = Vector3(1.5, 2, 3)
	add_child(cam)
	cam.look_at(Vector3(0, 0.5, 0))
	var l := DirectionalLight3D.new()
	l.rotation_degrees = Vector3(-45, 30, 0)
	add_child(l)
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OS.get_environment("SHOT"))
	get_tree().quit()
