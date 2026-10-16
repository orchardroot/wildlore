class_name AmbienceRecipes
extends RefCounted
## Looping background beds (and the two train loops). Each id renders to exactly round(LENGTHS[id] * SR) frames
## that loop seamlessly: steady layers are rendered a second long and the overhang faded over the start
## (Synth.seal_loop), every modulator has a whole number of cycles per loop, and one-off events wrap round.
## The finished loop is levelled to TARGET_DB (RMS dBFS), well under the music (about -12).

const SR := 22050
const OVERHANG := 1.0

const LENGTHS := {
	"amb_coast": 24.0, "amb_country": 24.0, "amb_city": 20.0, "amb_moor": 24.0, "amb_cave": 20.0,
	"amb_interior": 16.0, "amb_night": 24.0,
	"amb_rain_light": 16.0, "amb_rain_heavy": 16.0, "amb_gale": 24.0, "amb_rain_roof": 16.0,
	"train_run": 4.0, "crossing_alarm": 1.0,
}
const TARGET_DB := {
	"amb_coast": -27.0, "amb_country": -30.0, "amb_city": -29.0, "amb_moor": -28.0, "amb_cave": -32.0,
	"amb_interior": -36.0, "amb_night": -30.0,
	"amb_rain_light": -30.0, "amb_rain_heavy": -26.0, "amb_gale": -27.0, "amb_rain_roof": -32.0,
	"train_run": -18.0, "crossing_alarm": -20.0,
}
const LIMIT := 0.55  # peaks are rounded off above this (about -5 dBFS) before the final levelling

static func ids() -> Array:
	return LENGTHS.keys()

# --- building blocks ----------------------------------------------------------------------------------------------

## Deterministic 0..1 dice (state is a one-element array so callers can share it).
static func _rand(state: Array) -> float:
	state[0] = (int(state[0]) * 1103515245 + 12345) & 0x7FFFFFFF
	return float(state[0]) / 2147483647.0

## Filtered noise, `m` frames, levelled to RMS 1.
static func _noise(m: int, seed: int, lp: float, hp: float) -> PackedFloat32Array:
	var b := Synth.noise(m / float(SR), SR, seed)
	if lp > 0.0:
		Synth.lowpass(b, lp, SR)
		Synth.lowpass(b, lp, SR)
	if hp > 0.0:
		Synth.highpass(b, hp, SR)
	Synth.normalise_rms(b, 0.0)
	return b

## Sum of sines with whole cycles per loop of `n` frames ([cycles, amplitude, phase] each), `m` frames long.
static func _lfo(m: int, n: int, parts: Array) -> PackedFloat32Array:
	var out := Synth.make(m)
	for i in m:
		var v := 0.0
		for p in parts:
			v += float(p[1]) * sin(TAU * float(p[0]) * i / n + float(p[2]))
		out[i] = v
	return out

static func _sum(dst: PackedFloat32Array, src: PackedFloat32Array, gain := 1.0) -> void:
	Synth.mix_into(dst, src, 0, gain)

static func _at(sec: float) -> int:
	return Synth.frames(sec, SR)

## A short sine with a pitch sweep and a plucked envelope (chirps, drips, plinks).
static func _blip(f0: float, f1: float, dur: float, decay: float, attack := 0.002) -> PackedFloat32Array:
	var b := Synth.osc(Synth.SINE, f0, f1, dur, SR)
	Synth.pluck_env(b, SR, attack, decay)
	return b

## A soft tonal call (gull, owl): sine plus a little second harmonic, vibrato, shaped attack and release.
static func _call(f0: float, f1: float, dur: float, vib_hz: float, vib_cents: float, a: float, r: float, lp: float) -> PackedFloat32Array:
	var b := Synth.osc(Synth.SINE, f0, f1, dur, SR, 0.5, vib_hz, vib_cents)
	var h := Synth.osc(Synth.TRI, f0 * 2.0, f1 * 2.0, dur, SR, 0.5, vib_hz, vib_cents)
	Synth.mix_into(b, h, 0, 0.18)
	Synth.lowpass(b, lp, SR)
	Synth.adsr(b, SR, a, 0.05, 0.85, r)
	return b

## Raindrops scattered round the loop: `per_sec` of them, each a tick of noise and maybe a tiny plink.
static func _patter(out: PackedFloat32Array, per_sec: float, lp: float, hp: float, decay: float, g_lo: float, g_hi: float, plink: float, seed: int) -> void:
	var st := [seed]
	var count := int(per_sec * out.size() / SR)
	for k in count:
		var at := int(_rand(st) * out.size())
		var g := lerpf(g_lo, g_hi, pow(_rand(st), 2.0))
		var d := Synth.noise(0.012, SR, seed * 31 + k)
		if lp > 0.0:
			Synth.lowpass(d, lp, SR)
		if hp > 0.0:
			Synth.highpass(d, hp, SR)
		Synth.pluck_env(d, SR, 0.0005, decay)
		Synth.mix_wrap(out, d, at, g)
		if plink > 0.0 and _rand(st) < 0.3:
			var f := 2400.0 + 2200.0 * _rand(st)
			Synth.mix_wrap(out, _blip(f, f * 0.9, 0.025, 220.0, 0.0005), at, g * plink)

# --- render -------------------------------------------------------------------------------------------------------

static func render(id: String) -> PackedFloat32Array:
	var n := Synth.frames(LENGTHS[id], SR)
	var m := n + _at(OVERHANG)
	var bed := Synth.make(m)   # steady layers, sealed into a loop below
	var ev := Synth.make(n)    # one-off events, wrapped round the loop
	match id:
		"amb_coast":
			# Surf: a low wash swelling every six seconds, a hiss of foam trailing each wave, the sea's rumble under it.
			var swell := _lfo(m, n, [[4, 0.42, 0.0], [1, 0.14, 1.3], [7, 0.06, 0.4]])
			var surf := _noise(m, 3, 700.0, 70.0)
			var foam := _noise(m, 4, 4500.0, 1800.0)
			var lag := _at(0.9)
			for i in m:
				var s := clampf(0.5 + swell[i], 0.0, 1.0)
				var s2 := clampf(0.5 + swell[posmod(i - lag, n)], 0.0, 1.0)
				surf[i] *= 0.25 + 1.5 * s * s
				foam[i] *= 0.05 + 0.6 * s2 * s2 * s2
			_sum(bed, surf)
			_sum(bed, foam)
			_sum(bed, _noise(m, 5, 120.0, 0.0), 0.5)
			# Gulls, well off: two or three falling kyows each.
			var st := [11]
			for t0 in [2.7, 10.9, 19.3]:
				var calls := 2 + int(_rand(st) * 2.0)
				var p := 0.92 + 0.16 * _rand(st)
				for c in calls:
					var g := _call(1700.0 * p, 1120.0 * p, 0.24, 17.0, 60.0, 0.025, 0.08, 3000.0)
					Synth.mix_wrap(ev, g, _at(t0 + c * 0.32), 3.0 - 0.6 * c)
		"amb_country":
			# A light breeze, leaves stirring in the gusts, and now and then a bird.
			var wind := _noise(m, 21, 450.0, 50.0)
			var gust := _lfo(m, n, [[2, 0.25, 0.0], [5, 0.2, 1.1]])
			var leaves := _noise(m, 22, 6000.0, 2500.0)
			var rustle := _lfo(m, n, [[3, 0.5, 2.0], [7, 0.2, 0.3]])
			for i in m:
				wind[i] *= clampf(0.55 + gust[i], 0.15, 1.2)
				leaves[i] *= pow(clampf(0.5 + 0.5 * rustle[i], 0.0, 1.0), 3.0)
			_sum(bed, wind)
			_sum(bed, leaves, 0.3)
			var st := [23]
			for p in 6:
				var t := (p + 0.2 + 0.6 * _rand(st)) * float(LENGTHS[id]) / 6.0
				var g := 1.2 + 1.0 * _rand(st)
				match p % 3:
					0:  # cheeps
						for c in 3 + int(_rand(st) * 3.0):
							var f := 3600.0 + 800.0 * _rand(st)
							Synth.mix_wrap(ev, _blip(f, f * 1.25, 0.05, 50.0), _at(t + c * 0.12), g)
					1:  # a short warble
						for c in 4 + int(_rand(st) * 3.0):
							var f := 2800.0 + 2400.0 * _rand(st)
							var d := 0.08 + 0.08 * _rand(st)
							var w := Synth.osc(Synth.SINE, f, f * (0.85 + 0.3 * _rand(st)), d, SR, 0.5, 35.0, 80.0)
							Synth.adsr(w, SR, 0.01, 0.02, 0.7, 0.03)
							Synth.mix_wrap(ev, w, _at(t), g * 0.8)
							t += d + 0.03
					_:  # a wren's trill
						var f := 4500.0 + 500.0 * _rand(st)
						for c in 10 + int(_rand(st) * 5.0):
							Synth.mix_wrap(ev, _blip(f, f * 1.1, 0.03, 80.0), _at(t + c * 0.045), g * 0.7)
		"amb_city":
			# A low hum of the city, distant traffic, a car passing a street or two away.
			_sum(bed, _noise(m, 31, 140.0, 30.0))
			var hum := Synth.osc(Synth.SINE, 100.0, 100.0, m / float(SR), SR)
			_sum(bed, hum, 0.15)
			var road := _noise(m, 32, 600.0, 80.0)
			var drift := _lfo(m, n, [[2, 0.2, 0.0], [5, 0.15, 2.0]])
			for i in m:
				road[i] *= 0.6 + drift[i]
			_sum(bed, road, 0.6)
			var st := [33]
			for k in 6:
				var dur := 3.0 + 1.5 * _rand(st)
				var car := _noise(_at(dur), 40 + k, 800.0, 90.0)
				for i in car.size():
					car[i] *= pow(sin(PI * float(i) / car.size()), 2.0)
				Synth.mix_wrap(ev, car, _at((k + _rand(st)) * float(LENGTHS[id]) / 6.0), 0.7 + 0.6 * _rand(st))
		"amb_moor":
			# Wind over open ground: a wandering moan, a body of low rush, rising and falling in gusts.
			var moan := Synth.noise(m / float(SR), SR, 51)
			var fcs := _lfo(m, n, [[3, 220.0, 0.0], [7, 120.0, 1.7]])
			for i in m:
				fcs[i] += 380.0
			Synth.bandpass(moan, 0.0, 2.5, SR, fcs)
			Synth.normalise_rms(moan, 0.0)
			var body := _noise(m, 52, 260.0, 40.0)
			var gust := _lfo(m, n, [[2, 0.35, 0.6], [5, 0.2, 2.4]])
			for i in m:
				var e := clampf(0.45 + gust[i], 0.1, 1.2)
				moan[i] *= pow(e, 1.5)
				body[i] *= 0.6 + 0.4 * e
			_sum(bed, moan)
			_sum(bed, body, 0.8)
		"amb_cave":
			# Still air, a deep rumble, and water dripping into pools with a little echo off the rock.
			_sum(bed, _noise(m, 61, 90.0, 25.0))
			_sum(bed, _noise(m, 62, 600.0, 200.0), 0.15)
			var st := [63]
			for k in 9:
				var t := (k + 0.15 + 0.7 * _rand(st)) * float(LENGTHS[id]) / 9.0
				var f := 900.0 + 1000.0 * _rand(st)
				var g := 3.0 + 3.0 * _rand(st)
				Synth.mix_wrap(ev, _blip(f, f * 1.7, 0.05, 70.0, 0.0005), _at(t), g)
				Synth.mix_wrap(ev, _blip(f * 2.3, f * 2.3, 0.04, 40.0, 0.0005), _at(t + 0.004), g * 0.3)
			Synth.echo(ev, _at(0.11), 0.35, 0.5)
		"amb_interior":
			# Room tone: the faint low air of a building, a whisper of hiss.
			var room := _noise(m, 71, 260.0, 45.0)
			var drift := _lfo(m, n, [[1, 0.1, 0.0]])
			for i in m:
				room[i] *= 0.9 + drift[i]
			_sum(bed, room)
			_sum(bed, _noise(m, 72, 3000.0, 800.0), 0.12)
		"amb_night":
			# Soft night air, crickets at three distances, and once a tawny owl.
			_sum(bed, _noise(m, 81, 300.0, 40.0), 0.6)
			var swell := _lfo(n, n, [[2, 0.3, 0.0]])
			for cr in [[4200.0, 43, 3, 0.032, 0.022, 0.0, 1.4], [4650.0, 31, 4, 0.026, 0.018, 0.21, 0.8], [3900.0, 53, 2, 0.04, 0.025, 0.37, 0.5]]:
				var f: float = cr[0]
				var period := n / int(cr[1])
				var pulse := Synth.osc(Synth.SINE, f, f, cr[4], SR)
				for i in pulse.size():
					pulse[i] *= pow(sin(PI * float(i) / pulse.size()), 2.0)
				for c in int(cr[1]):
					var at := c * period + _at(cr[5])
					for k in int(cr[2]):
						var pos := (at + _at(k * float(cr[3]))) % n
						Synth.mix_wrap(ev, pulse, pos, float(cr[6]) * (0.7 + swell[pos]))
			var owl := Synth.make(_at(3.5))
			Synth.mix_into(owl, _call(390.0, 350.0, 0.45, 0.0, 0.0, 0.06, 0.15, 900.0), 0)
			Synth.mix_into(owl, _call(380.0, 370.0, 0.12, 0.0, 0.0, 0.02, 0.05, 900.0), _at(1.9))
			Synth.mix_into(owl, _call(400.0, 340.0, 1.0, 7.0, 50.0, 0.06, 0.3, 900.0), _at(2.0 + 0.25))
			Synth.mix_wrap(ev, owl, _at(8.0), 3.0)
		"amb_rain_light":
			_sum(bed, _noise(m, 91, 5500.0, 1400.0))
			_sum(bed, _noise(m, 92, 400.0, 60.0), 0.3)
			_patter(ev, 35.0, 0.0, 2500.0, 600.0, 0.8, 3.0, 0.4, 93)
		"amb_rain_heavy":
			var hiss := _noise(m, 101, 6000.0, 400.0)
			var drift := _lfo(m, n, [[2, 0.15, 0.0]])
			for i in m:
				hiss[i] *= 0.85 + drift[i]
			_sum(bed, hiss)
			_sum(bed, _noise(m, 102, 500.0, 50.0), 0.7)
			_patter(ev, 110.0, 0.0, 1500.0, 500.0, 0.4, 1.6, 0.3, 103)
		"amb_gale":
			# A gale: a big howl roaming up and down, a thin whistle in the strongest gusts, a heavy rush beneath.
			var howl := Synth.noise(m / float(SR), SR, 111)
			var fh := _lfo(m, n, [[3, 400.0, 0.0], [8, 200.0, 0.9]])
			var whistle := Synth.noise(m / float(SR), SR, 112)
			var fw := _lfo(m, n, [[5, 250.0, 1.4]])
			for i in m:
				fh[i] += 650.0
				fw[i] += 1150.0
			Synth.bandpass(howl, 0.0, 4.0, SR, fh)
			Synth.bandpass(whistle, 0.0, 14.0, SR, fw)
			Synth.normalise_rms(howl, 0.0)
			Synth.normalise_rms(whistle, 0.0)
			var body := _noise(m, 113, 350.0, 40.0)
			var gust := _lfo(m, n, [[3, 0.4, 0.5], [7, 0.25, 2.2]])
			for i in m:
				var e := clampf(0.35 + gust[i], 0.08, 1.2)
				howl[i] *= pow(e, 1.3)
				whistle[i] *= e * e
				body[i] *= 0.6 + 0.4 * e
			_sum(bed, howl)
			_sum(bed, whistle, 0.25)
			_sum(bed, body, 0.9)
		"amb_rain_roof":
			# Rain heard from inside: a dull drumming on slates and the tok of a gutter dripping.
			_sum(bed, _noise(m, 121, 600.0, 60.0))
			_patter(ev, 45.0, 1000.0, 100.0, 90.0, 0.6, 1.6, 0.0, 122)
			var drips := int(LENGTHS[id] / 1.6)
			for k in drips:
				Synth.mix_wrap(ev, _blip(720.0, 610.0, 0.06, 60.0), _at(0.3) + k * (n / drips), 1.4)
			Synth.lowpass(ev, 1400.0, SR)
		"train_run":
			# Wheels on rails: a rumble, a motor hum and the di-dum of bogies over the joints.
			_sum(bed, _noise(m, 131, 260.0, 35.0))
			_sum(bed, _noise(m, 132, 1200.0, 300.0), 0.35)
			var motor := Synth.osc(Synth.SAW, 85.0, 85.0, m / float(SR), SR)
			Synth.lowpass(motor, 300.0, SR)
			Synth.normalise_rms(motor, 0.0)
			_sum(bed, motor, 0.15)
			for k in 8:
				for j in 2:
					var at := _at(0.1 + k * 0.5 + j * 0.09)
					var th := Synth.osc(Synth.SINE, 140.0, 70.0, 0.07, SR)
					Synth.pluck_env(th, SR, 0.001, 45.0)
					Synth.mix_wrap(ev, th, at, 1.8)
					var ck := Synth.noise(0.03, SR, 140 + k * 2 + j)
					Synth.lowpass(ck, 2200.0, SR)
					Synth.highpass(ck, 400.0, SR)
					Synth.pluck_env(ck, SR, 0.0005, 120.0)
					Synth.mix_wrap(ev, ck, at, 1.1)
		"crossing_alarm":
			# The two-tone warble of a level crossing, high-low, high-low.
			for k in 4:
				var f := 760.0 if k % 2 == 0 else 590.0
				var t := Synth.osc(Synth.TRI, f, f, 0.25, SR)
				var h := Synth.osc(Synth.SINE, f * 2.0, f * 2.0, 0.25, SR)
				Synth.mix_into(t, h, 0, 0.3)
				Synth.lowpass(t, 2500.0, SR)
				Synth.adsr(t, SR, 0.004, 0.0, 1.0, 0.004)
				Synth.mix_into(ev, t, _at(k * 0.25))
		_:
			push_error("unknown ambience " + id)
	var out := Synth.seal_loop(bed, n, m - n)
	_sum(out, ev)
	Synth.remove_dc(out)
	Synth.normalise_rms(out, TARGET_DB[id])
	for pass_i in 4:
		if Synth.peak(out) <= LIMIT:
			break
		for i in out.size():
			out[i] = LIMIT * tanh(out[i] / LIMIT)
		Synth.normalise_rms(out, TARGET_DB[id])
	return out
