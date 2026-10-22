extends TestCase
## Wave 45 session C: 33 species that stopped too early gain an evolved form. Each is in its line file, has a
## recipe and sprites, an evolution that teaches something, and a Fieldbook entry with one true thing.

const NEW := {
	"binfox": "brushmaster", "dipling": "rapidipper", "hootlet": "hootenanny", "cragchough": "choughtain",
	"loaghtan": "hexhorn", "gwyllgi": "annwnhound", "brownie": "gruagach", "bansheen": "keenwife",
	"flittermouse": "noctulord", "natterjack": "natterchoir", "pincray": "signalclaw", "petrelash": "tempestrel",
	"churrjar": "nightchurr", "macaquet": "rockape", "barkdeer": "tuskbark", "afanc": "damlord",
	"azurana": "azurex", "roachroo": "peakaroo", "clearfin": "glaciefin", "glimmerjaw": "abyssjaw",
	"haarling": "fretlord", "minchman": "bluechief", "whiffhorn": "pongifex", "scorchbun": "tinderhulk",
	"prismite": "spectrumite", "moggle": "mouser", "donkey": "sandtrot", "flamingale": "carotenor",
	"cahowl": "cahowler", "gritling": "edgelord", "wispet": "corpsecandle", "stagmor": "glenmonarch",
	"reindeer": "sleighlord"}

var dex := Dex.load_default()

func _bst(id: String) -> int:
	var t := 0
	for s in Rules.STATS:
		t += int(dex.get_species(id).base[s])
	return t

func test_at_least_thirty_new_forms() -> void:
	assert_true(NEW.size() >= 30, "%d new evolved forms" % NEW.size())

func test_each_form_is_wired_in() -> void:
	var moves := MoveDB.load_default()
	for base in NEW:
		var to: String = NEW[base]
		assert_true(dex.has(to), to + " exists")
		var evo = dex.get_species(base).evolves
		assert_true(evo is Dictionary and str(evo.to) == to, "%s evolves into %s" % [base, to])
		assert_true(Dex.in_appendix(to), to + " stays out of the original 200")
		var sp := dex.get_species(to)
		assert_eq(sp.evolves, null, to + " is the end of the line")
		assert_true(_bst(to) > _bst(base), "%s is stronger than %s" % [to, base])
		assert_true(_bst(to) <= 540, "%s: %d is in line with the other finals" % [to, _bst(to)])
		var fresh := 0
		for entry in sp.learnset:
			assert_true(moves.has(str(entry[1])), "%s knows a real move" % to)
			if int(entry[0]) >= int(evo.level):
				fresh += 1
		assert_true(fresh >= 3, "%s learns new moves after evolving" % to)
		assert_true(str(sp.dex.text) != "" and str(sp.dex.fact) != "", to + " has Fieldbook text and a fact")
		assert_false("—" in str(sp.dex.text) or "—" in str(sp.dex.fact), to + ": no em-dashes")

func test_each_form_has_art() -> void:
	for base in NEW:
		var to: String = NEW[base]
		assert_true(FileAccess.file_exists("res://art/recipes/creatures/%s.json" % to), to + " recipe")
		for suffix in ["front", "back", "icon"]:
			assert_true(FileAccess.file_exists("res://art/sprites/creatures/%s_%s.png" % [to, suffix]), "%s %s" % [to, suffix])

func test_evolutions_teach_something() -> void:
	var gated := 0
	for base in NEW:
		var evo: Dictionary = dex.get_species(base).evolves
		if evo.has("season") or evo.has("zone") or evo.has("flag") or evo.has("time") or evo.has("weather") or evo.has("bond"):
			gated += 1
		if evo.has("flag"):
			assert_true(str(evo.flag).begins_with("lang_cert_"), "%s: flags are language certificates" % base)
			assert_true(str(evo.get("flag_text", "")) != "", "%s says what the flag means" % base)
	assert_true(gated >= 25, "%d forms have a condition beyond a level" % gated)

func test_a_condition_holds_the_evolution_back() -> void:
	var c := Creature.new()
	c.species = dex.get_species("hootlet")
	c.level = 40
	assert_eq(Progression.evolution_target(c, {"season": "spring", "time": "night"}), "")
	assert_eq(Progression.evolution_target(c, {"season": "autumn", "time": "day"}), "")
	assert_eq(Progression.evolution_target(c, {"season": "autumn", "time": "night"}), "hootenanny")
