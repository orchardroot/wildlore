class_name Share
extends RefCounted
## Sharing pictures: postcards and photo-mode shots are written as PNGs to the Wildlore pictures folder with a caption
## in a strip along the foot, so the file says where it was taken. Files only, nothing is sent anywhere. Pure rules
## are static and tested; the screens call `export_image`.

const STRIP_HEIGHT_FRACTION := 0.07
const MIN_STRIP := 28

## "Cardiff, 2026-10-21": a caption from a place and a date (either may be empty).
static func caption(place: String, date_key: String) -> String:
	var bits := PackedStringArray()
	if place.strip_edges() != "":
		bits.append(place.strip_edges())
	if date_key != "":
		bits.append(date_key)
	return ", ".join(bits)

## "wildlore_postcard_cardiff_2026-10-21.png": a safe file name from a kind, a place and a date.
static func file_name(kind: String, place: String, date_key: String) -> String:
	var slug := ""
	for ch in place.to_lower():
		slug += ch if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") else "_"
	while slug.contains("__"):
		slug = slug.replace("__", "_")
	slug = slug.trim_prefix("_").trim_suffix("_")
	var parts := PackedStringArray(["wildlore", kind])
	if slug != "":
		parts.append(slug)
	if date_key != "":
		parts.append(date_key)
	return "_".join(parts) + ".png"

## Writes `img` with `text` in a strip along its foot as a new PNG in the Wildlore pictures folder (or user://photos),
## and returns its path, or "" if it could not be saved. The caption is drawn by a throwaway viewport, so this waits
## a frame; headless runs (no renderer) save the picture bare.
static func export_image(host: Node, img: Image, file: String, text: String, pictures := "", dev := false) -> String:
	var out := img
	if text != "" and not img.is_empty() and DisplayServer.get_name() != "headless":
		out = await _captioned(host, img, text)
	for dir in [PhotoMode.photo_dir(pictures, dev), PhotoMode.FALLBACK_DIR]:
		DirAccess.make_dir_recursive_absolute(dir)
		var path: String = dir.path_join(file)
		if out.save_png(path) == OK:
			return path
	return ""

static func _captioned(host: Node, img: Image, text: String) -> Image:
	var vp := SubViewport.new()
	vp.size = img.get_size()
	vp.transparent_bg = false
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	host.add_child(vp)
	var pic := TextureRect.new()
	pic.texture = ImageTexture.create_from_image(img)
	pic.size = Vector2(img.get_size())
	vp.add_child(pic)
	var strip := maxf(MIN_STRIP, img.get_height() * STRIP_HEIGHT_FRACTION)
	var band := ColorRect.new()
	band.color = Color(0.05, 0.04, 0.07, 0.78)
	band.position = Vector2(0, img.get_height() - strip)
	band.size = Vector2(img.get_width(), strip)
	vp.add_child(band)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", int(strip * 0.55))
	label.add_theme_color_override("font_color", Color("f6efdf"))
	label.position = band.position + Vector2(strip * 0.4, 0)
	label.size = Vector2(band.size.x - strip * 0.8, strip)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vp.add_child(label)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var result := vp.get_texture().get_image()
	vp.queue_free()
	return result
