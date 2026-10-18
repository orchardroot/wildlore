class_name Coats
extends RefCounted
## Uncommon coats: now and then (about 1 in 96) a wild creature turns up in a coat for the time of year. Winter
## white from November to February, russet in the autumn, sun-bleached gold in summer, a fresh green in spring;
## a gale brings out a dark storm coat, and one in four night coats is moonlit silver. A coat is only a look:
## Creature.variant holds it ("" for the usual one) and nothing in battle reads it.
## The Fieldbook notes each coat seen or caught in the flag coat_<species>_<variant> ("seen" or "caught").
## Pure logic: no autoload names (the validator loads things that load this).

const CHANCE := 1.0 / 96.0
const MOONLIT_SHARE := 0.25
const STORM_WEATHER := ["gale", "storm", "thunder"]
const ALL := ["spring", "summer", "autumn", "winter", "storm", "moonlit"]
const NAMES := {
	"spring": "Spring green", "summer": "Summer gold", "autumn": "Autumn russet", "winter": "Winter white",
	"storm": "Storm dark", "moonlit": "Moonlit",
}
## The battle line when one turns up.
const INTRO := {
	"winter": "Its coat has gone winter white. Lovely.",
	"autumn": "Its coat has turned russet, like the bracken. Lovely.",
	"summer": "Its coat is sun-bleached gold. Someone's been on holiday.",
	"spring": "Its coat has a fresh green tinge, like new leaves. Lovely.",
	"storm": "Its coat is storm dark, slate and thunder. Gorgeous.",
	"moonlit": "Its coat shines silver in the moonlight. Oh, look at that.",
}
## Four palette stops each, shadow to highlight: the sprite's brightness is mapped along them (see CoatArt).
## Chosen by eye against the HD-2D grade: never pure white or black, so it still sits in the scene.
const PALETTES := {
	"winter": [Color("4d5b78"), Color("a9b8cf"), Color("e6ecf2"), Color("fdfcf6")],
	"autumn": [Color("3e1416"), Color("8c2f1e"), Color("d2752e"), Color("f7d68e")],
	"summer": [Color("5c4318"), Color("b38a34"), Color("e6c96a"), Color("fff3c4")],
	"spring": [Color("1f4a3a"), Color("4f9e62"), Color("a6dc8c"), Color("f4fde2")],
	"storm": [Color("121826"), Color("2e3e58"), Color("5d7894"), Color("bfe4f2")],
	"moonlit": [Color("28224e"), Color("6a62ae"), Color("b8b2ea"), Color("f7f3ff")],
}
## A swatch colour per coat for the Fieldbook and the summary.
static func swatch(v: String) -> Color:
	var p: Array = PALETTES.get(v, [])
	return p[2] if p.size() > 2 else Color("8c8c8c")

## The seasonal coat for a month: winter is November to February here (a coat takes a while to come in).
static func season_coat(month: int) -> String:
	match month:
		11, 12, 1, 2:
			return "winter"
		9, 10:
			return "autumn"
		6, 7, 8:
			return "summer"
	return "spring"

## Which coat an uncommon creature wears: storm in a gale, moonlit for `u` < 1/4 at night, else the season's.
static func pick(month: int, weather: String, phase: String, u: float) -> String:
	if weather in STORM_WEATHER:
		return "storm"
	if phase == "night" and u < MOONLIT_SHARE:
		return "moonlit"
	return season_coat(month)

## A wild creature's coat: "" nearly always. Two rolls, both on the game's seeded Rng.
static func roll(rng: Rng, month: int, weather: String, phase: String) -> String:
	if rng.roll() >= CHANCE:
		return ""
	return pick(month, weather, phase, rng.roll())

static func intro_line(v: String) -> String:
	return str(INTRO.get(v, ""))

static func name_of(v: String) -> String:
	return str(NAMES.get(v, ""))

# --- the Fieldbook --------------------------------------------------------------

static func flag_key(species_id: String, v: String) -> String:
	return "coat_%s_%s" % [species_id, v]

static func record_seen(data: GameStateData, c: Creature) -> void:
	if c == null or c.variant == "":
		return
	var k := flag_key(str(c.species.id), c.variant)
	if data.flag(k) != "caught":
		data.set_flag(k, "seen")

static func record_caught(data: GameStateData, c: Creature) -> void:
	if c != null and c.variant != "":
		data.set_flag(flag_key(str(c.species.id), c.variant), "caught")

## "seen", "caught" or "".
static func status(data: GameStateData, species_id: String, v: String) -> String:
	var s: Variant = data.flag(flag_key(species_id, v))
	return str(s) if s is String else ""

## {"seen": n, "caught": n} over every coat flag (seen includes caught).
static func counts(data: GameStateData) -> Dictionary:
	var out := {"seen": 0, "caught": 0}
	for k in data.flags:
		if str(k).begins_with("coat_"):
			out.seen += 1
			if data.flags[k] == "caught":
				out.caught += 1
	return out

## The Stats page row: "3 seen, 1 caught" (or "None yet").
static func stats_line(data: GameStateData) -> String:
	var n := counts(data)
	if n.seen == 0:
		return "None yet"
	return "%d seen, %d caught" % [n.seen, n.caught]
