class_name Cries
extends RefCounted
## Creature cries, synthesised at runtime the first time each is needed and cached for the session.
## A species' cry is seeded by its id (so it never changes) and shaped by its types and size: a small hedgerow
## creature chirps, a big stone one rumbles, a gale one whistles, a spirit one wails with an echo.
## The primary type picks the voice; the secondary adds grit, breath or shimmer. Size (base stat total) sets
## pitch and length. Levelled to sit with the sound effects (TARGET_DB is the sfx median RMS; see
## tools/audio/loudness.gd, which also lists every cry). Lives in core/ (not tools/) because it runs in game.

const SR := 16000
const TARGET_DB := -17.5     # RMS, the median of res://audio/sfx
const PEAK := 0.85           # about -1.4 dBFS

## voice: [waveform, hz small, hz big, noise, lowpass Hz, syllables min, max, contour, vibrato Hz, vibrato depth]
## waveform: 0 sine, 1 triangle, 2 square, 3 saw. contour: how each syllable's pitch moves.
const VOICES := {
	"chirp":   [1, 2600.0, 1100.0, 0.0, 6000.0, 2, 4, "rise", 0.0, 0.0],
	"whistle": [0, 2100.0, 800.0, 0.12, 6500.0, 1, 2, "arch", 6.0, 0.02],
	"rumble":  [3, 230.0, 60.0, 0.3, 700.0, 1, 2, "fall", 3.0, 0.03],
	"warble":  [0, 1300.0, 320.0, 0.0, 4000.0, 1, 3, "arch", 18.0, 0.06],
	"croak":   [2, 520.0, 130.0, 0.05, 1500.0, 2, 3, "fall", 0.0, 0.0],
	"crackle": [2, 900.0, 260.0, 0.1, 2500.0, 1, 2, "arch", 0.0, 0.0],
	"zap":     [2, 1500.0, 420.0, 0.08, 4500.0, 1, 3, "fall", 40.0, 0.04],
	"roar":    [3, 420.0, 95.0, 0.28, 1400.0, 1, 2, "arch", 5.0, 0.02],
	"squawk":  [2, 1300.0, 480.0, 0.06, 3500.0, 1, 3, "rise", 0.0, 0.0],
	"chime":   [0, 2200.0, 850.0, 0.0, 7000.0, 1, 3, "rise", 0.0, 0.0],
	"eerie":   [0, 900.0, 260.0, 0.04, 3000.0, 1, 1, "arch", 5.0, 0.03],
	"bleat":   [3, 900.0, 220.0, 0.04, 1800.0, 1, 2, "arch", 7.0, 0.03],
}
const TYPE_VOICE := {
	"kin": "bleat", "hedgerow": "chirp", "brook": "warble", "tide": "warble", "hearth": "crackle", "gale": "whistle",
	"storm": "zap", "frost": "whistle", "stone": "rumble", "bog": "croak", "iron": "rumble", "urban": "squawk",
	"fae": "chime", "spirit": "eerie", "brawn": "roar", "night": "eerie",
}
const TYPE_LAYER := {
	"stone": "grit", "iron": "grit", "brawn": "grit", "storm": "grit", "hearth": "grit",
	"gale": "breath", "frost": "breath", "bog": "breath",
	"fae": "shimmer", "spirit": "shimmer", "night": "shimmer", "tide": "shimmer", "brook": "shimmer",
}

static var _cache := {}

## 0 (smallest first stage) .. 1 (legend-sized), from the base stat total.
static func size_of(sp: Dictionary) -> float:
	var total := 0
	for v in sp.get("base", {}).values():
		total += int(v)
	return clampf((total - 290.0) / 310.0, 0.0, 1.0)

## Everything that makes this species' cry, as plain data (for tests, and the loudness listing).
static func recipe(sp: Dictionary) -> Dictionary:
	var id := str(sp.get("id", ""))
	var types: Array = sp.get("types", ["kin"])
	var first := str(types[0]) if not types.is_empty() else "kin"
	var second := str(types[1]) if types.size() > 1 else ""
	var timbre: String = TYPE_VOICE.get(first, "bleat")
	var v: Array = VOICES[timbre]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("cry:" + id)
	var s := size_of(sp)
	var syl_lo := int(v[5])
	var syl_hi := int(v[6])
	var syllables := rng.randi_range(syl_lo, syl_hi)
	if s > 0.6:
		syllables = maxi(syl_lo, syllables - 1)  # big creatures call once and long
	var contour: String = v[7]
	if rng.randf() < 0.25:
		contour = ["rise", "fall", "arch"][rng.randi() % 3]  # a few break their kind's habit
	var sweep := rng.randf_range(1.25, 1.8)
	if contour == "fall":
		sweep = 1.0 / sweep
	return {
		"timbre": timbre,
		"layer": TYPE_LAYER.get(second, "") if second != "" else "",
		"wave": int(v[0]),
		"hz": lerpf(float(v[1]), float(v[2]), s) * rng.randf_range(0.88, 1.12),
		"secs": clampf(lerpf(0.32, 0.8, s) * rng.randf_range(0.9, 1.1), 0.25, 0.9),
		"syllables": syllables,
		"step": rng.randf_range(-0.18, 0.18),          # each syllable a little higher or lower than the last
		"contour": contour,
		"sweep": sweep,
		"noise": float(v[3]) + rng.randf_range(0.0, 0.05),
		"cutoff": float(v[4]) * rng.randf_range(0.85, 1.15),
		"vib_hz": float(v[8]) * rng.randf_range(0.8, 1.25),
		"vib": float(v[9]),
		"attack": rng.randf_range(0.006, 0.03) * (2.0 if timbre in ["rumble", "eerie", "roar"] else 1.0),
		"decay": rng.randf_range(0.5, 1.4),
		"echo": timbre == "eerie",
		"seed": rng.randi(),
	}

## The cry as mono samples at SR, levelled to TARGET_DB RMS with peaks under PEAK.
static func render(sp: Dictionary) -> PackedFloat32Array:
	var r := recipe(sp)
	var secs: float = r.secs
	var tail := 0.12 if r.echo else 0.0
	var n := int(round((secs + tail) * SR))
	var buf := PackedFloat32Array()
	buf.resize(n)
	var wave: int = r.wave
	var syl: int = r.syllables
	var slot := secs / syl
	var gap := 1.0 if syl == 1 else 0.8
	var lsweep := log(float(r.sweep))
	var noise_amt: float = r.noise + (0.2 if r.layer == "grit" else 0.0) + (0.12 if r.layer == "breath" else 0.0)
	var shimmer: bool = r.layer == "shimmer" or r.timbre in ["chime", "eerie"]
	var ratio := 2.76 if r.timbre == "chime" else (1.012 if r.timbre == "eerie" else 2.0)
	var crackle: bool = r.timbre == "crackle"
	var state: int = int(r.seed) & 0xFFFFFFFF
	var inv := 1.0 / SR
	for k in syl:
		var f0: float = float(r.hz) * (1.0 + float(r.step) * k)
		var start := int(k * slot * SR)
		var len_n := int(slot * gap * SR)
		var phase := 0.0
		var phase2 := 0.0
		var att: float = r.attack
		for i in len_n:
			var idx := start + i
			if idx >= n:
				break
			var u := float(i) / len_n
			var t := i * inv
			var c := u
			if r.contour == "arch":
				c = sin(PI * u)
			var f := f0 * exp(lsweep * c)
			if r.vib > 0.0:
				f *= 1.0 + r.vib * sin(TAU * r.vib_hz * t)
			phase += f * inv
			phase -= floor(phase)
			var x := 0.0
			if wave == 0:
				x = sin(TAU * phase)
			elif wave == 1:
				x = 4.0 * absf(phase - 0.5) - 1.0
			elif wave == 2:
				x = 0.7 if phase < 0.5 else -0.7
			else:
				x = 2.0 * phase - 1.0
			if shimmer:
				phase2 += f * ratio * inv
				phase2 -= floor(phase2)
				x += 0.35 * sin(TAU * phase2)
			state = (state * 1664525 + 1013904223) & 0xFFFFFFFF
			var white := state / 2147483648.0 - 1.0
			x += white * noise_amt
			if crackle and state % 97 == 0:
				x += 1.5 * white
			var env := minf(1.0, t / att) * pow(1.0 - u, r.decay)
			buf[idx] += x * env
	# one-pole low-pass for the voice's body
	var a := 1.0 - exp(-TAU * float(r.cutoff) * inv)
	var y := 0.0
	for i in n:
		y += a * (buf[i] - y)
		buf[i] = y
	if r.echo:
		var d := int(0.09 * SR)
		for i in range(n - 1, d - 1, -1):
			buf[i] += 0.35 * buf[i - d]
	_level(buf)
	return buf

static func _level(buf: PackedFloat32Array) -> void:
	var n := buf.size()
	if n == 0:
		return
	var mean := 0.0
	for v in buf:
		mean += v
	mean /= n
	var edge := mini(int(0.02 * SR), n / 4)
	for i in n:
		var g := 1.0
		if i < 80:
			g = i / 80.0
		elif i > n - edge:
			g = float(n - i) / edge
		buf[i] = (buf[i] - mean) * g
	var target := pow(10.0, TARGET_DB / 20.0)
	for pass_i in 3:
		var s := 0.0
		for v in buf:
			s += v * v
		var rms := sqrt(s / n)
		if rms <= 1e-9:
			return
		var k := target / rms
		var pk := 0.0
		for i in n:
			buf[i] *= k
			pk = maxf(pk, absf(buf[i]))
		if pk <= PEAK:
			return
		if pass_i < 2:
			for i in n:  # soft-limit the peaks, then level again
				buf[i] = 0.7 * tanh(buf[i] / 0.7)
		else:
			for i in n:
				buf[i] *= PEAK / pk

static func to_stream(buf: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = SR
	s.stereo = false
	s.data = bytes
	return s

## The species' cry as a stream, rendered once per session.
static func stream_for(sp: Dictionary) -> AudioStreamWAV:
	var id := str(sp.get("id", ""))
	if id == "":
		return null
	if not _cache.has(id):
		_cache[id] = to_stream(render(sp))
	return _cache[id]

static func clear_cache() -> void:
	_cache.clear()
