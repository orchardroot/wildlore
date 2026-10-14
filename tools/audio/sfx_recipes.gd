class_name SfxRecipes
extends RefCounted
## Sound effect recipes. Each id renders to a buffer of exactly round(LENGTHS[id] * SR) frames, peak set by PEAKS[id].

const SR := 44100

const LENGTHS := {
	"cursor": 0.06, "confirm": 0.16, "cancel": 0.16, "bump": 0.12, "door": 0.45, "step_grass": 0.12,
	"hit": 0.25, "hit_super": 0.4, "hit_weak": 0.22, "faint": 0.8, "snare_throw": 0.35, "snare_wobble": 0.4,
	"caught": 0.9, "level_up": 0.8, "heal": 0.9, "badge": 1.4, "evolve": 1.8,
	"cut": 0.3, "splash": 0.6, "scramble": 0.7, "bike_bell": 0.7, "train": 1.4, "ship_horn": 1.6,
	"crow": 0.75, "tomb_light": 1.8, "harp_gliss": 1.9,
}
const PEAKS := {
	"cursor": 0.5, "confirm": 0.6, "cancel": 0.55, "bump": 0.6, "door": 0.6, "step_grass": 0.35,
	"hit": 0.8, "hit_super": 0.9, "hit_weak": 0.5, "faint": 0.7, "snare_throw": 0.6, "snare_wobble": 0.6,
	"caught": 0.8, "level_up": 0.8, "heal": 0.7, "badge": 0.85, "evolve": 0.85,
	"cut": 0.6, "splash": 0.7, "scramble": 0.6, "bike_bell": 0.7, "train": 0.7, "ship_horn": 0.8,
	"crow": 0.75, "tomb_light": 0.7, "harp_gliss": 0.7,
}

static func ids() -> Array:
	return LENGTHS.keys()

static func _tone(kind: int, f0: float, f1: float, dur: float, a: float, d: float, s: float, r: float, lp := 0.0, duty := 0.5) -> PackedFloat32Array:
	var b := Synth.osc(kind, f0, f1, dur, SR, duty)
	if lp > 0.0:
		Synth.lowpass(b, lp, SR)
	Synth.adsr(b, SR, a, d, s, r)
	return b

## Decaying sine bell with an inharmonic-ish overtone.
static func _bell(f: float, dur: float, k: float) -> PackedFloat32Array:
	var b := Synth.osc(Synth.SINE, f, f, dur, SR)
	var h := Synth.osc(Synth.SINE, f * 2.01, f * 2.01, dur, SR)
	Synth.mix_into(b, h, 0, 0.3)
	Synth.pluck_env(b, SR, 0.002, k)
	return b

static func _noise_burst(dur: float, lp: float, hp: float, k: float, seed: int) -> PackedFloat32Array:
	var n := Synth.noise(dur, SR, seed)
	if lp > 0.0:
		Synth.lowpass(n, lp, SR)
	if hp > 0.0:
		Synth.highpass(n, hp, SR)
	Synth.pluck_env(n, SR, 0.001, k)
	return n

static func _at(sec: float) -> int:
	return Synth.frames(sec, SR)

static func render(id: String) -> PackedFloat32Array:
	var out := Synth.make(Synth.frames(LENGTHS[id], SR))
	match id:
		"cursor":
			Synth.mix_into(out, _tone(Synth.SQUARE, 1250.0, 1250.0, 0.05, 0.002, 0.02, 0.2, 0.025, 4500.0, 0.25), 0)
		"confirm":
			Synth.mix_into(out, _tone(Synth.SQUARE, 660.0, 660.0, 0.07, 0.003, 0.02, 0.6, 0.03, 3500.0, 0.3), 0)
			Synth.mix_into(out, _tone(Synth.SQUARE, 990.0, 990.0, 0.09, 0.003, 0.03, 0.5, 0.05, 3500.0, 0.3), _at(0.07))
		"cancel":
			Synth.mix_into(out, _tone(Synth.SQUARE, 600.0, 600.0, 0.07, 0.003, 0.02, 0.6, 0.03, 2500.0, 0.4), 0)
			Synth.mix_into(out, _tone(Synth.SQUARE, 400.0, 400.0, 0.09, 0.003, 0.03, 0.5, 0.05, 2500.0, 0.4), _at(0.07))
		"bump":
			var t := Synth.osc(Synth.SINE, 170.0, 65.0, 0.12, SR)
			Synth.pluck_env(t, SR, 0.002, 28.0)
			Synth.mix_into(out, t, 0)
			Synth.mix_into(out, _noise_burst(0.05, 700.0, 0.0, 60.0, 5), 0, 0.5)
		"door":
			var thump := Synth.osc(Synth.SINE, 120.0, 60.0, 0.16, SR)
			Synth.pluck_env(thump, SR, 0.002, 20.0)
			Synth.mix_into(out, thump, 0)
			Synth.mix_into(out, _noise_burst(0.1, 1800.0, 200.0, 30.0, 8), 0, 0.5)
			var creak := Synth.osc(Synth.TRI, 240.0, 190.0, 0.22, SR, 0.5, 9.0, 120.0)
			Synth.lowpass(creak, 900.0, SR)
			Synth.adsr(creak, SR, 0.05, 0.05, 0.6, 0.08)
			Synth.mix_into(out, creak, _at(0.08), 0.28)
			Synth.mix_into(out, _noise_burst(0.04, 0.0, 1500.0, 80.0, 9), _at(0.36), 0.35)
		"step_grass":
			var n := Synth.noise(0.12, SR, 12)
			Synth.lowpass(n, 3200.0, SR)
			Synth.highpass(n, 600.0, SR)
			Synth.adsr(n, SR, 0.012, 0.04, 0.3, 0.05)
			Synth.mix_into(out, n, 0)
		"hit":
			var t := Synth.osc(Synth.SINE, 260.0, 70.0, 0.22, SR)
			Synth.pluck_env(t, SR, 0.002, 16.0)
			Synth.mix_into(out, t, 0)
			Synth.mix_into(out, _noise_burst(0.1, 4500.0, 300.0, 35.0, 13), 0, 0.8)
		"hit_super":
			var t := Synth.osc(Synth.SINE, 300.0, 60.0, 0.38, SR)
			Synth.pluck_env(t, SR, 0.002, 9.0)
			Synth.mix_into(out, t, 0)
			Synth.mix_into(out, _noise_burst(0.16, 6000.0, 300.0, 22.0, 14), 0, 1.0)
			var ping := _tone(Synth.SQUARE, 880.0, 1760.0, 0.14, 0.002, 0.04, 0.5, 0.06, 5000.0, 0.25)
			Synth.mix_into(out, ping, _at(0.02), 0.35)
			Synth.mix_into(out, _bell(1320.0, 0.25, 12.0), _at(0.1), 0.3)
		"hit_weak":
			var t := Synth.osc(Synth.SINE, 150.0, 85.0, 0.2, SR)
			Synth.pluck_env(t, SR, 0.003, 18.0)
			Synth.mix_into(out, t, 0)
			Synth.mix_into(out, _noise_burst(0.08, 1300.0, 150.0, 45.0, 15), 0, 0.5)
		"faint":
			var d := Synth.osc(Synth.TRI, 520.0, 110.0, 0.8, SR, 0.5, 6.0, 60.0)
			Synth.lowpass(d, 1600.0, SR)
			Synth.adsr(d, SR, 0.02, 0.2, 0.7, 0.35)
			Synth.mix_into(out, d, 0)
		"snare_throw":
			var w := Synth.noise(0.35, SR, 16)
			Synth.lowpass_sweep(w, 500.0, 4200.0, SR)
			Synth.adsr(w, SR, 0.08, 0.1, 0.6, 0.12)
			Synth.mix_into(out, w, 0, 0.9)
			var s := Synth.osc(Synth.SINE, 300.0, 750.0, 0.3, SR)
			Synth.adsr(s, SR, 0.05, 0.05, 0.5, 0.1)
			Synth.mix_into(out, s, 0, 0.3)
		"snare_wobble":
			var w := Synth.osc(Synth.TRI, 330.0, 300.0, 0.4, SR, 0.5, 7.0, 380.0)
			Synth.lowpass(w, 1800.0, SR)
			Synth.adsr(w, SR, 0.01, 0.1, 0.6, 0.15)
			Synth.mix_into(out, w, 0, 0.8)
			Synth.mix_into(out, _noise_burst(0.03, 0.0, 1800.0, 90.0, 17), 0, 0.3)
		"caught":
			var notes := [523.25, 659.25, 783.99, 1046.5]
			for i in 4:
				Synth.mix_into(out, _bell(float(notes[i]), 0.5, 5.0), _at(0.09 * i), 0.7)
			var chord_at := _at(0.4)
			for f in [523.25, 659.25, 783.99, 1046.5]:
				Synth.mix_into(out, _bell(f, 0.5, 4.5), chord_at, 0.4)
			Synth.mix_into(out, _bell(2093.0, 0.4, 8.0), chord_at, 0.15)
		"level_up":
			var notes := [392.0, 493.88, 587.33, 783.99, 987.77]
			for i in 5:
				var t := _tone(Synth.SQUARE, float(notes[i]), float(notes[i]), 0.12, 0.003, 0.03, 0.6, 0.05, 3800.0, 0.35)
				Synth.mix_into(out, t, _at(0.075 * i), 0.5)
			for f in [783.99, 987.77, 1174.66]:
				var h := _tone(Synth.TRI, f, f, 0.4, 0.01, 0.1, 0.6, 0.25)
				Synth.mix_into(out, h, _at(0.375), 0.45)
		"heal":
			var notes := [523.25, 659.25, 783.99, 1046.5, 1318.5]
			for i in 5:
				Synth.mix_into(out, _bell(float(notes[i]), 0.55, 4.0), _at(0.11 * i), 0.6)
			Synth.mix_into(out, _bell(2093.0, 0.35, 7.0), _at(0.5), 0.25)
		"badge":
			var seq := [[392.0, 0.0, 0.14], [523.25, 0.16, 0.14], [659.25, 0.32, 0.14]]
			for s in seq:
				var t := Synth.osc(Synth.SAW, float(s[0]), float(s[0]), float(s[2]) + 0.04, SR)
				Synth.lowpass(t, 2200.0, SR)
				Synth.adsr(t, SR, 0.01, 0.03, 0.8, 0.04)
				Synth.mix_into(out, t, _at(float(s[1])), 0.5)
			for f in [392.0, 523.25, 659.25, 783.99]:
				var t := Synth.osc(Synth.SAW, f, f, 0.85, SR, 0.5, 5.5, 12.0, 0.1)
				Synth.lowpass(t, 2400.0, SR)
				Synth.adsr(t, SR, 0.02, 0.15, 0.75, 0.45)
				Synth.mix_into(out, t, _at(0.5), 0.35)
			Synth.mix_into(out, _bell(1568.0, 0.8, 4.0), _at(0.5), 0.2)
		"evolve":
			var g := Synth.osc(Synth.SINE, 220.0, 1760.0, 1.0, SR, 0.5, 11.0, 40.0)
			Synth.adsr(g, SR, 0.15, 0.1, 0.8, 0.15)
			Synth.mix_into(out, g, 0, 0.45)
			var g2 := Synth.osc(Synth.TRI, 330.0, 2640.0, 1.0, SR)
			Synth.lowpass(g2, 3000.0, SR)
			Synth.adsr(g2, SR, 0.2, 0.1, 0.6, 0.2)
			Synth.mix_into(out, g2, 0, 0.2)
			var sp := [880.0, 1108.7, 1318.5, 1760.0, 2217.4, 2637.0]
			for i in 6:
				Synth.mix_into(out, _bell(float(sp[i]), 0.4, 7.0), _at(0.35 + 0.1 * i), 0.3)
			for f in [523.25, 659.25, 783.99, 1046.5]:
				var t := Synth.osc(Synth.TRI, f, f, 0.8, SR)
				Synth.adsr(t, SR, 0.02, 0.2, 0.6, 0.5)
				Synth.mix_into(out, t, _at(1.0), 0.4)
			Synth.mix_into(out, _bell(2093.0, 0.8, 3.0), _at(1.0), 0.25)
		"cut":
			# Two snips of the shears, a twig crack, a rustle of falling bramble.
			for at in [0.0, 0.09]:
				Synth.mix_into(out, _noise_burst(0.05, 0.0, 3000.0, 70.0, 41 + int(at * 100.0)), _at(at), 0.8)
				var snap := Synth.osc(Synth.TRI, 2100.0, 1100.0, 0.04, SR)
				Synth.pluck_env(snap, SR, 0.0005, 80.0)
				Synth.mix_into(out, snap, _at(at), 0.4)
			Synth.mix_into(out, _noise_burst(0.03, 0.0, 1800.0, 90.0, 44), _at(0.17), 0.3)
			var rus := Synth.noise(0.1, SR, 45)
			Synth.lowpass(rus, 3500.0, SR)
			Synth.highpass(rus, 900.0, SR)
			Synth.adsr(rus, SR, 0.02, 0.03, 0.4, 0.05)
			Synth.mix_into(out, rus, _at(0.19), 0.2)
		"splash":
			var w := Synth.noise(0.5, SR, 51)
			Synth.lowpass_sweep(w, 4000.0, 700.0, SR)
			Synth.highpass(w, 150.0, SR)
			Synth.adsr(w, SR, 0.01, 0.12, 0.35, 0.3)
			Synth.mix_into(out, w, 0, 0.9)
			var plop := Synth.osc(Synth.SINE, 300.0, 120.0, 0.15, SR)
			Synth.pluck_env(plop, SR, 0.002, 18.0)
			Synth.mix_into(out, plop, 0, 0.5)
			var drops := [[0.12, 520.0], [0.22, 700.0], [0.31, 610.0], [0.42, 880.0]]
			for dr in drops:
				var bl := Synth.osc(Synth.SINE, float(dr[1]), float(dr[1]) * 1.9, 0.09, SR)
				Synth.pluck_env(bl, SR, 0.002, 30.0)
				Synth.mix_into(out, bl, _at(float(dr[0])), 0.3)
		"scramble":
			# Scree: a rumble underneath and a scatter of stones, thinning out.
			var rum := Synth.noise(0.7, SR, 61)
			Synth.lowpass(rum, 450.0, SR)
			Synth.adsr(rum, SR, 0.05, 0.2, 0.5, 0.35)
			Synth.mix_into(out, rum, 0, 0.7)
			var seed := 7
			var t := 0.0
			var k := 0
			while t < 0.6:
				seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
				var lp := 1200.0 + float(seed % 3000)
				var g := (1.0 - t / 0.7) * 0.7
				Synth.mix_into(out, _noise_burst(0.03, lp, 400.0, 70.0, 70 + k), _at(t), g)
				var st := Synth.osc(Synth.SINE, 500.0 + float((seed >> 8) % 600), 250.0, 0.03, SR)
				Synth.pluck_env(st, SR, 0.0005, 90.0)
				Synth.mix_into(out, st, _at(t), g * 0.4)
				seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
				t += 0.02 + float(seed % 60) / 1000.0 * (1.0 + t)
				k += 1
		"bike_bell":
			for at in [0.0, 0.16]:
				Synth.mix_into(out, _bell(2637.0, 0.5, 6.0), _at(at), 0.7)
				Synth.mix_into(out, _bell(2637.0 * 2.76, 0.4, 9.0), _at(at), 0.3)
				Synth.mix_into(out, _bell(2637.0 * 5.4, 0.2, 18.0), _at(at), 0.12)
		"train":
			# Chuff chuff chuff-chuff, then the whistle.
			for at in [0.0, 0.17, 0.34, 0.45]:
				var ch := Synth.noise(0.11, SR, 81 + int(at * 100.0))
				Synth.lowpass(ch, 1300.0, SR)
				Synth.highpass(ch, 200.0, SR)
				Synth.adsr(ch, SR, 0.015, 0.03, 0.4, 0.05)
				Synth.mix_into(out, ch, _at(at), 0.9)
				var th := Synth.osc(Synth.SINE, 90.0, 55.0, 0.09, SR)
				Synth.pluck_env(th, SR, 0.002, 25.0)
				Synth.mix_into(out, th, _at(at), 0.5)
			for f in [740.0, 932.0]:
				var wh := Synth.osc(Synth.SINE, f, f * 0.98, 0.75, SR, 0.5, 7.0, 12.0, 0.2)
				var wh2 := Synth.osc(Synth.SINE, f * 2.0, f * 2.0, 0.75, SR)
				Synth.mix_into(wh, wh2, 0, 0.18)
				var br := Synth.noise(0.75, SR, 91)
				Synth.highpass(br, 2500.0, SR)
				Synth.mix_into(wh, br, 0, 0.08)
				Synth.adsr(wh, SR, 0.04, 0.1, 0.8, 0.3)
				Synth.mix_into(out, wh, _at(0.65), 0.4)
		"ship_horn":
			for f in [110.0, 165.0, 220.0]:
				var h := Synth.osc(Synth.SAW, f, f * 0.985, 1.5, SR, 0.5, 4.0, 5.0, 0.4)
				var h2 := Synth.osc(Synth.SAW, f * 1.007, f * 0.992, 1.5, SR)
				Synth.mix_into(h, h2, 0, 0.7)
				Synth.lowpass(h, 900.0, SR)
				Synth.adsr(h, SR, 0.08, 0.12, 0.85, 0.35)
				Synth.mix_into(out, h, 0, 0.5)
		"crow":
			# Two harsh caws: a falling saw, chopped by a fast growl, with a rasp of noise on top.
			for cw in [[0.0, 0.24, 780.0, 520.0], [0.33, 0.3, 700.0, 430.0]]:
				var dur: float = cw[1]
				var c := Synth.osc(Synth.SAW, cw[2], cw[3], dur, SR)
				var c2 := Synth.osc(Synth.SAW, float(cw[2]) * 1.5, float(cw[3]) * 1.5, dur, SR)
				Synth.mix_into(c, c2, 0, 0.4)
				for i in c.size():
					c[i] *= 0.55 + 0.45 * sin(TAU * 85.0 * i / SR)
				var rasp := Synth.noise(dur, SR, 61)
				Synth.highpass(rasp, 900.0, SR)
				Synth.lowpass(rasp, 3800.0, SR)
				Synth.mix_into(c, rasp, 0, 0.35)
				Synth.lowpass(c, 2800.0, SR)
				Synth.highpass(c, 300.0, SR)
				Synth.adsr(c, SR, 0.02, 0.05, 0.8, dur * 0.4)
				Synth.mix_into(out, c, _at(cw[0]), 0.7)
		"tomb_light":
			# A rising run of glassy bells over a shimmering, slowly swelling pad.
			var semis := [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24, 26]
			for k in semis.size():
				var f := 523.25 * pow(2.0, float(semis[k]) / 12.0)
				var gain := 0.5 + 0.5 * float(k) / semis.size()
				Synth.mix_into(out, _bell(f, 0.85, 4.5), _at(0.02 + k * 0.085), gain * 0.5)
				Synth.mix_into(out, _bell(f * 3.0, 0.4, 9.0), _at(0.02 + k * 0.085), gain * 0.12)
			for f in [1046.5, 1568.0, 2093.0]:
				var sh := Synth.osc(Synth.SINE, f, f * 1.01, 1.6, SR, 0.5, 6.5, 18.0, 0.0)
				Synth.adsr(sh, SR, 0.5, 0.2, 0.6, 0.7)
				Synth.mix_into(out, sh, _at(0.1), 0.12)
		"harp_gliss":
			# Two octaves of D major plucked in a quick sweep, each string ringing on.
			var gl := [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26, 28, 29, 31, 33]
			for k in gl.size():
				var f := 146.83 * pow(2.0, float(gl[k]) / 12.0)
				var s := Synth.osc(Synth.TRI, f, f, 1.2, SR)
				var h := Synth.osc(Synth.SINE, f * 2.0, f * 2.0, 1.2, SR)
				Synth.mix_into(s, h, 0, 0.3)
				Synth.pluck_env(s, SR, 0.002, 3.2)
				Synth.mix_into(out, s, _at(k * 0.04), 0.45 + 0.02 * k)
		_:
			push_error("unknown sfx " + id)
	Synth.fade_out(out, SR, 0.008)
	Synth.fade_in(out, SR, 0.001)
	Synth.remove_dc(out)
	Synth.normalise(out, PEAKS[id])
	Synth.fade_out(out, SR, 0.004)
	return out
