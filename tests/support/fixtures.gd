class_name Fixtures
extends RefCounted
## Shared builders for tests: real data where it exists, tiny hand-made species where a test needs something odd.

static var _chart: TypeChart
static var _dex: Dex
static var _moves: MoveDB

static func chart() -> TypeChart:
	if _chart == null:
		_chart = TypeChart.load_default()
	return _chart

static func dex() -> Dex:
	if _dex == null:
		_dex = Dex.load_default()
	return _dex

static func moves() -> MoveDB:
	if _moves == null:
		_moves = MoveDB.load_default()
	return _moves

## Zero IVs, no training, "steady" nature: stats are exactly predictable.
static func creature(species_id: String, level: int) -> Creature:
	return Creature.create(dex().get_species(species_id), level, FixedRng.new(), moves())

## A normalised hand-made species, for tests that need types or stats no real creature has.
static func species(id: String, types: Array, base := 50, extra := {}) -> Dictionary:
	var sp := {"id": id, "name": id.capitalize(), "types": types, "base": {},
		"growth": "medium", "catch_rate": 45, "base_xp": 60, "learnset": [[1, "scrap"]],
		"evolves": null, "habitat": [], "dex": {"text": "t", "fact": "f"}, "sprite": id}
	for s in Rules.STATS:
		sp.base[s] = base
	sp.merge(extra, true)
	return Dex.normalise(sp)

static func battle(player: Array, foe: Array, opts := {}) -> Battle:
	var o := {"chart": chart(), "move_db": moves(), "rng": FixedRng.new()}
	o.merge(opts, true)
	return Battle.new(player, foe, o)
