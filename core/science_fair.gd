class_name ScienceFair
extends RefCounted
## Science fair puzzles (Isles of Invention, 4.5), each teaching one idea by doing it:
##   binary  set the lamps to make a number, as the Manchester Baby held numbers: each lamp is worth double the next
##   cipher  turn a shift wheel until a Caesar-shifted word reads true, the oldest cipher there is
##   dna     write the partner strand of a bit of DNA: A pairs with T, C pairs with G
## Pure logic, no autoload names: puzzles come from an Rng so tests can pin them. ui/science_fair_screen.gd plays them.

const KINDS := ["binary", "cipher", "dna"]
const BASES := ["A", "C", "G", "T"]
const PAIR := {"A": "T", "T": "A", "C": "G", "G": "C"}
## Words for the cipher: short, plain, and all to do with these isles' science.
const WORDS := ["ENIGMA", "COLOSSUS", "TURING", "LOVELACE", "BABBAGE", "FARADAY", "MAXWELL", "DARWIN", "FRANKLIN",
	"BLETCHLEY", "TELEGRAPH", "RADAR", "PULSAR", "ATOM", "ROCKET", "DYNAMO", "HELIX", "BOMBE", "MORSE", "CIPHER"]
const TIPS := {
	"binary": "Each lamp is worth twice the one to its right: 1, 2, 4, 8, 16. Light the ones that add up to the number. The Manchester Baby stored every number like this, as dots on a screen: on or off, one or nought.",
	"cipher": "Julius Caesar shifted every letter the same number of places along the alphabet. Turn the wheel until the word makes sense. Enigma changed its shift with every key pressed, which is why it took the Bombe to break it.",
	"dna": "DNA is two strands zipped together, and the letters always pair the same way: A with T, C with G. Know one strand and you know the other. That is how a cell copies itself.",
}
const TITLES := {"binary": "Count like the Baby", "cipher": "Break the shift cipher", "dna": "Zip up the DNA"}

## A fresh puzzle of `kind`. `hard` makes it bigger (8 lamps, a longer strand). Always solvable.
static func make(kind: String, rng: Rng, hard := false) -> Dictionary:
	match kind:
		"binary":
			var bits := 8 if hard else 5
			return {"kind": kind, "bits": bits, "target": rng.roll_int(1, (1 << bits) - 1)}
		"cipher":
			var word: String = WORDS[rng.roll_int(0, WORDS.size() - 1)]
			var shift := rng.roll_int(1, 25)
			return {"kind": kind, "word": word, "shift": shift, "coded": shift_text(word, shift)}
		"dna":
			var n := 10 if hard else 6
			var s := ""
			for i in n:
				s += BASES[rng.roll_int(0, 3)]
			return {"kind": kind, "strand": s}
	return {}

## The number a row of lamps shows (index 0 is the leftmost, worth the most).
static func lamps_value(lamps: Array) -> int:
	var v := 0
	for b in lamps:
		v = v * 2 + (1 if b else 0)
	return v

## Place values left to right, e.g. [16, 8, 4, 2, 1].
static func place_values(bits: int) -> Array:
	var out := []
	for i in bits:
		out.append(1 << (bits - 1 - i))
	return out

## Shifts capital letters along the alphabet by `n` (wrapping); anything else is left alone.
static func shift_text(text: String, n: int) -> String:
	var out := ""
	for ch in text:
		var c := ch.unicode_at(0)
		if c >= 65 and c <= 90:
			out += char(65 + posmod(c - 65 + n, 26))
		else:
			out += ch
	return out

## What the coded word reads as with the wheel turned back by `guess`.
static func decode(p: Dictionary, guess: int) -> String:
	return shift_text(str(p.coded), -guess)

static func partner(strand: String) -> String:
	var out := ""
	for ch in strand:
		out += str(PAIR.get(ch, "?"))
	return out

## Is this answer right? binary: an Array of lamps; cipher: the shift guessed (int); dna: the partner String.
static func solved(p: Dictionary, answer: Variant) -> bool:
	match str(p.get("kind", "")):
		"binary":
			return answer is Array and (answer as Array).size() == int(p.bits) and lamps_value(answer) == int(p.target)
		"cipher":
			return typeof(answer) in [TYPE_INT, TYPE_FLOAT] and decode(p, int(answer)) == str(p.word)
		"dna":
			return answer is String and answer == partner(str(p.strand))
	return false
