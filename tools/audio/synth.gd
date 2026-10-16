class_name Synth
extends RefCounted
## Tiny offline synthesiser: oscillators, envelopes, filters and mixing on PackedFloat32Array buffers.
## Everything is deterministic (noise uses a private LCG, never the global RNG).

enum { SINE, SQUARE, SAW, TRI, NOISE }

static func make(n: int) -> PackedFloat32Array:
	var a := PackedFloat32Array()
	a.resize(n)
	return a

static func frames(sec: float, sr: int) -> int:
	return int(round(sec * sr))

static func _blep(t: float, dt: float) -> float:
	if t < dt:
		var x := t / dt
		return x + x - x * x - 1.0
	elif t > 1.0 - dt:
		var x := (t - 1.0) / dt
		return x * x + x + x + 1.0
	return 0.0

## One oscillator. Frequency sweeps exponentially f0 -> f1 across the buffer. Vibrato fades in after vib_delay.
static func osc(kind: int, f0: float, f1: float, dur: float, sr: int, duty := 0.5, vib_hz := 0.0, vib_cents := 0.0, vib_delay := 0.0, seed := 1) -> PackedFloat32Array:
	var n := frames(dur, sr)
	var out := make(n)
	var inv := 1.0 / sr
	var phase := 0.0
	var state := seed & 0xFFFFFFFF
	var lr := 0.0
	if f1 != f0 and f0 > 0.0 and f1 > 0.0:
		lr = log(f1 / f0)
	var vib_k := vib_cents * 0.000578
	for i in n:
		var f := f0
		if lr != 0.0:
			f = f0 * exp(lr * float(i) / n)
		if vib_k != 0.0:
			var t := i * inv
			var depth := clampf((t - vib_delay) * 4.0, 0.0, 1.0)
			f *= 1.0 + vib_k * depth * sin(TAU * vib_hz * t)
		var dt := f * inv
		phase += dt
		phase -= floor(phase)
		var v := 0.0
		if kind == SINE:
			v = sin(TAU * phase)
		elif kind == SQUARE:
			v = (1.0 if phase < duty else -1.0) + _blep(phase, dt) - _blep(fposmod(phase - duty, 1.0), dt)
		elif kind == SAW:
			v = 2.0 * phase - 1.0 - _blep(phase, dt)
		elif kind == TRI:
			v = 4.0 * absf(phase - 0.5) - 1.0
		else:
			state = (state * 1664525 + 1013904223) & 0xFFFFFFFF
			v = state / 2147483648.0 - 1.0
		out[i] = v
	return out

static func noise(dur: float, sr: int, seed := 1) -> PackedFloat32Array:
	return osc(NOISE, 1.0, 1.0, dur, sr, 0.5, 0.0, 0.0, 0.0, seed)

## Linear attack/decay to sustain level, then a linear release over the final r seconds.
static func adsr(buf: PackedFloat32Array, sr: int, a: float, d: float, s: float, r: float) -> void:
	var n := buf.size()
	var total := float(n) / sr
	for i in n:
		var t := float(i) / sr
		var e := s
		if t < a:
			e = t / maxf(a, 0.00001)
		elif t < a + d:
			e = 1.0 - (1.0 - s) * (t - a) / maxf(d, 0.00001)
		if t > total - r:
			e *= maxf(0.0, (total - t) / maxf(r, 0.00001))
		buf[i] *= e

## Short linear attack then exponential decay (plucks, thumps), with a final 15 ms fade to zero.
static func pluck_env(buf: PackedFloat32Array, sr: int, attack: float, decay_k: float) -> void:
	var n := buf.size()
	var fade := mini(n, int(0.015 * sr))
	for i in n:
		var t := float(i) / sr
		var e := exp(-t * decay_k)
		if t < attack:
			e *= t / maxf(attack, 0.00001)
		if i > n - fade:
			e *= float(n - i) / fade
		buf[i] *= e

static func lowpass(buf: PackedFloat32Array, fc: float, sr: int) -> void:
	var a := 1.0 - exp(-TAU * fc / sr)
	var y := 0.0
	for i in buf.size():
		y += a * (buf[i] - y)
		buf[i] = y

static func highpass(buf: PackedFloat32Array, fc: float, sr: int) -> void:
	var a := 1.0 - exp(-TAU * fc / sr)
	var y := 0.0
	for i in buf.size():
		y += a * (buf[i] - y)
		buf[i] = buf[i] - y

## Low-pass whose cutoff glides from fc0 to fc1 (whooshes).
static func lowpass_sweep(buf: PackedFloat32Array, fc0: float, fc1: float, sr: int) -> void:
	var n := buf.size()
	var y := 0.0
	for i in n:
		var fc := fc0 + (fc1 - fc0) * float(i) / n
		y += (1.0 - exp(-TAU * fc / sr)) * (buf[i] - y)
		buf[i] = y

## Chamberlin state-variable band-pass: resonant, for wind howl and the body of a creak. `fcs` (one cutoff per
## frame, same length as buf) overrides `fc` so the band can wander.
static func bandpass(buf: PackedFloat32Array, fc: float, q: float, sr: int, fcs := PackedFloat32Array()) -> void:
	var low := 0.0
	var band := 0.0
	var damp := 1.0 / maxf(q, 0.5)
	var vary := fcs.size() == buf.size()
	var k := 2.0 * sin(PI * minf(fc, sr * 0.16) / sr)
	for i in buf.size():
		if vary:
			k = 2.0 * sin(PI * minf(fcs[i], sr * 0.16) / sr)
		var high := buf[i] - low - damp * band
		band += k * high
		low += k * band
		buf[i] = band

## Makes a seamless loop of the first `n` frames: the `x` frames rendered past the end are faded (equal power)
## over the start, so the end runs straight on into the beginning. Returns the n-frame loop.
static func seal_loop(buf: PackedFloat32Array, n: int, x: int) -> PackedFloat32Array:
	var out := buf.slice(0, n)
	for i in mini(x, buf.size() - n):
		var w := float(i) / x
		out[i] = buf[i] * sqrt(w) + buf[n + i] * sqrt(1.0 - w)
	return out

## Adds src into a looping dst at `offset`, wrapping past the end back to the start.
static func mix_wrap(dst: PackedFloat32Array, src: PackedFloat32Array, offset: int, gain := 1.0) -> void:
	var n := dst.size()
	for i in src.size():
		dst[(offset + i) % n] += src[i] * gain

## Scales so the RMS is `db` dBFS.
static func normalise_rms(buf: PackedFloat32Array, db: float) -> void:
	var r := rms(buf)
	if r > 0.0:
		scale(buf, pow(10.0, db / 20.0) / r)

static func scale(buf: PackedFloat32Array, g: float) -> void:
	for i in buf.size():
		buf[i] *= g

## Adds src into dst starting at frame offset (clipped to dst length).
static func mix_into(dst: PackedFloat32Array, src: PackedFloat32Array, offset: int, gain := 1.0) -> void:
	if offset < 0:
		return
	var n := mini(src.size(), dst.size() - offset)
	for i in n:
		dst[offset + i] += src[i] * gain

static func fade_out(buf: PackedFloat32Array, sr: int, sec: float) -> void:
	var n := buf.size()
	var f := mini(n, int(sec * sr))
	for i in f:
		buf[n - 1 - i] *= float(i) / f

static func fade_in(buf: PackedFloat32Array, sr: int, sec: float) -> void:
	var f := mini(buf.size(), int(sec * sr))
	for i in f:
		buf[i] *= float(i) / f

static func peak(buf: PackedFloat32Array) -> float:
	var p := 0.0
	for v in buf:
		p = maxf(p, absf(v))
	return p

static func rms(buf: PackedFloat32Array) -> float:
	if buf.is_empty():
		return 0.0
	var s := 0.0
	for v in buf:
		s += v * v
	return sqrt(s / buf.size())

static func remove_dc(buf: PackedFloat32Array) -> void:
	if buf.is_empty():
		return
	var m := 0.0
	for v in buf:
		m += v
	m /= buf.size()
	for i in buf.size():
		buf[i] -= m

static func normalise(buf: PackedFloat32Array, target: float) -> void:
	var p := peak(buf)
	if p > 0.0:
		scale(buf, target / p)

## Gentle tanh saturation: a cheap compressor so drum hits do not dictate the loudness of a whole track.
static func soften(buf: PackedFloat32Array, drive := 1.2) -> void:
	for i in buf.size():
		buf[i] = tanh(buf[i] * drive)

## Circular feedback comb (a poor man's room). Wraps around so loops stay seamless.
static func echo(buf: PackedFloat32Array, delay: int, fb: float, wet: float) -> void:
	var n := buf.size()
	if delay <= 0 or delay >= n:
		return
	var y := buf.duplicate()
	for pass_i in 2:
		for i in n:
			y[i] = buf[i] + fb * y[(i - delay + n) % n]
	for i in n:
		buf[i] += wet * y[(i - delay + n) % n]

static func to_stream(buf: PackedFloat32Array, sr: int, loop_begin := -1, loop_end := -1) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = sr
	s.stereo = false
	s.data = bytes
	if loop_begin >= 0 and loop_end > loop_begin:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
		s.loop_begin = loop_begin
		s.loop_end = loop_end
	return s

static func _has_chunk(bytes: PackedByteArray, tag: String) -> bool:
	var pos := 12
	while pos + 8 <= bytes.size():
		if bytes.slice(pos, pos + 4).get_string_from_ascii() == tag:
			return true
		pos += 8 + bytes.decode_u32(pos + 4)
		pos += pos & 1
	return false

## Saves via AudioStreamWAV.save_to_wav, then makes sure a looping file carries a 'smpl' chunk so Godot's importer keeps the loop.
static func save_wav(stream: AudioStreamWAV, path: String) -> int:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var err := stream.save_to_wav(path)
	if err != OK or stream.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		return err
	var f := FileAccess.open(path, FileAccess.READ)
	var bytes := f.get_buffer(f.get_length())
	f.close()
	if _has_chunk(bytes, "smpl"):
		return OK
	var c := PackedByteArray()
	c.resize(68)
	c.encode_u8(0, 0x73)
	c.encode_u8(1, 0x6d)
	c.encode_u8(2, 0x70)
	c.encode_u8(3, 0x6c)
	c.encode_u32(4, 60)
	c.encode_u32(16, 1000000000 / stream.mix_rate)
	c.encode_u32(20, 60)
	c.encode_u32(36, 1)
	c.encode_u32(48, 0)
	c.encode_u32(52, stream.loop_begin)
	c.encode_u32(56, stream.loop_end - 1)
	bytes.append_array(c)
	bytes.encode_u32(4, bytes.size() - 8)
	var w := FileAccess.open(path, FileAccess.WRITE)
	w.store_buffer(bytes)
	w.close()
	return OK
