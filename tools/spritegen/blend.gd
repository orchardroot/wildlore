extends RefCounted
## Blends two creature recipes into a third for a hybrid or a bred creature (docs/design/2026-10-21-breeding.md, 7).
## Deterministic, pure dictionaries in and out; Image-API only so it runs in the game (see ui/gene_art.gd).
##
## blend(sire, dam, spec, showing): the body and its markings come from the dam; the head (layers in the top of the
## body box), the limbs (layers in the bottom of it), the face layers and the eyes come from the sire, their positions
## rescaled from the sire's body box into the dam's. spec = {body, face, palette}: palette is "mix" (each colour
## pulled half way to the partner colour of the same luminance rank), "dam" or "sire" (the dam's colours win).
## `showing` is Genetics.showing: mark thickens or thins the patterns, hue warms the palette (ginger).
## The back view is derived from `layers` by the renderer, so the hand-tuned back_* keys are dropped.

const Creature = preload("res://tools/spritegen/creature.gd")

const HEAD_BAND := 0.3     # layers centred in the top 30% of the body box (or above it) are the head
const LIMB_BAND := 0.2     # and in the bottom 20% (or below, above the ground line) are limbs
const GROUND_Y := 86.0
const BACK_KEYS := ["back_layers", "back_over", "back_hide", "back_marks", "icon_box"]

static func blend(sire: Dictionary, dam: Dictionary, spec: Dictionary, showing := {}) -> Dictionary:
	var out := dam.duplicate(true)
	var di := Creature._body_index(dam.get("layers", []))
	var si := Creature._body_index(sire.get("layers", []))
	if di >= 0 and si >= 0:
		out = _graft(sire, dam, di, si)
	for k in BACK_KEYS:
		out.erase(k)
	out["id"] = "%s_x_%s" % [str(sire.get("id", "")), str(dam.get("id", ""))]
	_mix_palette(out, str(spec.get("palette", "mix")))
	return modify(out, showing)

## Mark and ginger on a single recipe (also used on its own for a purebred with unusual makings).
static func modify(recipe: Dictionary, showing: Dictionary) -> Dictionary:
	var out := recipe.duplicate(true)
	var mark := int(showing.get("mark", 1))
	if mark != 1:
		for list_key in ["layers", "face_layers"]:
			for l in out.get(list_key, []):
				if str(l.get("pattern", "none")) != "none":
					_mark_pattern(l, mark)
	var hue := float(showing.get("hue", 0.0))
	if hue != 0.0:
		var pal: Dictionary = out.get("palette", {})
		for k in pal:
			pal[k] = _shift_hue(pal[k], hue)
	return out

static func _mark_pattern(l: Dictionary, mark: int) -> void:
	var d := float(l.get("density", 9))
	var p := float(l.get("period", 6.0))
	if mark >= 2:
		l["density"] = clampi(int(round(d * 1.5)), 1, 60)
		l["period"] = maxf(2.0, p * 0.8)
	else:
		l["density"] = maxi(1, int(round(d * 0.4)))
		l["period"] = p * 1.4

static func _shift_hue(v, hue: float):
	if v is Dictionary:
		var d: Dictionary = v.duplicate()
		for k in d:
			d[k] = _shift_hue(d[k], hue)
		return d
	var c := Color.html(str(v))
	c.h = fposmod(c.h + hue, 1.0)
	return "#" + c.to_html(false)

# --- grafting ------------------------------------------------------------------------------

static func _graft(sire: Dictionary, dam: Dictionary, di: int, si: int) -> Dictionary:
	var dl: Array = dam.get("layers", [])
	var sl: Array = sire.get("layers", [])
	var db := Creature._layer_box(dl[di])
	var sb := Creature._layer_box(sl[si])
	var sx := db.size.x / maxf(1.0, sb.size.x)
	var sy := db.size.y / maxf(1.0, sb.size.y)
	var s_avg := (sx + sy) * 0.5
	var map_pt := func(x: float, y: float) -> Vector2:
		return Vector2(db.get_center().x + (x - sb.get_center().x) * sx, db.get_center().y + (y - sb.get_center().y) * sy)
	var dam_keep: Array = []
	for i in dl.size():
		if _role(dl[i], db) == "body":
			dam_keep.append(dl[i])
	var s_head: Array = []
	var s_limbs: Array = []
	for i in sl.size():
		if i == si:
			continue
		match _role(sl[i], sb):
			"head":
				s_head.append(_prefixed(_mapped(sl[i], map_pt, sx, sy, s_avg)))
			"limb":
				s_limbs.append(_prefixed(_mapped(sl[i], map_pt, sx, sy, s_avg)))
	var out := dam.duplicate(true)
	var layers: Array = []
	layers.append_array(s_limbs)
	layers.append_array(dam_keep.duplicate(true))
	layers.append_array(s_head)
	out["layers"] = layers
	var faces: Array = []
	for f in sire.get("face_layers", []):
		faces.append(_prefixed(_mapped(f, map_pt, sx, sy, s_avg)))
	out["face_layers"] = faces
	var eyes: Array = []
	for e in sire.get("eyes", []):
		var m := _mapped(e, map_pt, sx, sy, s_avg)
		if m.has("colour"):
			m["colour"] = "s_" + str(m["colour"]) if sire.get("palette", {}).has(str(m["colour"])) else m["colour"]
		eyes.append(m)
	out["eyes"] = eyes
	# the sire's palette rides along under an s_ prefix so the two never collide
	var pal: Dictionary = out.get("palette", {}).duplicate(true)
	for k in sire.get("palette", {}):
		pal["s_" + str(k)] = sire["palette"][k]
	out["palette"] = pal
	out["_sire_palette"] = (sire.get("palette", {}) as Dictionary).keys()
	return out

## "head", "limb" or "body" relative to a body box.
static func _role(l: Dictionary, body: Rect2) -> String:
	if str(l.get("shape", "ellipse")) == "line" or l.get("front_only", false):
		return "body"
	var c := Creature._layer_box(l).get_center()
	if c.y >= GROUND_Y:
		return "body"   # the ground shadow stays with the dam
	if c.y > body.end.y - body.size.y * LIMB_BAND:
		return "limb"
	if c.y < body.position.y + body.size.y * HEAD_BAND:
		return "head"
	return "body"

static func _mapped(l: Dictionary, map_pt: Callable, sx: float, sy: float, s_avg: float) -> Dictionary:
	var m := l.duplicate(true)
	if m.has("at"):
		var p: Vector2 = map_pt.call(float(m["at"][0]), float(m["at"][1]))
		m["at"] = [p.x, p.y]
	if m.has("points"):
		var np: Array = []
		for pt in m["points"]:
			var p: Vector2 = map_pt.call(float(pt[0]), float(pt[1]))
			np.append([p.x, p.y])
		m["points"] = np
	if m.has("size"):
		m["size"] = [float(m["size"][0]) * sx, float(m["size"][1]) * sy]
	if m.has("r"):
		m["r"] = float(m["r"]) * s_avg
	if m.has("width"):
		m["width"] = maxf(1.0, float(m["width"]) * s_avg)
	if m.has("len"):
		m["len"] = float(m["len"]) * s_avg
	if m.has("round"):
		m["round"] = float(m["round"]) * s_avg
	return m

## Sire layers reference the sire's palette names, so point them at the s_ copies.
static func _prefixed(l: Dictionary) -> Dictionary:
	l["_sire"] = true
	return l

# --- palette -------------------------------------------------------------------------------

## Pulls the colours of the two parents together by luminance rank. Layers marked `_sire` are rewritten to the s_
## names first (here, once the palettes are known), then the markers are stripped.
static func _mix_palette(r: Dictionary, mode: String) -> void:
	var pal: Dictionary = r.get("palette", {})
	var sire_keys: Array = r.get("_sire_palette", [])
	r.erase("_sire_palette")
	for list_key in ["layers", "face_layers"]:
		for l in r.get(list_key, []):
			if l.get("_sire", false):
				for ck in ["colour", "pcolour"]:
					if l.has(ck) and sire_keys.has(str(l[ck])):
						l[ck] = "s_" + str(l[ck])
				l.erase("_sire")
	if sire_keys.is_empty():
		return
	var dam_names: Array = []
	var sire_names: Array = []
	for k in pal:
		if str(k).begins_with("s_") and sire_keys.has(str(k).substr(2)):
			sire_names.append(k)
		else:
			dam_names.append(k)
	var by_lum := func(a, b) -> bool: return _lum(pal[a]) < _lum(pal[b])
	dam_names.sort_custom(by_lum)
	sire_names.sort_custom(by_lum)
	if dam_names.is_empty() or sire_names.is_empty():
		return
	var to_sire := 0.5
	var to_dam := 0.5
	match mode:
		"dam":
			to_sire = 0.0
			to_dam = 1.0
		"sire":
			to_sire = 1.0
			to_dam = 0.0
	var mixed := pal.duplicate(true)
	for i in dam_names.size():
		var j := int(round(float(i) / maxf(1.0, dam_names.size() - 1.0) * (sire_names.size() - 1)))
		mixed[dam_names[i]] = _lerp_col(pal[dam_names[i]], pal[sire_names[j]], to_sire)
	for j in sire_names.size():
		var i := int(round(float(j) / maxf(1.0, sire_names.size() - 1.0) * (dam_names.size() - 1)))
		mixed[sire_names[j]] = _lerp_col(pal[sire_names[j]], pal[dam_names[i]], to_dam)
	r["palette"] = mixed

static func _base(v) -> Color:
	return Color.html(str(v.get("base", "#888888")) if v is Dictionary else str(v))

static func _lum(v) -> float:
	var c := _base(v)
	return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b

static func _lerp_col(a, b, t: float):
	if t <= 0.0:
		return a
	return "#" + _base(a).lerp(_base(b), t).to_html(false)
