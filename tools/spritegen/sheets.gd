extends RefCounted
## Contact sheets built from the generated PNGs on disk.

const BG := Color("#d9d2c4")
const BG2 := Color("#cfc7b8")

static func _load(path: String) -> Image:
	var img := Image.load_from_file(ProjectSettings.globalize_path(path))
	if img == null:
		img = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.convert(Image.FORMAT_RGBA8)
	return img

static func _grid(cells: Array, cw: int, ch: int, cols: int, scale: int) -> Image:
	if cells.is_empty():
		return Image.create(8, 8, false, Image.FORMAT_RGBA8)
	var rows := int(ceil(cells.size() / float(cols)))
	var out := Image.create(cols * cw * scale, rows * ch * scale, false, Image.FORMAT_RGBA8)
	for r in rows:
		for c in cols:
			out.fill_rect(Rect2i(c * cw * scale, r * ch * scale, cw * scale, ch * scale), BG if (r + c) % 2 == 0 else BG2)
	for i in cells.size():
		var img: Image = cells[i]
		var sc := img.duplicate() as Image
		sc.resize(img.get_width() * scale, img.get_height() * scale, Image.INTERPOLATE_NEAREST)
		var cx := (i % cols) * cw * scale + (cw * scale - sc.get_width()) / 2
		var cy := (i / cols) * ch * scale + (ch * scale - sc.get_height())
		out.blend_rect(sc, Rect2i(0, 0, sc.get_width(), sc.get_height()), Vector2i(cx, cy))
	return out

static func creatures(ids: Array, which: String) -> Image:
	var cells: Array = []
	for id in ids:
		match which:
			"icon":
				cells.append(_load("res://art/sprites/creatures/%s_icon.png" % id))
			_:
				var sheet := _load("res://art/sprites/creatures/%s_%s.png" % [id, which])
				var fr := Image.create(96, 96, false, Image.FORMAT_RGBA8)
				fr.blit_rect(sheet, Rect2i(0, 0, 96, 96), Vector2i(0, 0))
				cells.append(fr)
	if which == "icon":
		return _grid(cells, 32, 32, 7, 3)
	return _grid(cells, 96, 96, 6 if which == "front" else 6, 2)

static func chars(ids: Array) -> Image:
	var cells: Array = []
	for id in ids:
		cells.append(_load("res://art/sprites/chars/%s.png" % id))
	return _grid(cells, 96, 192, 6, 2)

## Developer preview: front and back (first frame) of each id, scaled up.
static func preview(ids: Array, scale: int) -> Image:
	var cells: Array = []
	for id in ids:
		for which in ["front", "back"]:
			var sheet := _load("res://art/sprites/creatures/%s_%s.png" % [id, which])
			var fr := Image.create(96, 96, false, Image.FORMAT_RGBA8)
			fr.blit_rect(sheet, Rect2i(0, 0, 96, 96), Vector2i(0, 0))
			cells.append(fr)
	return _grid(cells, 96, 96, 4, scale)
