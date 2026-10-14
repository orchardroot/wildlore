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
