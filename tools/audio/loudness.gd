extends SceneTree
## Prints RMS dBFS, peak dBFS and loop-seam stats for every rendered music track, sfx and ambience loop in res://audio/.
## Ambience beds are meant to sit 12 dB or more under the music median (see AmbienceRecipes.TARGET_DB).
## Usage: godot --headless --path . -s res://tools/audio/loudness.gd
## seam_db: level step across the loop point (RMS of the 250 ms after the start minus the 250 ms before the end).
## click: |last sample - first sample| divided by the RMS sample-to-sample delta of the track (about 1 is unremarkable, above 4 is an audible click).

static func read_wav(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var b := f.get_buffer(f.get_length())
	f.close()
	var sr := 22050
	var pos := 12
	var data := PackedFloat32Array()
	var looping := false
	while pos + 8 <= b.size():
		var tag := b.slice(pos, pos + 4).get_string_from_ascii()
		var n := b.decode_u32(pos + 4)
		if tag == "fmt ":
			sr = b.decode_u32(pos + 12)
		elif tag == "data":
			var cnt := n / 2
			data.resize(cnt)
			for i in cnt:
				data[i] = b.decode_s16(pos + 8 + i * 2) / 32768.0
		elif tag == "smpl":
			looping = true
		pos += 8 + n + (n & 1)
	return {"data": data, "sr": sr, "loop": looping}

static func db(x: float) -> float:
	return 20.0 * log(maxf(x, 1e-9)) / log(10.0)

static func rms_of(a: PackedFloat32Array, from := 0, to := -1) -> float:
	if to < 0:
		to = a.size()
	var s := 0.0
	for i in range(from, to):
		s += a[i] * a[i]
	return sqrt(s / maxf(1.0, float(to - from)))

static func measure(path: String) -> Dictionary:
	var w := read_wav(path)
	if w.is_empty():
		return {}
	var d: PackedFloat32Array = w["data"]
	var pk := 0.0
	for v in d:
		pk = maxf(pk, absf(v))
	var out := {"rms": db(rms_of(d)), "peak": db(pk), "loop": w["loop"], "secs": d.size() / float(w["sr"])}
	if w["loop"]:
		var k := int(0.25 * w["sr"])
		out["seam_db"] = db(rms_of(d, 0, k)) - db(rms_of(d, d.size() - k, d.size()))
		var ds := 0.0
		for i in range(1, d.size()):
			ds += (d[i] - d[i - 1]) * (d[i] - d[i - 1])
		out["click"] = absf(d[0] - d[d.size() - 1]) / maxf(sqrt(ds / d.size()), 1e-9)
	return out

static func ids_in(dir: String) -> Array:
	var r: Array = []
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".wav"):
			r.append(f.get_basename())
	r.sort()
	return r

static func median(a: Array) -> float:
	var s := a.duplicate()
	s.sort()
	if s.size() % 2 == 1:
		return s[s.size() / 2]
	return (float(s[s.size() / 2 - 1]) + float(s[s.size() / 2])) / 2.0

func _initialize() -> void:
	for kind in ["music", "sfx", "ambience"]:
		var rows: Array = []
		for id in ids_in("res://audio/%s" % kind):
			var m := measure("res://audio/%s/%s.wav" % [kind, id])
			if not m.is_empty():
				rows.append([id, m])
		var rms_list: Array = []
		for r in rows:
			rms_list.append(r[1]["rms"])
		var med := median(rms_list)
		print("== %s (median rms %.2f dBFS) ==" % [kind, med])
		print("%-20s %6s %7s %7s %7s %7s %7s" % ["id", "secs", "rms", "peak", "vs_med", "seam_db", "click"])
		for r in rows:
			var m: Dictionary = r[1]
			var seam := "      -       -"
			if m["loop"]:
				seam = "%7.2f %7.2f" % [m["seam_db"], m["click"]]
			print("%-20s %6.2f %7.2f %7.2f %+7.2f %s" % [r[0], m["secs"], m["rms"], m["peak"], m["rms"] - med, seam])
	quit(0)
