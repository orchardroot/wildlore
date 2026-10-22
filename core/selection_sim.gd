class_name SelectionSim
extends RefCounted
## The moor model (wave 45 session N): natural selection you can watch. A population of diploid creatures with one
## colour gene, D dark (dominant) and d pale; predators take the ones that stand out against the backdrop, and the
## survivors breed. Pure logic, seeded, no autoloads. Two scenarios:
##  - "moor"        a toy moor, one step a season: heather and peat favour a dark coat, a snowy winter a pale one. The
##                  survivors breed once a year, after winter. `climate` "snowy" or "mild" (no snow lying) shows how a
##                  change in winters shifts the balance. A model, not a real study, and it says so.
##  - "manchester"  the peppered moth round Manchester, one step a year from 1840 to 2000: no dark moths until the first
##                  is recorded in 1848, soot from the 1850s, the Clean Air Act of 1956, and a little gene flow from moths
##                  flying in from the cleaner countryside. The shape is history's; the numbers are the model's.
## Nothing is stored: the screen makes a new one each time.

const N := 400                 # the population the sums run on
const SHOWN := 60              # how many the screen draws
const SEASONS := ["spring", "summer", "autumn", "winter"]
const MIGRANTS := 0.03         # share of each Manchester generation that flew in from the countryside
const MIGRANT_DARK := 0.05     # dark allele frequency out there
const MUTATION := 0.0005       # a pale allele turning dark, per copy passed on (Manchester, from 1848)
const START_YEAR := 1840
const END_YEAR := 2000
const FIRST_DARK := 1848

const SCENARIOS := {
	"moor": {"name": "The moor", "blurb": "A toy moor. Heather hides a dark coat; snow hides a pale one. One step is a season."},
	"manchester": {"name": "Manchester, 1840 to 2000", "blurb": "Peppered moths on soot and lichen. One step is a year."},
}

var scenario := "moor"
var climate := "snowy"
var rng: Rng
var t := 0                     # steps taken
var pop: Array = []            # genotypes: the number of dark copies, 0 to 2
var history: Array = []        # dark share after each step, the first entry the start
var last_eaten := {"dark": 0, "pale": 0}

func _init(scenario_id := "moor", seed_value := 1, climate_id := "snowy") -> void:
	scenario = scenario_id if SCENARIOS.has(scenario_id) else "moor"
	climate = climate_id
	rng = Rng.new(seed_value)
	pop.resize(N)
	for i in N:
		if scenario == "moor":
			pop[i] = (1 if rng.roll() < 0.4 else 0) + (1 if rng.roll() < 0.4 else 0)
		else:
			pop[i] = 0
	history.append(dark_fraction())

static func dark(g: int) -> bool:
	return g > 0

func dark_fraction() -> float:
	if pop.is_empty():
		return 0.0
	var n := 0
	for g in pop:
		if int(g) > 0:
			n += 1
	return float(n) / pop.size()

## The share of copies that are dark (the allele frequency, as against the share of creatures that look dark).
func dark_allele() -> float:
	var n := 0
	for g in pop:
		n += int(g)
	return float(n) / (2.0 * maxi(1, pop.size()))

func year() -> int:
	return START_YEAR + t if scenario == "manchester" else int(t / 4.0)

func finished() -> bool:
	return scenario == "manchester" and year() >= END_YEAR

## How dark the trees are round Manchester, 0 clean lichen to 1 black with soot.
static func soot(y: int) -> float:
	if y < 1850:
		return 0.0
	if y < 1880:
		return (y - 1850) / 30.0
	if y < 1956:
		return 1.0
	if y < 1986:
		return 1.0 - (y - 1956) / 30.0
	return 0.0

## This step's backdrop: {season, dark (0 to 1), text}.
func backdrop() -> Dictionary:
	if scenario == "manchester":
		var y := year()
		var s := soot(y)
		var text := "Pale lichen on the bark"
		if y >= 1956 and s > 0.0:
			text = "Clean Air Act, 1956: the soot is lifting"
		elif s >= 1.0:
			text = "Bark black with soot from the mills"
		elif s > 0.0:
			text = "Soot spreading from the mills"
		return {"season": "", "dark": s * 0.9, "text": text}
	var season: String = SEASONS[t % 4]
	if season == "winter" and climate == "snowy":
		return {"season": season, "dark": 0.0, "text": "Winter: snow lying on the moor"}
	var words := {"spring": "Spring: dark peat and old heather", "summer": "Summer: heather in flower",
		"autumn": "Autumn: brown bracken and heather", "winter": "Winter: a mild one, no snow lying"}
	return {"season": season, "dark": 1.0, "text": words[season]}

## The chance a dark and a pale creature live through this step: [dark, pale].
func survival() -> Array:
	var b := backdrop()
	if scenario == "manchester":
		var d := float(b.dark)
		return [0.5 + 0.4 * d, 0.9 - 0.4 * d]
	if b.season == "winter":
		return [0.45, 0.95] if climate == "snowy" else [0.9, 0.75]
	return [0.9, 0.75]

## One step: the predators take their share, then (once a year on the moor, every year in Manchester) the survivors breed.
func step() -> void:
	if finished():
		return
	var s := survival()
	var kept := []
	last_eaten = {"dark": 0, "pale": 0}
	for g in pop:
		var is_dark := int(g) > 0
		if rng.roll() < float(s[0] if is_dark else s[1]):
			kept.append(g)
		else:
			last_eaten["dark" if is_dark else "pale"] += 1
	var breeds: bool = scenario == "manchester" or SEASONS[t % 4] == "winter"
	pop = _breed(kept) if breeds else kept
	t += 1
	if scenario == "manchester" and year() == FIRST_DARK:
		pop[0] = 1  # the first dark peppered moth on record
		pop[1] = 1
	history.append(dark_fraction())

func _breed(parents: Array) -> Array:
	if parents.size() < 2:
		parents = [0, 1] if parents.is_empty() else [parents[0], parents[0]]
	var out := []
	out.resize(N)
	var mutate := scenario == "manchester" and year() >= FIRST_DARK
	for i in N:
		if scenario == "manchester" and rng.roll() < MIGRANTS:
			out[i] = (1 if rng.roll() < MIGRANT_DARK else 0) + (1 if rng.roll() < MIGRANT_DARK else 0) if mutate else 0
			continue
		out[i] = _copy(int(parents[rng.roll_int(0, parents.size() - 1)]), mutate) \
			+ _copy(int(parents[rng.roll_int(0, parents.size() - 1)]), mutate)
	return out

## One copy passed on by a parent with `g` dark copies: 1 dark, 0 pale.
func _copy(g: int, mutate: bool) -> int:
	var c := 1 if rng.roll() < g / 2.0 else 0
	if c == 0 and mutate and rng.roll() < MUTATION:
		c = 1
	return c

## What the screen draws: SHOWN creatures, true for dark. The first SHOWN of the population, as many as there are.
func sample() -> Array:
	var out := []
	for i in SHOWN:
		out.append(int(pop[i % maxi(1, pop.size())]) > 0 if not pop.is_empty() else false)
	return out
