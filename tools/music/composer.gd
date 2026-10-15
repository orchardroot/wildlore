class_name Composer
extends RefCounted
## Note-list composer. Melodies are written as scale degrees in a mode:
##   "1 3 5':2 b7,:1 r:2 1+3+5:4"  degree 1-7, ' octave up, , octave down, b/# accidental prefix,
##   :n duration in units (default 1), r rest, + chord. Bars are visual only ("|").
## Events are {i: instrument, t: unit, d: units, n: midi, v: velocity}.

const MODES := {
	"dorian": [0, 2, 3, 5, 7, 9, 10],
	"mixolydian": [0, 2, 4, 5, 7, 9, 10],
	"aeolian": [0, 2, 3, 5, 7, 8, 10],
	"ionian": [0, 2, 4, 5, 7, 9, 11],
}
const GAINS := {"fiddle": 1.0, "whistle": 1.0, "harp": 0.8, "guitar": 0.7, "bass": 0.9, "thump": 1.0, "tick": 0.8, "shaker": 0.6, "drone": 0.45, "brass": 0.9, "surf": 0.5, "reed": 0.9, "pipe": 1.0, "bouzouki": 0.75, "chanter": 0.85, "bell": 0.7}
const TARGET_RMS_DB := -12.0  ## every track is levelled to this RMS (plus level_db), so tracks sit together
const PEAK_CEIL := 0.89  ## about -1 dBFS; a track whose crest factor needs more than this stays a little quieter
const SEAM_RIDE_SEC := 2.0
const SEAM_FLOOR := 0.8  ## the tail is lifted to at least this fraction of the track RMS
const SEAM_MAX_BOOST := 4.0
const LOOSE := ["harp", "guitar", "bouzouki", "thump", "tick", "shaker"]  # voices that get a hint of human timing

var tonic := 62
var mode: Array = MODES["dorian"]
var unit := 0.15  ## seconds per unit
var upb := 8  ## units per bar
var bars := 16
var loop := true
var tail := 1.5
var level_db := 0.0  ## per-track loudness offset from TARGET_RMS_DB (battles +1, sanctuary and ending -1)
var seam_fade := 0.0  ## seconds of fade at each end of a looping track, so the loop point sits exactly on zero
var events: Array = []
var errors: Array = []

func midi_of(idx: int, acc := 0) -> int:
	var oct := floori(float(idx) / 7.0)
	var deg := idx - oct * 7
	return tonic + 12 * oct + int(mode[deg]) + acc

func _note(s: String) -> int:
	var i := 0
	var acc := 0
	if s[0] == "b":
		acc = -1
		i = 1
	elif s[0] == "#":
		acc = 1
		i = 1
	var deg := int(s[i]) - 1
	var oct := 0
	for j in range(i + 1, s.length()):
		if s[j] == "'":
			oct += 1
		elif s[j] == ",":
			oct -= 1
	return midi_of(deg + 7 * oct, acc)

## Returns {"items": [{t, d, n: Array}], "total": units}.
func parse(text: String) -> Dictionary:
	var items: Array = []
	var t := 0.0
	for tok in text.split(" ", false):
		if tok == "|":
			continue
		var parts := tok.split(":")
		var d := 1.0 if parts.size() < 2 else float(parts[1])
		var notes: Array = []
		if parts[0] != "r":
			for s in parts[0].split("+"):
				notes.append(_note(s))
		items.append({"t": t, "d": d, "n": notes})
		t += d
	return {"items": items, "total": t}

func _add(inst: String, t: float, d: float, n: int, v: float) -> void:
	events.append({"i": inst, "t": t, "d": d, "n": n, "v": v})

## A melodic line starting at `bar`; must fill exactly nbars bars.
func lead(inst: String, text: String, bar: int, nbars := 8, vel := 0.8, shift := 0) -> void:
	var p := parse(text)
	if absf(float(p["total"]) - nbars * upb) > 0.001:
		errors.append("lead '%s' at bar %d is %s units, wanted %d" % [inst, bar, str(p["total"]), nbars * upb])
	for it in p["items"]:
		for n in it["n"]:
			_add(inst, bar * upb + float(it["t"]), float(it["d"]) * 0.96, int(n) + shift, vel)

func _root(deg: int) -> int:
	var r := deg - 1
	if r > 3:
		r -= 7
	return r

## Arpeggiated chords: one chord (root degree 1-7) per bar; pattern chars 0-3 pick root, third, fifth, octave.
func arp(inst: String, chords: Array, bar: int, pattern: String, vel := 0.5, shift := 0) -> void:
	for k in chords.size():
		var r := _root(int(chords[k]))
		var tones := [r, r + 2, r + 4, r + 7]
		for u in pattern.length():
			var c := pattern[u]
			if c == ".":
				continue
			_add(inst, (bar + k) * upb + u, 3.0, midi_of(int(tones[int(c)]) + 0, 0) + shift, vel)

## Strummed chords: all three tones, slightly staggered, on units marked X (hard) or x (soft).
func strum(inst: String, chords: Array, bar: int, pattern: String, vel := 0.5, shift := 0) -> void:
	for k in chords.size():
		var r := _root(int(chords[k]))
		for u in pattern.length():
			var c := pattern[u]
			if c == ".":
				continue
			var vv := vel if c == "X" else vel * 0.6
			var ti := 0
			for tone in [r, r + 2, r + 4]:
				_add(inst, (bar + k) * upb + u + ti * 0.12, 2.0, midi_of(int(tone)) + shift, vv)
				ti += 1

## Sustained triads, one chord per bar: a pad.
func pad(inst: String, chords: Array, bar: int, vel := 0.3, shift := 0) -> void:
	for k in chords.size():
		var r := _root(int(chords[k]))
		for tone in [r, r + 2, r + 4]:
			_add(inst, (bar + k) * upb, float(upb) * 0.98, midi_of(int(tone)) + shift, vel)

## Bass: pattern chars x (root) and o (fifth), one chord per bar.
func bass(chords: Array, bar: int, pattern: String, vel := 0.7, shift := -12) -> void:
	for k in chords.size():
		var r := _root(int(chords[k]))
		for u in pattern.length():
			var c := pattern[u]
			if c == ".":
				continue
			var idx := r if c == "x" else r + 4
			_add("bass", (bar + k) * upb + u, 2.0, midi_of(idx) + shift, vel)

## Percussion: X thump accent, x soft thump, r rim tick, s shaker, . rest. Repeats for nbars.
func drums(pattern: String, bar: int, nbars: int, vel := 0.8) -> void:
	for k in nbars:
		for u in pattern.length():
			var c := pattern[u]
			var t := float((bar + k) * upb + u)
			if c == "X":
				_add("thump", t, 1.0, tonic - 24, vel)
			elif c == "x":
				_add("thump", t, 1.0, tonic - 17, vel * 0.55)
			elif c == "r":
				_add("tick", t, 0.5, 60, vel)
			elif c == "s":
				_add("shaker", t, 0.5, 60, vel * 0.8)

## Drone on tonic (two octaves down) and fifth for nbars bars.
func drone(bar: int, nbars: int, vel := 0.5) -> void:
	var t := float(bar * upb)
	var d := float(nbars * upb) + 0.5 / unit
	_add("drone", t, d, tonic - 24, vel)
	_add("drone", t, d, tonic - 17, vel * 0.5)

func total_seconds() -> float:
	return bars * upb * unit

func render(sr: int) -> PackedFloat32Array:
	var L := Synth.frames(total_seconds(), sr)
	var tail_n := Synth.frames(tail, sr)
	var out := Synth.make(L + tail_n)
	var cache := {}
	var idx := 0
	for e in events:
		idx += 1
		var inst: String = e["i"]
		var t := float(e["t"]) * unit
		if inst in LOOSE:
			t += float((idx * 7919) % 13 - 6) * 0.0008
		var start := maxi(0, Synth.frames(t, sr))
		if start >= L:
			continue
		var dur := float(e["d"]) * unit
		var key := "%s|%d|%.3f|%.2f" % [inst, int(e["n"]), dur, float(e["v"])]
		if not cache.has(key):
			cache[key] = Inst.render(inst, int(e["n"]), dur, sr, float(e["v"]))
		var g: float = GAINS.get(inst, 1.0)
		g *= 1.0 + float((idx * 31) % 7 - 3) * 0.02
		Synth.mix_into(out, cache[key], start, g)
	if loop:
		# Ring-out folds onto the start so the loop point is seamless.
		for i in tail_n:
			if i < L:
				out[i] += out[L + i]
		out.resize(L)
	# Small room: two circular combs, then compress gently and level.
	Synth.echo(out, Synth.frames(0.137, sr), 0.35, 0.22)
	Synth.echo(out, Synth.frames(0.263, sr), 0.30, 0.16)
	Synth.remove_dc(out)
	Synth.soften(out, 1.3)
	if loop and seam_fade > 0.0:
		Synth.fade_in(out, sr, seam_fade)
		Synth.fade_out(out, sr, seam_fade)
	if not loop:
		Synth.fade_out(out, sr, 0.4)
		Synth.fade_in(out, sr, 0.004)
	if loop:
		_seam_ride(out, sr)
	_level(out)
	return out

## Some phrases end on a rest, so the last second or two dips well below the body of the track and the loop breathes
## out and back in. Ride the gain up over the tail (never down, never beyond SEAM_MAX_BOOST) so the seam has no level step.
func _seam_ride(out: PackedFloat32Array, sr: int) -> void:
	var n := out.size()
	var blk := maxi(1, int(0.025 * sr))
	var nb := n / blk
	var tail_b := mini(nb, int(SEAM_RIDE_SEC / 0.025))
	var floor_rms := Synth.rms(out) * SEAM_FLOOR
	var g := PackedFloat32Array()
	g.resize(nb)
	g.fill(1.0)
	for b in range(nb - tail_b, nb):
		var s := 0.0
		for i in range(b * blk, (b + 1) * blk):
			s += out[i] * out[i]
		var e := sqrt(s / blk)
		g[b] = clampf(floor_rms / maxf(e, 1e-5), 1.0, SEAM_MAX_BOOST)
	# Smooth the gain curve (moving average, 7 blocks) so the ride itself is inaudible.
	var sm := g.duplicate()
	for b in nb:
		var acc := 0.0
		for k in range(-3, 4):
			acc += g[clampi(b + k, 0, nb - 1)]
		sm[b] = acc / 7.0
	for i in n:
		var pos := (float(i) + 0.5) / blk - 0.5
		var b0 := clampi(int(floor(pos)), 0, nb - 1)
		var b1 := mini(b0 + 1, nb - 1)
		out[i] *= lerpf(sm[b0], sm[b1], clampf(pos - b0, 0.0, 1.0))

func _level(out: PackedFloat32Array) -> void:
	var r := Synth.rms(out)
	var p := Synth.peak(out)
	if r <= 0.0:
		return
	var g := pow(10.0, (TARGET_RMS_DB + level_db) / 20.0) / r
	if p * g > PEAK_CEIL:
		g = PEAK_CEIL / p
	Synth.scale(out, g)
