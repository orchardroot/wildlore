class_name CharSprite
extends Sprite3D
## A pixel-art character billboard. Sheet: 3 columns x 4 rows of 32x48 (rows down, left, right, up;
## columns step-left, stand, step-right). Falls back to a placeholder when the art is missing.

const ROWS := {"down": 0, "left": 1, "right": 2, "up": 3}

var facing := "down"
var _walk_t := 0.0
var walking := false

func setup(sprite_id: String) -> void:
	var path := "res://art/sprites/chars/%s.png" % sprite_id
	if not ResourceLoader.exists(path):
		path = "res://art/sprites/chars/_placeholder.png"
	texture = load(path) if ResourceLoader.exists(path) else _fallback()
	hframes = 3
	vframes = 4
	pixel_size = 1.0 / 32.0
	billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	shaded = true
	double_sided = true
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	centered = true
	offset = Vector2(0, 24)
	_apply()
	var blob := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(0.7, 0.42)
	q.orientation = PlaneMesh.FACE_Y
	blob.mesh = q
	var m := StandardMaterial3D.new()
	m.albedo_texture = _blob_tex()
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(0, 0, 0, 0.45)
	blob.material_override = m
	blob.position = Vector3(0, 0.02, 0)
	blob.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(blob)

func set_facing(dir: String) -> void:
	facing = dir
	_apply()

func _process(delta: float) -> void:
	if walking:
		_walk_t += delta
	else:
		_walk_t = 0.0
	_apply()

func _apply() -> void:
	var col := 1
	if walking:
		var phase := int(_walk_t * 8.0) % 4
		col = [0, 1, 2, 1][phase]
	frame = ROWS.get(facing, 0) * 3 + col

static func _fallback() -> Texture2D:
	var img := Image.create(96, 192, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for fy in 4:
		for fx in 3:
			img.fill_rect(Rect2i(fx * 32 + 8, fy * 48 + 8, 16, 38), Color("d0408a"))
	return ImageTexture.create_from_image(img)

static func _blob_tex() -> Texture2D:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t
