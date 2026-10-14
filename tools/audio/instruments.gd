class_name Inst
extends RefCounted
## Folk-flavoured voices built from Synth. Each returns a buffer of the note length plus its own tail.

static func hz(midi: int) -> float:
	return 440.0 * pow(2.0, (midi - 69) / 12.0)

static func render(name: String, midi: int, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	match name:
		"fiddle": return fiddle(hz(midi), dur, sr, vel)
		"whistle": return whistle(hz(midi), dur, sr, vel)
		"harp": return harp(hz(midi), dur, sr, vel)
		"guitar": return guitar(hz(midi), dur, sr, vel)
		"bass": return bass(hz(midi), dur, sr, vel)
		"thump": return thump(hz(midi), sr, vel)
		"tick": return tick(sr, vel)
		"shaker": return shaker(sr, vel)
		"drone": return drone(hz(midi), dur, sr, vel)
		"brass": return brass(hz(midi), dur, sr, vel)
		"surf": return surf(dur, sr, vel)
		"reed": return reed(hz(midi), dur, sr, vel)
		"pipe": return pipe(hz(midi), dur, sr, vel)
		"bouzouki": return bouzouki(hz(midi), dur, sr, vel)
	push_error("unknown instrument " + name)
	return Synth.make(1)

## Saw through a two-pole low-pass, delayed vibrato, slight bow attack, a detuned twin for body.
static func fiddle(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.10
	var total := dur + rel
	var a := Synth.osc(Synth.SAW, f, f, total, sr, 0.5, 5.3, 14.0, 0.18)
	var b := Synth.osc(Synth.SAW, f * 1.0035, f * 1.0035, total, sr, 0.5, 5.3, 14.0, 0.18)
	Synth.mix_into(a, b, 0, 0.7)
	var fc := minf(f * 4.5, 3400.0)
	Synth.lowpass(a, fc, sr)
	Synth.lowpass(a, fc, sr)
	Synth.adsr(a, sr, 0.045, 0.10, 0.82, rel)
	Synth.scale(a, 0.55 * vel)
	return a

## Sine with a touch of second harmonic plus breath noise; light late vibrato.
static func whistle(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.09
	var total := dur + rel
	var a := Synth.osc(Synth.SINE, f, f, total, sr, 0.5, 5.0, 8.0, 0.25)
	var h := Synth.osc(Synth.SINE, f * 2.0, f * 2.0, total, sr)
	Synth.mix_into(a, h, 0, 0.13)
	var br := Synth.noise(total, sr, 7 + int(f))
	Synth.highpass(br, 1500.0, sr)
	Synth.lowpass(br, 5000.0, sr)
	Synth.mix_into(a, br, 0, 0.16)
	Synth.adsr(a, sr, 0.035, 0.08, 0.85, rel)
	Synth.scale(a, 0.5 * vel)
	return a

## Decaying triangle plus a quiet octave: harp-ish.
static func harp(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var total := maxf(dur, 0.5) + 0.4
	var a := Synth.osc(Synth.TRI, f, f, total, sr)
	var h := Synth.osc(Synth.SINE, f * 2.0, f * 2.0, total, sr)
	Synth.mix_into(a, h, 0, 0.3)
	Synth.pluck_env(a, sr, 0.003, 3.4)
	Synth.scale(a, 0.6 * vel)
	return a

## Brighter, shorter pluck: guitar-ish strum voice.
static func guitar(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var total := maxf(dur, 0.3) + 0.25
	var a := Synth.osc(Synth.SAW, f, f, total, sr)
	Synth.lowpass(a, minf(f * 5.0, 2600.0), sr)
	Synth.pluck_env(a, sr, 0.002, 6.5)
	Synth.scale(a, 0.5 * vel)
	return a

static func bass(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var total := maxf(dur, 0.25) + 0.2
	var a := Synth.osc(Synth.TRI, f, f, total, sr)
	Synth.pluck_env(a, sr, 0.004, 4.2)
	Synth.scale(a, 0.8 * vel)
	return a

## Bodhran-ish: low sine that drops in pitch plus a dull skin slap.
static func thump(f: float, sr: int, vel: float) -> PackedFloat32Array:
	var total := 0.28
	var a := Synth.osc(Synth.SINE, f * 1.6, f * 0.8, total, sr)
	Synth.pluck_env(a, sr, 0.002, 16.0)
	var n := Synth.noise(total, sr, 3 + int(f))
	Synth.lowpass(n, 900.0, sr)
	Synth.pluck_env(n, sr, 0.001, 70.0)
	Synth.mix_into(a, n, 0, 0.6)
	Synth.scale(a, 0.95 * vel)
	return a

## Dry stick tick on the rim.
static func tick(sr: int, vel: float) -> PackedFloat32Array:
	var n := Synth.noise(0.06, sr, 11)
	Synth.highpass(n, 2500.0, sr)
	Synth.pluck_env(n, sr, 0.0005, 60.0)
	var t := Synth.osc(Synth.SINE, 900.0, 600.0, 0.06, sr)
	Synth.pluck_env(t, sr, 0.0005, 70.0)
	Synth.mix_into(n, t, 0, 0.5)
	Synth.scale(n, 0.5 * vel)
	return n

static func shaker(sr: int, vel: float) -> PackedFloat32Array:
	var n := Synth.noise(0.07, sr, 21)
	Synth.highpass(n, 5000.0, sr)
	Synth.pluck_env(n, sr, 0.004, 45.0)
	Synth.scale(n, 0.35 * vel)
	return n

## Two detuned saws, low-passed hard, swelling in and out.
static func drone(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.6
	var total := dur + rel
	var a := Synth.osc(Synth.SAW, f, f, total, sr)
	var b := Synth.osc(Synth.SAW, f * 1.004, f * 1.004, total, sr)
	var c := Synth.osc(Synth.SAW, f * 1.5, f * 1.5, total, sr)
	Synth.mix_into(a, b, 0, 0.8)
	Synth.mix_into(a, c, 0, 0.35)
	Synth.lowpass(a, 380.0, sr)
	Synth.lowpass(a, 380.0, sr)
	Synth.adsr(a, sr, 0.5, 0.2, 0.9, rel)
	Synth.scale(a, 0.6 * vel)
	return a

## Two detuned saws with a low-pass that opens through the note: a blaring, slightly pompous brass.
static func brass(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.08
	var total := dur + rel
	var a := Synth.osc(Synth.SAW, f, f, total, sr, 0.5, 5.0, 6.0, 0.3)
	var b := Synth.osc(Synth.SAW, f * 1.006, f * 1.006, total, sr)
	Synth.mix_into(a, b, 0, 0.8)
	Synth.lowpass_sweep(a, f * 2.0, clampf(f * 8.0, 900.0, 4000.0), sr)
	Synth.adsr(a, sr, 0.03, 0.08, 0.85, rel)
	Synth.scale(a, 0.45 * vel)
	return a

## Filtered noise that swells and falls away: a wave on the shore. The note is ignored.
static func surf(dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var n := Synth.noise(dur, sr, 31 + int(dur * 10.0))
	Synth.lowpass(n, 1100.0, sr)
	Synth.lowpass(n, 1100.0, sr)
	Synth.highpass(n, 180.0, sr)
	Synth.adsr(n, sr, dur * 0.4, 0.1, 0.7, dur * 0.45)
	Synth.scale(n, 0.9 * vel)
	return n

## Accordion-ish: two slightly detuned square-ish reeds (musette beat), mellowed, with a soft bellows attack.
static func reed(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.07
	var total := dur + rel
	var a := Synth.osc(Synth.SQUARE, f, f, total, sr, 0.4, 5.0, 6.0, 0.3)
	var b := Synth.osc(Synth.SQUARE, f * 1.007, f * 1.007, total, sr, 0.3)
	Synth.mix_into(a, b, 0, 0.9)
	var c := Synth.osc(Synth.SAW, f * 0.5, f * 0.5, total, sr)
	Synth.mix_into(a, c, 0, 0.25)
	var fc := clampf(f * 5.0, 900.0, 2600.0)
	Synth.lowpass(a, fc, sr)
	Synth.lowpass(a, fc, sr)
	Synth.adsr(a, sr, 0.05, 0.1, 0.85, rel)
	Synth.scale(a, 0.4 * vel)
	return a

## A soft, breathy, distant pipe: sine with a hollow third harmonic, lots of air, slow swell.
static func pipe(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var rel := 0.25
	var total := dur + rel
	var a := Synth.osc(Synth.SINE, f, f, total, sr, 0.5, 4.6, 9.0, 0.4)
	var h := Synth.osc(Synth.SINE, f * 3.0, f * 3.0, total, sr)
	Synth.mix_into(a, h, 0, 0.12)
	var br := Synth.noise(total, sr, 13 + int(f))
	Synth.highpass(br, 1200.0, sr)
	Synth.lowpass(br, 4200.0, sr)
	Synth.mix_into(a, br, 0, 0.28)
	Synth.adsr(a, sr, 0.14, 0.12, 0.8, rel)
	Synth.scale(a, 0.5 * vel)
	return a

## Bright double-course pluck, a little metallic: bouzouki-ish.
static func bouzouki(f: float, dur: float, sr: int, vel: float) -> PackedFloat32Array:
	var total := maxf(dur, 0.3) + 0.25
	var a := Synth.osc(Synth.SAW, f, f, total, sr)
	var b := Synth.osc(Synth.SAW, f * 1.004, f * 1.004, total, sr)
	var o := Synth.osc(Synth.TRI, f * 2.0, f * 2.0, total, sr)
	Synth.mix_into(a, b, 0, 0.8)
	Synth.mix_into(a, o, 0, 0.4)
	Synth.lowpass(a, minf(f * 7.0, 3600.0), sr)
	Synth.pluck_env(a, sr, 0.002, 5.5)
	Synth.scale(a, 0.42 * vel)
	return a
